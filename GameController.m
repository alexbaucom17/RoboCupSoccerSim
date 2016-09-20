%Game Controller Script
%runs game at high level

%% Initialization
close all
clear
rng('shuffle')

%set up configuration variables
addpath game pff
Config();

%set up world
w = world(cfg);

%set up potential field functions
pff_funcs = create_pff_funcs(cfg,cfg.use_static_functions);

%set up players
p = cell(cfg.num_players,1);
for i = 1:cfg.num_players
    if i <= cfg.num_players_red
        color = 'red';
        num = i;
        teammates = cfg.num_players_red-1;
        pos = cfg.start_pos(num,:);
    else
        color = 'blue';
        num = i-cfg.num_players_red;
        teammates = cfg.num_players_blue-1;
        pos = cfg.start_pos(num+5,:);
    end
    p{i} = player(color,pos,num,teammates,cfg,pff_funcs);
end

%set up ball
b = ball([0,0],cfg);

%set up field
if cfg.drawgame
    [fig, stats_handles, ax]= ShowField(cfg);
else
    fig = -1;
end

%% Main Execution Loop
t=tic;
t_draw = 0;
stats.gametime = 0;
stats.num_updates = 0;
if cfg.record_movie
    writerObj = VideoWriter('out.avi'); % Name it.
    writerObj.FrameRate = 60; % How many frames per second.
    open(writerObj);
end

while (ishandle(fig) && stats.gametime<=cfg.halflength) || (~cfg.drawgame && stats.gametime<=cfg.halflength)
     
    %check for goals, out of bounds, and player leaving field
    [p,b,w] = CheckWorld(p,b,w,cfg);
    
    %update current state of world
    w = update(w,p,b);
    
    %run player updates
    for i = 1:cfg.num_players 
        p{i} = update(p{i},w);
    end
    
    %update ball
    b = update(b);
    
    %update collisions
    [p,b] = HandleCollisions(p,b,cfg);   
    
    %update team scoring system
    score = ScoreGame(w,cfg);
    
    %statistics calculations
    stats.timeelapsed = toc(t);
    stats.gametime = p{1}.gametime;
    stats.speed = stats.gametime/stats.timeelapsed;
    stats.fps = stats.num_updates/stats.timeelapsed;
    stats.num_updates = stats.num_updates + 1;
    stats.score = [w.red_score,w.blue_score];
    
    %drawing update - only update at specified interval   
    if cfg.drawgame && (stats.gametime - t_draw) > cfg.drawgame_time
        t_draw = stats.gametime;
        [p,b,w] = AnimateGame(p,b,w,fig,ax,stats_handles,stats,cfg);        
    end
    
    %record movie frames
    if cfg.record_movie
        frame = getframe(gcf);
        writeVideo(writerObj, frame);
    end
    
end

disp(stats)
disp(score)
if cfg.record_movie
   close(writerObj); % Saves the movie.
end
    




