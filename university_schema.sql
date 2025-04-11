-- Drop tables if they exist to ensure clean creation (in reverse order due to dependencies)
DROP TABLE FacultyCourseAssignments;
DROP TABLE Transcripts;
DROP TABLE CoursePrerequisites;
DROP TABLE Enrollments;
DROP TABLE CourseOfferings;
DROP TABLE Courses;
DROP TABLE Students;
DROP TABLE Faculty;
DROP TABLE Classrooms;
DROP TABLE Departments;

-- 1. Departments Table
CREATE TABLE Departments (
    DepartmentID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    DepartmentName VARCHAR2(100) NOT NULL,
    DepartmentCode VARCHAR2(10) UNIQUE NOT NULL,
    HeadFacultyID NUMBER,
    Building VARCHAR2(50),
    OfficeNumber VARCHAR2(20),
    Phone VARCHAR2(15),
    Email VARCHAR2(100),
    CreatedDate DATE DEFAULT SYSDATE,
    CONSTRAINT chk_dept_email CHECK (Email LIKE '%@%.%'),
    CONSTRAINT chk_dept_phone CHECK (REGEXP_LIKE(Phone, '^\+?[1-9][0-9]{7,14}$'))
);

-- 2. Faculty Table
CREATE TABLE Faculty (
    FacultyID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    FirstName VARCHAR2(50) NOT NULL,
    LastName VARCHAR2(50) NOT NULL,
    DepartmentID NUMBER NOT NULL,
    Email VARCHAR2(100) UNIQUE NOT NULL,
    Phone VARCHAR2(15),
    HireDate DATE NOT NULL,
    Rank VARCHAR2(50) CHECK (Rank IN ('Professor', 'Associate Professor', 'Assistant Professor', 'Lecturer')),
    OfficeLocation VARCHAR2(50),
    Status VARCHAR2(20) DEFAULT 'Active' CHECK (Status IN ('Active', 'On Leave', 'Retired')),
    CreatedDate DATE DEFAULT SYSDATE,
    CONSTRAINT fk_faculty_dept FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID),
    CONSTRAINT chk_faculty_email CHECK (Email LIKE '%@%.%')
);

-- Add foreign key for Departments.HeadFacultyID after Faculty table creation
ALTER TABLE Departments
ADD CONSTRAINT fk_dept_head FOREIGN KEY (HeadFacultyID) REFERENCES Faculty(FacultyID);

-- 3. Students Table
CREATE TABLE Students (
    StudentID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    FirstName VARCHAR2(50) NOT NULL,
    LastName VARCHAR2(50) NOT NULL,
    Email VARCHAR2(100) UNIQUE NOT NULL,
    Phone VARCHAR2(15),
    DateOfBirth DATE,
    AdmissionDate DATE NOT NULL,
    DepartmentID NUMBER NOT NULL,
    Program VARCHAR2(100) NOT NULL,
    Status VARCHAR2(20) DEFAULT 'Active' CHECK (Status IN ('Active', 'Graduated', 'Suspended', 'Dropped')),
    CreatedDate DATE DEFAULT SYSDATE,
    CONSTRAINT fk_student_dept FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID),
    CONSTRAINT chk_student_email CHECK (Email LIKE '%@%.%'),
    CONSTRAINT chk_student_dob CHECK (DateOfBirth < AdmissionDate)
);

-- 4. Courses Table
CREATE TABLE Courses (
    CourseID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    CourseCode VARCHAR2(10) UNIQUE NOT NULL,
    CourseName VARCHAR2(100) NOT NULL,
    DepartmentID NUMBER NOT NULL,
    Credits NUMBER(2) NOT NULL CHECK (Credits BETWEEN 1 AND 6),
    Level VARCHAR2(20) CHECK (Level IN ('Undergraduate', 'Graduate', 'Doctoral')),
    Description VARCHAR2(500),
    Prerequisites VARCHAR2(200),
    MaxEnrollment NUMBER(4) DEFAULT 100 CHECK (MaxEnrollment > 0),
    CreatedDate DATE DEFAULT SYSDATE,
    CONSTRAINT fk_course_dept FOREIGN KEY (DepartmentID) REFERENCES Departments(DepartmentID),
    CONSTRAINT chk_course_code CHECK (REGEXP_LIKE(CourseCode, '^[A-Z]{3}[0-9]{3}$'))
);

-- 5. Classrooms Table
CREATE TABLE Classrooms (
    ClassroomID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Building VARCHAR2(50) NOT NULL,
    RoomNumber VARCHAR2(20) NOT NULL,
    Capacity NUMBER(4) NOT NULL CHECK (Capacity > 0),
    Facilities VARCHAR2(200),
    CreatedDate DATE DEFAULT SYSDATE,
    CONSTRAINT uk_classroom UNIQUE (Building, RoomNumber)
);

-- 6. Course Offerings Table
CREATE TABLE CourseOfferings (
    OfferingID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    CourseID NUMBER NOT NULL,
    FacultyID NUMBER NOT NULL,
    Semester VARCHAR2(20) NOT NULL CHECK (Semester IN ('Fall', 'Spring', 'Summer')),
    AcademicYear NUMBER(4) NOT NULL,
    Schedule VARCHAR2(100),
    ClassroomID NUMBER,
    CurrentEnrollment NUMBER DEFAULT 0,
    Status VARCHAR2(20) DEFAULT 'Open' CHECK (Status IN ('Open', 'Closed', 'Cancelled')),
    CreatedDate DATE DEFAULT SYSDATE,
    CONSTRAINT fk_offering_course FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    CONSTRAINT fk_offering_faculty FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID),
    CONSTRAINT fk_offering_classroom FOREIGN KEY (ClassroomID) REFERENCES Classrooms(ClassroomID),
    CONSTRAINT uk_offering UNIQUE (CourseID, Semester, AcademicYear)
);

-- 7. Enrollments Table
CREATE TABLE Enrollments (
    EnrollmentID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    StudentID NUMBER NOT NULL,
    OfferingID NUMBER NOT NULL,
    EnrollmentDate DATE DEFAULT SYSDATE,
    Grade VARCHAR2(2) CHECK (Grade IN ('A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'F', NULL)),
    Status VARCHAR2(20) DEFAULT 'Enrolled' CHECK (Status IN ('Enrolled', 'Completed', 'Dropped', 'Withdrawn')),
    CreatedDate DATE DEFAULT SYSDATE,
    CONSTRAINT fk_enroll_student FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    CONSTRAINT fk_enroll_offering FOREIGN KEY (OfferingID) REFERENCES CourseOfferings(OfferingID),
    CONSTRAINT uk_enrollment UNIQUE (StudentID, OfferingID)
);

-- 8. Course Prerequisites Table
CREATE TABLE CoursePrerequisites (
    PrerequisiteID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    CourseID NUMBER NOT NULL,
    PrerequisiteCourseID NUMBER NOT NULL,
    CreatedDate DATE DEFAULT SYSDATE,
    CONSTRAINT fk_prereq_course FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    CONSTRAINT fk_prereq_prereq FOREIGN KEY (PrerequisiteCourseID) REFERENCES Courses(CourseID),
    CONSTRAINT uk_prerequisite UNIQUE (CourseID, PrerequisiteCourseID),
    CONSTRAINT chk_no_self_prereq CHECK (CourseID != PrerequisiteCourseID)
);

-- 9. Transcripts Table
CREATE TABLE Transcripts (
    TranscriptID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    StudentID NUMBER NOT NULL,
    CourseID NUMBER NOT NULL,
    Semester VARCHAR2(20) NOT NULL,
    AcademicYear NUMBER(4) NOT NULL,
    Grade VARCHAR2(2) CHECK (Grade IN ('A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'F')),
    CreditsEarned NUMBER(2) NOT NULL,
    CreatedDate DATE DEFAULT SYSDATE,
    CONSTRAINT fk_transcript_student FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    CONSTRAINT fk_transcript_course FOREIGN KEY (CourseID) REFERENCES Courses(CourseID)
);

-- 10. Faculty Course Assignments Table
CREATE TABLE FacultyCourseAssignments (
    AssignmentID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    FacultyID NUMBER NOT NULL,
    CourseID NUMBER NOT NULL,
    CreatedDate DATE DEFAULT SYSDATE,
    CONSTRAINT fk_assign_faculty FOREIGN KEY (FacultyID) REFERENCES Faculty(FacultyID),
    CONSTRAINT fk_assign_course FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    CONSTRAINT uk_assignment UNIQUE (FacultyID, CourseID)
);

-- Create Indexes for Performance
CREATE INDEX idx_student_email ON Students(Email);
CREATE INDEX idx_faculty_email ON Faculty(Email);
CREATE INDEX idx_course_code ON Courses(CourseCode);
CREATE INDEX idx_enroll_student_offering ON Enrollments(StudentID, OfferingID);
CREATE INDEX idx_offering_course_semester ON CourseOfferings(CourseID, Semester, AcademicYear);

-- Commit the changes
COMMIT;
