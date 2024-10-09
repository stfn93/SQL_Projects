-- Keep a log of any SQL queries you execute as you solve the mystery.

--View descriptions from the crime scene
1. [SELECT description
      FROM crime_scene_reports
     WHERE year = 2023
       AND month = 7
       AND day = 28
       AND street = "Humphrey Street";
]
/*
Theft of the CS50 duck took place at 10:15am at the Humphrey Street bakery.
Interviews were conducted today with three witnesses who were present at the time – each of their interview transcripts mentions the bakery.
*/
2. [SELECT transcript
      FROM interviews
     WHERE year = 2023
       AND month = 7
       AND day = 28;
]
/*
| Sometime within ten minutes of the theft, I saw the thief get into a car in the bakery parking lot and drive away.
If you have security footage from the bakery parking lot, you might want to look for cars that left the parking lot in that time frame.                                                          |

| I don't know the thief's name, but it was someone I recognized.
Earlier this morning, before I arrived at Emma's bakery, I was walking by the ATM on Leggett Street and saw the thief there withdrawing some money.                                                                                                 |

| As the thief was leaving the bakery, they called someone who talked to them for less than a minute.
In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow.
The thief then asked the person on the other end of the phone to purchase the flight ticket. |
*/
3. [SELECT license_plate
      FROM bakery_security_logs
     WHERE month = 7
       AND day = 28
       AND activity = 'exit'
       AND hour = 10
       AND minute > 15
       AND minute < 25;
]
/*
| 5P2BI95       || 94KL13X       || 6P58WS2       || 4328GD8       |
| G412CB7       || L93JTIZ       || 322W7JE       || 0NTHK55       |
*/

4.[
SELECT name
  FROM people
  JOIN bank_accounts ON people.id = bank_accounts.person_id
  JOIN atm_transactions ON bank_accounts.account_number = atm_transactions.account_number
  JOIN bakery_security_logs ON people.license_plate = bakery_security_logs.license_plate
 WHERE atm_location = "Leggett Street"
   AND transaction_type = "withdraw"
   AND atm_transactions.month = 7
   AND atm_transactions.day = 28
   AND activity = 'exit'
   AND bakery_security_logs.minute > 15
   AND bakery_security_logs.minute < 25
   AND bakery_security_logs.hour = 10
   AND bakery_security_logs.day = 28
   AND bakery_security_logs.month = 7;
]
/*
| Bruce   || Diana   || Iman    || Luca    |
*/
5. [
  SELECT *
    FROM flights
   WHERE origin_airport_id = 8
     AND day = 29
ORDER BY hour ASC;
]
/*
| id | origin_airport_id | destination_airport_id | year | month | day | hour | minute |
+----+-------------------+------------------------+------+-------+-----+------+--------+
| 36 | 8                 | 4                      | 2023 | 7     | 29  | 8    | 20     |
| 43 | 8                 | 1                      | 2023 | 7     | 29  | 9    | 30     |
| 23 | 8                 | 11                     | 2023 | 7     | 29  | 12   | 15     |
| 53 | 8                 | 9                      | 2023 | 7     | 29  | 15   | 20     |
| 18 | 8                 | 6                      | 2023 | 7     | 29  | 16   | 0      |*/
6. [
SELECT *
FROM people
WHERE license_plate IN (
    SELECT license_plate
      FROM bakery_security_logs
     WHERE month = 7
       AND day = 28
       AND activity = 'exit'
       AND minute < 25
       AND minute > 15
)
AND id IN (
    SELECT person_id
    FROM bank_accounts
    JOIN atm_transactions ON bank_accounts.account_number = atm_transactions.account_number
   WHERE atm_location = "Leggett Street"
     AND transaction_type = "withdraw"
     AND month = 7
     AND day = 28
)
AND passport_number IN (
      SELECT passport_number
        FROM passengers
       WHERE flight_id IN (
          SELECT flight_id
            FROM flights
           WHERE origin_airport_id = 8
             AND day = 29))
AND phone_number IN (
      SELECT phone_number
        FROM phone_calls
       WHERE day = 28
         AND month = 7
);
]
/*

| 396669 | Iman  | (829) 555-5269 | 7049073643      | L93JTIZ       |
| 467400 | Luca  | (389) 555-5198 | 8496433585      | 4328GD8       |
| 514354 | Diana | (770) 555-1861 | 3592750733      | 322W7JE       |
| 686048 | Bruce | (367) 555-5533 | 5773159633      | 94KL13X       |
+--------+-------+----------------+-----------------+---------------+
*/

8. [
SELECT people.name, passengers.passport_number, flights.*
  FROM people
  JOIN passengers ON people.passport_number = passengers.passport_number
  JOIN flights ON passengers.flight_id = flights.id
 WHERE people.id IN (396669, 467400, 514354, 686048)
   AND flights.origin_airport_id = 8
   AND flights.day = 29;
]
/*|  name  | passport_number | id | origin_airport_id | destination_airport_id | year | month | day | hour | minute |
+--------+-----------------+----+-------------------+------------------------+------+-------+-----+------+--------+
| Diana  | 3592750733      | 18 | 8                 | 6                      | 2023 | 7     | 29  | 16   | 0      | Diana can be excluded!
| Bruce  | 5773159633      | 36 | 8                 | 4                      | 2023 | 7     | 29  | 8    | 20     |
| Luca   | 8496433585      | 36 | 8                 | 4                      | 2023 | 7     | 29  | 8    | 20     |
*/
9. [
SELECT people.name, phone_calls.*
  FROM people
  JOIN phone_calls ON people.phone_number = phone_calls.caller
 WHERE people.id IN (686048, 467400) --Brian and Luca IDs
   AND phone_calls.day = 28
   AND phone_calls.month = 7;
]
/*
| name  | id  |     caller     |    receiver    | year | month | day | duration |
+-------+-----+----------------+----------------+------+-------+-----+----------+
| Bruce | 233 | (367) 555-5533 | (375) 555-8161 | 2023 | 7     | 28  | 45       |   Bruce is a thief
| Bruce | 236 | (367) 555-5533 | (344) 555-9601 | 2023 | 7     | 28  | 120      |
| Bruce | 245 | (367) 555-5533 | (022) 555-4052 | 2023 | 7     | 28  | 241      |
| Bruce | 285 | (367) 555-5533 | (704) 555-5790 | 2023 | 7     | 28  | 75       |*/

10. [
SELECT city
  FROM airports
 WHERE id = 4;
]
/*
|     city      |  Bruce flew to New York City
+---------------+
| New York City |*/

12. [
SELECT name
  FROM people
 WHERE phone_number = '(375) 555-8161';
]
/*
| name  |  - Robin helped Bruce
+-------+
| Robin |*/
