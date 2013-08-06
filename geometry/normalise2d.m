function [T] = normalise2d(matches)

centroid = mean(matches,2);
nmatches = matches-centroid(:,ones(size(matches,2),1));

d = nmatches(1,:).^2 + nmatches(2,:).^2;
d = mean(sqrt(d));
s = sqrt(2)/d;
c = centroid;
c(1:2) = -c(1:2)*s;
T = [s 0; 0 s; 0 0];
T = [T c];

end


