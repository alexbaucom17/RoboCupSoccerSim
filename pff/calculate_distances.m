function [dball,dshotpath,dshotpathDef,dgoalAtt,dgoalDef,dbehindball,dsideline,dteammate] ...
                = calculate_distances(cfg,Pxy,Pa,Bxy,Txy,dir)

%distance to boundaries
xb = cfg.field_length_max;
yb = cfg.field_width_max;
dsideline = abs([xb-Pxy(:,1), -xb-Pxy(:,1), yb-Pxy(:,2),-yb-Pxy(:,2)]);

%distance to ball
dball = sqrt(sum((repmat(Bxy,size(Pxy,1),1) - Pxy).^2,2));

%distance to teammates
n = size(Txy,1);
Txy = repmat(permute(Txy,[3,2,1]),size(Pxy,1),1,1);
dxyteam = Txy-repmat(Pxy,1,1,n);
Dteam = sqrt(sum(dxyteam.^2,2));
dteammate = permute(Dteam,[1,3,2]);

%distance to attacking shot path
goal_attack = [dir*cfg.goal_posts(1),0];
dshotpath = point_to_line(Pxy,Bxy,goal_attack); 

%distance to defending shot path
goal_def = -goal_attack;
dshotpathDef = point_to_line(Pxy,Bxy,goal_def); 

%distance to goals
dgoalAtt = abs(goal_attack(1) - Pxy(:,1));
dgoalDef = abs(Pxy(:,1) - goal_def(1));

%interaction terms to force behind ball
d1 = -dir*(repmat(Bxy(1),size(Pxy,1),1) - Pxy(:,1)-0.05);
dbehindball = max(d1 * 1./(dshotpath+1), 0.001*ones(size(d1)));


end


function d = point_to_line(pt, v1, v2)
      n = size(pt,1);
      a = repmat([v1 - v2,0],n,1);
      b = [pt - repmat(v2,n,1), zeros(n,1)];
      d = sqrt(sum(cross(a,b,2).^2,2)) / norm(a(1,:));
end

