#!/bin/bash

echo "<!DOCTYPE html>
<html lang='en'>
<head>
    <meta charset='UTF-8'>
    <title>Nginx: Какой-то текущий сайт</title>
</head>
<body>
    <h1> Nginx: Какой-то текущий сайт </h1>
    <h4> Расположен в корне /var/www/html </h4>
    <hr>
    <p style='font-size:16px'>Файл конфигурации <b>/etc/nginx/sites-available/$DOMAIN_NAME.conf</b></p>
    <pre>
        <iframe src='$DOMAIN_NAME.txt' height='330' width='600' style='border:2px solid skyblue;'></iframe>
    </pre>
    <hr>
</body>
</html>
" > ~/$PROJECT_NAME/Nginx/www/html/index.html

