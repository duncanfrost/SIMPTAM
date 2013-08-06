function [outPTAM] = localapplyparam(PTAM, range,ids, param)


ncameras = size(PTAM.KeyFrames,2);
npoints = size(ids,1);


for i = 1:npoints
    index = findmappointid(PTAM.Map,ids(i)); 
    PTAM.Map.points(index).location(1:3) = PTAM.Map.points(index).location(1:3) + param(1 + 3*(i-1):3 + 3*(i-1));
end

    

for i = 1:ncameras
    if sum(i==range)>0
        kfcount = find(range==i);
        mu = param(3*npoints + 1 + 6*(kfcount-1): 3*npoints + 6 + 6*(kfcount-1));
        change = expmap(mu);
        PTAM.KeyFrames(i).Camera.E = change*PTAM.KeyFrames(i).Camera.E;
    end
end




outPTAM = PTAM;
        

end

