
if ~exist('filtZPGQ')
  addpath('/home/tofric/iscmodeling/lentickle/mf');
end


f = logspace(log10(10), log10(1e6), 200);

param = paramTTFSS_cavity(3, f);

[hOL, hCross, hEOM, hPZT, info] = getTTFSS_cavity(param, f);

G = hOL(:,3);

semilogx(f, db(1+G), 'linewidth', 2);


TNI_req = 12000 * (f / 200).^(-1/2);
TNI_req((f<20) | (f>100e3)) = NaN;

SQL_req = 1e6 * ((f / 200).^(-1) .* (f > 200) + ...
                 (f / 200)       .* (f <= 200));
SQL_req((f<10) | (f>10e3)) = NaN;

hold all
plot(f, db(SQL_req), 'color', [1 0 0], 'linewidth', 2);
plot(f, db(TNI_req), 'color', [1 0.5 0], 'linewidth', 2, 'linestyle', '--');
sql_touching_freq = 200;
plot(sql_touching_freq, interp1(f, db(SQL_req), sql_touching_freq), 'o', 'markersize', 10, 'color', [0.1 0 0], 'linewidth', 2)
hold off

line(get(gca,'xlim'), [0 0], 'color', [0 0 0]);
grid on

legend('LIGO TTFSS',  'sub-SQL requirement','TNI requirement', 'SQL touching frequency')

xlabel('frequency [Hz]');
ylabel('frequency noise suppression [dB]');

title('AEI 10m frequency noise suppression requirements');

ylim([-10 150])
set(gca,'ytick', -10:10:150);

set([gca; findall(gca, 'Type','text')], 'FontSize', 16);