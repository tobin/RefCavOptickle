

%pmc design changed.
gpmc = 1;  %overall DC gain in V/Hz
fpmc =  3.063232605609970e+005;%cavity corner frequency
[ap,bp,cp,dp]     = lowpass(fpmc, gpmc);
pmc = ss(ap,bp,cp,dp);
%pmc = gpmc;

%cavity response (optical part, plus detector)
gcav = 3e-2;  %overall DC gain in V/Hz
fcav = 2.425739345030138e+003 %cavity corner frequency
[ac,bc,cc,dc]     = lowpass(fcav, gcav);
cavity = ss(ac,bc,cc,dc);

%servo common path
%could put HF phase delay in here, currently just a gain and cavity pole
%compensation (extend cavity pole to 1/f dominant pole

common = 1;

%eom response - phase lead over appropriate frequency range (approximation)
aeom  = 0.015;  %Hz/V scaled (at one Hz, EOM broadband by newfocus)
%[ae,be,ce,de] = transdif(1,1e8, aeom);
[ae,be,ce,de] = highpass(1e8, 15e5);
aeom = ss(ae,be,ce,de);

%pzt response
respzt = 2e5; %guess resonance f
qpzt = 10;   %q
apzt = 1e6;     % DC response Hz/V
[ap,bp,cp,dp] = res2pole(respzt, qpzt, apzt);
%just flat PZT for now
%ap = 0; bp = 0; cp = 0; dp= apzt;
apzt = ss(ap,bp,cp,dp);

%temp response
atemp = 1e9;

%servo temp path (note, follows pzt output, just a low pass at 0.1 Hz)
gt = 1e-13 ;
[at,bt,ct,dt] = lowpass(1,gt);
gtemp = ss(at,bt,ct,dt);


%servo pzt path - start with one low pass and  transitional integrator (that could be
%switched maintianing gain above 10 kHz)



%[as1,bs1,cs1,ds1] = transint(100,3e3,3000);
%[as,bs,cs,ds] = series(as,bs,cs,ds,as1,bs1,cs1,ds1);
%[as1,bs1,cs1,ds1] = lowpass(7e4,6e4);
%[as,bs,cs,ds] = series(as,bs,cs,ds,as1,bs1,cs1,ds1);
[as,bs,cs,ds] = lowpass(7e4,1);
[as1,bs1,cs1,ds1] = lowpass(8e4,3e3);
[as,bs,cs,ds] = series(as,bs,cs,ds,as1,bs1,cs1,ds1);
[as1,bs1,cs1,ds1] = lowpass(8e4,1);
[as,bs,cs,ds] = series(as,bs,cs,ds,as1,bs1,cs1,ds1);
[as1,bs1,cs1,ds1] = lowpass(1e5,1);
[as,bs,cs,ds] = series(as,bs,cs,ds,as1,bs1,cs1,ds1);

[as1,bs1,cs1,ds1] = transint(1,fcav, 1);
[as,bs,cs,ds] = series(as,bs,cs,ds,as1,bs1,cs1,ds1);
[as1,bs1,cs1,ds1] = transdif(23e3,1e8,1);
[as,bs,cs,ds] = series(as,bs,cs,ds,as1,bs1,cs1,ds1);
%%%%% for locking purpose, no DC boost%%%%%%%%%%%%%%%%%%%%%
[as1,bs1,cs1,ds1] = highpass(1,1);
[as,bs,cs,ds] = series(as,bs,cs,ds,as1,bs1,cs1,ds1);
[as1,bs1,cs1,ds1] = highpass(1.1,1);
[as,bs,cs,ds] = series(as,bs,cs,ds,as1,bs1,cs1,ds1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[as1,bs1,cs1,ds1] = transint(1000, 3e4, 60000);
[as,bs,cs,ds] = series(as,bs,cs,ds,as1,bs1,cs1,ds1);
[as1,bs1,cs1,ds1] = lowpass(2000,1);
[as,bs,cs,ds] = series(as,bs,cs,ds,as1,bs1,cs1,ds1);
[as1,bs1,cs1,ds1] = lowpass(4e3,1);
[as,bs,cs,ds] = series(as,bs,cs,ds,as1,bs1,cs1,ds1);
%[as1,bs1,cs1,ds1] = lowpass(2e4,1);
%[as,bs,cs,ds] = series(as,bs,cs,ds,as1,bs1,cs1,ds1);
[as1,bs1,cs1,ds1] = lowpass(4.1e3,1);
[as,bs,cs,ds] = series(as,bs,cs,ds,as1,bs1,cs1,ds1);
[as1,bs1,cs1,ds1] = lowpass(7e3,1);
[as,bs,cs,ds] = series(as,bs,cs,ds,as1,bs1,cs1,ds1);
gpzt = ss(as,bs,cs,ds);

% %servo eom path
% [ae,be,ce,de] = lowpass(fcav,1);
% [ae2,be2,ce2,de2] = transint(6e3,1e5,1);
% [ae,be,ce,de]=series(ae,be,ce,de,ae2,be2,ce2,de2);
% [ae2,be2,ce2,de2] = transint(8.1e3,1e5,3000);
% [ae,be,ce,de]=series(ae,be,ce,de,ae2,be2,ce2,de2);
% [ae2,be2,ce2,de2] = transint(2e4,6e5,5e4);
% [ae,be,ce,de]=series(ae,be,ce,de,ae2,be2,ce2,de2);
% [ae2,be2,ce2,de2] = transint(2e3,1e8,1);
% [ae,be,ce,de]=series(ae,be,ce,de,ae2,be2,ce2,de2);
% [ae2,be2,ce2,de2] = transint(1e4,1e6,1);
% [ae,be,ce,de]=series(ae,be,ce,de,ae2,be2,ce2,de2);
% %%%to reduce the gain at lower frequency to avoid saturation
% [ae2,be2,ce2,de2] = transdif(1e-3,100,2e-1);
% %[ae2,be2,ce2,de2] = highpass(50,2e4);
% [ae,be,ce,de]=series(ae,be,ce,de,ae2,be2,ce2,de2);
% %%%%%%%%%%%%%%%%%%
% [ae2,be2,ce2,de2] = transdif(1e4,1e8, 5e-5);
% [ae,be,ce,de] = series(ae,be,ce,de,ae2,be2,ce2,de2);
% [ae2,be2,ce2,de2] = transdif(1.1e4,1e8, 1);
% [ae,be,ce,de] = series(ae,be,ce,de,ae2,be2,ce2,de2);
% [ae2,be2,ce2,de2] = transdif(1e5,1e8, 1);
% [ae,be,ce,de] = series(ae,be,ce,de,ae2,be2,ce2,de2);
% [ae2,be2,ce2,de2] = transint(1.2e3,1e7, 1);
% [ae,be,ce,de] = series(ae,be,ce,de,ae2,be2,ce2,de2);
% [ae2,be2,ce2,de2] = transdif(1e-4,1, 1e-4);
% [ae,be,ce,de] = series(ae,be,ce,de,ae2,be2,ce2,de2);
[ae,be,ce,de] = transdif(3e-4, 1,5);
[ae2,be2,ce2,de2] = transdif(4e-4,2, 1);
[ae,be,ce,de] = series(ae,be,ce,de,ae2,be2,ce2,de2);
[ae2,be2,ce2,de2] = lowpass(8e2,1);
[ae,be,ce,de]=series(ae,be,ce,de,ae2,be2,ce2,de2);
[ae2,be2,ce2,de2] = lowpass(9e2,1);
[ae,be,ce,de]=series(ae,be,ce,de,ae2,be2,ce2,de2);
%[ae2,be2,ce2,de2] = lowpass(2e3,1);
%[ae,be,ce,de]=series(ae,be,ce,de,ae2,be2,ce2,de2);
geom = ss(ae,be,ce,de);

% geom=1;