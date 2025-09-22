function [xTraining, yTraining, xTest, yTest] = GetDataByMeasurements(dataSize, features, overlapPerc, scale, noisePerc, outlierFactor)
overlap = scale*nthroot(overlapPerc,features);

y = ones(dataSize,1);
y(dataSize / 2:end,1) = -y(dataSize / 2:end,1);
x = scale * rand(dataSize, features);

featuresToShift = ceil(features * rand);
randIndX = randperm(features, featuresToShift);
boolArrayX = false(1, features);
boolArrayX(randIndX) = true;
x(1:dataSize/2-1, boolArrayX) = x(1:dataSize/2-1, boolArrayX) - scale + overlap/2;
x(1:dataSize/2-1, ~boolArrayX) = x(1:dataSize/2-1, ~boolArrayX) - overlap/2;
x(dataSize/2:end, ~boolArrayX) = x(dataSize/2:end, ~boolArrayX) - scale + overlap/2;
x(dataSize/2:end, boolArrayX) = x(dataSize/2:end, boolArrayX) - overlap/2;

yAll = y;
xAll = x;
randInd = randperm(dataSize, dataSize / 2);
boolArray = false(1, dataSize);
boolArray(randInd) = true;
xTraining = xAll(boolArray, :);
yTraining = yAll(boolArray, :);
xTest = xAll(~boolArray, :);
yTest = yAll(~boolArray, :);

nrRandomPoints = ceil(dataSize*noisePerc/2);
randIndNoise = randperm(dataSize / 2, nrRandomPoints);
boolArrayNoise = false(1, dataSize / 2);
boolArrayNoise(randIndNoise) = true;
xTraining(boolArrayNoise, :) = (-scale+overlap/2)*outlierFactor + 2*((scale-overlap/2)*outlierFactor)*rand(nrRandomPoints, features);

for i = 1:features-1
    theta_rad = 2 * pi *rand;
    R2D = [cos(theta_rad), -sin(theta_rad);
         sin(theta_rad),  cos(theta_rad)];
    RND = eye(features);
    while true
        featuresToBeRotated = randi(features,[1,2]);
        if featuresToBeRotated(1) ~= featuresToBeRotated(2)
            break
        end
    end
    RND(featuresToBeRotated,featuresToBeRotated) = R2D;
    xTraining = xTraining*RND;
    xTest = xTest*RND;
end
shift = -scale + 2*scale*rand;
xTraining = xTraining + shift;
xTest = xTest -scale + shift;
end