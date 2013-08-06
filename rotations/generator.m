function [R] = generator(p)
%GENERATOR Outputs one of the generator matrices. Notation is translation
%is first 3 elements, rotation is next 3.


switch p
    case 1
        R = [0 0 0 1; 0 0 0 0; 0 0 0 0; 0 0 0 0];
    case 2
        R = [0 0 0 0; 0 0 0 1; 0 0 0 0; 0 0 0 0];
    case 3
        R = [0 0 0 0; 0 0 0 0; 0 0 0 1; 0 0 0 0];
    case 4
        R = [0 0 0 0; 0 0 -1 0; 0 1 0 0; 0 0 0 0];
    case 5
        R = [0 0 1 0; 0 0 0 0; -1 0 0 0; 0 0 0 0];
    case 6
        R = [0 -1 0 0; 1 0 0 0; 0 0 0 0; 0 0 0 0];
end




end

