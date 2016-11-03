classdef world
    %WORLD world class which holds info about everything going on in the
    %game
    
    properties
        red_score %score for the red team
        blue_score %score for the blue team
        world_exact %struct with 'exact' information about the world
        world_random %struct with randomized variations of exact world info
        num_oob %keeps track of how many out of bounds by each team
        own_goals %tracks number of own goals by each team
        num_kicks %tracks number of kicks for each team
    end
    
    properties (Access = protected)     
       cfg %local copy of configuration variable
       pIDred %id numbers for rerd team
       pIDblue %id numbers for blue team
       redGoal %location of center of red goal [x,y]
       blueGoal %location of center of blue goal [x,y]
       line_handles %object handles to lines that are drawn to show players seeing the ball
       roles %list of roles for each player
    end
    
    methods
        
        %constructor which assigns information based on configuration
        %variable
        function obj = world(cfg)
            obj.red_score = 0;
            obj.blue_score = 0;
            obj.cfg = cfg;
            obj.pIDred = 1:obj.cfg.num_players_red;
            obj.pIDblue = (obj.cfg.num_players_red+1):obj.cfg.num_players;
            obj.world_exact.posArray = zeros(obj.cfg.num_players,2);
            obj.redGoal = [obj.cfg.goal_posts(3,1),0];
            obj.blueGoal = [obj.cfg.goal_posts(1,1),0];
            obj.world_random.seeball = zeros(obj.cfg.num_players,1);
            obj.world_exact.seeball = ones(obj.cfg.num_players,1);
            obj.line_handles = [];
            obj.roles = [obj.cfg.start_roles_red(1:obj.cfg.num_players_red) obj.cfg.start_roles_blue(1:obj.cfg.num_players_blue)]';
            obj.num_oob = [0,0];
            obj.own_goals = [0,0];
            obj.num_kicks = [0,0];
        end
        
        %update function for the world
        %this collects information from all the players and the ball and
        %centralizes it for distributing to players as 'observations'
        function obj = update(obj,p,b)
            
            %figure out who can see the ball
            a2ball = zeros(obj.cfg.num_players,1);
            d2ball = zeros(obj.cfg.num_players,1);
            for i = 1:obj.cfg.num_players
                
                %compute angle/dist to ball
                b2p = b.pos - p{i}.pos(1:2);
                a2ball(i) = atan2(b2p(2),b2p(1));
                d2ball(i) = norm(b2p);
                
                %see which players match angle to see ball
                %there is a chance the ball won't be seen
                if abs(a2ball(i) - p{i}.pos(3)) < obj.cfg.world_seeBallFOV/2
                    if obj.world_random.seeball(i) == 1
                        obj.world_random.seeball(i) = (rand*d2ball(i)/2) < obj.cfg.world_seeBallContRate;
                    else                        
                        obj.world_random.seeball(i) = (rand*d2ball(i)/2) < obj.cfg.world_seeBallNewRate;
                    end
                else
                    obj.world_random.seeball(i) = 0;
                end
            end
                     
            %update current player information
            %with exact and noisy values
            for i = 1:obj.cfg.num_players
                
                %exact values
                obj.world_exact.players(i).number = p{i}.player_number;
                obj.world_exact.players(i).pos = p{i}.pos;
                obj.world_exact.players(i).vel = p{i}.get_vel();
                obj.world_exact.players(i).role = obj.roles(i);
                obj.world_exact.players(i).ball_local = b.pos - p{i}.pos(1:2);
                obj.world_exact.posArray(i,1:2) = p{i}.pos(1:2);
                obj.world_exact.angles(i) = p{i}.pos(3);
                
                %generate noise
                pos_noise = randn(1,2);
                pos_noise = obj.cfg.world_posErr * randn * pos_noise/norm(pos_noise);
                ang_noise = obj.cfg.world_angErr * randn;
                ball_noise = randn(1,2);
                ball_noise_dir = randn * ball_noise/norm(ball_noise);
                ball_local_err = obj.cfg.world_ball_local_err*norm(obj.world_exact.players(i).ball_local) * ball_noise_dir;
                
                %add noise
                obj.world_random.players(i).number = p{i}.player_number;
                obj.world_random.players(i).role = obj.roles(i);                
                obj.world_random.players(i).pos = p{i}.pos + [pos_noise, ang_noise];
                obj.world_random.players(i).vel = p{i}.get_vel();
                obj.world_random.posArray(i,1:2) = obj.world_random.players(i).pos(1:2);
                obj.world_random.angles(i) = obj.world_random.players(i).pos(3);
                
                %only get local ball info if player can see it
                if obj.world_random.seeball(i) == 1
                    obj.world_random.players(i).ball_local = obj.world_exact.players(i).ball_local + ball_local_err;
                else
                    obj.world_random.players(i).ball_local = [];
                end
                
            end
                        
            %grab team data
            obj.world_exact.redTeam = obj.world_exact.players(obj.pIDred);
            obj.world_exact.blueTeam = obj.world_exact.players(obj.pIDblue);            
            obj.world_random.redTeam = obj.world_random.players(obj.pIDred);
            obj.world_random.blueTeam = obj.world_random.players(obj.pIDblue);
            
            %update teamball info (for use if local ball isn't available)
            obj.world_exact.teamball.pos = b.pos;
            obj.world_exact.teamball.vel = b.vel;
            pos_noise = randn(1,2);
            pos_noise = obj.cfg.world_teamballErr * randn * pos_noise/norm(pos_noise);
            obj.world_random.teamball.pos = b.pos+pos_noise;
            
            %update roles (won't be sent to players until next update)
            obj = switch_roles(obj);

        end

        %function to get id of attacking players 
        function ids = get_attacker_ids(obj)
             ids = find(obj.roles == player.ATTACKER);
        end
        
        %Get an exact observation of the current world state
        %
        %clr - observing player color
        %num - observing player number
        %world_info has the following fields
        %   goal_attack - global position of attacking goal [x,y]
        %   goal_defend - global position of defending goal [x,y]
        %   cur_player - info about the current player
        %       number - player number
        %       pos - player global position [x,y,a]
        %       vel - player local velocity [x,y,a]
        %       role - player role
        %       ball_local - local ball location (empty if not seen) [x,y]
        %   myTeam - info about current team. Same fields as cur_player,
        %       but for all team members
        %   opTeam - info about opposing team. Same fields as cur_player,
        %       but for all enemy team members
        %   teamball - info about team ball
        %       pos - global position of ball
        %       vel - global velocity of ball
        %   attackerID - id of attacker for use in behavior (for speed)
        function world_info = get_world_exact(obj,clr,num)
            
            %find attackers
            attackerIDs = obj.get_attacker_ids();
            
            %get proper goals
            if strcmp(clr,'red')
                goal_attack = obj.blueGoal;
                goal_defend = obj.redGoal;
                cur_player = obj.world_exact.redTeam(num);
                world_info.myTeam = obj.world_exact.redTeam;
                world_info.opTeam = obj.world_exact.blueTeam;
                world_info.attackerID = attackerIDs(1);                
            else
                goal_attack = obj.redGoal;
                goal_defend = obj.blueGoal;
                cur_player = obj.world_exact.blueTeam(num);
                world_info.myTeam = obj.world_exact.blueTeam;
                world_info.opTeam = obj.world_exact.redTeam;
                world_info.attackerID = attackerIDs(2) - obj.cfg.num_players_red;
            end   

            %add current player info for easy access
            world_info.cur_player = cur_player;
            
            %other info
            world_info.goal_attack = goal_attack;
            world_info.goal_defend = goal_defend; 
            world_info.teamball = obj.world_exact.teamball;
        end
        
        
        %Get an stocastic observation of the current world state
        %
        %clr - observing player color
        %num - observing player number
        %world_info has the following fields
        %   goal_attack - global position of attacking goal [x,y]
        %   goal_defend - global position of defending goal [x,y]
        %   cur_player - info about the current player
        %       number - player number
        %       pos - player global position [x,y,a]
        %       vel - player local velocity [x,y,a]
        %       role - player role
        %       ball_local - local ball location (empty if not seen) [x,y]
        %   myTeam - info about current team. same fields as cur_player,
        %       but for all team members
        %   teamball - info about team ball (if somebody on team sees ball)
        %       pos - global position of ball
        %   attackerID - id of attacker for use in behavior (for speed)
        function world_info = get_world_random(obj,clr,num)
               
            %find attackers
            attackerIDs = obj.get_attacker_ids();
            
             %get proper goals + team specific info
            if strcmp(clr,'red')
                goal_attack = obj.blueGoal;
                goal_defend = obj.redGoal;
                cur_player = obj.world_random.redTeam(num);
                world_info.myTeam = obj.world_random.redTeam;
                if any(obj.world_random.seeball(obj.pIDred))
                    world_info.teamball = obj.world_random.teamball;
                else
                    world_info.teamball = [];
                end
                world_info.attackerID = attackerIDs(1);
            else
                goal_attack = obj.redGoal;
                goal_defend = obj.blueGoal;
                cur_player = obj.world_random.blueTeam(num);
                world_info.myTeam = obj.world_random.blueTeam;
                world_info.seeball(obj.pIDred) = 0;
                if any(obj.world_random.seeball(obj.pIDblue))
                    world_info.teamball = obj.world_random.teamball;
                else
                    world_info.teamball = [];
                end
                world_info.attackerID = attackerIDs(2) - obj.cfg.num_players_red;
            end   

            %add current player info for easy access
            world_info.cur_player = cur_player;
            
            %other info
            world_info.goal_attack = goal_attack;
            world_info.goal_defend = goal_defend;    
            
        end
        
        
        %draw vision lines from player to ball if they see the ball
        %ax - current axes
        function obj = draw_lines(obj,ax)
            
            seesBall = find(obj.world_random.seeball);
            bpos = obj.world_exact.teamball.pos;
            delete(obj.line_handles);
            obj.line_handles = [];
            for i = 1:length(seesBall)
                idx = seesBall(i);
                ppos = obj.world_exact.players(idx).pos(1:2);
                X = [bpos(1), ppos(1)];
                Y = [bpos(2), ppos(2)];
                obj.line_handles(idx) = line(ax,X,Y,'LineStyle','--','Color','m');
            end            
        end
        
        %function to centralize role switching
        %but runs basically the same code each robot would normally run
        %individually, it just doesn't make sense to run it 5 times
        %returns array of roles where each entry matches the player in the
        %player list
        function obj = switch_roles(obj)

            %get the right world information
            if obj.cfg.world_random_on
                world_info = obj.world_random;
            else
                world_info = obj.world_exact;
            end

            %build array of goals for easy calculations
            defending_goals = [repmat(obj.redGoal,obj.cfg.num_players_red,1);
                               repmat(obj.blueGoal,obj.cfg.num_players_blue,1)];
            attacking_goals = [repmat(obj.blueGoal,obj.cfg.num_players_red,1);
                               repmat(obj.redGoal,obj.cfg.num_players_blue,1)];
            %distance to defensive goal
            d_goal = sqrt(sum((world_info.posArray - defending_goals).^2,2));
            %distance to ball
            d_ball_xy = repmat(world_info.teamball.pos,obj.cfg.num_players,1) -  world_info.posArray;
            d_ball = sqrt(sum(d_ball_xy.^2,2));
            %angle to ball
            a_ball = atan2(d_ball_xy(:,2),d_ball_xy(:,1));
            da_ball = a_ball - world_info.angles';
            idx = abs(da_ball) > pi;
            da_ball(idx) = 2*pi-abs(da_ball(idx));
            %angle to attacking goal
            xy_goal_att = attacking_goals - world_info.posArray;
            da_goal = atan2(xy_goal_att(:,2),xy_goal_att(:,1)) - a_ball;
            idx = abs(da_goal) > pi;
            da_goal(idx) = 2*pi-abs(da_goal(idx));
            
            
            %ETA = time to reach ball, time to turn towards ball, time to
            %turn towards goal
            eta = d_ball/obj.cfg.player_MaxLinVelX(1) + ...
                  abs(da_ball)/obj.cfg.player_MaxAngVel + ...
                  abs(da_goal)/obj.cfg.player_MaxAngVel;
            def = d_goal;

            %add any penalties
            non_attacker_idx = obj.roles ~= player.ATTACKER; 
            eta(non_attacker_idx) = eta(non_attacker_idx) + obj.cfg.nonAttackerPenalty/obj.cfg.player_MaxLinVelX(1);
            non_defender_idx = (obj.roles ~= player.DEFENDER) | (obj.roles ~= player.DEFENDER2);
            def(non_defender_idx) = def(non_defender_idx) + obj.cfg.nonDefenderPenalty;

            %sort vectors
            [~, eta_idx1] = sort(eta(obj.pIDred));
            [~, def_idx1] = sort(def(obj.pIDred));
            [~, eta_idx2] = sort(eta(obj.pIDblue));
            [~, def_idx2] = sort(def(obj.pIDblue));

            for i = 1:2

                %get correct info for the team
                if i == 1
                    eta_idx = eta_idx1;
                    def_idx = def_idx1;
                    role_idx = obj.pIDred;
                    cur_roles = -ones(obj.cfg.num_players_red,1);
                else
                    eta_idx = eta_idx2;
                    def_idx = def_idx2;
                    role_idx = obj.pIDblue;
                    cur_roles = -ones(obj.cfg.num_players_blue,1);
                end

                %skip role swithcing if team doesn't see ball
                if ~any(world_info.seeball(role_idx))
                    continue
                end

                %remove goalie number from lists and force it to remain
                %player 1 is always goalie as default
                if ~obj.cfg.force_initial_roles
                    eta_idx(eta_idx == 1) = [];
                    def_idx(def_idx == 1) = [];
                    cur_roles(1) = player.GOALIE;
                else
                    %check to see if this game has goalies
                    goalie_id = find(obj.roles(role_idx) == player.GOALIE);
                    if any(goalie_id)
                        eta_idx(eta_idx==goalie_id) = [];
                        def_idx(def_idx==goalie_id) = [];
                        cur_roles(goalie_id) = player.GOALIE;
                    end
                end
                

                %get number if roles to assign
                n = length(eta_idx);

                %closest to ball is attacker
                if n >= 1
                    cur_roles(eta_idx(1)) = player.ATTACKER;
                    %remove attacker id to avoid double assignment
                    def_idx(def_idx == eta_idx(1)) = [];
                    eta_idx(1) = [];
                end

                if n >= 2
                    %closest to goal is defender unless it is the attacker
                    cur_roles(def_idx(1)) = player.DEFENDER;
                    %remove defender id to avoid double assignment
                    eta_idx(eta_idx == def_idx(1)) = [];
                end

                %second closest to ball is supporter
                if n >= 3
                    cur_roles(eta_idx(1)) = player.SUPPORTER;
                end

                %remaining player is defender2
                if n >= 4
                    cur_roles(cur_roles == -1) = player.DEFENDER2;
                end

                %put these roles into world object role list
                obj.roles(role_idx) = cur_roles;
                
            end %end for
            
        end %end function switch roles
 
    end %end methods block
            
end

