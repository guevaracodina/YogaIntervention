function [T, TO, TR, TT] = func_ttest_breath(strc, kAn)
    % We have to obtain for each column if the data is paired or not
    
    nMetric = numel(strc(1).gp_statistics(kAn).kanalysis);
    nStims = numel(strc(1).gp_statistics(1).kanalysis(1).Metric);
    
    for g = 1:numel(strc)
        HSW_nM = cell(nMetric, 1);
        for met = 1:nMetric
            HSW_nS = cell(nStims, 1);
            for stm = 1:nStims
                sch = size(strc(g).gp_statistics(kAn).kanalysis(met).Metric(stm).Hb{1}, 2);
                HSW_hb = zeros(3, sch);
                for hb = 1:3
                    m_norm = strc(g).gp_statistics(kAn).kanalysis(met).Metric(stm).Hb{hb};
                    H_SW = zeros(1, sch);
                    for ch = 1:sch
                        [H, pValue, W] = func_swtest(m_norm(:, ch), 0.05); % if H = 1 so the channel is unpared (no normal)
                        H_SW(1, ch) = H;
                    end
                    HSW_hb(hb, :) = H_SW;
                end
                HSW_nS{stm} = HSW_hb;
            end
            HSW_nM{met} = HSW_nS;
        end
        gpH(g).group = HSW_nM;
    end
    
    %%
    % How ends the data saved
    % gpH(g).group -> pre,post
    % gpH(g).group{M} -> mean, max, trapz
    % gpH(g).group{M}{S} -> Breath or K,N,P, it depends what data is analysing
    % gpH(g).group{M}{S}(hb, ch) -> (O,R,T),(1,..,24)
    
    % Let's to normalize the for pre and post same value
    pre = strc(1).gp_statistics;
    post = strc(2).gp_statistics;
    
    S = 1;
    
    pvalMT = cell(3,1);
    for M = 1:numel(gpH(1).group)
    
        TpvalH = cell(3, 1);
        for hb = 1:3
            PH = zeros(5, size(gpH(1).group{1}{S}, 2));
            for ch = 1:size(gpH(1).group{1}{S}, 2)
                h1 = gpH(1).group{M}{S}(hb, ch);
                h2 = gpH(2).group{M}{S}(hb, ch);
                Hout = h1 & h2;
                
                D1 = pre(kAn).kanalysis(M).Metric(1).Hb{hb}(:, ch);
                D2 = post(kAn).kanalysis(M).Metric(1).Hb{hb}(:, ch);
    
                if Hout == 1 % data is unpaired
                    [p,h] = ranksum(D1,D2,'alpha',0.05);
                    d = func_cohens_d_np(D2, D1);
                elseif Hout == 0 % paired data
                    [h,p] = ttest(D1,D2,'Alpha',0.05);
                    d = func_cohens_d_p(D2,D1);
                end
    
                if ch == 5 || ch == 24
                    h = NaN;
                    p = NaN;
                end
    
                PH(1, ch) = p;
                PH(2, ch) = h;
                PH(5, ch) = d; % Cohens D
            end
            fDR = ioi_fdr(PH(1, :));
            logicfDR = fDR < 0.05;
            PH(3, :) = fDR;
            PH(4, :) = logicfDR;
    
            TpvalH{hb} = PH;
        end
        pvalMT{M} = TpvalH;
    end
    
    % let's generate a table where show the data
    % pvalMT: Mean, Max, Trapz -> HbO, HbR, HbT
    Tc = cell(0, 8);
    namesT = {'Metric', 'Hb','p_value', 'Significative', 'p_val_corr', 'SignificativeC', 'CohensD, (PRE - POST) ','Channel'};
    HB = {'O', 'R', 'T'};
    metric = {'mean', 'max', 'trapz'};
    % row = 0;
    for met = 1:3
        for hb = 1:3
            for ch = 1:size(gpH(1).group{1}{1}, 2)
                pval = pvalMT{met}{hb}(1, ch);
                logval = pvalMT{met}{hb}(2, ch);
                pval_corr = pvalMT{met}{hb}(3, ch);
                logval_corr = pvalMT{met}{hb}(4, ch);
                dCohens = pvalMT{met}{hb}(5, ch);
                Tc(end+1, :) = {metric{met}, HB{hb}, pval, logval, pval_corr, logval_corr, dCohens, ch};
            end
        end
    end
    T = cell2table(Tc, 'VariableNames',namesT);
    
    
    TO = T(strcmp(T.Hb, 'O') & T.Significative == 1, :);
    TR = T(strcmp(T.Hb, 'R') & T.Significative == 1, :);
    TT = T(strcmp(T.Hb, 'T') & T.Significative == 1, :);
end