function [] = VisPFF(p,b,w,cfg,num,clr)
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
if strcmp(clr,'red')
    team_pos = reshape([w.world_exact.redTeam(team_idx).pos],3,[])';
    dir = 1;
else
    team_pos = reshape([w.world_exact.blueTeam(team_idx).pos],3,[])';
    dir = -1;
    num = num + cfg.num_players_red;
end
team_pos = team_pos(:,1:2);

%set up function 
pff = p{num}.GenPFF();
fn = @(x,y) pff(calculate_distances(cfg,[x,y],0,ball_global,team_pos,dir));

%run function for all x and y
Z = arrayfun(fn,X,Y);
figure
colormap('default')
imagesc(Z)
hold on
colorbar

[min1,idxY] = min(Z);
[val, idxX] = min(min1);
xval = X(1,idxX);
yval = Y(idxY(idxX),1);
fprintf('The min value is %4.1f at location %4.1f,%4.1f\n',val,xval,yval);


%do gradient descent to see path
real_start = p{num}.pos(1:2);
[~,map_start(1)] = min(abs(X(1,:) - real_start(1)));
[~,map_start(2)] = min(abs(Y(:,1) - real_start(2)));
[path,~] = gradient_descent(Z,map_start);

scatter(path(:,1),path(:,2),20,[1,0,0],'filled')


end


function [path,minval] = gradient_descent(costmap,start)
%GRADIENT_DESCENT do simple gradient descent to find minimum and path

%init
minval = Inf;
path = start;
mapsize = size(costmap);

%first pass
connections = [1,0; 1,1; 0,1; -1,1; -1,0; -1,-1; 0,-1; 1,-1];
check2D = repmat(start,8,1) + connections;
check1D = sub2ind(mapsize,check2D(:,2),check2D(:,1));
vals = costmap(check1D);

%check if there are still lower values
while any(vals < minval)
    
    %find best node
    [minval,idx] = min(vals);
    new_node = check2D(idx,:);
    path = [path; new_node];
    
    %do checks of new node
    check2D = repmat(new_node,8,1) + connections;
    check1D = sub2ind(mapsize,check2D(:,2),check2D(:,1));
    vals = costmap(check1D);
end

end