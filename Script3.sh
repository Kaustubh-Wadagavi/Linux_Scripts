# Shell script to read source file and copy it to target file. If the file
# is copied successfully then give message 'File copied successfully'
# else give message 'problem copying file'
# -------------------------------------------------------------------------

echo -n "Enter soruce file name : "
read src
echo -n "Enter target file name : "
read targ
 
if [ ! -f $src ]
then
 echo "File $src does not exists"
 exit 1
elif [ -f $targ ]
then
 echo "File $targ exist, cannot overwrite"
 exit 2
fi
 
# copy file 
cp $src $targ
 
# store exit status of above cp command. It is use to 
# determine  if shell command operations is successful or not
status=$?
 
if [ $status -eq 0 ]
then
 echo 'File copied successfully'
else
 echo 'Problem copuing file'
fi
