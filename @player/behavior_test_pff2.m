function obj = behavior_test_pff2(obj,world) 
%BEHAVIOR runs simple fsm to simulate player behavior

%simple FSM
if obj.behaviorState == player.KICK
    obj = behavior_kick(obj,world);        
elseif obj.behaviorState == player.MOVE
    obj = behavior_move(obj,world);
elseif obj.behaviorState == player.SEARCH;
    obj = behavior_search(obj,world);
else
    obj.behaviorState = player.SEARCH;
    obj = behavior_search(obj,world);
end

end


function obj = behavior_move(obj,world)

%update previous ball info if we don't have current info
if isempty(world.cur_player.ball_local)
    
    %check if the teamball is known
    if ~isempty(world.teamball)
        ball_global = world.teamball.pos;
    else
        ball_global = obj.prev_ball.pos;
        
        %do search if ball is lost for too long
        if (obj.gametime - obj.prev_ball.time) > obj.cfg.ballLostTime
            obj.behaviorState = player.SEARCH;
            obj.bh_init = true;    
        end
    end
else
    %update prev_ball info if we currently see it
    ball_global = world.cur_player.pos(1:2) + world.cur_player.ball_local;
    obj.prev_ball.pos = ball_global;
    obj.prev_ball.time = obj.gametime;
end

%do calculations
obj.pos_des = get_pos_des(obj,world,ball_global);
obj = get_vel_pff(obj,world);

%check to see if we need to transition
if obj.nearAng && obj.nearPos && obj.role == player.ATTACKER
    obj.behaviorState = player.KICK;
    obj.bh_init = true; 
end

%check to see if we need to transition
if obj.nearAng && obj.nearPos && obj.role == player.GOALIE
    obj.behaviorState = player.KICK;
    obj.bh_init = true; 
end



end

function obj = behavior_search(obj,world)

%if we don't see the ball, do some simple searching for it  
if isempty(world.teamball)
    
    if obj.bh_init
        dist = obj.prev_ball.pos - world.cur_player.pos(1:2);
        dist_rel = obj.local2globalTF'*[dist';0];
        ang = atan2(dist_rel(2),dist_rel(1));
        dir = sign(ang);
        obj.bh_init = false;
        obj.vel_des = [0,0,dir*obj.cfg.player_MaxAngVel/2]; 
    end           
            
%if we do see the ball, update prev info and switch to move
else
    obj.prev_ball.pos = world.teamball.pos;
    obj.prev_ball.time = obj.gametime;
    obj.behaviorState = player.MOVE;
    obj.bh_init = true;
end

end

function obj = behavior_kick(obj,world)

obj.kick = 1;
obj.behaviorState = player.SEARCH;
obj.bh_init = true;

end


%calculate desired position
function pos_des  = get_pos_des(obj,world,ball_global)

%get position information
pose_info = world.cur_player.pos;
pos_cur = pose_info(1:2);
ang_cur = pose_info(3);

%find differences between ball and goal
dpBall = ball_global - pos_cur;
dpGoal = world.goal_attack - pos_cur;
dpGoalDef = world.goal_defend - pos_cur;
dir = sign(world.goal_attack(1));

%find attacker
attacker_num = world.attackerID;

if obj.role == player.ATTACKER
    
    %find desired angle
    ang_des = atan2(dpGoal(2),dpGoal(1));

    %find desired position
    n = [cos(ang_des), sin(ang_des)];
    pos_des(1:2) = ball_global - n*(obj.cfg.player_hitbox_radius);
    pos_des(3) = ang_des;
    
elseif obj.role == player.SUPPORTER
    attacker_pos = world.myTeam(attacker_num).pos;
    pos_des(1) = attacker_pos(1) - dir*obj.cfg.SupportDistX;
    pos_des(2) = attacker_pos(2) - sign(ball_global(2))*obj.cfg.SupportDistY;
    pos_des(3) = atan2(dpBall(2),dpBall(1));
    
elseif obj.role == player.DEFENDER2
    distFromGoal = obj.cfg.DefenderFrac*(ball_global(1) - world.goal_defend(1));
    pos_des(1) = world.goal_defend(1) + distFromGoal;
    pos_des(2) = ball_global(2);
    pos_des(3) = atan2(dpBall(2),dpBall(1));
    
elseif obj.role == player.DEFENDER
    distFromGoal = obj.cfg.Defender2Frac*(ball_global(1) - world.goal_defend(1));
    pos_des(1) = world.goal_defend(1) + distFromGoal;
    pos_des(2) = 0.5*ball_global(2);
    pos_des(3) = atan2(dpBall(2),dpBall(1));
elseif obj.role == player.GOALIE
    if norm(dpBall) < obj.cfg.GoalieGoThresh
        %find desired angle
        ang_des = atan2(dpBall(2),dpBall(1));
        %find desired position
        n = [cos(ang_des), sin(ang_des)];
        pos_des(1:2) = ball_global - n*(obj.cfg.player_hitbox_radius+obj.cfg.ball_radius);
        pos_des(3) = ang_des;
    else
        pos_des(1) = world.goal_defend(1) + dir*obj.cfg.GoalieHomeDist;
        pos_des(2) = 0;
        pos_des(3) = atan2(dpBall(2),dpBall(1));        
    end
        
end

%keep player within boundaries
if abs(pos_des(1)) > obj.cfg.field_length_max
    pos_des(1) = sign(pos_des(1))*obj.cfg.field_length_max;
end
if abs(pos_des(2)) > obj.cfg.field_width_max
    pos_des(2) = sign(pos_des(2))*obj.cfg.field_width_max;
end



end

% %calculate desired velocity
% function obj = get_vel_des(obj,world)
% 
% %get position information
% pose_info = world.cur_player.pos;
% pos_cur = pose_info(1:2);
% ang_cur = pose_info(3);
% pos_des = obj.pos_des(1:2);
% ang_des = obj.pos_des(3);
% 
% %conversion to local coordinates
% dp_gobal = pos_des - pos_cur;
% dp_local = obj.local2globalTF'*[dp_gobal';1];
% dp_local = dp_local(1:2);     
% 
% %find required change in angle
% da = ang_des-ang_cur;
% if abs(da) > pi
%     da = -sign(da)*(2*pi-abs(da));
% end
% 
% %do max linear velocity if far away. When close use
% %proportional controller
% if norm(dp_local) > obj.cfg.closetoPos
%     obj.vel_des(1:2) = dp_local/norm(dp_local) * obj.cfg.player_MaxLinVel;
%     obj.nearPos = false;
% else
%     obj.vel_des(1:2) = 5 * dp_local * obj.cfg.player_MaxLinVel;
%     obj.nearPos = true;
% end
% 
% %do max angular velocity if far away. When close use
% %proportional controller
% if abs(da) > obj.cfg.closetoAng
%     obj.vel_des(3) = sign(da) * obj.cfg.player_MaxAngVel;
%     obj.nearAng = false;
% else
%     obj.vel_des(3) = da * obj.cfg.player_MaxAngVel;
%     obj.nearAng = true;
% end
% 
% end

function obj = get_vel_pff(obj,world)

%collect information
pos_cur = world.cur_player.pos;
pos_des = obj.pos_des;
vel_cur = world.cur_player.vel;
vel_des = [0,0,0]; %assume this for now
team_idx = (1:5) ~= world.cur_player.number;
team_pos = reshape([world.myTeam(team_idx).pos],3,[])';
team_vel = reshape([world.myTeam(team_idx').vel],3,[])';
amax = obj.cfg.player_accelLin;
pROB = obj.cfg.player_hitbox_radius;

%generate attractive force
mass = 5.30535;
m = 2;
n = 2;
Ap = 10;
Av = 1;
dp = pos_des - pos_cur;
dv = vel_des - vel_cur;

%adjust angle turning
if abs(dp(3)) > pi
   dp(3) = -sign(dp(3))*(2*pi-abs(dp(3)));
end

%solve for attractive force towards the target position
if norm(dp) > 0
    Fatt1 = m*Ap*norm(dp)^(m-1)*dp/norm(dp);
else
    Fatt1 = [0,0,0];
end
if norm(dv) > 0
    Fatt2 = n*Av*norm(dv)^(n-1)*dv/norm(dv);
else
    Fatt2 = [0,0,0];
end

%find total force
Ft = Fatt1 + Fatt2;

%check how close we are to target
if norm(dp(1:2)) < obj.cfg.closetoPos
    obj.nearPos = true;
else
    obj.nearPos = false;
end
if abs(dp(3)) < obj.cfg.closetoAng
    obj.nearAng = true;
else
    obj.nearAng = false;
end

%solve for repulsive forces from other players and environment
%don't really care about angle here
% p0 = pROB + 0.2; %obstacle influence range
% eta = 0.3; %scaling constant
% 
% for i = 1:size(team_pos,1)
%     dp = team_pos(i,1:2) - pos_cur(1:2);
%     dv = team_vel(i,1:2) - vel_cur(1:2);
%     nRO = dp/norm(dp);
%     vRO = dv*dp';
%     rhoS = norm(dp);
%     rhoM = vRO^2/(2*amax);
% 
%     if vRO <= 0 || (rhoS-rhoM) >= p0
%         Frep = [0,0];
%     elseif vRO > 0 && (rhoS-rhoM) > 0 && (rhoS-rhoM) < p0
%         Frep1 = -eta/(rhoS-pROB-rhoM)^2 * (1+vRO/amax) * nRO;
%         tmp = - dv - vRO*nRO;
%         vRO_perp = norm(tmp);
%         nRO_perp = tmp/vRO_perp;
%         Frep2 = eta*vRO*vRO_perp/(rhoS*amax*(rhoS-pROB-rhoM)^2)*nRO_perp;
%         Frep = Frep1 + Frep2;
%     else
%         Frep = [0,0]; %not techincally defined in this case
%     end
%     Ft = Ft + [Frep, 0];
% end

%caluclate desired velocity from total force
a = obj.local2globalTF'*Ft'/mass; %acceleration in local frame
a(3) = Ft(3);
obj.vel_des = vel_cur + a'*obj.timestep;


end



