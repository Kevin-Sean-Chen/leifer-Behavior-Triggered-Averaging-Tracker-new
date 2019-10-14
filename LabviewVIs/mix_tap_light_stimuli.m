% Those are the UI inputs
dur=400;
period=25;
sti=16;
minPower=4;
maxPower=10;
hold_before_tap=10;
taps=2;
prop_no_tap=0.3;
prop_no_light=0.1;

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
%create randomly shuffled power array
power_array=linspace(minPower,maxPower,number_light);

% power and voltage in one period
ini_sti=period-sti+1;
tap_int=(sti-hold_before_tap)/(taps+1); %tap intervals
p_per=zeros(1,period);
v_per=zeros(1,period);
p_per(ini_sti:period)=1;
for i =1:taps  % tap_voltages in one standard period
    v_per(ini_sti+hold_before_tap+round(tap_int*i))=vol_tap; 
end
% randomly select which cycles to apply conditions 
rand_ind_cycle=randperm(cycle);
light_index=rand_ind_cycle(1:number_light);
tap_index=rand_ind_cycle(cycle-number_tap+1:end);
for i=1:number_tap
    cycle_inx=tap_index(i);
    end_frame=cycle_inx*period;
    ini_frame=end_frame-period+1;
    voltages(ini_frame:end_frame)=v_per;
end
for i=1:number_light
    cycle_inx=light_index(i);
    power=power_array(i);
    end_frame=cycle_inx*period;
    ini_frame=end_frame-period+1;
    powers(ini_frame:end_frame)=p_per.*power;
end

%%
figure
xx=1:dur;
plot(xx,powers);hold on
plot(xx,voltages)

