function [ X ] = linearreproject(match1, match2, P1, P2,XX)

%Separate projection matrices into rows
P1_1 = P1(1,:);
P1_2 = P1(2,:);
P1_3 = P1(3,:);
P2_1 = P2(1,:);
P2_2 = P2(2,:);
P2_3 = P2(3,:);

x1 = match1(1);
y1 = match1(2);

x2 = match2(1);
y2 = match2(2);

A = [x1*P1_3 - P1_1; 
    y1*P1_3 - P1_2;
    x2*P2_3 - P2_1;
    y2*P2_3 - P2_2;];

[U S V] = svd(A);

X = V(:,4);
X = X./X(4);
X = single(X);



end