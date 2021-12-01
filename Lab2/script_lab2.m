S = imread('misc/4.1.01.tiff');
S1 = S;
S1(:,:,3) = uint8(S1(:,:,3) .* 0.8);
computePower(S)
computePower(S1)
rel_distance(S, S1)


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

function d = rel_distance(A, B)
    C = abs_distance(A, B);
    d = (C*100)/(size(A(:,:,1),1)*size(A(:,:,1),2)*sqrt(100^2+(255^2)*2));
end


