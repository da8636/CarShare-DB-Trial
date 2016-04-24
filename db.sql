CREATE TABLE Location (
	id integer PRIMARY KEY,
	name varchar(50),
	type varchar(50),
	partOf integer references Location(id)
);

CREATE TABLE CarBay (
	name varchar(50) PRIMARY KEY,
	address text,
	description text,
	location integer references Location(id) NOT NULL,
	latitude real,
	longitude real
);

CREATE TABLE MembershipPlan (
	name varchar(50) PRIMARY KEY,
	monthly_rate money,
	hourly_rate money,
	km_rate money,
	daily_rate money,
	daily_km_rate money,
	daily_km_rate_included money
);

CREATE TABLE Member (
	email varchar(50) PRIMARY KEY,
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
 	membership_plan varchar(50) references MembershipPlan(name) NOT NULL, 
 	member_since date
);

CREATE TABLE Phone (
	email varchar(50) references Member(email) NOT NULL,
	phone varchar(10) -- Maximum standard *Australian* mobile phone number
);

CREATE TABLE CarModel (
	make varchar(30) NOT NULL,
	model varchar(30) NOT NULL,
	name varchar(50),
	capacity integer,
	category varchar(50),
	PRIMARY KEY (make, model)
);

CREATE TABLE Car (
	regno char(6) PRIMARY KEY,
	make varchar(30) NOT NULL,
	model varchar(30) NOT NULL,
	FOREIGN KEY (make, model) references CarModel(make, model),
	year integer,
	transmission varchar(50),
	parkedAt varchar(50) references CarBay(name) NOT NULL
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
	PRIMARY KEY (regno, startDate, startHour)
);

CREATE TABLE PaymentMethod (
	paymentNum integer PRIMARY KEY,
	email varchar(50) references Member(email)
);

ALTER TABLE Member ADD COLUMN preferred_payment integer references PaymentMethod(paymentNum) NOT NULL;

CREATE TABLE Paypal (
	paymentNum integer PRIMARY KEY references PaymentMethod(paymentNum),
	paypal_email varchar(50)
);

CREATE TABLE BankAccount (
	paymentNum integer PRIMARY KEY references PaymentMethod(paymentNum),
	name varchar(30),
	-- constraint of 3 digits space 3 digits for bsb --
	bsb char(7),
	account varchar(30)
);

CREATE TABLE CreditCard (
	paymentNum integer PRIMARY KEY references PaymentMethod(paymentNum),
	name varchar(30),
	brand varchar(30),
	expires date,
	num integer
);