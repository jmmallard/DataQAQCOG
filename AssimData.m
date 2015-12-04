%Assimilate data, stitch into coherent time series, and plot

clearvars -except CalhounData
close all

% %Load Calhoun Data
% load('CalhounData.mat')

%Inputs
filename = '100615_C1T1W0_48.csv';
loc = 'C1T1W0_48';

%Check if input location exists in CalhounData, if not add it
if isempty(structfind(CalhounData,'name',loc));
    CalhounData(length(CalhounData)+1).name = 'loc';
end

%Read file(s) and assimilate raw data
importedData = readtable(filename);
dlDate = datestr(datenum(filename(1:6),'mmddyy'),'mmmddyy'); %convert date so it starts with a letter
locI = structfind(CalhounData,'name',loc); %find correct index in CalhounData to match input file
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
ylabel(['Water Level (', CalhounData(locI).data.Properties.VariableUnits{2},')'])
datetick('x')
k = waitforbuttonpress; %Pause to check imported data
close all

%Concatenate imported variables with existing CalhounData.data table
    %First check to only incorporate any non-intersecting data
tempTable = table(datetime,level,watertemp,loggertemp);
[UniqueData, iInput] = setdiff(tempTable,CalhounData.data);
if ~isempty(UniqueData) %Only add data if there is unique data to add
    CalhounData(locI).data = vertcat(CalhounData(locI).data,tempTable(iInput,:));
end

%Plot overall data
plot(CalhounData.data.datetime,CalhounData.data.level)
title(['Data for ', loc])
ylabel(['Water Level (', CalhounData(locI).data.Properties.VariableUnits{2},')'])
datetick('x')
