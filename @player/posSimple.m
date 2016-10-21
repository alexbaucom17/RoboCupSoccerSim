function [ pos_des ] = posSimple( obj,world,ball_global )
%POSSIMPLE Calculate desired position

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
    pos_des(3) = atan2(dpBall(2),dpBall(1));
    
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
    if norm(dpBall) < obj.cfg.GoalieGoThresh && norm(dpGoalDef) < obj.cfg.GoalieMaxRange
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

