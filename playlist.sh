#look for the given argument directory for mp3 files
find $1/*.mp3 -printf "%f\n"| cat -n > songlist.text

#if statement to return error if no directory given
if [[ $# -eq 0 ]] ; then
  echo "Warning: No directory given"
  exit 0
fi

#look for previous z variable if the script has been played previously
source var.text 

#declare index value
declare -i x=1 

#if statement to defult z to 0 for first time playback
if [[ $z == "" ]] 
then
declare -i z=0
fi
while [ 1 ] #intialize infinte loop
do
check=`cat checklist.text| tail -1|cut -d " " -f 1` #create value that will act as bookmark for playback if resumed
echo -n > checklist.text #erase log file to decrease errors and save memory
if [[ $check > 0 ]] #intalize check if the script has been played previously
then
z=$((z+1))
while IFS= read -r line; do #playback file from last known playback location
echo $line >> checklist.text #bookmark each line into new log file
echo $line
sleep 3
done < <(tail -n "+$check" formatlist.text) #feed in log file with bookmarked location as check value
fi
echo "z=$z" > var.text #create times played variable and export to text file for import on resume
echo -n > newsonglist.text #clear log file
shuf songlist.text > shufsonglist.text #shuffle songs for next cycle playback
play=shufsonglist.text #push shuffled list as new value
x=1 #intalize index count per cycle
cat $play | while read line #output songlist with index and times played value to text file for later formatting
do
echo "$x $z playing file $line" >> newsonglist.text
x=$((x+1))
done
z=$((z+1)) #increment play count
awk '{print $1," ("$5",",$2"): ",$3,$4,$6}' newsonglist.text > formatlist.text #format final output for desired information
cat formatlist.text | while read line #output formated lines
do
echo $line >> checklist.text #save to log file
echo $line
sleep 3
done
echo -n > checklist.text #clear log file
done #finish then return to start
