%try running NM using matlab built in fminsearch

%% Initialization
close all
clear
rng('shuffle')
addpath game pff NM
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
default_behavior_str = 'behavior_test_pff';
default_behavior = str2func(default_behavior_str);

%test behavior is which behavior to run learning on
test_behavior_str = 'behavior_test_pff2';
test_behavior = str2func(test_behavior_str);

%override some config values for learning
Config();
cfg.drawgame = false;
cfg.halflength = 300; %run 2 5 minute halves to remove any side advantage

%set up behavior list
bh_list = repmat({default_behavior},cfg.num_players,1);
bh_list(cfg.training_role) = {test_behavior};

%start parpool if needed and add needed files + data
p = gcp();
C = parallel.pool.Constant(cfg);
if isempty(p.AttachedFiles)
    p.addAttachedFiles({default_behavior_str,test_behavior_str});
else
    p.updateAttachedFiles();
end  

%% Set up function

fun = @(w) score_vertex(w,C,bh_list,batch_size,cfg);
w0 = cfg.NM_initial;

options = optimset('Display','iter');
[w_opt,score] = fminsearch(fun,w0,options);
