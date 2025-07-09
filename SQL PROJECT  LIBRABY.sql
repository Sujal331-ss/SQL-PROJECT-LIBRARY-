-- CREATING DATABASE 
CREATE DATABASE Library_Project;


-- CREATING TABLES 


DROP TABLE IF EXISTS Branch;
CREATE TABLE Branch (
    branch_id VARCHAR(50) PRIMARY KEY,
	manager_id VARCHAR(50),
	branch_address VARCHAR(50),
	contact_no VARCHAR(25)			
);


DROP TABLE IF EXISTS Employees;
CREATE TABLE Employees (
    emp_id VARCHAR(50) PRIMARY KEY,
  	emp_name VARCHAR(50),
 	position VARCHAR(50),
 	salary INT,
    branch_id VARCHAR(50),
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id)
);


DROP TABLE IF EXISTS MEMBERS;
CREATE TABLE MEMBERS (
    member_id VARCHAR(50) PRIMARY KEY,
 	member_name VARCHAR(50),
	member_address VARCHAR(50),
	reg_date DATE
);


DROP TABLE IF EXISTS Books;
CREATE TABLE Books (
	isbn VARCHAR(50) PRIMARY KEY,
	book_title VARCHAR(80),
	category VARCHAR(50),
	rental_price FLOAT,
	status VARCHAR(20),
	author VARCHAR(50),
	publisher VARCHAR(50)		
); 


DROP TABLE IF EXISTS Issued_Status;
CREATE TABLE Issued_Status (
    issued_id VARCHAR(50) PRIMARY KEY,
	issued_member_id VARCHAR(50),
    FOREIGN KEY (issued_member_id) REFERENCES MEMBERS(member_id),
	issued_book_name VARCHAR(75),
	issued_date DATE,
	issued_book_isbn VARCHAR(100),
    FOREIGN KEY (issued_book_isbn) REFERENCES Books(isbn),
	issued_emp_id VARCHAR(50),
    FOREIGN KEY (issued_emp_id) REFERENCES Employees(emp_id)
);


DROP TABLE IF EXISTS Return_Status;
CREATE TABLE Return_Status (
    return_id VARCHAR(50) PRIMARY KEY,
	issued_id VARCHAR(50),
    FOREIGN KEY (issued_id) REFERENCES Issued_Status(issued_id),
	return_book_name VARCHAR(50),
	return_date DATE,
	return_book_isbn VARCHAR(50), 
FOREIGN KEY (return_book_isbn) REFERENCES Books(isbn)
);


-- TASKS

-- Task 1. Create a New Book Record -- "'978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO Books (isbn, book_title, category, rental_price, status, author, publisher)
values 
('978-1-60129-456-2', "To Kill a Mockingbird", 'Classic', '6.00', 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address
UPDATE Members 
SET member_address = "123 OKAH ST"
WHERE member_id = "C103";

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status 
WHERE  issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT COUNT(*) as 'books issued' , issued_member_id, member_name, member_address
FROM issued_status
JOIN 
    Members ON
Issued_status.issued_member_id= members.member_id
GROUP BY issued_member_id, member_name, member_address
HAVING COUNT(*)>1
; 


-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt** 
CREATE TABLE book_issued_cnt
AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id)  
FROM books as b
JOIN 
issued_status as ist
on ist.issued_book_isbn=b.isbn
GROUP BY b.isbn, b.book_title;


-- Task 7: Retrieve All Books in a Specific Category:
SELECT * FROM books 
WHERE category = 'Classic';


-- Task 8: Find Total Rental Income by Category:
SELECT SUM(rental_price) AS rnt_p, books.category
from issued_status
JOIN books
ON books.isbn = issued_status.issued_book_isbn
GROUP BY books.category
ORDER BY rnt_p DESC;


-- Task 9: List Members Who Registered in the Last 180 Days:
SELECT member_id, member_name, reg_date
FROM members 
WHERE reg_date >= date_sub( '2024-05-01', interval 
180 DAY) ; 


-- TASK 10: List Employees with Their Branch Manager's Name and their branch details:
SELECT employees.emp_id,
employees.emp_name,
branch.manager_id,
e2.emp_name, 
branch.branch_id,
branch.branch_address, 
branch.contact_no
FROM employees 
JOIN branch
ON branch.branch_id=employees.branch_id
JOIN employees as e2
on branch.manager_id=e2.emp_id;


-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:
CREATE TABLE Expensive_books as 
SELECT * 
FROM books
WHERE rental_price>7;


-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT *
from issued_status as iss
left JOIN return_status as re
on iss.issued_id=re.issued_id
where return_id is null;


-- TASK 13:  CTAS: Create a Table of Active Members
Use the CRE_ATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.
CREATE TABLE active_members as
SELECT * 
FROM members
WHERE member_id IN ( SELECT DISTINCT issued_member_id   
		FROM issued_status
         where issued_date > DATE_SUB('2024-04-13', INTERVAL 2 month));
         
         select * FROM active_members;