%Assimilate data, stitch into coherent time series, and plot

clearvars -except CalhounData
close all

% %Load Calhoun Data
% load('CalhounData.mat')

%Inputs
filename = '100615_C1T2W0_55.CSV';
loc = 'C1T2W0_55';

%Check if input location exists in CalhounData, if not add it, metadata,
%and headers (note that headers is currently just applicabple to wells)
if isempty(structfind(CalhounData,'name',loc));
    newI = length(CalhounData)+1;
    CalhounData(newI).name = loc;
    CalhounData(newI).raw = struct();
    CalhounData(newI).meta = input('Enter metadata as cell array of strings: \n')
    CalhounData(newI).headers = CalhounData(1).header;
end

%Read file(s) and assimilate raw data if not already assimilated. If
%assimilated, stop execution and print error message
importedData = readtable(filename,'FileType','text');
dlDate = datestr(datenum(filename(1:6),'mmddyy'),'mmmddyy'); %convert date so it starts with a letter
locI = structfind(CalhounData,'name',loc); %find correct index in CalhounData to match input file
if sum(strcmp(dlDate,fieldnames(CalhounData(locI).raw))) > 0 
    error('Error. \nData downloaded on %s has already been assimilated',dlDate)
end
CalhounData(locI).raw.(dlDate) = importedData; %write raw data as table to variable named for date downloaded

%Convert imported data to numeric arrays with variable names following
%CalhounData.data variable names for specific locations. Variable names in
%imported data are printed to screen and user is prompted to select which
%one (using it's number) corresponds to each of the CalhounData variable names
dates = datenum(importedData.datetime, 'mm/dd/yyyy HH:MM:SS');
datetime = dates;

importedData.Properties.VariableNames %Print variable names from imported data to screen
levelInput = input('# Input variable -> level? enter 0 if none: ');
if levelInput == 0
    level = repmat(-9999,length(dates),1);
else
    level = importedData{:,levelInput}; 
end

importedData.Properties.VariableNames 
wtempInput = input('# Input variable -> watertemp? enter 0 if none: ');
if wtempInput == 0
    watertemp = repmat(-9999,length(dates),1);
else
    watertemp = importedData{:,wtempInput};
end

importedData.Properties.VariableNames %What about situation where this variable does not exist
ltempInput = input('# Input variable -> loggertemp? enter 0 if none: ');
if ltempInput == 0
    loggertemp = repmat(-9999,length(dates),1);
    
else
    loggertemp = importedData{:,ltempInput};
end

%Plot imported data for visual check
plot(datetime,level)
title(['Imported Data DL on: ', dlDate])
ylabel('Water Level')
datetick('x')
k = waitforbuttonpress; %Pause to check imported data
close all

%Concatenate imported variables with existing CalhounData.data table
    %First check to only incorporate any non-intersecting data
tempTable = table(datetime,level,watertemp,loggertemp);
[UniqueData, iInput] = setdiff(tempTable,CalhounData.data); %Find Unique Data
[OverlapData, ~, ~] = intersect(tempTable,CalhounData.data); %Find overlapping data and print max range to screen
dateOne = datestr(OverlapData.datetime(1));
dateEnd = datestr(OverlapData.datetime(end));
disp(['Overlapping data range contained within ',dateOne,' and ',dateEnd]) 

if ~isempty(UniqueData) %Only add data if there is unique data to add
    CalhounData(locI).data = vertcat(CalhounData(locI).data,tempTable(iInput,:));
end

%Plot overall data
plot(CalhounData.data.datetime,CalhounData.data.level)
title(['Data for ', loc])
ylabel(['Water Level (', CalhounData(locI).data.Properties.VariableUnits{2},')'])
datetick('x')
