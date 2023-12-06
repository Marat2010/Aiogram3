#!/bin/bash

# --- Выполнять под пользователем проекта (не root) ---

#curl https://get.acme.sh | sh -s email=my@example.com
wget -O -  https://get.acme.sh | sh -s email=my@example.com


