--tests.sql

--part1: test all ways a registration could fail

--this student is already waiting for the course. This will raise an exception
INSERT INTO Registrations VALUES ('2222222222','CCC333');

--this student is already registered for the course CCC333. This will raise the same exception as the insert above

INSERT INTO Registrations VALUES ('5555555555','CCC333');

--this student has already passed the course we are trying to register them for . should raise an exception
INSERT INTO Registrations VALUES ('4444444444','CCC333');

--this student has not passed all prerequisite courses for the course they are trying to register for. The course CCC111 has 2 prerequisite courses: CCC222 & CCC444. The student has not passed any of the prerequisite courses.

INSERT INTO Registrations VALUES ('2222222222','CCC111');


--part2: test the outcomes of successful registrations/unregistrations

--successful registrations

--registered to unlimited course. The course CCC555 is an unlimited capacity course.
INSERT INTO Registrations VALUES ('1111111111','CCC555');


--registered to limited course. We have to invent a new limited course because all limited courses are already full. We will make an already existing course into a limited course with capacity of 5.

INSERT INTO LimitedCourses VALUES ('CCC555',5);
INSERT INTO Registrations VALUES ('2222222222','CCC555');


--being put in waiting list for a limited course because limited course is full. CCC333 is a limited course with a capacity of 2 and it is full so the student who tries to register will be put in a waiting list. We create a new student because all students are already registered,waiting or passed the course CCC333.
INSERT INTO Students VALUES ('7777777777','N5','ls7','Prog3');
INSERT INTO Registrations VALUES ('7777777777','CCC333');


--successful unregistrations(includes removing someone from waiting list)

--Remove student from waiting list of a course, with other students in the waiting list for that same course. The waiting list should update positions of the remaining students

DELETE FROM Registrations WHERE student='3333333333' AND course='CCC333';

--unregister student from unlimited course. Course CCC111 has unlimited capacity.

DELETE FROM Registrations WHERE student='1111111111' AND course='CCC111';


--unregistered from limited course without waiting list

DELETE FROM Registrations WHERE student='2222222222' AND course='CCC555';


--unregistered from limited course with waiting list. First person in waiting list should join the course.

DELETE FROM Registrations WHERE student='5555555555' AND course='CCC333';


--unregiestered from overfull course with waiting list. No person in the waiting list should be able to join the course because it will still be full.

DELETE FROM Registrations WHERE student='1111111111' AND course='CCC222';







































