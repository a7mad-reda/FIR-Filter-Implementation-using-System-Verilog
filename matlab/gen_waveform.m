clc
clear
f1 = 100e3;    %First Wave frequency  = 100 khz 
f2 = 300e3;    %Second Wave frequency = 300 khz 
f3 = 1e6;      %Third Wave frequency  = 1   Mhz 

fs = 100e6;    %Sampling frequency    = 100 Mhz
ts = 1/fs;     %Sampling Period "time for single sample"

fmin = min([f1, f2, f3]); %Minimum Frequency
tmax = 1/fmin;            %Maximum Period

ts_max = 2 * tmax; %Maximum Sampling time = 2 cycles of the slowest signal

t = 0 : ts : ts_max;

signal1 = 5 * sin(2*pi*f1*t);
signal2 = 5 * sin(2*pi*f2*t);
signal3 = 5 * sin(2*pi*f3*t);

sum = signal1 + signal2 + signal3;

%Display the Waveforms
subplot(4,1,1),plot(signal1);
xlabel('Time index n');
ylabel('Amplitude');
title('Signal1 Waveform'); 
subplot(4,1,2),plot(signal2);
xlabel('Time index n');
ylabel('Amplitude');
title('Signal2 Waveform'); 
subplot(4,1,3),plot(signal3);
xlabel('Time index n');
ylabel('Amplitude');
title('Signal3 Waveform'); 
subplot(4,1,4),plot(sum);
xlabel('Time index n');
ylabel('Amplitude');
title('Signals Magnitude'); 

%Convert Samples to signed Binary
value = sum'; 
singed = 1;
total_width = 16;
fraction_width = 12;
fixed_point = fi(value,singed,total_width,fraction_width);
fixed_2_bin = fixed_point.bin;
%pointIndex = fixed_point.WordLength - fixed_point.FractionLength;
%str1 = fixed_2_bin(1:pointIndex);
%str2 = fixed_2_bin(pointIndex+1:end);
%fprintf('%s_%s\n', str1, str2);

%Write ouputs to a file in binary
mem = fopen('mem.txt','wt');
if mem > 0
for i = 1:size(fixed_2_bin)
fprintf(mem,'%s\n', fixed_2_bin(i,:));
end
fclose(mem);
end

%Write ouputs to a file in decimal
memdec = fopen('decimal.txt','wt');
if memdec > 0
for i = 1:size(sum)
fprintf(memdec,'%s\n', sum(i,:));
end
fclose(memdec);
end

