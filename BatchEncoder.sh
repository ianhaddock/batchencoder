#!/usr/local/bin/bash -e

OUTPUT_DIR="/mnt/m4v"
PROCESSING_DIR="/mnt/Processing"
SOURCE_DIR="/mnt/DVDs"
COMPLETED_DIR="/mnt/Completed"
PLEX_DIR="/mnt/PlexMovies"
HANDBRAKE_PRESET="AppleTV 3"
EXTENSION="m4v"
LOGS="/var/log/ripdvd.log"

echo "Running Rip DVD" >> $LOGS

# grab each DVD folder in the source directory 
for i in $( ls $SOURCE_DIR); do

   # move to a processng directory
   echo "Copying "$i" to Processing directory" >> $LOGS
   mv $SOURCE_DIR/$i $PROCESSING_DIR/$i

   # send dvd to handbrake using 2 threads and AppleTV 3 settings
   echo "Starting Handbrake CLI" >> $LOGS
   HandBrakeCLI -i $PROCESSING_DIR/$i -o $OUTPUT_DIR/$i.$EXTENSION -x threads=2 --preset="AppleTV 3" 2>> $LOGS

   # move to completed folder
   echo "Moving "$i" to completed directory" >> $LOGS
   mv $PROCESSING_DIR/$i $COMPLETED_DIR/$i

   # move m4v to Plex once its completed
   echo "Moving "$i" to Plex" >> $LOGS 
   cp -v $OUTPUT_DIR/$i.$EXTENSION $PLEX_DIR/$i.$EXTENSION 2>> $LOGS
done


#function rip_dvd() {	 
        # Grab the DVD title
        #DVD_TITLE=$(blkid -o value -s LABEL $SOURCE_DRIVE)
        # Replace spaces with underscores
        #DVD_TITLE=${DVD_TITLE// /_}
        # Backup the DVD to out hard drive
        #dvdbackup -v -i $SOURCE_DRIVE -o $OUTPUT_DIR -M -n $DVD_TITLE
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
        #HandBrakeCLI -i $OUTPUT_DIR/$DVD_TITLE -o $OUTPUT_DIR/$DVD_TITLE.$EXTENSION --preset=$HANDBRAKE_PRESET
        # Clean up
        #rm -R $OUTPUT_DIR/$DVD_TITLE
	#cp $OUTPUT_DIR/$DVD_TITLE.$EXTENSION /media/PlexShare/Movies/$DVD_TITLE.$EXTENSION

#}

#rip_dvd

