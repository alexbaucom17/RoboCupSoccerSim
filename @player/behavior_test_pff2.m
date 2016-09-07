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
obj = get_vel_pff(obj,world,ball_global);

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


function obj = get_vel_pff(obj,world,ball_global)

%collect information
pos_cur = world.cur_player.pos;
vel_cur = world.cur_player.vel;
team_idx = (1:5) ~= world.cur_player.number;
team_pos = reshape(world.myTeam(team_idx).pos(1:2),3,[])';
team_vel = reshape([world.myTeam(team_idx').vel],3,[])';
amax = obj.cfg.player_accelLin;
pROB = obj.cfg.player_hitbox_radius;

%need to run these calculations for small set of points near player
D = calculate_distances(cfg,pos_cur(1:2),pos_cur(3),ball_global,team_pos);


end



