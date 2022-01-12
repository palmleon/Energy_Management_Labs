
classdef functions_script
    methods (Static)
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
            C = functions_script.abs_distance(A, B);
            d = C/(size(A(:,:,1),1)*size(A(:,:,1),2)*sqrt(100^2+(255^2)*2));
        end
        
        % Function to compute efficiency,
        % where A is the original image and B the modified one
        function e = efficiency(A, B)
            e = 1 - functions_script.computePower(B)/functions_script.computePower(A);
        end
        
        function d = distortion(A, B)
            d = functions_script.rel_distance(rgb2lab(A), rgb2lab(B));
        end
        
        % HUNGRY BLUE, reduces the value of blue from 100% to 0%
        function [dist, eff] = hungryblue(A)
            S = A;
            power_saved = zeros(11,1);
            distance = zeros(11,1);
            Apower = functions_script.computePower(A);
            g = 1;
            for c = 1.0:-0.1:0.0
                S(:,:,3) = uint8(A(:,:,3) .* c);
                power_saved(g) = 1 - (functions_script.computePower(S)/Apower);
                distance(g) = functions_script.distortion(A, S);
                g = g+1;
            end
            dist = distance;
            eff = power_saved;
        end
        
        % HISTOGRAM EQUALISATION
        function [dist, eff] = histogram_eq(A)
            S = histeq(A);
            eff = functions_script.efficiency(A, S);
            dist = functions_script.distortion(A, S);
        end
        
        
        %%%%%%%%%% Second day functions %%%%%%%%%%

        function S = computeCurrentPerColour(A)
            p1 = 4.251e-5;
            p2 = -3.029e-4;
            p3 = +3.024e-5;
            Vdd = 15;
        
            S = ((p1 * Vdd * double(A))/255) + ((p2 * double(A))/255) + p3;
        end
        
        %%%%%%%%%% File handling functions %%%%%%%%%%
        
        % Retrives names of the files located in the directory "path"
        function files = files_name(path)
            files = dir(path);
        
            % Removing "." and ".."
            files = files(3:end);
        
            files = {files(:).name};
            path = strcat(path, "/");
            files = strcat(path, files);
        end
        
        % Collects all the images paths from banchmark
        function relative_paths = all_images_banchmark()
            path = "./images/BSDS500/train";
            relative_paths = functions_script.files_name(path);
            path = "./images/BSDS500/test";
            relative_paths = cat(2, relative_paths, functions_script.files_name(path));
            path = "./images/BSDS500/val";
            relative_paths = cat(2, relative_paths, functions_script.files_name(path));
            path = "./images/USC-SIPI";
            relative_paths = cat(2, relative_paths, functions_script.files_name(path));
            path = "./images/Screenshots";
            relative_paths = cat(2, relative_paths, functions_script.files_name(path));
        end
    end
end

