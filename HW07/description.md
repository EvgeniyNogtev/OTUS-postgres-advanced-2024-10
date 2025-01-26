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

