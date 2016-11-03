function obj = behavior_advancedFSM(obj,world) 
%BEHAVIOR runs simple fsm to simulate player behavior

%simple FSM
if obj.behaviorState == player.KICK
    obj = behavior_kick(obj,world);        
elseif obj.behaviorState == player.MOVE
    obj = behavior_move(obj,world);
elseif obj.behaviorState == player.SEARCH;
    obj = behavior_search(obj,world);
elseif obj.behaviorState == player.APPROACH;
    obj = behavior_approach(obj,world);
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
[ obj, nearPos, ~ ] = obj.behavior_handle{obj.get_bh_id()}(obj,world,ball_global);

%check to see if we need to transition
if nearPos && (obj.role == player.ATTACKER || (obj.role == player.GOALIE && norm(world.cur_player.ball_local) < obj.cfg.GoalieGoThresh))
    obj.behaviorState = player.APPROACH;
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

function obj = behavior_approach(obj,world)

%check to make sure we can still see the ball
if isempty(world.cur_player.ball_local)
    obj.behaviorState = player.SEARCH;
    obj.bh_init = true;
    return
end

if norm(world.cur_player.ball_local) > obj.cfg.closetoPos
    obj.behaviorState = player.MOVE;
    obj.bh_init = true;
end

%get info about the world
ball_global = world.cur_player.pos(1:2) + world.cur_player.ball_local;
pose_global = world.cur_player.pos;
goal_attack = world.goal_attack;

%find desired angle (want to point towards attacking goal)
dpGoal = goal_attack - pose_global(1:2);
ang_des = atan2(dpGoal(2),dpGoal(1));

%find desired position (behind ball in line with goal)
n = [cos(ang_des), sin(ang_des)];
pos_des(1:2) = ball_global - n*(obj.cfg.player_hitbox_radius+obj.cfg.ball_radius);

%stay pointing at ball while moving to position
dpBall = world.cur_player.ball_local;
pos_des(3) = atan2(dpBall(2),dpBall(1));

%update desired pose and calculate velocity
obj.pos_des = pos_des;
[ obj.vel_des,nearPos,nearAng ] = obj.velSimple(world);

% obj.vel_des = 0.1*obj.vel_des;

if nearAng && nearPos
    obj.behaviorState = player.KICK;
    obj.bh_init = true; 
end   


end




