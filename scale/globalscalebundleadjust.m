function [ outPTAM ] = globalscalebundleadjust(PTAM, World,nkeyframes,nconstraints,Cgt)
%BUNDLEADJUST Does bundle adustment on the PTAM model.






ncameras = size(PTAM.KeyFrames,2);
npoints = size(PTAM.Map.points,2);

%Calculate the current error


dp = 1;
niter = 50;
iter = 0;

lambda = 0.001;



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
count = 0;
for i = 1:size(Cgt,1)-1
    for j = i:size(Cgt,2)
        
        if sum(gtids == i)>0 && sum(gtids == j)>0
            consi = find(gtids == i);
            consj = find(gtids == j);
            
            for k = 1:size(consi,1)
                for l = 1:size(consj,1)
                    ci = consi(k);
                    cj = consj(l);
                    if ci ~= cj
                        if cj<ci
                            temp = cj;
                            cj = ci;
                            ci = temp;
                        end
                        if C(ci,cj) == -1
                            C(ci,cj) = Cgt(i,j);
                            count = count + 1;
                        end
              
                    end
                end
            end
                
            
        end
        
    end
end






nconstraints = sum(sum(C>0));

display('Running...');





while iter < niter

    iter = iter + 1;
    
    
   
    %Calculate residuals and jacobian
    tic
    [r, J] = scalecalculateresiduals2(PTAM, range, counts, map,true,ids,C);
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
    
    [vC, vP, mM, delta_cams, delta_points] = calculateresidualssparse(PTAM.KeyFrames, PTAM.Map,map,true,lambda,left1,right1);
    
    






    
    
    newPTAM = scaleapplyparam(PTAM, range,ids, param);

    [nr] = scalecalculateresiduals2(newPTAM, range, counts,map,false,ids,C);
    
    
    nerror = nr'*nr;
   

   
    

    clc
    display(error);
    display(nerror);
    display(range);
    display(iter);
    display(norm(param));
    display(lambda);
    display(nconstraints);
%     display(cres');
    display(norm(right));
    display(baerror);
    display(cerror);


    PTAM = newPTAM;
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







    



