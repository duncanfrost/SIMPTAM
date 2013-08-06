function [r,J, ploterr] = calculateposeres(PTAM,Ext)
nparams = 6;
ncameras = size(PTAM.KeyFrames,2);
nresid = ncameras;

J = zeros(6*nresid, 6*(ncameras-1));
r = zeros(6*nresid,1);

ploterr = zeros(size(PTAM.KeyFrames,2));


for i = 1:nresid
    
    
    
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
        display('This doesnt look good');
    end
    
    
    if ~isreal(logmap(in))
        display('This doesnt look good');
    end
    
    
    
    r(6*(i-1) + 1:6*(i-1) + 6) = logmap(in);
    ploterr(i) = norm(logmap(in));
   

    if i ~= 1
        J(6*(i-1) + 1: 6*(i-1) + 6, 6*(i-2) + 1: 6*(i-2) + 6) = J1;
    end
    if j ~= 1
        J(6*(i-1) + 1: 6*(i-1) + 6, 6*(j-2) + 1: 6*(j-2) + 6) = J2;
    end

end
end




