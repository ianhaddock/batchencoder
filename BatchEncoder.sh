#!/bin/bash -e

OUTPUT_DIR="/mnt/dvdstorage/m4v"
PROCESSING_DIR="/mnt/dvdstorage/Processing"
SOURCE_DIR="/mnt/dvdstorage/DVDs"
COMPLETED_DIR="/mnt/dvdstorage/Completed"
PLEX_DIR="/mnt/dvdstorage/Completed"
FAILED_DIR="/mnt/dvdstorage/Failed"
HANDBRAKE_PRESET="AppleTV 3"
EXTENSION="mkv"
LOGS="/mnt/dvdstorage/ripdvd.log"

echo "Running Rip DVD 2";

function stageFiles()
{
 # grab each DVD folder in the source directory 
 # check if DVD has already been encoded here
   if [ -z "$(cat $LOGS | grep $1)" ]; 
   then
    echo "Copying "$1" to Processing directory"
    mv $SOURCE_DIR/$1 $PROCESSING_DIR/$1
    NEW=1;
   else 
    echo "Movie "$1" has already been processed. Moving to Completed directory."
    mv $SOURCE_DIR/$1 $COMPLETED_DIR/$1
    NEW=0;
  fi
}


function encodeFiles() 
{
   if [ $NEW -eq 1 ];
   then
    # send dvd to handbrake using 2 threads and AppleTV 3 settings
    echo "Starting Handbrake CLI"
    HandBrakeCLI --native-language eng -sF=1 --subtitle-burned --min-duration 25 -i $PROCESSING_DIR/$1 -o $OUTPUT_DIR/$1.$EXTENSION -x threads=4 --preset="AppleTV 3" 
    # check for errors.
    if [ $? -eq 0 ];
     then
     # move to completed folder
     echo "Moving "$1" to completed directory"
     mv $PROCESSING_DIR/$1 $COMPLETED_DIR/$1
    else 
     echo "Encoding failed, moving "$i" to Failed directory."
     mv $PROCESSING_DIR/$i $FAILED_DIR/$i 
     NEW=0;
    fi

   else
    echo "Skipping "$1".";
   fi
}

function deliverFiles() 
{
   if [ $NEW -eq 1 ];
   then
   # move m4v to Plex once its completed
   echo "Moving "$1" to Plex" 
   cp -v $OUTPUT_DIR/$1.$EXTENSION $PLEX_DIR/$1.$EXTENSION
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
    #deliverFiles $i;
done

echo "Completed "$COUNT" new DVD Titles."

exit 1;

