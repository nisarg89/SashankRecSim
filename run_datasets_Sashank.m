% Run Simulations
nVertexSim = 100; % Number of vertices to average over
nSim = 100;   % Number of samples for voters
nInSim = 100; % Number of samples of votes to determine accuracy (fast, given weights are pre-computed)

addpath('./matlab_bgl');

maxNumCompThreads(15);

% Where to store the results
resultsDir = './RecResults';
if ~exist(resultsDir, 'dir')
    mkdir(resultsDir);
end

% Get the datasets
datasetDir = './KONECT';
tmp = dir(datasetDir);
[~,I] = sort([tmp.bytes]);
tmp = {tmp.name};
tmp = tmp(I);
datasets = tmp(3:end);
clear tmp;
% datasets = datasets(~strcmp(datasets,'out.maayan-vidal'));
numDatasets = length(datasets);

% List of all mechanisms
uniform_weights = @(~,is_voting,~) is_voting/sum(is_voting);
mechList = {@our_mechanism,@random_walk,uniform_weights,@single_depth};
mechNames = {'Legit+','Random Walk','Uniform Weights','Legit'};
numMech = length(mechList);

% List of p_vote values (probability of voting)
p_vote_list = [0.01:0.02:0.09 0.1:0.2:0.9];
npVote = length(p_vote_list);

% List of p_acc values (probability of being correct given voting)
p_acc_list = [0.51:0.02:0.59 0.6:0.1:0.9];
npAcc = length(p_acc_list);

% Results
nodeStatsNames = {'NumConsidered','L2Norm','LeximinBetter'};
numNodeStats = length(nodeStatsNames);

timeStats = zeros(numDatasets,npVote,nVertexSim,nSim,numMech); % Running time
nodeStats = zeros(numDatasets,npVote,nVertexSim,nSim,numMech,numNodeStats); % Number of nodes given positive weight to
accStats = zeros(numDatasets,npVote,npAcc,nVertexSim,nSim,numMech);  % Accuracy
skippedDatasets = false(1,numDatasets);
disconnectedDatasets = false(1,numDatasets);

if isempty(gcp('nocreate')) % Create parallel pool if it doesn't already exist
    parpool(15);
end

for datasetID=1:numDatasets
    % Get the graph
    datasetName = datasets{datasetID};
    G = read_dataset([datasetDir '/' datasetName]);
    [~,C] = graphconncomp(G,'Directed',false);
    if max(C) > 1
        disconnectedDatasets(datasetID) = true;
        largest_component = mode(C);
        init_nodes = find(C==largest_component);
        G = G(init_nodes,init_nodes);
        clear largest_component init_nodes;
    end
    clear C;
    n = size(G,1);
    fprintf('\nDataset %d/%d: %s\n',datasetID,numDatasets,datasetName);

    % Test if biconnected component fails on this graph
    [a,C] = biconnected_components(G,'nocheck',1);
    [~,J,V] = find(C);
    num_blocks = max(V);
    TMP = unique([J V],'rows');  
    block_tree = sparse(TMP(:,1),TMP(:,2),1,n,num_blocks);
    is_tree = graphisspantree([sparse(n,n) block_tree; block_tree' sparse(num_blocks,num_blocks)]);
    if ~is_tree
        fprintf('Biconnected components fails on this dataset. Skipping!\n');
        skippedDatasets(datasetID) = true;
        continue;
    end
    clear a C J V num_blocks block_tree is_tree;

    % For each probability of node being voting
    for p_vote_id = 1:npVote
        p_vote = p_vote_list(p_vote_id);
        fprintf('p_vote = %.2f\n',p_vote);
        parfor vertexID = 1:nVertexSim
            v = randi(n);
            tempTimeStats = zeros(nSim,numMech);
            tempNodeStats = zeros(nSim,numMech,numNodeStats);
            tempAccStats = zeros(npAcc,nSim,numMech);
            for simID = 1:nSim
                % Decide which nodes are voting
                is_voting = rand(1,n)<=p_vote; is_voting(v) = 0;   % The node we want to recommend to does not vote.
                while all(~is_voting) % Make sure that there is at least one voting node
                    is_voting = rand(1,n)<=p_vote; is_voting(v) = 0;
                end
                num_voters = sum(is_voting);

                weights = zeros(numMech,n);
                for mechID = 1:numMech
                    tic; weights(mechID,:) = mechList{mechID}(G,is_voting,v); tempTimeStats(simID,mechID) = toc;
%                     assert(all(weights(mechID,~is_voting)<1e-5)); % All non-voting nodes must have weight 0
%                     assert(abs(sum(weights(mechID,:))-1)<1e-5); % The weights must sum to 1

                    % Node Statistics
                    tempNodeStats(simID,mechID,1) = sum(weights(mechID,:) > 0);
                    tempNodeStats(simID,mechID,2) = norm(weights(mechID,is_voting)-ones(1,num_voters)/num_voters);
                end
                assert(~any(weights(1,:)==0 & weights(2,:)>0));
                
                % Remaining Node Statistics
                ourSorted = sort(weights(1,:));
                RWSorted = sort(weights(2,:));
                SingleDepthSorted = sort(weights(4,:));
                if isequal(ourSorted,RWSorted)
                    tempNodeStats(simID,2,3) = 0.5;
                else
                    [~,index] = sortrows([ourSorted;RWSorted]);
                    tempNodeStats(simID,2,3) = index(2)==2;
                end
                if isequal(ourSorted,SingleDepthSorted)
                    tempNodeStats(simID,4,3) = 0.5;
                else
                    [~,index] = sortrows([ourSorted;SingleDepthSorted]);
                    tempNodeStats(simID,4,3) = index(2)==2;
                end
                
                % For each p_acc_id, compute the accuracy. 
                for p_acc_id = 1:npAcc
                    p_acc = p_acc_list(p_acc_id);
                    votes = bsxfun(@times,is_voting',rand(n,nInSim)<=p_acc);
                    tempAccStats(p_acc_id,simID,[1 2 4]) = mean(weights([1 2 4],:) * votes >= 0.5,2);
                    % Can exactly compute the accuracy of uniform
                    uniform_acc = binocdf(ceil(num_voters/2)-1,num_voters,p_acc,'upper');
                    tempAccStats(p_acc_id,simID,3) = uniform_acc;
                end
            end
            timeStats(datasetID,p_vote_id,vertexID,:,:) = tempTimeStats;
            nodeStats(datasetID,p_vote_id,vertexID,:,:,:) = tempNodeStats;
            accStats(datasetID,p_vote_id,:,vertexID,:,:) = tempAccStats;
%             fprintf('.\n');
        end
    end
    % Save the results
    save([resultsDir '/results_datasets_last4'],...
        'datasetID','datasetDir','datasets','numDatasets',...
        'skippedDatasets','disconnectedDatasets',...
        'nodeStatsNames','numNodeStats',...
        'mechList','mechNames','numMech',...
        'p_vote_list','npVote','p_acc_list','npAcc','nVertexSim','nSim','nInSim',...
        'timeStats','nodeStats','accStats');
end
fprintf('\n');

% if ~isempty(gcp('nocreate')) % If a pool exists
%     delete(gcp);
% end
