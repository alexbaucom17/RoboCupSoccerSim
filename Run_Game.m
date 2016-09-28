%runs a single match for testing

%% Initialization
close all
clear
rng('shuffle')

%set up configuration variables
addpath game pff
Config();
cfg.drawgame = true;

%behvariors
bh_list = repmat({@behavior_test_pff},cfg.num_players,1);
bh_list(1) = {@behavior_test_pff2};
         
%run game
[stats,scores] = GameController(cfg,bh_list);

disp(stats)
disp(scores)


    




