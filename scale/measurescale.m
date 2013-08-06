function [ ] = measurescale(PTAM, World)

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
D_gt = -1*ones(npoints,npoints);
D_est = D_gt;



for i = 1:size(sharedids,2)
    for j = i:size(sharedids,2)
        if i~=j
            D_gt(i,j) = norm(sharedX1(:,i) - sharedX1(:,j));
            D_est(i,j) = norm(sharedX2(:,i) - sharedX2(:,j));
            
            
        end
        
    end
end




D_est = D_est + -1*(D_est==0);
D_gt = D_gt + -1*(D_gt==0);

err = D_est ./ D_gt;
display('Calculating scale diff');
display(mean(mean(err)));
display(std(std(err)));



    
    
    




end

