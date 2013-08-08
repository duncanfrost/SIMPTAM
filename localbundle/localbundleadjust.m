function [ outPTAM ] = localbundleadjust(PTAM, World,nkeyframes)
%BUNDLEADJUST Does bundle adustment on the PTAM model.






ncameras = size(PTAM.KeyFrames,2);
npoints = size(PTAM.Map.points,2);




%Calculate the current error


dp = 1;
niter = 5;
iter = 0;

lambda = 0.002;

for i = 1:ncameras
    map{i} = generateidmap(PTAM.KeyFrames(i));
end


if size(PTAM.KeyFrames,2) < 2
    outPTAM = PTAM;
    return;
else
    if size(PTAM.KeyFrames,2) < nkeyframes + 2
        range = 3:size(PTAM.KeyFrames,2);
    else
        range =  size(PTAM.KeyFrames,2)-(nkeyframes-1):size(PTAM.KeyFrames,2);
    end
end

LocalKeyFrames = PTAM.KeyFrames(range);




[ ids ] = idsinkfs(LocalKeyFrames,PTAM.Map);


  
counts = kfidhist(PTAM.KeyFrames,ids);





while iter < niter

    iter = iter + 1;
    
    
   
    %Calculate residuals and jacobian
    tic
    [r, J] = localcalculateresiduals(PTAM, range, counts, map,true,ids);
    toc
    

    error = r'*r;
    left = J'*J + lambda*diag(diag(J'*J));
    right = J'*r;
    pn = left\right;
    param = -dp*pn;






    
    
    newPTAM = localapplyparam(PTAM, range,ids, param);

    [nr] = localcalculateresiduals(newPTAM, range, counts,map,true,ids);
    
    
    nerror = nr'*nr;
    

    clc
    display(error);
    display(nerror);
    display(range);
    display(iter);
    display(norm(param));
    display(lambda);


    
    if nerror < error
        PTAM = newPTAM;
        lambda = lambda * (1-0.2);
    else
        lambda = lambda * (1+0.2);
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







    



