#!/bin/bash

sizes=(29 57)
sizes2x=(29 40 57 60)

for i in ${sizes[@]}
do
  convert iTunesArtwork.png -resize "$i"x"$i" Icon-"$i".png
done

for i in ${sizes2x[@]}
do
  convert iTunesArtwork.png -resize "$[ $i * 2 ]x$[ $i * 2 ]" Icon-"$i"@2x.png
done

convert -size 640x1136 xc:white Default-568h@2x.png
