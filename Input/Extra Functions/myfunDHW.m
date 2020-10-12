function TotalP = myfunDHW(amp, mu, sigma)


x = max(0.2,mu - 2*sigma):.2:(mu + 2*sigma);

y = amp / (1/(sqrt(2*pi)*sigma))*normpdf(x,mu,sigma);

TotalP = sum(x.*y) ;