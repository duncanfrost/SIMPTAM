function [ outPTAM ] = scalebundleadjust(PTAM, World,nkeyframes,nconstraints,Cgt)
%BUNDLEADJUST Does bundle adustment on the PTAM model.






ncameras = size(PTAM.KeyFrames,2);
npoints = size(PTAM.Map.points,2);








%Calculate the current error


dp = 1;
niter = 200;
iter = 0;

lambda = 0.002;

for i = 1:ncameras
    map{i} = generateidmap(PTAM.KeyFrames(i));
end


if size(PTAM.KeyFrames,2) <= 2
    outPTAM = PTAM;
    return;
else
    if size(PTAM.KeyFrames,2) < nkeyframes + 2
        range = 3:size(PTAM.KeyFrames,2);
    else
        range =  size(PTAM.KeyFrames,2)-(nkeyframes-1):size(PTAM.KeyFrames,2);
        
        KeyFrame1 = PTAM.KeyFrames(size(PTAM.KeyFrames,2));
        kf1position = camcentre(KeyFrame1.Camera.E);
        [KeyFrame2 indices] =  findclosestkeyframe(PTAM.KeyFrames,kf1position,nkeyframes);
        range = indices;
        
        
    end
end

LocalKeyFrames = PTAM.KeyFrames(range);




[ ids ] = idsinkfs(LocalKeyFrames,PTAM.Map);

gtids = zeros(size(ids,1),1);
for i = 1:size(ids,1)
    gtids(i) = PTAM.Map.points(ids(i)).gtid;
end
    

npoints = size(ids,1);
  
counts = kfidhist(PTAM.KeyFrames,ids);


C = ones(npoints,npoints)*-1;

% for i = 1:nconstraints
%     consi = randi([1 npoints]);
%     consj = consi;
%     while consj == consi
%         consj = randi([1 npoints]);
%     end
% 
%     if consj < consi
%         temp = consi;
%         consi = consj;
%         consj = temp;
%     end
% 
%     X1 = World.Map.points(gtids(consi)).location;
%     X2 = World.Map.points(gtids(consj)).location;
% 
%     C(consi,consj) = norm(X1 - X2);
% end


for i = 1:size(Cgt,1)-1
    for j = i+1:size(Cgt,2)
        
        if sum(gtids == i)>0 && sum(gtids == j)>0
            consi = gtids == i;
            consj = gtids == j;
            C(consi,consj) = Cgt(i,j);
        end
        
    end
end






nconstraints = sum(sum(C>0));







while iter < niter

    iter = iter + 1;
    
    
   
    %Calculate residuals and jacobian
    tic
    [r, J] = scalecalculateresiduals(PTAM, range, counts, map,true,ids,C);
    toc
    
    nresi = size(r,1);
    cres = r(nresi-nconstraints+1:nresi);
    
    bares =  r(1:nresi-nconstraints);
    baerror = bares'*bares;
    cerror = cres'*cres;

    error = r'*r;
    left = J'*J + lambda*diag(diag(J'*J));
    right = J'*r;
    pn = left\right;
    param = -dp*pn;






    
    
    newPTAM = scaleapplyparam(PTAM, range,ids, param);

    [nr] = scalecalculateresiduals(newPTAM, range, counts,map,true,ids,C);
    
    
    nerror = nr'*nr;
    

    clc
    display(error);
    display(nerror);
    display(range);
    display(iter);
    display(norm(param));
    display(lambda);
    display(nconstraints);
    display(cres');
    display(baerror);
    display(cerror);


    
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







    



