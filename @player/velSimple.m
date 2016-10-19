function [ vel_des, nearPos,nearAng ] = velSimple( obj,world )
%VELSIMPLE calculate desired velocity with very simple controller

%get position information
pose_info = world.cur_player.pos;
pos_cur = pose_info(1:2);
ang_cur = pose_info(3);
pos_des = obj.pos_des(1:2);
ang_des = obj.pos_des(3);

%conversion to local coordinates
dp_gobal = pos_des - pos_cur;
dp_local = obj.local2globalTF'*[dp_gobal';1];
dp_local = dp_local(1:2);     

%find required change in angle
da = ang_des-ang_cur;
if abs(da) > pi
    da = -sign(da)*(2*pi-abs(da));
end

%do max linear velocity if far away. When close use
%proportional controller
if norm(dp_local) > obj.cfg.closetoPos
    vel_des(1:2) = dp_local/norm(dp_local) * obj.cfg.player_MaxLinVelX(1);
    nearPos = false;
else
    vel_des(1:2) = 5 * dp_local * obj.cfg.player_MaxLinVelX(1);
    nearPos = true;
end

%do max angular velocity if far away. When close use
%proportional controller
if abs(da) > obj.cfg.closetoAng
    vel_des(3) = sign(da) * obj.cfg.player_MaxAngVel;
    nearAng = false;
else
    vel_des(3) = da * obj.cfg.player_MaxAngVel;
    nearAng = true;
end


end

