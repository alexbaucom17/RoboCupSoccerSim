function [ p,b,w ] = CheckWorld(p,b,w,cfg)
%CHECKWORLD Checks for world events
%   Updates player and ball for scoring, out of bounds, and players leaving
%   field. Currently players are simply reset to sidelines without given timed
%   penalty, but timed penalty could be added later if needed


%% Check ball out of bounds or in goal

%bools to make out of bounds/net checks
oobX = false;
oobY = false;
goal = false;

%check ball out of bounds in X direciton
bpos = b.pos;
if abs(bpos(1)) + cfg.ball_radius > cfg.field_length
    oobX = true;
end
%check ball out of bounds in Y direciton
if abs(bpos(2)) + cfg.ball_radius > cfg.field_width
    oobY = true;
end
%check ball in net in Y direciton
if abs(bpos(2)) + cfg.ball_radius < cfg.goal_posts(2,2)
    goal = true;
end

%check which condition the ball is actuall in
%out of bounds in Y direction
if oobY

    %determine which team touched the ball last
    if strcmp(b.prev_touch,'red')
        dir = -1;
    else
        dir = 1;
    end
    
    %shift ball back 1 m from where it went out of bounds
    if dir*(bpos(1) - b.kick_loc(1)) < 0
        newpos = b.kick_loc(1) + dir;
    else
        newpos = bpos(1) + dir;
    end
    
    if abs(newpos) > cfg.oobLineX
        newpos = dir*cfg.oobLineX;
    end
    b.pos = [newpos, sign(bpos(2))*cfg.oobLineY];
    b.vel = [0,0];
    
%goal scored
elseif oobX && goal
    
    %blue goal
    if bpos(1) < 0
        w.blue_score = w.blue_score + 1;
        if strcmp(b.prev_touch,'red')
            w.own_goals(1) = w.own_goals(1) + 1;
        end
    %red goal    
    else
        w.red_score = w.red_score + 1;
        if strcmp(b.prev_touch,'blue')
            w.own_goals(2) = w.own_goals(2) + 1;
        end
    end
    
    %reset ball
    b.pos = [0,0];
    b.vel = [0,0];
    
%out of bounds in X direction
elseif oobX 
      
    %whose side did it go out on
    sideX = sign(bpos(1));
    %which side of goal did it go out on
    sideY = sign(bpos(2));
    
    %change placement based on who touched ball last
    if strcmp(b.prev_touch,'red')
        if sideX == 1
            b.pos = [0,sideY*cfg.oobLineY];
        else
            b.pos = [-cfg.oobLineX,sideY*cfg.oobLineY];
        end            
    else
         if sideX == -1
            b.pos = [0,sideY*cfg.oobLineY];
        else
            b.pos = [cfg.oobLineX,sideY*cfg.oobLineY];
        end   
    end
    b.vel = [0,0];

end


%% check player out of bounds

%allocate memory space
ppos = zeros(cfg.num_players,2);

%get all player positions
for i = 1:cfg.num_players
    ppos(i,:) = p{i}.pos(1:2);
end

%check players in X/Y direcitons
oobX = abs(ppos(:,1)) > cfg.field_length_max;
oobY = abs(ppos(:,2)) > cfg.field_width_max;
oob = oobX | oobY;
num_oob = [0,0];

%reset all players that went out of bounds
if sum(oob) > 0
    oob_idx = find(oob);
    for i = 1:sum(oob)
        cur_idx = oob_idx(i);
        p_cur = p{cur_idx};
        
        %figure out where player needs to be placed
        if strcmp(p_cur.team_color,'red')
            sideX = -1;
            num_oob(1) = num_oob(1) + 1;
        else
            sideX = 1;
            num_oob(2) = num_oob(2) + 1;
        end
        sideY = -sign(b.pos(2));
        ang = -sideY*pi/2;
        
        %reset pos and vel
        p{cur_idx}.pos = [sideX*cfg.penalty_corners(3,1),sideY*cfg.field_width,ang];
        p{cur_idx}.SetZeroVel();
    end
    w.num_oob = w.num_oob + num_oob;
end

end

