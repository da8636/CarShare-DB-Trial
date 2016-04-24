BEGIN;
SET CONSTRAINTS ALL DEFERRED;
INSERT INTO Member
VALUES('lightingbolt@gmail.com', 'Mr', 'Harry', 'Potter', 'Scarhead', 'Alohomora', 394, '8/9/2016', '13 Digby CCT, Crace, ACT, Australia', 'Leaky Cauldron', '31 July 1980', 'Gold', '31 July 1993', 1);
INSERT INTO PaymentMethod (PaymentNum, email)
VALUES (1, 'lightingbolt@gmail.com');
COMMIT;
