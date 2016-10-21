function [ obj,nearPos, nearAng ] = moveSimple( obj,world,ball_global )
%MOVESIMPLE Summary of this function goes here
%   Detailed explanation goes here

obj.pos_des = posSimple(obj,world,ball_global);
[obj.vel_des, nearPos, nearAng] = velSimple(obj,world);

end

