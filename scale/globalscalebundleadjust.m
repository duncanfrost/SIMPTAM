function [ outPTAM ] = globalscalebundleadjust(PTAM, World,nkeyframes,nconstraints,vConstraints)
%BUNDLEADJUST Does bundle adustment on the PTAM model.






ncameras = size(PTAM.KeyFrames,2);
npoints = size(PTAM.Map.points,2);

%Calculate the current error


dp = 1;
niter = 40;
iter = 0;

lambda = 0.11;



display('Generating id map...');
for i = 1:ncameras
    map{i} = generateidmap(PTAM.KeyFrames(i));
end



display('Filling constraint matrix');

range = 2:ncameras;

LocalKeyFrames = PTAM.KeyFrames(range);




[ ids ] = idsinkfs(LocalKeyFrames,PTAM.Map);

gtids = zeros(size(ids,1),1);
for i = 1:size(ids,1)
    gtids(i) = PTAM.Map.points(ids(i)).gtid;
end
    

npoints = size(ids,1);
  
counts = kfidhist(PTAM.KeyFrames,ids);

C = -1*ones(npoints,npoints);
for i = 1:size(vConstraints,2)
    p1 = vConstraints{i}.p1;
    p2 = vConstraints{i}.p2;
    
    
    if sum(ids == p1) > 0 && sum(ids == p2) > 0
        C(p1,p2) = vConstraints{i}.value;
    end
end



% C = C*0;
% C(1,6) = 1;
% C(5,7) = 1;
% C(3,4) = 1;


nconstraints = sum(sum(C>0));

display('Running...');



alpha = 10;

while iter < niter

    iter = iter + 1;
    
    
   
    %Calculate residuals and jacobian
    range = [2 3];

    [r, J] = scalecalculateresiduals2(PTAM, range, counts, map,true,ids,C,alpha);

    
    

    
    
    nresi = size(r,1);
    cres = r(nresi-nconstraints+1:nresi);
    
    bares =  r(1:nresi-nconstraints);
    baerror = bares'*bares;
    cerror = cres'*cres;

    error = r'*r;
    left = J'*J + lambda*diag(diag(J'*J));
    right = J'*r;
    pn = left\right;
    param = dp*pn;
    
%     H = left;
%     
%          
%     ncameras = size(PTAM.KeyFrames,2) - 1;
%     npoints = size(PTAM.Map.points,2);
%     
%     A = H(1:ncameras*6, 1:ncameras*6);
%     B = H(1:ncameras*6,ncameras*6+1:size(H,2));
%     C = B';
%     D = H(ncameras*6 + 1:size(H,2),ncameras*6 + 1:size(H,2));
%     
%     Dinv = inv(D); %This is easy to calculate;
%     
%     a = right(1:ncameras*6);
%     b = right(ncameras*6+1:size(H,2));
% 
%     
%     left1 = (A-B*Dinv*C);
%     right1 = a - B*Dinv*b;

    left1 = [];
    right1 = [];
    
   
    
    
    
    range = [size(PTAM.KeyFrames,2)-1 size(PTAM.KeyFrames,2)];
    
    %[vCameras, vPoints, mMeasurements, vCons, delta_cams, delta_points, errors1] = calculateresidualssparse2(PTAM.KeyFrames, PTAM.Map,map,true,lambda,left1,right1,vConstraints,J,r);
    
    
    
    [vC, vAC, vP, mM, vM, vCons, delta_cams, delta_points errors] = calculateresidualssparse3(PTAM.KeyFrames, range, PTAM.Map,map,true,lambda,left1,right1,vConstraints,J,r);
    
    error = errors.total;
    cerror = errors.constraints;

%     orig_delta_cams = param(1:6*(ncameras-1));
%     orig_delta_points = param(6*(ncameras-1)+1:size(param));
% 
%     cam_error = norm(orig_delta_cams-delta_cams);
%     point_error = norm(orig_delta_points-delta_points);

  
    
   
    
    
    newPTAM = sparsescaleapplyparam2(PTAM, vAC, vP);

    
    %[vCameras, vPoints, mMeasurements, vCons, delta_cams, delta_points, nerrors1] = calculateresidualssparse2(newPTAM.KeyFrames, newPTAM.Map,map,true,lambda,left1,right1,vConstraints,J,r);
    
    [vC, vAC, vP, mM,vM, vCons, delta_cams, delta_points nerrors] = calculateresidualssparse3(newPTAM.KeyFrames,range, newPTAM.Map,map,true,lambda,left1,right1,vConstraints,J,r);

    
    
    nerror = nerrors.total;
   

   
    

    clc
%     display(cam_error);
%     display(point_error);
    
    display(error);
    display(errors.ba);
    display(cerror);
    display(nerror);
    
    
    display(range);
    display(iter);
    %display(norm(param));
    display(lambda);
    display(nconstraints);
%     display(cres');
    display(norm(right));
    %display(baerror);
    %display(cerror);



    if nerror < error
        PTAM = newPTAM;
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







    



