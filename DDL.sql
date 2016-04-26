CREATE TABLE Location (
	id serial PRIMARY KEY,
	name varchar(50) UNIQUE, -- Location names should be easily discernable, as such make them unique
	type varchar(50) DEFAULT 'Parking Lot',
	partOf integer REFERENCES Location(id) ON DELETE SET NULL
);

CREATE TABLE CarBay (
	name varchar(50) PRIMARY KEY,
	address text,
	description text DEFAULT 'A car bay. You can park your booked car here',
	location integer REFERENCES Location(id) ON DELETE CASCADE NOT NULL, -- If Glebe gets demolished, all car bays in Glebe will not be servicable.
	latitude decimal,
	longitude decimal,
	CONSTRAINT latitude_check CHECK(latitude between -90 and 90),
	CONSTRAINT logitude_check CHECK(longitude between -180 and 180)
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
	email varchar(50) PRIMARY KEY, -- Emails are case insensitive
	title varchar(4), --All titles accepted by the system are at most four characters long
	family_name varchar(50) NOT NULL, -- People need names, otherwise we can't check their names against their license
	given_name varchar(50) NOT NULL, -- See above
	nickname varchar(50) UNIQUE, -- Nicknames should uniquely identify members
	password text NOT NULL, -- The password will only be stored in a hashed format, which can get very long
 	license integer UNIQUE NOT NULL, -- License numbers should not be duplicated between different members. A license number is needed to verify the member
 	license_expiry date NOT NULL,
 	address varchar(50),
 	fav_bay_name varchar(50) REFERENCES CarBay(name) ON UPDATE CASCADE ON DELETE SET NULL,
 	birthdate date,
 	membership_plan varchar(50) REFERENCES MembershipPlan(name) ON UPDATE CASCADE NOT NULL,
 	member_since date,
	CONSTRAINT email_check CHECK(email ~ '[^@]+@[^@]+(\.[^@]+)+'), -- It is assumed that a confirmation email will be sent to confirm registration, if they successfully registered, then, their email must be valid. This constraint is simply here to help prevent data entry errors.
	CONSTRAINT title_check CHECK(title in ('Mr','Ms','Mrs','Miss','Mx','Mstr','Dr','Prof')),
	CONSTRAINT nickname_check CHECK(nickname NOT LIKE '% %'), -- Nicknames can't contain spaces
	CONSTRAINT birthdate_check CHECK(EXTRACT(YEAR FROM birthdate) >= 1900) -- Nobody is alive that's that old
);

CREATE TABLE Phone (
	email varchar(50) REFERENCES Member(email) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL, -- Not a primary key because we need multiple entries, one per phone number
	phone varchar(10) UNIQUE NOT NULL -- 10 numbers is the stanard *Australian* mobile number, we assume mobile numbers because home phones are shared. UNIQUE prevents duplication. Varchar is used as numerical types doe not preserve leading zeroes
	CONSTRAINT phone_check CHECK(phone ~ '[0-9]{10}') --Phone numbers must be numeric
);

CREATE TABLE CarModel (
	make varchar(30) NOT NULL,
	model varchar(30) NOT NULL,
	capacity integer,
	category varchar(50) DEFAULT 'Sedan', -- Most common car category is the Sedan.
	PRIMARY KEY (make, model)
);

CREATE TABLE Car (
	regno char(6) PRIMARY KEY,
	make varchar(30) NOT NULL,
	model varchar(30) NOT NULL,
	name varchar(50) UNIQUE NOT NULL, -- Cars should be uniquely identifiable by their names
	FOREIGN KEY (make, model) REFERENCES CarModel(make, model) ON UPDATE CASCADE, -- A CarModel should never be deleted when there are still cars using it
	year integer,
	transmission varchar(50), -- Automatic/Manual
	parkedAt varchar(50) REFERENCES CarBay(name) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL, -- There should not be any cars parked in a bay that is no longer servicable.
	CONSTRAINT regno_check CHECK(regno ~ '[A-Z0-9]{6}'), -- Checks that the registration number is in a valid format
	CONSTRAINT transmission CHECK(transmission in ('Automatic', 'Manual'))
);

CREATE TABLE Booking (
	regno char(6) REFERENCES Car(regno) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL, -- Bookings with cars that are no longer in use should be removed as they don't make sense.
	startDate date NOT NULL,
	startHour integer NOT NULL,
	duration integer NOT NULL, -- The specifications state that bookings are limited to being in terms of hours
	whenBooked timestamp,
	bookedBy varchar(50) REFERENCES Member(email) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	PRIMARY KEY (regno, startDate, startHour),
	CONSTRAINT startHour_check CHECK(startHour between 0 and 23)
);

CREATE TABLE PaymentMethod (
	paymentNum serial UNIQUE,
	email varchar(50) REFERENCES Member(email) ON UPDATE CASCADE ON DELETE CASCADE NOT NULL,
	PRIMARY KEY (paymentNum, email)
);

ALTER TABLE Member ADD COLUMN preferred_payment integer;
ALTER TABLE Member ADD CONSTRAINT prefered_payment_fkey FOREIGN KEY (preferred_payment) REFERENCES PaymentMethod(paymentNum) ON UPDATE CASCADE DEFERRABLE; -- Adds a circular reference that is not possible on table creation

CREATE TABLE Paypal (
	paymentNum integer PRIMARY KEY REFERENCES PaymentMethod(paymentNum),
	paypal_email varchar(50) NOT NULL -- Assume that spouse, family or company paypal accounts are shared
	CONSTRAINT paypal_check CHECK(paypal_email ~ '[^@]+@[^@]+(\.[^@]+)+')  -- It is assumed that paypal emails will already be checked by an external mechanism. This constraint is simply here to help prevent data entry errors.
);

CREATE TABLE BankAccount (
	paymentNum integer PRIMARY KEY REFERENCES PaymentMethod(paymentNum),
	name varchar(30),
	bsb char(7),
	account integer, -- Assume that spouse, family or company bank accounts are shared
	CONSTRAINT bsb_check CHECK (bsb ~ '[0-9]{3}-[0-9]{3}') -- Checks that the bsb number is in a valid format
);

CREATE TABLE CreditCard (
	paymentNum integer PRIMARY KEY REFERENCES PaymentMethod(paymentNum),
	name varchar(30),
	brand varchar(30) NOT NULL, -- All credit cards have a brand
	expires date NOT NULL, -- All credit cards have an expiry date
	num integer -- Assume that spouse, family or company credit cards are shared
);

-- EMAIL TRIGGERS
-- As this converts all emails and nicknames into lowercase, it ensures that other emails and nicknames cannot be the same jsut with differing case thanks to the UNIQUE constraint
CREATE FUNCTION standardizeMember() RETURNS trigger AS 
$$
BEGIN
	NEW.email := lower(NEW.email);
	NEW.nickname := lower(NEW.nickname);
	RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER DUPLICATE_MEMBER_EMAIL_CHECK
	BEFORE INSERT ON Member
	FOR EACH ROW
	EXECUTE PROCEDURE standardizeMember();
-- END EMAIL TRIGGERS

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

-- Ensures that licenses have not expired
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

-- Checks to ensure that no one has more than 3 payment methods
CREATE FUNCTION countPaymentNums(e varchar(50)) RETURNS integer AS
$$
BEGIN
	RETURN (SELECT COUNT(P.paymentNum) FROM PaymentMethod P where P.email=e);
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER MAX_PAYMENT_METHODS_CHECK
	BEFORE INSERT ON PaymentMethod
	FOR EACH ROW
	WHEN (countPaymentNums(NEW.email) > 3)
	EXECUTE PROCEDURE tooManyPaymentMethods();
-- END PAYMENT NUMBER TRIGGERS

-- CARBAY ASSERTIONS
--NOTE: This is commented out as PostgresSQL 9.5 does not support assertions yet
/*
CREATE ASSERTION carToBaySurjection CHECK
(
	NOT EXISTS
		(
			SELECT(B.name)
			FROM CarBay B LEFT JOIN Car C
			ON B.name = C.parkedAt
			WHERE C.parkedAt IS NULL
		)
	)
*/
-- END CARBAY ASSERTIONS