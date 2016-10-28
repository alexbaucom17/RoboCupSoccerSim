function [p,b,w] = AnimateGame(p,b,w,fig,ax,stats_handles,stats,cfg)
%ANIMATEGAME Handles drawing and animation of game simulation

for i = 1:cfg.num_players
    p{i} = p{i}.draw_player(ax);
    
    if cfg.debug
        p{i} = p{i}.draw_player_hitbox(ax,cfg);
    end
end

b = b.draw_ball(ax);

w = w.draw_lines(ax);

%draw statistics text
if ~cfg.pff_testing
    str = sprintf('Elapsed time: %4.2f s',stats.timeelapsed); 
    set(stats_handles.elapsed_time,'String',str)  
    str = sprintf('Game time: %4.2f s ',stats.gametime); 
    set(stats_handles.game_time,'String',str)
    str = sprintf('Game speed: %4.2f x ',stats.speed); 
    set(stats_handles.game_speed,'String',str)
    str = sprintf('FPS: %4.1f ',stats.fps); 
    set(stats_handles.fps,'String',str)
    str = sprintf('%i       %i ',stats.score(1),stats.score(2)); 
    set(stats_handles.score2,'String',str)
end

%force drawing update
drawnow

end
