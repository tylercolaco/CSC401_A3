nums = [18.43,20.80,17.70,22.45,26.19,30.02,27.83,30.75,18.61,23.08,19.98,22.07,26.92,30.57,31.30,33.03,44.98];
total_3_gauss = 0;
for i=1:4
    total_3_gauss = total_3_gauss + nums(i);
end

for i=9:12
    total_3_gauss = total_3_gauss + nums(i);
end

total_7_gauss = 0;
for i=5:8
    total_7_gauss = total_7_gauss + nums(i);
end

for i=13:16
    total_7_gauss = total_7_gauss + nums(i);
end


avg_3_gauss = total_3_gauss/8;
avg_7_gauss = total_7_gauss/8;

disp('increase for 3 to 7 dimensions');
disp(avg_7_gauss-avg_3_gauss);


total_1_state=0;
total_2_state=0;
total_2_gauss=0;
total_4_gauss=0;
total_10_spks=0;
total_15_spks=0;
ctr = 0;
flag = 1;
for i=1:16
    if(mod(i,2))
        total_1_state = total_1_state + nums(i);
    else
        total_2_state = total_2_state + nums(i);
    end
    if(i<9)
        total_2_gauss = total_2_gauss + nums(i);
    else
        total_4_gauss = total_4_gauss + nums(i);
    end
    if(ctr == 2)
        ctr = 1;
        flag = ~flag;
    else 
        ctr = ctr + 1;
    end
    if(flag)
        total_10_spks = total_10_spks + nums(i);
    else
        total_15_spks = total_15_spks + nums(i);
    end
end

avg_1_state=total_1_state/8;
avg_2_state=total_2_state/8;

disp('increase for 1 to 2 states');
disp(avg_2_state-avg_1_state);

avg_2_gauss=total_2_gauss/8;
avg_4_gauss=total_4_gauss/8;

disp('increase for 2 to 4 gauss');
disp(avg_4_gauss-avg_2_gauss);

avg_10_spks=total_10_spks/8;
avg_15_spks=total_15_spks/8;

disp('increase for 10 to 15 spks');
disp(avg_15_spks-avg_10_spks);