function result = gmmClassify( dir_test, theta )
files = dir(strcat(dir_test,'/*.mfcc'));

%to get each data file load
test_file = load(strcat(dir_test,'/',files(1).name));


result = 1;
end