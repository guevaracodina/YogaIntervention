
function datas = func_load(dirFile_Subjects, timeSn)
    ng = numel(dirFile_Subjects); % how many groups
    for g = 1:ng
        subj_paths = dirFile_Subjects(g).paths;
        nsubj = length(subj_paths); % n subjects
        saveFrecuencies = zeros(nsubj, 1); % vector to save the frecuency per subject

        for s = 1:nsubj
            pathS = subj_paths{s};
            load(pathS);
            if ~isempty(output.dcAvg)
                dataS = output.dcAvg.dataTimeSeries;
                timeS = output.dcAvg.time;
            else
                dataS = output.dc.dataTimeSeries;
                timeS = output.dc.time;
            end
            dt = diff(timeS); dt = dt(~isnan(dt));
            fs = 1/median(dt);
            saveFrecuencies(s) = fs;
            
            % ---------------- NaN data cleaning --------------------
            [~, col] = find(isnan(dataS)); % The positions where NaN values are found are obtained - Errors
            if ~isempty(col)
                unq = unique(col); % The columns without repeats are obtained
                dataS(:, unq) = [];
            end
            
            data(s).value = dataS;
            data(s).time = timeS;
        end
        vufs = unique(saveFrecuencies); minorfs = min(vufs);% obtain the minor frecuency
        difFrecuency = saveFrecuencies ~= minorfs;
        for s = 1:nsubj
            dataS = data(s).value;
            timeS = data(s).time;

            logicMark = difFrecuency(s);

            fs_n = double(int8(minorfs));
            fs_o = double(int8(saveFrecuencies(s)));
            N_target = round((timeSn(end)-timeSn(1))*fs_n)+1;
            % Standard time
            x = timeSn(1) + (0:N_target-1)'/fs_n;
            
            if logicMark == 1
%                 y = resample(dataS, fs_n, fs_o);
                y = interp1(timeS, dataS, x, 'pchip');
            else
                y = dataS;
            end

            % Force length
            if size(y,1) > N_target
                y = y(1:N_target,:);
            elseif size(y,1) < N_target
                y(end+1:N_target,:) = NaN;
            end


            data(s).value = y;
            data(s).time = x;
        end
        datas(g).group = data;
    end
end