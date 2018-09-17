--------------------------------------------------------------- -- Retail  
Database; Create Tables Script 
---------------------------------------------------------------
drop table employees;
create table employees (ssn int not null primary key, fname 
varchar(30),lname varchar(30), bdate date, sex char(1),salary real,superssn int,deptint int,
address1 varchar(30),address2 varchar(40),city char(20),state char(2),zip int;

drop table department;
create table department (deptint int,deptname varchar(30), mgrssn int,locationint int);

drop table location;
create table location(locationint int not null primary key, lname
varchar(30),lmgrssn int);

drop table works;
create table works(workid int not null primary key,essn int, deptint int,hours int);

drop table supplier;
create table supplier(supplierint int not null primary 
key,suppliername varchar(50),deptint int, address1 varchar(50),address2 varchar(50),city
varchar(50),state varchar(50),zip int,phone int);


drop table inventory;
create table inventory(itemint int not null primary key,itemname varchar(50),supplierint int references Supplier,unitprice int,quantityinhand int 
check(quantityinhand>0),deptint int);


drop table orders;
create table orders(orderno int not null primary key, supplierint 
int references supplier, orderdate date);

drop table supplierOrder;
create table supplierOrder(supplierorderid int not null primary 
key,orderint int references Orders,itemint int references Inventory, qty int check(Qty>0),unitprice int check(unitprice>=0.0));

drop table transactions;
create table transactions(transactionid int not null primary 
key,storecard char(1),paymenttype varchar(2),checkint int,creditcardtype varchar(10),creditexpdate date,creditint 
int,dateoftransaction date,amount int);


drop table sales;
create table sales(salesid int not null primary key,transactionid 
int references transactions,itemint int references inventory,qty int);

drop table errorlog;
create table errorlog(errorlogid int not null primary key, 
errordescription varchar(1000),creationdate	date);

drop table priceLookUp;
create table priceLookUp(pricelookupid int not null primary 
key,itemint int references inventory, description varchar(40), price int,activeorpassive 
char(1));

drop sequence user_id_seq;

/*CREATE SEQUENCE seq_user_id
	 MINVALUE 1
	 MAXVALUE 999999999999999999
	 START WITH 1
	 INCREMENT BY 1
	 NOCACHE ;(oracle version)*/

create sequence seq_user_id start 1 increment 1 maxvalue 9999999;