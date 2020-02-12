% Arroyo Christian
clear, clf
%Frecuencia a trabajar en megaherzios
fc=7.5e9;
% Tamaño de las antenas en metros
htx=30; hrx=30;
% Distancia entre elementos
distance=[1:2:50].^2;
%invocacion a PL_Hata
y_urban=PL_Hata(fc,distance,htx,hrx,'urban');
y_suburban=PL_Hata(fc,distance,htx,hrx,'suburban');
y_open=PL_Hata(fc,distance,htx,hrx,'open');
% Impresion de los trayectos
semilogx(distance,y_urban,'r-s', distance,y_suburban,'k-o', distance,y_open,'b-^')
% Imresion de las leyendas
title(['Modelo Hata PL, f_c = ',num2str(fc/1e6),' MHz'])
xlabel('Distancia [m]'), ylabel('Path loss [dB]')
legend('Area Urbana','Area Sub-Urbana','Area Abierta',2), grid on, axis([1 1000 40 110])


% Bibliografia: 
% MIMO-OFDM Wireless Communication With MATLAB.
% https://www.youtube.com/watch?v=2lQvoJy_g2Q
% http://rci.cujae.edu.cu/index.php/rci/rt/printerFriendly/67/html
% http://www.mathworks.com/help/matlab/ref/colorspec.html?refresh=true