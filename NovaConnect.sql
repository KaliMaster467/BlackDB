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
    ModMonitor boolean not null,
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

drop procedure if exists sp_productSale;
delimiter //
create procedure sp_productSale(in id int, in prodId int, in payMethod int(2), in comments nvarchar(200))
begin
	declare actID int;
	declare actDate date;
	declare msg nvarchar(64);
    set actID = (select count(*) from ProductsSale)+1;
    set actDate = curDate();
    insert into ProductsSale(SaleID, SaleUserID, SaleProductID, SaleDate, SalePayMethod, SaleComments) 
    values (id, prodId, prodID, actDate, payMethod, comments);
    set msg = 'Gotcha';
    select msg as sstatus;
end//
delimiter ;
drop procedure if exists sp_checkSale;
delimiter //
create procedure sp_checkSale(in usId int, in prodId int)
begin
	declare exist int;
    declare msg nvarchar(60);
    set exist = (select count(*) from ProductsSale where SaleUserID = usId and SaleProductID = prodId);
    if(exist = 0) then
		set msg = 'compra inexistente';
    else
		select Products.ProductName as nombreProducto, Products.ProductPrice as precio, Products.ProductDescription as descripcion, ProductsSale.SaleDate as fechaDeCompra, ProductsSale.SalePayMethod as formaDePago, ProductsSale.SaleComments as comentarios from ProductsSale inner join Products on ProductsSale.SaleProductID = Products.ProductID;
        set msg = 'compra encontrada';
    end if;
    select msg as sstatus;
    
end//
delimiter ;

drop procedure if exists sp_fireAlert;
delimiter //
create procedure sp_fireAlert(in usID int, in loc nvarchar(160), in attended boolean, in realAlert boolean, in comments nvarchar(200))
begin
	declare alertID int;
    declare actDate date;
    declare msg nvarchar(60);
    set alertID = (select count(*) from Alerts)+1;
    set actDate = curdate();
    insert into Alerts(AlertID, AlertUserID, AlertDate, AlertLocation, AlertAttended, AlertReal, AlertComments) values (alertID, usID, actDate, loc, attended, realAlert, comments);
    set msg = 'Alerta registrada';
    select msg as sstatus;
end//
delimiter ;

drop procedure if exists sp_checkAlert;
delimiter //
create procedure sp_checkAlert(in usID int)
begin
	declare exist int;
    declare msg nvarchar(60);
    set exist = (select count(*) from Alerts where AlertUserID = usID);
    if(exist =0) then
		set msg = 'No tiene alertas';
    else
		select AlertDate as fecha, AlertLocation as lugar, AlertAttended as atendieron, AlertReal as fueReal, alertComments as comentarios from Alerts;
		set msg = 'Alertas encontradas';
    end if;
    select msg as sstatus;
end//
delimiter;

drop procedure if exists sp_registerAdmin;
delimiter //
create procedure sp_registerAdmin(in pass nvarchar(32))
begin
	declare actID int;
    declare actDate date;
    declare msg nvarchar(60);
    set actID = (select count(*) from Administradores)+1;
    set actDate = curdate();
    insert into Administradores(AdminID, AdminRegisterDate, AdminPass) values (actID, actDate, pass);
end//
delimiter ;

drop procedure if exists sp_registerMonitor;
delimiter //
create procedure sp_registerMonitor(in firstLN nvarchar(32), in secondLN nvarchar(32), in namess nvarchar(64), in tel int(12), in email nvarchar(64), in deleg nvarchar(40), in turn nvarchar(16), in pass nvarchar(32), in dir nvarchar(160))
begin 
	declare actID int;
    declare actDate date;
	declare msg nvarchar(30);
    set actID = (select count(*) from Monitor)+1;
    set actDate = curdate();
    insert into Monitor (MonitorID, MonitorRegisterDate, MonitorFirstLastName, MonitorSecondLastName, MonitorTelephone, MonitorEmail, MonitorDel, MonitorTurn, MonitorPass, MonitorDir)
    values (actID, actDate, firstLN, secondLN, namess, tel, email, deleg, turn, pass, dir);
end//
delimiter ;
drop procedure if exists sp_checkMonitor;
delimiter //
create procedure sp_checkMonitor(in id int)
begin
	declare exist int;
    declare msg nvarchar(30);
    set exist = (select count(*) from Monitor where MonitorID = id);
    if(exist = 0) then
		set msg = 'El monitor no existe';
    else
		select MonitorFirstLastName as apellidoPat, MonitorSecondLastName as apellidoMat, MonitorRealName as nombreComp, MonitorEmail as email, MonitorDel as delegacion, MonitorTurn as turno from Monitor;
        set msg = 'El monitor fue encontrado';
    end if;
    select msg as sstatus;
end//
delimiter ;

drop procedure if exists sp_monitoringOn;
delimiter //
create procedure sp_monitoringOn(in monitorId int, in hours int)
begin
	declare actId int;
    declare actDate date;
    set actId = (select count(*) from Monitoring);
    set actDate = curdate();
    insert into Monitoring(MonID, MonMonitorID, MonStartDate, MonHours) values (actId, monitorId, actDate, hours);
end//
delimiter ;

drop procedure if exists sp_checkMonitoring;
delimiter //
create procedure sp_checkMonitoring(in monitorID int)
begin
	declare msg nvarchar(60);
	declare exist int;
    set exist = (select count(*) from Monitoring where MonMonitorID = monitorID);
    if (exist = 0) then
		set msg = 'no hay horas registradas';
    else
		select Monitor.MonitorFirstLastName as apellidoPat, Monitor.MonitorSecondLastName as apellidoMat, Monitor.MonitorRealName as nombres, Monitor.MonitorEmail as email, Monitor.MonitorDel as delegacion, Monitor.MonitorTurn as turno,
        Monitoring.MonStartDate as fecha, Monitoring.MonHours as Horas from Monitoring inner join Monitor on Monitoring.MonMonitorID = Monitor.MonitorID;
        set msg = 'monitoreo encontrado';
    end if;
end//
delimiter ;

drop procedure if exists sp_blockUser;
delimiter //
create procedure sp_blockUser(in userID int, in reason nvarchar(160))
begin
	declare actID int;
	declare actDate nvarchar(60);
    declare msg nvarchar(30);
    declare exist int;
    set actId = (select count(*) from BlockedUsers)+1;
    set actDate = curdate();
    set exist = (select count(*) from Users where UserID = userID);
    if (exist = 0) then
		set msg = 'usuario inexistente';
    else
		insert into BlockedUsers (BlockedUserID, BlockedUserUserID, BlockedUserDate, BlockedUserReason) values (actID, userID, actDate, reason);
        set msg = 'usuario bloqueado!!';
    end if;
    select msg as sstatus;
end//
delimiter ;

drop procedure if exists sp_checkBlockedUser;
delimiter //
create procedure sp_checkBlockedUser(in userID int)
begin
	declare exist int;
    declare msg nvarchar(60);
    set exist = (select count(*) from BlockedUsers where BlockedUserUserID = userID);
    if (exist=0) then
		set msg = 'bloqueo no encontrado';
	else
		select Users.UserID as idUsuario, Users.UserFirstLastName as apellidoPat, Users.UserSecondLastName as apellidoMat, Users.UserRealName as namee, BlockedUsers.BlockedUserDate as fechaBloqueo, BlockedUsers.BlockedUserReason as razon from BlockedUsers inner join Users on BlockedUsers.BlockedUserUserID = Users.UserID;
		set msg = 'bloqueo encontrado';
	end if;
    select msg as sstatus;
end//
/*Faltan modificaciones de Monitor o Usuario, que registre cuando se usa un producto y talvez un Trigger que bloquee los usuarios con 3 faltas y maybe una tabla con las faltas que ha cometido el usuario (por ejemplo alertas fake o cosas asi)*/
/*
create table Modifications(
	ModID int not null primary key,
    ModMonitor boolean not null,
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
*/
