% Model the performance of the reference cavity with the mirrors we have
%
% We recently discovered that the reference cavity mirrors we received have
% twice the intended transmission (1000 ppm and 600 ppm instead of 500 ppm
% and 300 ppm).  This script simulates the design configuration, the
% configuration with a 1000 ppm / 600 ppm combination, and a configuration
% with two 1000 ppm transmission mirrors (we have a spare).
%
% Tobin Fricke - June 2012

par.Mod.f1 = 8e6;   % Modulation frequency [Hz]
par.Mod.g1 = 0.6;   % Modulation depth [radians]

par.Laser.power = 130e-3 / besselj(0, par.Mod.g1)^2;  % Laser power
par.Laser.vFrf = [-1 0 1] * par.Mod.f1;               % RF frequencies 

% Define the HR losses of the two mirrors
par.M1.L = 0;
par.M2.L = 200e-6;

% Define the transmissivities of the two mirrors
par.M1.T = 500e-6;
par.M2.T = 300e-6;

% Set the reflectivity of the AR surface of the mirrors
par.Rar = 0;

% Variant #1: Design configuration
par1 = par;

% Variant #2: 1000ppm and 600 ppm
par.M1.T = 1000e-6;
par.M2.T = 600e-6;
par2 = par;

% Variant #3: 1000ppm and 1000 ppm
par.M1.T = 1000e-6;
par.M2.T = 1000e-6;
par3 = par;

% Do the simulation
opt1 = optRefCav(par1);
opt2 = optRefCav(par2);
opt3 = optRefCav(par3);

f = logspace(log10(1), log10(10000), 300);
[fDC1, sigDC1, sigAC1, mMech1, noiseAC1, noiseMech1] = tickle(opt1, [], f);
[fDC2, sigDC2, sigAC2, mMech2, noiseAC2, noiseMech2] = tickle(opt2, [], f);
[fDC3, sigDC3, sigAC3, mMech3, noiseAC3, noiseMech3] = tickle(opt3, [], f);

nREFL_Iprobe = getProbeNum(opt1, 'REFL_I');
nREFL_Qprobe = getProbeNum(opt1, 'REFL_Q');

nEX = getDriveIndex(opt1, 'M2');
nMod = getDriveIndex(opt1, 'PM');

%% Plot the results
%W_per_m  = getTF(sigAC1, nREFL_Iprobe, nEX) / 2;
%W_per_Hz = getTF(sigAC1, nREFL_Iprobe, nMod) ./ (1i * f.');
%L = 21.2;
%nu = 3e8 / 1064e-9;
%loglog(f, abs(W_per_m) * L/nu, f, abs(W_per_Hz));
set(0, 'DefaultAxesFontSize',14)
set(0, 'DefaultTextFontSize', 14);
set(0, 'DefaultLineLinewidth', 2);
loglog(f, abs(noiseAC1(nREFL_Iprobe, :).' ./ (getTF(sigAC1, nREFL_Iprobe, nMod) ./ (1i * f'))));
hold all
loglog(f, abs(noiseAC2(nREFL_Iprobe, :).' ./ (getTF(sigAC2, nREFL_Iprobe, nMod) ./ (1i * f'))));
loglog(f, abs(noiseAC3(nREFL_Iprobe, :).' ./ (getTF(sigAC3, nREFL_Iprobe, nMod) ./ (1i * f'))));
hold off
legend('500 / 300 (design)', '1000 / 600', '1000 ppm / 1000 ppm');
xlabel('frequency [Hz]');
ylabel('Hz / rtHz');
title(sprintf('reference cavity shot-noise-limited sensitivity /\n assumes 200 ppm intra-cavity loss, 130 mW incident power /\n mod depth 0.6 radians, no higher order modes'));
ylim([1e-6 1e-5]);
%%



