function [ outkfpoints ] = removeintrinsics(kfpoints,K)
%REMOVEINTRINSICS Removes the intrinsic camera parameters from a set of
%image points
outkfpoints = zeros(size(kfpoints));



for i = 1:size(kfpoints,2)
    kfp = kfpoints(:,i);
    kfpn = K\kfp;
    kfpn = kfpn/kfpn(3);
    outkfpoints(:,i) = kfpn;
    
    
end



end

