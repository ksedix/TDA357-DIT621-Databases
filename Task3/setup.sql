--✔ enligt schema, Officiell

CREATE TABLE Students (
  idnr CHAR(10) PRIMARY KEY,
  name TEXT NOT NULL,
  login TEXT NOT NULL,
  program TEXT NOT NULL,
  UNIQUE (login),
  UNIQUE (idnr, program)
);

CREATE TABLE Departments (
  name TEXT PRIMARY KEY,
  abbreviation TEXT UNIQUE
);

CREATE TABLE Courses (
  code CHAR(6) PRIMARY KEY,
  name TEXT NOT NULL,
  credits REAL NOT NULL,
  department TEXT NOT NULL,
  FOREIGN KEY (department) REFERENCES Departments
);

CREATE TABLE Programs (
  name TEXT PRIMARY KEY,
  abbreviation TEXT
);

CREATE TABLE ProgramDepartment (
  program TEXT REFERENCES Programs,
  department TEXT REFERENCES Departments,
  PRIMARY KEY (program, department)
);

CREATE TABLE PrerequisiteCourses (
  course CHAR(6) REFERENCES Courses,
  prerequisiteCourse CHAR(6) REFERENCES Courses,
  PRIMARY KEY (course, prerequisiteCourse)
);


CREATE TABLE Branches (
  name TEXT,
  program TEXT REFERENCES Programs,
  PRIMARY KEY(name,program)
);

CREATE TABLE LimitedCourses (
  
  code CHAR(6) REFERENCES Courses,
  capacity INT NOT NULL,
  CHECK (capacity>0),
  PRIMARY KEY (code)
 
);

CREATE TABLE StudentBranches(
  
  student CHAR(10),
  branch TEXT NOT NULL,
  program TEXT NOT NULL,
  PRIMARY KEY (student),
  FOREIGN KEY (student, program) REFERENCES Students(idnr,program),
  FOREIGN KEY (branch,program) REFERENCES Branches(name,program)
  
);

CREATE TABLE Classifications(
  
  name TEXT PRIMARY KEY
  
);

CREATE TABLE Classified (
  
  course CHAR(6) REFERENCES Courses,
  classification TEXT REFERENCES Classifications,
  PRIMARY KEY (course, classification)
 
);


--mandatory courses for each program
CREATE TABLE MandatoryProgram (
  
  course CHAR(6) REFERENCES Courses,
  program TEXT,
  PRIMARY KEY (course,program)
  
);

CREATE TABLE MandatoryBranch (
  
  course CHAR(6) REFERENCES Courses,
  branch TEXT,
  program TEXT,
  PRIMARY KEY (course,branch,program),
  FOREIGN KEY (branch,program) REFERENCES Branches
  
);

CREATE TABLE RecommendedBranch (
  
  course CHAR(6) REFERENCES Courses,
  branch TEXT,
  program TEXT,
  PRIMARY KEY (course,branch,program),
  FOREIGN KEY (branch,program) REFERENCES Branches
  
);


CREATE TABLE Registered (
  
  student CHAR(10) REFERENCES Students,
  course CHAR(6) REFERENCES Courses,
  PRIMARY KEY (student,course)
    
);


--check that grade is a valid value
CREATE TABLE Taken (
  
  student CHAR(10) REFERENCES Students,
  course CHAR(6) REFERENCES Courses,
  grade CHAR(1) NOT NULL,
  CHECK (grade IN ('U','3','4','5')),
  PRIMARY KEY (student,course)
  
);

         

CREATE TABLE WaitingList (
  
  student CHAR(10) REFERENCES Students,
  course CHAR(6) REFERENCES LimitedCourses,
  position SERIAL NOT NULL,
  PRIMARY KEY (student,course)
  
);



--Officiell

--✔1 BasicInformation(idnr, name, login, program, branch)
CREATE VIEW BasicInformation AS SELECT idnr,name,login,students.program,branch FROM Students LEFT OUTER JOIN StudentBranches ON (idnr=student AND Students.program=StudentBranches.program);

--✔2 FinishedCourses(student, course, grade, credits)
CREATE VIEW FinishedCourses AS SELECT Taken.*,credits FROM Taken JOIN Courses ON (code=course); 

--✔3 PassedCourses(student, course, credits)
CREATE VIEW PassedCourses AS SELECT student,course,credits FROM FinishedCourses WHERE grade NOT LIKE 'U';

--✔4 Registrations(student, course, status)
CREATE VIEW Registrations AS SELECT student,course,CASE 
WHEN position IS NULL THEN 'registered'
ELSE 'waiting'
END AS status
FROM Registered NATURAL FULL OUTER JOIN WaitingList;

--✔5 UnreadMandatory(student, course)
CREATE VIEW UnreadMandatory AS
SELECT student,course FROM StudentBranches NATURAL JOIN MandatoryBranch UNION 
SELECT Students.idnr AS student,course
FROM Students
NATURAL JOIN Mandatoryprogram EXCEPT SELECT student,course FROM PassedCourses;

--✔6 PathToGraduation(student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified)

CREATE VIEW PathToGraduation AS
WITH 
table1 AS (SELECT idnr AS student FROM Students), 
table2 AS (SELECT student,SUM(credits) AS totalCredits FROM PassedCourses GROUP BY student),
table3 AS (SELECT student,COUNT(course) AS mandatoryLeft FROM UnreadMandatory GROUP BY student),
table4 AS (SELECT student,SUM(credits) AS mathCredits FROM passedCourses NATURAL JOIN Classified WHERE classification='math' GROUP BY student),
table5 AS (SELECT student,SUM(credits) AS researchCredits FROM passedCourses NATURAL JOIN Classified WHERE classification='research' GROUP BY student),
table6 AS (SELECT student,COUNT(classification) AS seminarCourses FROM passedCourses NATURAL JOIN Classified WHERE classification='seminar' GROUP BY student),
helperTable AS (SELECT student,credits AS recommendedCredits FROM studentBranches NATURAL JOIN RecommendedBranch NATURAL JOIN PassedCourses),
table7 AS (SELECT student,CASE WHEN mandatoryLeft IS NULL AND mathCredits>=20 AND researchCredits>=10 AND seminarCourses>=1 AND recommendedCredits>=10 THEN TRUE ELSE FALSE
END AS qualified FROM table1 NATURAL LEFT OUTER JOIN table2 NATURAL LEFT OUTER JOIN table3 NATURAL LEFT OUTER JOIN table4 NATURAL LEFT OUTER JOIN table5 NATURAL LEFT OUTER JOIN table6 NATURAL LEFT OUTER JOIN helperTable)

SELECT student,COALESCE(totalCredits,0) AS totalCredits,COALESCE(mandatoryLeft,0) AS mandatoryLeft,COALESCE(mathCredits,0) AS mathCredits,COALESCE(researchCredits,0) AS researchCredits, COALESCE(seminarCourses,0) AS seminarCourses, qualified

FROM table1 NATURAL LEFT OUTER JOIN table2 NATURAL LEFT OUTER JOIN table3 NATURAL LEFT OUTER JOIN table4 NATURAL LEFT OUTER JOIN table5 NATURAL LEFT OUTER JOIN table6 NATURAL LEFT OUTER JOIN table7;

--✔7 CourseQueuePositions(course,student,place)
CREATE VIEW CourseQueuePositions AS SELECT course, student, position AS place
FROM waitinglist;



--TASK 2: New inserts (we created them)

--the programs we know exist from previous inserts(TASK1) ✔
INSERT INTO Programs VALUES ('Prog1','P1'); 
INSERT INTO Programs VALUES ('Prog2','P2');

--the departments we know exist from previous inserts ✔
INSERT INTO Departments VALUES ('Dep1','D1');

--which department gives a program ✔
INSERT INTO ProgramDepartment VALUES ('Prog1','Dep1');
INSERT INTO ProgramDepartment VALUES ('Prog2','Dep1');


--Inserts from TASK1 (we did not create them)

INSERT INTO Branches VALUES ('B1','Prog1');
INSERT INTO Branches VALUES ('B2','Prog1');
INSERT INTO Branches VALUES ('B1','Prog2');

INSERT INTO Students VALUES ('1111111111','N1','ls1','Prog1');
INSERT INTO Students VALUES ('2222222222','N2','ls2','Prog1');
INSERT INTO Students VALUES ('3333333333','N3','ls3','Prog2');
INSERT INTO Students VALUES ('4444444444','N4','ls4','Prog1');
INSERT INTO Students VALUES ('5555555555','Nx','ls5','Prog2');
INSERT INTO Students VALUES ('6666666666','Nx','ls6','Prog2');

INSERT INTO Courses VALUES ('CCC111','C1',22.5,'Dep1');
INSERT INTO Courses VALUES ('CCC222','C2',20,'Dep1');
INSERT INTO Courses VALUES ('CCC333','C3',30,'Dep1');
INSERT INTO Courses VALUES ('CCC444','C4',60,'Dep1');
INSERT INTO Courses VALUES ('CCC555','C5',50,'Dep1');

--we made these up ✔
INSERT INTO PrerequisiteCourses VALUES ('CCC111','CCC222');
INSERT INTO PrerequisiteCourses VALUES ('CCC111','CCC333');
INSERT INTO PrerequisiteCourses VALUES ('CCC222','CCC444');
--we have to put them after Courses insert because it will not work otherwise

INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',2);

INSERT INTO Classifications VALUES ('math');
INSERT INTO Classifications VALUES ('research');
INSERT INTO Classifications VALUES ('seminar');

INSERT INTO Classified VALUES ('CCC333','math');
INSERT INTO Classified VALUES ('CCC444','math');
INSERT INTO Classified VALUES ('CCC444','research');
INSERT INTO Classified VALUES ('CCC444','seminar');


INSERT INTO StudentBranches VALUES ('2222222222','B1','Prog1');
INSERT INTO StudentBranches VALUES ('3333333333','B1','Prog2');
INSERT INTO StudentBranches VALUES ('4444444444','B1','Prog1');
INSERT INTO StudentBranches VALUES ('5555555555','B1','Prog2');

INSERT INTO MandatoryProgram VALUES ('CCC111','Prog1');

INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1');
INSERT INTO MandatoryBranch VALUES ('CCC444', 'B1', 'Prog2');

INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1');
INSERT INTO RecommendedBranch VALUES ('CCC333', 'B1', 'Prog2');

INSERT INTO Registered VALUES ('1111111111','CCC111');
INSERT INTO Registered VALUES ('1111111111','CCC222');
INSERT INTO Registered VALUES ('1111111111','CCC333');
INSERT INTO Registered VALUES ('2222222222','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC333');

INSERT INTO Taken VALUES('4444444444','CCC111','5');
INSERT INTO Taken VALUES('4444444444','CCC222','5');
INSERT INTO Taken VALUES('4444444444','CCC333','5');
INSERT INTO Taken VALUES('4444444444','CCC444','5');

INSERT INTO Taken VALUES('5555555555','CCC111','5');
INSERT INTO Taken VALUES('5555555555','CCC222','4');
INSERT INTO Taken VALUES('5555555555','CCC444','3');

INSERT INTO Taken VALUES('2222222222','CCC111','U');
INSERT INTO Taken VALUES('2222222222','CCC222','U');
INSERT INTO Taken VALUES('2222222222','CCC444','U');

INSERT INTO WaitingList VALUES('3333333333','CCC222',1);
INSERT INTO WaitingList VALUES('3333333333','CCC333',1);
INSERT INTO WaitingList VALUES('2222222222','CCC333',2);






















    
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
         
