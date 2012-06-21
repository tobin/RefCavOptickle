par.Mod.f1 = 8e6;
par.Mod.g1 = 0.6;  

mod = par.Mod.f1;
par.Laser.power = 130e-3;
par.Laser.vFrf = [-mod 0 mod];

par.M1.T = 500e-6;
par.M2.T = 300e-6;

par.L   = 0;
par.Rar = 0;

par1 = par;

par.M1.T = 1000e-6;
par.M2.T = 600e-6;

par2 = par;

par.M1.T = 1000e-6;
par.M2.T = 1000e-6;

par3 = par;

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

%%
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



