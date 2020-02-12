close all;
clear all;
clc;
n1=1;
n2=14;
FFT_SIZE=256;
%CP=16;

%% Data Generator 
Data_gen = randint(1,11,255)
D=dec2bin(Data_gen);
s=0;

%% BER PARAMETERS
EbNo=0:1:15;
BER = zeros(1,length(EbNo)); 
numPackets=15;
frmLen = 1000;
for idx = 1: length(EbNo)
    for packetidx = 1 : numPackets
        
        
%% Convolution Encoder
conv_in=[];
for index =1:11
conv_in=[conv_in double(D(index,:))-48];
end
conv_in=[conv_in 0 0 0 0 0 0 0 0]; %%8 bits padding
DIN=conv_in;
trel = poly2trellis(7, [171 133]); % Define trellis.
code = convenc(conv_in,trel);
clear conv_in;
inter_out=code;
%% BPSK Data Mapping
mapper_out=mapping(inter_out',1,1);
clear inter_out;
%D=mapper_out;
ifft_in=[0,mapper_out(1:96),zeros(1,32),zeros(1,31),mapper_out(97:192)]
tx_data=ifft(ifft_in);
clear ifft_in;
%rx_data=awgn(tx_data,10,'measured');
%rx_data=awgn(tx_data,10,'measured');
%rx_data=awgn(tx_data,2,'measured');
%rx_data=awgn(tx_data,1,'measured');

   rx_data = awgn(tx_data./sqrt(16), EbNo(idx) , 'measured');
   rx_data = awgn(rx_data./sqrt(16), EbNo(idx) , 'measured');
   rx_data = awgn(rx_data./sqrt(16), EbNo(idx) , 'measured');
   
rx_data=fft(rx_data);
clear tx_data;
rx_data1=[rx_data(1,2:97) rx_data(1,161:256)]; % taking out symbols for demapping
% rx_data1=RECON;
Demap_out=demapper(rx_data1,1,1);
%%viterbi decoder
vit_out=vitdec(Demap_out,trel,7,'trunc','hard');
clear Demap_out;
DOUT=vit_out;
%figure;plot(DOUT-DIN);
[number,ratio] = biterr(DIN,vit_out);
error(packetidx) = biterr(DIN,vit_out);
 
 end % End of for loop for numPackets
    BER21(idx) = sum(error)/(log2(4)*numPackets*frmLen);
end 

h=gcf;clf(h); grid on; hold on;
set(gca,'yscale','log','xlim',[EbNo(1), EbNo(end)],'ylim',[0 1]);
xlabel('Eb/No (dB)'); ylabel('BER'); set(h,'NumberTitle','off');
set(h,'Name','BER Results');
set(h, 'renderer', 'zbuffer');  title('OFDM alone BER PLOTS');
semilogy(EbNo(1:end),BER21(1:end),'b-*');

%error=biterr(DOUT,DIN);
%Grouping Bits and converting to Dec for RS Decoder
