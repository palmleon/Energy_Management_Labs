image = functions_script.all_images_banchmark;

% echo off all
% images = all_images_banchmark;
% n_images = size(images, 2);
% dist = zeros(n_images,1);
% eff = zeros(n_images,1);
% for i = 1:n_images
%     S = imread(images(i));
%     if (size(S, 3) == 1)
%         clear A;
%         A(:,:,1) = S;
%         A(:,:,2) = S;
%         A(:,:,3) = S;
%         S = A;
%     end
%     disp( (i/n_images) * 100);
%     [dist(i,1),eff(i,1)] = histogram_eq(S);
% end
% save('result_histeq', 'images', 'dist', 'eff');

nImages = 14;
nTransf = 3; % ?? to be defined ??
extensions = [".tiff", ".jpg", ".png"];
Efficiency = zeros(nTransf, nImages);
Distortion = zeros(nTransf, nImages);

for i = 1:nImages
    % load the image
    S = imread("images/image_" + num2str(1) + extensions(ceil(1/5)));
    % apply all defined transformations for each transformation,
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

% metric = eff ./ ((1+dist).^2);
% metric2 = eff ./ dist;
% plot(0.1:0.1:1.0, mean(matric1(2:11,:),2), 'bx-', 0.1:0.1:1.0, mean(matric2(2:11,:), 2), 'kx-');

% errorbar(0.0:0.1:1.0, mean(dist,2), std(dist, 0, 2), 'kx-');
% hold on;
% plot(0.0:0.1:1.0, max(dist,[], 2), 'bl-',0.0:0.1:1.0, min(dist,[], 2), 'r-')
% title('Distance');
% hold off;
% figure, errorbar(0.0:0.1:1.0, mean(eff,2), std(eff, 0, 2), 'kx-');
% hold on;
% plot(0.0:0.1:1.0, max(eff,[], 2), 'bl-',0.0:0.1:1.0, min(eff,[], 2), 'r-')
% title('Efficiency');
% hold off;
% figure, errorbar(0.1:0.1:1.0, mean(metric,2), std(metric, 0, 2), 'kx-');
% hold on;
% plot(0.1:0.1:1.0, max(metric,[], 2), 'bl-',0.1:0.1:1.0, min(metric,[], 2), 'r-')
% title('Our metric');
% boxplot(transpose(metric));
% title('Our metric');