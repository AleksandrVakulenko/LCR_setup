



clc
resp = '-00.00374E-12NADC,+0001547.173645secs,+03951RDNG#'
resp = '+0000.101E+00NVDC,+0001101.615483secs,+00871RDNG#';

% resp = '12.34e+01, 9';

[a, b]=sscanf(resp, "%eNVDC,%esecs,%dRDNG#")



%eNVDC,%esecs,%dRDNG#