%Nombre: Christian Arroyo
%Tema: Preamulo Legacy y GreenField
%Codigo de MATLAB: propiedad de MATHWORKS.COM
%https://www.mathworks.com/help/wlan/examples/802-11n-signal-recovery-with
%-preamble-decoding.html

%Waveform Transmission
% VHT link parameters
cfgVHTTx = wlanVHTConfig( ...
    'ChannelBandwidth',    'CBW80', ...
    'NumTransmitAntennas', 3, ...
    'NumSpaceTimeStreams', 2, ...
    'SpatialMapping',      'Hadamard', ...
    'STBC',                true, ...
    'MCS',                 5, ...
    'GuardInterval',       'Long', ...
    'APEPLength',          1050);
% Propagation channel
numRx = 3;                  % Number of receive antennas
delayProfile = 'Model-C';   % TGac channel delay profile
% Impairments
noisePower = -30;  % Noise power to apply in dBW
cfo = 62e3;        % Carrier frequency offset (Hz)
% Generated waveform parameters
numTxPkt = 1;      % Number of transmitted packets
idleTime = 20e-6;  % Idle time before and after each packet
% Generate waveform
rxWave = vhtSigRecGenerateWaveform(cfgVHTTx, numRx, ...
    delayProfile, noisePower, cfo, numTxPkt, idleTime);


%Packet Recovery
cfgVHTRx = wlanVHTConfig('ChannelBandwidth', cfgVHTTx.ChannelBandwidth);
idxLSTF = wlanFieldIndices(cfgVHTRx, 'L-STF');
idxLLTF = wlanFieldIndices(cfgVHTRx, 'L-LTF');
idxLSIG = wlanFieldIndices(cfgVHTRx, 'L-SIG');
idxSIGA = wlanFieldIndices(cfgVHTRx, 'VHT-SIG-A');
%configures objects and variables for processing.
chanBW = cfgVHTTx.ChannelBandwidth;
sr = helperSampleRate(chanBW);
% Setup plots for example
[spectrumAnalyzer, timeScope, constellationDiagram] = ...
    vhtSigRecSetupPlots(sr);
% Minimum packet length is 10 OFDM symbols
lstfLen = double(idxLSTF(2)); % Number of samples in L-STF
minPktLen = lstfLen*5;
rxWaveLen = size(rxWave, 1);


%Front-End Processing
searchOffset = 0; % Offset from start of waveform in samples
while (searchOffset + minPktLen) <= rxWaveLen
    % Packet detection
    pktOffset = wlanPacketDetect(rxWave, chanBW, searchOffset);
    % Adjust packet offset
    pktOffset = searchOffset + pktOffset;
    if isempty(pktOffset) || (pktOffset + idxLSIG(2) > rxWaveLen)
        error('** No packet detected **');
    end
    % Coarse frequency offset estimation using L-STF
    LSTF = rxWave(pktOffset + (idxLSTF(1):idxLSTF(2)), :);
    coarseFreqOffset = wlanCoarseCFOEstimate(LSTF, chanBW);
    % Coarse frequency offset compensation
    rxWave(pktOffset+1:end,:) = helperFrequencyOffset( ...
        rxWave(pktOffset+1:end,:), sr, -coarseFreqOffset);
    % Symbol timing synchronization: 4 OFDM symbols to search for L-LTF
    LLTFSearchBuffer = rxWave(pktOffset + idxLSTF(2)/2 + ...
        (idxLSTF(1):idxLLTF(2)), :);
    LLTFStartOffset = helperSymbolTiming(LLTFSearchBuffer, chanBW) - 1;
    % If no L-LTF detected skip samples and continue searching
    if isempty(LLTFStartOffset)
        fprintf('** No L-LTF detected **\n\n');
        searchOffset = pktOffset+lstfLen;
        continue;
    end
    % Adjust the packet offset now that the L-LTF offset is known
    pktOffset = pktOffset + LLTFStartOffset - ...
        double(idxLSTF(2)/2);
    if (pktOffset < 0) || ((pktOffset + minPktLen) > rxWaveLen)
        fprintf('** Timing offset invalid **\n\n');
        searchOffset = pktOffset+lstfLen;
        continue;
    end
    % Timing synchronization complete: packet detected
    fprintf('Packet detected at index %d\n\n',pktOffset+1);
    % Fine frequency offset estimation using L-LTF
    LLTF = rxWave(pktOffset + (idxLLTF(1):idxLLTF(2)), :);
    fineFreqOffset = wlanFineCFOEstimate(LLTF, chanBW);
    % Fine frequency offset compensation
    rxWave(pktOffset+1:end,:) = helperFrequencyOffset( ...
    rxWave(pktOffset+1:end,:), sr, -fineFreqOffset);
    % Display estimated carrier frequency offset
    cfoCorrection = coarseFreqOffset + fineFreqOffset; % Total CFO
    fprintf('Estimated CFO: %5.1f Hz\n\n',cfoCorrection);
    break; % Front-end processing complete, stop searching for a packet
end


%Format Detection
% Channel estimation using L-LTF
LLTF = rxWave(pktOffset + (idxLLTF(1):idxLLTF(2)), :);
demodLLTF = wlanLLTFDemodulate(LLTF, chanBW);
chanEstLLTF = wlanLLTFChannelEstimate(demodLLTF, chanBW);
% Estimate noise power in NonHT fields
noiseVarNonHT = helperNoiseEstimate(demodLLTF);
% Detect the format of the packet
fmt = wlanFormatDetect(rxWave(pktOffset + (idxLSIG(1):idxSIGA(2)), :), ...
    chanEstLLTF, noiseVarNonHT, chanBW);
disp([fmt ' format detected']);
if ~strcmp(fmt,'VHT')
    error('** A format other than VHT has been detected **');
end


%L-SIG Decoding
% Recover L-SIG field bits
disp('Decoding L-SIG... ');
[recLSIGBits, failCheck] = wlanLSIGRecover( ...
    rxWave(pktOffset + (idxLSIG(1):idxLSIG(2)), :), ...
    chanEstLLTF, noiseVarNonHT, chanBW);
if failCheck % Skip L-STF length of samples and continue searching
    disp('** L-SIG check fail **');
else
    disp('L-SIG check pass');
end
% Calculate the receive time and corresponding number of samples in the
% packet
lengthBits = recLSIGBits(6:17).';
RXTime = ceil((bi2de(double(lengthBits)) + 3)/3) * 4 + 20; % us
numRxSamples = RXTime * 1e-6 * sr; % Number of samples in receive time
fprintf('RXTIME: %dus\n', RXTime);
fprintf('Number of samples in packet: %d\n\n', numRxSamples);


%The waveform and spectrum of the detected packet within rxWave are
%displayed given the calculated RXTIME and corresponding number of samples.
sampleOffset = max((-lstfLen + pktOffset), 1); % First index to plot
sampleSpan = numRxSamples + 2*lstfLen;           % Number samples to plot
% Plot as much of the packet (and extra samples) as we can
plotIdx = sampleOffset:min(sampleOffset + sampleSpan, rxWaveLen);
% Configure timeScope to display the packet
timeScope.TimeSpan = sampleSpan/sr;
timeScope.TimeDisplayOffset = sampleOffset/sr;
timeScope.YLimits = [0 max(abs(rxWave(:)))];
timeScope(abs(rxWave(plotIdx ,:)));
% Display the spectrum of the detected packet
spectrumAnalyzer(rxWave(pktOffset + (1:numRxSamples), :));


%VHT-SIG-A Decoding
% Recover VHT-SIG-A field bits
disp('Decoding VHT-SIG-A... ');
[recVHTSIGABits, failCRC] = wlanVHTSIGARecover( ...
    rxWave(pktOffset + (idxSIGA(1):idxSIGA(2)), :), ...
    chanEstLLTF, noiseVarNonHT, chanBW);
if failCRC
    disp('** VHT-SIG-A CRC fail **');
else
    disp('VHT-SIG-A CRC pass');
end
% Create a VHT format configuration object by retrieving packet parameters
% from the decoded L-SIG and VHT-SIG-A bits
cfgVHTRx = helperVHTConfigRecover(recLSIGBits, recVHTSIGABits);

% Display the transmission configuration obtained from VHT-SIG-A
vhtSigRecDisplaySIGAInfo(cfgVHTRx);


%The information provided by VHT-SIG-A allows the location of subsequent
%fields within the received waveform to be calculated.
% Obtain starting and ending indices for VHT-LTF and VHT-Data fields
% using retrieved packet parameters
idxVHTLTF  = wlanFieldIndices(cfgVHTRx, 'VHT-LTF');
idxVHTSIGB = wlanFieldIndices(cfgVHTRx, 'VHT-SIG-B');
idxVHTData = wlanFieldIndices(cfgVHTRx, 'VHT-Data');
% Warn if waveform does not contain whole packet
if (pktOffset + double(idxVHTData(2))) > rxWaveLen
    fprintf('** Not enough samples to recover entire packet **\n\n');
end

%VHT-SIG-B Decoding
% Estimate MIMO channel using VHT-LTF and retrieved packet parameters
demodVHTLTF = wlanVHTLTFDemodulate( ...
    rxWave(pktOffset + (idxVHTLTF(1):idxVHTLTF(2)), :), cfgVHTRx);
chanEstVHTLTF = wlanVHTLTFChannelEstimate(demodVHTLTF, cfgVHTRx);

% Estimate noise power in VHT fields
noiseVarVHT = helperNoiseEstimate(demodLLTF, chanBW, ...
    cfgVHTRx.NumSpaceTimeStreams);
% VHT-SIG-B Recover
disp('Decoding VHT-SIG-B...');
[sigbBits, sigbSym] = wlanVHTSIGBRecover( ...
    rxWave(pktOffset + (idxVHTSIGB(1):idxVHTSIGB(2)),:), ...
        chanEstVHTLTF, noiseVarVHT, chanBW);
% Interpret VHT-SIG-B bits to recover the APEP length (rounded up to a
% multiple of four bytes) and generate reference CRC bits
[refSIGBCRC, sigbAPEPLength] = helperInterpretSIGB(sigbBits, chanBW, true);
disp('Decoded VHT-SIG-B contents: ');
fprintf('  APEP Length (rounded up to 4 byte multiple): %d bytes\n\n', ...
    sigbAPEPLength);


%VHT Data Decoding
% Recover PSDU bits using retrieved packet parameters and channel
% estimates from VHT-LTF
disp('Decoding VHT Data field...');
[rxPSDU, rxSIGBCRC, eqDataSym] = wlanVHTDataRecover( ...
    rxWave(pktOffset + (idxVHTData(1):idxVHTData(2)), :), ...
    chanEstVHTLTF, noiseVarVHT, cfgVHTRx);

% Plot equalized constellation for each spatial stream
refConst = helperReferenceSymbols(cfgVHTRx);
[Nsd, Nsym, Nss] = size(eqDataSym);
eqDataSymPerSS = reshape(eqDataSym, Nsd*Nsym, Nss);
for iss = 1:Nss
    constellationDiagram{iss}.ReferenceConstellation = refConst;
    constellationDiagram{iss}(eqDataSymPerSS(:, iss));
end
% Test VHT-SIG-B CRC from service bits within VHT Data against
% reference calculated with VHT-SIG-B bits
if ~isequal(refSIGBCRC, rxSIGBCRC)
    disp('** VHT-SIG-B CRC fail **');
else
    disp('VHT-SIG-B CRC pass');
end