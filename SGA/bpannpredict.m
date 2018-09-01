function Y=bpannpredict(net,X)

Y=net(X');
Y=Y';
end