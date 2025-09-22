function [w, b] = SvmL0a(x, y, errorPenaltyConstant)
n = size(x,2); %amount of features
m = size(x,1); %amount of training data

objL = zeros(n + 2*m + 1,1);
objL(n+2+m:end) = errorPenaltyConstant * ones(m,1);

objQ = zeros(n + 2*m + 1);
objQ(1:n,1:n) = eye(n);
AError = eye(m);
A1 = [y.*x, y, AError, zeros(m)];
A2 = [zeros(m,n+1), eye(m), eye(m)*-9999999];
A = [A1; A2];

sense = [repmat('>', m, 1); repmat('<', m ,1)];

model.obj = objL;
model.Q = sparse(objQ);
model.A = sparse(A);
model.sense = sense;
model.vtype = [repmat('C', n + m + 1, 1); repmat('I',m,1)];
model.modelsence = 'min';
model.lb = [-Inf(n + 1,1); zeros(2*m,1)];
model.ub = [Inf(n + m + 1,1); ones(m,1)];
params.outputflag = 0;

rhs = [ones(m,1); zeros(m,1)];
model.rhs = rhs;
results = gurobi(model, params);

varResults = results.x';
w = varResults(1:n);
b = varResults(n+1);
end