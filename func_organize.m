% if you want to change the letters for the stimulus for data, change the
% variable stimuli


function org_data = func_organize(struct_data, v_analysis)

    stimuli = {'K', 'N', 'P'}; % -> The stimuli are known
    name_gp = {'Pre', 'Post'};
    name_metrics = {'mean', 'max', 'trapz'};
    responseH = {'O', 'R', 'T'}; % fNIRS
    load('channels_PF24.mat'); % this file charge a table of channels for a prefrontal configuration
    lCh = length(cSD.Detector); % Amount of channels
    lr = length(responseH);
    amtC = lCh*lr; % Metric of amount of columns for a stimulus
    M = struct_data.datas(1).group(1).value; % ""replace images with a struct variable""
    st = size(M, 2); stims = st/amtC; % stim tells how many of stimuli have data
    base_or_analyze = zeros(3, st);
    CtoT = cell(0,8);

    for g = 1:numel(struct_data.datas)
        gp = struct_data.datas(g).group;
        t = gp.time;
        %Baseline
        [~, idx1_b] = min(abs(t - v_analysis(1, 1)));
        [~, idx2_b] = min(abs(t - v_analysis(1, 2)));
        idx_1 = idx1_b:idx2_b;
        %Analysis
        [~, idx1_A] = min(abs(t - v_analysis(2, 1)));
        [~, idx2_A] = min(abs(t - v_analysis(2, 2)));
        idx_2 = idx1_A:idx2_A;

        %Let's save all data
        mean_data = zeros(numel(gp), st);
        max_data = zeros(numel(gp), st);
        trapz_data = zeros(numel(gp), st);

        %Save data for metrics and if base or vector to analyze
        metriCell = cell(2, 3); % Rows: 1-Base, 2-Analyze and Columns: 1-mean, 2-max, 3-trapz

        for base_Aly = 1:2
            idx = eval(sprintf('idx_%d', base_Aly));
            for s = 1:numel(gp)
                subj = gp(s).value;
                subj_daly = subj(idx, :);
                t_daly = t(idx);

                mean_data(s, :) = mean(subj_daly, 1);
                max_data(s, :) = max(abs(subj_daly), [], 1);
                trapz_data(s, :) = trapz(t_daly, subj_daly, 1);      
            end
            metriCell(base_Aly, 1) = {mean_data};
            metriCell(base_Aly, 2) = {max_data};
            metriCell(base_Aly, 3) = {trapz_data};
        end
        OrgMetrics(g).group = metriCell;
    end
    % Now we have to eliminate the outliers
    for g = 1:numel(OrgMetrics)
        pO{g, 1} = cellfun(@(x) func_locOutliers(x, [5, 95]), OrgMetrics(g).group, 'UniformOutput', false);
    end

    for g = 1:numel(pO)
        for m = 1:numel(pO{g})
            gA = pO{-g+g*2}{m}; 
            gB = pO{2+-g+1}{m};

            d = OrgMetrics(g).group{m};

            allIdx = [];
            if ~isempty(gA)
                allIdx = [allIdx; gA];
            end
            if ~isempty(gB)
                allIdx = [allIdx; gB];
            end

            if ~isempty(allIdx)
                allIdx = unique(allIdx,'rows'); % avoid duplicates
                linIdx = sub2ind(size(d), allIdx(:,1), allIdx(:,2));
                d(linIdx) = NaN;
            end
            OrgMetrics(g).group{m} = d;  % save modified
        end
    end
    % Now it's gonna be organize the data for the analyis and plots
    for g = 1:numel(OrgMetrics)
        gp = OrgMetrics(g).group;

        % This cycle organization it's for statistic analysis
        % we'll extract the type of data: base or to analyze
        for dba = 1:size(gp, 1)
            datt = gp(dba, :); % we're selecting wich data manipulate
            for mtc = 1:3
                datm = datt{mtc};
                for stm = 1:stims % let's divide 
                    dats = datm(:, 1+amtC*(stm-1):amtC*stm);

                    dcell = cell(1,3);
                    for hb = 1:3
                        dath = dats(:, hb:3:end);
                        dcell{hb} = dath;
                    end
                    dStim(stm).Hb = dcell;
                    dStim(stm).Simulus = stimuli(stm);
                end
                dMetric(mtc).Metric = dStim;
                dMetric(mtc).nMetric = name_metrics{mtc};
            end
            dType(dba).kanalysis = dMetric;
        end

        % To obtain the data in tables
        for base_Aly = 1:2
            for metric = 1:3
                T_data = OrgMetrics(g).group{base_Aly, metric};
                for s = 1:size(T_data, 1)
                    T_subj = T_data(s, :);

                    for stml = 1:stims
                        T_stim_S = T_subj(1+amtC*(stml-1):amtC*stml);% 1:K, 2:N, 3:P                 
                        for hb = 1:3
                            T_hb_S = T_stim_S(hb:3:end);% 1:O, 2:R, 3:T
                            for ch = 1:lCh
                                val_ch = T_hb_S(ch);
                                if stims == 1
                                    CtoT(end+1, :) = {name_gp(g), s, ch, responseH(hb), 'Breath', metric, base_Aly, val_ch};
                                elseif stims > 1
                                    CtoT(end+1, :) = {name_gp(g), s, ch, responseH(hb), stimuli(stml), metric, base_Aly, val_ch};
                                end
                            end
                        end
                    end

                end
            end
        end

        % This is the matrices with all samples of data
        data_s = struct_data.datas(g).group; 
        % Only we'll obtain the value's column
        for subj = 1:numel(data_s)
            subject = data_s(subj).value;
            for stm = 1:stims
                stm_subj = subject(:, 1+amtC*(stm-1):amtC*stm);

                hb_cell = cell(1, 3);
                for hb = 1:3
                    resp_hb = stm_subj(:, hb:3:end);
                    hb_cell{hb} = resp_hb;
                end
                dstim(stm).Hb = hb_cell;
                if stims == 1
                    dstim(stm).Stimulus = 'Breath';
                elseif stims > 1
                    dstim(stm).Stimulus = stimuli{stm};
                end
            end
            dsubj(subj).values = dstim;
        end
        
        org_data(g).gp_statistics = dType;
        org_data(g).gp_subj = dsubj;
        org_data(g).time = data_s.time;
        org_data(g).ngp = name_gp{g};
        
        org_data(g).gp_statistics(1).nkanalysis = v_analysis(1, :);
        org_data(g).gp_statistics(2).nkanalysis = v_analysis(2, :);
    end

    T = cell2table(CtoT, ...
        'VariableNames',{'TimeG','Subj','Channel','Hb','Stimulus','Metric','Type_aly', 'Value'});
    org_data(1).table_statistics = T;
    
    
end
