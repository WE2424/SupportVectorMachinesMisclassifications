function [score] = GetScore(x, y, w, b)
estimation = x*w' + b;
score = sum((estimation > 0 & y > 0) | (estimation < 0 & y < 0), "all") / length(estimation);
end