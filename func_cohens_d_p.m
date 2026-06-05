function d = func_cohens_d_p(x,y)

    valid = ~isnan(x) & ~isnan(y);

    x = x(valid);
    y = y(valid);

    diff = y - x;

    d = mean(diff) / std(diff);

end