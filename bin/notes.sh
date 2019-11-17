#!/usr/bin/env bash

if [ -d ~/activity-personal/draft_mak/new_diary ]; then
  exec vim ~/activity-personal/draft_mak/new_diary/`date +%g%m`.txt
else
  mkdir -p ~/activity-public/diary
  exec vim ~/activity-public/diary/`date +%g%m`.txt
fi

