#!/bin/bash

echo "<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <title>Nginx ind: Ещё Какой-то сайт </title>
</head>
<body>
    <h2>Nginx ind: Ещё Какой-то сайт (страница ind.html) </h2>
    <h4>Расположен '/var/www/ind' (не корневая папка '/var/www/html') </h4>
    <hr>
    <p style='font-size:16px'>Файл конфигурации <b>/etc/nginx/sites-available/$DOMAIN_NAME.conf</b></p>
    <pre>
        <iframe src='$DOMAIN_NAME.txt' height='330' width='600' style='border:2px solid LightBlue;'></iframe>
    </pre>
    <hr>
</body>
</html>
" > ~/$PROJECT_NAME/Nginx/www/ind/ind.html
