#!/bin/bash

##############################################################################
# Script to generate a DMG from an App Bundle.
#
# Generating a pretty DMG file programmatically is a bit of an art.  Many
# thanks to the appdmg project for showing how:
# (https://github.com/LinusU/node-appdmg)
#


function usage() {
    cat <<EOF
A skeleton program.

Usage: ${SCRIPTNAME} [OPTIONS] APPBUNDLE

  APPBUNDLE             App Bundle to read.

  -o DMGFILE            DMG file to produce.  Default is same as App Bundle
                        name with the .dmg extension.

EOF
}


function main() {
    local OPTIND OPTARG OPTERR opt
    local appfile dmgfile
    local exitcode=0

    # Process options
    while getopts "o:h" opt; do
        case "$opt" in
            o)  dmgfile=$OPTARG ;;
            h)  usage && exit 0 ;;
            *)  exitcode=1
        esac
    done
    shift $((OPTIND-1))

    appfile=$1
    [[ -z "${dmgfile-}" ]] && dmgfile=$(basename "$appfile" .app).dmg

    # Sanity check
    [[ -z "$appfile" ]] && printf "Invalid argument count!\n" 1>&2 && exitcode=1
    (( exitcode )) && usage 1>&2 && exit $exitcode

    build-dmg "$appfile" "$dmgfile"
}


function build-dmg() {
    local BUNDLE=$1
    local FINAL_DMG=$2
    local TEMP_DMG="temp.dmg"
    local TEMP_DMG_SIZE=$(( $(du -sm "$BUNDLE" | cut -f1) * 15 / 10 ))m
    local VOLNAME=$(basename "$BUNDLE" .app)
    local ICON="${BUNDLE}/Contents/Resources/tuxpaint.icns"
    local BACKGROUND="background.png"
    local VOLUME

    echo "   * Creating the temporary image for ${FINAL_DMG}..."
    hdiutil create "$TEMP_DMG" -ov -fs HFS+ -size "$TEMP_DMG_SIZE" -volname "$VOLNAME" \
    && VOLUME=$(hdiutil attach "$TEMP_DMG" -nobrowse -noverify -noautoopen | grep Apple_HFS | sed 's/^.*Apple_HFS[[:blank:]]*//') \
    || exit 1

    if [[ -r "$BACKGROUND" ]]; then
        echo "   * Adding the image background for ${FINAL_DMG}..."
        mkdir "$VOLUME/.background" \
        && tiffutil -cathidpicheck "$BACKGROUND" -out "$VOLUME/.background/background.tiff" \
        || exit 1
    fi

    echo "   * Setting the folder icon for ${FINAL_DMG}..."
    cp "$ICON" "$VOLUME/.VolumeIcon.icns" \
    && /usr/bin/SetFile -a C "$VOLUME" \
    || exit 1

    echo "   * Copying the contents for ${FINAL_DMG}..."
    cp -a "$BUNDLE" "$VOLUME" \
    && cp -a "DMG/Read Me.rtf" "$VOLUME/Read Me.rtf" \
    && cp -a "DMG/DS_Store" "$VOLUME/.DS_Store" \
    || exit 1

    echo "   * Configuring the folder to open upon mount for ${FINAL_DMG}..."
    bless --folder "$VOLUME" --openfolder "$VOLUME" \
    || exit 1

    echo "   * Unmounting the temporary image for ${FINAL_DMG}..."
    hdiutil detach "$VOLUME"

    echo "   * Creating the final image ${FINAL_DMG}..."
    hdiutil convert "$TEMP_DMG" -ov -format "UDBZ" -imagekey "zlib-level=9" -o "$FINAL_DMG"

    echo "   * Deleting the temporary image for ${FINAL_DMG}..."
    rm -f "$TEMP_DMG"
}


main "$@"
