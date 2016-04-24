-- TODO: ADD ASSERTION!!!!

CREATE TABLE Location (
	id serial PRIMARY KEY,
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
	CONSTRAINT logitude_check CHECK( longitude between -180 and 180)
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
	email varchar(50) PRIMARY KEY, -- emails are case insensitive 
	title varchar(4),
	family_name varchar(50) NOT NULL, -- People need names, otherwise we can't check their names against their license
	given_name varchar(50) NOT NULL, -- See above
	nickname varchar(50) UNIQUE, -- nicknames should uniquely identify members 
	password text NOT NULL, -- hashed passwords can get very long
 	license integer UNIQUE NOT NULL, -- License numbers should not be duplicated between different members. Need a license number to verify the member.
 	license_expiry date NOT NULL,
 	address varchar(50),
 	fav_bay_name varchar(50) references CarBay(name),
 	birthdate date,
 	membership_plan varchar(50) references MembershipPlan(name) NOT NULL, 
 	member_since date,
	CONSTRAINT email_check CHECK(email ~ '[^@]+@[^@]+(\.[^@]+)+'), 
	CONSTRAINT title_check CHECK(title in ('Mr','Ms','Mrs','Miss','Mx','Mstr','Dr','Prof')),
	CONSTRAINT nickname_check CHECK(nickname NOT LIKE '% %'), -- nicknames can't contain spaces. 
	CONSTRAINT birthdate_check CHECK(EXTRACT(YEAR FROM birthdate) >= 1900) -- Nobody is alive that's that old
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
	transmission varchar(50), -- Automatic/Manual
	parkedAt varchar(50) references CarBay(name) NOT NULL,
	CONSTRAINT regno_check CHECK(regno ~ '[A-Z0-9]{6}'),
	CONSTRAINT transmission CHECK(transmission in ('Automatic', 'Manual'))
);

CREATE TABLE Booking (
	regno char(6) references Car(regno) NOT NULL,
	startDate date NOT NULL,
	startHour integer NOT NULL,
	duration integer, -- limiting to hourly bookings
	whenBooked timestamp, 
	bookedBy varchar(50) references Member(email) NOT NULL,
	PRIMARY KEY (regno, startDate, startHour),
	CONSTRAINT startHour_check CHECK(startHour between 0 and 23)
);

CREATE TABLE PaymentMethod (
	paymentNum serial UNIQUE,
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

-- EMAIL TRIGGERS
CREATE FUNCTION emailExists() RETURNS trigger AS 
$$
BEGIN
	RAISE EXCEPTION 'This email already exists';
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION lowerEmail() RETURNS trigger AS
$$
BEGIN
	UPDATE Member M set M.email=lower(M.email) where lower(M.email)=lower(NEW.email);
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION checkEmailExists(e varchar(50)) RETURNS integer AS
$$
BEGIN
	RETURN (SELECT COUNT(M.email)
			FROM Member M
			WHERE M.email = lower(e));
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER DUPLICATE_MEMBER_EMAIL_CHECK
	BEFORE INSERT ON Member
	FOR EACH ROW
	WHEN (checkEmailExists(NEW.email) = 1)
	EXECUTE PROCEDURE emailExists();

CREATE TRIGGER LOWER_EMAILS
	AFTER INSERT ON Member
	FOR EACH ROW
	EXECUTE PROCEDURE lowerEmail();

--END EMAIL TRIGGERS
--NICKNAME TRIGGERS

CREATE FUNCTION nicknameExists() RETURNS trigger AS 
$$
BEGIN
	RAISE EXCEPTION 'This nickname already exists';
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION lowerNickname() RETURNS trigger AS
$$
BEGIN
	UPDATE Member M set M.nickname=lower(M.nickname) where lower(M.nickname)=lower(NEW.nickname);
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION checkNicknameExists(n varchar(50)) RETURNS integer AS
$$
BEGIN
	RETURN (SELECT COUNT(M.nickname)
			FROM Member M
			WHERE M.nickname = lower(n));
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER DUPLICATE_MEMBER_NICKNAME_CHECK
	BEFORE INSERT ON Member
	FOR EACH ROW
	WHEN (checkNicknameExists(NEW.nickname) = 1)
	EXECUTE PROCEDURE nicknameExists();

CREATE TRIGGER LOWER_NICKNAME
	AFTER INSERT ON Member
	FOR EACH ROW
	EXECUTE PROCEDURE lowerNickname();

-- END NICKNAME TRIGGERS
-- LICENSE TRIGGERS

CREATE FUNCTION licenseExpired() RETURNS trigger AS
$$
BEGIN
	RAISE EXCEPTION 'This license has expired';
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION licenseExpiredCheck(expiry date) RETURNS boolean AS
$$
BEGIN
	RETURN expiry < CURRENT_DATE;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER LICENSE_EXPIRED_ON_JOIN
	BEFORE INSERT ON Member
	FOR EACH ROW
		WHEN (licenseExpiredCheck(NEW.license_expiry))
		EXECUTE PROCEDURE licenseExpired();

-- END LICENSE TRIGGER
-- PAYMENT NUMBER TRIGGERS
CREATE FUNCTION tooManyPaymentMethods() RETURNS trigger AS
$$
BEGIN
	RAISE EXCEPTION 'You already have 3 payment methods';
END
$$ LANGUAGE plpgsql;

CREATE FUNCTION countPaymentNums() RETURNS integer AS
$$
BEGIN
	RETURN (SELECT COUNT(P.paymentNum) FROM PaymentMethod P where P.email=NEW.email);
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER MAX_PAYMENT_METHODS_CHECK
	BEFORE INSERT ON PaymentMethod
	FOR EACH ROW
	WHEN (countPaymentNums() > 3)
	EXECUTE PROCEDURE tooManyPaymentMethods();

-- END PAYMENT NUMBER TRIGGERS
