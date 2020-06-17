# 1. Установите СУБД MySQL. Создайте в домашней директории файл .my.cnf, задав в нем логин и пароль, который указывался при установке.

# Вместо mysql в начале файла мы используем client для того, чтобы разрешить доступ и в mysql, и в mysqldump.

vim .my.cnf
# [client]
# user=root
# password=***


# 2. Создайте базу данных example, разместите в ней таблицу users, состоящую из двух столбцов, числового id и строкового name.

# Зайдем без пароля в СУБД.
mysql

# Создадим БД, если таковой еще не существует.
CREATE DATABASE IF NOT EXISTS example;

# Объявим действия с БД example.
USE example;

# Создаем внутри таблицу сразу наполним ее.
CREATE TABLE users (
name VARCHAR(111) DEFAULT "Null",
id INT UNSIGNED
);

# Выведем итоги на экран.
SHOW TABLES FROM example;

DESC users;

exit

# 3. Создайте дамп базы данных example из предыдущего задания, разверните содержимое дампа в новую базу данных sample.

# Создаем дамп базы данных
mysqldump example > example.sql

# Переходим в mysql и проводим небольшие манипуляции.
mysql

CREATE DATABASE sample;

exit

# Разворачиваем содержимое дампа в новую базу данных sample.
mysql sample < example.sql

mysql

SHOW TABLES FROM sample;

# 4. (по желанию) Ознакомьтесь более подробно с документацией утилиты mysqldump. Создайте дамп единственной таблицы help_keyword базы данных mysql. 
Причем добейтесь того, чтобы дамп содержал только первые 100 строк таблицы.

CREATE DATABASE new_mysql;

exit

# Дамп содержит только первые 100 строк.
mysqldump mysql help_keyword --where="true limit 100" > mysql.sql