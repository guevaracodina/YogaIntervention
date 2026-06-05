function TS_img_copy = func_clc_or_median_NaNVal_Table(TS_img, strc_image)

% ======================================
timeG_len = numel(unique(TS_img.TimeG));
metric_len = numel(unique(TS_img.Metric));
stimulus_len = numel(unique(TS_img.Stimulus));
hb_len = numel(unique(TS_img.Hb));
ch_len = numel(unique(TS_img.Channel));
typeK_len = numel(unique(TS_img.Type_aly));
% ------
subj_len = numel(unique(TS_img.Subj));

% ======================================
timeG_name = {strc_image.ngp};
hb_name = unique(TS_img.Hb);
stimulus_name = unique(TS_img.Stimulus);

%%
% tic % ======================
% TS_img_copy = TS_img;
% Value_new = TS_img_copy.Value; % copy
% 
% [G, ~] = findgroups( ...
%     TS_img_copy.TimeG, ...
%     TS_img_copy.Hb, ...
%     TS_img_copy.Stimulus, ...
%     TS_img_copy.Channel, ...
%     TS_img_copy.Metric, ...
%     TS_img_copy.Type_aly);
% 
% for g = 1:max(G)
% 
%     idx = (G == g);
%     vals = TS_img_copy.Value(idx);
% 
%     nNaN = sum(isnan(vals));
% 
%     if (nNaN / subj_len) > 0.5
%         Value_new(idx) = NaN;
% 
%     elseif any(isnan(vals))
%         med = median(vals, 'omitnan');
%         vals(isnan(vals)) = med;
%         Value_new(idx) = vals;
%     end
% end
% 
% TS_img_copy.Value = Value_new;
% toc

% =================
%% Do not delete this block in case there is a problem
for g = 1:timeG_len
    for met = 1:metric_len
        for stm = 1:stimulus_len
            for hb = 1:hb_len
                for tyK = 1:typeK_len
                    for ch = 1:ch_len

                        TS_CY = TS_img(strcmp(TS_img.TimeG, timeG_name{g}) & ...
                               strcmp(TS_img.Hb, hb_name{hb}) & ...
                               strcmp(TS_img.Stimulus, stimulus_name{stm}) & ...
                               TS_img.Channel == ch & ...
                               TS_img.Metric == met & ...
                               TS_img.Type_aly == tyK, :);

                        nNaN = sum(isnan(TS_CY.Value)); % Number of subjects with NaN value
                        if (nNaN/subj_len) > 0.5 
                            TS_CY.Value = NaN;
                        elseif any(isnan(TS_CY.Value)) % we replace the NaNs with the median of the channel without NaNs
                            median_noNaN = median(TS_CY.Value, 'omitmissing');
                            TS_CY.Value(isnan(TS_CY.Value)) = median_noNaN;
                        end
                        TS_img{strcmp(TS_img.TimeG, timeG_name{g}) & ...
                               strcmp(TS_img.Hb, hb_name{hb}) & ...
                               strcmp(TS_img.Stimulus, stimulus_name{stm}) & ...
                               TS_img.Channel == ch & ...
                               TS_img.Metric == met & ...
                               TS_img.Type_aly == tyK, 8} = TS_CY.Value;

                        % idx = TS_img.TimeG == timeG_name{g} & ...
                        %       TS_img.Hb == hb_name{hb} & ...
                        %       TS_img.Stimulus == stimulus_name{stm} & ...
                        %       TS_img.Channel == ch & ...
                        %       TS_img.Metric == met & ...
                        %       TS_img.Type_aly == tyK;
                        % 
                        % TS_img{idx, 8} = TS_CY.Value;

                    end
                end
            end
        end
    end
end
TS_img_copy = TS_img;
%% Compare whether the data are the same
% sum((TS_img.Value == TS_img_copy.Value), 1), 
end
