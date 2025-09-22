function [w, b] = SvmBootstrap(x, y, subsetPerc, errorPenaltyConstant)
n = size(x,2); %amount of features
params.outputflag = 0;
maxIter = 5;

for iter = 1:maxIter
    class1Ind = y > 0;
    class2Ind = y < 0;
    totalClass1 = sum(class1Ind);
    totalClass2 = sum(class2Ind);
    totalSubset = ceil(min(totalClass1, totalClass2) * subsetPerc);

    class1RandInd = randperm(totalClass1, totalSubset);
    boolArrayClass1 = false(1, totalClass1);
    boolArrayClass1(class1RandInd) = true;

    class2RandInd = randperm(totalClass2, totalSubset);
    boolArrayClass2 = false(1, totalClass2);
    boolArrayClass2(class2RandInd) = true;

    xClass1 = x(class1Ind, :);
    xClass2 = x(class2Ind, :);
    xClass1 = xClass1(boolArrayClass1, :);
    xClass2 = xClass2(boolArrayClass2, :);
    yClass1 = y(class1Ind, :);
    yClass2 = y(class2Ind, :);
    yClass1 = yClass1(boolArrayClass1, :);
    yClass2 = yClass2(boolArrayClass2, :);

    xClass1Rest = x(class1Ind, :);
    xClass1Rest = xClass1Rest(~boolArrayClass1, :);
    xClass2Rest = x(class2Ind, :);
    xClass2Rest = xClass2Rest(~boolArrayClass2, :);
    xRest = [xClass1Rest; xClass2Rest];

    xRun = [xClass1; xClass2];
    yRun = [yClass1; yClass2];
    
    m = 2*totalSubset;
    objL = zeros(n + m + 1,1);
    objL(n+2:end) = errorPenaltyConstant*ones(m,1);
    
    objQ = zeros(n + m + 1);
    objQ(1:n,1:n) = eye(n);
    AError = eye(m);
    
    sense = repmat('>', m, 1);
    
    model.obj = objL;
    model.Q = sparse(objQ);
    
    model.sense = sense;
    model.vtype = repmat('C', n + m + 1, 1);
    model.modelsense = 'min';
    model.lb = [-Inf(n + 1,1); zeros(m,1)];
    model.ub = Inf(n + m + 1,1);
    rhs = ones(m,1);
    model.rhs = rhs;

    A = [yRun.*xRun, yRun, AError];
    model.A = sparse(A);

    results = gurobi(model, params);

    wRun = results.x(1:n);
    bRun = results.x(n+1);
    estimation = xRest*wRun + bRun;
    yEstimation = ones(length(estimation),1);
    yEstimation(estimation < 0) = -1;

    x = [xRun; xRest];
    y = [yRun; yEstimation];
end
w = wRun';
b = bRun;
%{
scatter(x(y > 0, 1), x(y > 0, 2), 'r'); % Positive class
hold on;
scatter(x(y < 0, 1), x(y < 0, 2), 'b'); % Negative class
hold off;
%}
end