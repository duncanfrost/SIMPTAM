function [] = displayimagematches(ImagePoints1, ImagePoints2)

for i = 1:length(ImagePoints1)
    for j = 1:length(ImagePoints2)
        if ImagePoints1(i).id == ImagePoints2(j).id
            l1 = ImagePoints1(i).location;
            l2 = ImagePoints2(j).location;
            plot(l1(1), l1(2),'x','Color',[1 0 0]);
            plot(l2(1), l2(2),'x','Color',[0 0 1]);
            plot([l1(1) l2(1)], [l1(2) l2(2)],'g-');
        end
    end 
end

        
end
    
