%not used in paper

figure
fps = 14;
hold all
plot(0:1/fps:(length(Track.Frames)-1)/fps, unwrap(Track.Direction/360*2*pi))
plot(0:1/fps:(length(Track.Frames)-1)/fps, Track.AngSpeed/360*2*pi)

xlabel('Time (s)') % x-axis label
ylabel('radians, radians/s') % y-axis label
legend('Direction', 'dDirection/dt')

figure
%power spectra of direction
t = 0:1/fps:1-1/fps;
x = unwrap(Track.Direction/360*2*pi);
N = length(x);
xdft = fft(x);
xdft = xdft(1:N/2+1);
psdx = (1/(fps*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
%freq = 0:fps/length(x):fps/2;
freq = 0:fps/length(x):1;

plot(freq,10*log10(psdx(1:length(freq))))
grid on
title('Periodogram Using FFT')
xlabel('Frequency (Hz)')
ylabel('Power/Frequency (dB/Hz)')