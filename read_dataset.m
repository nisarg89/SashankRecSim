function G = read_dataset(filename)
%% Read the undirected graph dataset. The argument contains the name of the file. 
fid = fopen(filename);  % Open the file
if isempty(strfind(filename,'facebook-wosn')) && isempty(strfind(filename,'youtube-u-growth'))
    A = textscan(fid,'%f %f','CommentStyle','%'); % Ignore lines starting with %
else
    A = textscan(fid,'%f %f %f %f','CommentStyle','%'); % This has metadata
end
fclose(fid);
A = A(1:2);
n = max(max([A{:}]));
G = sparse(A{1},A{2},1,n,n); % Create a sparse graph
G = G+G'; % Make it symmetric
end