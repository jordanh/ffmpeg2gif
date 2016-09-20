#!/bin/bash
# ------------------------------------------------------------------
# ffmpeg2gif.sh
# A wrapper for ffmpeg simplify conversion to animated gifs
#
# [Jordan Husney <jordan.husney@gmail.com>]
# ------------------------------------------------------------------
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

VERSION=0.2.0
SUBJECT=ffmpeg2gif
USAGE="Usage: ffmpeg2gif.sh -hv -f <framerate> -u <yscale> input.mov output.gif"

# --- Options processing -------------------------------------------
if [ $# == 0 ] ; then
    echo $USAGE
    exit 1;
fi

framerate=30
yscale=480

while getopts ":f:y:vh" optname
  do
    case "$optname" in
      "v")
        echo "Version $VERSION"
        exit 0;
        ;;
      "f")
        if [[ "$OPTARG" =~ ^[0-9]+$ ]] && [ "$OPTARG" -ge 1 ]; then
            echo "framerate: $OPTARG"
            framerate=$OPTARG
        else
            echo "invalid framerate \"$OPTARG\"" && exit 1
        fi
        ;;
      "y")
        if [[ "$OPTARG" =~ ^[0-9]+$ ]] && [ "$OPTARG" -ge 1 ]; then
            echo "yscale: $OPTARG"
            yscale=$OPTARG
        else
            echo "invalid yscale \"$OPTARG\"" && exit 1
        fi
        ;;
      "h")
        echo $USAGE
        exit 0;
        ;;
      "?")
        echo "Unknown option $OPTARG"
        exit -1;
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        exit -1;
        ;;
      *)
        echo "Unknown error while processing options"
        exit -1;
        ;;
    esac
  done

shift $(($OPTIND - 1))

inputfile=$1
outputfile=$2

[[ -z $inputfile ]] && echo "no input file specified" && exit -1
[[ -z $outputfile ]] && echo "no output file specified" && exit -1

# --- Body --------------------------------------------------------
#  SCRIPT LOGIC GOES HERE
echo "input file: $inputfile"
echo "output file: $outputfile"
palettefile=$(mktemp /tmp/$SUBJECT.XXXXXX).png
filters="fps=$framerate,scale=$yscale:-1:flags=lanczos"

ffmpeg -v warning -i $1 -vf "$filters,palettegen" -y $palettefile &&
    ffmpeg -v warning -i $inputfile -i $palettefile \
      -lavfi "$filters [x]; [x][1:v] paletteuse" -y $outputfile

if [ -f $outputfile ]; then
    outputsize=`du -h $outputfile | cut -f1`
    echo "$outputfile is $outputsize"
fi

rm "$palettefile"
# -----------------------------------------------------------------
