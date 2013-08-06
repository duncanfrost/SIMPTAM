function [] = displayimage(ImagePoints, color)

for i = 1:length(ImagePoints)
    plot(ImagePoints(i).location(1), ImagePoints(i).location(2),'x','Color',color);
end

end

