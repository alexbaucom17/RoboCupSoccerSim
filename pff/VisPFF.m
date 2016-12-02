function [] = VisPFF(p,b,w,cfg,num,clr,ax)
%VISPFF Visualize potential field function

%graph params
xmin = -cfg.field_length_max;
xmax = cfg.field_length_max;
ymin  = -cfg.field_width_max;
ymax = cfg.field_width_max;
step_size = 0.1;

%set up grid
[X,Y] = meshgrid(xmin:step_size:xmax,ymin:step_size:ymax);

%get info about players
ball_global = b.pos;
if strcmp(clr,'red')
    team_idx = (1:cfg.num_players_red) ~= num;
    team_pos = reshape([w.world_exact.redTeam(team_idx).pos],3,[])';
    dir = 1;
else
    team_idx = (1:cfg.num_players_blue) ~= num;
    team_pos = reshape([w.world_exact.blueTeam(team_idx).pos],3,[])';
    dir = -1;
    num = num + cfg.num_players_red;
end
team_pos = team_pos(:,1:2);

%set up function 
% pff = p{num}.pffs{p{num}.role+1};
% fn = @(x,y) pff(calculate_distances(cfg,[x,y],0,ball_global,team_pos,dir));
% Z = arrayfun(fn,X,Y);

%symbolic pffs
pff = p{num}.pffs; %{p{num}.role+1};
weights = cfg.pff_weights(:,p{num}.role+1);
x = reshape(X,[],1);
y = reshape(Y,[],1);
[dball,dshotpath,dshotpathDef,dgoalAtt,dgoalDef,dbehindball,dsideline,dteammate] ...
                = calculate_distances(cfg,[x,y],0,ball_global,team_pos,dir);
z = pff(dball,dshotpath,dshotpathDef,dgoalAtt,dgoalDef,dbehindball,dsideline,dteammate,weights);
Z = reshape(z,size(X));


colormap('default')
contourf(ax,X,Y,Z,150)
hold on

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
pathX = X(1,path(:,1));
pathY = Y(path(:,2),1);

scatter(ax,pathX,pathY,20,[1,0,0],'filled')
hold off


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
