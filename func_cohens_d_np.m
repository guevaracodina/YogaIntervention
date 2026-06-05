function d = func_cohens_d_np(x,y)
    % For the unpaired dataset
    x = x(~isnan(x));
    y = y(~isnan(y));
    nx = length(x); ny = length(y);
    mx = mean(x, 'omitnan');  my = mean(y, 'omitnan');
    sx = std(x, 'omitmissing');   sy = std(y, 'omitmissing');
    s_pooled = sqrt(((nx-1)*sx^2 + (ny-1)*sy^2) / (nx+ny-2));
    d = (my - mx) / s_pooled;    % Post - Pre
end