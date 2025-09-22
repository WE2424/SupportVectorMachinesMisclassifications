function [w, b] = SvmL1L0(x, y, errorPenaltyConstant, alpha, mu)
n = size(x,2); %amount of features
m = size(x,1); %amount of training data

% w b xi p u
objL = zeros(n + 1 + 3*m, 1);
objL(n+2+2*m:n+1+3*m) = errorPenaltyConstant * -1 * ones(m,1)*(1-mu); %u
objL(n+2:n+1+m) = errorPenaltyConstant * ones(m,1) * mu;

objQ = zeros(n + 3*m + 1);
objQ(1:n,1:n) = eye(n);
AError = eye(m);
A = [y.*x, y, AError, repmat(zeros(m), 1, 2);
    zeros(m,n+1), alpha*eye(m), eye(m), zeros(m)];

sense = [repmat('>', m, 1); repmat('=', m, 1)];
rhs =   [ones(m,1)
        zeros(m,1)];

model.obj = objL;
model.Q = sparse(objQ);
model.A = sparse(A);
model.sense = sense;
model.rhs = rhs;
model.vtype = repmat('C', n + 3*m + 1, 1);
model.modelsense = 'min';
model.lb = [-Inf(n + 1,1); zeros(m,1); -Inf(2*m,1)];
model.ub = Inf(n + 3*m + 1,1);

for i = 1:m
    model.genconexp(i).xvar = n+1+m+i;
    model.genconexp(i).yvar = n+1+2*m+i;
end

params.outputflag = 0;

results = gurobi(model, params);

varResults = results.x';
w = varResults(1:n);
b = varResults(n+1);
end