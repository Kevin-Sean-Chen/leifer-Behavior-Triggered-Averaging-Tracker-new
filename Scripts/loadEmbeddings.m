folders = getfolders();
All_Embeddings = [];
for folder_index = 1:length(folders)
    %single experiment
    folder_name = folders{folder_index};
    load([folder_name '\embeddings.mat'])
    All_Embeddings = [All_Embeddings; Embeddings];
end
Embeddings = All_Embeddings;
clear All_Embeddings