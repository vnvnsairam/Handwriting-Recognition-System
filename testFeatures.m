function [guess,writers]=testFeatures(perPerson)

% test the features to see how well they discriminate between writers based
% on single words

words=readData(perPerson, 1, 1, 20, 10, 8);

totalData=1:length(words);

writerList=[];
formList={};

for word=words
    writerList=[writerList getField(word, 'writer')];
    formList{end+1}=getField(word, 'form');
end

% get unique lists of writers and forms
writerSet=unique(writerList);
formSet=unique(formList);

formWriters=zeros(2,length(formSet)); % track who wrote each form in formSet
for i=1:length(formSet)
    formIndex=find(strcmp(formList, formSet{i}));
    formWriters(2, i)=writerList(formIndex(1));
end

[testWriters,testIndices,testForms]=unique(formWriters(2, :)); % get a single form for each writer for the test set
testForms=formSet(testIndices); % record the testing forms
trainIndices=setdiff(1:length(formSet),testIndices); % record the training forms

% split words up into probe and gallery by index
gallery=[];
probe=[];
for i=totalData
    form=formList{i};
    if any(strcmp(testForms, form))
        probe=[probe i];
    else
        gallery=[gallery i];
    end
end

% set up guess and correct
guess=zeros(1,length(probe));
writers=zeros(1,length(guess));

fprintf('Number of probes: %d\n', length(probe));
fprintf('Number of gallery: %d\n', length(gallery));

assert(isempty(intersect(probe,gallery)));

i=1;
for word=words
    wordWriter=getField(word, 'writer');
    if find(writerSet==wordWriter)==i
        wordIm=getField(word, 'im');
        figure(i); imshow(wordIm/max(wordIm(:)));
        i=i+1;
        if i > length(writerSet) break; end
    end
end

formToWriter=zeros(2, length(writerSet), length(testForms));

for i=1:length(probe)

    testWord=words(probe(i));
    writerSim=zeros(1,length(writerSet));
    
    for j=gallery
        
        trainWord=words(j);
        
        s=wordRecordSimilarity(testWord, trainWord);
        
        trainWriter=getField(trainWord, 'writer');        
        writerIndex=find(writerSet == trainWriter);
        
        writerSim(writerIndex)=max(writerSim(writerIndex), s);

    end
    
    [s, guessi]=max(writerSim);

    % get current test form
    form=getField(testWord, 'form');
    formIndex=find(strcmp(testForms, form));

    % update form to writer similarity
    formToWriter(1, guessi, formIndex)=formToWriter(1, guessi, formIndex)+s;
    formToWriter(2, guessi, formIndex)=formToWriter(2, guessi, formIndex)+1;

    guess(i)=writerSet(guessi);
    writers(i)=getField(testWord, 'writer');
    
    fprintf('Test %d, %f%% correct %d => %d with similarity %f\n', i, 100*sum(guess(1:i)==writers(1:i))/i, writers(i), guess(i), s);
end

testGuess=zeros(1, length(testWriters));

for i=1:size(formToWriter, 3)

    % average form to writer similarity
    formToWriter(2, formToWriter(2, :, i)==0, i)=1;
    formToWriter(1, :, i)=formToWriter(1, :, i)./formToWriter(2, :, i);

    % record maximally similar writer
    [s,k]=max(formToWriter(1, :, i));
    testGuess(1,i)=writerSet(k);

end

testGuess
testWriters
sum(testGuess==testWriters)/length(testGuess)

fprintf('Percent correct: %f\n', 100*sum(guess==writers)/length(guess));
