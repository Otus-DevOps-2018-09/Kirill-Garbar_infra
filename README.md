#HW-3
## В процессе сделано:
 - Созданы две ВМ. Одна с внутренним. Одна с внешним и внутренним IP - пограничный сервер.
 - Проработаны несколько вариантов подключения через proxy по SSH
 - Проработан метод создания алиасов для SSH.
 - Проработана подключение по SSH keys.
 - Развёрнут по инструкции OpenVPN с надстройкой pritunl. Настроено использование с let's encrypt и сервисом sslip.io.

## Подключение к someinternalhost в одну команду. Три способа.
- ssh -o ProxyCommand="ssh -i ~/.ssh/appuser appuser@35.187.10.59 nc %h %p" appuser@10.156.0.2
- ssh -o ProxyCommand="ssh -W %h:%p -i ~/.ssh/appuser appuser@35.187.10.59" appuser@10.156.0.2
- ssh -tt -i ~/.ssh/appuser -A appuser@35.187.10.59 ssh -tt 10.156.0.2

## Вариант решения для подключения командой ssh someinternalhost.
Добавить Host в файл config в директории .ssh.
```
Host someinternalhost
        HostName 10.156.0.2
        User appuser
        IdentitiesOnly yes
        IdentityFile ~/.ssh/appuser
        ProxyCommand ssh -i ~/.ssh/appuser appuser@35.187.10.59 nc %h %p
```

## Данные для подключения
```
bastion_IP = 35.187.10.59
someinternalhost_IP = 10.156.0.2
```

## Как проверить работоспособность:
 - Перейти по ссылке https://35.187.10.59.sslip.io
 
 
 #HW-4
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

#HW-5
## В процессе сделано:
 - Выдали доступ приложению Packer к GCP.
 - Создали по инструкции базовый образ ubuntu с установленными ruby и mongodb и задеплоили в него приложение.
 - Добавили в созданный шаблон несколько переменных, файл variables.json. ID проекта, семейство базовых образов, тип машины, имя предсозданного диска, размер диска(не был учтён, т.к. предсозда был диск другого размера), тип диска, описание образа, название предсозданной сети.
 - Создали образ семейства reddit-full, добавив в него systemd unit для автозагрузки веб-сервера Puma с приложением и деплой приложения.
 - Добавили скрипт создания машины из готового образа redit-full.

## Как проверить работоспособность.
 - Выполнить команду из корня репозитория packer build immutable.json.
 - Выполнить скрипт config-scripts/create-reddit-vm.sh. Запомнить IP.
 - Добавить правило firewall, разрешающее входящий трафик на порт TCP 9292.
 - Пройти по ссылке http://IP:9292.
