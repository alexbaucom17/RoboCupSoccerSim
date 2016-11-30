function [p,b,w] = HandleCollisions(p,b,cfg,w)
%HANDLECOLLISIONS Checks for collisions between players and ball as well as
%kicks
%   Checks if there are colisions and calculates new velocities based on
%   elastic collision model. New velocites are updated in objects and
%   output as Pnew and Bnew

%get config parameters
ball_rad = cfg.ball_radius;
player_rad = cfg.player_hitbox_radius;
kick_rad = ball_rad + player_rad + cfg.kick_thresh;

%put all player positions and velocities in matrix
ppos = zeros(cfg.num_players,3);
kick = zeros(cfg.num_players,1);
for i = 1:cfg.num_players
    ppos(i,:) = p{i}.pos();
    kick(i) = p{i}.kick;
end


%%%%%%%%%%%%%%%%%%%%%Check kicks%%%%%%%%%%%%%%%%%%%%

%if a single player is atempting to kick, just exectute
%if multiple people are attempting kick, do it in a random order
kick_idx = find(kick == 1);
if ~isempty(kick_idx)
    ix = randperm(length(kick_idx));
    kick_idx_shuffled = kick_idx(ix);
    for i = 1:length(kick_idx_shuffled)
        idx = kick_idx_shuffled(i);
        pKick = p{idx};
        [b,status] = executeKick(pKick,b,kick_rad,cfg);
        if status == false
            kick(idx) = 0;
        else
            %keep track of number of kicks for each team
            if strcmp(b.prev_touch,'red')
                w.num_kicks(1) = w.num_kicks(1) + 1;
            else
                w.num_kicks(2) = w.num_kicks(2) + 1;
            end
        end
        p{idx}.kick = 0;        
    end
end
    

%%%%%%%%%%%%Bumping ball, but not kicking%%%%%%%%%%%

%get ball position and velocity
bpos = b.pos;

%figure out if any players are close enough to bump
bump = zeros(cfg.num_players,1);
for i = 1:cfg.num_players
    bump(i) = closeTo(ppos(i,1:2),bpos,ball_rad+player_rad);
end

%ignore bumping if the player already kicked
bump = bump & (kick==0);
bump_idx = find(bump == 1);

%execute any ball bumps in random order
if ~isempty(bump_idx)
    ix = randperm(length(bump_idx));
    bump_idx_shuffled = bump_idx(ix);
    for i = bump_idx_shuffled
        pBump = p{i};
        b = executeBallBump(pBump,b,ball_rad+player_rad);
    end
end


%%%%%%%%%%%%%%Players bumping%%%%%%%%%%%%%%%%%%%%%%%%%%
%figure out which players are bumping into each other
%and exectue bump code in random order
if cfg.num_players > 1
    bump_combos = nchoosek(1:cfg.num_players,2);
    bump_to_exectue = zeros(size(bump_combos,1),1);
    for i = 1:size(bump_combos,1)
        p1 = p{bump_combos(i,1)};
        p2 = p{bump_combos(i,2)};
        bump_to_exectue(i) = closeTo(p1.pos,p2.pos,2*player_rad);   
    end

    %if multiple people are bumping, do it in a random order
    bump_idx = find(bump_to_exectue);
    if ~isempty(bump_idx)
        ix = randperm(length(bump_idx));
        bump_idx_shuffled = bump_idx(ix);
        for j = 1:length(bump_idx_shuffled)
            i = bump_idx_shuffled(j);
            p1 = p{bump_combos(i,1)};
            p2 = p{bump_combos(i,2)};
            [p1,p2] = executePlayerBump(p1,p2,2*player_rad);
            p{bump_combos(i,1)} = p1;
            p{bump_combos(i,2)} = p2;
        end
    end
end

end

function [b,status] = executeKick(p,b,kick_rad,cfg)

%check if ball is close enough for kick
ppos = p.pos;
bpos = b.pos;
closeEnough = closeTo(ppos,bpos,kick_rad);

%find relative ball pos and angle
rel_ball_pos = [bpos(1) - ppos(1) ,bpos(2) - ppos(2)];
rel_ball_ang = atan2(rel_ball_pos(2),rel_ball_pos(1)) - ppos(3);

%fix rel_ball_angle if too big
if abs(rel_ball_ang) > pi
    rel_ball_ang = -sign(rel_ball_ang)*(2*pi-abs(rel_ball_ang));
end

%kick fails if not close enough or ball isn't in front of player
%for variance, kick will also randomly fail occasionally
if ~closeEnough || abs(rel_ball_ang) > cfg.kick_ang_thresh || rand < cfg.kick_fail_thresh
    status = false;
    return
end

%caluclate kick parameters
kick_angle_var = cfg.kick_angle_var;
kick_angle = ppos(3) + rand*rel_ball_ang/2 + randn*kick_angle_var;
kick_power = cfg.max_kick_power*rand;

%adjust ball velocity in kick direction with some more randomness thrown in
ball_vel_adjust = kick_power*[cos(kick_angle) sin(kick_angle)];
b = b.set_vel(0.5*rand*b.vel + ball_vel_adjust);
b.prev_touch = p.team_color;
b.kick_loc = p.pos(1:2);
status = true;

end


function b = executeBallBump(p,b,min_dist)
%assuming player mass is huge compared to the ball we just
%reverse the veloctiy of the ball in the normal direcion of collision
%source: https://physics.stackexchange.com/questions/79047/determine-resultant-velocity-of-an-elastic-particle-particle-collision-in-3d-spa

%find normal direction
r1 = p.pos(1:2);
r2 = b.pos(1:2);
n = (r1-r2)/norm(r1-r2);

%relative velocty between players
pvel = p.get_vel();
vrel = dot((pvel(1:2) - b.vel(1:2)),n);

%adjust velocities based on elastic colision
b.vel(1:2) = b.vel(1:2) + 2*vrel*n;

%adjust ball position so it doesn't go through the player at slow speeds
b.pos = r1-min_dist*n;
b.prev_touch = p.team_color;
b.kick_loc = p.pos(1:2);

end

function [p1,p2] = executePlayerBump(p1,p2,min_dist)

%assuming player masses are the same we just need to 
%reverse the velocties in the normal direciont of collision
%source: https://physics.stackexchange.com/questions/79047/determine-resultant-velocity-of-an-elastic-particle-particle-collision-in-3d-spa

%find normal directino
r1 = p1.pos(1:2);
r2 = p2.pos(1:2);
n = (r1-r2)/norm(r1-r2);

%relative velocty between players
p1vel = p1.get_vel();
p2vel = p2.get_vel();
vrel = dot((p1vel(1:2) - p2vel(1:2)),n);

%adjust velocities based on fully elastic collision of equal mass
p1vel(1:2) = p1vel(1:2) - vrel*n;
p2vel(1:2) = p2vel(1:2) + vrel*n;
p1.vel_override(p1vel);
p2.vel_override(p2vel);

%adjust player position so they can't go through each other
if norm(r1-r2) < min_dist
    c = (r1+r2)/2;
    p1.pos(1:2) = c+min_dist/2*n;
    p2.pos(1:2) = c-min_dist/2*n;
else
    p1.pos(1:2) = r1;
    p2.pos(1:2) = r2;
end
    

end

function isClose = closeTo(p1,p2,rad)

dist = sqrt((p1(1) - p2(1))^2 + (p1(2) - p2(2))^2);
isClose = dist < rad;

end
