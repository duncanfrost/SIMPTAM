function [m1 m2] = findunassmatches(KeyFrame1, KeyFrame2)

m1 = [];
m2 = [];

for i = 1:length(KeyFrame1.ImagePoints)
    if isempty(KeyFrame1.ImagePoints(i).id)
        for j = 1:length(KeyFrame2.ImagePoints)
            if (KeyFrame1.ImagePoints(i).gtid == KeyFrame2.ImagePoints(j).gtid)
                m1 = [m1 i];
                m2 = [m2 j];
            end
        end
    end
end

end

