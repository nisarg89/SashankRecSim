function [rec] = our_mechanism_rec(G,is_voting,votes,v)
%% Our Mechanism (Computes the recommendation)
% Graph G, set of voters (is_voting), set of votes (votes), central node v

n = size(G,1);

% Finds articulation points, and which biconnected component each edge belongs to
[a,C] = biconnected_components(G,'nocheck',1); % 'nocheck' = 1 prevents it from checking if the matrix is symmetric. Must pass a symmetric matrix.
[~,J,V] = find(C); % find(C) lists all edges and the component they belong to.
num_blocks = max(V); % Number of biconnected components

% We use unique to get a single entry (u,B) for every node u \in component B. This has multiple entries for articulation points and a single entry for every other node. 
TMP = unique([J V],'rows');  

% We store both the block tree and its transpose. Sparse matrices are efficiently accessible only via columns, but we also need all rows. 
block_tree = sparse(TMP(:,1),TMP(:,2),1,n,num_blocks);
block_tree_t = transpose(block_tree);

% Is the node an articulation point?
is_articulation = false(1,n);
is_articulation(a) = true;

% Call the node on v. No block to ignore. 
[rec,has_voting] = our_mechanism_helper(v,-1);
assert(has_voting);

    %% Finds the recommendation for u. Assumes all components except ignoreBlock are in the lobe of u (ignoreBlock is at u's "level").
    function [current_rec,has_voting] = our_mechanism_helper(u,ignoreBlock) 
        current_rec = 0;
        N = 0; % Number of legitimate "voting" nodes (either voting directly or someone in its lobe is voting)
        
        % Inspect every node in every component containing u (except ignoreBlock)
        ListBlocks = find(block_tree_t(:,u)>0)'; 
        ListBlocks = ListBlocks(ListBlocks~=ignoreBlock);
        for B = ListBlocks
            ListNodes = find(block_tree(:,B)>0)';
            for t = ListNodes
                if is_voting(t) % If voting, count its vote. Note: u must be a non-voter because we do not call this routine on voters.
                    current_rec = current_rec + votes(t); N = N+1;
                elseif is_articulation(t) && t ~= u % If not voting but has a lobe, call the mechanism recursively to find its recommendation. 
                    [temp_rec,temp_has_voting] = our_mechanism_helper(t,B);
                    if temp_has_voting
                        current_rec = current_rec + temp_rec;
                        N = N+1;
                    end
                end
            end
        end
        if N > 0
            has_voting = true;
            current_rec = current_rec/N;
        else
            has_voting = false;
        end
    end

end