function [ fns ] = pff_funcs_sym( cfg )
%PFF_FUNCS_SYM Summary of this function goes here
%   Detailed explanation goes here

%set up pff variable names
syms dball dshotpath dshotpathDef dgoalAtt dgoalDef dbehindball
dsideline = sym('dside',[1,4]);
dteammate = sym('dmate',[1,cfg.num_players_red-1]);
if isempty(dteammate)
    dteammate = sym('dmate',[1,1]);
    no_team = true;
else
    no_team = false;
end
dist_names = {dball dshotpath dshotpathDef dgoalAtt dgoalDef dbehindball dsideline dteammate};

%set up basic attracitve and repulsive functions
syms gain offset rang d
Uatt = (heaviside(d)-heaviside(d-rang))*1/2*gain*(d-offset)^2;
Urep = (heaviside(d)-heaviside(d-rang))*1/2*gain*(1/(d-offset)-1/rang)^2;

%figure out how many functions we need to generate for each player
%division by 3 since each function has 3 parameters
num_funcs = size(cfg.pff_weights,1)/3;
num_players = size(cfg.pff_weights,2);

%filenames
fnames = {'pff/pffGoalie','pff/pffAttacker','pff/pffDefender','pff/pffSupporter','pff/pffDefender2'};

%generate functions for each player
for i = 1:num_players
    
    %get weights for this player
    wList = cfg.pff_weights(:,i);
    f_total = sym(0);
    
    %loop through each function
    for j = 1:num_funcs
        
        %get weights and distance name for this function
        w = wList(3*j-2:3*j);
        dname = dist_names{j};
        
        %set up loop enviorment to be able to reuse weights for teammates
        %or sideline pff
        if strcmp(char(dname(1)),'dside1')
            loop = 4;
        elseif strcmp(char(dname(1)),'dmate1')
            loop = length(dname);
            if no_team
                w = [0,0,0];
            end
        else
            loop = 1;
        end
           
        %loop as many times as needed to use these weights
        for k = 1:loop
        
            %decide if this function is attracive or repulsive
            %pff_fun_desc has 1 for attractive and 0 for repulsive
            %substitue weights into function
            if cfg.pff_fun_desc(j)
                f = subs(Uatt,[rang,offset,gain,d],[w(1),w(2),w(3),dname(k)]);
            else
                %ignore this function if the range is 0 by setting gain to 0
                if w(1) == 0
                    f = subs(Urep,[rang,offset,gain],[1,0,0]);
                else
                    f = subs(Urep,[rang,offset,gain,d],[w(1),w(2),w(3),dname(k)]);
                end
            end

            %add this function to total function
            f_total = f_total+f;
        end
    end
    
    %create file and give function handle
    fns{i} = matlabFunction(f_total,'Vars',dist_names); %,'File',fnames{i});

end



end

