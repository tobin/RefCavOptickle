function [a,b,c,d] = transdif(lf,hf,dcGain)

%transistional differentiator in state space representation
%
%[a,b,c,d] = transdif(lf,hf,dcGain);
%
%lf                                                   start differentaition (Hz)
%hf                                                   stop differentaition (Hz)
%dcGain                                                   dc gain
%
%Stuart Killbourn (October 95)

z                 = -2*pi*lf;
p                 = -2*pi*hf;
k                 = dcGain*(hf/lf);

[a,b,c,d] = zp2ss(z,p,k);

