    echo “enter the file that we need to copy” #Accept 1st file from user
        read f1
        echo “enter the file to which the data will be copy” #Accept another file to copy the data
        read f2
       x=2
        for((j=1;j<=$x;j++))     
       do 
       head -$j $f1 >> $f2
       read
       done
       echo “the data successfully copied from the file” 
