function [w, b] = SvmElasticScad(x, y, errorPenaltyConstant, lambda, alpha, mu)
n = size(x,2); %amount of features
m = size(x,1); %amount of training data

bigM = 9999999;

c0 = 2*(alpha - 1);
c1 = 1 / c0;
c2 = 2*alpha*lambda / c0;
c3 = lambda^2 / c0;
c4 = (alpha + 1)*lambda^2 / 2;

objL = zeros(n + 1 + 5 * m, 1);
objL(n+2+2*m:n+1+3*m) = errorPenaltyConstant * -1 * ones(m,1) * (c4 + c3) * mu; %q
objL(n+2+3*m:n+1+4*m) = errorPenaltyConstant * ones(m,1) * c3* mu; %p

objQ = zeros(n + 1 + 5*m);
objQ(1:n,1:n) = eye(n); %w
objQ(n+2:n+1+m,n+2:n+1+m) = errorPenaltyConstant*eye(m) * (1-mu);
objQ(n+2:n+1+m,n+2+m:n+1+2*m) = errorPenaltyConstant * lambda * eye(m)* mu; %xi z
objQ(n+2+2*m:n+1+3*m, n+2+4*m: n+1+5*m) = errorPenaltyConstant * -1 * c1 * eye(m)* mu; %q u
objQ(n+2+2*m:n+1+3*m, n+2:n+1+m) = errorPenaltyConstant * c2 * eye(m)* mu; %q xi
objQ(n+2+3*m:n+1+4*m, n+2+4*m: n+1+5*m) = errorPenaltyConstant * c1 * eye(m)* mu; %p u
objQ(n+2+3*m:n+1+4*m, n+2:n+1+m) = errorPenaltyConstant * -1 * c2 * eye(m)* mu; %p xi

% w b xi z q p u
AError = eye(m);
A1 = [y.*x, y, AError, repmat(zeros(m), 1, 4)];
A2 = [zeros(m,n+1), -eye(m), -eye(m)*bigM, repmat(zeros(m), 1, 3); % -xi -zi
      zeros(m,n+1), eye(m), eye(m)*bigM, repmat(zeros(m), 1, 3); % xi zi
      zeros(m,n+1), -eye(m), zeros(m), -eye(m)*bigM, repmat(zeros(m), 1, 2); % -xi -qi
      zeros(m,n+1), eye(m), zeros(m), eye(m)*bigM, repmat(zeros(m), 1, 2)]; % xi qi
A = [A1; A2];

sense = [repmat('>', 5*m, 1)];
rhs =   [ones(m,1);
        repmat(-bigM - lambda,m,1);
        repmat(lambda,m,1);
        repmat(-bigM -alpha*lambda, m, 1);
        repmat(alpha*lambda, m, 1)];

model.obj = objL;
model.Q = sparse(objQ);
model.A = sparse(A);
model.sense = sense;
model.vtype = [repmat('C', n + m + 1, 1); repmat('I', 2*m, 1); repmat('C', 2*m, 1)];
model.modelsense = 'min';
model.lb = [-Inf(n + 1,1); zeros(5*m,1)];
model.ub = [Inf(n + m + 1,1); ones(2*m,1); Inf(2*m,1)];
model.rhs = rhs;

for i = 1:m
    Qc = zeros(n + 1 + 5*m);
    q = zeros(n + 1 + 5*m, 1);
    Qc(n+1+2*m+i,n+1+m+i) = 1;
    q(n + 1 + 3*m+i) = -1;
    model.quadcon(i).Qc = sparse(Qc); % q*z
    model.quadcon(i).q = q; % p
    model.quadcon(i).rhs = 0;
    model.quadcon(i).sense = '=';  
end
for i = 1:m
    Qc = zeros(n + 1 + 5*m);
    q = zeros(n + 1 + 5*m, 1);
    Qc(n+1+i,n+1+i) = 1;
    q(n + 1 + 4*m+i) = -1;
    model.quadcon(i+m).Qc = sparse(Qc); % xi*xi
    model.quadcon(i+m).q = q; % u
    model.quadcon(i+m).rhs = 0;
    model.quadcon(i+m).sense = '=';  
end


params.outputflag = 0;

results = gurobi(model, params);

varResults = results.x';
w = varResults(1:n);
b = varResults(n+1);
end