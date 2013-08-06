function [ counts ] = kfidhist(KeyFrames,ids)
counts = zeros(size(ids));
for i = 1:size(ids)
    counts(i) = imagepointinkeyframes(KeyFrames,ids(i));
end



end

