function [ error count ] = calculateerror(PTAM, World)
[error count] = calculateworlderror(World.Map,PTAM.Map);

end

