function [rec] = random_walk_rec(G,is_voting,votes,v)
%% Random Walk (Computes the recommendation)
% Graph G, set of voters (is_voting), set of votes (votes), central node v

n = length(is_voting);
deg = sum(G,2); % Find degrees

% System of Linear Equations
% A: One constraint for each node u: 
%    u's coefficient = 1, and 
%    if u is non-voter, then -1/deg(u) for each neighbor of u.
% B: If u is voter, B(u) = vote(u), else 0. 
%    It's fine that both voters voting 0 and non-voters have the same value.
%    We are simply finding the probability of ending up at 1.
A = speye(n)-bsxfun(@times,~is_voting(:)./deg,G);
B = votes(:) & is_voting(:);
solution = A\B; % solution(u) contains the recommendation at node u
rec = solution(v);
end