rate = 14;
amp = 50;
pulse_du = 2;
interval_du = [2,4,6];
periodic_num = [12,8,6];
cust_stim = [];

for ii = 1:3
    one_p = [amp*ones(1,pulse_du*rate),  zeros(1,interval_du(ii)*rate)];
    stim = repmat(one_p, 1, periodic_num(ii));
    cust_stim = [cust_stim; stim];
end

dlmwrite('periodic_drive.txt', cust_stim,'delimiter','\t');