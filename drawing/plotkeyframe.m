function [  ] = plotkeyframe(KeyFrame)


figure;
hold on
for i = 1:length(KeyFrame.ImagePoints)
    x = KeyFrame.ImagePoints(i).location(1);
    y = KeyFrame.ImagePoints(i).location(2);
    plot(x, y,'x','Color',[1 0 0]);
    
    text(x+5,y+5,['ID: ' int2str(KeyFrame.ImagePoints(i).id)]);
    text(x-5,y-5,['GTID: ' int2str(KeyFrame.ImagePoints(i).gtid)]);
    
    
end





end

