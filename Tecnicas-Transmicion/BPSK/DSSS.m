%     -------------- GENERADOR  DE BITS ALEATORIOS: ------------------
    
    
    % Generando numeros de 32 bits: 
       generador_bits = randi([-1 1], 32, 1);   % Genera un vector de datos binarios.
       
    % Para mostrarlos en fila (en forma serial):
       serial=reshape(generador_bits,1,[]);     % Cambia las columnas por filas del vector columna de bits.
       disp(serial)                             % Los muestra en la ventana de comandos de Matlab.
     
 
%=========================================================================
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
%/////////////////////////////////////////////////////////////////////////
%=========================================================================
%      ---------------------  MODULADOR_BPSK: ---------------------
    % 1. Generador senial chip:
    
            % Generando numeros de 32 bits: 
               generador_chip = randi([-1 1], 128, 1);   % Genera un vector de datos binarios.

            % Para mostrarlos en fila (en forma serial):
               serial_chip = reshape(generador_chip,1,[]);     % Cambia las columnas por filas del vector columna de bits.
               disp(serial_chip)                             % Los muestra en la ventana de comandos de Matlab.
    
    % 2. XOR senial:
    
         

    % 3. Pulsos y Modulacion BPSK (Dominio del tiempo):
            f=0.5;
            t=0:2*pi/99:2*pi;
            cp=[];sp=[];
            mod=[];mod1=[];bit=[];
          for n=1:length(generador_bits);
            if generador_bits(n)==0;
                die=-ones(1,100);       %   Modulante
                se=zeros(1,100);        %   Se?al
            else generador_bits(n)=1;
                die=ones(1,100);        %   Modulante
                se=ones(1,100);         %   Se?al
            end
            c=sin(f*t);
            cp=[cp die];
            mod=[mod c];
            bit=[bit se];
        end
            bpsk=cp.*mod;
 
                
%=========================================================================
%/////////////////////////////////////////////////////////////////////////
%=========================================================================
%      ----------------- Power Spectral Density (PDS): ----------------

%na = 4;
%w = hanning(floor(max(size(qpsk))/na));
%w = hanning(floor(max(size(qpsk))));

%=========================================================================
%/////////////////////////////////////////////////////////////////////////
%=========================================================================
%     ---------------------- GR?FICAS/PLOTS: ---------------------

   % Gr?fica de la senial binaria generada:
      
       subplot(4,1,1);plot(bit,'LineWidth',1.5);grid on;
       title('SENAL BINARIA');
       axis([0 100*length(generador_bits) -0.25 1.25]);
       xlabel('Bits');
       ylabel('SENAL BINARIA');
       
   % Gr?fica de la senial chip generada:
      
       subplot(4,1,2);plot(bit,'LineWidth',1.5);grid on;
       title('SENAL CHIP');
       axis([0 100*length(generador_chip) -0.25 1.25]);
       xlabel('Bits');
       ylabel('SENAL CHIP');
        
   % Gr?fica de la senial BPSK en el dominio del tiempo:
       subplot(4,1,3);plot(bpsk,'LineWidth',1.5);grid on;
       title('MODULACION BPSK');
       axis([0 100*length(generador_chip) -2.25 2.25]);
       xlabel('Bits');
       ylabel('BPSK');
   
   % Gr?fica de la senial PDS:
   %    subplot(4,1,4);pwelch(qpsk,w,[],128,2500,'twosided'); grid on;
    %   title('ESPECTRO PSD');
     %  xlabel('Frecuencia Normalizada');
      % ylabel('PDS [dB]');

   
   % Gr?fica de la constelaci?n BPSK:
       scatterplot(generador_bits);
       title('CONSTELACION BPSK');
       xlabel('En-Fase');
       ylabel('Cuadratura');
       disp(length(generador_bits));
   
  
   