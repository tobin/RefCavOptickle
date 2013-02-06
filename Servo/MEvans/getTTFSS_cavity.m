% [hOL, hEOM, hPZT] = getTFs(param)
%
% Example (parameter version 3):
% [hOL, hCross, hEOM, hPZT, info] = getTTFSS(paramTTFSS(3, f), f);
% zplotlog(f, hOL);

function [hOL, hCross, hEOM, hPZT, info] = getTTFSS(param, f)
  
  % s-domain
  f = f(:);
  s = 2i * pi * f;
  
  % extract everything from the parameter struct
  struct2workspace(param);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Cavity Response
  filtRefCav = filtZPGQ([], polesRefCav, gainRefCav, 0);
  hRefCav = sresp(filtRefCav, f);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RF Input Stage
  filtRF = filtZPGQ(zerosRF, polesRF, gainRF, 0);
  hRF = sresp(filtRF, f);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Common Path
  % U3 and VGA
  hComm = hRF * (R4 / R3) * 10^(commGain / 20);
      
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Fast Path
  % U8 and U9
  hU8 = parRC(R30, C36, s) ./ R35;
  hU9 = parRC(R31, C37, s) ./ R36;
  hU7 = R29 ./ R37_R32;
  
  % output filter
  hOut = 1 ./ (s .* C51 .* serRC(R46, C51, s));
  
  % total, with VGA
  hPZT = hComm .* 10.^(fastGain / 20) .* hU8 .* hU9 .* hU7;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EOM Path
  % U4
  hU4 = parRR(serRC(R17, C15, s), R19) ./ serRC(R22, C23, s);
  hU5 = parRR(serRC(R18, C18, s), R20) ./ serRC(R24, C24, s);
      
  % U6
  zPA = ((s * L1 + R15) ./ (s * L1)) .* ...
    (serRC(R14, C11, s) + parRR(R15, s * L1));

  hU6 = R21 ./ serRC(R25, C25, s);
  hU6pa = R21 ./ zPA;
  
  % total
  hU456 = hU4 .* hU5 .* hU6;
  hEOM = hComm .* (hU456 + hU6pa);

  % high voltage
  hHV = parRR(serRC(hv.R45, hv.C25, s), hv.R47) ./ serRC(hv.R42, hv.C22, s);
      
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Total Open-Loop
  hDelayPZT = exp(-s * delayPZT);
  hDelayEOM = exp(-s * delayEOM);
  hOL(:, 1) = hDelayPZT .* hRefCav .* coefPZT .* hOut .* hPZT;
  hOL(:, 2) = hDelayEOM .* hRefCav .* coefEOM .* hHV .* hEOM .* s;
  hOL(:, 3) = hOL(:, 1) + hOL(:, 2);

  hCross = hOL(:, 1) ./ (1 + hOL(:, 2));
  
  % other stuff
  info = workspace2struct;
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%
function h = parRC(R, C, s)
  h = 1 ./ ((1 ./ R) + s .* C);
end

%%%%%%%%%%%%%%%%%%%%%%%%%
function h = serRC(R, C, s)
  h = R + 1 ./ (s .* C);
end

%%%%%%%%%%%%%%%%%%%%%%%%%
function h = parRR(R1, R2)
  h = 1 ./ ((1 ./ R1) + (1 ./ R2));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% struct2workspace(s)
%   assigns all of the argument's fields to the caller's workspace

function struct2workspace(s)

  % loop over structs
  for m = 1:numel(s)
    
    % get field names
    names = fieldnames(s(m));
    
    % assign them in the caller's workspace
    for n = 1:numel(names)
      assignin('caller', names{n}, s(m).(names{n}));
    end
    
  end
  
end

% s = workspace2struct
%   store variables in the current workspace in the returned struct

function s = workspace2struct
  
  % get the names of variables in the calling function
  names = evalin('caller', 'who');
  
  % assign their values to fields in a struct
  for n = 1:numel(names)
    s.(names{n}) = evalin('caller', names{n});
  end
  
end
