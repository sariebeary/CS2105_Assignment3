if [ $# -ne 1 ]
    then
        echo "Usage: test.sh <BobPort>"
        exit 1
fi


echo "Running Bob..."
cd bob
javac Bob.java
java Bob $1 > bobOutput.txt & 2>&1
cd ..

sleep 3

echo "Running Alice..."
cd alice
javac Alice.java
java Alice sunfire.comp.nus.edu.sg $1 > aliceOutput.txt 2>&1
cd ..

PIDS=$( ps -fu $USER | grep -i "java" | grep -v grep | awk '{print $2}' )

for pid in $PIDS
do
    kill $pid
    echo "killed java process with PID "$pid
done

sleep 1

cmp alice/msgs.txt bob/docs.txt

if [ $? -ne 0 ]
then
    echo "Test failed, possibly due to different encodings."
    echo "We try removing trailing CRLF and try again."
    cat alice/msgs.txt | tr -d '\r\n' > alice/msgs_after.txt
    cat bob/docs.txt | tr -d '\r\n' > bob/docs_after.txt
    cmp alice/msgs_after.txt bob/docs_after.txt
    if [ $? -ne 0 ]
    then
        echo "Test failed."
    else
        echo "Test passed."
        rm -f alice/msgs_after.txt alice/msgs.txt bobs/docs_after.txt
    fi
else
    echo "Test passed."
    rm -f alice/msgs.txt
fi


