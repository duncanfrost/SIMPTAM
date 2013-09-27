function [vCameras, vPoints, mMeasurements, vCons, delta_cams, delta_points] = calculateresidualssparse2(KeyFrames, Map ,map,calcJ,lambda,left1,right1, vCons, J, r)
%CALCULATERESIDUALS Summary of this function goes here
%   Detailed explanation goes here

ncameras = size(KeyFrames,2);
npoints = size(Map.points,2);
camparams = 6;
pointparams = 3;
K = KeyFrames(1).Camera.K;






for i = 1:size(KeyFrames,2)
    vCameras{i}.U = zeros(6,6);
    vCameras{i}.ea = zeros(6,1);
end

for i = 1:size(Map.points,2)
    vPoints{i}.V = zeros(3,3);
    vPoints{i}.eb = zeros(3,1);
end




measCount = 0;







for i = 1:size(KeyFrames,2)
    
    for j = 1:size(KeyFrames(i).ImagePoints,2)
        
        id = KeyFrames(i).ImagePoints(j).id;
        if ~isempty(id)
            
            measCount = measCount + 1;
            
            
            E = KeyFrames(i).Camera.E;
            
            imagePoint = KeyFrames(i).ImagePoints(j).location;
            
            pointCamera = E*Map.points(id).location;
            X = pointCamera(1);
            Y = pointCamera(2);
            Z = pointCamera(3);
            x = X/Z;
            y = Y/Z;
            pix = K*[x y 1]';
            x = pix(1);
            y = pix(2);
            
            
            
            u = imagePoint(1);
            v = imagePoint(2);
            
            meas.err = [(u-x) (v-y)]';
            meas.c = i;
            meas.p = id;
            
            fx = K(1,1);
            fy = K(2,2);
            
            
            if calcJ
                
                A = zeros(2,6);
                B = zeros(2,3);
                if i > 1
                    for c = 1:camparams
                        [dX_dp dY_dp dZ_dp] = expdiffXn(X,Y,Z,eye(4,4),c);
                        A(1,c) = fx*(dX_dp*Z - dZ_dp*X)/(Z^2);
                        A(2,c)= fy*(dY_dp*Z - dZ_dp*Y)/(Z^2);
                    end
                end
                
                for p = 1:pointparams
                    [dX_dp dY_dp dZ_dp] = diffXn3D(E,p);
                    B(1,p) = fx*(dX_dp*Z - dZ_dp*X)/(Z^2);
                    B(2,p) = fy*(dY_dp*Z - dZ_dp*Y)/(Z^2);
                end
            end
            
            
            meas.A = A;
            meas.B = B;
            
            vCameras{meas.c}.U = vCameras{meas.c}.U + A'*A;
            vCameras{meas.c}.Ustar = vCameras{meas.c}.U + diag(diag(vCameras{meas.c}.U))*lambda;
            vCameras{meas.c}.ea = vCameras{meas.c}.ea + A'*meas.err;
            vPoints{meas.p}.V = vPoints{meas.p}.V + B'*B;
            vPoints{meas.p}.Vstar = vPoints{meas.p}.V + diag(diag(vPoints{meas.p}.V))*lambda;
            vPoints{meas.p}.eb = vPoints{meas.p}.eb + B'*meas.err;
            vPoints{meas.p}.hasConstraint = false;
            
            meas.W = A'*B;
            vMeasurements{measCount} = meas;
            mMeasurements{meas.p, meas.c} = meas;
            
            
            
        end
        
        
        
    end
end




alpha = 100;
for i = 1:size(vCons,2)
    value = vCons{i}.value;
    p1 = vCons{i}.p1;
    p2 = vCons{i}.p2;
    
    X1 = Map.points(p1).location;
    X2 = Map.points(p2).location;
    N = X1(1:3)-X2(1:3);
    
    
    
    
    
    
    
    residual = (norm(N) - value)*alpha;
    
    
    
    B1(1) = (alpha*N(1))/norm(N);
    B1(2) = (alpha*N(2))/norm(N);
    B1(3) = (alpha*N(3))/norm(N);
    
    B2(1) = (-alpha*N(1))/norm(N);
    B2(2) = (-alpha*N(2))/norm(N);
    B2(3) = (-alpha*N(3))/norm(N);
    
    vPoints{p1}.Bcons = B1;
    vPoints{p2}.Bcons = B2;
    vPoints{p1}.T = B1'*B2;
    vPoints{p2}.T = B2'*B1;
    vPoints{p1}.V = vPoints{p1}.V +  B1'*B1;
    vPoints{p2}.V = vPoints{p2}.V +  B2'*B2;
    
    vPoints{p1}.Vstar = vPoints{p1}.V + diag(diag(vPoints{p1}.V))*lambda;
    vPoints{p2}.Vstar = vPoints{p2}.V + diag(diag(vPoints{p2}.V))*lambda;
    
    vPoints{p1}.hasConstraint = true;
    vPoints{p2}.hasConstraint = true;
    
    vPoints{p1}.eb = vPoints{p1}.eb + B1'*residual;
    vPoints{p2}.eb = vPoints{p2}.eb + B2'*residual;
    
    
    vCons{i}.V = [vPoints{p1}.V vPoints{p1}.T; vPoints{p2}.T vPoints{p2}.V];
    vCons{i}.Vstar =  vCons{i}.V + diag(diag(vCons{i}.V))*lambda;
    
    
    
end

for i=1:size(mMeasurements,1)
    for j=1:size(mMeasurements,2)
        if ~isempty(mMeasurements{i,j})
            mMeasurements{i,j}.Y = mMeasurements{i,j}.W/vPoints{i}.Vstar;
        else
             mMeasurements{i,j}.W = zeros(6,3);
        end
    end
end










%Diagonal parts of S
S = zeros((size(KeyFrames,2)-1)*6,(size(KeyFrames,2)-1)*6);
E = zeros((size(KeyFrames,2)-1)*6,1);
for j = 2:size(KeyFrames,2)
    m6 =  vCameras{j}.Ustar;
    v6 =  vCameras{j}.ea;
    
    for i = 1:size(vCons,2)
        p1 = vCons{i}.p1;
        p2 = vCons{i}.p2;
        if ~isempty(mMeasurements{p1,j}) || ~isempty(mMeasurements{p2,j})
            if ~isempty(mMeasurements{p1,j}) && ~isempty(mMeasurements{p2,j})
                W = [mMeasurements{p1,j}.W mMeasurements{p2,j}.W];
            else
                if ~isempty(mMeasurements{p1,j})
                    W = [mMeasurements{p1,j}.W zeros(6,3)];
                else
                     W = [zeros(6,3) mMeasurements{p2,j}.W];
                end
            end
            
            
            Y = W/vCons{i}.Vstar;
            Eb = [vPoints{p1}.eb; vPoints{p2}.eb];
            m6 = m6 - Y*W';
            v6 = v6 - Y*Eb;
        end
    end
    
    for i = 1:size(Map.points,2)
        if ~isempty(mMeasurements{i,j}) && ~vPoints{i}.hasConstraint
            m6 = m6 - (mMeasurements{i,j}.Y*mMeasurements{i,j}.W');
            v6 = v6 - (mMeasurements{i,j}.Y*vPoints{i}.eb);
        end
    end
    
    matStart = (j-2)*6 + 1;
    matEnd = (j-2)*6 + 6;
    
    S(matStart:matEnd,matStart:matEnd) = m6;
    E(matStart:matEnd) = v6;
end


%Non-Diagonal Parts
for j = 2:size(KeyFrames,2)
    for k = 2:size(KeyFrames,2)
        if j~=k
            in = zeros(6,6);
            jStart = (j-2)*6 + 1;
            jEnd = (j-2)*6 + 6;
            kStart = (k-2)*6 + 1;
            kEnd = (k-2)*6 + 6;
            
            
            for i = 1:size(vCons,2)
                p1 = vCons{i}.p1;
                p2 = vCons{i}.p2;
                if ~isempty(mMeasurements{p1,j}) && ~isempty(mMeasurements{p2,j}) && ~isempty(mMeasurements{p1,k}) && ~isempty(mMeasurements{p2,k})
                    W1 = [mMeasurements{p1,j}.W mMeasurements{p2,j}.W];
                    Y = W1/vCons{i}.Vstar;
                    W2 = [mMeasurements{p1,k}.W mMeasurements{p2,k}.W];
                    in = in - Y*W2';
                end
                
            end
            
            
            for i = 1:size(Map.points,2)
                if ~isempty(mMeasurements{i,j}) && ~isempty(mMeasurements{i,k}) && ~vPoints{i}.hasConstraint
                    in = in - (mMeasurements{i,j}.Y*mMeasurements{i,k}.W');
                end
            end
            
            S(jStart:jEnd,kStart:kEnd) = in;
            
            
            
            
        end
    end
end


delta_cams = S\E;

delta_points = zeros(3*size(Map.points,2),1);


for i = 1:size(vCons,2)
    p1 = vCons{i}.p1;
    p2 = vCons{i}.p2;
    
    
    delta = [vPoints{p1}.eb; vPoints{p2}.eb];
    for j = 2:size(KeyFrames,2)
        camStart = (j-2)*6 + 1;
        camEnd = (j-2)*6 + 6;
        if ~isempty(mMeasurements{p1,j}) && ~isempty(mMeasurements{p2,j})
            W = [mMeasurements{p1,j}.W mMeasurements{p2,j}.W]; 
            delta = delta - W'*delta_cams(camStart:camEnd);
        end
    end
    
    
    point1Start = (p1-1)*3 + 1;
    point1End = (p1-1)*3 + 3;
    point2Start = (p2-1)*3 + 1;
    point2End = (p2-1)*3 + 3;
    
    delta = vCons{i}.Vstar\delta;
    delta_points(point1Start:point1End) = delta(1:3);
    delta_points(point2Start:point2End) = delta(4:6);
    
end




for i = 1:size(Map.points,2)
    if ~vPoints{i}.hasConstraint
        delta = vPoints{i}.eb;

        pointStart = (i-1)*3 + 1;
        pointEnd = (i-1)*3 + 3;
        
        for j = 2:size(KeyFrames,2)
            camStart = (j-2)*6 + 1;
            camEnd = (j-2)*6 + 6;
            if ~isempty(mMeasurements{i,j})
                delta = delta - mMeasurements{i,j}.W'*delta_cams(camStart:camEnd);
            end
        end

        delta = vPoints{i}.Vstar\delta;
        delta_points(pointStart:pointEnd) = delta;
    end
    
end

















end



