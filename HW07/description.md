1. Создать 3 ВМ для Postgres, 3 ВМ для etcd и 1 ВМ для haproxy
    ![alt text](image.png)

2. Прописываем хосты в каждой ВМ

3. Установка ETCD на ВМ:
    - останавливаем исмотрим статусы
    ![alt text](image-1.png)
    - обновляем файл конфигурации
    - запускаем ETCD

    ![alt text](image-2.png)
    ![alt text](image-3.png)
    ![alt text](image-4.png)
    ![alt text](image-5.png)

4. Установка PostgreSQL на ВМ
    ![alt text](image-6.png)

5. Установка Patroni на ВМ с postgres:
    - установить библиотеки для python
    - остановить postgres, удалить кластер
    - установить patroni[etcd]
    - закинуть файл конфигурации patroni коастера на ноды с postgresql
    - на всех нодах необходимо создать папку для хранения файлов и назначить ей нужные права, в нашем случае это /mnt/patroni.

6. Инициализация Patroni
    - Перегрузить ВМ на которых установлен patroni
    - запускаем patroni на нодах
    
    ![alt text](image-7.png)

