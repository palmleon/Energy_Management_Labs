nImages = 14;
nTransf = 3; % ?? to be defined ??
extensions = [".tiff", ".jpg", ".png"];
Efficiency = zeros(nTransf, nImages);
Distortion = zeros(nTransf, nImages);

for i = 1:nImages
    % load the image
    S = imread("images/image_" + num2str(1) + extensions(ceil(1/5)));
    % apply all defined transformations
    % for each transformation, 
    %   save the resulting efficiency and distorsion in the E and D matrix
    % Distorsion is defined as the Euclidean Distance in the LAB space
    % Efficiency is defined as 1 - POWER_MOD/POWER_ORIG
    %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Hungry blue with k = 0.8
    S1 = S;
    S1(:,:,3) = uint8(S(:,:,3) .* 0.8);
    Efficiency(1,i) = efficiency(S, S1);
    Distortion(1,i) = distortion(S, S1);
    % Hungry blue with k = 0.6
    S1 = S;
    S1(:,:,3) = uint8(S(:,:,3) .* 0.6);
    Efficiency(2,i) = efficiency(S, S1);
    Distortion(2,i) = distortion(S, S1);
    % Hungry blue with k = 0.4
    S1 = S;
    S1(:,:,3) = uint8(S(:,:,3) .* 0.4);
    Efficiency(3,i) = efficiency(S, S1);
    Distortion(3,i) = distortion(S, S1);
    % Histogram equalization

    % Reduce V with k = 0.8

    % Reduce V with k = 0.6

    % Reduce V with k = 0.4

    % Reduce L with k = 0.8

    % Reduce L with k = 0.6

    % Reduce L with k = 0.4

    % Reduce B and V with k = 0.9

    % Reduce B and V with k = 0.8

    % Reduce B and V with k = 0.7

    % Reduce L and V with k = 0.9

    % Reduce L and V with k = 0.8

    % Reduce L and V with k = 0.7

    % Reduce B and L with k = 0.9
    
    % Reduce B and L with k = 0.8

    % Reduce B and L with k = 0.7

    % Reduce B, l and V with k = 0.93

    % Reduce B, l and V with k = 0.86

    % Reduce B, l and V with k = 0.79

end

% statistical analysis on the efficiency and distorsion of images
% ...

function S = computePower(A)
    gamma = 0.7755;
    Wr = 2.13636845*10^-7;
    Red = (double(A(:,:,1)) .^ gamma) .* Wr;
    Wg = 1.77746705*10^-7;
    Green = (double(A(:,:,2)) .^ gamma) .* Wg;
    Wb = 2.14348309*10^-7;
    Blue = (double(A(:,:,3)) .^ gamma) .* Wb;
    W0 = 1.48169521*10^-6;
    S = W0 + sum(sum(Red+Green+Blue));
end

function d = abs_distance(A, B)
    Diff = (A - B) .^ 2;
    Diff = Diff(:,:,1) + Diff(:,:,2) + Diff(:,:,3);
    d = sum(sum(sqrt(double(Diff))));
end

function d = rel_distance(A, B) % not percentage value
    C = abs_distance(A, B);
    d = C/(size(A(:,:,1),1)*size(A(:,:,1),2)*sqrt(100^2+(255^2)*2));
end

% Function to compute efficiency,
% where A is the original image and B the modified one
function e = efficiency(A, B)
    e = 1 - computePower(B)/computePower(A);
end

function d = distortion(A, B)
    d = rel_distance(rgb2lab(A), rgb2lab(B));
end


