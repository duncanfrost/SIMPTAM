function [ ids] = idsinkfs(KeyFrames,Map)
ids = [];


for i = 1:500
    if imagepointinkeyframes(KeyFrames,i) > 0 && mapcontainsid(Map, i)
        ids = [ids; i];
    end
end

end

