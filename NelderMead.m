%Script to run the Nelder-Mead simplex algorithm for reinforcement learning

%% Initialization
close all
clear
rng('shuffle')
addpath game pff NM NM/StructSort
disp('Initializing...')

%File to load from if restarting test, otherwise leave blank
load_from_file = ''; %'data/NM_Runs/NM_2016-10-10-14-40-08.mat';

%save after this many iteration
save_after = 25; %iterations

%batch size is the number of games that will be played to get a score for
%the current node, ideally this should be a multiple of however many
%workers are in the parallel pool
batch_size = 4; 

%When to stop searching
max_iter = 100;

%defualt behavior is what all nodes will be tested against to get a score
%future iterations could possibly be tested against the best node from
%previous trials
default_behavior_str = 'moveSimple';
default_behavior = str2func(default_behavior_str);

%test behavior is which behavior to run learning on
test_behavior_str = 'movePff';
test_behavior = str2func(test_behavior_str);

%override some config values for learning
cfg = Config();
cfg.drawgame = false;
cfg.halflength = 300; %run 2 5 minute halves to remove any side advantage

%set up behavior list
bh_list = repmat({default_behavior},cfg.num_players,1);
bh_list(cfg.training_role) = {test_behavior};

%loop counter
n = 0;

%start parpool if needed and add needed files + data
p = gcp();
C = parallel.pool.Constant(cfg);
if isempty(p.AttachedFiles)
    p.addAttachedFiles({default_behavior_str,test_behavior_str});
else
    p.updateAttachedFiles();
end  

%% Set up initial simplex

%create a new simplex from scratch
if isempty(load_from_file)
    disp('Generating initial simplex...')
    S = generate_simplex(cfg);

    %get scores for all vertices
    tic
    for i = 1:(cfg.NM_dim+1)
        fprintf('Scoring vertex %i out of %i\n',i,cfg.NM_dim+1)
        S(i).score = score_vertex(S(i).vertex,C,bh_list,batch_size,cfg);
    end
    t = toc;
    fprintf('It took %4.1f seconds to run %i vertices\n',t,cfg.NM_dim+1)
    fprintf('Therefore the worst case run time for the main loop is %4.1f minutes\n',...
                (t/(cfg.NM_dim+1))*max_iter*cfg.NM_dim/60)
            
else
    
    disp('Loading data from file')
    
    %load data from file to continue where we left off
    load(load_from_file)
    
    %overwrite C
    C = parallel.pool.Constant(cfg);
end


%% Run learning loop

disp('Entering main loop')
while n <= max_iter
    
    %print iteration number
    fprintf('%i: ',n)
    
    %perform simplex transformation based off of vertex scores
    S = simplex_transformation(S,cfg,C,bh_list,batch_size);    
    
    %increment loop counter
    n = n+1; 
    
    %save every so often
    if mod(n,save_after) == 0
        SaveData(S,cfg,n,bh_list)
    end
    
    %Test for termination
    if termination_test(S,cfg)
        break
    end
end

if n < max_iter
    disp('Search has completed')
else
    disp('Search has reached max iterations')
end

t = toc;
fprintf('It took %4.1f seconds to run %i iterations\n',t,n-1)

%estimate final parameters based on simplex
new_pff_weights = estimate_final_parameters(S,cfg);
