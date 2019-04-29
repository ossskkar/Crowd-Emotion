close all, clear all, clc, plt=0;
[x,t] = simplefit_dataset;
net = fitnet(10);
rng(0)
[net tr ] = train(net, x, t);
plt = plt+1, figure(plt), hold on;
plot(log(tr.perf),'b', 'LineWidth', 2)
% plot(log(tr.vperf),'g', 'LineWidth', 2)
plot(log(tr.tperf),'r', 'LineWidth', 2)