CREATE TABLE Location (
	id integer PRIMARY KEY,
	name varchar(50) UNIQUE, -- Location names should be easily discernable, as such make them unique
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
	nickname varchar(50) UNIQUE, -- nicknames should uniquely identify members
	password varchar(50),
 	license integer UNIQUE, -- License numbers should not be duplicated between different members
 	license_expiry date,
 	address varchar(50),
 	fav_bay_name varchar(50) references CarBay(name),
 	birthdate date,
 	membership_plan varchar(50) references MembershipPlan(name) NOT NULL, 
 	member_since date
);

CREATE TABLE Phone (
	email varchar(50) references Member(email) NOT NULL, -- Not a primary key because we need multiple entries, one per phone number
	phone varchar(10) UNIQUE -- 10 numbers is the stanard *Australian* mobile number, we assume mobile numbers because home phones are shared. UNIQUE prevents duplication.  
);

CREATE TABLE CarModel (
	make varchar(30) NOT NULL,
	model varchar(30) NOT NULL,
	name varchar(50) UNIQUE, -- Cars should be uniquely identifiable by their names 
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
	regno char(6) references Car(regno) NOT NULL,
	startDate date NOT NULL,
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
	paypal_email varchar(50) UNIQUE -- Assuming that Paypal emails are personal and are used by one person.
);

CREATE TABLE BankAccount (
	paymentNum integer PRIMARY KEY references PaymentMethod(paymentNum),
	name varchar(30),
	-- constraint of 3 digits space 3 digits for bsb --
	bsb char(7),
	account integer UNIQUE -- The same bank account should not be used by multiple people. Assuming they don't start with a zero.
);

CREATE TABLE CreditCard (
	paymentNum integer PRIMARY KEY references PaymentMethod(paymentNum),
	name varchar(30),
	brand varchar(30),
	expires date,
	num integer UNIQUE -- The same credit card should not be used by multiple people.
);
