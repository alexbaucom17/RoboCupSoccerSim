function cfg = FullRunConfig(i)
%initialize configuration variables

%initialize configuraiton variable
cfg = [];

if nargin ~= 1
    i = 0;
end

%set parameters for given trial number
if i == 1
    
    cfg.num_players_red = 1;
    cfg.num_players_blue = 1;
    %Goalie-0; Attacker-1; Defender-2; Supporter-3; Defender2-4
    cfg.start_roles_red = [1 2 3 4 0];
    cfg.start_roles_blue = [1 2 3 4 0];
    cfg.force_initial_roles = true;
    cfg.training_role = [1]; 
    cfg.load_fname = '';
    
elseif i == 2
    
    cfg.num_players_red = 2;
    cfg.num_players_blue = 2;
    %Goalie-0; Attacker-1; Defender-2; Supporter-3; Defender2-4
    cfg.start_roles_red = [1 2 3 4 0];
    cfg.start_roles_blue = [1 2 3 4 0];
    cfg.force_initial_roles = true;
    cfg.training_role = [2];  
    cfg.load_fname = strcat('FullRunData/Run',num2str(i-1));
    
elseif i == 3
    
    cfg.num_players_red = 3;
    cfg.num_players_blue = 3;
    %Goalie-0; Attacker-1; Defender-2; Supporter-3; Defender2-4
    cfg.start_roles_red = [1 2 3 4 0];
    cfg.start_roles_blue = [1 2 3 4 0];
    cfg.force_initial_roles = true;
    cfg.training_role = [3];  
    cfg.load_fname = strcat('FullRunData/Run',num2str(i-1));
    
elseif i == 4
    
    cfg.num_players_red = 4;
    cfg.num_players_blue = 4;
    %Goalie-0; Attacker-1; Defender-2; Supporter-3; Defender2-4
    cfg.start_roles_red = [1 2 3 4 0];
    cfg.start_roles_blue = [1 2 3 4 0];
    cfg.force_initial_roles = true;
    cfg.training_role = [4];  
    cfg.load_fname = strcat('FullRunData/Run',num2str(i-1));
    
elseif i == 5
    
    cfg.num_players_red = 2;
    cfg.num_players_blue = 2;
    %Goalie-0; Attacker-1; Defender-2; Supporter-3; Defender2-4
    cfg.start_roles_red = [1 0 3 4 2];
    cfg.start_roles_blue = [1 0 3 4 2];
    cfg.force_initial_roles = true;
    cfg.training_role = [0];  
    cfg.load_fname = strcat('FullRunData/Run',num2str(i-1));
    
elseif i == 6
    
    cfg.num_players_red = 2;
    cfg.num_players_blue = 2;
    %Goalie-0; Attacker-1; Defender-2; Supporter-3; Defender2-4
    cfg.start_roles_red = [1 0 3 4 2];
    cfg.start_roles_blue = [1 0 3 4 2];
    cfg.force_initial_roles = true;
    cfg.training_role = [0];  
    cfg.load_fname = strcat('FullRunData/Run',num2str(i-1));
    
elseif i == 7
    
    cfg.num_players_red = 3;
    cfg.num_players_blue = 3;
    %Goalie-0; Attacker-1; Defender-2; Supporter-3; Defender2-4
    cfg.start_roles_red = [1 2 3 4 0];
    cfg.start_roles_blue = [1 2 3 4 0];
    cfg.force_initial_roles = true;
    cfg.training_role = [2,3];  
    cfg.load_fname = strcat('FullRunData/Run',num2str(i-1));
    
elseif i == 8
    
    cfg.num_players_red = 4;
    cfg.num_players_blue = 4;
    %Goalie-0; Attacker-1; Defender-2; Supporter-3; Defender2-4
    cfg.start_roles_red = [1 2 3 4 0];
    cfg.start_roles_blue = [1 2 3 4 0];
    cfg.force_initial_roles = true;
    cfg.training_role = [2,4];  
    cfg.load_fname = strcat('FullRunData/Run',num2str(i-1));
    
elseif i == 9
    
    cfg.num_players_red = 5;
    cfg.num_players_blue = 5;
    %Goalie-0; Attacker-1; Defender-2; Supporter-3; Defender2-4
    cfg.start_roles_red = [1 2 3 4 0];
    cfg.start_roles_blue = [1 2 3 4 0];
    cfg.force_initial_roles = true;
    cfg.training_role = [1];  
    cfg.load_fname = strcat('FullRunData/Run',num2str(i-1));
    
elseif i == 10
    
    cfg.num_players_red = 5;
    cfg.num_players_blue = 5;
    %Goalie-0; Attacker-1; Defender-2; Supporter-3; Defender2-4
    cfg.start_roles_red = [1 2 3 4 0];
    cfg.start_roles_blue = [1 2 3 4 0];
    cfg.force_initial_roles = true;
    cfg.training_role = [2,3,4,0];  
    cfg.load_fname = strcat('FullRunData/Run',num2str(i-1));
    
%defualt config    
elseif i == 0
    
    cfg.num_players_red = 5;
    cfg.num_players_blue = 5;
    cfg.force_initial_roles = false;
    cfg.training_role = [0]; 
    cfg.load_fname = '';
    
end


%drawing
cfg.drawgame = false;
cfg.debug = false;

%timing
cfg.realtime = false;
cfg.timestep = 0.1;
cfg.halflength = 300; %seconds
if cfg.realtime
    cfg.drawgame_time = 0;
else
    cfg.drawgame_time = 0.5;
end
cfg.record_movie = false;

%number of players
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

%starting roles
%Goalie-0; Attacker-1; Defender-2; Supporter-3; Defender2-4
if ~cfg.force_initial_roles
    cfg.start_roles_red = [0 1 2 3 4];
    cfg.start_roles_blue = [0 1 2 3 4];
end

%ball parameters
cfg.ball_radius = 0.04; %m
cfg.ball_friction = 0.45; %m/s^2 
cfg.MinBallVel = 0.01; %m/s

%player parameters
cfg.player_hitbox_radius = 0.1; %m
cfg.player_accelLin = [0.04,0.02]; %m/s^2
cfg.player_accelAng = 0.04; %rad/s^2
cfg.player_MaxLinVelX = [0.1,-0.04]; %m/s
cfg.player_MaxLinVelY = 0.04;
cfg.player_MaxAngVel = 0.2; %rad/s

%kick parameters
cfg.kick_thresh = 0.05;
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
cfg.closetoPos = 0.4; %m
cfg.closetoAng = 20*pi/180; %rad
cfg.closetoPosKick = 0.15; %m
cfg.closetoAngKick = 5*pi/180; %rad
cfg.closetoAngGoalie = 40*pi/180; %rad
cfg.ballLostTime = 1; %sec
cfg.GoalieGoThresh = 1; %m
cfg.GoalieMaxRange = 1.2; %m - distance goalie can move away from goalline
cfg.GoalieHomeDist = 0.3;
cfg.SupportDistX = 0.75;
cfg.SupportDistY = 0.5;
cfg.DefenderFrac = 0.5;
cfg.Defender2Frac = 0.25;
cfg.nonAttackerPenalty = 0.7;
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
%attractive                       %goalie attacker defender supporter defender2  
pff_weights.ball_range         = [   0.75   10       0         9        0 ];
pff_weights.ball_offset        = [   0.01   0        0         2        0 ];
pff_weights.ball_gain          = [   5      5        0         5        0 ];
pff_weights.shotpath_range     = [   0      10       0         9        0 ];
pff_weights.shotpath_offset    = [   0      0.1      0         2        0 ];
pff_weights.shotpath_gain      = [   0      20       0         5        0 ];
pff_weights.shotpathDef_range  = [   10     0        9         0        9 ];
pff_weights.shotpathDef_offset = [   0.01   0        0.01      0        0.5];
pff_weights.shotpathDef_gain   = [   4      0        2         0        3 ];
pff_weights.goalAtt_range      = [   0      0        0         3        0 ];
pff_weights.goalAtt_offset     = [   0      0        0         2        0 ];
pff_weights.goalAtt_gain       = [   0      0        0         1        0 ];
pff_weights.goalDef_range      = [   9      0        10        0        9 ];
pff_weights.goalDef_offset     = [   0.5    0        1.5       0        2.5 ];
pff_weights.goalDef_gain       = [   4      0        3         0        2 ];
pff_weights.Bball_range        = [   0      9        9         2        9 ];
pff_weights.Bball_offset       = [   0      0        0         0        0 ];
pff_weights.Bball_gain         = [   0      50       9         1        9 ];
%repulsive
pff_weights.sideline_range     = [   0.1    0.2      0.2       0.2      0.2];
pff_weights.sideline_offset    = [   0      0        0         0        0];
pff_weights.sideline_gain      = [   1      1        1         1        1 ];
pff_weights.teammate_range     = [   0      0.5      1         1        1 ];
pff_weights.teammate_offset    = [   0      0        0         0        0 ];
pff_weights.teammate_gain      = [   0      0.5      0.5       0.5      0.5];

%more pff parameters
cfg.pff_fun_desc = [1 1 1 1 1 1 0 0];
cfg.pff_testing = false;
cfg.num_local_samples = 10;
cfg.local_sample_distance = 0.1;
cfg.pff_vel_scale = 10;
cfg.pff_weights = cell2mat(struct2cell(pff_weights));
    
%Game Scoring
cfg.goalsForPts = 100;
cfg.goalsAgainstPts = -100;
cfg.oobPts = -10;
cfg.close2ballthresh = 0.5; %m
cfg.close2ballPts = 0;
cfg.ownGoalForPts = -50;
cfg.ownGoalAgainstPts = -100;
cfg.kickPts = 0;

%Nelder mead learning parameters and calculations
cfg.NM_fn_thresh = 150;
cfg.NM_domain_thresh = 0.01;
cfg.NM_weight_penalty = 0;
cfg.NM_initial_step_size = 0.05;
cfg.NM_saveAfter = 100;
cfg.NM_batchSize = 4;
cfg.NM_maxIter = 2000;
cfg.validation_batchSize = 50;

%override initial weights if desired
if ~isempty(cfg.load_fname)
    load(cfg.load_fname)
    cfg.pff_weights = new_weights;
end

%remove all 0 weights from training set but keep index for easy replacement
%later
cfg.training_role = cfg.training_role+1;
cfg.NM_initial = reshape(cfg.pff_weights(:,cfg.training_role),1,[]);
cfg.NM_idx = [];
for i = cfg.training_role
    col = cfg.pff_weights(:,i);
    rows = find(col ~= 0);
    cols = repmat(i,length(rows),1);
    cfg.NM_idx = [cfg.NM_idx; sub2ind(size(cfg.pff_weights),rows,cols)];
end    
cfg.NM_initial(cfg.NM_initial == 0) = []; 
cfg.NM_dim = length(cfg.NM_initial);

%adaptive parameters for NM
%http://www.webpages.uidaho.edu/~fuchang/res/anms.pdf
cfg.NM_alpha = 1;
cfg.NM_beta = 1 + 2/cfg.NM_dim;
cfg.NM_gamma = 0.75-1/(2*cfg.NM_dim);
cfg.NM_delta = 1-1/cfg.NM_dim;




end




