function [ term_x, term_f ] = termination_test( S,cfg )
%TERMINATION_TEST Test for termination conditions for Nelder Mead algorithm
%   Checks to see if the domain has converged sufficiently and returns true
%   for term_x if so
%   Also checks to see if the function values have converged sufficiently
%   and returns true for term_f if so

%set defualt conditions
term_x = false;
term_f = false;

%sort vertices by score
S_sorted = StructSort(S,'score');

%compute score range and check if it is small enough
score_range = S_sorted(end).score - S_sorted(1).score;
if abs(score_range) < cfg.NM_fn_thresh
    term_f = true;
end

%compute domain range and check to see if it is small enough
%we will start with simple norm for now and see how that does
norms = zeros(cfg.NM_dim+1,1);
for i = 1:(cfg.NM_dim+1)
    norms(i) = norm(S(i).vertex);
end
norm_range = range(norms);
if abs(norm_range) < cfg.NM_domain_thresh
    term_x = true;
end

end

