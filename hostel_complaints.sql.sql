DROP DATABASE IF EXISTS hostel_complaint_db;
CREATE DATABASE hostel_complaint_db;
USE hostel_complaint_db;

CREATE TABLE Room (
    Room_ID    INT PRIMARY KEY AUTO_INCREMENT,
    Room_No    VARCHAR(10) NOT NULL UNIQUE,
    Floor      INT NOT NULL,
    Capacity   INT NOT NULL CHECK (Capacity > 0),
    Room_Type  VARCHAR(20) NOT NULL,                -- Single / Double / Triple
    Status     VARCHAR(15) NOT NULL DEFAULT 'Vacant'
               CHECK (Status IN ('Vacant','Occupied','Maintenance'))
);

CREATE TABLE Student (
    Student_ID      INT PRIMARY KEY AUTO_INCREMENT,
    Name            VARCHAR(50) NOT NULL,
    Phone_No        VARCHAR(15) NOT NULL,
    Email           VARCHAR(80) UNIQUE,
    Course          VARCHAR(50),
    Year            INT CHECK (Year BETWEEN 1 AND 5),
    Date_of_Joining DATE,
    Room_ID         INT,
    FOREIGN KEY (Room_ID) REFERENCES Room(Room_ID)
        ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE Complaint_Category (
    Category_ID   INT PRIMARY KEY AUTO_INCREMENT,
    Category_Name VARCHAR(40) NOT NULL UNIQUE,
    Description   VARCHAR(150)
);

CREATE TABLE Complaint (
    Complaint_ID   INT PRIMARY KEY AUTO_INCREMENT,
    Student_ID     INT NOT NULL,
    Room_ID        INT NOT NULL,
    Category_ID    INT NOT NULL,
    Complaint_Type VARCHAR(40),
    Description    VARCHAR(255),
    Date_Reported  DATE NOT NULL,
    Priority       VARCHAR(10) NOT NULL DEFAULT 'Medium'
                   CHECK (Priority IN ('Low','Medium','High')),
    Status         VARCHAR(15) NOT NULL DEFAULT 'Pending'
                   CHECK (Status IN ('Pending','In Progress','Resolved')),
    FOREIGN KEY (Student_ID)  REFERENCES Student(Student_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Room_ID)     REFERENCES Room(Room_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Category_ID) REFERENCES Complaint_Category(Category_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Maintenance_Staff (
    Staff_ID            INT PRIMARY KEY AUTO_INCREMENT,
    Staff_Name          VARCHAR(50) NOT NULL,
    Phone_No            VARCHAR(15) NOT NULL,
    Specialization      VARCHAR(40),
    Availability_Status VARCHAR(15) NOT NULL DEFAULT 'Available'
                        CHECK (Availability_Status IN ('Available','Busy','On Leave'))
);

CREATE TABLE Maintenance_Job (
    Job_ID           INT PRIMARY KEY AUTO_INCREMENT,
    Complaint_ID     INT NOT NULL,
    Staff_ID         INT NOT NULL,
    Assigned_Date    DATE NOT NULL,
    Start_Date       DATE,
    Completion_Date  DATE,
    In_Time          DATETIME,          
    Out_Time         DATETIME, 
    Work_Description VARCHAR(255),
    Cost             DECIMAL(10,2) DEFAULT 0.00 CHECK (Cost >= 0),
    Status           VARCHAR(15) NOT NULL DEFAULT 'Assigned'
                     CHECK (Status IN ('Assigned','In Progress','Completed')),
	CONSTRAINT chk_in_out CHECK (Out_Time IS NULL OR Out_Time >= In_Time),
    FOREIGN KEY (Complaint_ID) REFERENCES Complaint(Complaint_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Staff_ID) REFERENCES Maintenance_Staff(Staff_ID)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

CREATE TABLE Complaint_Feedback (
    Feedback_ID   INT PRIMARY KEY AUTO_INCREMENT,
    Complaint_ID  INT NOT NULL,
    Student_ID    INT NOT NULL,
    Job_ID        INT,
    Rating        INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comment       VARCHAR(255),
    Feedback_Date DATE,
    FOREIGN KEY (Complaint_ID) REFERENCES Complaint(Complaint_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Student_ID)   REFERENCES Student(Student_ID)
        ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (Job_ID)       REFERENCES Maintenance_Job(Job_ID)
        ON UPDATE CASCADE ON DELETE SET NULL
);

INSERT INTO Room (Room_No, Floor, Capacity, Room_Type, Status) VALUES
('101', 1, 3, 'Triple', 'Occupied'),
('102', 1, 2, 'Double', 'Occupied'),
('201', 2, 2, 'Double', 'Occupied'),
('202', 2, 1, 'Single', 'Vacant'),
('301', 3, 3, 'Triple', 'Occupied');

INSERT INTO Student (Name, Phone_No, Email, Course, Year, Date_of_Joining, Room_ID) VALUES
('Aarav Patil',   '9876500001', 'aarav@mail.com',  'B.Tech CSE',  2, '2025-07-15', 1),
('Riya Sharma',   '9876500002', 'riya@mail.com',   'B.Tech IT',   3, '2024-07-10', 1),
('Kunal Deshmukh','9876500003', 'kunal@mail.com',  'BCA',         1, '2026-07-20', 2),
('Sneha Joshi',   '9876500004', 'sneha@mail.com',  'MBA',         2, '2025-08-01', 3),
('Rahul Verma',   '9876500005', 'rahul@mail.com',  'B.Tech Mech', 4, '2023-07-12', 3),
('Pooja Nair',    '9876500006', 'pooja@mail.com',  'B.Sc',        1, '2026-07-22', 5);

INSERT INTO Complaint_Category (Category_Name, Description) VALUES
('Electrical', 'Fan, light, switch, wiring issues'),
('Plumbing',   'Leakage, tap, flush, drainage issues'),
('Furniture',  'Bed, table, chair, cupboard repair'),
('Cleaning',   'Room and washroom cleanliness'),
('Internet',   'Wi-Fi and LAN connectivity problems');

INSERT INTO Complaint
(Student_ID, Room_ID, Category_ID, Complaint_Type, Description, Date_Reported, Priority, Status) VALUES
(1, 1, 1, 'Fan',        'Ceiling fan not working',             '2026-09-01', 'High',   'Resolved'),
(2, 1, 2, 'Tap',        'Washroom tap leaking',                '2026-09-02', 'Medium', 'In Progress'),
(3, 2, 3, 'Cupboard',   'Cupboard door broken',                '2026-09-03', 'Low',    'Pending'),
(4, 3, 5, 'Wi-Fi',      'No internet since two days',          '2026-09-03', 'High',   'Resolved'),
(5, 3, 1, 'Tube light', 'Tube light flickering',               '2026-09-04', 'Medium', 'In Progress'),
(6, 5, 4, 'Washroom',   'Washroom not cleaned for a week',     '2026-09-05', 'High',   'Pending'),
(1, 1, 3, 'Bed',        'Bed frame is loose',                  '2026-09-06', 'Medium', 'Pending'),
(4, 3, 2, 'Flush',      'Flush tank not filling',              '2026-09-06', 'High',   'Pending');

INSERT INTO Maintenance_Staff (Staff_Name, Phone_No, Specialization, Availability_Status) VALUES
('Ramesh Kale',  '9123400001', 'Electrician', 'Busy'),
('Suresh More',  '9123400002', 'Plumber',     'Busy'),
('Dinesh Pawar', '9123400003', 'Carpenter',   'Available'),
('Anita Gaikwad','9123400004', 'Cleaner',     'Available'),
('Vikas Rane',   '9123400005', 'Network',     'Available');

INSERT INTO Maintenance_Job
(Complaint_ID, Staff_ID, Assigned_Date, Start_Date, Completion_Date, In_Time, Out_Time, Work_Description, Cost, Status) VALUES
(1, 1, '2026-09-01', '2026-09-01', '2026-09-02', '2026-09-01 10:00:00', '2026-09-02 12:00:00', 'Replaced fan capacitor',        350.00, 'Completed'),
(2, 2, '2026-09-02', '2026-09-03', NULL,         '2026-09-03 11:00:00', NULL,                  'Replacing tap washer',           150.00, 'In Progress'),
(4, 5, '2026-09-03', '2026-09-03', '2026-09-04', '2026-09-03 14:00:00', '2026-09-04 11:00:00', 'Router reset and cable changed', 500.00, 'Completed'),
(5, 1, '2026-09-04', '2026-09-05', NULL,         '2026-09-05 09:30:00', NULL,                  'Replacing tube light and choke', 200.00, 'In Progress');

INSERT INTO Complaint_Feedback (Complaint_ID, Student_ID, Job_ID, Rating, Comment, Feedback_Date) VALUES
(1, 1, 1, 5, 'Fixed quickly, very satisfied', '2026-09-02'),
(4, 4, 3, 4, 'Internet works fine now',        '2026-09-05');

SELECT * FROM Room;
SELECT * FROM Student;
SELECT * FROM Complaint_Category;
SELECT * FROM Complaint;
SELECT * FROM Maintenance_Staff;
SELECT * FROM Maintenance_Job;
SELECT * FROM Complaint_Feedback;

SELECT s.Student_ID, s.Name, r.Room_No, r.Floor, r.Room_Type
FROM Student s
JOIN Room r ON s.Room_ID = r.Room_ID;

SELECT s.Name, c.Complaint_ID, c.Complaint_Type, c.Date_Reported, c.Status
FROM Student s
JOIN Complaint c ON s.Student_ID = c.Student_ID
ORDER BY s.Name;

SELECT r.Room_No, COUNT(c.Complaint_ID) AS Total_Complaints
FROM Room r
LEFT JOIN Complaint c ON r.Room_ID = c.Room_ID
GROUP BY r.Room_No;

SELECT c.Complaint_ID, cc.Category_Name, c.Description, c.Priority
FROM Complaint c
JOIN Complaint_Category cc ON c.Category_ID = cc.Category_ID;

SELECT c.Complaint_ID, c.Description, j.Job_ID, ms.Staff_Name,
       ms.Specialization, j.Status AS Job_Status, j.Cost
FROM Complaint c
JOIN Maintenance_Job j     ON c.Complaint_ID = j.Complaint_ID
JOIN Maintenance_Staff ms  ON j.Staff_ID = ms.Staff_ID;

SELECT f.Feedback_ID, s.Name AS Student, ms.Staff_Name, f.Rating, f.Comment
FROM Complaint_Feedback f
JOIN Student s            ON f.Student_ID = s.Student_ID
JOIN Maintenance_Job j    ON f.Job_ID = j.Job_ID
JOIN Maintenance_Staff ms ON j.Staff_ID = ms.Staff_ID;

SELECT c.Complaint_ID, c.Description, c.Priority
FROM Complaint c
LEFT JOIN Maintenance_Job j ON c.Complaint_ID = j.Complaint_ID
WHERE j.Job_ID IS NULL AND c.Status = 'Pending'
ORDER BY FIELD(c.Priority,'High','Medium','Low');

SELECT Status, COUNT(*) AS Total FROM Complaint GROUP BY Status;

SELECT ms.Staff_Name, SUM(j.Cost) AS Total_Cost
FROM Maintenance_Staff ms
JOIN Maintenance_Job j ON ms.Staff_ID = j.Staff_ID
GROUP BY ms.Staff_Name;

SELECT ms.Staff_Name, ROUND(AVG(f.Rating),2) AS Avg_Rating
FROM Complaint_Feedback f
JOIN Maintenance_Job j    ON f.Job_ID = j.Job_ID
JOIN Maintenance_Staff ms ON j.Staff_ID = ms.Staff_ID
GROUP BY ms.Staff_Name;

SELECT Staff_ID, Staff_Name, Specialization
FROM Maintenance_Staff
WHERE Availability_Status = 'Available';

SELECT cc.Category_Name, COUNT(*) AS Total
FROM Complaint c
JOIN Complaint_Category cc ON c.Category_ID = cc.Category_ID
GROUP BY cc.Category_Name
ORDER BY Total DESC
LIMIT 1;
SELECT r.Room_No, ms.Staff_Name, ms.Specialization, c.Complaint_Type,
       j.In_Time, j.Out_Time,
       TIMESTAMPDIFF(MINUTE, j.In_Time, j.Out_Time) AS Minutes_Spent
FROM Maintenance_Job j
JOIN Complaint c          ON j.Complaint_ID = c.Complaint_ID
JOIN Room r               ON c.Room_ID = r.Room_ID
JOIN Maintenance_Staff ms ON j.Staff_ID = ms.Staff_ID
WHERE r.Room_No = '101'
ORDER BY r.Room_No, j.In_Time;
INSERT INTO Complaint
(Student_ID, Room_ID, Category_ID, Complaint_Type, Description, Date_Reported, Priority)
VALUES (2, 1, 5, 'Wi-Fi', 'Slow internet speed', '2026-09-07', 'Medium');

INSERT INTO Maintenance_Job (Complaint_ID, Staff_ID, Assigned_Date, Work_Description)
VALUES (LAST_INSERT_ID(), 5, '2026-09-07', 'Check access point and speed');

UPDATE Complaint SET Priority = 'High' WHERE Complaint_ID = 3;

UPDATE Maintenance_Job
SET Status = 'Completed', Completion_Date = '2026-09-07', Cost = 175.00,
Out_Time = '2026-09-07 16:30:00'
WHERE Job_ID = 2;

DELETE FROM Complaint_Feedback WHERE Feedback_ID = 2;

CREATE OR REPLACE VIEW vw_complaint_details AS
SELECT c.Complaint_ID, s.Name AS Student, r.Room_No, cc.Category_Name,
       c.Complaint_Type, c.Priority, c.Status, c.Date_Reported
FROM Complaint c
JOIN Student s            ON c.Student_ID = s.Student_ID
JOIN Room r               ON c.Room_ID = r.Room_ID
JOIN Complaint_Category cc ON c.Category_ID = cc.Category_ID;

SELECT * FROM vw_complaint_details WHERE Status <> 'Resolved';

DELIMITER $$

CREATE TRIGGER trg_after_job_insert
AFTER INSERT ON Maintenance_Job
FOR EACH ROW
BEGIN
    UPDATE Complaint SET Status = 'In Progress' WHERE Complaint_ID = NEW.Complaint_ID;
    UPDATE Maintenance_Staff SET Availability_Status = 'Busy' WHERE Staff_ID = NEW.Staff_ID;
END$$

CREATE TRIGGER trg_after_job_update
AFTER UPDATE ON Maintenance_Job
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Completed' AND OLD.Status <> 'Completed' THEN
        UPDATE Complaint SET Status = 'Resolved' WHERE Complaint_ID = NEW.Complaint_ID;
        UPDATE Maintenance_Staff SET Availability_Status = 'Available' WHERE Staff_ID = NEW.Staff_ID;
    END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE PROCEDURE sp_assign_job(
    IN p_complaint_id INT,
    IN p_staff_id     INT,
    IN p_work_desc    VARCHAR(255)
)
BEGIN
    INSERT INTO Maintenance_Job (Complaint_ID, Staff_ID, Assigned_Date, Work_Description)
    VALUES (p_complaint_id, p_staff_id, CURDATE(), p_work_desc);
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE sp_staff_in(IN p_job_id INT)
BEGIN
    UPDATE Maintenance_Job
    SET In_Time = NOW(), Start_Date = CURDATE(), Status = 'In Progress'
    WHERE Job_ID = p_job_id;
END$$

CREATE PROCEDURE sp_staff_out(IN p_job_id INT)
BEGIN
    UPDATE Maintenance_Job
    SET Out_Time = NOW()
    WHERE Job_ID = p_job_id;
END$$

DELIMITER ;
CALL sp_assign_job(6, 4, 'Deep clean washroom');
SELECT Complaint_ID, Status FROM Complaint WHERE Complaint_ID = 6;          -- In Progress
SELECT Staff_Name, Availability_Status FROM Maintenance_Staff WHERE Staff_ID = 4;  -- Busy
CALL sp_staff_in(6);
CALL sp_staff_out(6);
SELECT Job_ID, In_Time, Out_Time FROM Maintenance_Job WHERE Job_ID = 6;
START TRANSACTION;
    UPDATE Maintenance_Job SET Status = 'Completed', Completion_Date = CURDATE(), Out_Time=NOW()
    WHERE Job_ID = 4;
COMMIT;
SELECT r.Room_No, ms.Staff_Name, c.Complaint_Type,
       j.In_Time, j.Out_Time,
       TIMESTAMPDIFF(MINUTE, j.In_Time, j.Out_Time) AS Minutes_Spent
FROM Maintenance_Job j
JOIN Complaint c          ON j.Complaint_ID = c.Complaint_ID
JOIN Room r               ON c.Room_ID = r.Room_ID
JOIN Maintenance_Staff ms ON j.Staff_ID = ms.Staff_ID
WHERE r.Room_No = '101'
ORDER BY r.Room_No, j.In_Time;
