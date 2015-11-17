nList = zeros(1,numDatasets);
for datasetID=1:numDatasets
    datasetName = datasets{datasetID};
    G = read_dataset([datasetDir '\' datasetName]);
    [~,C] = graphconncomp(G,'Directed',false);
    if max(C) > 1
        largest_component = mode(C);
        init_nodes = find(C==largest_component);
        G = G(init_nodes,init_nodes);
        clear largest_component init_nodes;
    end
    clear C;
    nList(datasetID) = size(G,1);
end