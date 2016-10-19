%Simulates a single soccer match

%initialize
close all
clear
rng('shuffle')
addpath game

%set up configuration variables
cfg = Config();
cfg.drawgame = true; %overwrite this here for easy access to change it

%set up behavior
red_team = @moveSimple;
blue_team = @moveSimplePff;    
bh_list = [repmat({red_team},cfg.num_players_red,1); repmat({blue_team},cfg.num_players_blue,1)];

%uncomment to set up behaviors for individual players
%bh_list(1) = {@moveSimple}; %red team player
%bh_list(cfg.num_players_red+2) = {@moveSimple}; %blue team player
    
%run game
[stats,scores] = GameController(cfg,bh_list);

%show results
disp(stats)
disp(scores)


    




