function [a,b,c,d] = transint(lf,hf,dcGain)

%transistional integrator in state space representation
%
%[a,b,c,d] = transint(lf,hf,dcGain);
%
%lf                                                   start integration (Hz)
%hf                                                   stop integration (Hz)
%dcGain                                                   dc gain
%
%Stuart Killbourn (October 95)

z                 = -2*pi*hf;
p                 = -2*pi*lf;
k                 = dcGain*(lf/hf);

[a,b,c,d] = zp2ss(z,p,k);

