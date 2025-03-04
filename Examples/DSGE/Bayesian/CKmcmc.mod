// The two shock model
// This takes steady state of hours as given, and computes the psi
// parameter that corresponds.
close all;

var y c k n invest z1 z2 MUC MUL r w;
varexo e1 e2;

parameters alppha betta delta gam  nss rho1 sigma1 rho2 sigma2 psi c1 iss yss kss css;
set_param_value('alppha',0.33)
set_param_value('betta', 0.99)
set_param_value('delta',0.025)
set_param_value('gam', 2.0)
set_param_value('rho1', 0.9)
set_param_value('sigma1', 0.02)
set_param_value('rho2', 0.7)
set_param_value('sigma2', 0.01)
set_param_value('nss', 1/3)

model;
  MUC = (c)^(-gam);
  MUL = psi*exp(z2);
  r = alppha * exp(z1) * (k(-1))^(alppha-1) * n^(1-alppha);
  w = (1-alppha)*exp(z1)* (k(-1))^alppha * n^(-alppha);
  MUC = betta*MUC(+1) * (1 + r(+1) - delta);
  MUL/MUC = w;
  z1 = rho1*z1(-1) + sigma1*e1;
  z2 = rho2*z2(-1) + sigma2*e2;
  y = exp(z1) * ((k(-1))^alppha) * (n^(1-alppha));
  invest = y - c;
  k = invest + (1-delta)*k(-1);
end;

shocks;
var e1 = 1;
var e2 = 1;
end;

steady_state_model;
c1 = ((1/betta + delta - 1)/alppha)^(1/(1-alppha));
kss = nss/c1;
iss = delta*kss;
yss = kss^alppha * nss^(1-alppha);
css = yss - iss;
psi =  (css^(-gam)) * (1-alppha) * (kss^alppha) * (nss^(-alppha));
k = kss;
n = nss;
c = css;
y = yss;
invest = iss;
MUC = c^(-gam);
r = alppha  * k^(alppha-1) * n^(1-alppha);
w = (1-alppha)* (k)^alppha * n^(-alppha);
MUL = w*MUC;
z1 = 0;
z2 = 0;
end;


estimated_params;
 betta, uniform_pdf, , ,  0.95, 0.9999; 
 gam, uniform_pdf, , , 0.0,  5.0;
 rho1, uniform_pdf, , , 0.0,  1.0; 
 sigma1, uniform_pdf, , , 0.0,  0.1;
 rho2, uniform_pdf, , ,   0.0,  1.0; 
 sigma2, uniform_pdf, , , 0.0,  0.1;
 nss, uniform_pdf, , , 6/24, 9/24; 
end;

varobs c n;  // experiment choosing one or two from y c n MPK MPL (c and n work well)

// short MCMC for illustration only 
estimation(order=1, datafile=dsgedata, nobs=160, mh_replic=10000, mh_nblocks=1, mh_jscale=0.8, mh_init_scale=5, irf=40);


