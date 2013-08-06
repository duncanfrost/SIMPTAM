function [ outPTAM] = posegraph3(PTAM, World,Ext)




inPTAM = PTAM;

ncameras = size(PTAM.KeyFrames,2);

dp = 0.01;
iter = 1;
niter = 500;
lambda = 0.0000001;


for i = 1:ncameras
    map{i} = generateidmap(PTAM.KeyFrames(i));
end
    





f = figure;


while iter < niter
    iter = iter + 1;
    
    
    
    
    [r,J, ploterr] = calcposeres(PTAM,Ext);
    
    
    left = J'*J + lambda*diag(diag(J'*J));
    right = J'*r;
    pn = left\right;
    dparam = -dp*pn;
    
    error = r'*r;
    
    figure(f);
    plot(ploterr);
    drawnow;
    
    PTAM2 = PTAM;
    for i=2:size(PTAM2.KeyFrames,2)
        mu =  dparam((6*(i-2) + 1:6*(i-2) + 6));
        PTAM2.KeyFrames(i).Camera.E = expmap(mu)*PTAM2.KeyFrames(i).Camera.E;
        
        if sum(sum(isnan(PTAM2.KeyFrames(i).Camera.E))) > 0
%             display('something is wrong');
        end
        
        
        
    end
    
    [r,J] = calcposeres(PTAM2,Ext);
    
    
    nerror = r'*r;
    
    
    if nerror < error
        PTAM = PTAM2;
        if lambda > 1e-15
            lambda = lambda * (1-0.1);
        end
    else
        lambda = lambda * (1+0.1);
    end
    
    
    

    clc;
    display(iter);
    display(error);
    display(nerror);
    display(lambda);
    
    
end


r = zeros(6*ncameras,1);
for i = 1:size(World.KeyFrames,2)
    
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
    r(6*(i-1) + 1:6*(i-1) + 6) = logmap(in);
    
    
    
end
error2 = r'*r;

display(error2);



outPTAM = PTAM;


for i = 1:size(inPTAM.Map.points,2)
    id = PTAM.Map.points(i).id;
    for j = 1:size(PTAM.KeyFrames,2) 
        pointIndex = map{j}(id);
        if pointIndex > 0
            Told = inPTAM.KeyFrames(j).Camera.E;
            Tnew = outPTAM.KeyFrames(j).Camera.E;
            newlocation = Tnew\Told*outPTAM.Map.points(i).location;
            diff = outPTAM.Map.points(i).location-newlocation;
            if norm(diff) > 0.01
                outPTAM.Map.points(i).location = outPTAM.Map.points(i).location + diff*1;
                break;
            end
        end
        
    end
    
    
end








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


function [r,J, ploterr] = calcposeres(PTAM,Ext)
nparams = 6;
ncameras = size(PTAM.KeyFrames,2);
nresid = ncameras;

J = zeros(6*nresid, 6*(ncameras-1));
r = zeros(6*nresid,1);

ploterr = zeros(size(PTAM.KeyFrames,2));


for i = 1:nresid-1
    
    
    
    if i == size(PTAM.KeyFrames,2)
        j = 1;
    else
        j = i + 1;
    end
    
    
    
    
    
    
    
    
    
    
    Ti = PTAM.KeyFrames(i).Camera.E;
    Tj = PTAM.KeyFrames(j).Camera.E;
    Tji = Ext{i};
    Rji = Tji(1:3,1:3);
    tji = Tji(1:3,4);
    
    
    

    Tij = Ti/Tj;
    in = Tji*Tij;
    r_small = logmap(in);
    tau = r_small(1:3);
    phi = r_small(4:6);
    
    A = [-crossnot(phi) -crossnot(tau);
        zeros(3,3) -crossnot(phi)];
    
    B = eye(6,6) + 0.5*A;
    C = [Rji crossnot(tji)*Rji
        zeros(3,3) Rji];
    
    J1 = B*C;
    
    A = [crossnot(phi) crossnot(tau);
        zeros(3,3) crossnot(phi)];
    B = eye(6,6) + 0.5*A;
    
    J2 = -B;
    
    
    
    
    
    
    
    if( rcond(in) < 1e-12 )
%         display('This doesnt look good');
    end
    
    
    if ~isreal(logmap(in))
%         display('This doesnt look good');
    end
    
    
    
    r(6*(i-1) + 1:6*(i-1) + 6) = logmap(in);
    ploterr(i) = norm(logmap(in));
    
    
%     for k = 1:nparams
%         if (i~=1)
%             J(6*(i-1) + k,6*(i-2) + k) = 1;
%         end
%         if (j~=1)
%             J(6*(i-1) + k,6*(j-2) + k) = -1;
%         end
%     end


if i ~= 1
    J(6*(i-1) + 1: 6*(i-1) + 6, 6*(i-2) + 1: 6*(i-2) + 6) = J1;
end
if j ~= 1
    J(6*(i-1) + 1: 6*(i-1) + 6, 6*(j-2) + 1: 6*(j-2) + 6) = J2;
end



        
    
end
end
function map = generateidmap(KeyFrame)

map = ones(500,1)*-1;
for i = 1:size(KeyFrame.ImagePoints,2)
    map(KeyFrame.ImagePoints(i).id) = i;
end

% map = -1*(map==0) + map;
end





