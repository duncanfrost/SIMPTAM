function [ ] = checkforemptyids( PTAM )
count = 0;

for i = size(PTAM.KeyFrames,2)
    for j = 1:size(PTAM.KeyFrames(i).ImagePoints,2)
        id = PTAM.KeyFrames(i).ImagePoints(j).id;
        
        if isempty(id)
            count = count + 1;
        end
    end
    
end

display('Empty ids');
display(count);
    
    
end

