function [ outPTAM ] = camadjust(PTAM, World)

ncameras = size(PTAM.KeyFrames,2);


D = zeros(ncameras,ncameras);

for i = 1:ncameras-1
    X1 = camcentre(World.KeyFrames(i).Camera.E);
    X2 = camcentre(World.KeyFrames(i+1).Camera.E);
    
    D(i,i+1) = norm(X1-X2);
    
end


niter = 1000;
iter = 1;



while iter < niter
    
    iter = iter + 1;
    
    [r, J] = camcalculateresiduals(PTAM, D);
    
    error = r'*r;
    
    
    s = -0.0001*J'*r;
    
    newPTAM = camapplyparam(PTAM,D,s);
    
    
    [nr, ~] = camcalculateresiduals(newPTAM, D);
    
    nerror = nr'*nr;
    
    if nerror < error
        PTAM = newPTAM;
    end
    
    clc;
    display(iter);
    display(error);
    display(nerror);
    
    
    
    
end

outPTAM = PTAM;
end


function [r, J] = camcalculateresiduals(PTAM, D)
nresi = sum(sum(D>0));
r = zeros(nresi,1);
J = zeros(nresi,2*nresi);
ncameras = size(PTAM.KeyFrames,2);
row = -1;
N1 = zeros(3,1);
N2 = zeros(3,1);
for i = 1:ncameras-1
    for j = i+1:ncameras
        if D(i,j) > 0
            row = row + 2;
            
            E1 = PTAM.KeyFrames(i).Camera.E;
            E2 = PTAM.KeyFrames(j).Camera.E;
            
            
            X1 = E2*[camcentre(E1); 1];
            X2 = E1*[camcentre(E2); 1];
            
            N1(1) = X1(1);
            N1(2) = X1(2);
            N1(3) = X1(3);
            
            N2(1) = X2(1);
            N2(2) = X2(2);
            N2(3) = X2(3);
            
            

            J(row,row) = 2*(X1(1)*N1(1) + X1(2)*N1(2) + X1(3)*N1(3));
            J(row+1,row+1) = 2*(X2(1)*N2(1) + X2(2)*N2(2) + X2(3)*N2(3));
            
            r(row) = N1'*N1 - D(i,j)^2;
            r(row+1) = N2'*N2 - D(i,j)^2;    
        end
    end
end



end


function [PTAM] = camapplyparam(PTAM,D,s)

ncameras = size(PTAM.KeyFrames,2);
row = -1;
for i = 1:ncameras-1
    for j = i+1:ncameras
        if D(i,j) > 0
            row = row + 2;
            s1 = s(row);
            s2 = s(row+1);
            
             E1 = PTAM.KeyFrames(i).Camera.E;
            E2 = PTAM.KeyFrames(j).Camera.E;
            
            
            X1 = E2*[camcentre(E1); 1];
            X2 = E1*[camcentre(E2); 1];
            
            X1n = X1(1:3)*(s1 + 1);
            X2n = X2(1:3)*(s2 + 1);
            
            X1n = E2\[X1n; 1]; 
            X2n = E1\[X2n; 1];
            
            R1 = PTAM.KeyFrames(i).Camera.E(1:3,1:3);
            R2 = PTAM.KeyFrames(j).Camera.E(1:3,1:3);
            
            t1 = -R1*X1n(1:3);
            t2 = -R2*X2n(1:3);
            PTAM.KeyFrames(i).Camera.E(1:3,4) = t1(1:3);
            PTAM.KeyFrames(j).Camera.E(1:3,4) = t2(1:3);
            
            
        end
    end
end








end