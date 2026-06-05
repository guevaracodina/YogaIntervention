
function [DetallesStim, DetallesAct, DetallesPrePost, DetallesInt] = func_ANOVA_img(strc_image)
    %% ============================================================
    % COMPLETE MIXED ANOVA + POSTHOC + EFFECTS + FDR
    % ============================================================
    
    TS_img = strc_image(1).table_statistics;
    TS = func_clc_or_median_NaNVal_Table(TS_img, strc_image);
    
    % Short channels eliminated
    shortChannels = [5 24];
    TS = TS(~ismember(TS.Channel, shortChannels), :);
    
    fprintf('\n=== ANOVA ===\n');
    
    HbTypes  = unique(TS.Hb);
    Metrics  = unique(TS.Metric);
    Channels  = unique(TS.Channel);
    
    Resultados = [];
    DetallesStim = [];
    DetallesAct  = [];
    DetallesPrePost = [];
    DetallesInt  = [];
    
    for h = 1:numel(HbTypes)
        for met = 1:numel(Metrics)
            for c = 1:numel(Channels)
            
                %% ================= FILTER =================
                tCh = TS(strcmp(TS.Hb, HbTypes{h}) & ...
                         TS.Metric == Metrics(met) & ...
                         TS.Channel == Channels(c), :);
            
                tCh = tCh(~isnan(tCh.Value), :);
                if height(tCh) < 10, continue; end
            
                conds = unique(tCh.TimeG);
                estims = unique(tCh.Stimulus);
                types  = unique(tCh.Type_aly);
            
                if numel(conds)<2 || numel(estims)<2 || numel(types)<2
                    continue;
                end
            
                %% ================= ANOVA =================
                try
                    [p,~,stats] = anovan(tCh.Value, ...
                        {tCh.TimeG, tCh.Stimulus, tCh.Type_aly, tCh.Subj}, ...
                        'model','interaction','random',4,'display','off');
            
                    pC   = p(1); pE   = p(2); pT   = p(3);
                    pCE  = p(4); pCT  = p(5); pET  = p(6);
                    pCET = p(min(7,end));
                catch
                    continue;
                end
            
                %% ========================================================
                %% POST-HOC STIMULUS (PER INTERVAL, PAIRED)
                %% ========================================================
                for t = unique(tCh.Type_aly)'
            
                    tSub = tCh(tCh.Type_aly == t, :);
            
                    if numel(unique(tSub.Stimulus)) < 2, continue; end
            
                    try
                        [~,~,statsSub] = anovan(tSub.Value, ...
                            {tSub.TimeG, tSub.Stimulus, tSub.Subj}, ...
                            'model','interaction','random',3,'display','off');
            
                        cStim = multcompare(statsSub,'Dimension',2,'Display','off');
                    catch
                        continue;
                    end
            
                    for i = 1:size(cStim,1)
            
                        g1 = statsSub.grpnames{2}{cStim(i,1)};
                        g2 = statsSub.grpnames{2}{cStim(i,2)};
            
                        idx1 = strcmp(tSub.Stimulus,g1);
                        idx2 = strcmp(tSub.Stimulus,g2);
            
                        sub1 = tSub.Subj(idx1);
                        sub2 = tSub.Subj(idx2);
            
                        [~,ia,ib] = intersect(sub1,sub2);
            
                        D1 = tSub.Value(idx1); D2 = tSub.Value(idx2);
                        D1 = D1(ia); D2 = D2(ib);
            
                        if numel(D1)<2, continue; end
            
                        D = D1 - D2;
            
                        if std(D)==0
                            d = NaN;
                        else
                            d = mean(D)/std(D);
                        end
            
                        n = length(D);
                        J = 1 - 3/(4*n - 1);
                        g = d*J;
            
                        glass = mean(D)/std(D2);
            
                        ss_effect = mean(D)^2;
                        ss_total  = var(D)*(n-1);
            
                        eta2 = ss_effect/ss_total;
                        eta2p = eta2;
            
                        DetallesStim = [DetallesStim;
                            table(Channels(c), HbTypes(h), Metrics(met), ...
                            t,{g1},{g2},cStim(i,6),d,g,glass,eta2,eta2p)];
                    end
                end
            
                %% ========================================================
                %% ACTIVATION (BASELINE vs STIM, PAIRED)
                %% ========================================================
                base = tCh.Value(tCh.Type_aly==1);
                stim = tCh.Value(tCh.Type_aly==2);
            
                if numel(base)>2 && numel(stim)>2
                    [~,pAct] = ttest(base,stim);
            
                    D = stim - base;
            
                    if std(D)==0
                        d = NaN;
                    else
                        d = mean(D)/std(D);
                    end
            
                    n = length(D);
                    J = 1 - 3/(4*n - 1);
                    g = d*J;
            
                    glass = mean(D)/std(base);
            
                    ss_effect = mean(D)^2;
                    ss_total  = var(D)*(n-1);
            
                    eta2 = ss_effect/ss_total;
                    eta2p = eta2;
            
                    DetallesAct = [DetallesAct;
                        table(Channels(c), HbTypes(h), Metrics(met), ...
                        pAct,d,g,glass,eta2,eta2p)];
                end
            
                %% ========================================================
                %% PRE vs POST (PAIRED)
                %% ========================================================
                for t = unique(tCh.Type_aly)'
                for s = unique(tCh.Stimulus)'
            
                    tSub = tCh(tCh.Type_aly == t & strcmp(tCh.Stimulus,s), :);
            
                    idxPre  = strcmp(tSub.TimeG,'Pre');
                    idxPost = strcmp(tSub.TimeG,'Post');
            
                    subPre  = tSub.Subj(idxPre);
                    subPost = tSub.Subj(idxPost);
            
                    [~,ia,ib] = intersect(subPre,subPost);
            
                    D1 = tSub.Value(idxPre);
                    D2 = tSub.Value(idxPost);
            
                    D1 = D1(ia);
                    D2 = D2(ib);
            
                    if numel(D1)<2, continue; end
            
                    [~,pPP] = ttest(D1,D2);
            
                    D = D2 - D1;
            
                    if std(D)==0
                        d = NaN;
                    else
                        d = mean(D)/std(D);
                    end
            
                    n = length(D);
                    J = 1 - 3/(4*n - 1);
                    g = d*J;
            
                    glass = mean(D)/std(D1);
            
                    ss_effect = mean(D)^2;
                    ss_total  = var(D)*(n-1);
            
                    eta2 = ss_effect/ss_total;
                    eta2p = eta2;
            
                    DetallesPrePost = [DetallesPrePost;
                        table(Channels(c), HbTypes(h), Metrics(met), ...
                        t,s,pPP,d,g,glass,eta2,eta2p)];
                end
                end
            
                %% ========================================================
                %% INTERACTION (PAIRED)
                %% ========================================================
                grupo = strcat(tCh.TimeG,"_",tCh.Stimulus,"_I",string(tCh.Type_aly));
            
                try
                    [~,~,statsInt] = anovan(tCh.Value,{grupo,tCh.Subj}, ...
                        'random',2,'display','off');
            
                    cInt = multcompare(statsInt,'Display','off');
            
                    for i=1:size(cInt,1)
            
                        gA = statsInt.grpnames{1}{cInt(i,1)};
                        gB = statsInt.grpnames{1}{cInt(i,2)};
            
                        DA = tCh.Value(strcmp(grupo,gA));
                        DB = tCh.Value(strcmp(grupo,gB));
            
                        n1=numel(DA); n2=numel(DB);
            
                        if n1<2 || n2<2, continue; end
            
                        % ⚠ Here it is not perfectly paired (complex combinations)
                        sP = sqrt(((n1-1)*var(DA)+(n2-1)*var(DB))/(n1+n2-2));
            
                        if sP==0
                            d = NaN;
                        else
                            d = (mean(DA)-mean(DB))/sP;
                        end
            
                        DetallesInt = [DetallesInt;
                            table(Channels(c), HbTypes(h), Metrics(met), ...
                            {gA},{gB},cInt(i,6),d)];
                    end
                catch
                end
            
                %% RESULTS
                Resultados = [Resultados;
                    table(Channels(c), HbTypes(h), Metrics(met), ...
                    pC,pE,pT,pCE,pCT,pET,pCET)];
            
            end
        end
    end
    
    %% ============================================================
    %% RENAME
    %% ============================================================
    
    Resultados.Properties.VariableNames = ...
    {'Channel','Hb','Metric',...
     'p_Cond','p_Stim','p_Interval',...
     'p_CondStim','p_CondInt','p_StimInt','p_Triple'};
    
    if ~isempty(DetallesStim)
        DetallesStim.Properties.VariableNames = ...
        {'Channel','Hb','Metric','Type_aly',...
         'Stim_A','Stim_B','p',...
         'CohensD','HedgesG','GlassDelta','Eta2','Eta2_partial'};
    end
    
    if ~isempty(DetallesAct)
        DetallesAct.Properties.VariableNames = ...
        {'Channel','Hb','Metric','p_activation',...
         'CohensD','HedgesG','GlassDelta','Eta2','Eta2_partial'};
    end
    
    if ~isempty(DetallesPrePost)
        DetallesPrePost.Properties.VariableNames = ...
        {'Channel','Hb','Metric','Type_aly','Stimulus',...
         'p','CohensD','HedgesG','GlassDelta','Eta2','Eta2_partial'};
    end
    
    if ~isempty(DetallesInt)
        DetallesInt.Properties.VariableNames = ...
        {'Channel','Hb','Metric','Group_A','Group_B','p','CohensD'};
    end
    
    %% ============================================================
    %% FDR
    %% ============================================================
    
    Resultados.q_Cond      = ioi_fdr(Resultados.p_Cond);
    Resultados.q_Stim      = ioi_fdr(Resultados.p_Stim);
    Resultados.q_Intervalo = ioi_fdr(Resultados.p_Intervalo);
    Resultados.q_CondStim  = ioi_fdr(Resultados.p_CondStim);
    Resultados.q_CondInt   = ioi_fdr(Resultados.p_CondInt);
    Resultados.q_StimInt   = ioi_fdr(Resultados.p_StimInt);
    Resultados.q_Triple    = ioi_fdr(Resultados.p_Triple);
    
    if ~isempty(DetallesStim)
        DetallesStim.q = ioi_fdr(DetallesStim.p);
    end
    
    if ~isempty(DetallesAct)
        DetallesAct.q = ioi_fdr(DetallesAct.p_activacion);
    end
    
    if ~isempty(DetallesPrePost)
        DetallesPrePost.q = ioi_fdr(DetallesPrePost.p);
    end
    
    if ~isempty(DetallesInt)
        DetallesInt.q = ioi_fdr(DetallesInt.p);
    end
    
    fprintf('\n=== COMPLETE ANALYSIS FINISHED ===\n');

end