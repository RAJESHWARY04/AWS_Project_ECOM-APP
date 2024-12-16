# Introduction

This is a sample e-commerce application built for learning purposes.

Tech stack: Apache, PHP, Mysql 

Apache: Apache is a widely-used open-source web server software developed and maintained by the Apache Software Foundation. Its main purpose is to serve web pages and deliver web content over the internet

PHP: PHP can act as middleware in a web application architecture. Middleware refers to software components that sit between different layers of an application and facilitate communication and data processing between them. PHP's server-side scripting capabilities make it well-suited for this role. PHP code can interact with databases, process form data, generate HTML output, handle sessions, and perform other server-side tasks. It works closely with Apache to generate dynamic web pages and deliver them to users' web browsers.

The php-mysql package provides the necessary libraries and extensions for PHP to connect to MySQL databases. Without this package, PHP will not be able to establish connections to MySQL servers, execute SQL queries, or manipulate data in MySQL databases.

MySQL: MySQL is a widely-used open-source relational database management system (RDBMS) that is known for its reliability, scalability, and performance. It is one of the most popular databases in the world and is used by millions of developers and organizations for various purposes. It organizes data into tables with rows and columns



Here's how to deploy it on CentOS systems:

## Deploy Pre-Requisites


## Deploy and Configure Database

1. Install MariaDB

```
sudo yum install -y mariadb-server
sudo vi /etc/my.cnf  --> just check the configurations
sudo service mariadb start
sudo systemctl enable mariadb
```

2. Configure Database

```
$ mysql
MariaDB > CREATE DATABASE ecomdb;
MariaDB > CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
MariaDB > GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
MariaDB > FLUSH PRIVILEGES;
```

> ON a multi-node setup remember to provide the IP address of the web server here: `'ecomuser'@'web-server-ip'`

3. Load Product Inventory Information to database

Create the db-load-script.sql

#### these SQL queries are used to create a new database named "ecomdb", create a table named "products" within that database to store information about products, and insert multiple rows of product data into the "products" table. This is a common setup for creating a simple product database for an e-commerce application ###


```
cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;

INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");

EOF
```

Run sql script

```

mysql < db-load-script.sql
```


## Deploy and Configure Web

1. Install required packages

```
sudo yum install -y httpd php php-mysql
```

2. Configure httpd

Change `DirectoryIndex index.html` to `DirectoryIndex index.php` to make the php page the default page

```
sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf
```

3. Start httpd

```
sudo service httpd start
sudo systemctl enable httpd
```

4. Download code

```
sudo yum install -y git
#Copy learning-app-ecommerce directory into /var/www/html/
```

5. Update index.php

Update index.php file to connect to the right database server. In this case `localhost` since the database is on the same server.

```
sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php

              <?php
                        $link = mysqli_connect('172.20.1.101', 'ecomuser', 'ecompassword', 'ecomdb');
                        if ($link) {
                        $res = mysqli_query($link, "select * from products;");
                        while ($row = mysqli_fetch_assoc($res)) { ?>
```

> ON a multi-node setup remember to provide the IP address of the database server here.
```
sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php
```

6. Test

```
curl http://localhost
```
