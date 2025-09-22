addpath('data')
addpath('evaluation')
addpath('models')
addpath('helper')

cfg = ReadYaml('.config/config.yaml');

addpath(cfg.gurobiPath)

pdset = [           repmat(makedist("Normal", cfg.m1, cfg.s1), cfg.features, 1); repmat(makedist("Normal", cfg.m2, cfg.s2), cfg.features, 1)];
noisePdSet =    [           repmat(makedist("Normal", cfg.m3, cfg.s3), cfg.features, 1); repmat(makedist("Normal", cfg.m4, cfg.s4), cfg.features, 1)];

score = zeros(cfg.iMax, 11);
time = zeros(cfg.iMax, 11);

for i = 1:cfg.iMax
    if cfg.getDataByMeasurements
        [xTraining, yTraining, xTest, yTest] = GetDataByMeasurements(cfg.dataSize, cfg.features, cfg.overlapPerc, cfg.scale, cfg.noisePerc, cfg.outlierFactor);
    else
        [xTraining, yTraining, xTest, yTest] = GetDataByDistributions(cfg.dataSize, pdset, noisePdSet, cfg.noisePerc1, cfg.noisePerc2);
    end
    tic
    [w, b] = SvmL0a(xTraining, yTraining, cfg.errorPenaltyConstant);
    time(i,1) = toc;
    score(i,1) = GetScore(xTest, yTest, w, b);
    tic
    [w, b] = SvmL1(xTraining, yTraining, cfg.errorPenaltyConstant);
    time(i,2) = toc;
    score(i,2) = GetScore(xTest, yTest, w, b);
    tic
    [w, b] = SvmL2(xTraining, yTraining, cfg.errorPenaltyConstant);
    time(i,3) = toc;
    score(i,3) = GetScore(xTest, yTest, w, b);
    tic
    [w, b] = SvmBootstrap(xTraining, yTraining, 0.5, cfg.errorPenaltyConstant);
    time(i,4) = toc;
    score(i,4) = GetScore(xTest, yTest, w, b);
    tic
    [w, b] = SvmCappedL1y(xTraining, yTraining, cfg.errorPenaltyConstant, 100);
    time(i,5) = toc;
    score(i,5) = GetScore(xTest, yTest, w, b);
    tic
    [w, b] = SvmL0b(xTraining, yTraining, cfg.errorPenaltyConstant, 10);
    time(i,6) = toc;
    score(i,6) = GetScore(xTest, yTest, w, b);
    tic
    [w, b] = SvmL2L1(xTraining, yTraining, cfg.errorPenaltyConstant, 0.5);
    time(i,7) = toc;
    score(i,7) = GetScore(xTest, yTest, w, b);
    tic
    [w, b] = SvmL2L0(xTraining, yTraining, cfg.errorPenaltyConstant, 10, 0.5);
    time(i,8) = toc;
    score(i,8) = GetScore(xTest, yTest, w, b);
    tic
    [w, b] = SvmL1L0(xTraining, yTraining, cfg.errorPenaltyConstant, 10, 0.5);
    time(i,9) = toc;
    score(i,9) = GetScore(xTest, yTest, w, b);
    tic
    [w, b] = SvmScad(xTraining, yTraining, cfg.errorPenaltyConstant, 10, 3);
    time(i,10) = toc;
    score(i,10) = GetScore(xTest, yTest, w, b);
    tic
    [w, b] = SvmElasticScad(xTraining, yTraining, cfg.errorPenaltyConstant, 10, 3, 0.5);
    time(i,11) = toc;
    score(i,11) = GetScore(xTest, yTest, w, b);
end

result = sum(score,1)/iMax
varResult = var(score,0,1)
resultTime = sum(time,1)/iMax