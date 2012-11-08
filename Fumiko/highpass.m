function [a,b,c,d] = highpass(fcut,hfGain)

%high pass filter in state space representation
%
%[a,b,c,d] = highpass(fcut,hfGain);
%
%fcut                                                   low-frequency cut (Hz)
%hfGain                                                   high frequency gain
%
%Stuart Killbourn (October 95)


z                 = 0;
p                 = -2*pi*fcut;
k                 = hfGain;

[a,b,c,d] = zp2ss(z,p,k);

