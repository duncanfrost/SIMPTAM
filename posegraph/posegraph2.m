function [ outPTAM] = posegraph2(PTAM, World,Ext)




inPTAM = PTAM;

ncameras = size(PTAM.KeyFrames,2);

dp = 0.01;
iter = 1;
niter = 500;
lambda = 0.000000001;


for i = 1:ncameras
    map{i} = generateidmap(PTAM.KeyFrames(i));
end
    





% f = figure;
% g = figure;


while iter < niter
    iter = iter + 1;
    
 
    
    
    [r,J, ploterr] = calculateposeres(PTAM,Ext);
    
    
    left = J'*J + lambda*diag(diag(J'*J));
    right = J'*r;
    pn = left\right;
    dparam = -dp*pn;
    
    error = r'*r;
    
%     figure(f);
%     plot(ploterr);
%     
%     figure(g);
%     clf(g);
%     displaykeyframes(World,PTAM);
%     drawnow;
    
    PTAM2 = PTAM;
    for i=2:size(PTAM2.KeyFrames,2)
        mu =  dparam((6*(i-2) + 1:6*(i-2) + 6));
        PTAM2.KeyFrames(i).Camera.E = expmap(mu)*PTAM2.KeyFrames(i).Camera.E;
        
        if sum(sum(isnan(PTAM2.KeyFrames(i).Camera.E))) > 0
           display('something is wrong');
        end
        
        
        
    end
    
    [r,J] = calculateposeres(PTAM2,Ext);
    
    
    nerror = r'*r;
    
    
    if nerror < error
        PTAM = PTAM2;
        if lambda > 1e-30
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





