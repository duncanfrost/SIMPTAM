function [ out ] = mapcontainsid(Map, id)


for i = 1:size(Map.points,2)
    if Map.points(i).id == id
        out = true;
        return;
    end
    
end

out = false;

end

