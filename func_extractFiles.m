function dirFile_Subjects = func_extractFiles(grupos)
    loclen = length(grupos);
    dirFile_Subjects = struct;
    for i = 1:loclen
        cgrupo = char(grupos(i));
        sDir = dir(cgrupo);
        nfiles = 0;

        for iDirs = 1:numel(sDir)
            if sDir(iDirs).isdir && ~strcmp(sDir(iDirs).name, '.') && ~strcmp(sDir(iDirs).name, '..')
                nfiles = nfiles + 1;
                
                folder = fullfile(cgrupo, sDir(iDirs).name);
                pathfile = dir(folder); 
                varchives = [pathfile.bytes]; %Vector to compare size of bytes
                [~, ind] = max(varchives); % Here will adquire wich archive gonna being process
                file = fullfile(folder, pathfile(ind).name);
                
                
                files{nfiles,1} = file;
            end
        end
        nf = numel(files);
        folderNum = nan(nf,1);

        for n = 1:nf

            parts = split(files{n}, filesep);
            lastFolder = parts{end-1};

            num = regexp(lastFolder, '\d+', 'match');

            if ~isempty(num)
                folderNum(n) = str2double(num{end});
            end

        end

        [~, idx] = sort(folderNum,'MissingPlacement','last');

        files_sorted = files(idx);
        
        dirFile_Subjects(i).paths = files_sorted;
    end
end