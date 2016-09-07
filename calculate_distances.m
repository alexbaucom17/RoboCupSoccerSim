function D = calculate_distances(cfg,Pxy,Pa,Bxy,Txy)

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
D.behindball = 0;

%distance from goaline
D.goalline = 0;


end

