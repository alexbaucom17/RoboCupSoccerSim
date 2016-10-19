function [ obj,nearPos, nearAng ] = moveSimple( obj,world,ball_global )
%MOVESIMPLE Run simple movement calculations

obj.pos_des = posSimple(obj,world,ball_global);
[obj.vel_des, nearPos, nearAng] = velSimple(obj,world);

end

