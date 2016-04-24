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
	longitude real,
	CONSTRAINT latitude_check CHECK( latitude between -90 and 90),
	CONSTRAINT logitude_check CHECK( longitutde between -180 and 180)
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
	email citext PRIMARY KEY, -- emails are case insensitive 
	title varchar(4),
	family_name varchar(50) NOT NULL, -- People need names, otherwise we can't check their names against their license
	given_name varchar(50) NOT NULL, -- See above
	nickname varchar(50) UNIQUE, -- nicknames should uniquely identify members 
	password text, -- hashed passwords can get very long
 	license integer UNIQUE NOT NULL, -- License numbers should not be duplicated between different members. Need a license number to verify the member.
 	license_expiry date NOT NULL,
 	address varchar(50),
 	fav_bay_name varchar(50) references CarBay(name),
 	birthdate date,
 	membership_plan varchar(50) references MembershipPlan(name) NOT NULL, 
 	member_since date,
	CONSTRAINT email_check CHECK(email ~ '[^@]+@[^@]+(\.[^@]+)+'), 
	CONSTRAINT title_check CHECK(title in ('Mr','Ms','Mrs','Miss','Mx','Mstr','Dr','Prof'))
	CONSTRAINT nickname_check CHECK(nickname NOT LIKE '% %') -- nicknames can't contain spaces. 
);

CREATE TABLE Phone (
	email varchar(50) references Member(email) NOT NULL, -- Not a primary key because we need multiple entries, one per phone number
	phone varchar(10) UNIQUE -- 10 numbers is the stanard *Australian* mobile number, we assume mobile numbers because home phones are shared. UNIQUE prevents duplication.  
	CONSTRAINT phone_check CHECK(phone ~ '[0-9]{10}')
);

CREATE TABLE CarModel (
	make varchar(30) NOT NULL,
	model varchar(30) NOT NULL,
	capacity integer,
	category varchar(50),
	PRIMARY KEY (make, model)
);

CREATE TABLE Car (
	regno char(6) PRIMARY KEY,
	make varchar(30) NOT NULL,
	model varchar(30) NOT NULL,
	name varchar(50) UNIQUE NOT NULL, -- Cars should be uniquely identifiable by their names 
	FOREIGN KEY (make, model) references CarModel(make, model),
	year integer,
	transmission varchar(50),
	parkedAt varchar(50) references CarBay(name) NOT NULL,
);

CREATE TABLE Booking (
	regno char(6) references Car(regno) NOT NULL,
	startDate date NOT NULL,
	startHour integer NOT NULL,
	duration integer, -- limiting to hourly bookings
	whenBooked timestamp, 
	bookedBy varchar(50) references Member(email) NOT NULL,
	PRIMARY KEY (regno, startDate, startHour)
);

CREATE TABLE PaymentMethod (
	paymentNum integer,
	email varchar(50) references Member(email),
	PRIMARY KEY (paymentNum, email)
);

ALTER TABLE Member ADD COLUMN preferred_payment integer references PaymentMethod(paymentNum) NOT NULL;

CREATE TABLE Paypal (
	paymentNum integer PRIMARY KEY references PaymentMethod(paymentNum),
	paypal_email varchar(50) UNIQUE NOT NULL -- Assuming that Paypal emails are personal and are used by one person.
	CONSTRAINT paypal_check CHECK(paypal_email ~ '[^@]+@[^@]+(\.[^@]+)+') 
);

CREATE TABLE BankAccount (
	paymentNum integer PRIMARY KEY references PaymentMethod(paymentNum),
	name varchar(30),
	bsb char(7),
	account integer UNIQUE, -- The same bank account should not be used by multiple people. Assuming they don't start with a zero.
	CONSTRAINT bsb_check CHECK (bsb ~ '[0-9]{3}-[0-9]{3}')
);

CREATE TABLE CreditCard (
	paymentNum integer PRIMARY KEY references PaymentMethod(paymentNum),
	name varchar(30),
	brand varchar(30),
	expires date,
	num integer UNIQUE -- The same credit card should not be used by multiple people.
);
