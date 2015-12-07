%Run this script to save a dated copy of CalhounData to CalhounDataBackup
%folder

pushd('../../CalhounDataMatBackup')

todaysDate = datestr(date,'mmddyy',2000);
save(['CalhounData' todaysDate '.mat'],'CalhounData');

popd %return to previous directory