function map = generateidmap(KeyFrame)

map = ones(2000,1)*-1;
for i = 1:size(KeyFrame.ImagePoints,2)
    if ~isempty(KeyFrame.ImagePoints(i).id)
        map(KeyFrame.ImagePoints(i).id) = i;
    else
        display('no id');
    end
end
end
    