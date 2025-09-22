function [xTraining, yTraining, xTest, yTest] = GetDataByDistributions(dataSize, pdset, noisePdSet, noisePerc1, noisePerc2)
n = length(pdset)/2;

y = ones(dataSize,1);
y(dataSize / 2:end,1) = -y(dataSize / 2:end,1);
x = zeros(dataSize,n);

for i = 1:n
    x(1:dataSize/2,i) = random(pdset(i),[dataSize/2,1]);
    x(dataSize/2+1:end,i) = random(pdset(n+i), [dataSize/2,1]);
end

yAll = y;
xAll = x;
randInd = randperm(dataSize, dataSize / 2);
boolArray = false(1, dataSize);
boolArray(randInd) = true;
xTraining = xAll(boolArray, :);
yTraining = yAll(boolArray, :);
xTest = xAll(~boolArray, :);
yTest = yAll(~boolArray, :);

xTraining1 = xTraining(yTraining > 0,:);
class1Size = size(xTraining1,1);
nrRandomPoints1 = ceil(class1Size*noisePerc1);
randIndNoise1 = randperm(class1Size, nrRandomPoints1);
boolArrayNoise1 = false(1, class1Size);
boolArrayNoise1(randIndNoise1) = true;

xTraining2 = xTraining(yTraining < 0,:);
class2Size = size(xTraining2,1);
nrRandomPoints2 = ceil(class2Size*noisePerc2);
randIndNoise2 = randperm(class2Size, nrRandomPoints2);
boolArrayNoise2 = false(1, class2Size);
boolArrayNoise2(randIndNoise2) = true;

for i = 1:n
    xTraining1(boolArrayNoise1, i) = random(noisePdSet(i), [sum(boolArrayNoise1),1]);
    xTraining2(boolArrayNoise2, i) = random(noisePdSet(n+i), [sum(boolArrayNoise2),1]);
end

xTraining = [xTraining1; xTraining2];
yTraining = [ones(class1Size,1); -ones(class2Size,1)];
end