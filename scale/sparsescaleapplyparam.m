function [outPTAM] = sparsescaleapplyparam(PTAM, vCameras, vPoints)





for j = 2:size(vCameras,2)
    change = expmap(vCameras{j}.delta);
    PTAM.KeyFrames(j).Camera.E = change*PTAM.KeyFrames(j).Camera.E;
end
    

for i = 1:size(vPoints,2)
    PTAM.Map.points(i).location(1:3) = PTAM.Map.points(i).location(1:3) + vPoints{i}.delta;
end




outPTAM = PTAM;
        

end

