#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from menu import selection_menu
import sys
import subprocess
import urllib.parse

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

quoted = urllib.parse.quote(search_str, safe='')

options = [
    [ 'Google', 'xdg-open https://www.google.com/search?q=%s'%quoted ],
    [ 'Yandex', 'xdg-open https://www.yandex.ru/search/?text=%s'%quoted ],
    [ 'Mail.ru','xdg-open https://go.mail.ru/search?q=%s'%quoted ],
    [ 'StackOverflow', 
      'xdg-open https://stackoverflow.com/search?q=%s'%quoted ],
]

s=selection_menu(options,default=0,title='search',label=buff.decode('utf-8'))
