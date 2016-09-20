folders = getfoldersGUI();
Embeddings = [];
for folder_index = 1:length(folders)
    %single experiment
    folder_name = folders{folder_index}
    load([folder_name '\embeddings.mat'])
    Embeddings = [Embeddings; embeddingValues];
end
