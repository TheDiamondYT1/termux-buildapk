#!/data/data/com.termux/files/usr/bin/bash

ANDROID_JAR="/sdcard/android.jar"
INPUT_DIR=$(pwd)
OUTPUT_DIR="gen"
OUTPUT_FILE="app.apk"

show_usage() {
    echo "usage: buildapk [-d input dir][-o output dir][-f output file]"
    echo "Compile and package android applications."
    echo "Example:"
    echo "- buildapk -d /sdcard/app -o build -f lol.apk"
    echo "(None of the aguments required - just execute from same dir as AndroidManifest.xml"
}

set_in_directory() {
    echo -n "Setting input directory to $1..."
    INPUT_DIR=$1
    echo "done"
}

set_out_directory() {
    echo -n "Setting output directory to $1..."
    OUTPUT_DIR=$1
    echo "done"
}

set_out_file() {
    echo -n "Setting output file name to $1..."
    OUTPUT_FILE=$1
    echo "done"
}
   
do_build() {
    if [ ! -f $ANDROID_JAR ]; then
        echo "Error: android.jar not found in $ANDROID_JAR. Aborting..."
        exit 1
    fi
    if [ ! -d $OUTPUT_DIR ]; then
        mkdir $OUTPUT_DIR
    else
        rm -rf $OUTPUT_DIR
        mkdir $OUTPUT_DIR
    fi
    mkdir $OUTPUT_DIR/build
    
    echo -n "Creating R.java..."
    if [ ! -f "$INPUT_DIR/AndroidManifest.xml" ]; then
        echo "fail"
        echo "Error: not an app project. Aborting..."
        exit 1
    fi
    aapt package -m -J $OUTPUT_DIR/build -M ./AndroidManifest.xml -S res -I $ANDROID_JAR
    echo "done"
     
    echo -n "Compilng and dexing source files..."
    jack --output-dex $OUTPUT_DIR/build
    echo "done"
    
    echo -n "Creating apk and adding dexed classes..."
    cd $OUTPUT_DIR
    aapt package -f -M ../AndroidManifest.xml -S ../res -I $ANDROID_JAR -F build/app.apk.unaligned
    aapt add -f build/app.apk.unaligned build/classes.dex
    echo "done"
    
    echo -n "Signing finished apk..."
    apksigner keystore build/app.apk.unaligned $OUTPUT_FILE
    echo "done"
    
    echo "Done! Finished apk is in the $OUTPUT_DIR folder."
    echo "https://github.com/TheDiamondYT1/termux-buildapk"
}

while true; do
    case "$1" in
        -h|--help) show_usage; exit 0;;
        -d|--directory) set_in_directory $2; exit 0;;
        -o|--output) set_out_directory $2; exit 0;;
        -f|--file) set_out_file $2; exit 0;;
        *) do_build; exit 1;;
    esac
done
