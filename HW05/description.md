1. Создание VM
    - 2 cpu 2 GB
    - ubuntu
    - публичный доступ
    - доступ по ssh, указать логин

    ![alt text](image.png)

2. sudo apt install postgresql 

    ![alt text](image-1.png)

3. Создать таблицу с данными

    ![alt text](image-2.png)

4. Остановка postgres

    ![alt text](image-3.png)

5. Создайте новый диск

    ![alt text](image-4.png)

6. Примонтировать к ВМ

    ![alt text](image-5.png)

7. проинициализируйте диск согласно инструкции - https://yandex.cloud/ru/docs/compute/operations/vm-control/vm-attach-disk

    ![alt text](image-6.png)

8. сделайте пользователя postgres владельцем

    ![alt text](image-7.png)

9. перенесите содержимое

    ![alt text](image-8.png)

10. попытайтесь запустить кластер

    ![alt text](image-9.png)

11. Поменять в конфигурационном файле путь в параметре "data_directory" на новый.
    `data_directory = 'mnt/new_disk/data/17/main'`

12. Запустить postgres

    ![alt text](image-10.png)

13. Проверить содержимое ранее созданной таблицы

    ![alt text](image-11.png)

Задание со звездочкой

1. Создал новую ВМ
2. Установил на нее postgresql
3. Остановил postgresql, удалил /var/lib/postgresql/17
4. Зайти на старую ВМ, остановить postgresql
5. Отсоединить диск от старой ВМ и присоединить к новой
6. Смонтируйте разделы диска на новой ВМ 
    ```
    sudo mkdir /mnt/vdb2 
    sudo mount /dev/vdb1 /mnt/vdb2
    ```
    ![alt text](image-12.png)

7. Поменять в конфигурационном файле путь в параметре "data_directory" на новый.
    `data_directory = 'mnt/vdb2/data/17/main'`
8. Запустить postgresql

    ![alt text](image-13.png)

9. Проверить содержимое ранее созданной таблицы

    ![alt text](image-14.png)
    ![alt text](image-15.png)