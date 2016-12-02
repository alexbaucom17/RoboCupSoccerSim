function [stats,score] = GameController(C,bh_list,r_seed,weights)

%so every match with the same parameters will be the same
clear ScoreGame

%set random seed
if nargin > 2
    rng(r_seed,'twister')
else
    rng('default')
end

%handle inputs
if isprop(C,'Value')
    cfg = C.Value;
else
    cfg = C;
end


%override defualt weights if needed
if nargin > 3
    cfg.pff_weights = weights;
end

%set up world
w = world(cfg);

%set up potential field functions
pff_funcs = @pffGeneral; %pff_funcs_symGeneral(cfg);

%set up players
p = cell(cfg.num_players,1);
for i = 1:cfg.num_players
    if i <= cfg.num_players_red
        color = 'red';
        num = i;
        teammates = cfg.num_players_red-1;
        pos = cfg.start_pos(num,:);
        bh = bh_list(1:cfg.num_players_red);
    else
        color = 'blue';
        num = i-cfg.num_players_red;
        teammates = cfg.num_players_blue-1;
        pos = cfg.start_pos(num+5,:);
        bh = bh_list(cfg.num_players_red+1:end);
    end
    p{i} = player(color,pos,num,teammates,cfg,pff_funcs,bh);
end

%set up ball
b = ball([0,0],cfg);

%set up field
if cfg.drawgame
    [fig, stats_handles, ax]= ShowField(cfg);
else
    fig = -1;
end

if cfg.record_movie
    V = VideoWriter('SoccerSimulation.mp4','MPEG-4');
    open(V);
end


%% Main Execution Loop
t=tic;
t_draw = 0;
stats.gametime = 0;
stats.num_updates = 0;

while (ishandle(fig) && stats.gametime<=cfg.halflength) || (~cfg.drawgame && stats.gametime<=cfg.halflength)
     
    %check for goals, out of bounds, and player leaving field
    [p,b,w] = CheckWorld(p,b,w,cfg);
    
    %update current state of world
    w = w.update(p,b);
    
    %run player updates
    for i = 1:cfg.num_players 
        p{i} = p{i}.update(w);
    end
    
    %update ball
    b = b.update();
    
    %update collisions
    [p,b,w] = HandleCollisions(p,b,cfg,w);  
    
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
    
    if cfg.record_movie
        frame = getframe;
        writeVideo(V,frame);
    end
    
end

if cfg.record_movie
    close(V);
end


end



