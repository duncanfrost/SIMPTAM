function [outPTAM ] = correctscale2(PTAM, World,cc)

display('Calculating scale diff');


KeyFrame = PTAM.KeyFrames(size(PTAM.KeyFrames,2));
E = KeyFrame.Camera.E;


count = 0;
for i = 1:size(KeyFrame.ImagePoints,2)
    if ~isempty(KeyFrame.ImagePoints(i).id)
        count = count + 1;
        gtids(count) = KeyFrame.ImagePoints(i).gtid;
        ids(count) = KeyFrame.ImagePoints(i).id;
    end
end



sharedids = [];
X_World = [];
X_PTAM = [];
for i = 1:size(gtids,2)
    X1 = World.Map.points(gtids(i)).location;
    X2 = PTAM.Map.points(ids(i)).location;
    X_World = [X_World X1];
    X_PTAM = [X_PTAM X2];
end

npoints = size(gtids,2);

nresi = 1;

consi = randi([1 npoints]);
consj = consi;
while consj == consi
    consj = randi([1 npoints]);
end

if consj < consi
    temp = consi;
    consi = consj;
    consj = temp;
end



C = zeros(npoints,npoints);
C(consi,consj) = norm(X_World(:,consi) - X_World(:,consj));



r = zeros(nresi,1);
J = zeros(nresi, 3*npoints);

s = ones(npoints,1);


















D = zeros(3,1);
N = zeros(3,1);

iter = 0;
niter = 200;

dparam = zeros(3*npoints,1);


while iter < niter
    iter = iter + 1;
    count = 0;
    for i = 1:npoints-1
        for j = i+1:npoints
            
            if C(i,j) > 0
                count = count + 1;
                
                
                dxi(1,1) = dparam(3*(i-1)+1);
                dxi(2,1) = dparam(3*(i-1)+2);
                dxi(3,1) = dparam(3*(i-1)+3);
                
                dxj(1,1) = dparam(3*(j-1)+1);
                dxj(2,1) = dparam(3*(j-1)+2);
                dxj(3,1) = dparam(3*(j-1)+3);
                
                N = (X_PTAM(1:3,i)+dxi) - (X_PTAM(1:3,j)+dxj);
                
                
                
                
                r = norm(N)^2 - C(i,j)^2;
                
                
                
                J(1,3*(i-1)+1) = 2*N(1);
                J(1,3*(i-1)+2) = 2*N(2);
                J(1,3*(i-1)+3) = 2*N(3);
                
                
                J(1,3*(j-1)+1) = -2*N(1);
                J(1,3*(j-1)+2) = -2*N(2);
                J(1,3*(j-1)+3) = -2*N(3);
            end
            
            
            
        end
    end
    
    right = J'*r;
%     left = J'*J;
    dt1 = right;
%     inv(left);
    dt = -0.001*dt1;
    
    dparam = dparam + dt;
    
    
    clc;
    
    
    error = r'*r;
    display(error);
    display(norm(dparam));
    %     display(dt1);
    %     display(dt);
    %     display(s);
    display(cc);
    display(iter);
    
    
%         pause(0.5);
    
    
    
    
end



outPTAM = PTAM;

for i = 1:npoints
    id = ids(i);
    dxi(1,1) = dparam(3*(i-1)+1);
    dxi(2,1) = dparam(3*(i-1)+2);
    dxi(3,1) = dparam(3*(i-1)+3);

    outPTAM.Map.points(id).location(1:3) = outPTAM.Map.points(id).location(1:3) + dxi;
end








end

