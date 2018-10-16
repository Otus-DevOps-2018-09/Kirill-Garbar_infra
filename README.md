# Выполнено ДЗ №

 - [X] Основное ДЗ
 - [X] Задание со *

## В процессе сделано:
 - Созданы две ВМ. Одна с внутренним. Одна с внешним и внутренним IP - пограничный сервер.
 - Проработаны несколько вариантов подключения через proxy по SSH
 - Проработан метод создания алиасов для SSH.
 - Проработана подключение по SSH keys.
 - Развёрнут по инструкции OpenVPN с надстройкой pritunl. Настроено использование с let's encrypt и сервисом sslip.io.

## Подключение к someinternalhost в одну команду. Три способа.
ssh -o ProxyCommand="ssh -i ~/.ssh/appuser appuser@35.187.10.59 nc %h %p" appuser@10.156.0.2
ssh -o ProxyCommand="ssh -W %h:%p -i ~/.ssh/appuser appuser@35.187.10.59" appuser@10.156.0.2
ssh -tt -i ~/.ssh/appuser -A appuser@35.187.10.59 ssh -tt 10.156.0.2

## Вариант решения для подключения командой ssh someinternalhost.
Добавить Host в файл config в директории .ssh.
Host someinternalhost
        HostName 10.156.0.2
        User appuser
        IdentitiesOnly yes
        IdentityFile ~/.ssh/appuser
        ProxyCommand ssh -i ~/.ssh/appuser appuser@35.187.10.59 nc %h %p

## Данные для подключения
- bastion_IP = 35.187.10.59
- someinternalhost_IP = 10.156.0.2

## Как проверить работоспособность:
 - Перейти по ссылке https://35.187.10.59.sslip.io

## PR checklist
 - [X] Выставил label с номером домашнего задания
 - [X] Выставил label с темой домашнего задания
