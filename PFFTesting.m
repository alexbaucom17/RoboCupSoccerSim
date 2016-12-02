%Test script for visualizing and testing potential fields

%% Initialization
close all
clear

%set up configuration variables
addpath game pff
cfg = Config();

%override some configurations for potential field testing
cfg.start_pos(2,:) = [-1,0.5,0];      %red attacker
cfg.start_pos(3,:) = [-2.5,1,0];     %red defender
cfg.start_pos(4,:) = [-1,-0.2,0];      %red supporter
cfg.start_pos(5,:) = [-2.5,-1,0];   %red defender2
cfg.start_pos(1,:) = [-4,0,0];    %red goalie
cfg.start_pos(7,:) = [0.5,0.5,pi];      %blue attacker
cfg.start_pos(8,:) = [3,1,pi];      %blue defender
cfg.start_pos(9,:) = [1,0,pi];     %blue supporter
cfg.start_pos(10,:) = [3,-1,pi];  %blue defender2
cfg.start_pos(6,:) = [4,0,pi];    %blue goalie
cfg.debug = true;
cfg.ball_start = [0,0];
cfg.pff_testing = true;
cfg.num_players_red = 5;
cfg.num_players_blue = 5;
cfg.num_players = cfg.num_players_red + cfg.num_players_blue;

bh_list =  cat(1,repmat({@movePff},cfg.num_players_red,1),...
             repmat({@movePff},cfg.num_players_blue,1));

%set up world
w = world(cfg);

%set up potential field functions
pff_funcs = pff_funcs_symGeneral(cfg);

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
b = ball(cfg.ball_start,cfg);

%set up field
[fig, stats_handles, ax]= ShowField(cfg);
stats = 0;
hold on


%% Main Visualization

%check for goals, out of bounds, and player leaving field
[p,b,w] = CheckWorld(p,b,w,cfg);

%update current state of world
w = update(w,p,b);

%run player updates
for i = 1:cfg.num_players 
    p{i} = p{i}.update(w);
end

%update ball
b = update(b);

%update collisions
[p,b] = HandleCollisions(p,b,cfg);   

%pff visualization
num = 1; %player to visualize
clr = 'red';
VisPFF(p,b,w,cfg,num,clr,ax);

%drawing update
[p,b,w] = AnimateGame(p,b,w,fig,ax,stats_handles,stats,cfg); 
hold off

    




