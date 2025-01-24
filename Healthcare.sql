-- This script was created and executed by Carlos Egana, who performed the data analysis
-- to gather relevant information about patients, medical appointments, procedures, and costs,
-- using SQL to obtain key insights for decision-making.
-- Creation date: January 24, 2025


-- 1. How many patients are registered in the system?
-- Total patients
SELECT 
    COUNT(PatientID)
FROM
    patient;

-- 2. How many appointments has each patient had?
-- Total appointments per patient
SELECT 
    a.PatientID, COUNT(b.InvoiceID) AS Total
FROM
    appointment a
        LEFT JOIN
    billing b ON a.PatientID = b.PatientID
GROUP BY a.PatientID
ORDER BY total DESC;

-- 3. Which patients have had more than 3 appointments in the last six months?
-- 3+ Appointments in the last six months
SELECT 
    a.PatientID, a.Date, COUNT(b.InvoiceID) AS Total
FROM
    appointment a
        LEFT JOIN
    billing b ON a.PatientID = b.PatientID
WHERE
    a.Date >= '2023-06-01'
GROUP BY a.PatientID , a.Date
HAVING Total >= 3
ORDER BY Total DESC;

-- 4. What are the available procedures and how many are there?
-- Procedures
SELECT DISTINCT
    ProcedureName
FROM
    medical_procedure
ORDER BY ProcedureName ASC;

-- 5. How many different procedures are there?
-- Number of procedures
SELECT 
    COUNT(DISTINCT ProcedureName)
FROM
    medical_procedure;

-- 6. What are the 5 most common procedures in the last year?
-- Top 5 procedures
SELECT 
    ProcedureName, COUNT(ProcedureID) AS Total
FROM
    medical_procedure m
        LEFT JOIN
    appointment a ON m.AppointmentID = a.AppointmentID
WHERE
    a.Date >= '2023-01-01'
GROUP BY ProcedureName
ORDER BY Total DESC
LIMIT 5;

-- 7. Which medical specialties have the highest demand?
-- Most requested specialties
SELECT 
    d.Specialization, COUNT(d.Specialization) AS Total
FROM
    Appointment a
        LEFT JOIN
    Doctor d ON a.DoctorID = d.DoctorID
GROUP BY d.Specialization
ORDER BY Total DESC
LIMIT 10;

-- 8. What is the average medical cost per patient? Assign a category based on total spent.
-- AVG of bills, category assignment, and Subquery application
SELECT 
    PatientID,
    Total,
    CASE
        WHEN Total < 510275.7080 THEN 'Low Amount'
        WHEN Total > 510275.7080 THEN 'High Amount'
    END AS `Level of Bill`
FROM
    (SELECT 
        PatientID, SUM(Amount) AS Total
    FROM
        billing
    GROUP BY PatientID) AS Subquery
ORDER BY Total DESC;

-- 9. Which doctors have the highest number of scheduled appointments? Group by specialty.
-- Number of appointments per doctor
SELECT 
    d.DoctorName,
    d.Specialization,
    COUNT(a.AppointmentID) AS TotalAppointments
FROM
    doctor d
        LEFT JOIN
    appointment a ON d.DoctorID = a.DoctorID
GROUP BY d.DoctorName , d.Specialization
ORDER BY d.Specialization , TotalAppointments DESC;

-- 10. Which doctors are associated with the most expensive procedures?
-- Create views to determine procedures
CREATE VIEW appointment_billing AS
    SELECT 
        a.PatientID, a.DoctorID, COALESCE(b.Amount, 0) AS Amount
    FROM
        appointment a
            LEFT JOIN
        billing b ON a.PatientID = b.PatientID;

SELECT 
    ab.DoctorID, d.DoctorName, SUM(ab.Amount) AS TotalAmount
FROM
    appointment_billing ab
        LEFT JOIN
    doctor d ON ab.DoctorID = d.DoctorID
GROUP BY ab.DoctorID , d.DoctorName
ORDER BY TotalAmount DESC;

-- 11. Which procedures are most commonly repeated by patients?
-- Using CTE to determine the most requested procedures by patients
WITH AppointmentSummary AS (
    SELECT a.patientID, 
           count(a.AppointmentID) AS TotalAppointments, 
           a.DoctorID, 
           d.Specialization
    FROM appointment a
    LEFT JOIN doctor d
    ON a.DoctorID = d.DoctorID
    GROUP BY a.patientID, a.DoctorID, d.Specialization
)
SELECT * 
FROM AppointmentSummary
ORDER BY TotalAppointments DESC;
