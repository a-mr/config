#!/bin/sh

#lynx -source http://pogoda.yandex.ru|html2text -utf8|grep °C|head -n1|sed 's/^ *//'
#lynx -source http://pogoda.yandex.ru|html2text|grep °C|head -n1|sed 's/^ *//'

FILE=$HOME/tmp/weather-google
elinks -dump "http://www.google.com/search?hl=en&q=weather" > $FILE
TEMP=$(grep -Eo '[0-9]+°C' $FILE|head -n1)
WIND=$(grep -Eo '[0-9]+ m/s' $FILE|head -n1) 
echo $TEMP, $WIND
rm -f $FILE
