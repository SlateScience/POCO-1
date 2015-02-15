#!/bin/bash -f

POCO_DIST_PATH=$PWD/`dirname $0`

clean=
dobuild=
install=

usage(){
cat << EOF
usage: $0 [options]

Cross-platform build for SpiderMonkey (OSX, IOS and Android)

OPTIONS:
-c  Clean before build
-b  Do actually build
-i  Install after build
-x  Echo all commands
-h  this help

EOF
}

while getopts "cbixh" OPTION; do
case "$OPTION" in
c)
clean=1
;;
b)
dobuild=1
;;
i)
install=1
;;
x)
set -x
;;
h)
usage
exit 0
;;
esac
done

if [[ ! $POCO_SRC_PATH ]]; then
    echo "You have to define POCO_SRC_PATH"
    exit 1
fi

OMITTED_LIBS=Data/ODBC,Data/MySQL
# sudo port upgrade openssl

clean_platform () {
 	echo "Cleaning up $POCO_DIST_PATH/include/Poco/"
   	rm -rf $POCO_DIST_PATH/include/Poco
    cd $POCO_SRC_PATH/
 	echo "Cleaning up $POCO_SRC_PATH/build-$1/"
 	rm -rf dist lib
	./configure --omit=$OMITTED_LIBS
 	make -s clean
 }

install_platform () {
	platform=$1
   	echo Installing $platform
   	cd $POCO_SRC_PATH
   	make -s install
   	echo Copying from dist to $POCO_DIST_PATH
   	set -x
   	cp -r dist/include $POCO_DIST_PATH
   	rm -rf $POCO_DIST_PATH/lib/$platform
   	cp -r dist/lib $POCO_DIST_PATH/lib/$platform 
   	set +x
	cd $POCO_DIST_PATH
   	rm -f lib/$platform/libPoco*d.a
}

build_osx () {
	OPENSSL_INCLUDE=$POCO_DIST_PATH/include

 	echo "Building OS/X"
 	echo "Building for OSX 32-bit"
	./configure --config=Darwin32-clang-libc++ --no-tests --no-samples --omit=$OMITTED_LIBS --static --prefix=$POCO_SRC_PATH/dist --include-path=$OPENSSL_INCLUDE
	make -s -j4

 	echo "Building for OSX 64-bit"
	./configure --config=Darwin64-clang-libc++ --no-tests --no-samples --omit=$OMITTED_LIBS --static --prefix=$POCO_SRC_PATH/dist --include-path=$OPENSSL_INCLUDE
	make -s -j4

	echo "Stitching into one FAT lib for OS/X"
	cd lib
	set -x
	lipo -c Darwin/i386/libPocoCrypto.a Darwin/x86_64/libPocoCrypto.a -o libPocoCrypto.a
	lipo -c Darwin/i386/libPocoData.a Darwin/x86_64/libPocoData.a -o libPocoData.a
	lipo -c Darwin/i386/libPocoDataSQLite.a Darwin/x86_64/libPocoDataSQLite.a -o libPocoDataSQLite.a
	lipo -c Darwin/i386/libPocoFoundation.a Darwin/x86_64/libPocoFoundation.a -o libPocoFoundation.a
	lipo -c Darwin/i386/libPocoNet.a Darwin/x86_64/libPocoNet.a -o libPocoNet.a
	lipo -c Darwin/i386/libPocoNetSSL.a Darwin/x86_64/libPocoNetSSL.a -o libPocoNetSSL.a
	lipo -c Darwin/i386/libPocoUtil.a Darwin/x86_64/libPocoUtil.a -o libPocoUtil.a
	lipo -c Darwin/i386/libPocoXML.a Darwin/x86_64/libPocoXML.a -o libPocoXML.a
	lipo -c Darwin/i386/libPocoZip.a Darwin/x86_64/libPocoZip.a -o libPocoZip.a
	rm -rf Darwin/i386 Darwin/x86_64
	set +x
	cd ..
}

build_ios () {
 	echo "Building for iOS"
   	cd $POCO_SRC_PATH

#Simulator:
 	echo "Building for iOS Simulator"
 	./configure --config=iPhoneSimulator-clang-libc++ --omit=$OMITTED_LIBS --no-tests --no-samples --prefix=$POCO_SRC_PATH/dist --include-path=$OPENSSL_INCLUDE
	make -s -j4

#Device:
	echo "Building for iOS Device"
	./configure --config=iPhone-clang-libc++ --omit=$OMITTED_LIBS --no-tests --no-samples --prefix=$POCO_SRC_PATH/dist --include-path=$OPENSSL_INCLUDE
	echo "Building for iOS/armv7 (32-bit)"
	make IPHONE_SDK_VERSION_MIN=5.0 POCO_TARGET_OSARCH=armv7 -s -j4
	echo "Building for iOS/arm64 (64-bit)"
	make IPHONE_SDK_VERSION_MIN=5.0 POCO_TARGET_OSARCH=arm64 -s -j4

#Then, stitch everything together (the resulting fat libs will end-up in the upper directory):
	echo "Stitching into one FAT lib for iOS"
	cd lib
	set -x
	lipo -c iPhoneSimulator/i686/libPocoCrypto.a iPhoneOS/armv7/libPocoCrypto.a iPhoneOS/arm64/libPocoCrypto.a -o libPocoCrypto.a
	lipo -c iPhoneSimulator/i686/libPocoData.a iPhoneOS/armv7/libPocoData.a iPhoneOS/arm64/libPocoData.a -o libPocoData.a
	lipo -c iPhoneSimulator/i686/libPocoDataSQLite.a iPhoneOS/armv7/libPocoDataSQLite.a iPhoneOS/arm64/libPocoDataSQLite.a -o libPocoDataSQLite.a
	lipo -c iPhoneSimulator/i686/libPocoFoundation.a iPhoneOS/armv7/libPocoFoundation.a iPhoneOS/arm64/libPocoFoundation.a -o libPocoFoundation.a
	lipo -c iPhoneSimulator/i686/libPocoNet.a iPhoneOS/armv7/libPocoNet.a iPhoneOS/arm64/libPocoNet.a -o libPocoNet.a
	lipo -c iPhoneSimulator/i686/libPocoNetSSL.a iPhoneOS/armv7/libPocoNetSSL.a iPhoneOS/arm64/libPocoNetSSL.a -o libPocoNetSSL.a
	lipo -c iPhoneSimulator/i686/libPocoUtil.a iPhoneOS/armv7/libPocoUtil.a iPhoneOS/arm64/libPocoUtil.a -o libPocoUtil.a
	lipo -c iPhoneSimulator/i686/libPocoXML.a iPhoneOS/armv7/libPocoXML.a iPhoneOS/arm64/libPocoXML.a -o libPocoXML.a
	lipo -c iPhoneSimulator/i686/libPocoZip.a iPhoneOS/armv7/libPocoZip.a iPhoneOS/arm64/libPocoZip.a -o libPocoZip.a
	rm -rf iPhoneSimulator/i686 iPhoneOS/armv7 iPhoneOS/arm64
	set +x
	cd ..

    cd $POCO_DIST_PATH
}

build_android () {
 	echo "Building Android"
}

do_platform () {
	if [[ $clean ]]; then
		clean_platform $1
	fi
    
 	if [[ $dobuild ]]; then
		build_$1
    fi 

	if [[ $install ]]; then
   		install_platform $1
	fi
    
}

#do_platform osx
do_platform ios
#do_platform android

if [[ ! $clean ]]; then
	echo "To clean before build run with the -c option:"
	echo "$0 -c"
fi

if [[ ! $dobuild ]]; then
	echo "To actually build run with the -b option:"
	echo "$0 -b"
fi

if [[ ! $install ]]; then
	echo "To install after build run with the -i option:"
	echo "$0 -i"
fi


