function [ outPTAM] = posegraph(PTAM, World)



error1 = [];
pls1 = [];
clc;
Exts1 = [];
EExts1 = [];
ncameras = size(PTAM.KeyFrames,2);

J = zeros(6*ncameras, 6*ncameras);
r = zeros(6*ncameras,1);
iter = 1;
niter = 1000;
nparams = 6;

for i = 1:size(PTAM.KeyFrames,2)-1
    if i == size(PTAM.KeyFrames,2)
        j = 1;
    else
        j = i + 1;
    end
    
    W12 = World.KeyFrames(i).Camera.E/World.KeyFrames(j).Camera.E;
    tprior = -W12(1:3,1:3)*W12(1:3,4);
    pl = norm(tprior);
    
    if i == size(PTAM.KeyFrames,2)
         [Ext{i} E1 F1] = calculateext(PTAM.KeyFrames(i),PTAM.KeyFrames(j),PTAM.KeyFrames(i).Camera.K,pl);
    else
        [Ext{i} E1 F1] = calculateext(PTAM.KeyFrames(i),PTAM.KeyFrames(j),PTAM.KeyFrames(i).Camera.K,pl);
    end
end


        
        


while iter < niter
    iter = iter + 1;
    

    for i = 1:size(PTAM.KeyFrames,2)-1

        

        if i == size(PTAM.KeyFrames,2)
            j = 1;
        else
            j = i + 1;
        end






      



        Ti = PTAM.KeyFrames(i).Camera.E;
        Tj = PTAM.KeyFrames(j).Camera.E;
     

        Tji = Tj/Ti;
        Tij = Ti/Tj;
        in = Ext{i}*Tij;
        
        
        if( rcond(in) < 1e-12 )
           display('This doesnt look good');
        end

        
        if ~isreal(logmap2(in))
            display('This doesnt look good');
        end
        
        

        r(6*(i-1) + 1:6*(i-1) + 6) = logmap2(in);
        
        
        
        for k = 1:nparams
            J(6*(i-1) + k,6*(i-1) + k) = 1;
            J(6*(i-1) + k,6*(j-1) + k) = -1;
        end
         
    end
    
    
    
    
    
     dparam = -0.1*J'*r;
     
     for i=1:size(PTAM.KeyFrames,2)
         mu =  dparam((6*(i-1) + 1:6*(i-1) + 6));
         PTAM.KeyFrames(i).Camera.E = expmap(mu)*PTAM.KeyFrames(i).Camera.E;
     end
     
     error = r'*r;
     clc;
     display(iter);
     display(error);


end


r = zeros(6*ncameras,1);
for i = 1:size(World.KeyFrames,2)-1
    
%     display(i);
    
    if i == size(World.KeyFrames,2)
        j = 1;
    else
        j = i + 1;
    end
    
     
    Ti = World.KeyFrames(i).Camera.E;
    Tj = World.KeyFrames(j).Camera.E;
    Tij = Ti/Tj;
    in = Ext{i}*Tij;
    
 

    Tij = Ti/Tj;
    Tji = Tj/Ti;
    in = Ext{i}*Tij;
    r(6*(i-1) + 1:6*(i-1) + 6) = logmap2(in);

end
error2 = r'*r;

display(error2);



outPTAM = PTAM;


end

function [C] = crossnot(w)

C = zeros(3,3);

C(1,2) = -w(3);
C(2,1) = w(3);

C(1,3) = w(2);
C(3,1) = -w(2);

C(3,2) = w(1);
C(2,3) = -w(1);

end


function [error1 error2] = calculateerror(Keyframe1, Keyframe2,K,E1,E2)

kf1points = [];
kf2points = [];
ids = [];
ids2 = [];
error1 = 0;
error2 = 0;

for i = 1:length(Keyframe1.ImagePoints)
    for j = 1:length(Keyframe2.ImagePoints)
        if (Keyframe1.ImagePoints(i).id == Keyframe2.ImagePoints(j).id)
            kf1p = K\Keyframe1.ImagePoints(i).location;
            kf1p = kf1p / kf1p(3);
            kf2p = K\Keyframe2.ImagePoints(j).location;
            kf2p = kf2p / kf2p(3);
            kf1points = [kf1points kf1p];
            kf2points = [kf2points kf2p];
            ids = [ids Keyframe1.ImagePoints(i).id];
            ids2 = [ids2 Keyframe2.ImagePoints(j).id];
            
        end
        
    end
end


for i = 1:size(kf1points,2)
    error1 = error1 + abs(kf2points(:,i)'*E1*kf1points(:,i));
    error2 = error2 + abs(kf2points(:,i)'*E2*kf1points(:,i));
end

end





