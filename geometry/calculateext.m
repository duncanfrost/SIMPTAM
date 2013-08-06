function [Ext E F2] = calculateext(Keyframe1, Keyframe2,K,priorlength)

kf1points = [];
kf2points = [];
ids = [];
ids2 = [];

for i = 1:length(Keyframe1.ImagePoints)
    for j = 1:length(Keyframe2.ImagePoints)
        if (Keyframe1.ImagePoints(i).id == Keyframe2.ImagePoints(j).id)
            kf1p = Keyframe1.ImagePoints(i).location;
            kf1p = kf1p / kf1p(3);
            kf2p = Keyframe2.ImagePoints(j).location;
            kf2p = kf2p / kf2p(3);
            kf1points = [kf1points kf1p];
            kf2points = [kf2points kf2p];
            ids = [ids Keyframe1.ImagePoints(i).id];
            ids2 = [ids2 Keyframe2.ImagePoints(j).id];
            
        end
        
    end
end

R = [];
t = [];

while isempty(R)
    
    
    perm = randperm(size(kf1points,2));
    kf1points = kf1points(:,perm);
    kf2points = kf2points(:,perm);
    % kf1points = kf1points(:,1:12);
    % kf2points = kf2points(:,1:12);
    
    F2 = fundmatrix(kf1points,kf2points);
    
%     F2 = estimateFundamentalMatrix(kf1points(1:2,:)',kf2points(1:2,:)','Method','MSAC');
    % F = vgg_F_from_7pts_2img(kf1points(:,1:7),kf2points(:,1:7));
%     display(F);
    E = K'*F2*K;
    t = null(E');
%     display(t);
    t1 = t;
    t2 = -t;
    
    ferror = 0;
    ferror2 = 0;
    for i = 1:size(kf1points,2)
%         ferror = ferror + abs(kf2points(:,i)'*F1*kf1points(:,i));
        ferror2 = ferror2 + abs(kf2points(:,i)'*F2*kf1points(:,i));
    end
%     display(ferror);
% %     
    
    
    
    [U, S, V] = svd(E);
    
    W = [0 -1 0; 1 0 0; 0 0 1];
    
    R1 = U*W*V';
    R2 = U*W'*V';
    
    % display(R1);
    % display(R2);
    
    P = [eye(3,3) zeros(3,1)];
    P1 = [R1 t1];
    P2 = [R1 t2];
    P3 = [R2 t1];
    P4 = [R2 t2];
    
    
    
    
    error1 = 0;
    error2 = 0;
    error3 = 0;
    error4 = 0;
    
    for i = 1:size(kf1points,2)
        X1 = linearreproject(K\kf1points(:,i),K\kf2points(:,i),P,P1);
        X2 = linearreproject(K\kf1points(:,i),K\kf2points(:,i),P,P2);
        X3 = linearreproject(K\kf1points(:,i),K\kf2points(:,i),P,P3);
        X4 = linearreproject(K\kf1points(:,i),K\kf2points(:,i),P,P4);
        
        if (X1(3)>0.5)
            X1 = [R1 t1; 0 0 0 1]*X1;
            error1 = error1 + (X1(3)<0);
        else
            error1 = error1 + 1;
        end
        
        if (X2(3)>0.5)
            X2 = [R1 t2; 0 0 0 1]*X2;
            error2 = error2 + (X2(3)<0);
        else
            error2 = error2 + 1;
        end
        
        if (X3(3)>0.5)
            X3 = [R2 t1; 0 0 0 1]*X3;
            error3 = error3 + (X3(3)<0);
        else
            error3 = error3 + 1;
        end
        
        if (X4(3)>0.5)
            X4 = [R2 t2; 0 0 0 1]*X4;
            error4 = error4 + (X4(3)<0);
        else
            error4 = error4 + 1;
        end
        
        
    end
    
%     display(error1);
%     display(error2);
%     display(error3);
%     display(error4);
    
    
    
    if error1 == 0
        R = R1;
        t = t1;
    end
    
    if error2 == 0
        R = R1;
        t = t2;
    end
    
    if error3 == 0
        R = R2;
        t = t1;
    end
    
    if error4 == 0
        R = R2;
        t = t2;
    end
    
end


tscale = -R*t;
scale = abs(priorlength/norm(tscale));
tscalenew = tscale*scale;

t = -R'*tscalenew;






% display(R);
% display(t);
% 
% R = single(R);
% t = single(t);


Ext = [R t; 0 0 0 1];

end

