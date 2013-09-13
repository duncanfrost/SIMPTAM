function [ outPTAM ] = estimatepose(PTAM)
%BUNDLEADJUST Does bundle adustment on the PTAM model.



dp = 1;
niter = 80;
iter = 0;
lambda = 10;
map = generateidmap(PTAM.CurrFrame);

while iter < niter
    

    iter = iter + 1;

    [r, J] = calculateresidualscamonly(PTAM.Camera, PTAM.CurrFrame, PTAM.Map,map,true);
    
    error = r'*r;
    left = J'*J + lambda*diag(diag(J'*J));
    right = J'*r;
    pn = left\right;

    param = -dp*pn;
   
    NewCam = PTAM.Camera;
    NewCam.E = expmap(param)*PTAM.Camera.E; 
    [r] = calculateresidualscamonly(NewCam, PTAM.CurrFrame, PTAM.Map,map,true);
    nerror = r'*r;
    
    
    if nerror <= error
        error = nerror;
        PTAM.Camera.E = expmap(param)*PTAM.Camera.E; 
        %PTAM.Camera.se3 = PTAM.Camera.se3 + param;
        lambda = lambda * (1-0.1);
    else
        lambda = lambda * (1+0.1);
    end
    
    clc;
    display(error);
    display(iter);
    display(norm(param));
end

outPTAM = PTAM;

end





    






