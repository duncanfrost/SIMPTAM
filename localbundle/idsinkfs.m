function [ ids] = idsinkfs(KeyFrames,Map)
ids = [];


for i = 1:300
    if imagepointinkeyframes(KeyFrames,i) > 0 && mapcontainsid(Map, i)
        ids = [ids; i];
    end
end

end

