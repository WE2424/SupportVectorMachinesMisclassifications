function [w, b] = SvmL2(x, y, errorPenaltyConstant)
n = size(x,2); %amount of features
m = size(x,1); %amount of training data

objL = zeros(n + m + 1,1);

objQ = zeros(n + m + 1);
objQ(1:n,1:n) = eye(n);
objQ(n+2:end,n+2:end) = errorPenaltyConstant*eye(m);
AError = eye(m);
A = [y.*x, y, AError];

sense = repmat('>', m, 1);

model.obj = objL;
model.Q = sparse(objQ);
model.A = sparse(A);
model.sense = sense;
model.vtype = repmat('C', n + m + 1, 1);
model.modelsence = 'min';
model.lb = [-Inf(n + 1,1); zeros(m,1)];
model.ub = Inf(n + m + 1,1);
params.outputflag = 0;

rhs = ones(m,1);
model.rhs = rhs;
results = gurobi(model, params);

varResults = results.x';
w = varResults(1:n);
b = varResults(n+1);
end