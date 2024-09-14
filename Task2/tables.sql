--✔ enligt schema, Officiell


CREATE TABLE Students (
  idnr CHAR(10) PRIMARY KEY,
  name TEXT NOT NULL,
  login TEXT NOT NULL,
  program TEXT NOT NULL,
  UNIQUE (login),
  UNIQUE (idnr, program)
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

CREATE TABLE Departments (
  name TEXT PRIMARY KEY,
  abbreviation TEXT UNIQUE
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




