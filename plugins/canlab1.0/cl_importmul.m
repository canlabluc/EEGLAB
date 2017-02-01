% Imports mul files from BESA, utilizing corresponding .set files to
% first acquire subject information and build a starting EEG object.
%
% Usage:
%   >> cl_importmul(importpath_mul, importpath_cnt, exportpath)
%
% Inputs:
% importpath_mul: A string which specifies the directory containing the
%                 .mul files to be imported.
%
% importpath_set: A string which specifies the directory containing the
%                 corresponding .set files, which area already in EEGLAB
%                 structure format. To acquire these, we run 
%                 cl_importcnt().
%
% exportpath: A string which specifies the directory to which to save
%             the resulting .set file. 
%
function cl_importmul(importpath_mul, importpath_set, exportpath, montage)

% Construct a list of mul files, and a list of set files
files_set = dir(fullfile(strcat(importpath_set, '/*.set')));
for i = 1:numel(files_set)

    file = files_set(i).name(1:end-4);
    
    % First, import the .set file and corresponding .mul file
    EEG = pop_loadset(files_set(i).name, importpath_set);
    mul = readBESAmul(strcat(importpath_mul, '/', file, '.mul'));
    
    % Replace .set data with that from the .mul file
    EEG.data = mul.data';
    
    if strcmp(montage, 'dmn')
        PCCc     = EEG.data(1:3, :);
        mPFCc    = EEG.data(4:6, :);
        LAGc     = EEG.data(7:9, :);
        RAGc     = EEG.data(10:12, :);
        LLatTc   = EEG.data(13:15, :);
        RLatTc   = EEG.data(16:18, :);
        NoiseL1c = EEG.data(19:21, :);
        NoiseR1c = EEG.data(22:24, :);
        NoiseL2c = EEG.data(25:27, :);
        NoiseR2c = EEG.data(28:30, :);
        NoiseM1c = EEG.data(31:33, :);
        NoiseM2c = EEG.data(34:36, :);

        PCC     = sqrt(sum(PCCc.^2,     1));
        mPFC    = sqrt(sum(mPFCc.^2,    1));
        LAG     = sqrt(sum(LAGc.^2,     1));
        RAG     = sqrt(sum(RAGc.^2,     1));
        LLatT   = sqrt(sum(LLatTc.^2,   1));
        RLatT   = sqrt(sum(RLatTc.^2,   1));
        NoiseL1 = sqrt(sum(NoiseL1c.^2, 1));
        NoiseL2 = sqrt(sum(NoiseL2c.^2, 1));
        NoiseR1 = sqrt(sum(NoiseR1c.^2, 1));
        NoiseR2 = sqrt(sum(NoiseR2c.^2, 1));
        NoiseM1 = sqrt(sum(NoiseM1c.^2, 1));
        NoiseM2 = sqrt(sum(NoiseM2c.^2, 1));
        EEG.data = [
            PCC     ; PCCc;
            mPFC    ; mPFCc;
            LAG     ; LAGc;
            RAG     ; RAGc;
            LLatT   ; LLatTc;
            RLatT   ; RLatTc;
            NoiseL1 ; NoiseL1c;
            NoiseR1 ; NoiseR1c;
            NoiseL2 ; NoiseL2c;
            NoiseR2 ; NoiseR2c;
            NoiseM1 ; NoiseM1c;
            NoiseM2 ; NoiseM2c
        ];

        labels = {'PCC','PCCr','PCCv','PCCh','mPFC','mPFCr','mPFCv','mPFCh','LAG',...
                  'LAGr','LAGv','LAGh','RAG','RAGr','RAGv','RAGh','LLatT','LLatTe1',...
                  'LLatTe2','LLatTe3','RLatT','RLatTe1','RLatTe2','RLatTe3','Noise1L',...
                  'Noise1L1','Noise1L2','Noise1L3','Noise1R','Noise1R1','Noise1R2',...
                  'Noise1R3','Noise2L','Noise2L1','Noise2L2','Noise2L3','Noise2R',...
                  'Noise2R1','Noise2R2','Noise2R3','Noise1M','Noise1M1','Noise1M2',...
                  'Noise1M3','Noise2M','Noise2M1','Noise2M2','Noise2M3'};

    elseif strcmp(montage, 'frontal')
        LdlPFCc  = EEG.data(1:3,   :);
        RdlPFCc  = EEG.data(4:6,   :);
        LFrontc  = EEG.data(7:9,   :);
        RFrontc  = EEG.data(10:12, :);
        LIPLc    = EEG.data(13:15, :);
        RIPLc    = EEG.data(16:18, :);
        LIPSc    = EEG.data(19:21, :);
        RIPSc    = EEG.data(22:24, :);
        NoiseL1c = EEG.data(25:27, :);
        NoiseR1c = EEG.data(28:30, :);
        NoiseL2c = EEG.data(31:33, :);
        NoiseR2c = EEG.data(34:36, :);
        NoiseFc  = EEG.data(37:39, :);

        LdlPFC  = sqrt(sum(LdlPFCc.^2,  1));
        RdlPFC  = sqrt(sum(RdlPFCc.^2,  1));
        LFront  = sqrt(sum(LFrontc.^2,  1));
        RFront  = sqrt(sum(RFrontc.^2,  1));
        LIPL    = sqrt(sum(LIPLc.^2,    1));
        RIPL    = sqrt(sum(RIPLc.^2,    1));
        LIPS    = sqrt(sum(LIPSc.^2,    1));
        RIPS    = sqrt(sum(RIPSc.^2,    1));
        NoiseL1 = sqrt(sum(NoiseL1c.^2, 1));
        NoiseR1 = sqrt(sum(NoiseR1c.^2, 1));
        NoiseL2 = sqrt(sum(NoiseL2c.^2, 1));
        NoiseR2 = sqrt(sum(NoiseR2c.^2, 1));
        NoiseF  = sqrt(sum(NoiseFc.^2,  1));
        EEG.data = [
            LdlPFC  ; LdlPFCc;
            RdlPFC  ; RdlPFCc;
            LFront  ; LFrontc;
            RFront  ; RFrontc;
            LIPL    ; LIPLc;
            RIPL    ; RIPLc;
            LIPS    ; LIPSc;
            RIPS    ; RIPSc;
            NoiseL1 ; NoiseL1c;
            NoiseR1 ; NoiseR1c;
            NoiseL2 ; NoiseL2c;
            NoiseR2 ; NoiseR2c;
            NoiseF  ; NoiseFc;
        ];

        labels = {'LdlPFC','LdlPFC1','LdlPFC2','LdlPFC3','RdlPFC','RdlPFC1',...
                  'RdlPFC2','RdlPFC3','LFRont','LFront1','LFront2','LFront3',...
                  'RFront','RFront1','RFront2','RFront3','LIPL','LIPLr','LIPLv',...
                  'LIPLh','RIPL','RIPLr','RIPLv','RIPLh','LIPS','LIPSr','LIPSv',...
                  'LIPSh','RIPS','RIPSr','RIPSv','RIPSh','Noise1L','Noise1L1',...
                  'Noise1L2','Noise1L3','Noise1R','Noise1R1','Noise1R2','Noise1R3',...
                  'Noise2L','Noise2L1','Noise2L2','Noise2L3','Noise2R','Noise2R1',...
                  'Noise2R2','Noise2R3','NoiseF','NoiseF1','NoiseF2','NoiseF3'};

    elseif strcmp(montage, 'dorsal')
        LFEFc  = EEG.data(1:3,   :);
        RFEFc  = EEG.data(4:6,   :);
        LaIPSc  = EEG.data(7:9,   :);
        RaIPSc  = EEG.data(10:12, :);
        LpIPSc    = EEG.data(13:15, :);
        RpIPSc    = EEG.data(16:18, :);
        Noise1Lc    = EEG.data(19:21, :);
        Noise1Rc    = EEG.data(22:24, :);
        Noise2Lc    = EEG.data(25:27, :);
        Noise2Rc    = EEG.data(28:30, :);
        Noise3Lc    = EEG.data(31:33, :);
        Noise3Rc    = EEG.data(34:36, :);

        LFEF = sqrt(sum(LFEFc.^2, 1));
        RFEF = sqrt(sum(RFEFc.^2, 1));
        LaIPS = sqrt(sum(LaIPSc.^2, 1));
        RaIPS = sqrt(sum(RaIPSc.^2, 1));
        LpIPS = sqrt(sum(LpIPSc.^2, 1));
        RpIPS = sqrt(sum(RpIPSc.^2, 1));
        Noise1L = sqrt(sum(Noise1Lc.^2, 1));
        Noise1R = sqrt(sum(Noise1Rc.^2, 1));
        Noise2L = sqrt(sum(Noise2Lc.^2, 1));
        Noise2R = sqrt(sum(Noise2Rc.^2, 1));
        Noise3L = sqrt(sum(Noise3Lc.^2, 1));
        Noise3R = sqrt(sum(Noise3Rc.^2, 1));
        EEG.data = [
            LFEF  ; LFEFc;
            RFEF  ; RFEFc;
            LaIPS  ; LaIPSc;
            RaIPS  ; RaIPSc;
            LpIPS    ; LpIPSc;
            RpIPS    ; RpIPSc;
            Noise1L    ; Noise1Lc;
            Noise1R    ; Noise1Rc;
            Noise2L ; Noise2Lc;
            Noise2R ; Noise2Rc;
            Noise3L ; Noise3Lc;
            Noise3R ; Noise3Rc;
        ];

        labels = {'LFEF','LFEFr','LFEFv','LFEFh','RFEF','RFEFr','RFEFv','RFEFh',...
                  'LaIPS','LaIPSr','LaIPSv','LaIPSh','RaIPS','RaIPSr','RaIPSv',...
                  'RaIPSh','LpIPS','LpIPSr','LpIPSv','LpIPSh','RpIPS','RpIPSr',...
                  'RpIPSv','RpIPSh','Noise1L','Noise1L1','Noise1L2','Noise1L3',...
                  'Noise1R','Noise1R1','Noise1R2','Noise1R3','Noise2L','Noise2L1',...
                  'Noise2L2','Noise2L3','Noise2R','Noise2R1','Noise2R2','Noise2R3',...
                  'Noise3L','Noise3L1','Noise3L2','Noise3L3','Noise4R','Noise4R1',...
                  'Noise4R2','Noise4R3'};

    elseif strcmp(montage, 'ventral')
        LIFGc  = EEG.data(1:3,   :);
        RIFGc  = EEG.data(4:6,   :);
        LMFGc  = EEG.data(7:9,   :);
        RMFGc  = EEG.data(10:12, :);
        LTPJc    = EEG.data(13:15, :);
        RTPJc    = EEG.data(16:18, :);
        LSTGc    = EEG.data(19:21, :);
        RSTGc    = EEG.data(22:24, :);
        NoiseLc    = EEG.data(25:27, :);
        NoiseRc    = EEG.data(28:30, :);
        NoiseFc    = EEG.data(31:33, :);
        Noisec    = EEG.data(34:36, :);

        LIFG = sqrt(sum(LIFGc.^2, 1));
        RIFG = sqrt(sum(RIFGc.^2, 1));
        LMFG = sqrt(sum(LMFGc.^2, 1));
        RMFG = sqrt(sum(RMFGc.^2, 1));
        LTPJ = sqrt(sum(LTPJc.^2, 1));
        RTPJ = sqrt(sum(RTPJc.^2, 1));
        LSTG = sqrt(sum(LSTGc.^2, 1));
        RSTG = sqrt(sum(RSTGc.^2, 1));
        NoiseL = sqrt(sum(NoiseLc.^2, 1));
        NoiseR = sqrt(sum(NoiseRc.^2, 1));
        NoiseF = sqrt(sum(NoiseFc.^2, 1));
        Noise = sqrt(sum(Noisec.^2, 1));

        EEG.data = [
            LIFG  ; LIFGc;
            RIFG  ; RIFGc;
            LMFG  ; LMFGc;
            RMFG  ; RMFGc;
            LTPJ    ; LTPJc;
            RTPJ    ; RTPJc;
            LSTG    ; LSTGc;
            RSTG    ; RSTGc;
            NoiseL ; NoiseLc;
            NoiseR ; NoiseRc;
            NoiseF ; NoiseFc;
            Noise ; Noisec;
        ];

        labels = {'LIFG','LIFGr','LIFGv','LIFGh','RIFG','RIFGr','RIFGv','RIFGh',...
                  'LMFG','LMFGr','LMFGv','LMFGh','RMFG','RMFGr','RMFGv','RMFGh',...
                  'LTPJ','LTPJr','LTPJv','LTPJh','RTPJ','RTPJr','RTPJv','RTPJh',...
                  'LSTG','LSTGr','LSTGv','LSTGh','RSTG','RSTGr','RSTGv','RSTGh',...
                  'NoiseL','NoiseL1','NoiseL2','NoiseL3','NoiseR','NoiseR1',...
                  'NoiseR2','NoiseR3','NoiseF','NoiseF1','NoiseF2','NoiseF3',...
                  'Noise','Noise1','Noise2','Noise3'};

    end

    EEG.nbchan = size(EEG.data, 1);
    EEG.chanlocs = EEG.chanlocs(1:EEG.nbchan);
    for i = 1:size(labels, 2)
      EEG.chanlocs(i).labels = labels{i};
      EEG.chanlocs(i).urchan = i;
    end

    pop_saveset(EEG, 'filename', file, 'filepath', exportpath, 'savemode', 'onefile');
end
end
