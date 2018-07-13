duty_cycle_list = [1, 10, 50];
freqency_list = [200, 1000];
trials = 5;
pulse_duration = 28;
pulse_wait = 812;
frame_count = 25200;


pulse_duty_cycle = []
pulse_frequency = []
for i = 1:size(duty_cycle_list,2)
    for j = 1:size(freqency_list,2)
        for trial = 1:trials
            pulse_duty_cycle = cat(2, pulse_duty_cycle, duty_cycle_list(i))
            pulse_frequency = cat(2, pulse_frequency, freqency_list(j))
        end
    end
end
pulse_duty_cycle = pulse_duty_cycle(:,randperm(size(pulse_duty_cycle,2)))
pulse_frequency = pulse_frequency(:,randperm(size(pulse_frequency,2)))


duty_cycles = zeros(1,frame_count);
frequencies = zeros(1,frame_count);
min_duty_cycle = 0;
rising = 1;
step_count = 0;
pulse_index = 1;
current_duty_cycle = min_duty_cycle;
current_freqency = pulse_frequency(1, 1);
for frame = 1:frame_count
    duty_cycles(1,frame) = current_duty_cycle;
    frequencies(1,frame) = current_freqency;
    if rising
        if step_count >= pulse_wait
            if pulse_index > size(pulse_duty_cycle, 2)
               %end of the pulse arrary reached, do nothing
               current_duty_cycle = min_duty_cycle;
            else
                rising = 0;
                step_count = 0;
                current_duty_cycle = pulse_duty_cycle(1, pulse_index);
                current_freqency = pulse_frequency(1, pulse_index);
                pulse_index = pulse_index + 1;
            end
        end
    else
        if step_count >= pulse_duration
            rising = 1;
            step_count = 0;
            current_duty_cycle = min_duty_cycle;
        end
    end
    step_count = step_count + 1;
end