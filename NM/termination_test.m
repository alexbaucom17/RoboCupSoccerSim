function [term] = termination_test( S,cfg )
%TERMINATION_TEST Test for termination conditions for Nelder Mead algorithm
%   Checks to see if the domain has converged sufficiently 
%   Also checks to see if the function values have converged sufficiently
%   Returns true if both conditions are met (according to MATLAB
%   implimentation of fminsearch)

%set defualt conditions
term_x = false;
term_f = false;

%sort vertices by score
S_sorted = sortStruct(S,'score');

%compute score range and check if it is small enough
score_range = S_sorted(end).score - S_sorted(1).score;
if abs(score_range) < cfg.NM_fn_thresh
    term_f = true;
    %fprintf('Function scores have converged with a range of %4.1f\n',score_range)
end

%compute domain range and check to see if it is small enough
%use infinity norm of difference between all points and best point
%as speicifed by MATLAB implimentation of fminsearch
norms = zeros(cfg.NM_dim+1,1);
for i = 2:(cfg.NM_dim+1)
    norms(i) = max(abs(S(i).vertex - S(1).vertex));
end
if max(norms) < cfg.NM_domain_thresh
    term_x = true;
    fprintf('Search domain has converged with a norm range of %4.3f\n',max(norms))
end

term = term_x && term_f;

if ~term
    fprintf('    Function range: %4.1f. Domain range: %4.3f. Best score: %4.1f\n',score_range,max(norms),S(1).score)
    
end

