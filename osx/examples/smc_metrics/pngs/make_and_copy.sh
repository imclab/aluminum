#/bin/bash

ls 10  | awk '{ printf("../AnalyzeFramesInFolder 10/%s 20 > 10/%s/metric.txt\n", $1, $1) }' | /bin/sh
ls 20  | awk '{ printf("../AnalyzeFramesInFolder 20/%s 40 > 20/%s/metric.txt\n", $1, $1) }' | /bin/sh
ls 30  | awk '{ printf("../AnalyzeFramesInFolder 30/%s 60 > 30/%s/metric.txt\n", $1, $1) }' | /bin/sh
ls 40  | awk '{ printf("../AnalyzeFramesInFolder 40/%s 80 > 40/%s/metric.txt\n", $1, $1) }' | /bin/sh


find 10 -name metric.txt  | awk '{ printf("cp %s /Users/angus.forbes/Dropbox/SubtleMotionCuesProject/mturkQUIZ/userstudy6/videos/%s\n", $1, $1) }' | /bin/sh
find 20 -name metric.txt  | awk '{ printf("cp %s /Users/angus.forbes/Dropbox/SubtleMotionCuesProject/mturkQUIZ/userstudy6/videos/%s\n", $1, $1) }' | /bin/sh
find 30 -name metric.txt  | awk '{ printf("cp %s /Users/angus.forbes/Dropbox/SubtleMotionCuesProject/mturkQUIZ/userstudy6/videos/%s\n", $1, $1) }' | /bin/sh
find 40 -name metric.txt  | awk '{ printf("cp %s /Users/angus.forbes/Dropbox/SubtleMotionCuesProject/mturkQUIZ/userstudy6/videos/%s\n", $1, $1) }' | /bin/sh

