echo “enter the file name that we have to display”
        read a
        if [ -e $a ]
        then
        echo “enter the nos. of lines”
        read b
        x = ‘wc –l $a’
        if [ $b –le $x ]
        then
        head -$b $a
        else
        echo “entered line is not found”
        fi 
        else
        echo “the file does not exist”
        fi
