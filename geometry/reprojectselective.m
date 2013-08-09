function [KeyFrame1, KeyFrame2, PTAM, World ] = reprojectselective(KeyFrame1, KeyFrame2,m1,m2, PTAM, World)

E1 = KeyFrame1.Camera.E(1:3,:);
E2 = KeyFrame2.Camera.E(1:3,:);
K = KeyFrame1.Camera.K;




for i = 1:size(m1,2)
    index1 = m1(i);
    index2 = m2(i);
    point1 = KeyFrame1.ImagePoints(index1).location;
    point2 = KeyFrame2.ImagePoints(index2).location;
    gtid = KeyFrame1.ImagePoints(index1).gtid;
    gtid2 = KeyFrame2.ImagePoints(index2).gtid;
    
    
    point1 = K\point1;
    point1 = point1/point1(3);
    
    point2 = K\point2;
    point2 = point2/point2(3);
    
    newpoint = linearreproject(point1,point2,E1,E2);
    
    PTAM.mapcount = PTAM.mapcount + 1;
    PTAM.Map.points(PTAM.mapcount).location = newpoint;
    PTAM.Map.points(PTAM.mapcount).id = PTAM.mapcount;
    PTAM.Map.points(PTAM.mapcount).gtid = KeyFrame1.ImagePoints(index1).gtid;
    
    KeyFrame1.ImagePoints(index1).id = PTAM.mapcount;
    
    KeyFrame2.ImagePoints(index2).id = PTAM.mapcount;
    
%     display([gtid gtid2; index1 index2]);
       
    World.Map.points(gtid).estids = [World.Map.points(gtid).estids PTAM.mapcount];
    
end
