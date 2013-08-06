function [outPTAM ] = correctscale(PTAM, World)

display('Calculating scale diff');


KeyFrame = World.KeyFrames(size(World.KeyFrames,2));
E = KeyFrame.Camera.E;




[X1 x1 ids1] = findmapkeyframematches(World.Map, KeyFrame,0,false);
[X2 x2 ids2] = findmapkeyframematches(PTAM.Map, KeyFrame,0,false);


sharedids = [];
sharedX1 = [];
sharedX2 = [];
for i = 1:size(ids1,2)
    for j = 1:size(ids2,2)
        
        if ids1(i) == ids2(j)
            sharedids = [sharedids ids1(i)];
            
            sharedX1 = [sharedX1 E*X1(:,i)];
            sharedX2 = [sharedX2 E*X2(:,j)];
        end
    end
end

npoints = size(sharedids,2);


ncomb = ((npoints-1)*((npoints-1) + 1)) /2;
nresi = 3*ncomb;



r = zeros(nresi,1);
J = zeros(nresi, npoints);

s = ones(npoints,1);


















D = zeros(3,1);
N = zeros(3,1);

iter = 0;
niter = 20;



while iter < niter
    iter = iter + 1;
    count = 0;
    for i = 1:npoints-1
        for j = i+1:npoints
            count = count + 1;
            
            D(1) = (sharedX1(1,i) - sharedX1(1,j));
            D(2) = (sharedX1(2,i) - sharedX1(2,j));
            D(3) = (sharedX1(3,i) - sharedX1(3,j));
            
            N(1) = (s(i)*sharedX2(1,i) - s(j)*sharedX2(1,j));
            N(2) = (s(i)*sharedX2(2,i) - s(j)*sharedX2(2,j));
            N(3) = (s(i)*sharedX2(3,i) - s(j)*sharedX2(3,j));
            
            
            
           
            
            
            resiStart = 3*(count-1) + 1;
            resiEnd = 3*(count-1) + 3;
            
            
            
            
            r(resiStart:resiEnd) = D.^2 - N.^2;
            
            
            J(3*(count-1) + 1,i) = -2*N(1)*sharedX2(1,i);
            J(3*(count-1) + 2,i) = -2*N(2)*sharedX2(2,i);
            J(3*(count-1) + 3,i) = -2*N(3)*sharedX2(3,i);
            
            
            J(3*(count-1) + 1,j) = 2*N(1)*sharedX2(1,j);
            J(3*(count-1) + 2,j) = 2*N(2)*sharedX2(2,j);
            J(3*(count-1) + 3,j) = 2*N(3)*sharedX2(3,j);
            
           
            
            
        end
    end
    
    right = J'*r;
    left = J'*J;
    dt1 = left\right;
    dt = dt1;

    s = s - dt;
            
    
    clc;
    
    
    error = r'*r;
    display(error);
    display(norm(s));
%     display(dt1);
%     display(dt);
%     display(s);
    display(iter);
    
    
%     pause(0.5);
    
    
    
    
end



outPTAM = PTAM;
for i = 1:npoints
    for j = 1:size(outPTAM.Map.points,2)
        if outPTAM.Map.points(j).id == sharedids(i)
            pointWorld = double(outPTAM.Map.points(j).location);
            pointCamera = E*pointWorld;
            pointCamera(1:3) = pointCamera(1:3)*s(i);
            Rinv = E(1:3,1:3)';
            tinv = -Rinv*E(1:3,4);
            Einv = [Rinv tinv; 0 0 0 1];
            outPTAM.Map.points(j).location = Einv*pointCamera;
%             outPTAM.Map.points(j).location(1:3) = outPTAM.Map.points(j).location(1:3)*s(i);
        end
    end
end







end

