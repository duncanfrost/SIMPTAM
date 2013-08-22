clear all;
close all
load E;

bar = ones(18,1)*73.8563 / 199;
E = E/199;
plot(E,'bx-');
hold on;
plot(bar,'r');
xlim([1 18]);
ylim([0.15 0.5]);
hold off;
ylabel('Mean Landmark Error');
xlabel('Keyframe');
legend('Bundle Adjustment with Constraints','Pure Bundle Adjustment');
title('Mean landmark error vs. keyframe in which a single constraint is found');

figure;
load EAC;
EAC = mean(EAC,2);
EAC = EAC/199;
plot(EAC,'bx-');
hold on;
plot(bar(1:5),'r');
xlim([1 5]);
ylim([0.15 0.5]);
ylabel('Mean Landmark Error');
xlabel('Constraints per Keyframe');
legend('Bundle Adjustment with Constraints','Pure Bundle Adjustment');
title('Mean landmark error vs. number of constraits for every keyframe');