-- List all female patients along with their city and blood group. --
select patient_id, first_name, city, blood_group from patients where gender = 'female';
-- Find all doctors who specialize in Cardiology. --
select first_name, specialization from doctors where specialization = 'cardiology';
-- How many appointments were completed, cancelled, and marked No-Show? --
select count(status) as number_of_appointments, status from appointments group by status;
-- List all patients registered after January 1, 2020, ordered by registration date. --
select first_name, registered_date from patients where registered_date > '2020-01-01' order by registered_date;
-- What is the total revenue generated from completed appointments? --
select status, sum(fee) as revenue from appointments where status = 'completed';
-- Find the top 3 most expensive admission bills.-- 
select total_bill from admissions order by total_bill desc limit 3;
-- List all appointments scheduled for February 2024. --
select appointment_id, appointment_date from appointments where appointment_date between '2024-02-01' and '2024-02-29';
-- How many patients belong to each blood group? --
select count(blood_group), blood_group as no_of_patients from patients group by blood_group;
-- List the distinct room types available in the admissions table. --
select distinct room_type from admissions;
-- List each patient's full name along with the doctor they visited and the appointment date --
select concat(p.first_name, ' ', p.last_name) as full_name, 
concat(d.first_name, ' ', d.last_name) as full_doc_name, a.appointment_date from appointments a
join doctors d on a.doctor_id = d.doctor_id
join patients p on a.patient_id = p.patient_id;
-- Find the total bill amount per department for all admissions --
select d.department_name, sum(a.total_bill) as total_revenue from admissions a 
inner join departments d on a.department_id = d.department_id group by d.department_name;
-- Which patients have been both admitted (inpatient) AND had outpatient appointments? --
select ad.patient_id from admissions ad inner join appointments a on ad.patient_id = a.patient_id;
-- Find all doctors who have **never** had an appointment --
select d.doctor_id, d.first_name, d.specialization from doctors d left join appointments a on d.doctor_id = a.doctor_id where a.doctor_id is null;
-- List departments where the average admission bill exceeds ₹80,000 --
select d.department_name, avg(a.total_bill) as avg_bill from departments d 
join admissions a on d.department_id = a.department_id group by d.department_name having avg(total_bill) > 80000;
-- For each doctor, show the total number of appointments and total fees collected --
select d.first_name, d.doctor_id, count(a.doctor_id) as total_appointments, sum(a.fee) as total_fees from doctors d
left join appointments a on d.doctor_id = a.doctor_id group by d.doctor_id, d.first_name;
-- Find the patient who has visited the hospital the most number of times (appointments + admissions combined) --
SELECT p.patient_id, p.first_name, p.last_name, COUNT(*) AS total_visits FROM patients p
JOIN (SELECT patient_id FROM appointments UNION ALL SELECT patient_id FROM admissions
) AS all_visits ON p.patient_id = all_visits.patient_id GROUP BY p.patient_id, p.first_name, p.last_name ORDER BY total_visits DESC LIMIT 1;
-- List all admissions where the patient was in the ICU, along with the patient name and diagnosis. --
select a.patient_id, a.diagnosis, p.first_name from patients p join admissions a on p.patient_id = a.patient_id where a.room_type = 'ICU';
-- Find patients whose total admission bill is more than ₹1,00,000--
select p.first_name, a.patient_id, sum(a.total_bill) as total_patient_bill from patients p join 
admissions a on p.patient_id = a.patient_id group by a.patient_id, p.first_name having sum(a.total_bill) > 100000;
-- Rank doctors within each specialization by number of appointments using RANK  --
SELECT doctor_id, first_name, specialization, total_appointments, RANK() OVER (PARTITION BY specialization ORDER BY total_appointments DESC) AS rank_in_specialization
FROM (SELECT d.doctor_id, d.first_name, d.specialization, COUNT(a.appointment_id) AS total_appointments FROM doctors d LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.specialization) AS doctor_counts;
-- Calculate the running total of admission bills ordered by admission date using `SUM() OVER()-- 
select admission_id, total_bill, admission_date, sum(total_bill) over(order by admission_date) as running_total from admissions;
-- For each patient, show their latest appointment date and the appointment before that using `LAG()` --
select patient_id, appointment_date, lag(appointment_date, 1) over(partition by patient_id order by appointment_date) as last_appointed from appointments;
-- Find the top-earning doctor per department using `ROW_NUMBER() OVER(PARTITION BY department) --
select doctor_id, first_name, department_id, row_number() over(partition by department_id order by total_earnings desc) from 
(select d.doctor_id, d.first_name, d.department_id, sum(a.total_bill) as total_earnings
from doctors d join admissions a on d.doctor_id = a.doctor_id group by d.doctor_id, d.first_name, d.department_id) as earnings;
--  Calculate the length of stay (in days) for each admission, and find the average length of stay per department. --
select admission_id, admission_date, discharge_date, DATEDIFF(discharge_date, admission_date) as length_of_stay, 
avg(DATEDIFF(discharge_date, admission_date)) over(partition by department_id) as avg_days from admissions; 
-- Identify patients who were admitted more than once. Show their name, number of admissions, and total cumulative bill. --
select p.patient_id, p.first_name, count(a.admission_id) as no_of_admissions, sum(a.total_bill) 
from patients p join admissions a on p.patient_id = a.patient_id group by p.patient_id, p.first_name having no_of_admissions >1;