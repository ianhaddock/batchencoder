#!/usr/local/bin/bash -e

#source file location 
SOURCE_DIR="/mnt/01-Source"

#handbrake processing folders 
PROCESSING_DIR="/mnt/02-Processing/Processing_Source"
OUTPUT_DIR="/mnt/02-Processing"

#destination folders
COMPLETED_DIR="/mnt/03-Completed/Completed_Source"
MKV_DIR="/mnt/03-Completed/"

FAILED_DIR="/mnt/04-Failed"

HANDBRAKE_PRESET="AppleTV 3"
EXTENSION="mkv"
LOGS="/mnt/Transcode_Source_to_AppleTV3.log"

echo "**** Running Transcode to AppleTV 3 Handbrake script ****";

function stageFiles()
{
 # grab source file or folder from the source directory 
   # check if file or folder has already been encoded before
   if [ -z "$(cat $LOGS | grep $1)" ]; 
   then
    echo "Copying "$1" to Processing directory"
    mv $SOURCE_DIR/$1 $PROCESSING_DIR/$1
    NEW=1;
   else 
    echo "Source "$1" has already been processed. Moving to failed directory."
    mv $SOURCE_DIR/$1 $FAILED_DIR/$1
    NEW=0;
  fi
}


function encodeFiles() 
{
   if [ $NEW -eq 1 ];
   then
    # send source to handbrake using 2 threads and AppleTV 3 settings
    echo "*** Starting Handbrake CLI ***"
    HandBrakeCLI --native-language eng -sF=1 --subtitle-burned --main-feature --min-duration 25 -x threads=2 -i $PROCESSING_DIR/$1 -o $OUTPUT_DIR/$1.$EXTENSION --preset="AppleTV 3" 
    # check for errors.
    if [ $? -eq 0 ];
     then
     # move processed file to completed folder
     echo "Moving "$1" to completed transcoded directory and source to completed source directory."
     mv $OUTPUT_DIR/$1.$EXTENSION $MKV_DIR/$1.$EXTENSION
     # move source file to completed source folder
     mv $PROCESSING_DIR/$1 $COMPLETED_DIR/$1
    else 
     echo "Encoding failed, moving "$i" to Failed directory."
     mv $PROCESSING_DIR/$i $FAILED_DIR/$i 
     # move stub of output file to failed directory
     mv $OUTPUT_DIR/$1.$EXTENSION $FAILED_DIR/$1.$EXTENSION
     NEW=0;
    fi

   else
    echo "*** Skipping "$1" *** ";
   fi
}

function deliverFiles() 
{
   if [ $NEW -eq 1 ];
   then
   # move m4v to Plex once its completed
   #echo "Moving "$1" to Plex" 
   #cp -v $OUTPUT_DIR/$1.$EXTENSION $PLEX_DIR/$1.$EXTENSION
   echo $i" completed "$(date +%m-%d-%y_%H:%M:%S)  >> $LOGS;
   COUNT=$(($COUNT+1)); 
   else 
   echo "Skipping "$1".";
   fi
}


#function rip_dvd() {	 
        # Grab the DVD title
        #DVD_TITLE=$(blkid -o value -s LABEL $SOURCE_DRIVE)
        # Replace spaces with underscores
        #DVD_TITLE=${DVD_TITLE// /_}
        # Backup the DVD to out hard drive
        #dvdbackup -v -@ $SOURCE_DRIVE -o $OUTPUT_DIR -M -n $DVD_TITLE
        # grep for the HandBrakeCLI process and get the PID
        #HANDBRAKE_PID=`ps aux|grep H\[a\]ndBrakeCLI`
        #set -- $HANDBRAKE_PID
        #HANDBRAKE_PID=$2
        # Wait until our previous Handbrake job is done
        #if [ -n "$HANDBRAKE_PID" ]
        #then
        #        while [ -e /proc/$HANDBRAKE_PID ]; do sleep 1; done
        #fi
        # HandBrake isn't ripping anything so we can pop out the disc
        #eject $SOURCE_DRIVE
        # And now we can start encoding
        #HandBrakeCLI -@ $OUTPUT_DIR/$DVD_TITLE -o $OUTPUT_DIR/$DVD_TITLE.$EXTENSION --preset=$HANDBRAKE_PRESET
        # Clean up
        #rm -R $OUTPUT_DIR/$DVD_TITLE
	#cp $OUTPUT_DIR/$DVD_TITLE.$EXTENSION /media/PlexShare/Movies/$DVD_TITLE.$EXTENSION
#}
#rip_dvd



### main thread ###

COUNT=0;

for i in $( ls $SOURCE_DIR);
do
 
    stageFiles $i;
    encodeFiles $i;
    deliverFiles $i;
done

echo "Completed "$COUNT" new DVD Titles."

exit 1;

