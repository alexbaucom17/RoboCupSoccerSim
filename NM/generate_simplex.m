function [ S ] = generate_simplex( cfg )
%GENERATE_SIMPLEX Generates nelder-mead simlex based on configuration
%parameters
%   S is a N+1x1 struct array with two fields: vertex (an Nx1 array of
%   weights) and score (the function evaluated at that vertex)

%initialize simplex with starting point
S = struct('vertex',cfg.NM_initial,'score',[]);

%set up remaining vertices with step size in each unit direction
for i = 1:cfg.NM_dim
    new_vertex = cfg.NM_initial;
    new_vertex(i) = new_vertex(i) + cfg.NM_initial_step_size;
    S(i+1).vertex = new_vertex;
    S(i+1).score = [];
end

end

