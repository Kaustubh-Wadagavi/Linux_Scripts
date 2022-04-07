  a=$#
     for (( i=1;i<=$a;i++ )) 
     do
     if grep -w $i student
     then
     grep –A 4 $i student
     echo
     echo “continue”
     read
     else
     echo “record not found”
     fi
    done
