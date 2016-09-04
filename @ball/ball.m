classdef ball
    %BALL Soccer ball simulation object
    
    properties
        pos %ball position [x,y]
        vel %ball velocity [x,y]
        prev_touch %previous color to touch the ball
        kick_loc %previous location the ball was touched
    end
    
    properties (Access = protected)
        prev_time %previous simulation time
        realtime %if simulation is realtime
        timestep %simulation timestep
        radius %ball radius
        draw_handle %ball drawing handle
        friction %ball friction deceleration
        cfg %local configuration variable
    end
    
    methods
        
        %initialize ball
        function obj = ball(ipos,cfg)
            obj.pos = ipos;
            obj.vel = [0,0]; 
            obj.prev_time = tic;
            obj.realtime = cfg.realtime;
            obj.timestep = cfg.timestep;
            obj.radius = cfg.ball_radius;
            obj.draw_handle = [];
            obj.friction = cfg.ball_friction; 
            obj.cfg = cfg;
            obj.prev_touch = [];
            obj.kick_loc = [];
        end
        
        %set ball velocity
        function obj = set_vel(obj,vel)
            obj.vel = vel;
        end
        
        %update ball position
        function obj = update(obj)
            
            if obj.realtime
                
                %get dt since last update
                dt = toc(obj.prev_time);
                obj.prev_time = tic;
                
            else
                %if we are not realtime, just use defualt timestep
                dt = obj.timestep;
            end
            
            %velocity decay from friciton
            if norm(obj.vel) ~= 0
                dv = obj.vel/norm(obj.vel)*obj.friction*dt;
                dvTooLarge = abs(dv)>abs(obj.vel);
                obj.vel = obj.vel - dv;
                vTooSmall = abs(obj.vel) < obj.cfg.MinBallVel;
                
                if any(vTooSmall)
                    obj.vel(vTooSmall) = 0;
                end
                if any(dvTooLarge)
                    obj.vel(dvTooLarge) = 0;
                end
            end            
            
            %update position based off of current velocity        
            dp = obj.vel*dt;
            obj.pos = obj.pos + dp;
        end
        
        %draw ball on given axes
        function obj = draw_ball(obj,ax)
            d = obj.radius*2;
            px = obj.pos(1) - obj.radius;
            py = obj.pos(2) - obj.radius;
            
            delete(obj.draw_handle);
            obj.draw_handle = rectangle(ax,'Position',[px py d d],...
                'Curvature',[1,1],'FaceColor','black','EdgeColor','none');            
        end
        
    end    
end

