function [weights] = random_walk(G,is_voting,v)
%% Random Walk (Computes the weights)
% Graph G, set of voters (is_voting), central node v

n = length(is_voting);
num_voters = sum(is_voting);
deg = sum(G,2); % Find degrees

% System of Linear Equations
% A: One constraint for each node u: 
%    u's coefficient = 1, and 
%    if u is non-voter, then -1/deg(u) for each neighbor of u.
% B: One column (i.e., one system of linear equation) for each voter u. 
%    In that column, RHS for u is 1, everything else is 0. 
%    The k^th column in the solution now gives the probability of ending up at u starting from different nodes.
A = speye(n)-bsxfun(@times,~is_voting(:)./deg,G);
B = sparse(find(is_voting),1:num_voters,ones(1,num_voters),n,num_voters); % B has 1 in every column k and row corresponding to k^th voter
solution = A\B;
weights = zeros(1,n);
weights(is_voting) = solution(v,:);
end