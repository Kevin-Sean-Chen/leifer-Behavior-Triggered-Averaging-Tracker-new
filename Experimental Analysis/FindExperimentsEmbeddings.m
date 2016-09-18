parameters.numProcessors = 15;
parameters.numProjections = 19;
parameters.pcaModes = 5;
parameters.samplingFreq = 14;
parameters.minF = 0.3;
parameters.maxF = parameters.samplingFreq ./ 2; %nyquist frequency
parameters.trainingSetSize = 55000;
parameters.subsamplingIterations = 10;
parameters = setRunParameters(parameters);
Prefs = load_excel_prefs;
load('reference_embedding.mat')

folders = getfolders();

for folder_index = 1:length(folders)
    folder_name = folders{folder_index}
    if ~exist([folder_name '\embeddings.mat'], 'file')

        %single experiment
        folder_name = folders{folder_index};
        load([folder_name '\tracks.mat'])
        load([folder_name '\LEDVoltages.txt'])

        try
            experiment_parameters = load([folder_name '\parameters.txt']);
            frames = experiment_parameters(length(experiment_parameters));
        catch
            experiment_parameters = readtable([folder_name '\parameters.txt'], 'Delimiter', '\t');
            frames = experiment_parameters{1,{'FrameCount'}};
        end

        if exist([folder_name '\spectra.mat'], 'file')
            load([folder_name '\spectra.mat'])
        else
            %get the spectra
            [Spectra, ~, ~, ~] = generate_spectra(Tracks, parameters, Prefs);
            %save spectra
            save([folder_name '\spectra.mat'], 'Spectra', '-v7.3');
        end


        data = vertcat(Spectra{:});
        [embeddingValues,~] = findEmbeddings(data,trainingSetData,trainingEmbedding,parameters);
        clear data

        save([folder_name '\embeddings.mat'], 'embeddingValues', '-v7.3')
    end
end

