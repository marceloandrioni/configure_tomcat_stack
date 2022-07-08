#!/bin/bash

# workdir (main directory)
# If you change this here, it will have to be manually changed in:
#   tomcat/setenv.sh
#   thredds/catalog.xml
wd="/usr/local/tds"

jdk_tar="jdk-11.0.15.1_linux-x64_bin.tar.gz"
tomcat_tar="apache-tomcat-8.5.81.tar.gz"
thredds_war="thredds##5.4.war"
ncwms_war="ncWMS2##2.5.2.war"

ncwms_dir=$HOME/.ncWMS2   # default dir for ncWMS2 conf files

[ -s "$jdk_tar" ] || { echo "File $jdk_tar not found, please download the 'x64 Compressed Archive' from https://www.oracle.com/java/technologies/downloads/#java11" ;
                        exit 1 ; }
[ -s "$tomcat_tar" ] || { echo "File $tomcat_tar not found, please download the 'Binary Distributions >> Core >> tar.gz' from https://tomcat.apache.org/download-80.cgi" ;
                          exit 1 ; }
[ -s "$thredds_war" ] || { echo "File $thredds_war not found, please download it from https://www.unidata.ucar.edu/downloads/tds/" ;
                          exit 1 ; }
[ -s "$ncwms_war" ] || { echo "File $ncwms_war not found, please download it from https://github.com/Reading-eScience-Centre/ncwms/releases" ;
                          exit 1 ; }

# create workdir (main directory) and ncwms_dir
for directory in $wd $ncwms_dir; do
    if [ -d "$directory" ]; then

        cat > /dev/tty << EOF
There is already a directory $directory, exiting so no important data is overwritten.
Manually backup the important files and remove the directory before running this script again.
EOF
        exit 1

    else

        echo "Creating directory $directory"
        mkdir -p $directory || { echo "Failed to create directory $directory as user $USER, trying as sudo..." ;
                          sudo mkdir -p $directory ;
                          sudo chown $USER:$USER $directory ; }

    fi
done

echo "Unpacking JDK (Java Development Kit)"
tar -xzvf $jdk_tar -C $wd
jdk=$wd/`basename $jdk_tar _linux-x64_bin.tar.gz`
ln -s $jdk $wd/jdk

echo "Unpacking Tomcat"
tar -xzvf $tomcat_tar -C $wd
tomcat=$wd/`basename $tomcat_tar .tar.gz`
ln -s $tomcat $wd/tomcat

# deploy war pkgs
cp -vf $thredds_war $ncwms_war $wd/tomcat/webapps

# copy Tomcat config files
mkdir -p $wd/content
cp -vf tomcat/setenv.sh $wd/tomcat/bin
cp -vf tomcat/tomcat-users.xml $wd/tomcat/conf

# -----------------------------------------------------------------------------
# start tomcat for the first time

echo "Starting Tomcat"
$wd/tomcat/bin/startup.sh

echo "Waiting 90 seconds to unpack/load everything..."
sleep 90s

echo "Stopping Tomcat"
$wd/tomcat/bin/shutdown.sh

sleep 5s

# -----------------------------------------------------------------------------
# Note: this has to be done AFTER tomcat unpacked the war files and the directory
# tree was created (in $wd/content and $wd/tomcat/webapps)

# copy thredds config files
mkdir -p $wd/datasets/cmems
cp -vf thredds/catalog.xml $wd/content/thredds
cp -vf thredds/cmems_forecast_*.nc $wd/datasets/cmems

# copy ncWMS config files
cp -vf ncwms/config.xml $ncwms_dir

echo "Starting Tomcat"
$wd/tomcat/bin/startup.sh

echo "Waiting 60 seconds to load everything..."
sleep 60s

# -----------------------------------------------------------------------------
# show main webpages

browse http://localhost:8080 &
browse http://localhost:8080/manager &
echo "Use the user/password defined in tomcat-users.xml to log in the manager app."
browse http://localhost:8080/thredds &
browse http://localhost:8080/ncWMS2/Godiva3.html &

echo "Commands to start/stop Tomcat"
echo "$wd/tomcat/bin/startup.sh"
echo "$wd/tomcat/bin/shutdown.sh"

echo "Done!"
