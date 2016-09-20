%Script to run the Nelder-Mead simplex algorithm for reinforcement learning

%% Initialization
close all
clear
rng('shuffle')
addpath game pff NM StructSort
disp('Initializing...')

%batch size is the number of games that will be played to get a score for
%the current node, ideally this should be a multiple of however many
%workers are in the parallel pool
batch_size = 8; 

%When to stop searching
max_iter = 100;

%defualt behavior is what all nodes will be tested against to get a score
%future iterations could possibly be tested against the best node from
%previous trials
default_behavior_str = 'behavior_simple';
defualt_behavior = str2func(default_behavior_str);

%test behavior is which behavior to run learning on
test_behavior_str = 'behavior_test_pff2';
test_behavior = str2func(test_behavior_str);

%override some config values for learning
Config();
cfg.drawgame = false;
cfg.halflength = 300; %run 2 5 minute halves to remove any side advantage

%loop counter
n = 0;

%termination tests
term_x = false; %terminate based on domain
term_f = false; %terminate based on function value

%start parpool if needed and add needed files + data
p = gcp();
C = parallel.pool.Constant(cfg);
if isempty(p.AttachedFiles)
    p.addAttachedFiles({default_behavior_str,test_behavior_str});
else
    p.updateAttachedFiles();
end  

%% Set up initial simplex

disp('Generating initial simplex.')
S = generate_simplex(cfg);

%get scores for all vertices
for i = 1:(cfg.NM_dim+1)
    S(i).score = score_vertex(S(i).vertex,C,default_behavior,test_behavior,batch_size,cfg);
end

%% Run learning loop

disp('Entering main loop')
while n < max_iter && term_x == false && term_f == false
    
    %perform simplex transformation based off of vertex scores
    S = simplex_transformation(S,cfg,C,default_behavior,test_behavior,batch_size);    
    
    %Test for termination
    [term_x, term_f] = termination_test(S);
    
    %increment loop counter
    n = n+1; 
end

%estimate final parameters based on simplex
w = estimate_final_parameters(S);
