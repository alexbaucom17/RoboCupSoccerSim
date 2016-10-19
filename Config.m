function cfg = Config()

%initialize configuraiton variable
cfg = [];

%drawing
cfg.drawgame = true; %show game gui or not
cfg.debug = false; %shows various debug info (right now just player boundaries)

%timing
cfg.realtime = false; %run the simulation in realtime or not
cfg.timestep = 0.1; %seconds
cfg.halflength = 600; %seconds
if cfg.realtime
    cfg.drawgame_time = 0; %draw as fast as possible
else
    cfg.drawgame_time = 0.5; %draw at specified interval
end
cfg.record_movie = false; %whether to save simulation display as a movie
                          %Note: very resource intensive! Expect about 10x
                          %slowdown

%number of players 
%max 5 per team is supported
%min 2 per team is supported due to role switching implimentation
cfg.num_players_red = 5;
cfg.num_players_blue = 5;
cfg.num_players = cfg.num_players_red + cfg.num_players_blue;

%starting positions [xpos(m), ypos(m), angle(rad)]
%red team
cfg.start_pos(2,:) = [-1,0,0];
cfg.start_pos(3,:) = [-2,-1,0];
cfg.start_pos(4,:) = [-2,1,0];
cfg.start_pos(5,:) = [-3,-0.5,0];
cfg.start_pos(1,:) = [-3,0.5,0];
%blue team
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
cfg.player_hitbox_radius = 0.13; %m size of bounding box for player collisions
cfg.player_accelLin = [0.04,0.02]; %m/s^2 [x,y]
cfg.player_accelAng = 0.04; %rad/s^2
cfg.player_MaxLinVelX = [0.1,-0.04]; %m/s [forward,backward]
cfg.player_MaxLinVelY = 0.04; %m/s
cfg.player_MaxAngVel = 0.2; %rad/s

%kick parameters
cfg.kick_thresh = 0.1; %m max distance between player and ball for kick
cfg.kick_ang_thresh = 30*pi/180; %rad max angle between player and ball for kick
cfg.kick_fail_thresh = 0.05; %percent of time that kick fails
cfg.max_kick_power = 2.1; %m/s max speed ball can be kicked with
cfg.kick_angle_var = 2*pi/180; %angular variation in kick

%field
cfg.field_length= 4.5; %m
cfg.field_width = 3; %m
cfg.field_length_max = 1.1*cfg.field_length;
cfg.field_width_max = 1.1*cfg.field_width;
cfg.line_thickness = 0.05; %m field line thickness
cfg.goal_posts = [4.5,-0.8; 4.5,0.8; -4.5,-0.8; -4.5,0.8]; %location in meters 
cfg.goal_depth = 0.25; %goal depth in x direction
cfg.spots = [-3.2,0; 3.2,0]; %location of spots
cfg.spot_size = 0.1; %diameter of spots in meters
cfg.penalty_corners = [-3.9,1.1; -3.9,-1.1; 3.9,1.1; 3.9,-1.1]; %coreners of penalty box
cfg.penaltyY = cfg.penalty_corners(1,2)-cfg.penalty_corners(2,2);
cfg.penaltyX = cfg.field_length - cfg.penalty_corners(3,1);
cfg.circle_radius = 0.75; %center circle radius in meters
cfg.oobLineY = cfg.field_width-0.25; %X location ball will be returned to when it goes out of bounds
cfg.oobLineX = cfg.field_length - 0.5; %Y location ball will be returned to when it goes out of bounds

%behavior_simpleFSM params
cfg.closetoPos = 0.1; %m distance threshold to be considered close to the desired position
cfg.closetoAng = 20*pi/180; %angle threshold to be considered close to the desired angle
cfg.ballLostTime = 1; %sec how long until ball is considered lost
cfg.GoalieGoThresh = 1; %m how close the ball needs to get until goalie will charge for it
cfg.GoalieHomeDist = 0.3; %m how far from end line goalie should stay
cfg.SupportDistX = 0.75; %m how far behind attacker the supporter should stay
cfg.SupportDistY = 0.5; %m how far to side of attacker the supporter should stay
cfg.DefenderFrac = 0.5; %percent of attacker distance from goal line the defender should maintain
cfg.Defender2Frac = 0.25; %percent of attacker distance from goal line the second defender should maintain
cfg.nonAttackerPenalty = 0.7; %m role switch non-attacker penalty
cfg.nonDefenderPenalty = 1; %m role switch non-defender penalty

%world stocasticity
cfg.world_random_on = false; %enable or disable world stocasticity
cfg.world_observeOpp = false; %can players observe opponent team or not
cfg.world_posErr = 0.07; %m mean position variance
cfg.world_angErr = 3*pi/180; %rad mean anglular variance
cfg.world_teamballErr = 0.1; %m mean gloabl err of team ball observation
cfg.world_ball_local_err = 0.05; %meters of error per meter of distance from ball
cfg.world_seeBallNewRate = 0.8; %chance of seeing the ball if player did not see the ball in the previous update
cfg.world_seeBallContRate = 0.99; %chance of continuing to see the ball if player saw the ball in the previous frame
cfg.world_seeBallFOV = 120*pi/180; %field of view for seeing ball
    
%Game Scoring
cfg.goalsForPts = 10000; %get points for scoring a goal
cfg.goalsAgainstPts = -10000; %lose points for getting a goal scored against
cfg.oobPts = -100; %lose points for a player going out of bounds
cfg.close2ballthresh = 0.5; %m when to count attacker as close to the ball
cfg.close2ballPts = 0.01; %points for each update where the attacker is close to the ball
cfg.ownGoalForPts = -5000; %take away some points if a goal was actually an own goal scored by the other team
cfg.ownGoalAgainstPts = -10000; %take away even more points if a goal scored against us was an own goal
cfg.kickPts = 15; %points for every kick


