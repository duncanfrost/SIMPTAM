function [ outPTAM ] = bundleadjust(PTAM, World)
%BUNDLEADJUST Does bundle adustment on the PTAM model.






ncameras = size(PTAM.KeyFrames,2);
npoints = size(PTAM.Map.points,2);




%Calculate the current error


dp = 1;
niter = 5;
iter = 0;

lambda = 0.0000000001;

for i = 1:ncameras
    map{i} = generateidmap(PTAM.KeyFrames(i));
end
    
%dp = 0.0000001;


while iter < niter

    iter = iter + 1;
    
    
   
    %Calculate residuals and jacobian
    tic
      [r, J] = calculateresiduals(PTAM.KeyFrames, PTAM.Map,map,true);
    left = J'*J + lambda*diag(diag(J'*J));
    right = J'*r;
    pn = left\right;
    param = -dp*pn;
    toc
    
    H = left;
    
    ncameras = size(PTAM.KeyFrames,2) - 1;
    npoints = size(PTAM.Map.points,2);
    
    A = H(1:ncameras*6, 1:ncameras*6);
    B = H(1:ncameras*6,ncameras*6+1:size(H,2));
    C = B';
    D = H(ncameras*6 + 1:size(H,2),ncameras*6 + 1:size(H,2));
    
    Dinv = inv(D); %This is easy to calculate;
    
    a = right(1:ncameras*6);
    b = right(ncameras*6+1:size(H,2));

    
    left1 = (A-B*Dinv*C);
    right1 = a - B*Dinv*b;
    

   
    
    
    tic
    [vCameras, vPoints, mMeasurements, delta_cams, delta_points] = calculateresidualssparse(PTAM.KeyFrames, PTAM.Map,map,true,lambda,left1,right1);
    toc
    

    
   
    
    error = r'*r;
 
    
    
    rescount = size(r,1)/2;

    
    
    newPTAM = applyparam(PTAM, param);

    [nr] = calculateresiduals(newPTAM.KeyFrames, newPTAM.Map, map,false);
    
    
    nerror = nr'*nr;
    
    
    rescalePTAM = applyrescale(newPTAM,World);

    [rr] = calculateresiduals(rescalePTAM.KeyFrames, rescalePTAM.Map, map,false);
    rerror = rr'*rr;
    
    
    clc
    display(rescount);
    display(error);
    display(nerror);
    display(rerror);
    display(iter);
    display(norm(param));
    display(lambda);
    %display(res_end);

    
    if rerror < error
        PTAM = rescalePTAM;
        lambda = lambda * (1-0.1);
    else
        lambda = lambda * (1+0.1);
    end
    
end



outPTAM = PTAM;




end




