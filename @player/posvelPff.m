function [ vel_des,nearPos,nearAng ] = posvelPff( obj,world,ball_global )
%POSVELPFF Summary of this function goes here

%collect information
pos_cur = world.cur_player.pos;
vel_cur = world.cur_player.vel;
team_idx = (1:obj.num_teammates+1) ~= world.cur_player.number;
team_pos = reshape([world.myTeam(team_idx).pos],3,[])';
team_pos = team_pos(:,1:2);
team_vel = reshape([world.myTeam(team_idx).vel],3,[])';
amax = obj.cfg.player_accelLin;
pROB = obj.cfg.player_hitbox_radius;

%need to run these calculations for small set of points near player
samples = linspace(-pi,pi,obj.cfg.num_local_samples);
sample_dX = obj.cfg.local_sample_distance*cos(samples);
sample_dY = obj.cfg.local_sample_distance*sin(samples);
sampleX = pos_cur(1) + sample_dX; 
sampleY = pos_cur(2) + sample_dY;

%append our current position to samples to only need 1 function call
sampleX = [sampleX pos_cur(1)];
sampleY = [sampleY pos_cur(2)];

%use symoblic pffs
%pff = obj.pffs{obj.role+1};
pff = obj.pffs;
weights = obj.cfg.pff_weights(:,obj.role+1);
[dball,dshotpath,dshotpathDef,dgoalAtt,dgoalDef,dbehindball,dsideline,dteammate] ...
                = calculate_distances(obj.cfg,[sampleX',sampleY'],pos_cur(3),ball_global,team_pos,obj.dir);
P = pff(dball,dshotpath,dshotpathDef,dgoalAtt,dgoalDef,dbehindball,dsideline,dteammate,weights);
cur_val = P(end);
P = P(1:end-1);


%find direction of new velocity along best gradient
[min_val,idx] = min(P);
dir = [sample_dX(idx);sample_dY(idx)];
ang = pos_cur(3);
tf = [cos(ang) sin(ang); -sin(ang) cos(ang)]; %need tf because dx and dy are global positions
dir = tf*(dir/norm(dir));
mag = obj.cfg.pff_vel_scale*max([0,cur_val-min_val]);
vel_des(1:2) = mag*dir';

%set angle to just track ball
dpBall = ball_global - pos_cur(1:2);
ang_des = atan2(dpBall(2),dpBall(1)); 
da = ang_des-pos_cur(3);
if abs(da) > pi
    da = -sign(da)*(2*pi-abs(da));
end
vel_des(3) = 5*da;

nearPos = norm(world.cur_player.pos(1:2) - ball_global) < 2*obj.cfg.closetoPos;
nearAng = 1;

end

