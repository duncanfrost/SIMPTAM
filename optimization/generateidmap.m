function map = generateidmap(KeyFrame)

map = ones(2000,1)*-1;
for i = 1:size(KeyFrame.ImagePoints,2)
    map(KeyFrame.ImagePoints(i).id) = i;
end
end
    