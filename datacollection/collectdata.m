
ntests = 25;
load WorldFrames;
Frames = World.KeyFrames;

%% Single Constraints





for j = 1:ntests
    counts = ones(18,1)*0;
    C = constraintmatrix(Frames, World,counts);
    save Constraints C;
    [PTAM World] = proj;
    [error count] = calculateworlderror(World.Map,PTAM.Map);
    %Calculate error
end


%% N constraints in each kf




