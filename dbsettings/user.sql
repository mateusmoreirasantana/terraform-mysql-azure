CREATE USER IF NOT EXISTS ' '@'%' IDENTIFIED BY 'terraform';

CREATE DATABASE IF NOT EXISTS terraformDB;

ALTER DATABASE terraformDB
  DEFAULT CHARACTER SET utf8
  DEFAULT COLLATE utf8_general_ci;

GRANT ALL PRIVILEGES ON terraformDB.* TO 'terraform'@'%' IDENTIFIED BY 'terraform';
