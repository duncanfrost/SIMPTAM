
ntests = 1;
load WorldFrames;
Frames = World.KeyFrames;

%% Single Constraints


s = RandStream('mt19937ar','Seed',10);
RandStream.setGlobalStream(s);

for i = 1:18
    for j = 1:ntests
        counts = ones(18,1)*0;
        counts(i) = 1;
        currC = constraintmatrix(Frames, World,counts);
        Const{i,j} = currC;
    end
end

Errors = zeros(18,ntests);

for j = 1:ntests
    
    for i = 11:18
        
        C = Const{i,j};
        save Constraints C;
        [PTAM World] = proj;
        close all;
        [error count] = calculateworlderror(World.Map,PTAM.Map);
        Errors(i,j) = error;
        save Errors1 Errors
        
    end
end

clc;
display('Done!');