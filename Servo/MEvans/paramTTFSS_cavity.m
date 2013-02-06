% param = paramTTFSS(ver)

function param = paramTTFSS(ver, f)
  
  if nargin < 1
    ver = 0;
  end
  if nargin > 1
    % s-domain
    f = f(:);
    s = 2i * pi * f;
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Default Values
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RF Input Stage
  param.polesRF = [3e6 0; 1.6e6 1.2; 3e5 0]; % tweaked to match measurements
  param.zerosRF = [3e6 0; 42e6 100; 6e5 0];
  param.gainRF = 0.5; % ?
  
  param.polesRefCav = [150e3 0];
  param.gainRefCav = 0.25 / 150e3;  % V/Hz ~ fringe height / cavity pole
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Common Path
  % U3 gain of 3.16 = 10dB
  param.R3 = 124;
  param.R4 = 392;
  
  param.commGain = 20; % in dB (650 => 16db)
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fast Path
  param.fastGain = 20; % in dB (800 => 22db)
  
  % U8
  param.R35 = 560; % input
  param.R30 = 4.87e3; % FB
  param.C36 = 3.3e-9; % FB
  
  % U9
  param.R36 = 750; % input
  param.R31 = 3.09e3; % FB
  param.C37 = 1.5e-9; % FB
  
  % U7
  param.R37_R32 = 1e3; % input network effective impedence
  param.R29 = 5.6e3;   % FB
  
  % output filter
  param.R46 = 15.8e3;
  param.C51 = 1e-6;
  
  % PZT coefficent in Hz/V
  param.coefPZT = 3.5e6;
  param.delayPZT = 1200e-9;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EOM Path
  % U4
  param.C23 = 1e-6; % input
  param.R22 = 1.1e3; % input
  param.R19 = 24.9e3; % FB
  param.C15 = 3.3e-9; % FB
  param.R17 = 0e3; % FB
  
  % U5
  param.C24 = 1e-6; % input
  param.R24 = 1.3e3; % input
  param.R20 = 47e3; % FB
  param.C18 = 3.3e-9; % FB
  param.R18 = 1.5e3; % FB
  
  % U6
  param.C11 = 330e-12; % input (pass around)
  param.R14 = 3.01e3; % input (pass around)
  param.L1 = 200e-6; % input (pass around)
  param.R15 = 100; % input (pass around)
  
  param.C25 = 1e-6; % input
  param.R25 = 499; % input
  param.R21 = 10e3; % FB
  
  % high voltage output (PA85)
  param.hv.C22 = 221e-9; % and C21
  param.hv.R42 = 3.3e3;
  
  param.hv.R47 = 100e3;
  param.hv.R45 = 1e3;
  param.hv.C25 = 47e-12;
      
  % EOM coefficent in rad/V
  param.coefEOM = 10e-3;
  param.delayEOM = 0e-9;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Version Specific Values
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  switch ver
    case 0 % default
    case 1
      % low gain mode - PZT only
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Common Path
      % U3 - now 1
      %param.R3 = 392;
      %param.R4 = 392;
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fast Path
      % move PZT poles up, allowing wider band PZT

      %param.R30 = 2e3; % FB, U8
      %param.C36 = 330e-12; % FB, U8
      
      param.C36 = 100e-12; % FB, U8
      
      param.commGain = 0; % in dB
      param.fastGain = 0; % in dB
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EOM Path
      param.R19 = 2e3; % FB, U4 (move pole out)
      param.C23 = 33e-9;  % higher AC couple
      param.C24 = 100e-9;  % higher AC couple
  
    case 2
      % in high gain mode
      param = paramTTFSS(1, f);

      param.commGain = 20; % in dB
      param.fastGain = 20; % in dB
    case 3
      % squeezer version, with mini-boost on PZT path
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Common Path
      % U3 - now 1
      %param.R3 = 392;
      %param.R4 = 392;
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fast Path
      % move PZT poles up, allowing wider band PZT
      param.R30 = 1e3 + parRC(20e3, 33e-9, s); % FB, U8 - mini-boost
      param.C36 = 560e-12; % FB, U8
      
      %param.R31 = 3e3 + parRC(10e3, 10e-9, s); % FB, U9
      %param.C37 = 1e-12; % FB, U9

      param.commGain = 20; % in dB
      param.fastGain = 30; % in dB
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EOM Path
      param.R19 = 2e3; % FB, U4 (move pole out)
  
    case 4
      % high-gain - 3 times less PZT signal than v2
      % this is to prevent problems due to PZT resonances
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Common Path
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fast Path
      % move PZT pole up, allowing wider band PZT

      param.C36 = 330e-12; % FB, U8
      
      param.commGain = 20; % in dB
      param.fastGain = 20; % in dB
      
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EOM Path
      param.R19 = 2e3; % FB, U4 (move pole out)
      param.C23 = 33e-9;  % higher AC couple
      param.C24 = 100e-9;  % higher AC couple
  
    otherwise
      error('Unknown version %d', ver)
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%
function h = parRC(R, C, s)
  h = 1 ./ ((1 ./ R) + s .* C);
end

