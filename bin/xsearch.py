#!/usr/bin/env python
# -*- coding: utf-8 -*-
from menu import selection_menu
import sys
import subprocess
import urllib

#primary selection
buff=""
search_str=""
try:
    buff = subprocess.check_output(['xclip', '-o'],
            stderr=subprocess.STDOUT) # use stderr
    search_str = buff
except subprocess.CalledProcessError as exc:
    buff += exc.output
except:
    buff += str(sys.exc_info())
# will be urllib.parse.quote in python3
quoted = urllib.quote(search_str, safe='')

options = [
    [ 'Google', 'my-web-browser https://www.google.com/search?q=%s'%quoted ],
    [ 'Yandex', 'my-web-browser https://www.yandex.ru/search/?text=%s'%quoted ],
    [ 'Mail.ru','my-web-browser https://go.mail.ru/search?q=%s'%quoted ],
    [ 'StackOverflow', 
      'my-web-browser https://stackoverflow.com/search?q=%s'%quoted ],
]

selection_menu(options,default=0,title='search',label=buff)
