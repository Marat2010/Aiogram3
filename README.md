## Деплой телеграм бота (Aiogram3+Webhook+SSL) на VPS/VDS: 

<u>***!!! Осторожно, скрипты могут затереть ваши файлы!!!***</u>  
<u>***Предполагается установка на вновь созданный сервер!***</u>  

### Описание
Полный цикл работ по размещению бота на Aiogram3 c webhook, SSL на VPS/VDS.  
Проверено на ОС серверов Timeweb, Рег.ру:  Ubuntu 20.04, Ubuntu 22.04.

1. Подключаемся к серверу `ssh root@xxx.xxx.xxx.xxx` .  

2. Скачиваем первый скрипт:  
    ```
    wget https://raw.githubusercontent.com/Marat2010/Aiogram3/master/Scripts/1_start.sh
    ```

3. Делаем скрипт исполняемым:  
   ```
   chmod +x 1_start.sh
    ```

4. Запускаем скрипт (под root-ом):  
    ```
    ./1_start.sh
    ```
    - Установка пакетов: vsftpd, mc, python3-venv
    - Создание пользователя для проекта.
    - Копирование скриптов в каталог пользователя
    - Смена пароля root-а

5. Заходим под созданным пользователем:  
    `# su 'PROJECT_USER'`  
    `$ cd ~`

6. Запускаем второй скрипт (под пользователем):  
    ```
    Scripts/2_venv.sh
    ```
    - Создание проекта
    - Установка и активация вирт. окружения
    - Копирование файлов
    - Установка Aiogram 3.2.0
    - Установка переменных окружения: BOT_TOKEN, DOMAIN_NAME, PROJECT_NAME
    - Подготовка самоподписанного SSL сертификата для домена (IP)
    - Запуск сервиса (SYSTEMD) бота
    
    **Перезайти `$ exit`, `# su 'PROJECT_USER'`, `$ cd ~`**  
    **Или перезагрузиться.**  

7. Запускаем третий скрипт (под пользователем):  
    ```
    Scripts/3_nginx.sh
    ```
    - Установка пакета Nginx
    - Настройка Nginx
    - Копирование примеров страниц сайта
    - Установка переменных окружения: EMAIL_SSL (для cron-а)
    - Перезапуск Nginx

    **Перезайти под root-ом: $ exit, $ exit, # ssh root@xxx.xxx.xxx.xxx**  
     **Или перезагрузиться.**  

8. Запускаем четвертый скрипт (под root-ом) :  
    ```
    Scripts/4_cert.sh
    ```
    - Установка пакета acme-nginx.
    - Установка бесплатных сертификатов SSL (Let's Encrypt) для домена, через acme-nginx
    - Настройка автоматического обновления сертификатов
    - Перезапуск Nginx

    **Всё, проверяем! )**

Для использования ***самоподписанного сертификата без Nginx***, необходимо в **main.py** установить в **True**:  
    >`FROM_ENV_FILE = True`  
    >`SELF_SSL = True`  

После остановить Nginx, и перезапустить службу:  
    ```
    sudo systemctl stop nginx.service

    systemctl daemon-reload

    sudo systemctl restart Aiogram3_bot.service
    ```

**Полное описание на <a href="http://habr.ru" target="_blank">хабре</a>.**  
Видео на [youtube](http://youtube.com).  
Проверял телеграмма бота здесь: [@RuPyBot](https://t.me/RuPytBot).  

