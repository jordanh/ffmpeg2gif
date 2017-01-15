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

VERSION=0.3.1
SUBJECT=ffmpeg2gif
USAGE="Usage: ffmpeg2gif.sh [-hv -f <framerate> -y <yscale> -s <skip_sec> -t <duration_sec>] input.mov output.gif"

# --- Options processing -------------------------------------------
if [ $# == 0 ] ; then
    echo $USAGE
    exit 1;
fi

framerate=30
yscale=480
skip_sec=-1
duration_sec=-1

while getopts ":f:y:s:t:vh" optname
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
      "s")
        if [[ "$OPTARG" =~ ^[0-9:.]+$ ]]; then
            echo "skip_sec: $OPTARG"
            skip_sec=$OPTARG
        else
            echo "invalid skip_sec \"$OPTARG\"" && exit 1
        fi
        ;;
      "t")
        if [[ "$OPTARG" =~ ^[0-9:.]+$ ]]; then
            echo "duration_sec: $OPTARG"
            duration_sec=$OPTARG
        else
            echo "invalid duration_sec \"$OPTARG\"" && exit 1
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

[[ -z "$inputfile" ]] && echo "no input file specified" && exit -1
[[ -z "$outputfile" ]] && outputfile=$1.gif

# --- Body --------------------------------------------------------
#  SCRIPT LOGIC GOES HERE
echo "input file: \"$inputfile\""
echo "output file: \"$outputfile\""
palettefile=$(mktemp /tmp/$SUBJECT.XXXXXX).png
filters="fps=$framerate,scale=$yscale:-1:flags=lanczos"

optional_params=""
if [ "$skip_sec" != -1 ]; then
  optional_params="-ss $skip_sec"
fi
if [ "$duration_sec" != -1 ]; then
  optional_params="$optional_params -t $duration_sec"
fi

ffmpeg $optional_params -v warning \
  -i "$inputfile" -vf "$filters,palettegen" -y "$palettefile" &&
  ffmpeg $optional_params -v warning -i "$inputfile" -i "$palettefile" \
    -lavfi "$filters [x]; [x][1:v] paletteuse" -y "$outputfile"

if [ -f "$outputfile" ]; then
    outputsize=`du -h "$outputfile" | cut -f1`
    echo "\"$outputfile\" is $outputsize"
fi

rm "$palettefile" 2> /dev/null
exit 0
# -----------------------------------------------------------------
