# Выполнено ДЗ №

 - [X] Основное ДЗ
 - [X] Задание со *

## В процессе сделано:
 - Развёрнуто приложение на виртуальной машине в GCP.
 - Добавлено вручную правило для разрешения входящего трафика на сервера с определённым тегом.
 - Написаны скрипты для развёртывания приложения.
 - Скрипты объединены в один и приложение развёрнуто одним скриптом.
 - Скрипт добавлен в качестве файла в команду создание ВМ gcloud.
 - Скрипт добавлен в качестве ссылки на файл в бакете. Бакет сделан публичным.
 - Добавлено из консоли gcloud правило для разрешения входящего трафика на сервера с определённым тегом.

## Команда для создания виртуальной машины с скриптом развёртывания приложения в виде локального файла.
```
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata-from-file startup-script=startup_script.sh
```

## Команда для создания виртуальной машины с скриптом развёртывания приложения в видессылки на файл в бакете.
```
gcloud compute instances create reddit-app\
  --boot-disk-size=10GB \
  --image-family ubuntu-1604-lts \
  --image-project=ubuntu-os-cloud \
  --machine-type=g1-small \
  --tags puma-server \
  --restart-on-failure \
  --metadata startup-script-url=https://storage.googleapis.com/reddit-app/startup_script.sh
```

## Команда для создания правила фаерволла из консоли gcloud
```
gcloud compute firewall-rules create default-puma-server \
    --action allow \
    --direction ingress \
    --rules tcp:9292 \
    --source-ranges 0.0.0.0/0 \
    --target-tags puma-server
```

## Данные для подключения
```
testapp_IP = 35.205.139.96
testapp_port = 9292
```

## Как проверить работоспособность:
 - Перейти по ссылке https://35.205.139.96:9292

## PR checklist
 - [X] Выставил label с номером домашнего задания
 - [X] Выставил label с темой домашнего задания
