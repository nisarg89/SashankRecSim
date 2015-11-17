n = 8; % Number of nodes
v = 1; % Whom to recommend

% Build the graph
G = zeros(n,n);
G(1,[2 3 5]) = 1;
G([2 3],4) = 1;
G(5,[6 7 8]) = 1;
G = G+transpose(G);
G = sparse(G);

% Voters and votes
is_voting = logical([0 1 1 1 0 1 1 1]);
votes = [0 1 0 0 0 1 1 0]; % Ignore nodes which are not voting

% Test the mechanisms
display(random_walk(G,is_voting,v));
display(round(random_walk_rec(G,is_voting,votes,v)));
display(our_mechanism(G,is_voting,v));
display(round(our_mechanism_rec(G,is_voting,votes,v)));
