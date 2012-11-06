% Here we model the reference cavity as a two-mirror cavity for simplicity.

function opt = optRefCav(par)

opt = Optickle(par.Laser.vFrf);

opt = addSource(opt, 'Laser', [0 sqrt(par.Laser.power) 0]);

opt = addModulator(opt, 'AM', 1);
opt = addModulator(opt, 'PM', 1i);

opt = addLink(opt, 'Laser', 'out', 'AM', 'in', 0);
opt = addLink(opt, 'AM', 'out', 'PM', 'in', 0);

opt = addRFmodulator(opt, 'Mod', par.Mod.f1, 1i * par.Mod.g1);

opt = addLink(opt, 'PM', 'out', 'Mod', 'in', 5);

% [opt, sn] = addMirror(opt, name, aio, Chr, Thr, Lhr, Rar, Lmd, Nmd)

opt = addMirror(opt, 'M1', 0, 0, par.M1.T, par.M1.L, par.Rar,   0e-6);
opt = addMirror(opt, 'M2', 0, 0, par.M2.T, par.M2.L, par.Rar,  0);

% Specify the suspensions
% dampRes = [0.01 + 1i, 0.01 - 1i];
% opt = setMechTF(opt, 'IX', zpk([], -w * dampRes, 1 / mI));
% opt = setMechTF(opt, 'EX', zpk([], -w * dampRes, 1 / mE));
% 

opt = addSink(opt, 'REFL', 1);
opt = addSink(opt, 'TRANS', 1);

opt = addLink(opt, 'Mod', 'out', 'M1', 'bk', 0);

% Cavity outputs:
opt = addLink(opt, 'M1', 'bk', 'REFL', 'in',  0);
opt = addLink(opt, 'M2', 'bk', 'TRANS', 'in', 0);

% The main cavity
opt = addLink(opt, 'M1', 'fr', 'M2', 'fr', 21.2/2);
opt = addLink(opt, 'M2', 'fr', 'M1', 'fr', 21.2/2);

% Add probes
opt = addProbeIn(opt, 'REFL_DC', 'REFL', 'in', 0, 0);
opt = addProbeIn(opt, 'REFL_I',  'REFL', 'in', par.Mod.f1, 0);
opt = addProbeIn(opt, 'REFL_Q',  'REFL', 'in', par.Mod.f1, 90);

opt = addProbeIn(opt, 'TRANS_DC', 'TRANS', 'in', 0, 0);

% add unphysical intra-cavity probes
opt = addProbeOut(opt, 'CAVITY', 'M1', 'fr', 0, 0);
  