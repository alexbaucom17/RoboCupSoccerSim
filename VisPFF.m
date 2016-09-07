function [] = VisPFF(p,b,w,cfg,num)
%VISPFF Visualize potential field function

%graph params
xmin = -cfg.field_length_max;
xmax = cfg.field_length_max;
ymin  = -cfg.field_width_max;
ymax = cfg.field_width_max;
step_size = 0.05;

%set up grid
[X,Y] = meshgrid(xmin:step_size:xmax,ymin:step_size:ymax);

%get info about players
ball_global = b.pos;
team_idx = (1:5) ~= num;
team_pos = reshape([w.world_exact.redTeam(team_idx).pos],3,[])';
team_pos = team_pos(:,1:2);

%set up function 
pff = p{num}.GenPFF();
fn = @(x,y) pff(calculate_distances(cfg,[x,y],0,ball_global,team_pos));

%run function for all x and y
Z = arrayfun(fn,X,Y);
figure
colormap('default')
imagesc(Z)
colorbar


end

