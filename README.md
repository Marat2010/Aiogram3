### Деплой телеграм бота (Aiogram3+Webhook) на VPS/VDS: 

1. Подключаемся к серверу `ssh root@xxx.xxx.xxx.xxx` .  

2. Скачиваем первый скрипт:  
    `wget https://raw.githubusercontent.com/Marat2010/Aiogram3/master/Scripts/1_start.sh`  

3. Делаем скрипт исполняемым:  
    `chmod +x 1_start.sh`

4. Запускаем скрипт:  
    `./1_start.sh`  
    - Установка пакетов: vsftpd, mc, 
    - Добавление пользователя.
    - Копирование скриптов в каталог пользователя
    - Смена пароля root-а

5. Заходим под созданным пользователем:  
    `su 'user'`  

6. Запускаем второй скрипт:  
    `Scripts/2_venv.sh`
    - Установка пакетов: python3-venv, mkcert
    - Создание проекта
    - Установка и активация вирт. окружения
    - Копирование файлов
    - Установка Aiogram 3.2.0
    - Установка переменных окружения: BOT_TOKEN, DOMAIN_NAME, PROJECT_NAME, RUN_USER
    - Подготовка SSL сертификата для домена в каталоге SSL

7. Запускаем третий скрипт:  
    `Scripts/3_nginx.sh`
    - Установка пакетов: Nginx
    - Копирование конфиг. файлов
    - Копирование файлов сертификатов


....

**Полное описание на <a href="http://habr.ru" target="_blank">хабре</a>.**  
Видео на [youtube](http://youtube.com).  
Проверяю телеграмма бота здесь: [@RuPyBot](https://t.me/RuPytBot).  
