close all
% Those are the UI inputs

dur=280;
period=28;
minPower=4;
maxPower=10;
sti=25;
hold_before_tap=5;
taps=1;
prop_no_tap=0.2;
prop_no_light=0.3;

% powers are for LED light; voltages are for tapping
% sti is the length of stimuli (ligh is on)
% An array of power is generated based on the number
% of trials we have for the whole duration
powers=zeros(1,dur);
voltages=zeros(1,dur);
vol_tap=5;
cycle=floor(dur/period);
number_tap=round((1-prop_no_tap)*cycle);
number_light=round((1-prop_no_light)*cycle);
number_both=round((1-prop_no_light-prop_no_tap)*cycle);
number_only_light=number_light-number_both;
%create randomly shuffled power array
power_array=linspace(minPower,maxPower,number_both);

% power and voltage in one period
ini_sti=period-sti+1;
tap_int=(sti-hold_before_tap)/(taps); %tap intervals
p_per=zeros(1,period);
v_per=zeros(1,period);
p_per(ini_sti:period)=1;
for i =1:taps % tap_voltages in one standard period
    v_per(ini_sti+hold_before_tap+round(tap_int*(i-1)))=vol_tap;
end
% randomly select which cycles to apply conditions
rand_ind_cycle=randperm(cycle);
light_only_index=rand_ind_cycle(1:number_only_light);
both_index=rand_ind_cycle(number_only_light+1:number_light);
tap_index=rand_ind_cycle(cycle-number_tap+1:end);
for i=1:number_tap
    cycle_inx=tap_index(i);
    end_frame=cycle_inx*period;
    ini_frame=end_frame-period+1;
    voltages(ini_frame:end_frame)=v_per;
end
for i=1:number_both
    cycle_inx=both_index(i);
    power=power_array(i);
    end_frame=cycle_inx*period;
    ini_frame=end_frame-period+1;
    powers(ini_frame:end_frame)=p_per.*power;
end
%for light only cycles, we use maxPower
for i=1:number_only_light
    cycle_inx=light_only_index(i);
    power=maxPower;
    end_frame=cycle_inx*period;
    ini_frame=end_frame-period+1;
    powers(ini_frame:end_frame)=p_per.*power;
end
%%
figure
xx=1:dur;
plot(xx,powers);hold on
plot(xx,voltages)

