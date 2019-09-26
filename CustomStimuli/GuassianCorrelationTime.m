function powers = GuassianCorrelationTime()
    frame_rate = 14;
    frame_count = 25200;
    correlationTime = .5;
    sigma = 9; %the standard deviation
    minPower = 0;
    maxPower = 18; %in this case, the average voltage
    currentPower = 9;

    powers = zeros(1,frame_count);
    A = exp(-(1/frame_rate)/correlationTime);
    powers(1,1) = 0; %the initial voltage is 0, we will offset later

    for frame = 2:frame_count
        powers(1,frame) = A*powers(1,frame-1) + (randn(1)*sqrt(sigma^2*(1-(A^2))));
    end

    %offset
    powers = powers + currentPower;

    %make sure the signal does not go out of bounds
    powers(powers<minPower) = minPower;
    powers(powers>maxPower) = maxPower;
    %voltages = powers / VoltageToPower; %convert to voltages

    figure
    plot(0:1/frame_rate:(frame_count-1)/frame_rate, powers, 'bo-')
    xlabel('time (s)') % x-axis label
    ylabel('voltage') % y-axis label
    
    
    N = length(powers);
    xdft = fft(powers);
    xdft = xdft(1:N/2+1);
    psdx = (1/(frame_count*N)) * abs(xdft).^2;
    psdx(2:end-1) = 2*psdx(2:end-1);
    freq = 0:frame_count/length(powers):frame_count/2;

    figure;
    plot(freq(1:100),10*log10(psdx(1:100)))
    grid on
    title('Periodogram Using FFT')
    xlabel('Frequency (Hz)')
    ylabel('Power/Frequency (dB/Hz)')

    periodogram(powers,rectwin(length(powers)),length(powers),frame_rate, 'power')
    
    figure 
    autocorr(powers)
    xlabel('frames (at 14fps)')
end
