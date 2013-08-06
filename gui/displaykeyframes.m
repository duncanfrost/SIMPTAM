function [] = displaykeyframes(World, PTAM)

hold on;

for modelCount = 1:2
    
    if modelCount == 1
        Model = World;
        pointColor = [1 0 0];
    else
        Model = PTAM;
        pointColor = [0 0 1];
    end
    
    KeyFrames = Model.KeyFrames;
    
    for i = 1:size(KeyFrames,2)
            Origin =  (KeyFrames(i).Camera.E)\[0 0 0 1]';
            plot(Origin(1),Origin(3),'o','Color',pointColor*0.8);
    end
      
end

hold off;

