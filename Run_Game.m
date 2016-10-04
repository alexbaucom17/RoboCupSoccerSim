%runs a single match for testing

%% Initialization
close all
clear
rng('shuffle')

%set up configuration variables
addpath game pff
Config();
cfg.drawgame = true;

%set up behavior
red_team = @behavior_test_pff;
blue_team = @behavior_test_pff;    

%behaviors
bh_list = [repmat({red_team},cfg.num_players_red,1); repmat({blue_team},cfg.num_players_blue,1)];

%uncomment to set up individual behaviors
load data/NM_test6_weights_attacker
cfg.pff_weights(:,2) = w';
bh_list(2) = {@behavior_test_pff2}; %red team player
%bh_list(cfg.num_players_red+1) = {@behavior_test_pff2}; %blue team player

         
%run game
[stats,scores] = GameController(cfg,bh_list);

%show results
disp(stats)
disp(scores)


    




