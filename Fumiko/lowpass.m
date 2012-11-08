function [a,b,c,d] = lowpass(fcut,dcGain)

%low pass filter in state space representation
%
%[a,b,c,d] = lowpass(fcut,dcGain);
%
%fcut                                                   frequency cut (Hz)
%dcGain                                                   dc gain
%
%Stuart Killbourn (October 95)

z                 = [];
p                 = -2*pi*fcut;
k                 = dcGain*2*pi*fcut;

[a,b,c,d] = zp2ss(z,p,k);
