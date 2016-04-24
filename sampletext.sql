INSERT INTO MembershipPlan
VALUES ('Platinum', '$50', '$20', '$1.50', '$60', '$5', '$150');

INSERT INTO MembershipPlan (name, monthly_rate, hourly_rate, km_rate, daily_rate, daily_km_rate, daily_km_rate_included)
VALUES
	('Gold', '$35', '$30', '$2.5', '$75','$7.50', '$75'),
	('Silver', '$20', '$40', '$3', '$85', '$8', '$50');

INSERT INTO CarBay (name, address, description, location, latitude, longitude)

INSERT INTO Member
VALUES('lightingbolt@gmail.com', 'Mr', 'Harry', 'Potter', 'Scarhead' 'Alohomora', '394', '8/9/2016', '13 Digby CCT, Crace, ACT, Australia', 'Leaky Cauldron', '31 July 1980', 'Gold', '31 July 1993');

INSERT INTO Member (email, title, family_name, given_name, nickname, password, license, license_expiry, address, birthdate, membership_plan, member_since)
VALUES
	('twinkle@hotmail.com', 'Mx', 'Albus', 'Dumbledore', 'Dumbly-dorr', 'I open at the close', '456', '4 July 2016', '5A Dawson Street, Curtin, ACT, Australia', '1 Feb 1950', 'Platinum', '2 Dec 1960'),
	('muggleborn@outlook.com', 'Mrs', 'Hermione', 'Granger-Malfoy', 'Bookworm', 'Dramione', '444', '17/12/2016', '2 Philip Place, Curtin, ACT', '19 Sept 1979', 'Silver', '2 Dec 1993');

INSERT INTO Phone (email, phone) VALUES
('scarhead@gmail.com', '9.75'),
('lightingbolt@gmail.com', '6325293028');

INSERT INTO Phone (email, phone) VALUES
('twinkle@hotmail.com', '7777777777'),
('lightingbolt@gmail.com', '0123456778'),
('muggleborn@outlook.com', '6868686868');
