%runs a single match for testing

%% Initialization
close all
clear

%set up configuration variables
addpath game pff
cfg = Config();
cfg.drawgame = false;

%set up behavior
red_team = @movePff;
blue_team = @moveSimple;    

%behaviors
bh_list = [repmat({red_team},cfg.num_players_red,1); repmat({blue_team},cfg.num_players_blue,1)];

%uncomment to set up individual behaviors
% red_player = player.DEFENDER;
% blue_player = player.NONE;
% test_behavior = @movePff;
% red_idx = cfg.start_roles_red(1:cfg.num_players_red) == red_player ;
% blue_idx = cfg.start_roles_blue(1:cfg.num_players_blue) == blue_player;
% idx = [red_idx blue_idx];
% bh_list(idx) = {test_behavior};

%uncomment to load weights from data
load data/NM_2016-11-22-19-55-28Supporter
cfg.pff_weights = new_pff_weights;
      
%run game
[stats,scores] = GameController(cfg,bh_list);

%show results
disp(stats)
disp(scores)


    




