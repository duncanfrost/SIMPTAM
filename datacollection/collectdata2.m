
ntests = 25;
load WorldFrames;
Frames = World.KeyFrames;

%% Single Constraints


s = RandStream('mt19937ar','Seed',10);
RandStream.setGlobalStream(s);

for i = 2:3
    for j = 1:ntests
        counts = ones(18,1)*i;
        currC = constraintmatrix(Frames, World,counts);
        Const{i,j} = currC;
    end
end

Errors = zeros(18,ntests);

for i = 2:3
    
    for j = 1:ntests
        C = Const{i,j};
        save Constraints C;
        [PTAM World] = proj;
        close all;
        [error count] = calculateworlderror(World.Map,PTAM.Map);
        Errors(i,j) = error;
        save ErrorsAllKF2 Errors

    end
end

clc;
display('Done!');