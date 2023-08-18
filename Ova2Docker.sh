#!/bin/bash

#Parameters
#   - 0 : Script name
#	- 1 : OVA file path

if [ "$EUID" -ne 0 ]
then
  echo "Please run this script with sudo"
  exit 1
fi

FILE_EXT=$(basename $1)
FILE=${FILE_EXT%.*}
DIR=$(dirname $1)

cd $DIR

echo "Will extract $1 into a .tar file"
tar -xvf $FILE.ova

files=$(ls *.vmdk)
fileCount=$( ls *.vmdk | wc -l )
#Check that there is only one vmdk file
if [ $fileCount -ge 2 ]
then
    echo "Error, more than one vmdk file found"
    return 1
elif [ $fileCount -eq 0 ]
then
    echo "Error, no vmdk file found"
    return 1
fi

file=$files
echo "Will convert $file into a raw file"
qemu-img convert -f vmdk $file -O raw $FILE.raw

#Display the partition table of a raw disk dump
result_to_split=$(parted -s $FILE.raw unit b print)

start_offset=-1
while IFS= read -r x; do
    if [[ "$x" =~ .*"ext4".* ]]; then
        stringarray=($x) # Convert full string to array 
        start_offset=( ${stringarray[1]//[!0-9]/ } ) #Convert second element to an array with only numbers
        break
    fi
done <<< "$result_to_split"

if [ $start_offset -eq -1 ] 
then 
    echo "Error, no start offset was found for ext4 partition"
    return 1
fi

echo "Start offset is $start_offset"
echo "Will mount file system from $start_offset offset to ./mnt"

mkdir mnt
mount -o loop,rw,offset=$start_offset $FILE.raw ./mnt

#Delete unwanted files
rm -rf mnt/swapfile
mv mnt/home/brainvisa mnt/home/brainvisa_tmp
mkdir mnt/home/brainvisa
mv mnt/home/brainvisa_tmp/.profile mnt/home/brainvisa
mv mnt/home/brainvisa_tmp/.bashrc mnt/home/brainvisa
mv mnt/home/brainvisa_tmp/.bash_logout mnt/home/brainvisa
chown --reference=mnt/home/brainvisa_tmp mnt/home/brainvisa
rm -rf mnt/home/brainvisa_tmp

echo "Remounting image filesystem read-only..."
umount ./mnt
mount -o loop,ro,offset=$start_offset $FILE.raw ./mnt

echo "Will create tar.gz of the filesystem in current directory"
tar -C mnt -czf $FILE.tar.gz .

#Clean behind myself
echo "Now i will clean a little behind myself"
echo "Unmounting image filesystem ..."
umount ./mnt
echo "Deleting image filesystem ..."
rm -rf ./mnt
echo "Deleting all intermediary files ..."
rm -f *.vmdk *.mf *.ovf *.raw

cd ..

echo "Done"

#Parse file name to get name and version for docker registry if needed
#first parameter : variable, here $FILE
#second parameter : first char to get
#third parameter : number of char to parse
label=${FILE:0:9}
num_version=${FILE:10:30}
echo "To import into docker, simply do :    >> docker import $DIR/$FILE.tar.gz registry.hbp.link/hip/app-in-browser/$label-vbox:$num_version"
echo "To push the image to the registry do: >> docker push registry.hbp.link/hip/app-in-browser/$label-vbox:$num_version" 
