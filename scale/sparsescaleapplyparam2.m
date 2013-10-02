function [outPTAM] = sparsescaleapplyparam2(PTAM, vActiveCameras, vPoints)





for j = 1:size(vActiveCameras,2)
    
    change = expmap(vActiveCameras{j}.delta);
    c = vActiveCameras{j}.c;
    PTAM.KeyFrames(c).Camera.E = change*PTAM.KeyFrames(c).Camera.E;
end
    

for i = 1:size(vPoints,2)
    PTAM.Map.points(i).location(1:3) = PTAM.Map.points(i).location(1:3) + vPoints{i}.delta;
end




outPTAM = PTAM;
        

end

