# Healthcare Management System - SQL Data Analysis

## Introduction

This repository contains SQL scripts that perform data analysis on a healthcare management system dataset. The analysis gathers relevant information about patients, medical appointments, procedures, and billing costs, which can be used to make important decisions for the healthcare system.

The script was created and executed by **Carlos Egana** to answer specific business-related questions. The dataset comes from a Kaggle dataset focused on healthcare management, which includes information about patients, doctors, appointments, medical procedures, and billing transactions.

---

## Dataset Information

### Patients Table:
- **PatientID**: Unique identifier for each patient.
- **firstname**: First name of the patient.
- **lastname**: Last name of the patient.
- **email**: Email address of the patient.

This table stores individual patient information, including their names and contact details.

### Doctors Table:
- **DoctorID**: Unique identifier for each doctor.
- **DoctorName**: Full name of the doctor.
- **Specialization**: Area of medical specialization.
- **DoctorContact**: Contact details of the doctor.

This table contains healthcare provider information, including doctor names, specializations, and contact details.

### Appointments Table:
- **AppointmentID**: Unique identifier for each appointment.
- **Date**: Date of the appointment.
- **Time**: Time of the appointment.
- **PatientID**: Foreign key referencing the Patients table, indicating the patient for the appointment.
- **DoctorID**: Foreign key referencing the Doctors table, indicating the doctor for the appointment.

This table records scheduled appointments and links patients to doctors.

### MedicalProcedure Table:
- **ProcedureID**: Unique identifier for each medical procedure.
- **ProcedureName**: Name or description of the medical procedure.
- **AppointmentID**: Foreign key referencing the Appointments table, indicating the appointment associated with the procedure.

This table stores details about medical procedures associated with specific appointments.

### Billing Table:
- **InvoiceID**: Unique identifier for each billing transaction.
- **PatientID**: Foreign key referencing the Patients table, indicating the patient for the billing transaction.
- **Items**: Description of items or services billed.
- **Amount**: Amount charged for the billing transaction.

This table contains records of billing transactions associated with specific patients.

---
## SQL Techniques Used

1. **COUNT()**  
   Used to count the total number of records in a table or the total number of appointments per patient.

2. **JOINs (LEFT JOIN)**  
   Used to combine data from multiple tables (e.g., appointment and billing) based on common columns, such as `PatientID` and `DoctorID`.

3. **GROUP BY**  
   Used to group data by certain columns (e.g., `PatientID`, `DoctorID`, `Specialization`) to aggregate values such as counts or sums.

4. **HAVING**  
   Used in conjunction with `GROUP BY` to filter the results after the aggregation has been applied (e.g., to find patients with more than 3 appointments).

5. **DISTINCT**  
   Used to select unique records from a column, such as the distinct names of medical procedures.

6. **Subqueries**  
   Used to perform a query within another query, such as calculating the total medical costs per patient and assigning them a category.

7. **CTE (Common Table Expression)**  
   Used to create temporary result sets that can be referenced within the `SELECT`, `INSERT`, `UPDATE`, or `DELETE` statements. In this case, it was used to summarize appointments per patient and doctor.

8. **CREATE VIEW**  
   Used to create a virtual table (view) that can be queried like a regular table, useful for simplifying complex queries.

9. **CASE**  
   A conditional expression used to assign categories based on conditions, such as categorizing patients based on their total bill.

---
## SQL Script Overview

The following SQL script analyzes the dataset to answer several business questions regarding the healthcare system:

```sql
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



