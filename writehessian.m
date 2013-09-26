load HH;

A = H(1:12, 1:12);
B = H(1:12,13:33);
D1 = H(13:15,13:15);
D2 = H(16:18,16:18);
D3 = H(19:21,19:21);
D4 = H(22:24,22:24);
D5 = H(25:27,25:27);
D6 = H(28:30,28:30);
D7 = H(31:33,31:33);
D = blkdiag(D1,D2,D3,D4,D5,D6,D7);










Dinv = inv(D); %This is easy to calculate;
C = B';


c = [1:33]';
a = c(1:12);
b = c(13:33);

left1 = (A-B*Dinv*C);
right1 = a - B*Dinv*b;
x = left1\right1;

right2 = b-C*x;
y = Dinv*right2;




while(1)
end





%Write A
fCams = fopen('A.txt','w');
for i = 1:size(A,1)
    for j = 1:size(A,2)
        fprintf(fCams,'%d ',double(A(i,j)));
    end
end
fclose(fCams);

fCams = fopen('B.txt','w');
for i = 1:size(B,1)
    for j = 1:size(B,2)
        fprintf(fCams,'%d ',double(B(i,j)));
    end
end
fclose(fCams);

fCams = fopen('D1.txt','w');
for i = 1:size(D1,1)
    for j = 1:size(D1,2)
        fprintf(fCams,'%d ',double(D1(i,j)));
    end
end
fclose(fCams);

fCams = fopen('D2.txt','w');
for i = 1:size(D2,1)
    for j = 1:size(D2,2)
        fprintf(fCams,'%d ',double(D2(i,j)));
    end
end
fclose(fCams);

fCams = fopen('D3.txt','w');
for i = 1:size(D3,1)
    for j = 1:size(D3,2)
        fprintf(fCams,'%d ',double(D3(i,j)));
    end
end
fclose(fCams);

fCams = fopen('D4.txt','w');
for i = 1:size(D4,1)
    for j = 1:size(D4,2)
        fprintf(fCams,'%d ',double(D4(i,j)));
    end
end
fclose(fCams);

fCams = fopen('D5.txt','w');
for i = 1:size(D5,1)
    for j = 1:size(D5,2)
        fprintf(fCams,'%d ',double(D5(i,j)));
    end
end
fclose(fCams);

fCams = fopen('D6.txt','w');
for i = 1:size(D6,1)
    for j = 1:size(D6,2)
        fprintf(fCams,'%d ',double(D6(i,j)));
    end
end
fclose(fCams);

fCams = fopen('D7.txt','w');
for i = 1:size(D7,1)
    for j = 1:size(D7,2)
        fprintf(fCams,'%d ',double(D7(i,j)));
    end
end
fclose(fCams);



