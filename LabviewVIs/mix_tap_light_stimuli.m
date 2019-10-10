
% Those are the UI inputs

dur=280;
period=28;
power=10;
sti=14;
hold_before_tap=5;
taps=2;
prop_tap=0.3;
prop_light=0.3;


% powers are for LED light; voltages are for tapping
% sti is the length of stimuli (ligh is on)
% by default, taps are applied in the middle of light pulse
% taps can wait for additional frames with hold_before_tap
vol_tap=5; 
cycle=floor(dur/period);
number_only_tap=round(prop_tap*cycle);
number_only_light=round(prop_light*cycle);
remain=mod(dur,period);
ini_sti=period-sti+1;
tap_int=(sti-hold_before_tap)/(taps+1); %tap intervals
p_per=zeros(1,period);
v_per=zeros(1,period);%power and voltage in one period

% the power and voltage of one standard period
for i=ini_sti:period  
    p_per(i)=power;
end
for i =1:taps  % add hold_before_tap in each sti
    v_per(ini_sti+hold_before_tap+round(tap_int*i))=vol_tap; 
end
% first assign each cycle with both light and tap
powers=repmat(p_per,1,cycle);
powers=[powers,p_per(1:remain)]; 
voltages =repmat(v_per,1,cycle);
voltages=[voltages,v_per(1:remain)];

% randomly select which cycles to apply conditions 
rand_ind_cycle=randperm(cycle,number_only_light+number_only_tap);
cycle_index_WO_light=rand_ind_cycle(1:number_only_tap);
cycle_index_WO_tap=rand_ind_cycle(number_only_tap+1:end);
%modify the cycles without light
for i=cycle_index_WO_light
    end_frame=i*period;
    ini_frame=end_frame-period+1;
    powers(ini_frame:end_frame)=0;
end
%modify the cycles without tap
for i=cycle_index_WO_tap
    end_frame=i*period;
    ini_frame=end_frame-period+1;
    voltages(ini_frame:end_frame)=0;
end

%%
xx=1:dur;
plot(xx,powers);hold on
plot(xx,voltages)

