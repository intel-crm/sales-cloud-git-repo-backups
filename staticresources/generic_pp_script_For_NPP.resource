#!/bin/bash

#get params
PATH=$1
PATH="${PATH%\"}"
PATH="${PATH#\"}"
FILE=$2
#PIMFOLDER=${PATH##*/}
#FOLDER=${PIMFOLDER::-2}
#COMPLETE=Complete_Refurbished.zip
#DELTA=Delta_Refurbished.zip
SearchFile=$4
BUCKET="pim-export"
#Declaring array to store bucketname
declare -a b_arr

#if [ $FILE = "$SearchFile" ]; then
#b_arr=("pim-export")
#fi

#get bucket name

case $3 in
        dev)
        FOLDER="ipa-master-data/dev"
        echo Environment is dev
        ;;

        preprod)
        FOLDER="ipa-master-data/preproduction"
        echo Environment is pre-prod
        ;;

        prod)
        FOLDER="ipa-master-data/production"
        echo Environment is prod
        ;;

        *)
        echo Wrong envmt
        ;;
esac

#zip file
cd $PATH
if [ $? != 0 ]; then
                echo "script failed at step: changing directory path to $PATH"
                exit 1
    fi

echo "changed directory path to $PATH"
/usr/bin/chmod 700 *.txt
if [ $? != 0 ]; then
                echo "script failed at step: modifying permissions"
                exit 1
    fi

echo "modified permissions successfully"
/usr/bin/mkdir test
if [ $? != 0 ]; then
                echo "script failed at step:creation of test dir"
                exit 1
    fi

echo "creation of test dir successful"
/usr/bin/cp *.txt test/
if [ $? != 0 ]; then
                echo "script failed at step: txt files successfully copied to test dir"
                exit 1
    fi

echo "txt files successfully copied to test dir"
cd test
if [ $? != 0 ]; then
                echo "script failed at step: change directory to test"
                exit 1
    fi


#/usr/bin/rename .txt .json *.txt
#if [ $? != 0 ]; then
#                echo "script failed at step: renaming of files to json"
#               exit 1
#   fi

#echo "renaming of files to json successful"


#/usr/bin/zip -r $FILE *.*
#if [ $? != 0 ]; then
#                echo "script failed at step: zipping of files"
#                exit 1
#    fi

#echo "files zipped"

#Move file based on type
if [ $FILE = "$SearchFile" ]
then
	 /usr/local/bin/aws s3 cp $PATH/test s3://$BUCKET/$FOLDER/ --recursive
    
    if [ $? != 0 ]; then
   		echo "copying to s3 bucket failed" 
		exit 1
	fi

	#Adding the below 4 lines of code to enable easy validation of the preprod search file in dev envmt
	#if [ $BUCKET = "pim-feeds-preprod" ]
	#then
	#	/usr/local/bin/aws s3 cp $PATH/test/$FILE s3://pim-feeds-dev/NPP_Export_Files/
	#fi

 /usr/bin/rm -r $PATH/test
if [ $? != 0 ]; then
                echo "script failed at step: removing test dir"
                exit 1
    fi
fi

echo "successfully removed the test dir"
