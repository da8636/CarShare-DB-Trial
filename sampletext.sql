INSERT INTO Location (name, type)
VALUES
	('Curtin District', 'Magically Hidden'),
	('Crace District', 'Parking Lot'),
	('Yarralumla District', 'Portal Allocation'),
	('Deakin District', 'Singular Spaces'),
	('Woden District', 'Parking Lot');

INSERT INTO CarBay (name, address, description, location, latitude, longitude)
VALUES
	('Leaky Cauldron', '24 Modly Place, Crace, ACT, Australia', 'Magically Hidden. Can not be see by muggles', 1, 24, 145),
	('Three Broomsticks', '151 Jamuna Avenue, Curtin, ACT, Australia', 'Parking Lot. Beware of muggles', 2, 44, 92),
	('Hogwarts', '934 Train Station, Yarralumla, ACT, Australia', 'Portal Allocation found on platform 9 3/4', 3, 1, 12),
	('Ministry of Magic', '222 Public Toilet, Yarralumla, ACT, Austrlia', 'Portal Allocation found behind the public toilet', 4, 2, 10),
	('Diagon Alley', '112 Northbourne Avenue, Deakin, ACT, Australia', 'Singular Spaces, slim fit. Tight fit, limited parking. Very Popular', 5, -49, -120),
	('Hogsmeade', '2 Melbourne Street, Woden, ACT Australia', 'Parking Lot. Space worthy near other parking lots. Beware of muggles', 6, 33, 100);

INSERT INTO MembershipPlan
VALUES ('Platinum', '$50', '$20', '$1.50', '$60', '$5', '$150');

INSERT INTO MembershipPlan (name, monthly_rate, hourly_rate, km_rate, daily_rate, daily_km_rate, daily_km_rate_included)
VALUES
	('Gold', '$35', '$30', '$2.5', '$75','$7.50', '$75'),
	('Silver', '$20', '$40', '$3', '$85', '$8', '$50'),
	('Bronze', '$10', '$50', '$4.5', '$95', '$8.50', '$35');

INSERT INTO Member
VALUES('lightingbolt@gmail.com', 'Mr', 'Harry', 'Potter', 'Scarhead', 'Alohomora', 394, '8/9/2016', '13 Digby CCT, Crace, ACT, Australia', 'Leaky Cauldron', '31 July 1980', 'Gold', '31 July 1993');

INSERT INTO Member (email, title, family_name, given_name, nickname, password, license, license_expiry, address, fav_bay_name, birthdate, membership_plan, member_since)
VALUES
	('twinkle@hotmail.com', 'Mx', 'Albus', 'Dumbledore', 'Dumbly-dorr', 'I open at the close', 456, '4 July 2016', '5A Dawson Street, Yarralumla, ACT, Australia', 'Hogwarts', '1 Feb 1950', 'Platinum', '2 Dec 1960'),
	('muggleborn@outlook.com', 'Mrs', 'Hermione', 'Granger-Malfoy', 'Bookworm', 'Dramione', 444, '17/12/2017', '2 Philip Place, Curtin, ACT', 'Three Broomsticks', '19 Sept 1980', 'Silver', '2 Dec 1993'),
	('dragon@iprimus.com', 'Mr', 'Draco', 'Malfoy', 'Ferret', 'Redeemed', 888, '24/10/2017', '2 Philip Place, Curtin, ACT', 'Hogsmeade', '5 June 1980', 'Platinum', '2 Dec 1993');

INSERT INTO Phone (email, phone)
VALUES
	('dragon@iprimus.com', '1999888999'),
	('lightingbolt@gmail.com', '6325293028');

INSERT INTO Phone (email, phone)
VALUES
	('twinkle@hotmail.com', '7777777777'),
	('muggleborn@outlook.com', '6868686868'),
	--testing multiple phones for individual
	('lightingbolt@gmail.com', '0123456778');


INSERT INTO CarModel (make, model, capacity, category)
VALUES
	('Toyota', 'Camry', 5, 'Sedan'),
	('Nissan', 'Dualis', 5, 'SUV'),
	('Nimbus', '2000', 2, 'Racing Broomstick'),
	('Nimbus', 'Firebolt', 2, 'Racing Broomstick');

INSERT INTO Car (regno, make, model, name, year, transmission, parkedAt)
VALUES
	('YBK9OC', 'Toyota', 'Camry', 'Bumble Bee', 1998, 'Automatic', 'Three Broomsticks'),
	('2TOO22', 'Nimbus', '2000', 'Nimby', 2000, 'Manual', 'Hogwarts'),
	('4FOUR4', 'Nimbus', 'Firebolt', 'Snappy', 2003, 'Manual', 'Leaky Cauldron'),
	--testing multiple car model but different regno--
	('3THREE', 'Nissan', 'Dualis', 'Minty', 2011, 'Automatic', 'Diagon Alley'),
	('YJB96X', 'Nissan', 'Dualis', 'Rampyari', 2012, 'Automatic', 'Ministry of Magic');

INSERT INTO Booking (regno, startDate, startHour, duration, whenBooked, bookedBy)
VALUES
	('YBK9OC', '2/08/2016', 15, 4, CURRENT_TIMESTAMP, 'muggleborn@outlook.com'),
	('2TOO22', '13/07/2016', 9, 12, CURRENT_TIMESTAMP, 'twinkle@hotmail.com'),
	('4FOUR4', '8/12/2016', 18, 23, CURRENT_TIMESTAMP, 'scarhead@gmail.com');

INSERT INTO PaymentMethod (email)
VALUES
	('muggleborn@outlook.com'),
	('twinkle@hotmail.com'),
	('lightingbolt@gmail.com');
