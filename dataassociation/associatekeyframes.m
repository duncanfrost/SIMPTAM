function [ CurrFrame ] = associatekeyframes(PrevFrame, CurrFrame)


for i = 1:size(PrevFrame.ImagePoints,2)
    for j = 1:size(CurrFrame.ImagePoints,2)
        if PrevFrame.ImagePoints(i).gtid == CurrFrame.ImagePoints(j).gtid
            CurrFrame.ImagePoints(j).id = PrevFrame.ImagePoints(i).id;
        end
    end
end
    





end

