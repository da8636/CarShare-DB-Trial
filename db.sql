CREATE TABLE Member (
	email varchar(50) primary key,
	title varchar(4),
	family_name varchar(50),
	given_name varchar(50),
	nickname varchar(50),
	password varchar(50),
 	license integer,
 	license_expiry date,
 	address varchar(50),
 	fav_bay_name varchar(50) references CarBay(name),
 	birthdate date,
 	membership_plan varchar(50) references MembershipPlan(title) NOT NULL, 
 	member_since date, 
 	preferred_payment integer references PaymentMethod(paymentNum) NOT NULL
);

CREATE TABLE Phone (
	email varchar(50), references Member(email) NOT NULL,
	phone varchar(10) -- Maximum standard *Australian* mobile phone number
);

CREATE TABLE Car (
	regno char(6) primary key,
	make varchar(30) references CarModel(make) NOT NULL,
	model varchar(30) references CarModel(model) NOT NULL,
	year integer,
	transmission varchar(50),
	parkedAt integer(50) references CarBay(name) NOT NULL
);

CREATE TABLE CarModel (
	make varchar(30) NOT NULL,
	model varchar(30) NOT NULL,
	name varchar(50)
	capacity integer,
	category varchar(50),
	primary key (make, model)
);

CREATE TABLE Booking (
	-- composite keys
	regno char(6) references Car(regno) NOT NULL,
	startDate date NOT NULL,
	startHour integer NOT NULL,
	-- composite keys end 
	duration integer, -- limiting to hourly bookings
	whenBooked timestamp, 
	bookedBy varchar(50) references Member(email) NOT NULL,
	primary key (regno, startDate, startHour)
);

CREATE TABLE CarBay (
	name varchar(50) primary key,
	address text,
	description text,
	location integer references Location(id) NOT NULL,
	latitude real,
	longitude real
);

CREATE TABLE Location (
	id integer primary key,
	name varchar(50),
	type varchar(50),
	partOf integer references Location(id)
);

CREATE TABLE MembershipPlan (
	name varchar(50) primary key,
	monthly_rate money,
	hourly_rate money,
	km_rate money,
	daily_rate money,
	daily_km_rate money,
	daily_km_rate_included money
);

CREATE TABLE PaymentMethod (
	payment_num integer,
	email varchar(50) references Member(preferred_payment),
	primary key(payment_num, email)
);

CREATE TABLE Paypal (
	payment_num integer primary key references PaymentMethod(payment_num),
	paypal_email varchar(50)
);

CREATE TABLE BankAccount (
	payment_num integer primary key references PaymentMethod(payment_num),
	name varchar(30),
	-- constraint of 3 digits space 3 digits for bsb --
	bsb char(7),
	account varchar(30)
);

CREATE TABLE CreditCard (
	payment_num integer primary key references PaymentMethod(payment_num),
	name varchar(30),
	brand varchar(30),
	expires date,
	num integer
);


