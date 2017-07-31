  y = randn(2,4);         % random y values (3 groups of 4 parameters) 
  errY = 0.1.*y;          % 10% error
  h = barwitherr(errY, y);% Plot with errorbars

  set(gca,'XTickLabel',{'Group A','Group B','Group C'})
  legend('Parameter 1','Parameter 2','Parameter 3','Parameter 4')
  ylabel('Y Value')
  set(h(1),'FaceColor','k');
