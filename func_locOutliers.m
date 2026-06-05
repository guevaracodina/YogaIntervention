function y = func_locOutliers(x, pct)
    % Calculation by percentiles
    % Calculate percentiles by column
    low  = prctile(x,pct(1));
    high = prctile(x,pct(2));
    % Shows the mask of prctile values
    mask = (x >= low) & (x <= high);
    % if mask = 1 - not an outlier, if mask = 0 - is an outlier
    [row, col] = find(mask == 0);

    y = [row, col];
end