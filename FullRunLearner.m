function [ new_pff_weights ] = FullRunLearner( cfg,fname )
%FULLRUNLEARNER Summary of this function goes here
%   Detailed explanation goes here

%File to load from if restarting test, otherwise leave blank
if nargin == 2
    load_from_file = fname;
else
    load_from_file = '';
end

%save after this many iteration
save_after = cfg.NM_saveAfter; %iterations

%batch size is the number of games that will be played to get a score for
%the current node, ideally this should be a multiple of however many
%workers are in the parallel pool
batch_size = cfg.NM_batchSize; 

%When to stop searching
max_iter = cfg.NM_maxIter;

%defualt behavior is what all nodes will be tested against to get a score
%future iterations could possibly be tested against the best node from
%previous trials
default_behavior_str = 'moveSimple';
default_behavior = str2func(default_behavior_str);

%test behavior is which behavior to run learning on
test_behavior_str = 'movePff';
test_behavior = str2func(test_behavior_str);

%set up behavior list
bh_list = repmat({default_behavior},cfg.num_players,1);
training_idx = cfg.start_roles_red(1:cfg.num_players_red) == (cfg.training_role-1); 
bh_list(training_idx) = {test_behavior};

%loop counter
n = 0;
n_restarts = 0;
restart = false;

%start parpool if needed and add needed files + data
p = gcp();
C = parallel.pool.Constant(cfg);
if isempty(p.AttachedFiles)
    p.addAttachedFiles({default_behavior_str,test_behavior_str});
else
    p.updateAttachedFiles();
end  

%timer
t_start = tic;
if ~exist('t_elapsed','var')
    t_elapsed = 0;
end

%% Set up initial simplex

%create a new simplex from scratch
if isempty(load_from_file)
    disp('Generating initial simplex...')
    S = generate_simplex(cfg);

    %get scores for all vertices
    for i = 1:(cfg.NM_dim+1)
        fprintf('Scoring vertex %i out of %i\n',i,cfg.NM_dim+1)
        S(i).score = score_vertex(S(i).vertex,C,bh_list,batch_size,cfg);
    end
               
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
    
    %if restart is required
    if restart
        disp('Restarting NM...')
        n_restarts = n_restarts + 1;
        cfg.pff_weights = estimate_final_parameters(S,cfg);
        cfg = ConfigureNM(cfg);
        S = generate_simplex(cfg);
        %get scores for all vertices
        for i = 1:(cfg.NM_dim+1)
            fprintf('Scoring vertex %i out of %i\n',i,cfg.NM_dim+1)
            S(i).score = score_vertex(S(i).vertex,C,bh_list,batch_size,cfg);
        end
    end
        
    %print iteration number
    fprintf('%i-%i: ',n_restarts, n)
    
    %perform simplex transformation based off of vertex scores
    S = simplex_transformation(S,cfg,C,bh_list,batch_size);    
    
    %increment loop counter
    n = n+1; 
    
    %save every so often
    if mod(n,save_after) == 0
        SaveData(S,cfg,n,bh_list,t_start)
    end
    
    %Test for termination
    if termination_test(S,cfg)
        restart = true;
    end
end

if n < max_iter
    disp('Search has completed')
else
    disp('Search has reached max iterations')
end

t = toc(t_start);
fprintf('It took %4.1f seconds to run %i iterations\n',t+t_elapsed,n-1)

%estimate final parameters based on simplex
new_pff_weights = estimate_final_parameters(S,cfg);


end

