function [] = displaytopdown(World, PTAM, viewhandle, displayfull, displaykeyframes)

cla(viewhandle);
axes(viewhandle);
hold on;
plot(0, 0,'bx');



for modelCount = 1:2
    
    
    if modelCount == 1
        Model = World;
        pointColor = [1 0 0];
    else
        Model = PTAM;
        pointColor = [0 0 1];
    end
    
    Camera = Model.Camera;
    points = Model.Map.points;
    KeyFrames = Model.KeyFrames;

    if displayfull
        Yaxis = (Camera.E)\[0 1 0 1]';
        Zaxis = (Camera.E)\[0 0 1 1]';
        Xaxis = (Camera.E)\[1 0 0 1]';
        plot(Zaxis(1),Zaxis(3),'bx');
        plot(Yaxis(1),Yaxis(3),'gx');
        plot(Xaxis(1),Xaxis(3),'rx');
    else
        Origin =  (Camera.E)\[0 0 0 1]';
        plot(Origin(1),Origin(3),'bo');
    end

    
    pointsx = zeros(size(points,2));
    pointsy = zeros(size(points,2));
    for i = 1:size(points,2)
        pointsx(i) = points(i).location(1);
        pointsy(i) = points(i).location(3);
    end
    plot(pointsx,pointsy,'+','Color',pointColor);
    
    if displaykeyframes
        for i = 1:size(KeyFrames,2)
            Origin =  (KeyFrames(i).Camera.E)\[0 0 0 1]';
            plot(Origin(1),Origin(3),'o','Color',pointColor*0.8);
        end
    end
end





hold off;
end

