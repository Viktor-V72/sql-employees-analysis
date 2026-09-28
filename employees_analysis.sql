-- SQL Step Project (MySQL)

-- ============================================
-- Part 1. Queries on the employees database
-- ============================================

-- 1. Show the average employee salary for each year, before 2005.
SELECT ROUND(AVG(sal.salary),2) AS avg_salary,
    YEAR(sal.from_date) as sal_year
FROM employees.salaries sal
WHERE  sal.from_date < '2005-01-01'
GROUP BY  YEAR(sal.from_date)
ORDER BY sal_year;

/* 2. Show the average salary for each department.
Note: calculated using employees' current salary and current department */
SELECT demp.dept_no,
	ROUND(AVG(sal.salary),2) AS avg_sal
FROM employees.salaries sal
INNER JOIN employees.dept_emp demp
	ON demp.emp_no = sal.emp_no
    AND demp.to_date > CURDATE()
WHERE sal.to_date > CURDATE()
GROUP BY demp.dept_no
ORDER BY demp.dept_no;

-- 3. Show the average salary for each department for each year
SELECT demp.dept_no,
	ROUND(AVG(sal.salary),2) AS avg_sal,
	YEAR(sal.from_date) as sal_year
FROM employees.salaries sal
INNER JOIN employees.dept_emp demp
	ON demp.emp_no = sal.emp_no
    AND sal.from_date < demp.to_date
    AND sal.to_date > demp.from_date
GROUP BY demp.dept_no,
		YEAR(sal.from_date)
ORDER BY demp.dept_no,
         sal_year;

-- 4. Show departments that currently have more than 15,000 employees.
SELECT dept_no,
	count(emp_no) AS qnt_emp
FROM employees.dept_emp
WHERE to_date > CURDATE()
GROUP BY dept_no
HAVING count(emp_no) > 15000;

-- 5. For the longest-serving manager, show their number, department, hire date and last name
SELECT emp.emp_no,
	mng.dept_no,
    emp.hire_date,
    emp.last_name
FROM employees.employees emp
INNER JOIN employees.dept_manager mng
	ON emp.emp_no = mng.emp_no
    AND mng.to_date > CURDATE()
ORDER BY emp.hire_date
LIMIT 1;

-- 6. Show the top 10 current employees with the largest difference between their salary and their department's average salary.
WITH cte_das
AS
(
	SELECT demp.dept_no,
		AVG(sal.salary)	AS avg_sal
	FROM employees.dept_emp demp
	INNER JOIN employees.salaries sal
			ON demp.emp_no = sal.emp_no
			AND sal.to_date > CURDATE()
	WHERE demp.to_date > CURDATE()
	GROUP BY dept_no
)
SELECT emp.emp_no,
	CONCAT(emp.first_name, " ", emp.last_name) AS full_name,
    ABS(sal.salary - das.avg_sal) AS diff
FROM employees.employees emp
INNER JOIN employees.salaries sal
	ON emp.emp_no = sal.emp_no
    AND sal.to_date > CURDATE()
INNER JOIN employees.dept_emp demp
	ON emp.emp_no = demp.emp_no
    AND demp.to_date > CURDATE()
INNER JOIN cte_das das
	ON das.dept_no = demp.dept_no
ORDER BY diff DESC
LIMIT 10;

/* 7. For each department, show the second manager in order. Output the department,
 the manager's full name, hire date and the date they became department manager */
WITH cte_row
AS
(
SELECT mng.dept_no,
	CONCAT(emp.first_name, " ", emp.last_name) AS full_name,
    emp.hire_date,
    mng.from_date,
    ROW_NUMBER() OVER (PARTITION BY mng.dept_no ORDER BY mng.from_date) AS row_n
FROM employees.employees emp
INNER JOIN employees.dept_manager mng
	ON emp.emp_no = mng.emp_no
)
SELECT *
FROM cte_row
WHERE cte_row.row_n = 2;

-- ============================================
-- Part 2. Database design
-- ============================================

/* 1. Create a database for course management. It should include the following tables:
- students: student_no, teacher_no, course_no, student_name, email, birth_date
- teachers: teacher_no, teacher_name, phone_no
- courses: course_no, course_name, start_date, end_date */

CREATE DATABASE IF NOT EXISTS course_mng;

USE course_mng;

CREATE TABLE IF NOT EXISTS course_mng.courses (
	course_no INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(255) NOT NULL,
    start_date DATE,
    end_date DATE
);

CREATE TABLE IF NOT EXISTS course_mng.teachers (
	teacher_no INT AUTO_INCREMENT PRIMARY KEY,
	teacher_name VARCHAR(255) NOT NULL,
    phone_no VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS course_mng.students (
	student_no INT AUTO_INCREMENT PRIMARY KEY,
	teacher_no INT,
    course_no INT,
    student_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
	birth_date DATE,
    
    FOREIGN KEY(teacher_no) REFERENCES teachers(teacher_no),
    FOREIGN KEY(course_no) REFERENCES courses(course_no)
);


-- 2. Add sample data (7-10 rows) to each table.

START TRANSACTION;

INSERT INTO course_mng.courses(course_name, start_date, end_date) 
VALUES('English', '2021-07-29', '2021-08-29'),
	('Mathematics', '2021-09-01', '2021-12-15'),
	('Physics', '2022-01-10', '2022-05-20'),
	('Computer Science', '2022-09-05', '2022-12-20'),
	('Data Analytics', '2023-02-01', '2023-06-01'),
	('Web Development', '2023-09-15', '2024-01-15'),
	('Database Systems', '2024-03-01', '2024-07-01');
    
INSERT INTO course_mng.teachers(teacher_name, phone_no)
VALUES ('John Smith', '+15551234567'),
	('Emily Johnson', '+15552345678'),
	('Michael Brown', '+15553456789'),
	('Sarah Davis', '+15554567890'),
	('David Wilson', '+15555678901'),
	('Jessica Miller', '+15556789012'),
	('Daniel Taylor', '+15557890123');
    
INSERT INTO course_mng.students(teacher_no, course_no, student_name, email, birth_date)
VALUES (1, 1, 'Viggo Denver' ,'viggo.denver@gmail.com', '2001-05-11'),
	(2, 2, 'Emma Carter', 'emma.carter@gmail.com', '2000-08-17'),
	(3, 3, 'Liam Walker', 'liam.walker@gmail.com', '2002-03-25'),
	(4, 4, 'Sophia Bennett', 'sophia.bennett@gmail.com', '2001-11-09'),
	(5, 5, 'Noah Cooper', 'noah.cooper@gmail.com', '1999-06-30'),
	(6, 6, 'Olivia Brooks', 'olivia.brooks@gmail.com', '2003-01-14'),
	(7, 7, 'Ethan Foster', 'ethan.foster@gmail.com', '2002-09-21');
    
COMMIT;

-- Added a few more students so that the data is more varied
INSERT INTO course_mng.students(teacher_no, course_no, student_name, email, birth_date)
VALUES
(1, 1, 'Jacob Harris', 'jacob.harris@gmail.com', '2002-12-18'),
(3, 3, 'Grace Turner', 'grace.turner@gmail.com', '2001-04-27'),
(5, 5, 'Lucas Moore', 'lucas.moore@gmail.com', '2000-09-05');


-- 3. For each teacher, show the number of students they have worked with

SELECT tch.teacher_name,
	count(std.student_no) AS std_count
FROM course_mng.teachers tch
INNER JOIN course_mng.students std
	ON std.teacher_no = tch.teacher_no
GROUP BY tch.teacher_no, tch.teacher_name;

-- 4. Intentionally create 3 duplicates in the students table (add 3 identical rows)

ALTER TABLE course_mng.students
DROP INDEX email;

INSERT INTO course_mng.students(teacher_no, course_no, student_name, email, birth_date)
SELECT teacher_no,
	course_no,
	student_name,
	email,
	birth_date
FROM course_mng.students
LIMIT 3;
    
-- 5. Write a query that returns duplicate rows in the students table
SELECT teacher_no,
	course_no, 
	student_name,
    birth_date,
    email,
	count(email) AS qnt_email
FROM course_mng.students
GROUP BY teacher_no,
	course_no, 
	student_name,
    birth_date,
	email
HAVING qnt_email > 1;
