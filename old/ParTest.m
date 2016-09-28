
%% Initialization
close all
clear
rng('shuffle')
addpath game

%more stats
red_goals = 0;
blue_goals = 0;
red_wins = 0;
blue_wins = 0;

%set up configuration variables
Config();
num_games = 100;

%setup team behaviors
bh1 = {@behavior_simple};
bh2 = {@behavior_test_pff};
behaviors_red = repmat(bh1,num_games,1);
behaviors_blue = repmat(bh2,num_games,1);

%override some config values for parallel testing
cfg.drawgame = false;
cfg.halflength = 300; %run 2 5 minute halves

%start parpool if needed and add needed files + data
p = gcp();
C = parallel.pool.Constant(cfg);
if isempty(p.AttachedFiles)
    p.addAttachedFiles({'behavior_simple.m','behavior_test_pff.m'});
else
    p.updateAttachedFiles();
end    

%% Run simulations

%run sim
disp('Running simulations...')
tic
parfor i = 1:num_games
    
    stats1 = ParGameController(C,behaviors_red{i},behaviors_blue{i});
    stats2 = ParGameController(C,behaviors_blue{i},behaviors_red{i});
    stats{i}.game1 = stats1;
    stats{i}.game2 = stats2;
    
end
toc

%% Post processing

for i = 1:num_games
    red_goals = red_goals + stats{i}.game1.score(1);
    red_goals = red_goals + stats{i}.game2.score(2);
    blue_goals = blue_goals + stats{i}.game1.score(2);
    blue_goals = blue_goals + stats{i}.game2.score(1);
    if stats{i}.game1.score(1) > stats{i}.game1.score(2)
        red_wins = red_wins + 1;
    elseif stats{i}.game1.score(1) < stats{i}.game1.score(2)
        blue_wins = blue_wins + 1;
    end  
    if stats{i}.game2.score(1) < stats{i}.game2.score(2)
        red_wins = red_wins + 1;
    elseif stats{i}.game2.score(1) > stats{i}.game2.score(2)
        blue_wins = blue_wins + 1;
    end     
end

win_ratio = blue_wins/red_wins;
goal_ratio = blue_goals/red_goals;

fprintf('Win ratio: %4.2f\n',win_ratio)
fprintf('Goal ratio: %4.2f\n',goal_ratio)
fprintf('Red stats: %i wins, %i goals\n',red_wins,red_goals);
fprintf('Blue stats: %i wins, %i goals\n',blue_wins,blue_goals);
