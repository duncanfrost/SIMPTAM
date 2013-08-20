clear all;

C = 2 ;


mu1 = rand(6,1);
mu2 = rand(6,1);
E1 = expmap(mu1);
E2 = expmap(mu2);



s = ones(2,1);

resi = zeros(2,1);
drds = zeros(2,1);


for i = 1:1000
    
    X1 = E2*[-R1'*t1; 1];
    X2 = E1*[-R2'*t2; 1];
    
    
    N1 = s(1)*X1(1);
    N2 = s(1)*X1(2);
    N3 = s(1)*X1(3);
    
    drds(1) = 2*(X1(1)*N1 + X1(2)*N2 + X1(3)*N3);
    resi(1) = N1^2 + N2^2 + N3^2 - C^2;
    
    
    
    N1 = s(2)*X2(1);
    N2 = s(2)*X2(2);
    N3 = s(2)*X2(3);
    
    drds(2) = 2*(X2(1)*N1 + X2(2)*N2 + X2(3)*N3);
    resi(2) = N1^2 + N2^2 + N3^2 - C^2;
    
    
    
    
  
    
    
    
    
    
       
    
    
    
    
    
    
    
    
    error = resi'*resi;
    
    
    s = s - drds'*resi*0.001;
    clc;
    display(error);
    display(i);
    display(s);
    display(drds'*resi);
 
    
    
%     pause(0.01);
end



X1 = -R1'*t1;
X2 = -R2'*t2;



X1n = E2*[-R1'*t1; 1];
X1n(1:3) = X1n(1:3)*s(1);
X1n = X1n;

X1nn = E2\X1n;
X1nn = X1nn(1:3);



X2n = E1*[-R2'*t2; 1];
X2n(1:3) = X2n(1:3)*s(2);
X2n = X2n;

X2nn = E1\X2n;
X2nn = X2nn(1:3);


D1 = E1*[X2; 1];
D2 = E1*[X2nn; 1];


D1 = D1(1:3);
D2 = D2(1:3);

D1 = D1/norm(D1);
D2 = D2/norm(D2);


close all;
hold on;
plot3([X1nn(1) X2nn(1)],[X1nn(2) X2nn(2)],[X1nn(3) X2nn(3)],'r-');
plot3([X1(1) X2(1)],[X1(2) X2(2)],[X1(3) X2(3)],'b-');









