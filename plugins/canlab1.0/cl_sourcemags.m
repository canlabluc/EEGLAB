% Takes source-transformed DMN data and computes the magnitude of each channel,
% since channels are typically given in vector form.
function cl_sourcemags(importpath, exportpath)

% Create list of files in the directory
files = dir(fullfile(strcat(importpath, '/*.set')));
for id = 1:numel(files)
    EEG = pop_loadset(files(id).name, importpath);
    PCC_comps     = EEG.data(1:3, :);
    mPFC_comps    = EEG.data(4:6, :);
    LAG_comps     = EEG.data(7:9, :);
    RAG_comps     = EEG.data(10:12, :);
    LLatT_comps   = EEG.data(13:15, :);
    RLatT_comps   = EEG.data(16:18, :);
    NoiseL1_comps = EEG.data(19:21, :);
    NoiseR1_comps = EEG.data(22:24, :);
    NoiseL2_comps = EEG.data(25:27, :);
    NoiseR2_comps = EEG.data(28:30, :);
    NoiseM1_comps = EEG.data(31:33, :);
    NoiseM2_comps = EEG.data(34:36, :);

    PCC     = sqrt(sum(PCC_comps.^2, 1));
    mPFC    = sqrt(sum(mPFC_comps.^2, 1));
    LAG     = sqrt(sum(LAG_comps.^2, 1));
    RAG     = sqrt(sum(RAG_comps.^2, 1));
    LLatT   = sqrt(sum(LLatT_comps.^2, 1));
    RLatT   = sqrt(sum(RLatT_comps.^2, 1));
    NoiseL1 = sqrt(sum(NoiseL1_comps.^2, 1));
    NoiseL2 = sqrt(sum(NoiseL2_comps.^2, 1));
    NoiseR1 = sqrt(sum(NoiseR1_comps.^2, 1));
    NoiseR2 = sqrt(sum(NoiseR2_comps.^2, 1));
    NoiseM1 = sqrt(sum(NoiseM1_comps.^2, 1));
    NoiseM2 = sqrt(sum(NoiseM2_comps.^2, 1));

    EEG.data = [PCC
                PCC_comps
                mPFC
                mPFC_comps
                LAG
                LAG_comps
                RAG
                RAG_comps
                LLatT
                LLatT_comps
                RLatT
                RLatT_comps
                NoiseL1
                NoiseL1_comps
                NoiseR1
                NoiseR1_comps
                NoiseL2
                NoiseL2_comps
                NoiseR2
                NoiseR2_comps
                NoiseM1
                NoiseM1_comps
                NoiseM2
                NoiseM2_comps];

    labels = {'PCC','PCCr_DMN_w','PCCv_DMN_w','PCCh_DMN_w','mPFC','mPFCr_DMN_w','mPFCv_DMN_w','mPFCh_DMN_w','LAG','LAGr_DMN_w','LAGv_DMN_w','LAGh_DMN_w','RAG','RAGr_DMN_w','RAGv_DMN_w','RAGh_DMN_w','LLatT','LLatTe_N_w','LLatTe_N_w','LLatTe_N_w','RLatT','RLatTe_N_w','RLatTe_N_w','RLatTe_N_w','NoiseL1','NoiseL1_N_w','NoiseL1_N_w','NoiseL1_N_w','NoiseR1','NoiseR1_N_w','NoiseR1_N_w','NoiseR1_N_w','NoiseL2','NoiseL2_N_w','NoiseL2_N_w','NoiseL2_N_w','NoiseR2','NoiseR2_N_w','NoiseR2_N_w','NoiseR2_N_w','NoiseM1','NoiseM1_N_w','NoiseM1_N_w','NoiseM1_N_w','NoiseM2','NoiseM2_N_w','NoiseM2_N_w','NoiseM2_N_w'};

    for i = 1:size(labels, 2)
      EEG.chanlocs(i).labels = labels{i};
      EEG.chanlocs(i).urchan = i;
    end

    pop_saveset(EEG, 'filename', files(id).name(1:end-4), 'filepath',...
        exportpath, 'savemode', 'onefile');
end
end
