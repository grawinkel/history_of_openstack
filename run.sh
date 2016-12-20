#!/bin/bash

# Author: Matthias Grawinkel <meatz@quobyte.com>
# get list of all openstack/ projects from here: https://git.openstack.org/cgit
# script based on https://github.com/acaudwell/Gource/wiki/Visualizing-Multiple-Repositories

function add() {
  git clone https://github.com/openstack/$1.git
  gource --output-custom-log $1.txt $1

  #add project name as root
  sed -i -r "s#(.+)\|#\1|/$1#" $1.txt
}

function prepare() {
mkdir output
cd output
for pname in `cat ../project_names`; do
  add $pname
done

for f in *.txt; do
  cat $f >> all.txt
done

cat all.txt | sort > sorted.txt

}

FRAMERATE=60

function visualize() {
cd output
gource sorted.txt \
-1920x1080 \
--key \
--user-scale 1.5 \
--date-format "%Y-%m-%d" \
--hide root,bloom,mouse,filenames,dirnames \
--seconds-per-day 0.01 \
--title "History of all OpenStack repositories" \
--output-framerate ${FRAMERATE} \
--caption-file ../openstack_releases_captions.txt \
--caption-size 80 \
--caption-duration 12 \
-o - | ffmpeg -y -r ${FRAMERATE} -f image2pipe -vcodec ppm -i - -vcodec \
libx264 -preset slow -pix_fmt yuv420p -crf 18 -threads 0 \
openstack.mp4
}

prepare
visualize

