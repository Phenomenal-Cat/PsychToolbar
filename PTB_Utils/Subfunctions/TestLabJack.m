
% TestLabjack.m


lj = labJack('verbose',true);       % Open labJack verbosely
loop=0;
while loop <3
    lj.ledON;
    lj.toggleFIO(1);                    % Toggle FIO1 between low and high
    WaitSecs(1);
    lj.ledOFF;
    lj.toggleFIO(1);                    % Toggle FIO1 between low and high
    WaitSecs(1);
    loop = loop+1;
end
lj.timedTTL(1,200);                 % Send a 200ms timed TTL pulse on FIO2
lj.close;