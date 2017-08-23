function TY= elm_predict(TestingData_File,Model_name)

REGRESSION=0;
%CLASSIFIER=1;

%%%%%%%%%%% Load testing dataset

test_data=TestingData_File;
%TV.T=test_data(:,1)';
%TV.P=test_data(:,2:size(test_data,2))';
TV.P=test_data';
clear test_data;                                    %   Release raw testing data array

NumberofTestingData=size(TV.P,2);

%load elm_model.mat;
load([Model_name,'.mat']);

%%%%%%%%%%% Calculate the output of testing input
%start_time_test=cputime;
tempH_test=InputWeight*TV.P;
clear TV.P;             %   Release input of testing data             
ind=ones(1,NumberofTestingData);
BiasMatrix=BiasofHiddenNeurons(:,ind);              %   Extend the bias matrix BiasofHiddenNeurons to match the demention of H
tempH_test=tempH_test + BiasMatrix;
switch lower(ActivationFunction)
    case {'sig','sigmoid'}
        %%%%%%%% Sigmoid 
        H_test = 1 ./ (1 + exp(-tempH_test));
    case {'sin','sine'}
        %%%%%%%% Sine
        H_test = sin(tempH_test);        
    case {'hardlim'}
        %%%%%%%% Hard Limit
        H_test = hardlim(tempH_test);        
        %%%%%%%% More activation functions can be added here        
end
TY=(H_test' * OutputWeight)';                       %   TY: the actual output of the testing data
TY=TY';
end