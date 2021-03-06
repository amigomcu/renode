#!/bin/bash

set -e
set -u

#change dir to script location
cd "${0%/*}"
. common_make_packages.sh

# create MacOS app structure
MACOS_APP_DIR=Renode.app
PACKAGES=output/packages
OUTPUT=$BASE/$PACKAGES
mkdir -p $MACOS_APP_DIR/Contents/{MacOS,Resources}/

DIR=$MACOS_APP_DIR/Contents/MacOS

SED_COMMAND="sed -i''"
. common_copy_files.sh

cp macos/macos_run.sh $MACOS_APP_DIR/Contents/MacOS
cp macos/macos_run.command-license $MACOS_APP_DIR/Contents/MacOS
cp macos/Info.plist $MACOS_APP_DIR/Contents/
cp macos/renode.icns $MACOS_APP_DIR/Contents/Resources #Made with png2icns

COMMAND_SCRIPT=$MACOS_APP_DIR/Contents/MacOS/macos_run.command
MONO_MAJOR=`echo $MONOVERSION | cut -d'.' -f1`
MONO_MINOR=`echo $MONOVERSION | cut -d'.' -f2`
echo "#!/bin/sh" >> $COMMAND_SCRIPT
echo "REQUIRED_MAJOR=$MONO_MAJOR" >> $COMMAND_SCRIPT
echo "REQUIRED_MINOR=$MONO_MINOR" >> $COMMAND_SCRIPT
# skip the first line (with the hashbang)
tail -n +2 macos/macos_run.command >> $COMMAND_SCRIPT
chmod u+x $COMMAND_SCRIPT

mkdir -p $OUTPUT
hdiutil create -volname Renode_$VERSION -srcfolder $MACOS_APP_DIR -ov -format UDZO $OUTPUT/renode_$VERSION.dmg

#cleanup unless user requests otherwise
if $REMOVE_WORKDIR
then
  rm -rf $MACOS_APP_DIR
fi
