function [weights] = random_walk_opt(G,is_voting,v)
%% Random Walk (Computes the weights)
% Graph G, set of voters (is_voting), central node v

% fprintf('Starting BFS\n');
n = length(is_voting);
finished = false(1,n);
active = false(1,n);
active(v) = true;
while true
    u = find(active,1);
    if isempty(u) || u > length(active)
        break;
    end
    active(u) = false;
    finished(u) = true;
    if ~is_voting(u)
        neigh = find(G(:,u)>0)';
        active(neigh(~finished(neigh))) = true;
    end
end
pos_weight_nodes = find(finished & is_voting);
% fprintf('Ending BFS\n');

num_voters = sum(is_voting);
deg = sum(G,2); % Find degrees

A = speye(n)-bsxfun(@times,~is_voting(:)./deg,G);
weights = zeros(1,n);

for u = pos_weight_nodes
    b = sparse(u,1,1,n,1);
    [sol,~] = gmres(A,b,15,1e-6,1000);
    weights(u) = sol(v);
end
end