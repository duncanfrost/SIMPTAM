function [ index ] = findmappointid(Map,id)

index = 0;
for i = 1:size(Map.points,2)
    
    if Map.points(i).id == id
        index = i;
    end
end




end

