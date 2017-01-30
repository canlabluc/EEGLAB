function subj = cl_getportcodes(importpath)

files = dir(fullfile(strcat(importpath, '/*.set')));
subj(size(files, 1)) = struct();
for i = 1:numel(files)
    EEG = pop_loadset(files(i).name, importpath);
    subj(i).events = EEG.event;
end

end
