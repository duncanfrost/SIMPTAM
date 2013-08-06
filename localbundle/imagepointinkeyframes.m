function [ count ] = imagepointinkeyframes(KeyFrames,id)

count = 0;
for i = 1:size(KeyFrames,2)
    if ~isempty(imagepointinkf(KeyFrames(i),id))
        count = count + 1;
    end
end


end
