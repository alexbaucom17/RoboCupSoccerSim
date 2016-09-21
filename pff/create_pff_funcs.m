function [ fns ] = create_pff_funcs(cfg,static_flag)
%CREATE_PFF_FUNCS To be called once to generate all pff function handles
    %based off of Multi-Robot Dynamic Role Assignment by Vail and Veloso
    %flag arguement is to specify whether to use static functions or
    %annonymous functions
    
    
%%  Get static functions if requests

if nargin == 2 && static_flag == 1
    fns = get_static_functions(cfg);
    return
end


%% Individual potential field components

%boundary repulstion
Pwall = @(c1,k1,dwall) max([0,k1*(c1 - dwall)]);

%ball attraction
Pball = @(c2,k2,dball) k2*abs(c2 - dball);

%Teammate repulsion
Pteam = @(c3,k3,dteam) max([0,k3*(c3-dteam)]);

%forward bias for supporter
Pfwbias = @(k4,dbehind_ball) max([0,k4*dbehind_ball]);

%defense bias for defenders
Pdbias = @(k5,dgoalline) k5*dgoalline;

%attacker line up with shot path
Pshot = @(k6,dshotpath) k6*abs(dshotpath);

%attacker stay behind ball
Prevbias = @(k7,c7,d_behind_ball) max([0,c7-k7*d_behind_ball]); 

%supporter avoid shot path but stay close
Pshot_sup = @(k8,c8,dshotpath) k8*abs(c8-dshotpath);

%defender/goalie block shot path
Pdef_shot = @(k9,dshotpath_def) k9*abs(dshotpath_def);

%stay off to one side
Psidebias = @(k10,Ry,By) max([0,k10*Ry*By/cfg.field_width]); %not sure I like this function, might need to adjust


%% Put functions together

%make function for each role
for i = 1:5
    
    %grab weights for this role
    w = cfg.pff_weights(:,i);    
    
    fns{i} = @(D) Pwall(w(1),w(2),D.boundaries(1))+Pwall(w(1),w(2),D.boundaries(2))...
        +Pwall(w(1),w(2),D.boundaries(3))+Pwall(w(1),w(2),D.boundaries(4))...
        +Pball(w(3),w(4),D.ball)+sum(arrayfun(@(p) Pteam(w(5),w(6),p),D.team))...
        +Pfwbias(w(8),D.behindball)+Pdbias(w(7),D.goalline)+Pshot(w(9),D.shotpath)...
        +Prevbias(w(10),w(11),D.behindball)+Pshot_sup(w(12),w(13),D.shotpath)...
        +Pdef_shot(w(14),D.shotpath_def)+Psidebias(w(15),D.Ry,D.By);
    
end
    

end


function fns = get_static_functions(cfg)

if cfg.num_players_red ~= cfg.num_players_blue
    error('Number of players on each team must be equal to use static pff functions')
end

z = zeros(cfg.num_players_red-1,1);

%make function for each role
for i = 1:5
    
    %grab weights for this role
    w = cfg.pff_weights(:,i);    
    
    fns{i} = @(D)   max([0,w(2)*(w(1) - D.boundaries(1))])+...
                    max([0,w(2)*(w(1) - D.boundaries(2))])+...
                    max([0,w(2)*(w(1) - D.boundaries(3))])+...
                    max([0,w(2)*(w(1) - D.boundaries(4))])+...
                    w(4)*abs(w(3) - D.ball)+...
                    sum(max([z,w(6)*(w(5)-D.team)]))+...
                    w(7)*D.goalline; %+...
                    %max([0,w(8)*D.behindball])+...
                    %w(9)*D.shotpath+...
                    %max([0,w(11)-w(10)*D.behindball])+...
                    %w(12)*abs(w(13)-D.shotpath)+...
                    %w(14)*abs(D.shotpath_def)+...
                    %max([0,w(15)*D.Ry*D.By/cfg.field_width]);               
end


end

