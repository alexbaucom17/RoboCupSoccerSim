function [ vel_des, nearPos,nearAng ] = velPff( obj,world )
%VELPFF 

%collect information
pos_cur = world.cur_player.pos;
pos_des = obj.pos_des;
vel_cur = world.cur_player.vel;
vel_des = [0,0,0]; %assume this for now
team_idx = (1:(obj.num_teammates+1)) ~= world.cur_player.number;
team_pos = reshape([world.myTeam(team_idx).pos],3,[])';
team_vel = reshape([world.myTeam(team_idx').vel],3,[])';
amax = norm(obj.cfg.player_accelLin);
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
    nearPos = true;
else
    nearPos = false;
end
if abs(dp(3)) < obj.cfg.closetoAng
    nearAng = true;
else
    nearAng = false;
end

%solve for repulsive forces from other players and environment
%don't really care about angle here
p0 = pROB + 0.2; %obstacle influence range
eta = 0.3; %scaling constant

for i = 1:size(team_pos,1)
    dp = team_pos(i,1:2) - pos_cur(1:2);
    dv = team_vel(i,1:2) - vel_cur(1:2);
    nRO = dp/norm(dp);
    vRO = dv*dp';
    rhoS = norm(dp);
    rhoM = vRO^2/(2*amax);

    if vRO <= 0 || (rhoS-rhoM) >= p0
        Frep = [0,0];
    elseif vRO > 0 && (rhoS-rhoM) > 0 && (rhoS-rhoM) < p0
        Frep1 = -eta/(rhoS-pROB-rhoM)^2 * (1+vRO/amax) * nRO;
        tmp = - dv - vRO*nRO;
        vRO_perp = norm(tmp);
        nRO_perp = tmp/vRO_perp;
        Frep2 = eta*vRO*vRO_perp/(rhoS*amax*(rhoS-pROB-rhoM)^2)*nRO_perp;
        Frep = Frep1 + Frep2;
    else
        Frep = [0,0]; %not techincally defined in this case
    end
    Ft = Ft + [Frep, 0];
end

%caluclate desired velocity from total force
a = obj.local2globalTF'*Ft'/mass; %acceleration in local frame
a(3) = Ft(3);
vel_des = vel_cur + a'*obj.timestep;

end

