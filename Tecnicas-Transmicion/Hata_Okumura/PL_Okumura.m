% Arroyo Christian
clc, clear

F=input('Ingrese la frecuencia de 150Mhz<f<1920Mhz : ');
D=input('Ingrese la distancia donde se encuentra la estacion base 1Km<d<100Km : ');
Ht=30:1:100;
Hr=input('Ingrese el tamanio de la antena, no puede pasar los 10 metros : ');
Ld=32.45+20*log10(F)+20*log10(D);
Gt=20*log10(Ht/200);
Amu=35;
GareaA=33;
GareaCA=27;
GareaSU=13;

if Hr<=3, Ge=10*log10(Hr/3);
else if ((Hr>3)&&(Hr<=10)), Ge=20*log10(Hr/3);
    end
end

L=Ld+Amu-Gt-Ge-GareaA;
L2=Ld+Amu-Gt-Ge-GareaCA;
L3=Ld+Amu-Gt-Ge-GareaSU;

plot(Ht,L, 'c')
title('Modelo Okumura');
xlabel('Tamanio de la Antena Transmisora (Km)');
ylabel('Propagacion Path loss(dB) para  50 Km');
%gtext('Area Abierta');

hold on
plot(Ht,L2, 'm')
%gtext('Area Semi-Abierta');
hold on

plot(Ht,L3, 'g')
%gtext('Area Sub-Urbana');

legend('Area Abierta','Area Semi-Abierta','Area Sub-Urbana')
grid on

% Bibliografia: 
% MIMO-OFDM Wireless Communication With MATLAB.
% https://www.youtube.com/watch?v=2lQvoJy_g2Q
% http://rci.cujae.edu.cu/index.php/rci/rt/printerFriendly/67/html
% http://www.mathworks.com/help/matlab/ref/colorspec.html?refresh=true