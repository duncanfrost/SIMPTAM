function [ error points errors] = calculateworlderror(GTMap, EstMap)


error = 0;
points = 0;

errors = zeros(size(GTMap.points,2),1);






for i = 1:size(EstMap.points,2)   
    gtid = EstMap.points(i).gtid;
    errors(i) = norm(GTMap.points(gtid).location-EstMap.points(i).location);
    points = points + 1;
%     display(errors(i));
%     display(GTMap.points(gtid).location);
%     display(EstMap.points(i).location);
end


error = sum(errors);



end

