function [  ] = plotkeyframe(KeyFrame)


figure;
hold on
for i = 1:length(KeyFrame.ImagePoints)
    x = KeyFrame.ImagePoints(i).location(1);
    y = KeyFrame.ImagePoints(i).location(2);
    
    gtx = KeyFrame.ImagePoints(i).gtlocation(1);
    gty = KeyFrame.ImagePoints(i).gtlocation(2);
    
    
    plot(x, y,'x','Color',[1 0 0]);
    plot(gtx, gty,'x','Color',[0 0 1]);
    
    text(x+5,y+5,['ID: ' int2str(KeyFrame.ImagePoints(i).id)]);
    text(x-5,y-5,['GTID: ' int2str(KeyFrame.ImagePoints(i).gtid)]);
    
    
end





end

