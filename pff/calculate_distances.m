function D = calculate_distances(cfg,Pxy,Pa,Bxy,Txy,dir)

%distance to boundaries
xb = cfg.field_length_max;
yb = cfg.field_width_max;
D.boundaries = abs([xb-Pxy(1), -xb-Pxy(1), yb-Pxy(2),-yb-Pxy(2)]);

%distance to ball
D.ball = norm(Bxy - Pxy);

%distance to teammates
n = size(Txy,1);
dxyteam = Txy - repmat(Pxy,n,1);
D.team = sqrt(sum(dxyteam.^2,2));

%distance behind ball
D.behindball = dir*(Bxy(1) - Pxy(1));

%distance from goaline - calulcation looks weird but it is correct
D.goalline = abs(dir*cfg.field_length + Pxy(1));

%distance to attacking shot path
goal_attack = [dir*cfg.goal_posts(1),0];
D.shotpath = point_to_line(Pxy,Bxy,goal_attack); 

%distance to defending shot path
goal_def = -goal_attack;
D.shotpath_def = point_to_line(Pxy,Bxy,goal_def); 



end


function d = point_to_line(pt, v1, v2)
      a = [v1 - v2,0];
      b = [pt - v2,0];
      d = norm(cross(a,b)) / norm(a);
end

