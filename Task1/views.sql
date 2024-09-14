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


























