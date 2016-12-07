function [ Velocity ] = find_velocity(Speed, Direction, Centerlines, image_size)
%UNTITLED Summary of this function goes here
    
    direction_vector = [Speed.*-cosd(Direction); Speed.*sind(Direction)];
    head_vector = reshape(Centerlines(1,:,:),2,[]) - (image_size/2);    
    %normalize into unit vector
    head_normalization = hypot(head_vector(1,:), head_vector(2,:));
    head_vector = head_vector ./ repmat(head_normalization, 2, 1);
    
    Velocity = dot(head_vector, direction_vector);
end

