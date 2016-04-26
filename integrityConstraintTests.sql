UPDATE Member
SET fav_bay_name = 'Ministry of Magic'
WHERE email = 'lightingbolt@gmail.com';

UPDATE Member
SET family_name = 'Malfoy'
WHERE email = 'muggleborn@outlook.com';

UPDATE Member
SET email = 'scarhead@gmail.com'
WHERE email = 'lightingbolt@gmail.com';

UPDATE CarBay
SET name = 'Knockturn Alley'
WHERE name = 'Diagon Alley';

UPDATE Car
SET parkedAt = 'Hogsmeade'
WHERE regno = '3THREE';

UPDATE Car
SET regno = '9NINE9'
WHERE regno = '3THREE';

UPDATE Booking
SET startHour = '10'
WHERE bookedBy = 'twinkle@hotmail.com';

INSERT INTO PaymentMethod
VALUES ('5', 'scarhead@gmail.com');

UPDATE MembershipPlan
SET name = 'Diamond'
WHERE name = 'Platinum';

UPDATE Car
SET name = 'pinky'
WHERE name = 'Rampyari';

UPDATE BankAccount
SET bsb = '8637232'
WHERE paymentNum = 3;

UPDATE CreditCard
SET expires = '12-12-2016'
WHERE PaymentNum = 2;

DELETE FROM Booking
WHERE regno='YBK90C' and startDate='2/08/2016' and startHour=15;

DELETE FROM Car
WHERE regno='4FOUR4';

BEGIN;
DELETE FROM PaymentMethod
WHERE PaymentNum=1;

DELETE FROM Member
WHERE email='scarhead@gmail.com';
COMMIT;

DELETE FROM CarBay
WHERE name='Hogwarts';

DELETE FROM Location
WHERE name='Crace District'