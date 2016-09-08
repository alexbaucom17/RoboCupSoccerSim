%initialize configuraiton variable
cfg = [];

%drawing
cfg.drawgame = false;
cfg.debug = false;

%timing
cfg.realtime = false;
cfg.timestep = 0.1;
cfg.halflength = 600; %seconds
if cfg.realtime
    cfg.drawgame_time = 0;
else
    cfg.drawgame_time = 0.5;
end
cfg.record_movie = false;

%number of players
cfg.num_players_red = 5;
cfg.num_players_blue = 5;
cfg.num_players = cfg.num_players_red + cfg.num_players_blue;

%starting positions
cfg.start_pos(2,:) = [-1,0,0];
cfg.start_pos(3,:) = [-2,-1,0];
cfg.start_pos(4,:) = [-2,1,0];
cfg.start_pos(5,:) = [-3,-0.5,0];
cfg.start_pos(1,:) = [-3,0.5,0];

cfg.start_pos(7,:) = [1,0,pi];
cfg.start_pos(8,:) = [2,1,pi];
cfg.start_pos(9,:) = [2,-1,pi];
cfg.start_pos(10,:) = [3,-0.5,pi];
cfg.start_pos(6,:) = [3,0.5,pi];

%ball parameters
cfg.ball_radius = 0.05; %m
cfg.ball_friction = 0.45; %m/s^2 
cfg.MinBallVel = 0.01; %m/s

%player parameters
cfg.player_hitbox_radius = 0.13; %m
cfg.player_accelLin = 0.04; %m/s^2
cfg.player_accelAng = 0.05; %rad/s^2
cfg.player_MaxLinVel = 0.1; %m/s
cfg.player_MaxAngVel = 0.2; %rad/s

%kick parameters
cfg.kick_thresh = 0.1;
cfg.kick_ang_thresh = 30*pi/180;
cfg.kick_fail_thresh = 0.05;
cfg.max_kick_power = 2.1;
cfg.kick_angle_var = 2*pi/180;

%field
cfg.field_length= 4.5; %m
cfg.field_width = 3; %m
cfg.field_length_max = 1.1*cfg.field_length;
cfg.field_width_max = 1.1*cfg.field_width;
cfg.line_thickness = 0.05;
cfg.goal_posts = [4.5,-0.8; 4.5,0.8; -4.5,-0.8; -4.5,0.8];
cfg.goal_depth = 0.25;
cfg.spots = [-3.2,0; 3.2,0];
cfg.spot_size = 0.1;
cfg.penalty_corners = [-3.9,1.1; -3.9,-1.1; 3.9,1.1; 3.9,-1.1];
cfg.penaltyY = cfg.penalty_corners(1,2)-cfg.penalty_corners(2,2);
cfg.penaltyX = cfg.field_length - cfg.penalty_corners(3,1);
cfg.circle_radius = 0.75;
cfg.oobLineY = cfg.field_width-0.25;
cfg.oobLineX = cfg.field_length - 0.5;

%behavior
cfg.behavior_handle_red = @behavior_simple;
cfg.behavior_handle_blue = @behavior_test_pff;
cfg.closetoPos = 0.1; %m
cfg.closetoAng = 10*pi/180;
cfg.ballLostTime = 1; %sec
cfg.GoalieGoThresh = 1; %m
cfg.GoalieHomeDist = 0.3;
cfg.SupportDistX = 0.75;
cfg.SupportDistY = 0.5;
cfg.DefenderFrac = 0.5;
cfg.Defender2Frac = 0.25;
cfg.nonAttackerPenalty = 1;
cfg.nonDefenderPenalty = 1;

%world stocasticity
cfg.world_random_on = true;
cfg.world_observeOpp = false;
cfg.world_posErr = 0.07;
cfg.world_angErr = 3*pi/180;
cfg.world_teamballErr = 0.1; %gloabl err
cfg.world_ball_local_err = 0.05; %err/m
cfg.world_seeBallNewRate = 0.8;
cfg.world_seeBallContRate = 0.99;
cfg.world_seeBallFOV = 120*pi/180;

%Potential Field Function
%                   /wall\  /ball\  /team\  fb  db
%                   c1  k1  c2  k2  c3  k3  k4  k5    
% cfg.pff_weights = [ 1   1   0   0   1   1   0   1;  %goalie
%                     3   2   0.5 2   2   1   0   1;  %attacker
%                     3   2   0   0   2   1   0   1;  %defender
%                     3   2   0   1   2   1   1   0;  %supporter
%                     3   2   0   0   1   1   0   1]; %defender2

                                %goalie attacker defender supporter defender2   
pff_weights.boundary_reach =    [   1      3        3         3        3];
pff_weights.boundary_scale =    [   1      2        2         2        2];
pff_weights.ball_eq_pos    =    [   0      0.5      0         0        0];
pff_weights.ball_scale     =    [   0      2.5      0         1        0];
pff_weights.team_reach     =    [   0      1        0         2        0];
pff_weights.team_scale     =    [   0      1        0         1        0];
pff_weights.fwd_bias_scale =    [   0      0        0         1        0];
pff_weights.def_bias_scale =    [   1      0        1         0        1];
pff_weights.att_shot_scale =    [   0      1        0         0        0];
pff_weights.att_bias_scale =    [   0      1.3      0         0        0];
pff_weights.sup_shot_dist  =    [   0      0        0         2        0];
pff_weights.sup_shot_scale =    [   0      0        0         1        0];
pff_weights.def_shot_scale =    [   1      0        1         0        1];
pff_weights.offset_scale   =    [   0      0        0         1        0];

cfg.pff_weights = cell2mat(struct2cell(pff_weights));
clear pff_weights
    




