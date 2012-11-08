function [a,b,c,d] = res2pole(fcut,q,dcGain)

%resonant 2-pole low pass filter in state space representaion
%
%[a,b,c,d] = res2pole(fcut,q,dcGain);
%
%fcut                                                   frequency cut (Hz)
%q                                                   Q factor of resonance
%dcGain                                                   dc gain
%
%Stuart Killbourn (October 95)

% Sallen-Key Low Pass Filter (?) (Morag)

z                 = [];
p                 = pi*fcut*(-1/q + i*sqrt(4 - 1/(q^2)));
p                 = [conj(p) p]';
k                 = dcGain*(2*pi*fcut)^2;


[a,b,c,d] = zp2ss(z,p,k);


return

