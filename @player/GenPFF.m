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
Pwall = @(c1,k1,d) max([0,c1 - k1*d]); %where d is distance to boundary

%ball attraction
Pball = @(c2,k2,dball) 1/k2*abs(c2 - dball);

%Teammate repulsion
Pteam = @(c3,k3,dteam) max([0,c3-k3*dteam]);

%Forward bias
Pfwbias = @(k4,d_behind_ball) max([0,k4*d_behind_ball]);

%defense bias
Pdbias = @(k5,dgoalie) k5*dgoalie;


%% Put functions together

%make function for each role
for i = 1:5
    
    %grab weights for this role
    w = cfg.pff_weights(i,:);
    
    %update functions with proper weights
    Pwall2 = @(d) Pwall(w(1),w(2),d);
    Pball2 = @(d) Pball(w(3),w(4),d);
    Pteam2 = @(d) Pteam(w(5),w(6),d);
    Pfwbias2 = @(d) Pfwbias(w(6),d);
    Pdbias2 = @(d) Pdbias(w(7),d);
    
    %since there are multiple walls and teammates we need to use arrayfun
    %for these
    Pwall3 = @(d) sum(arrayfun(Pwall2,d));
    Pteam3 = @(d) sum(arrayfun(Pteam2,d));
    
    %put it all together
    fns{i} = @(D) Pwall3(D.boundaries) + Pball2(D.ball) + Pteam3(D.team) ...
                + Pfwbias2(D.behindball) + Pdbias2(D.goalline); 
end
    

end
