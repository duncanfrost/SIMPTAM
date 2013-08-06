function [ outPTAM ] = bundleadjust(PTAM, World)
%BUNDLEADJUST Does bundle adustment on the PTAM model.






ncameras = size(PTAM.KeyFrames,2);
npoints = size(PTAM.Map.points,2);




%Calculate the current error


dp = 1;
niter = 5;
iter = 0;

lambda = 0.00000018;

for i = 1:ncameras
    map{i} = generateidmap(PTAM.KeyFrames(i));
end
    



while iter < niter

    iter = iter + 1;
    
    
   
    %Calculate residuals and jacobian
    [r, J] = calculateresiduals(PTAM.KeyFrames, PTAM.Map,map,true);
   


    error = r'*r;
    left = J'*J + lambda*diag(diag(J'*J));
    right = J'*r;
    pn = left\right;
    param = -dp*pn;

    
    
    newPTAM = applyparam(PTAM, param);

    [nr] = calculateresiduals(newPTAM.KeyFrames, newPTAM.Map, map,false);
    
    
    nerror = nr'*nr;
    
    
    rescalePTAM = applyrescale(newPTAM,World);

    [rr] = calculateresiduals(rescalePTAM.KeyFrames, rescalePTAM.Map, map,false);
    rerror = rr'*rr;
    
    
    clc
    display(error);
    display(nerror);
    display(rerror);
    display(iter);
    display(norm(param));
    display(lambda);

    
    if rerror < error
        PTAM = rescalePTAM;
        lambda = lambda * (1-0.1);
    else
        lambda = lambda * (1+0.1);
    end
    
end



outPTAM = PTAM;




end


function map = generateidmap(KeyFrame)

map = ones(500,1)*-1;
for i = 1:size(KeyFrame.ImagePoints,2)
    map(KeyFrame.ImagePoints(i).id) = i;
end

% map = -1*(map==0) + map;
end



