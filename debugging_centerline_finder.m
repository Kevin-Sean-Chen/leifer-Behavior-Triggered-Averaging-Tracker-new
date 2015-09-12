for saved_image_stack_index = 1:38
    image_stack = saved_image_stacks(saved_image_stack_index).Images;
    Track = Tracks(saved_image_stacks(saved_image_stack_index).TrackIndex);
    [center_line, properties] = initial_sweep(image_stack, Track, saved_image_stack_index);
    saved_image_stack_index
end