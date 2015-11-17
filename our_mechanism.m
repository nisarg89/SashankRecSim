function [weights] = our_mechanism(G,is_voting,v)
%% Our Mechanism (Computes the weights)
% Graph G, set of voters (is_voting), central node v

n = size(G,1);

% Finds articulation points, and which biconnected component each edge belongs to
[a,C] = biconnected_components(G,'nocheck',1); % 'nocheck' = 1 prevents it from checking if the matrix is symmetric. Must pass a symmetric matrix.
[~,J,V] = find(C); % find(C) lists all edges and the component they belong to.
num_blocks = max(V); % Number of biconnected components

% % Debugging for out.maayan-vidal
% display(V(J==1));
% display(V(J==10));

% We use unique to get a single entry (u,B) for every node u \in component B. This has multiple entries for articulation points and a single entry for every other node. 
TMP = unique([J V],'rows');

% We store both the block tree and its transpose. Sparse matrices are efficiently accessible only via columns, but we also need all rows. 
block_tree = sparse(TMP(:,1),TMP(:,2),1,n,num_blocks);
block_tree_t = transpose(block_tree);

% % Debugging for out.maayan-vidal
% display(num_blocks);
% display(block_tree(1,1));
% display(block_tree(1,1068));
% display(block_tree(10,1));
% display(block_tree(10,1068));

% Is the node an articulation point?
is_articulation = false(1,n); % Boolean vector indicating if the node is an articulation point
is_articulation(a) = true;

% Call the node on v. Total weight to be distributed is 1. No block to ignore. 
[weights,~] = our_mechanism_helper(v,-1);
% assert(has_voting);
weights = full(weights);

    %% Finds the weights of nodes in the lobe of u. 
    % The weight to be distributed is w. 
    % Assumes all components except ignoreBlock are in the lobe of u (ignoreBlock is at u's "level").
    function [current_weights,has_voting] = our_mechanism_helper(u,ignoreBlock)
        current_weights = zeros(1,n);
        N = 0; % Number of legitimate "voting" nodes (either voting directly or someone in its lobe is voting)

        % Inspect every node in every component containing u (except ignoreBlock)
        ListBlocks = find(block_tree_t(:,u)>0)';
%         assert(ignoreBlock==-1 || any(ListBlocks==ignoreBlock));
        ListBlocks = ListBlocks(ListBlocks~=ignoreBlock);
        for B = ListBlocks
            ListNodes = find(block_tree(:,B)>0)';
            for t = ListNodes
                if is_voting(t) % If voting, count its vote. Note: u must be a non-voter because we do not call this routine on voters.
                    current_weights(t) = 1; N = N+1;
                elseif is_articulation(t) && t ~= u % If not voting but has a lobe, call the mechanism recursively to find its recommendation. 
                    [temp_weights,temp_has_voting] = our_mechanism_helper(t,B);
                    if temp_has_voting
                        current_weights = current_weights + temp_weights;
                        N = N+1;
                    end
                end
            end
        end
        if N > 0
            has_voting = true;
            current_weights = current_weights/N;
        else
            has_voting = false;
            current_weights = [];
        end
    end

end