--triggers.sql

--2 triggers

--trigger1
--put student in waiting list if they try to register for a course that is full. Also, raise exception if student is not eligible to register for the course

--trigger2
--If a student is unregistered from a course through the Registrations view, then the first student in the waiting list for that course is automatically added to the course registration.


--trigger1

CREATE FUNCTION registerStudent()
RETURNS trigger AS $$
BEGIN
--trigger code

--check that the student may actually register for the course

--it can not already be registered or waiting for the course
--behöver vi 2 exists?
IF (EXISTS (SELECT student,course FROM WaitingList WHERE (student=NEW.student AND course=NEW.course)) OR EXISTS (SELECT student,course FROM Registered WHERE student=NEW.student AND course=NEW.course)) THEN
    RAISE EXCEPTION 'Student can not already be registered or waiting';
END IF;
                        
--it can not already have passed the course                                      
                                                                                   
IF (EXISTS (SELECT student,course FROM passedCourses WHERE (student=NEW.student AND course=NEW.course))) THEN
    RAISE EXCEPTION 'Student can not have already passed the course';                      
END IF;
                                                            
                                                            
--it must have passed all prerequisite courses. all prerequisite courses must be in the students passed courses. Course CCC111 has 2 prerequisite courses. How to check that it has passed both of those prerequisite courses?                                                            

--get all prerequisite courses for the course you want to register to: SELECT prerequisiteCourse FROM prerequisiteCourses WHERE (course=NEW.course);                                                           
--get all students passed courses: SELECT course FROM passedCourses WHERE student=NEW.student;

--check that all prerequisite courses are in the students passed courses
--do union of the 2 tables. compare length of union with length of prerequisiteCourses
                                                            
                                                            
IF ((SELECT COUNT(*) FROM                                                         
((SELECT prerequisiteCourse FROM prerequisiteCourses WHERE (course=NEW.course)) INTERSECT (SELECT course FROM passedCourses WHERE student=NEW.student)) AS table1) NOT IN (SELECT COUNT(*) FROM prerequisiteCourses WHERE (course=NEW.course))) THEN                                                     
RAISE EXCEPTION 'Student must have passed all prerequisite courses for the course they are trying to register on';                     
END IF;
                                                              
                                                                                 --check if the course is a limited capacity course
IF (EXISTS (SELECT code FROM limitedCourses WHERE code=NEW.course)) THEN
--check that the course is not full(only if it is a limited course)
IF (SELECT COUNT(*) FROM registered WHERE course = NEW.course)>=(SELECT capacity FROM limitedCourses WHERE code = NEW.course) THEN
    INSERT INTO WaitingList VALUES (NEW.student, NEW.course, (SELECT COUNT(*)
    FROM waitingList
    WHERE course = NEW.course)+1);
ELSE 
    --if the course is not full, add the student as registered
    INSERT INTO Registered VALUES (NEW.student, NEW.course);
END IF;
ELSE
    --if it is not a limited capacity course, you can directly register the student for it.
    INSERT INTO Registered VALUES (NEW.student, NEW.course);
END IF;


RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trigger1
INSTEAD OF INSERT 
ON Registrations
FOR EACH ROW
EXECUTE PROCEDURE registerStudent();



--trigger2

CREATE FUNCTION unregisterStudent()
RETURNS trigger AS $$
BEGIN
                   
--delete the student from registered table or from waiting list            
IF (OLD.status='waiting') THEN
    DELETE FROM Registered WHERE (student=OLD.student AND course=OLD.course);   
    UPDATE WaitingList SET position = position-1
    WHERE course = OLD.course AND position > (SELECT position FROM WaitingList
    WHERE student=OLD.student AND course=OLD.course);
    DELETE FROM WaitingList WHERE (student=OLD.student AND course=OLD.course);        
ELSE       
DELETE FROM Registered WHERE (student=OLD.student AND course=OLD.course);
--if there is student in waiting list for the course and the course is not overfull, register them for the course. Update the waiting list.
IF (EXISTS (SELECT * FROM WaitingList WHERE course=OLD.course) AND (SELECT COUNT(*) FROM registered WHERE course = OLD.course)<(SELECT capacity FROM limitedCourses WHERE code = OLD.course))
THEN
    INSERT INTO Registered
    SELECT student,course FROM WaitingList WHERE (course=OLD.course AND position=1);
    DELETE FROM WaitingList WHERE (course=OLD.course AND position=1);
    UPDATE WaitingList SET position = position-1
    WHERE course = OLD.course;
END IF;                               
END IF;
                                                                                 
RETURN OLD;
END;
$$ LANGUAGE plpgsql;

                                                                                 
CREATE TRIGGER trigger2
INSTEAD OF DELETE 
ON Registrations
FOR EACH ROW
EXECUTE PROCEDURE unregisterStudent();
                                                                                                                                

















                                                                                                                                
                                                                                                                                
                                                                                                                                
                                                                                                                                