% Arroyo Auz Christian Xavier.
clc;
clear all;
close all;



% se obtiene datos aleatorios se necesitan 128 datos binarios para obtener
% 64 decimales
bin=round(rand(1,128));

%Se representa graficamente los datos que se encuentran de manera binaria
figure(1); 
stem(bin,'filled','b');
title('Datos Binarios Originales');
ylabel('Valor Binario');
xlabel('Numero Valor');
%Antes de usar el pskmod pasamos a un vector de 64 datos decimales
datosendecimal=zeros(1,64);
j=1;
for i=1:64
    datosendecimal(i)=(bin(j)*2^0)+(bin(j+1)*2^1);
    j=j+1;
end


%Graficando los datos decimales
figure(2);
stem(datosendecimal,'filled','green');
title('Datos Decimales');
ylabel('Valor Decimal');
xlabel('Numero de Valor');
datosmodulados=pskmod(datosendecimal,4);



%Se grafican los datos modulados
figure(3);
stem(datosmodulados,'filled','b');
title('Datos Modulados  con QPSK');
ylabel('Valor');
xlabel('Numero de Valor');
datosmodulados=reshape(datosmodulados,64/1,1);
ifftsubportadoras=ifft(datosmodulados);



%Graficamos los datos IFFT
figure(4);
stem(real(ifftsubportadoras),'filled','b');
title('Datos IFFT');
ylabel('Valor');
xlabel('Numero de Valor');
ifftprefijo=zeros(80,1);
j=1;
for i=48:64
    ifftprefijo(j)=ifftsubportadoras(i);
    j=j+1;
end



%Graficamos los datos con el prefijo
figure(5);
stem(ifftprefijo,'filled','red');
title('Datos Prefijo');
xlabel('Numero de valor');
ylabel('Valor');