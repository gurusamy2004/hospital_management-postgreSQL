-- ============================================================
--  HOSPITAL MANAGEMENT SYSTEM — PostgreSQL Version
--  Author : Gurusamy V
--  Level  : Intermediate
--  Covers : DDL, DML, JOINs, GROUP BY, Subqueries, Views
-- ============================================================


-- ============================================================
-- SECTION 1: DATABASE SETUP
-- ============================================================
-- Run this block ONCE in pgAdmin's Query Tool after connecting.
-- PostgreSQL does not support DROP DATABASE inside a script
-- while connected to it. So we use a schema to isolate objects.

DROP SCHEMA IF EXISTS hospital CASCADE;
CREATE SCHEMA hospital;
SET search_path TO hospital;


-- ============================================================
-- SECTION 2: TABLE CREATION (DDL)
-- ============================================================

-- 2.1 Departments
CREATE TABLE departments (
    department_id   SERIAL        PRIMARY KEY,
    dept_name       VARCHAR(100)  NOT NULL,
    location        VARCHAR(100)  NOT NULL
);

-- 2.2 Doctors
CREATE TABLE doctors (
    doctor_id       SERIAL        PRIMARY KEY,
    first_name      VARCHAR(50)   NOT NULL,
    last_name       VARCHAR(50)   NOT NULL,
    specialization  VARCHAR(100)  NOT NULL,
    department_id   INT           NOT NULL,
    contact_email   VARCHAR(100)  UNIQUE,
    hire_date       DATE          NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- 2.3 Patients
CREATE TABLE patients (
    patient_id      SERIAL        PRIMARY KEY,
    first_name      VARCHAR(50)   NOT NULL,
    last_name       VARCHAR(50)   NOT NULL,
    date_of_birth   DATE          NOT NULL,
    gender          VARCHAR(10)   CHECK (gender IN ('Male','Female','Other')) NOT NULL,
    contact_phone   VARCHAR(20),
    address         VARCHAR(200),
    registered_on   DATE          NOT NULL
);

-- 2.4 Appointments
CREATE TABLE appointments (
    appointment_id   SERIAL       PRIMARY KEY,
    patient_id       INT          NOT NULL,
    doctor_id        INT          NOT NULL,
    appointment_date DATE         NOT NULL,
    appointment_time TIME         NOT NULL,
    status           VARCHAR(20)  CHECK (status IN ('Scheduled','Completed','Cancelled')) DEFAULT 'Scheduled',
    reason           VARCHAR(200),
    FOREIGN KEY (patient_id) REFERENCES patients(patient_id),
    FOREIGN KEY (doctor_id)  REFERENCES doctors(doctor_id)
);

-- 2.5 Medical Records
CREATE TABLE medical_records (
    record_id       SERIAL        PRIMARY KEY,
    appointment_id  INT           NOT NULL UNIQUE,
    diagnosis       VARCHAR(300)  NOT NULL,
    prescription    TEXT,
    notes           TEXT,
    record_date     DATE          NOT NULL,
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
);

-- 2.6 Billing
CREATE TABLE billing (
    bill_id         SERIAL          PRIMARY KEY,
    patient_id      INT             NOT NULL,
    appointment_id  INT             NOT NULL,
    total_amount    NUMERIC(10,2)   NOT NULL,
    paid_amount     NUMERIC(10,2)   DEFAULT 0.00,
    payment_status  VARCHAR(20)     CHECK (payment_status IN ('Paid','Partial','Unpaid')) DEFAULT 'Unpaid',
    bill_date       DATE            NOT NULL,
    FOREIGN KEY (patient_id)     REFERENCES patients(patient_id),
    FOREIGN KEY (appointment_id) REFERENCES appointments(appointment_id)
);


-- ============================================================
-- SECTION 3: SAMPLE DATA (DML)
-- ============================================================

-- Departments
INSERT INTO departments (dept_name, location) VALUES
('Cardiology',       'Block A, Floor 1'),
('Neurology',        'Block A, Floor 2'),
('Orthopedics',      'Block B, Floor 1'),
('Pediatrics',       'Block B, Floor 2'),
('General Medicine', 'Block C, Floor 1');

-- Doctors
INSERT INTO doctors (first_name, last_name, specialization, department_id, contact_email, hire_date) VALUES
('Arjun',   'Sharma',    'Cardiologist',       1, 'arjun.sharma@hospital.com',  '2018-03-15'),
('Priya',   'Nair',      'Neurologist',        2, 'priya.nair@hospital.com',    '2019-07-01'),
('Rahul',   'Verma',     'Orthopedic Surgeon', 3, 'rahul.verma@hospital.com',   '2020-01-10'),
('Sneha',   'Iyer',      'Pediatrician',       4, 'sneha.iyer@hospital.com',    '2017-11-20'),
('Karthik', 'Raj',       'General Physician',  5, 'karthik.raj@hospital.com',   '2021-05-05'),
('Divya',   'Menon',     'Cardiologist',       1, 'divya.menon@hospital.com',   '2022-08-12'),
('Arun',    'Kumar',     'Neurologist',        2, 'arun.kumar@hospital.com',    '2016-04-30');

-- Patients
INSERT INTO patients (first_name, last_name, date_of_birth, gender, contact_phone, address, registered_on) VALUES
('Murugan',   'Selvam',    '1978-06-12', 'Male',   '9876543210', 'Chennai',    '2023-01-05'),
('Lakshmi',   'Devi',      '1990-03-25', 'Female', '9845612378', 'Madurai',    '2023-02-14'),
('Venkatesh', 'Pillai',    '1965-11-08', 'Male',   '9912345678', 'Coimbatore', '2023-03-20'),
('Anitha',    'Raj',       '2000-07-17', 'Female', '9733456789', 'Salem',      '2023-04-01'),
('Suresh',    'Babu',      '1955-01-30', 'Male',   '9654321098', 'Trichy',     '2023-04-15'),
('Kavitha',   'Sundaram',  '1983-09-22', 'Female', '9543210987', 'Chennai',    '2023-05-10'),
('Rajan',     'Muthusamy', '1970-12-05', 'Male',   '9432109876', 'Madurai',    '2023-06-18'),
('Geetha',    'Krishnan',  '1995-04-14', 'Female', '9321098765', 'Chennai',    '2023-07-22'),
('Bala',      'Subramani', '2010-08-03', 'Male',   '9210987654', 'Coimbatore', '2023-08-05'),
('Preethi',   'Mohan',     '1988-02-19', 'Female', '9109876543', 'Chennai',    '2023-09-11');

-- Appointments
INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, status, reason) VALUES
(1,  1, '2024-01-10', '09:00', 'Completed',  'Chest pain follow-up'),
(2,  2, '2024-01-12', '10:30', 'Completed',  'Migraine evaluation'),
(3,  3, '2024-01-15', '11:00', 'Completed',  'Knee pain assessment'),
(4,  4, '2024-01-18', '14:00', 'Completed',  'Routine pediatric checkup'),
(5,  1, '2024-02-05', '09:30', 'Completed',  'Hypertension management'),
(6,  5, '2024-02-08', '16:00', 'Completed',  'Fever and cold'),
(7,  2, '2024-02-20', '10:00', 'Cancelled',  'Headache consultation'),
(8,  6, '2024-03-01', '09:00', 'Completed',  'ECG and heart checkup'),
(9,  4, '2024-03-10', '13:00', 'Completed',  'Vaccination'),
(10, 7, '2024-03-15', '11:30', 'Completed',  'Dizziness and vertigo'),
(1,  6, '2024-04-02', '10:00', 'Scheduled',  'Cardiac stress test'),
(3,  3, '2024-04-05', '14:30', 'Scheduled',  'Post-surgery follow-up'),
(5,  1, '2024-04-10', '09:00', 'Completed',  'Blood pressure review'),
(2,  7, '2024-04-12', '15:00', 'Completed',  'MRI result discussion'),
(6,  5, '2024-04-20', '11:00', 'Cancelled',  'Routine check');

-- Medical Records
INSERT INTO medical_records (appointment_id, diagnosis, prescription, notes, record_date) VALUES
(1,  'Angina Pectoris',         'Nitroglycerin 0.5mg, Aspirin 75mg',    'Patient advised rest and low-sodium diet',        '2024-01-10'),
(2,  'Chronic Migraine',        'Sumatriptan 50mg, Paracetamol 500mg',  'MRI recommended, avoid bright light',             '2024-01-12'),
(3,  'Osteoarthritis — Knee',   'Ibuprofen 400mg, Physiotherapy',       'X-ray taken, physiotherapy sessions recommended', '2024-01-15'),
(4,  'Healthy — Routine Visit', 'Vitamin D3 supplement',                'Growth and weight normal for age',                '2024-01-18'),
(5,  'Hypertension Stage 2',    'Amlodipine 5mg, Metoprolol 25mg',     'Reduce salt intake, daily walk recommended',      '2024-02-05'),
(6,  'Viral Fever',             'Paracetamol 500mg, ORS, Rest',         'Viral, should resolve in 5 days',                '2024-02-08'),
(8,  'Mild Arrhythmia',         'Metoprolol 25mg',                      'Holter monitor for 24 hours advised',             '2024-03-01'),
(9,  'Vaccination — DPT Booster','N/A',                                 'No adverse reaction observed',                   '2024-03-10'),
(10, 'Benign Positional Vertigo','Betahistine 8mg',                     'Epley maneuver performed, improvement noted',    '2024-03-15'),
(13, 'Controlled Hypertension', 'Continue Amlodipine 5mg',             'BP within normal range, continue medication',     '2024-04-10'),
(14, 'Migraine with Aura',      'Topiramate 25mg, Sumatriptan 50mg',   'MRI shows no structural abnormalities',           '2024-04-12');

-- Billing
INSERT INTO billing (patient_id, appointment_id, total_amount, paid_amount, payment_status, bill_date) VALUES
(1,  1,  1500.00, 1500.00, 'Paid',    '2024-01-10'),
(2,  2,  1200.00, 1200.00, 'Paid',    '2024-01-12'),
(3,  3,  2500.00, 1500.00, 'Partial', '2024-01-15'),
(4,  4,   800.00,  800.00, 'Paid',    '2024-01-18'),
(5,  5,  1500.00,    0.00, 'Unpaid',  '2024-02-05'),
(6,  6,   600.00,  600.00, 'Paid',    '2024-02-08'),
(8,  8,  1800.00, 1800.00, 'Paid',    '2024-03-01'),
(9,  9,   400.00,  400.00, 'Paid',    '2024-03-10'),
(10, 10, 1000.00,  500.00, 'Partial', '2024-03-15'),
(5,  13, 1500.00, 1500.00, 'Paid',    '2024-04-10'),
(2,  14, 1200.00,    0.00, 'Unpaid',  '2024-04-12');


-- ============================================================
-- SECTION 4: QUERIES
-- ============================================================

-- ------------------------------------------------------------
-- LEVEL 1: Basic SELECT + JOIN Queries
-- ------------------------------------------------------------

-- Q1: List all patients with full name and registration date
SELECT
    patient_id,
    first_name || ' ' || last_name  AS full_name,
    gender,
    registered_on
FROM patients
ORDER BY registered_on;

-- Q2: List all doctors with their department name
SELECT
    d.doctor_id,
    d.first_name || ' ' || d.last_name  AS doctor_name,
    d.specialization,
    dept.dept_name,
    dept.location
FROM doctors d
JOIN departments dept ON d.department_id = dept.department_id
ORDER BY dept.dept_name;

-- Q3: List all completed appointments with patient and doctor names
SELECT
    a.appointment_id,
    p.first_name || ' ' || p.last_name  AS patient_name,
    d.first_name || ' ' || d.last_name  AS doctor_name,
    a.appointment_date,
    a.appointment_time,
    a.reason
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors  d ON a.doctor_id  = d.doctor_id
WHERE a.status = 'Completed'
ORDER BY a.appointment_date;

-- Q4: Show all billing records with patient name and payment status
SELECT
    b.bill_id,
    p.first_name || ' ' || p.last_name  AS patient_name,
    b.total_amount,
    b.paid_amount,
    (b.total_amount - b.paid_amount)     AS balance_due,
    b.payment_status,
    b.bill_date
FROM billing b
JOIN patients p ON b.patient_id = p.patient_id
ORDER BY b.bill_date;


-- ------------------------------------------------------------
-- LEVEL 2: GROUP BY + Aggregate Queries
-- ------------------------------------------------------------

-- Q5: Total appointments per doctor
SELECT
    d.first_name || ' ' || d.last_name  AS doctor_name,
    d.specialization,
    COUNT(a.appointment_id)             AS total_appointments
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name, d.specialization
ORDER BY total_appointments DESC;

-- Q6: Total revenue collected per department
SELECT
    dept.dept_name,
    COUNT(b.bill_id)                        AS total_bills,
    SUM(b.total_amount)                     AS total_billed,
    SUM(b.paid_amount)                      AS total_collected,
    SUM(b.total_amount - b.paid_amount)     AS outstanding
FROM billing b
JOIN appointments  a    ON b.appointment_id = a.appointment_id
JOIN doctors       d    ON a.doctor_id      = d.doctor_id
JOIN departments   dept ON d.department_id  = dept.department_id
GROUP BY dept.department_id, dept.dept_name
ORDER BY total_collected DESC;

-- Q7: Count of appointments by status
SELECT
    status,
    COUNT(*) AS count
FROM appointments
GROUP BY status;

-- Q8: Number of patients registered per month
SELECT
    EXTRACT(YEAR  FROM registered_on) AS year,
    EXTRACT(MONTH FROM registered_on) AS month,
    COUNT(*)                          AS new_patients
FROM patients
GROUP BY year, month
ORDER BY year, month;

-- Q9: Departments with more than 1 doctor
SELECT
    dept.dept_name,
    COUNT(d.doctor_id) AS doctor_count
FROM departments dept
JOIN doctors d ON dept.department_id = d.department_id
GROUP BY dept.department_id, dept.dept_name
HAVING COUNT(d.doctor_id) > 1;


-- ------------------------------------------------------------
-- LEVEL 3: Subqueries
-- ------------------------------------------------------------

-- Q10: Patients who have unpaid or partial bills
SELECT
    p.first_name || ' ' || p.last_name  AS patient_name,
    p.contact_phone,
    b.total_amount,
    b.paid_amount,
    b.payment_status
FROM patients p
JOIN billing b ON p.patient_id = b.patient_id
WHERE b.payment_status IN ('Unpaid', 'Partial');

-- Q11: Doctor with the highest number of completed appointments
SELECT
    d.first_name || ' ' || d.last_name  AS doctor_name,
    d.specialization,
    COUNT(a.appointment_id)             AS completed_count
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
WHERE a.status = 'Completed'
GROUP BY d.doctor_id, d.first_name, d.last_name, d.specialization
HAVING COUNT(a.appointment_id) = (
    SELECT MAX(cnt) FROM (
        SELECT COUNT(appointment_id) AS cnt
        FROM appointments
        WHERE status = 'Completed'
        GROUP BY doctor_id
    ) AS sub
);

-- Q12: Patients who visited more than once
SELECT
    p.first_name || ' ' || p.last_name  AS patient_name,
    COUNT(a.appointment_id)             AS total_visits
FROM patients p
JOIN appointments a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name
HAVING COUNT(a.appointment_id) > 1
ORDER BY total_visits DESC;

-- Q13: Patients who have never cancelled an appointment
SELECT
    first_name || ' ' || last_name  AS patient_name
FROM patients
WHERE patient_id NOT IN (
    SELECT DISTINCT patient_id
    FROM appointments
    WHERE status = 'Cancelled'
);

-- Q14: Average bill per department vs overall hospital average
SELECT
    dept.dept_name,
    ROUND(AVG(b.total_amount), 2)                           AS dept_avg_bill,
    (SELECT ROUND(AVG(total_amount)::NUMERIC, 2) FROM billing) AS hospital_avg_bill
FROM billing b
JOIN appointments  a    ON b.appointment_id = a.appointment_id
JOIN doctors       d    ON a.doctor_id      = d.doctor_id
JOIN departments   dept ON d.department_id  = dept.department_id
GROUP BY dept.dept_name;


-- ------------------------------------------------------------
-- LEVEL 4: Views
-- ------------------------------------------------------------

-- View 1: Full appointment summary
CREATE OR REPLACE VIEW vw_appointment_summary AS
SELECT
    a.appointment_id,
    a.appointment_date,
    a.status,
    p.first_name || ' ' || p.last_name  AS patient_name,
    d.first_name || ' ' || d.last_name  AS doctor_name,
    d.specialization,
    dept.dept_name,
    mr.diagnosis,
    b.total_amount,
    b.payment_status
FROM appointments a
JOIN patients     p    ON a.patient_id      = p.patient_id
JOIN doctors      d    ON a.doctor_id       = d.doctor_id
JOIN departments  dept ON d.department_id   = dept.department_id
LEFT JOIN medical_records mr ON a.appointment_id = mr.appointment_id
LEFT JOIN billing         b  ON a.appointment_id = b.appointment_id;

-- Use the view
SELECT * FROM vw_appointment_summary WHERE status = 'Completed';

-- View 2: Outstanding payments
CREATE OR REPLACE VIEW vw_outstanding_payments AS
SELECT
    p.first_name || ' ' || p.last_name  AS patient_name,
    p.contact_phone,
    b.bill_date,
    b.total_amount,
    b.paid_amount,
    (b.total_amount - b.paid_amount)     AS balance_due,
    b.payment_status
FROM billing b
JOIN patients p ON b.patient_id = p.patient_id
WHERE b.payment_status != 'Paid';

-- Use the view
SELECT * FROM vw_outstanding_payments ORDER BY balance_due DESC;


-- ============================================================
-- SECTION 5: BUSINESS INSIGHT QUERIES
-- ============================================================

-- INSIGHT 1: Which specialization generates the most revenue?
SELECT
    d.specialization,
    SUM(b.total_amount)  AS total_billed,
    SUM(b.paid_amount)   AS total_collected
FROM billing b
JOIN appointments a ON b.appointment_id = a.appointment_id
JOIN doctors d      ON a.doctor_id      = d.doctor_id
GROUP BY d.specialization
ORDER BY total_collected DESC;

-- INSIGHT 2: Monthly revenue trend
SELECT
    EXTRACT(YEAR  FROM bill_date)           AS year,
    EXTRACT(MONTH FROM bill_date)           AS month,
    SUM(total_amount)                       AS total_billed,
    SUM(paid_amount)                        AS collected,
    SUM(total_amount - paid_amount)         AS outstanding
FROM billing
GROUP BY year, month
ORDER BY year, month;

-- INSIGHT 3: Patient age group analysis
SELECT
    CASE
        WHEN DATE_PART('year', AGE(date_of_birth)) < 18 THEN 'Under 18'
        WHEN DATE_PART('year', AGE(date_of_birth)) < 40 THEN '18 – 39'
        WHEN DATE_PART('year', AGE(date_of_birth)) < 60 THEN '40 – 59'
        ELSE '60+'
    END AS age_group,
    COUNT(*) AS patient_count
FROM patients
GROUP BY age_group
ORDER BY age_group;

-- INSIGHT 4: Doctor utilization rate
SELECT
    d.first_name || ' ' || d.last_name         AS doctor_name,
    COUNT(a.appointment_id)                    AS total_appointments,
    SUM(CASE WHEN a.status = 'Completed' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN a.status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    ROUND(
        SUM(CASE WHEN a.status = 'Completed' THEN 1 ELSE 0 END) * 100.0
        / COUNT(a.appointment_id), 1
    ) AS completion_rate_pct
FROM doctors d
JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name
ORDER BY completion_rate_pct DESC;
