%% AEI 10m - Frequency Stabilization Servo

% Some general principles:
%
% The reference cavity and the PMC each have a cavity pole that appears in
% the frequency stabilization servo loop.  The Ref Cav pole is unavoidable;
% the PMC pole appears because the PMC sits between the laser and the
% reference cavity.  These two poles can be compensated by putting a zero
% into the servo, canceling the pole -- but, since a zero is unstable by
% itself, each of these compensating zeros must have a corresponding pole
% at higher frequency.  Thus the cavity poles can only be "extended".
%

                                         
                                         
                                         
% +---------------------------------------<<----------------------------------------------+
% |                                                                                       |
% |   +------------------+    +------------+         +---------+    +---------------+     |
% +-->| sys_common_plant |--->| sys_common |----+--->| sys_EOM |--->| sys_EOM_plant |--->(+)
%     +------------------+    +------------+    |    +---------+    +---------------+     ^  
%                                               |                                         |
%                                               |    +---------+    +---------------+     |
%                                               +--->| sys_PZT |--->| sys_PZT_plant |-----+
%                                                    +---------+    +---------------+
                                              
%%
% tell Matlab to use sensible units (Hz instead of rad/s):
set(cstprefs.tbxprefs, 'FrequencyUnits','Hz');

% physical constants
c = 299792458;       % [m/s]


%% COMMON PLANT
% This includes those parts of the plant that are common to all branches of
% the servo: the PMC, the reference cavity, and signal travel times.

F_pmc = 950;                              % finesse of PMC, page 881
fsr_pmc = 565.65e6;                       % FSR in Hz, page 881
pole_pmc = fsr_pmc / F_pmc / 2;           % Hz, derived

F_refcav = 7000;                          % Finesse of Ref Cav
fsr_refcav = 12e6;                        % FSR in [Hz]
pole_refcav = fsr_refcav / F_refcav / 2;  % cavity pole in Hz
g_refcav = 3e-2;                          % PDH gain, V/Hz

tau = 10/c;                               % delay [s]

sys_pmc    = zpk([], -2*pi*pole_pmc, 1);
sys_refcav = zpk([], -2*pi*pole_refcav, g_refcav);

sys_delay  = exp(-tau*zpk('s'));

sys_common_plant  = sys_pmc * sys_refcav * sys_delay;

%% COMMON SERVO

% Optionally include an "anti-boost" to reduce DC gain during lock
% acquisition.
sys_antiboost = zpk([0 0], -2*pi*[10 10], 1);

sys_common_servo = 1;

% Combine the plant and servo:
sys_common = sys_common_plant * sys_common_servo;

%% EOM SERVO

sys_EOM_servo = 10e7;

%% EOM PLANT
% The EOM has flat response for phase; when considered an actuator on
% frequency instead, it has a response that goes up like f, i.e. it has a
% zero at DC.

g_EOM = 0.015;                  %  Hz/volt at 1 Hz
sys_EOM_plant = zpk([0], [], 1);

% Combine the plant and servo:
sys_EOM = sys_EOM_servo * sys_EOM_plant;

%% PZT SERVO

% Make a notch at the PZT resonance frequency
sys_PZT_servo = 1;

%% PZT PLANT
% The PZT is a flat frequency actuator up to a resonance.

sqrts = @(x) [1 -1]*sqrt(x);
res2pole = @(f0, Q) (f0/2)*(1/Q - 1i*sqrts(4 - 1/Q^2));

PZTres_f = 200e3;           % guess, from Fumiko/Ken
PZTres_Q = 10;              % guess

sys_PZT_plant = zpk([], -2*pi*res2pole(PZTres_f, PZTres_Q), 1);

sys_PZT = sys_PZT_servo * sys_PZT_plant;

%% Set crossover frequency

f_crossover = 30e3;

[M_PZT, ~] = bode(sys_PZT, 2*pi*f_crossover);
[M_EOM, ~] = bode(sys_EOM, 2*pi*f_crossover);

sys_PZT = sys_PZT * (M_EOM / M_PZT);

%% Put it together

sys_total = sys_common * (sys_EOM + sys_PZT);

%plot it
bode(sys_total, sys_common * sys_EOM, sys_common * sys_PZT, {2*pi*0.1, 2*pi*10e6});
grid on
legend('total', 'EOM path', 'PZT path');