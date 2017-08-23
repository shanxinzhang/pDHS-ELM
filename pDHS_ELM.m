function predLabel= pDHS_ELM(inputfile,outputfile,species)
% Usage: pDHS_EELM(inputfile,outputfile,species)
% OR:    predLabel= pDHS_EELM(inputfile,outputfile,species)
%
% Input:
% inputfile     - Filename of input  data set in fasta format
% outputfile      - Filename of output result
% species         - species of the model, 
%                        0- represent A.thalian,
%                        1-represent rice
% Output: 
% predLabel          - prediciton results of each sequence
%                            0-represent Non-DHS, 
%                            1-represent DHS.


% Sample 
%predLabel= pDHS_EELM('test.fasta','test.out',0)
%
    %%%%    Authors:    SHANXIN ZHANG
    %%%%   JIANGNAN UNIVERSITY, P.R.CHINA
    %%%%    EMAIL:      SHANXINZHANG@JIANGNAN.EDU.CN
    %%%%    WEBSITE:    http://www.zhangsxbiolag.site/
    %%%%    DATE:       AUG. 2017

%Step 0: Preprocessing- obtain the ID of the input sequence;
[Header, ~] = fastaread(inputfile);
%Step 1: Generation features files
    command=['C:\Python27\python.exe .\Pse-in-One-1.0.3\Pse-in-One\kmer.py -f tab -l +1 -r 1 -k 5 ',inputfile, ' Reckmer.txt DNA'];
     system(command);
     if species==0
        command=['C:\Python27\python.exe .\Pse-in-One-1.0.3\Pse-in-One\pse.py -e user_indices.txt -f tab -l +1  -lamada  4  -w  0.1 ',inputfile,'  SC_PseDNC.txt DNA SC-PseDNC-General'];
         system(command);  
     else
        command=['C:\Python27\python.exe .\Pse-in-One-1.0.3\Pse-in-One\pse.py -e user_indices.txt -f tab -l +1  -lamada  6 -w  0.1 ',inputfile,'  SC_PseDNC.txt DNA SC-PseDNC-General'];
         system(command);  
     end
    %Step 2: load features
    revckmer_data=importdata('Reckmer.txt');
    psednc_data=importdata('SC_PseDNC.txt');
    data=[revckmer_data,psednc_data];
    clear revckmer_data psednc_data;
    %Step 3. predict using base classifiers
    no_base_classifier=25;
    for i=1:no_base_classifier
        %Step 3.1 load models
        if species==0
            model_name=['./TAIR10_model/ELM_model_',num2str(i)];
        else
             model_name=['./TIGR7_model/ELM_model_',num2str(i)];
        end
        %Step 3.2 prediction
       TY = elm_predict(data,model_name);
            for k=1:size(TY,1)
                 [~, label_index_actual]=max(TY(k,:));
                predict_label(k,i)=label_index_actual-1;
            end
    end
    output=sum(predict_label,2);
    predLabel=[];
    for i=1:length(output)
        if output(i)>=ceil(no_base_classifier/2)
            predLabel(i,1)=1;
        else
            predLabel(i,1)=0;
        end
    end
    fid=fopen(outputfile,'w');
    for i=1:length(predLabel)
        if predLabel(i)==1
            fprintf(fid,'The No.%d Sequence, ID=%s, is predicted as DHSs\n',i,Header{i});
        else
            fprintf(fid,'The No.%d Sequence, ID=%s, is predicted as Non-DHSs\n',i,Header{i});
        end
    end
    fclose(fid);
end