clc;

load sparse

tic
error = r'*r;
left = J'*J + lambda*diag(diag(J'*J));
right = J'*r;
pn = left\right;
param = -1*pn;
toc








tic
npoints = 59;
ncameras = 3;
A = J(:,1:npoints*3);
B = J(:,npoints*3+1:npoints*3+ncameras*6);
ea = A'*r;
eb = B'*r;

J2 = [A B];

U = A'*A;
V = B'*B;
W = A'*B;

U_star = U + lambda*(diag(diag(U)));
V_star = V + lambda*(diag(diag(V)));




Y = W/V_star;

S2 = U_star - (Y)*W';


delta_a = S2\(ea-Y*eb);
delta_b = V_star\(eb - W'*delta_a);
toc





