[![Build Status](https://travis-ci.com/Otus-DevOps-2018-09/Kirill-Garbar_infra.svg?branch=master)](https://travis-ci.com/Otus-DevOps-2018-09/Kirill-Garbar_infra)

# HW-3
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
 
 
 # HW-4
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

# HW-5
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

# HW-6
## В процессе сделано:
 - Удалили ключ из метаданных проекта, чтобы протестировать добавление ключа через метаданый ресурса.
 - Я перевёз средство разработки из Linux nano в MS VS Code. Пришлось заново настроить аутентификацию пакера и терраформа в gcloud.
 - Создали ВМ из образа reddit-base. Посмотрели tfstate, грепнули его, чтобы получить IP-адрес.
 - Создали output переменные. После редактирования ВМ сразу в консоль выводился IP-адрес.
 - Создали ресурс правило фаерволла для нашего приложения. Удалил старое правило из прошлых дз для чистоты эксперимента.
 - Добавили provisioners для деплоя приложения, добавили systemd unit из прошлого ДЗ со *.
 - Добавили входные переменные.
 - Использовали полезную команду terraform fmt для автоматического форматирования конфигов терраформа.
 - Пометили ВМ для пересоздания командой terraform taint.resource_type.resource_name.
 - Добавили несколько юзеров с ключами в метаданные проекта. Изменения применились не сразу, т.к. у меня в ЛК были созданы ещё какие-то старые экспериментальные ключи. Конфиг применился только после ручного удаления юзеров. Было бы неплохо этот эксперимент добавить в ДЗ.
 - Последующее добавление вручную и применение конфига удалило вручную созданных юзеров.
 - Изучили метод создания load balancer в GCP и в Terraform. В конфигах есть комментарии к ресурсам. Что можно ещё добавить в конфигурацию приложения: 1. Добавить внутренние адреса для инстансов приложений, оставить внешний адрес только у балансера. 2. Добавить репликацию/честную кластеризацию БД.
 - Изучили метод параметризации количества инстансов ВМ с приложением.

## Проблемы при добавлении ключей:
 - Изменения применились не сразу, т.к. у меня в ЛК были созданы ещё какие-то старые экспериментальные ключи. Конфиг применился только после ручного удаления юзеров. Было бы неплохо этот эксперимент добавить в ДЗ.

## Недостатки LB конфигурации.
 - При добавлении дополнительного ресурса ВМ необходимо в нескольких местах поменять конфиги. 1. Добавить ресурс ВМ. 2. Добавить ВМ в instance_group. 3. Добавить IP в output (для сохранения шаблонности).
 - При изменении конфигурации ВМ в ТФ необходимо добавить изменения в нескольких ресурсах.

## Что можно ещё добавить в конфигурацию приложения:
 - Добавить внутренние адреса для инстансов приложений, оставить внешний адрес только у балансера.
 - Добавить репликацию/честную кластеризацию БД.
 - Сейчас health-check работает только по недоступности приложения. Желательно, чтобы работала по превышению нагрузки, по кодам ответа HTTP. Чтобы работало распределение пользователей по прозрачным правилам, например, приблизительное непревышение разницы метрик нагрузки.

 # HW-7
 ## В процессе сделано
 - Импортировали правило файерволла, разрешающее подключение по SSH к машинам. Это было сделано, т.к. добавление правила с таким же именем вызывло конфликт, т.к. ТФ ничего не знал об этом правиле, т.к. в state-файле не было такой информации.
 - Изучили вопрос явных и неявных связей между ресурсами. Обратили вниманиеd в каком порядке добавляются и удаляются зависимые ресурсы.
 - Кроме неявных зависимостей, у всех ресурсов есть мета-параметр depends-on, который добавляет явную зависимость от ресурса. В доках и в гугле не нашёл нормального способа добавить зависимость в ресурсы одного модуль от ресурсов другого модуля.
 - Пакером разбили виртуалку с приложением и БД на две виртуалки: приложение и БД.
 - В ТФ так же разбили ресурс с ВМ на два ресурса: приложение и БД, созданные из образов, которые запаковали в пакере.
 - В конфиг ТФ приложения добавили правило файерволла, разрешающее доступ по порту 9292, а в конфиг ТФ БД добавили правило, разрешающее доступ к монге по 27017.
 - Оставшуюсь конфигурацию разбили по файлам main.tf, описывающий провайдер GCP и файл vpc.tf, описывающий правило доступа по ssh.
 - Далее конфигурации БД и приложения разбили по модулям, которые подключаются в основном файле main.tf.
 - Добавили модуль vpc.tf c переменной IP источника, чтобы для прода ограничивать доступ по SSH, а для препрода нет.
 - Добавили из реестра модулей модуль, создающий bucket'ы в GCP. Создали два бакета, для препрода и прода.
 - Настроили хранение стейтов в бакетах. Проверили, что при инициализации терраформа в директории с созданными конфиг файлами стейт берётся из бакета. Это ОЧЕНЬ удобно. Это позволяет не заботиться о хранении актуального стейта.
 - Проверили одновременное изменение конфигурации - не работает. Не работает даже terraform plan, что логично. Бакет не даёт прочитать state.
 - Добавили provisioners в DB и APP. В DB нужно изменть конфиг mongo, чтобы демон слушал не только локалхост. В APP нужно добавить переменную IP адрес сервера БД, которая запишется в unit. Нельзя добавить при деплое, т.е. приложение при каждом запуске берёт IP адрес из переменной.
 - Добавили запуск provisioners с условием. Добавляется null_resourse, который может запускаться по триггеру. Можно запускать по изменению, можно по равенству переменной чему-либо (тернарный оператор на count). Недостатком такой конфигурации является то, что при force пересоздании (taint), нужно помечать оба ресурса, и родительский, и null_resourse. Нужно как-то в триггеры добавить условие пересоздания родительского ресурса.

## Как проверить работоспособность.
 - Забрать проект c git.
 - Создать terraform.tfvars из terraform.tfvars.example, указать новый проект.
 - Перейти в директорию terraform.
 - Выполнить terraform init и terraform apply(Команда создаст бакет для хранения tfstate).
 - Перейти в директорию stage. Создать terraform.tfvars из terraform.tfvars.example, указать свой проект и заполнить другие переменные. Если необходимо добавить provisioners, указать переменную provisioner_condition = 1.
 - Выполнить terraform init и terraform apply(Команда создаст инфраструктуру с приложением).

 # HW-8
 ## В процессе сделано
 - Интегрировал своё окружение на Windows с Linux. Git остался на Windows, в Linux подключил раздел по cifs.
 - Установили Python2.7, pip, Ansible.
 - Заполнили инвентори в формате ini, конфиг, попинговали хосты.
 - Перевели инвентори в формат YAML.
 - Сравнили shell/command, command/service/systemd, command/git.
 - Написали просто плейбук на git clone. См. наблюдения в следующем пункте.
 - Ознакомились с форматом JSON инвентори. Используется для автоматизации получение инвентори.
 - Два формата. Практически плоский JSON со ссылочной структурой родитель-ребёнок и JSON с иерархической структурой (копия YAML). Первый нужно "скормить" Ansible в виде исполняемого скрипта, который возвращает JSON, второй возможно "скормить" в виде файла (команды см. в п. ниже).

 ## Выполнение простого плейбука.
 - Первый раз выполнили плейбук, когда приложение уже было склонировано. Ansible вернул по всем шагам OK. Удалили склонированный репозиторий и снова выполнили ту же команду. Ansible вернул changed по задаче клонирования репозитория.

 ## Команды для использования JSON инвентори.
```
ansible app -m ping -i get-inventory.sh
ansible app -m ping -i inventory.json
```

## Как проверить работоспособность.
- Забрать ветку ansible-1.
- Перейти в директорию terraform/stage
- Выполнить terraform init && terraform apply, получить IP адреса (ключи пользователя appuser должны быть в домашней директории ~/.ssh).
- Заменить IP адреса из инвентори (8.8.8.8 и 9.9.9.9).
- Выполнить команды из п. выше.

# HW-9
## В процессе сделано.
- Добавили в gitignore маску для временных файлов Ansible.
- Написали playbook с одним task внутри. Запускали, фильтруя этапы таска по тэгам, а хосты ключом --limit.
- Переписали playbook на несколько тасков. В каждый добавили ограничение по тэгам. Фильтр по --limit больше не нужен.
- Разбили три таска на три playbook: app.yml, db.yml, deploy.yml и директивой import_playbbok добавили их в корневой playbook.
- Изменили provisioners в packer с баш-скриптов на Ansible и пересобрали образы.
- Про выбор dynamic inventory написал в следующем пункте.
- Чтобы dynamic inventory заработал, я изменил hosts в наших playbook на те, которые описаны в GCP (reddit-app, reddit-db).
- Чтобы вручную не конфигурить внутренний адрес монги, научился работать с хостовыми перменными "{{ hostvars['reddit-db']['gce_private_ip'] }}".

## Подбор метода получения инвентори из GCP.
- В качестве dynamic inventory я выбрал gce.py. Кроме этого популярного решения на python были варианты получать инвентори через TF. Завязываться на TF я посчитал излишним. Все эти решения одинаковы с точки зрения функционала для наших нужд. Директорию с настройками div_env я целиком добавил в gitignore.

## Как проверить работоспособность.
- Забрать ветку ansible-2.
- Перейти в корневую директорию и выполнить
```
packer build packer/app.json
packer build packer/db.json
```
- Перейти в директорию terraform/stage.
- Выполнить terraform init && terraform apply (ключи пользователя appuser должны быть в домашней директории ~/.ssh). Запомнить app_external_ip.
- Настроить gce dynamic inventory и положить его в директорию dyn_inv.
- Перейти в директорию ansible и выполнить ansible-playbook site.yml.
- Перейти в браузере по ссылке http://app_external_ip:9292.

# HW-10
## В процессе сделано.
- Создали роли для db и app.
- Прикрутил dynamic inventory. Скрипт и ini файл лежит в директориях prod и stage. Не увере, что это правильно, но по-другому не читаются переменные group_var и host_vars.
- Создали структуру environments. В директориях stage и prod свои inventory, свои переменные (group_vars, host_vars). gce.py группирует хосты, создавая тэги tag_hostname.
- Распределили таски, хэндлеры, переменные и т.д. по структуре директорий роли. defaults - переменные по-умолчанию; files; handlers; meta - метаинформация, зависимости; tasks - таски; templates - шаблоны; tests; vars; Переменные задаются в директории environments для каждого окружения.
- Добавили переменную env, чтобы при выполнении playbook всегда видеть, на каком окружении он выполняется.
- Переместили playbooks в отдельную директорию.
- Переместили устаревшие данные в директорию old.
- Добавили вывод diff.
- Добавили роль nginx из ansible-galaxy и настроили на проксирование с 80 порта. Открыли 80 порт в TF. Не стали закрывать порт 9292.
- Создали пользователей на виртуалках, зашифровав credentials.yml с помощью ansible-vault.
- Добавили инфраструктурные тесты: packer validate, terraform validate, tflint, ansible-lint
- Badge со статусом билда добавил только для ветки master. Ветка хардкодится в ссылке в README. Варианты решения: 1. добавлять ссылку на свой сервис, который по хэдеру запроса сформирует ссылку на бэйдж и добавить в README; 2. Сделать precommit hook, который будет заменять ссылку на бэйдж в тревисе при каждом коммите. Вариант 1 не подходит из-за своей костыльности. Вариант 2 подходит. В жизни долгоживущие ветки создаются редко и для них так и так README пишутся вручную, поэтому можно забить динамически формировать ссылку на бэйдж :)

## Как проверить работоспособность.
- Забрать ветку ansible-3.
- Перейти в директорию terraform/stage.
- Выполнить terraform init && terraform apply (ключи пользователя appuser должны быть в домашней директории ~/.ssh). Запомнить app_external_ip.
- Настроить gce dynamic inventory и положить его в директорию stage и prod.
- Перейти в директорию ansible и выполнить ansible-playbook site.yml.
- Перейти в браузере по ссылке http://app_external_ip:80.
- Залогиниться на виртуалки под пользователем appuser, выполнить su user_name. Ввести password. Явки-пароли взять из ДЗ.

# HW-11
## В процессе сделано
- Установили VirtualBox и Vagrant.
- Заполнили конфигурацию в ВМ в Vagrantfile.
- Дописали в Vagrantfile provisioners.
- Добавили ещё один playbook в site.yml (base.yml), устанавливающий python я помощью raw модуля.
- Добавили в роли содержимое плэйбукиов packer_db и packer_app, чтобы роли могли управлять всем жизненным циклом приложения.
- Протестировли получившиеся ВМ вручную.
- Добавили конфиигурирование имени пользователя в playbooks и значение пльзователя по-умолчанию в defaults/main.yml в роли app. В Vagrantfile переопределяем значение по-умолчанию.
- В качестве задание со * добавили конфигурирование nginx прокси.
- Установили molecule, testinfra, python-vagrant через pip и requirements.txt.
- Внутри роли db инициализировали тестовую инфраструктуру molecule.
- Написали тесты для molecule с использованием тестового фреймворка testinfra.
- Самостоятельно дописали один тест на прослушивание порта монги.
- Доработали playbooks в шаблонах пакера, чтобы использовались роли. В задании было написано делать через теги. Я сделал через import_role и tasks_from. На мой взгляд тегирование здесь лишнее. Разница в том, где управлять provision'ом, из роли или из шаблона.
- Пакер видит роли через переменную в шаблоне пакера.
- Вынесли роль db в отдельный репозиторий, настроили там тесты молекулы в GCP с использованием оф.драйвера gce. Настроили в тревисе шифрование json, SSH ключа.
- Добавили бэйдж со статусом билда в репу роли, настроили интеграцию гитхаба и тревиса со слаком.
