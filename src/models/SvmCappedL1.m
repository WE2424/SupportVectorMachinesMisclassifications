function [w, b] = SvmCappedL1(x, y, errorPenaltyConstant, d)
n = size(x,2); %amount of features
m = size(x,1); %amount of training data

bigM = 9999999;

objL = zeros(n + 2*m + 1,1);
objL(n+2+m:end) = -errorPenaltyConstant * ones(m,1) * d;

objQ = zeros(n + 2*m + 1);
objQ(1:n,1:n) = eye(n);
objQ(n+2:n+1+m,n+2+m:n+1+2*m) = errorPenaltyConstant * eye(m);
AError = eye(m);
A1 = [y.*x, y, AError, zeros(m)];
A2 = [zeros(m,n+1), eye(m), -eye(m)*bigM;
      zeros(m,n+1), -eye(m), eye(m)*bigM];
A = [A1; A2];

sense = [repmat('>', 3*m, 1)];

model.obj = objL;
model.Q = sparse(objQ);
model.A = sparse(A);
model.sense = sense;
model.vtype = [repmat('C', n + m + 1, 1); repmat('I', m, 1)];
model.modelsense = 'min';
model.lb = [-Inf(n + 1,1); zeros(2*m,1)];
model.ub = [Inf(n + m + 1,1); ones(m,1)];
params.outputflag = 0;

rhs = [ones(m,1); repmat(-bigM + d,m,1); repmat(-d,m,1)];
model.rhs = rhs;
results = gurobi(model, params);

varResults = results.x';
w = varResults(1:n);
b = varResults(n+1);
end