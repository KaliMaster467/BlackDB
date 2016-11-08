drop database if exists NovaConnect;
create database NovaConnect;
use NovaConnect;

create table Users(
	UserID int not null primary key,
    UserRegisterDate date not null,
    UserFirstLastName nvarchar(32) not null,
    UserSecondLastName nvarchar(32) not null,
    UserRealName nvarchar(64) not null,
    UserTelephone nvarchar (20) not null,
    UserEmail nvarchar(64) not null,
    UserDel nvarchar(40) not null,
    UserPass nvarchar(32) not null,
    UserDir nvarchar(160) not null,
    UserActive boolean not null
);

create table Products(
	ProductID int not null primary key,
    ProductRegisterDate date not null,
    ProductName nvarchar(32) not null,
    ProductPrice int(10) not null,
    ProductExistence int (5) not null,
    ProductDescription nvarchar(250) not null
);

create table ProductsSale(
	SaleID int not null primary key,
    SaleUserID int not null,
    SaleProductID int not null,
    SaleDate date not null,
    SalePayMethod int(2) not null,
    SaleComments nvarchar(200),
    FOREIGN KEY (SaleUserID) REFERENCES Users(UserID),
    FOREIGN KEY (SaleProductID) REFERENCES Products(ProductID)
);

create table Alerts(
	AlertID int not null primary key,
    AlertUserID int not null,
    AlertDate date not null,
    AlertLocation nvarchar(160) not null,
    AlertAttended boolean not null,
    AlertReal boolean not null,
    AlertComments nvarchar(200),
    FOREIGN KEY (AlertUserID) REFERENCES Users(UserID)
);

create table Administradores(
	AdminID int not null primary key,
    AdminRegisterDate date not null,
    AdminPass nvarchar(32) not null
);

create table Monitor(
	MonitorID int not null primary key,
    MonitorRegisterDate date not null,
    MonitorFirstLastName nvarchar(32) not null,
    MonitorSecondLastName nvarchar(32) not null,
    MonitorRealName nvarchar(64) not null,
    MonitorTelephone int(12) not null,
    MonitorEmail nvarchar(64) not null,
    MonitorDel nvarchar(40) not null,
    MonitorTurn nvarchar(16) not null,
    MonitorPass nvarchar(32) not null,
    MonitorDir nvarchar(160) not null
);

create table Modifications(
	ModID int not null primary key,
    ModUserID int not null,
    ModDate date not null,
    ModLastTelephone int (12) not null,
    ModNewTelephone int (12) not null,
    ModLastEmail nvarchar(64) not null,
    ModNewEmail nvarchar(64) not null,
    ModLastDel nvarchar (40) not null,
    ModNewDel nvarchar(40) not null,
    ModLastDir nvarchar(160) not null,
    ModNewDir nvarchar(160) not null,
    ModLastPass nvarchar(32) not null,
    ModNewPass nvarchar(32) not null,
    FOREIGN KEY (ModUserID) REFERENCES Users(UserID)
);
create table Monitoring(
	MonID int not null primary key,
    MonMonitorID int not null,
    MonStartDate date not null,
    MonHours int(2) not null,
    FOREIGN KEY (MonMonitorID) REFERENCES Monitor(MonitorID)
);

create table BlockedUsers(
	BlockedUserID int not null primary key,
    BlockedUserUserID int not null,
    BlockedUserDate date not null,
    BlockedUserReason nvarchar(160) not null,
    FOREIGN KEY (BlockedUserUserID) REFERENCES Users(UserID)
);

create table ProductUse(
	ProductUseID int not null primary key,
    ProductUseProductID int not null,
    ProductUseStartDate date not null,
    ProductUseEndDate date not null,
    FOREIGN KEY (ProductUseProductID) REFERENCES Products(ProductID)
);
select * from Users;
select * from Products;
select * from ProductsSale;
select * from Alerts;
select * from Administradores;
select * from Monitor;
select * from Monitoring;
select * from Modifications;
select * from BlockedUsers;
select * from ProductUse;
delete from Users where UserID is null;
delete from Products where ProductID is null;
delete from ProductsSale where ProductsSale is null;
delete from Alerts where Alerts is null;
delete from Administradores where Administradores is null;
delete from Monitor where Monitor is null;
delete from Monitoring where Monitoring is null;
delete from Modifications where Users is null;
delete from BlockedUsers where Users is null;
delete from ProductUse where Users is null;

drop procedure if exists sp_registerUser;
delimiter //
create procedure sp_registerUser(in firstLName nvarchar(32), in secondLName nvarchar(32), in namee nvarchar(64),
	in tel nvarchar(20), in email nvarchar(64), in del nvarchar(40), in pas nvarchar(32), in dir nvarchar(160))
begin
	declare actID int;
	declare existss int;
	declare actDate date;
	declare msg nvarchar(64);
	set actID = (select count(*) from Users)+1;
    set actDate = curDate();
    set existss = (select count(*) from Users where UserEmail = email);
    if(existss = 0) then
		insert into Users(UserID, UserRegisterDate, UserFirstLastName, UserSecondLastName, UserRealName, UserTelephone, UserEmail, UserDel, UserPass, UserDir, UserActive)
			values(actID, actDate, firstLName, secondLName, namee, tel, email, del, pas, dir, false);
		set msg = 'Successfully registered';
	else
		set msg = 'User already on database (email)';
	end if;
	select msg as sstatus;
end//
delimiter ;

call sp_registerUser('Ochoa', 'Rodriguez', 'Daniel Salvador', '55396021', 'keimzely@gmail.com', 'Miguel Hidalgo', 'quequitas', 'aleluya123avenidaFeik');

drop procedure if exists sp_checkUser;
delimiter //
create procedure sp_checkUser(in email nvarchar(64))
begin
	declare exist int;
	declare msg nvarchar(64);
    set exist = (select count(*) from Users where UserEmail = email);
    if(exist = 1) then
		select UserFirstLastName as LastNameFirst, UserSecondLastName as LastNameSecond, UserRealName as UserName, 
        UserTelephone as Tel, UserEmail as email, UserDel as delegation from Users where UserEmail = email;
		set msg = 'User found';
    else 
		set msg = 'User not found';
    end if;
	select msg as sstatus;
end//
delimiter ;

call sp_checkUser('keimzely@gmail.com');

drop procedure if exists sp_registerProduct;
delimiter //
create procedure sp_registerProduct(in namee nvarchar(32), in price int(10), in existence int (5), in description nvarchar(250))
begin
	declare actID int;
	declare actDate date;
    declare exist int;
	declare msg nvarchar(64);
    set actID = (select count(*) from Products)+1;
    set actDate = curDate();
    set exist = (select count(*) from Products where ProductName = namee);
	if(exist = 0) then
		insert into Products(ProductID, ProductRegisterDate, ProductName, ProductPrice, ProductExistence, ProductDescription)
        values (actID, actDate, namee, price, existence, description);
		set msg = 'new Product On Sale!!';
    else
		set msg = 'Product Already On Sale'; 
    end if;
    select msg as sstatus;
end//
delimiter ;

call sp_registerProduct('Pulse-Sync', 1500, 20, 'La mejor pulsera del mundo lml');

drop procedure if exists sp_checkProducts;
delimiter //
create procedure sp_checkProducts(in idP int)
begin
	declare exist int;
	declare msg nvarchar(64);
    set exist = (select count(*) from Products where ProductID = idP);
    if(exist = 1) then
		select ProductName as nameOfProduct, ProductPrice as price, ProductExistence as currentExistence, ProductDescription as description from Products where ProductID = idP;
		set msg = 'Product Found';
    else 
		set msg = 'Product Not Found';
    end if;
	select msg as sstatus;
end//
delimiter ;

call sp_checkProducts(1);

drop procedure if exists sp_productSale;
delimiter //
create procedure sp_productSale(in userEmail nvarchar(64), in productName nvarchar(32), in payMethod int(2), in comments nvarchar(200))
begin
	declare actID int;
	declare actDate date;
    declare userID int;
    declare prodID int;
	declare msg nvarchar(64);
    set actID = (select count(*) from ProductsSale)+1;
    set actDate = curDate();
    set userID = (select UserID from Users where UserEmail = userEmail);
    set prodID = (select ProductID from Products where ProductName = productName);
    insert into ProductsSale(SaleID, SaleUserID, SaleProductID, SaleDate, SalePayMethod, SaleComments) 
    values (actID, userID, prodID, actDate, payMethod, comments);
    set msg = 'Gotcha';
    select msg as sstatus;
end//
delimiter ;
call sp_productSale('keimzely@gmail.com', 'Pulse-Sync', 2, 'la mejor pulsera pariente');

