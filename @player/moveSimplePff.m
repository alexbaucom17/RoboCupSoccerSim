function [ obj, nearPos, nearAng ] = moveSimplePff( obj,world,ball_global )
%MOVESIMPLEPFF Generate simple position and generate velocity using
%potential field function

obj.pos_des = posSimple(obj,world,ball_global);
[obj.vel_des, nearPos, nearAng] = velPff(obj,world);

end

