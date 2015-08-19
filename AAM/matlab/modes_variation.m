function nmodes = modes_variation(eigVal)

% ------------------------------------------ %
% -- Number of modes of variation to hold -- %
% ------------------------------------------ %

sumEig = sum(eigVal);

nmodes = 0;
total  = 0;
p      = 0.95;

% loop until sum of eigenval is greater than 95perc of all eigenval %
while (total < (p * sumEig)),
  nmodes = nmodes + 1;
  total = total + eigVal(nmodes);
end
