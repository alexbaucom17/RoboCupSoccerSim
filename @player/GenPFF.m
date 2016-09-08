function [ fn ] = GenPFF(obj)
%GenPFF Generate Potential Field Function
%  Generates potential field function for current player based on
%  configuration variables
%  Returns handle to funcition for local evaluation to do path planning

%creates pff functions for each role
if ~exist('obj.cfg.pff_funcs','var')
    obj.cfg.pff_funcs = create_pff_funcs(obj.cfg);
end

fn = obj.cfg.pff_funcs{obj.role+1};

end



function [ fns ] = create_pff_funcs(cfg)
%CREATE_PFF_FUNCS To be called once to generate all pff function handles
    %based off of Multi-Robot Dynamic Role Assignment by Vail and Veloso


%% Individual potential field components

%boundary repulstion
Pwall = @(c1,k1,dwall) max([0,c1 - k1*dwall]);

%ball attraction
Pball = @(c2,k2,dball) k2*abs(c2 - dball);

%Teammate repulsion
Pteam = @(c3,k3,dteam) max([0,c3-k3*dteam]);

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

%everyone face the ball

%goalie go to ball if close enough

%something to keep attacker off to side of ball if not behind it 


%% Put functions together

%make function for each role
for i = 1:5
    
    %grab weights for this role
    w = cfg.pff_weights(:,i);
    
    %update functions with proper weights
    Pwall2 = @(d) Pwall(w(1),w(2),d);
    Pball2 = @(d) Pball(w(3),w(4),d);
    Pteam2 = @(d) Pteam(w(5),w(6),d);
    Pfwbias2 = @(d) Pfwbias(w(7),d);
    Pdbias2 = @(d) Pdbias(w(8),d);
    Pshot2 = @(d) Pshot(w(9),d);
    Prevbias2 = @(d) Prevbias(w(10),w(11),d);
    Pshot_sup2 = @(d) Pshot_sup(w(12),w(13),d);
    Pdef_shot2 = @(d) Pdef_shot(w(14),d);
    Psidebias2 = @(Ry,By) Psidebias(w(15),Ry,By);
    
    %since there are multiple walls and teammates we need to use arrayfun
    %for these
    Pwall3 = @(d) sum(arrayfun(Pwall2,d));
    Pteam3 = @(d) sum(arrayfun(Pteam2,d));
    
    %put it all together
    fns{i} = @(D) Pwall3(D.boundaries)+Pball2(D.ball)+Pteam3(D.team) ...
             +Pfwbias2(D.behindball)+Pdbias2(D.goalline)+Pshot2(D.shotpath) ...
             +Prevbias2(D.behindball)+Pshot_sup2(D.shotpath)+Pdef_shot2(D.shotpath_def)...
             +Psidebias2(D.Ry,D.By);
end
    

end
