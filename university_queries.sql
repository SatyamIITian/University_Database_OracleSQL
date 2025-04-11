-- Query 1
SELECT DepartmentName, COUNT(HeadFacultyID) AS HeadCount
FROM Departments
GROUP BY DepartmentName
HAVING COUNT(HeadFacultyID) > 1;

-- Query 2
SELECT s.FirstName || ' ' || s.LastName AS StudentName, d.DepartmentName, c.CourseCode, co.Semester, co.AcademicYear
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN CourseOfferings co ON e.OfferingID = co.OfferingID
JOIN Courses c ON co.CourseID = c.CourseID
JOIN Departments d ON s.DepartmentID = d.DepartmentID
WHERE co.Semester = 'Fall' AND co.AcademicYear = 2024
ORDER BY StudentName;

-- Query 3
SELECT d.DepartmentName, COUNT(e.EnrollmentID) AS TotalEnrollments
FROM Departments d
JOIN Courses c ON d.DepartmentID = c.DepartmentID
JOIN CourseOfferings co ON c.CourseID = co.CourseID
JOIN Enrollments e ON co.OfferingID = e.OfferingID
WHERE co.Semester = 'Spring' AND co.AcademicYear = 2025
GROUP BY d.DepartmentName
ORDER BY TotalEnrollments DESC;

-- Query 4
SELECT f.FirstName || ' ' || f.LastName AS FacultyName, COUNT(co.OfferingID) AS CourseCount
FROM Faculty f
JOIN CourseOfferings co ON f.FacultyID = co.FacultyID
WHERE co.Semester = 'Fall' AND co.AcademicYear = 2024
GROUP BY f.FacultyID, f.FirstName, f.LastName
HAVING COUNT(co.OfferingID) > 1
ORDER BY CourseCount DESC;

-- Query 5
WITH GradePoints AS (
    SELECT t.StudentID, s.FirstName || ' ' || s.LastName AS StudentName, AVG(CASE t.Grade
        WHEN 'A+' THEN 4.0 WHEN 'A' THEN 4.0 WHEN 'A-' THEN 3.7 WHEN 'B+' THEN 3.3 WHEN 'B' THEN 3.0 WHEN 'B-' THEN 2.7
        WHEN 'C+' THEN 2.3 WHEN 'C' THEN 2.0 WHEN 'C-' THEN 1.7 WHEN 'D+' THEN 1.3 WHEN 'D' THEN 1.0 WHEN 'F' THEN 0.0
    END) AS GPA
    FROM Transcripts t
    JOIN Students s ON t.StudentID = s.StudentID
    GROUP BY t.StudentID, s.FirstName, s.LastName
)
SELECT StudentName, ROUND(GPA, 2) AS GPA
FROM GradePoints
WHERE GPA > 3.5
ORDER BY GPA DESC;

-- Query 6
SELECT c.CourseCode, c.CourseName, co.Semester, co.AcademicYear, co.CurrentEnrollment
FROM Courses c
JOIN CourseOfferings co ON c.CourseID = co.CourseID
WHERE co.CurrentEnrollment > 30
ORDER BY co.CurrentEnrollment DESC;

-- Query 7
SELECT cl.Building, cl.RoomNumber, COUNT(co.OfferingID) AS OfferingCount
FROM Classrooms cl
JOIN CourseOfferings co ON cl.ClassroomID = co.ClassroomID
WHERE co.Semester = 'Spring' AND co.AcademicYear = 2025
GROUP BY cl.Building, cl.RoomNumber
HAVING COUNT(co.OfferingID) > 1
ORDER BY OfferingCount DESC;

-- Query 8
SELECT f.FirstName || ' ' || f.LastName AS FacultyName, d.DepartmentName
FROM Faculty f
JOIN Departments d ON f.DepartmentID = d.DepartmentID
LEFT JOIN CourseOfferings co ON f.FacultyID = co.FacultyID AND co.Semester = 'Fall' AND co.AcademicYear = 2024
WHERE co.OfferingID IS NULL
ORDER BY FacultyName;

-- Query 9
SELECT s.FirstName || ' ' || s.LastName AS StudentName, COUNT(DISTINCT d.DepartmentID) AS DepartmentCount
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN CourseOfferings co ON e.OfferingID = co.OfferingID
JOIN Courses c ON co.CourseID = c.CourseID
JOIN Departments d ON c.DepartmentID = d.DepartmentID
WHERE co.Semester = 'Spring' AND co.AcademicYear = 2025
GROUP BY s.StudentID, s.FirstName, s.LastName
HAVING COUNT(DISTINCT d.DepartmentID) > 1
ORDER BY DepartmentCount DESC;

-- Query 10
SELECT c.CourseCode, c.CourseName, cp.PrerequisiteCourseID
FROM Courses c
JOIN CoursePrerequisites cp ON c.CourseID = cp.CourseID
LEFT JOIN CourseOfferings co ON cp.PrerequisiteCourseID = co.CourseID AND co.Semester = 'Spring' AND co.AcademicYear = 2025
WHERE co.OfferingID IS NULL
ORDER BY c.CourseCode;

-- Query 11
SELECT d.DepartmentName, SUM(c.Credits) AS TotalCredits
FROM Departments d
JOIN Courses c ON d.DepartmentID = c.DepartmentID
JOIN CourseOfferings co ON c.CourseID = co.CourseID
WHERE co.Semester = 'Fall' AND co.AcademicYear = 2024
GROUP BY d.DepartmentName
ORDER BY TotalCredits DESC
FETCH FIRST 5 ROWS ONLY;

-- Query 12
SELECT s.FirstName || ' ' || s.LastName AS StudentName
FROM Students s
WHERE NOT EXISTS (
    SELECT cp.PrerequisiteCourseID
    FROM CoursePrerequisites cp
    WHERE cp.CourseID = (SELECT CourseID FROM Courses WHERE CourseCode = 'CSC301')
    MINUS
    SELECT t.CourseID
    FROM Transcripts t
    WHERE t.StudentID = s.StudentID AND t.Grade != 'F'
)
ORDER BY StudentName;

-- Query 13
SELECT f.FirstName || ' ' || f.LastName AS FacultyName, c.CourseCode, c.CourseName
FROM Faculty f
JOIN CourseOfferings co1 ON f.FacultyID = co1.FacultyID
JOIN Courses c ON co1.CourseID = c.CourseID
JOIN CourseOfferings co2 ON co2.CourseID = c.CourseID AND co2.FacultyID = f.FacultyID
WHERE co1.Semester = 'Fall' AND co1.AcademicYear = 2024 AND co2.Semester = 'Spring' AND co2.AcademicYear = 2025
ORDER BY FacultyName, c.CourseCode;

-- Query 14
SELECT d.DepartmentName, ROUND(AVG(co.CurrentEnrollment), 2) AS AvgEnrollment
FROM Departments d
JOIN Courses c ON d.DepartmentID = c.DepartmentID
JOIN CourseOfferings co ON c.CourseID = co.CourseID
WHERE co.Semester = 'Fall' AND co.AcademicYear = 2024
GROUP BY d.DepartmentName
ORDER BY AvgEnrollment DESC;

-- Query 15
SELECT DISTINCT s.FirstName || ' ' || s.LastName AS StudentName, c.CourseCode, cl.Capacity
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN CourseOfferings co ON e.OfferingID = co.OfferingID
JOIN Courses c ON co.CourseID = c.CourseID
JOIN Classrooms cl ON co.ClassroomID = cl.ClassroomID
WHERE co.Semester = 'Spring' AND co.AcademicYear = 2025 AND cl.Capacity > 50
ORDER BY StudentName;

-- Query 16
SELECT c.CourseCode, c.CourseName, co.Semester, co.AcademicYear
FROM Courses c
JOIN CourseOfferings co ON c.CourseID = co.CourseID
LEFT JOIN Enrollments e ON co.OfferingID = e.OfferingID
WHERE co.Semester = 'Spring' AND co.AcademicYear = 2025 AND e.EnrollmentID IS NULL
ORDER BY c.CourseCode;

-- Query 17
SELECT f.FirstName || ' ' || f.LastName AS FacultyName, COUNT(fca.AssignmentID) AS AssignmentCount
FROM Faculty f
JOIN FacultyCourseAssignments fca ON f.FacultyID = fca.FacultyID
GROUP BY f.FacultyID, f.FirstName, f.LastName
ORDER BY AssignmentCount DESC
FETCH FIRST 1 ROWS ONLY;

-- Query 18
SELECT d.DepartmentName
FROM Departments d
WHERE NOT EXISTS (
    SELECT c.CourseID
    FROM Courses c
    WHERE c.DepartmentID = d.DepartmentID
    MINUS
    SELECT co.CourseID
    FROM CourseOfferings co
    WHERE co.Semester = 'Fall' AND co.AcademicYear = 2024
)
ORDER BY d.DepartmentName;

-- Query 19
SELECT s.FirstName || ' ' || s.LastName AS StudentName, SUM(t.CreditsEarned) AS TotalCredits
FROM Students s
JOIN Transcripts t ON s.StudentID = t.StudentID
WHERE t.Semester = 'Spring' AND t.AcademicYear = 2024
GROUP BY s.StudentID, s.FirstName, s.LastName
HAVING SUM(t.CreditsEarned) > 10
ORDER BY TotalCredits DESC;

-- Query 20
SELECT cl.Building, cl.RoomNumber, cl.Capacity, co.CurrentEnrollment, c.CourseCode, co.Semester, co.AcademicYear
FROM Classrooms cl
JOIN CourseOfferings co ON cl.ClassroomID = co.ClassroomID
JOIN Courses c ON co.CourseID = c.CourseID
WHERE co.Semester = 'Fall' AND co.AcademicYear = 2024 AND co.CurrentEnrollment > cl.Capacity
ORDER BY cl.Building, cl.RoomNumber;

-- Query 21
SELECT DISTINCT f.FirstName || ' ' || f.LastName AS FacultyName, c.CourseCode, c.CourseName
FROM Faculty f
JOIN CourseOfferings co ON f.FacultyID = co.FacultyID
JOIN Courses c ON co.CourseID = c.CourseID
JOIN CoursePrerequisites cp ON c.CourseID = cp.CourseID
WHERE co.Semester = 'Spring' AND co.AcademicYear = 2025
ORDER BY FacultyName, c.CourseCode;

-- Query 22
SELECT c.CourseCode, c.CourseName, ROUND(AVG(CASE t.Grade
    WHEN 'A+' THEN 4.0 WHEN 'A' THEN 4.0 WHEN 'A-' THEN 3.7 WHEN 'B+' THEN 3.3 WHEN 'B' THEN 3.0 WHEN 'B-' THEN 2.7
    WHEN 'C+' THEN 2.3 WHEN 'C' THEN 2.0 WHEN 'C-' THEN 1.7 WHEN 'D+' THEN 1.3 WHEN 'D' THEN 1.0 WHEN 'F' THEN 0.0
END), 2) AS AvgGrade
FROM Courses c
JOIN Transcripts t ON c.CourseID = t.CourseID
WHERE t.Semester = 'Spring' AND t.AcademicYear = 2024
GROUP BY c.CourseID, c.CourseCode, c.CourseName
ORDER BY AvgGrade DESC;

-- Query 23
SELECT s.FirstName || ' ' || s.LastName AS StudentName, d.DepartmentName, c.CourseCode, f.FirstName || ' ' || f.LastName AS FacultyName
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN CourseOfferings co ON e.OfferingID = co.OfferingID
JOIN Courses c ON co.CourseID = c.CourseID
JOIN Faculty f ON co.FacultyID = f.FacultyID
JOIN Departments d ON s.DepartmentID = d.DepartmentID
WHERE co.Semester = 'Fall' AND co.AcademicYear = 2024 AND f.FacultyID = d.HeadFacultyID
ORDER BY StudentName;

-- Query 24
SELECT c.CourseCode, c.CourseName
FROM Courses c
WHERE EXISTS (
    SELECT 1
    FROM CourseOfferings co1
    WHERE co1.CourseID = c.CourseID AND co1.Semester = 'Fall' AND co1.AcademicYear = 2024
) AND EXISTS (
    SELECT 1
    FROM CourseOfferings co2
    WHERE co2.CourseID = c.CourseID AND co2.Semester = 'Spring' AND co2.AcademicYear = 2025
)
ORDER BY c.CourseCode;

-- Query 25
SELECT s.FirstName || ' ' || s.LastName AS StudentName, d.DepartmentName
FROM Students s
JOIN Departments d ON s.DepartmentID = d.DepartmentID
LEFT JOIN Enrollments e ON s.StudentID = e.StudentID
LEFT JOIN CourseOfferings co ON e.OfferingID = co.OfferingID AND co.Semester = 'Spring' AND co.AcademicYear = 2025
WHERE co.OfferingID IS NULL
ORDER BY StudentName;

-- Query 26
SELECT DISTINCT d.DepartmentName AS FacultyDepartment, d2.DepartmentName AS CourseDepartment
FROM Faculty f
JOIN Departments d ON f.DepartmentID = d.DepartmentID
JOIN CourseOfferings co ON f.FacultyID = co.FacultyID
JOIN Courses c ON co.CourseID = c.CourseID
JOIN Departments d2 ON c.DepartmentID = d2.DepartmentID
WHERE d.DepartmentID != d2.DepartmentID
ORDER BY FacultyDepartment, CourseDepartment;

-- Query 27
SELECT d.DepartmentName, s.FirstName || ' ' || s.LastName AS StudentName, SUM(t.CreditsEarned) AS TotalCredits
FROM Students s
JOIN Departments d ON s.DepartmentID = d.DepartmentID
JOIN Transcripts t ON s.StudentID = t.StudentID
GROUP BY d.DepartmentName, s.StudentID, s.FirstName, s.LastName
ORDER BY d.DepartmentName, TotalCredits DESC;

-- Query 28
WITH RankedCourses AS (
    SELECT d.DepartmentName, c.CourseCode, c.CourseName, co.CurrentEnrollment,
           ROW_NUMBER() OVER (PARTITION BY d.DepartmentID ORDER BY co.CurrentEnrollment DESC) AS rn
    FROM Departments d
    JOIN Courses c ON d.DepartmentID = c.DepartmentID
    JOIN CourseOfferings co ON c.CourseID = co.CourseID
    WHERE co.Semester = 'Fall' AND co.AcademicYear = 2024
)
SELECT DepartmentName, CourseCode, CourseName, CurrentEnrollment
FROM RankedCourses
WHERE rn = 1
ORDER BY DepartmentName;

-- Query 29
SELECT f.FirstName || ' ' || f.LastName AS FacultyName, COUNT(DISTINCT co.Semester || co.AcademicYear) AS SemesterCount
FROM Faculty f
JOIN CourseOfferings co ON f.FacultyID = co.FacultyID
GROUP BY f.FacultyID, f.FirstName, f.LastName
HAVING COUNT(DISTINCT co.Semester || co.AcademicYear) > 1
ORDER BY SemesterCount DESC;

-- Query 30
WITH DeptAvgCredits AS (
    SELECT d.DepartmentID, AVG(SUM(t.CreditsEarned)) AS AvgCredits
    FROM Students s
    JOIN Transcripts t ON s.StudentID = t.StudentID
    JOIN Departments d ON s.DepartmentID = d.DepartmentID
    GROUP BY d.DepartmentID
)
SELECT d.DepartmentName, s.FirstName || ' ' || s.LastName AS StudentName, SUM(t.CreditsEarned) AS TotalCredits,
       ROUND(dac.AvgCredits, 2) AS DeptAvgCredits
FROM Students s
JOIN Transcripts t ON s.StudentID = t.StudentID
JOIN Departments d ON s.DepartmentID = d.DepartmentID
JOIN DeptAvgCredits dac ON d.DepartmentID = dac.DepartmentID
GROUP BY d.DepartmentID, d.DepartmentName, s.StudentID, s.FirstName, s.LastName, dac.AvgCredits
HAVING SUM(t.CreditsEarned) > dac.AvgCredits
ORDER BY d.DepartmentName, TotalCredits DESC;

-- Query 31
SELECT c.CourseCode, c.CourseName, COUNT(co.OfferingID) AS OfferingCount
FROM Courses c
JOIN CourseOfferings co ON c.CourseID = co.CourseID
GROUP BY c.CourseID, c.CourseCode, c.CourseName
HAVING COUNT(co.OfferingID) > 1
ORDER BY OfferingCount DESC;

-- Query 32
SELECT s.FirstName || ' ' || s.LastName AS StudentName, c.CourseCode, c.CourseName, t.Grade
FROM Students s
JOIN Transcripts t ON s.StudentID = t.StudentID
JOIN Courses c ON t.CourseID = c.CourseID
WHERE t.Semester = 'Spring' AND t.AcademicYear = 2024 AND t.Grade = 'F'
ORDER BY StudentName;

-- Query 33
WITH MaxCredits AS (
    SELECT DepartmentID, MAX(Credits) AS MaxCredits
    FROM Courses
    GROUP BY DepartmentID
)
SELECT d.DepartmentName, f.FirstName || ' ' || f.LastName AS FacultyName, c.CourseCode, c.CourseName, c.Credits
FROM Faculty f
JOIN CourseOfferings co ON f.FacultyID = co.FacultyID
JOIN Courses c ON co.CourseID = c.CourseID
JOIN Departments d ON c.DepartmentID = d.DepartmentID
JOIN MaxCredits mc ON c.DepartmentID = mc.DepartmentID AND c.Credits = mc.MaxCredits
ORDER BY d.DepartmentName, FacultyName;

-- Query 34
SELECT c.CourseCode, c.CourseName, co.Semester, co.AcademicYear, co.CurrentEnrollment, c.MaxEnrollment,
       ROUND((co.CurrentEnrollment / c.MaxEnrollment) * 100, 2) AS EnrollmentPercentage
FROM Courses c
JOIN CourseOfferings co ON c.CourseID = co.CourseID
WHERE co.Semester = 'Fall' AND co.AcademicYear = 2024
ORDER BY EnrollmentPercentage DESC;

-- Query 35
WITH CourseCounts AS (
    SELECT s.StudentID, s.FirstName || ' ' || s.LastName AS StudentName, d.DepartmentID, d.DepartmentName,
           COUNT(e.EnrollmentID) AS CourseCount,
           AVG(COUNT(e.EnrollmentID)) OVER (PARTITION BY d.DepartmentID) AS AvgCourseCount
    FROM Students s
    JOIN Departments d ON s.DepartmentID = d.DepartmentID
    JOIN Enrollments e ON s.StudentID = e.StudentID
    JOIN CourseOfferings co ON e.OfferingID = co.OfferingID
    WHERE co.Semester = 'Spring' AND co.AcademicYear = 2025
    GROUP BY s.StudentID, s.FirstName, s.LastName, d.DepartmentID, d.DepartmentName
)
SELECT DepartmentName, StudentName, CourseCount, ROUND(AvgCourseCount, 2) AS AvgCourseCount
FROM CourseCounts
WHERE CourseCount > AvgCourseCount
ORDER BY DepartmentName, CourseCount DESC;

-- Query 36
WITH StudentGPA AS (
    SELECT t.StudentID, AVG(CASE t.Grade
        WHEN 'A+' THEN 4.0 WHEN 'A' THEN 4.0 WHEN 'A-' THEN 3.7 WHEN 'B+' THEN 3.3 WHEN 'B' THEN 3.0 WHEN 'B-' THEN 2.7
        WHEN 'C+' THEN 2.3 WHEN 'C' THEN 2.0 WHEN 'C-' THEN 1.7 WHEN 'D+' THEN 1.3 WHEN 'D' THEN 1.0 WHEN 'F' THEN 0.0
    END) AS GPA
    FROM Transcripts t
    GROUP BY t.StudentID
)
SELECT c.CourseCode, c.CourseName, co.Semester, co.AcademicYear
FROM Courses c
JOIN CourseOfferings co ON c.CourseID = co.CourseID
WHERE NOT EXISTS (
    SELECT e.StudentID
    FROM Enrollments e
    JOIN StudentGPA sg ON e.StudentID = sg.StudentID
    WHERE e.OfferingID = co.OfferingID AND sg.GPA <= 3.0
)
ORDER BY c.CourseCode;

-- Query 37
SELECT d.DepartmentName, ROUND(AVG(COUNT(co.OfferingID)), 2) AS AvgTeachingLoad
FROM Departments d
JOIN Faculty f ON d.DepartmentID = f.DepartmentID
JOIN CourseOfferings co ON f.FacultyID = co.FacultyID
WHERE co.Semester = 'Fall' AND co.AcademicYear = 2024
GROUP BY d.DepartmentName
ORDER BY AvgTeachingLoad DESC;

-- Query 38
SELECT s.FirstName || ' ' || s.LastName AS StudentName, c1.CourseCode AS Course1, c2.CourseCode AS Course2
FROM Students s
JOIN Enrollments e1 ON s.StudentID = e1.StudentID
JOIN CourseOfferings co1 ON e1.OfferingID = co1.OfferingID
JOIN Courses c1 ON co1.CourseID = c1.CourseID
JOIN CoursePrerequisites cp ON cp.CourseID = c1.CourseID
JOIN Courses c2 ON cp.PrerequisiteCourseID = c2.CourseID
JOIN Enrollments e2 ON s.StudentID = e2.StudentID
JOIN CourseOfferings co2 ON e2.OfferingID = co2.OfferingID AND co2.CourseID = c2.CourseID
ORDER BY StudentName, c1.CourseCode;

-- Query 39
SELECT cl.Building, cl.RoomNumber, d.DepartmentName
FROM Classrooms cl
JOIN CourseOfferings co ON cl.ClassroomID = co.ClassroomID
JOIN Courses c ON co.CourseID = c.CourseID
JOIN Departments d ON c.DepartmentID = d.DepartmentID
WHERE co.Semester = 'Fall' AND co.AcademicYear = 2024
GROUP BY cl.ClassroomID, cl.Building, cl.RoomNumber, d.DepartmentName
HAVING COUNT(DISTINCT c.DepartmentID) = 1
ORDER BY cl.Building, cl.RoomNumber;

-- Query 40
WITH RankedCourses AS (
    SELECT c.CourseCode, c.CourseName, co.Semester, co.AcademicYear, co.CurrentEnrollment,
           ROW_NUMBER() OVER (PARTITION BY co.Semester, co.AcademicYear ORDER BY co.CurrentEnrollment DESC) AS rn
    FROM Courses c
    JOIN CourseOfferings co ON c.CourseID = co.CourseID
)
SELECT CourseCode, CourseName, Semester, AcademicYear, CurrentEnrollment
FROM RankedCourses
WHERE rn = 1
ORDER BY Semester, AcademicYear;

-- Query 41
SELECT f.FirstName || ' ' || f.LastName AS FacultyName, ROUND(AVG(co.CurrentEnrollment), 2) AS AvgEnrollment
FROM Faculty f
JOIN CourseOfferings co ON f.FacultyID = co.FacultyID
WHERE co.Semester = 'Fall' AND co.AcademicYear = 2024
GROUP BY f.FacultyID, f.FirstName, f.LastName
ORDER BY AvgEnrollment DESC;

-- Query 42
SELECT s.FirstName || ' ' || s.LastName AS StudentName
FROM Students s
WHERE NOT EXISTS (
    SELECT d.DepartmentID
    FROM Departments d
    JOIN Courses c ON d.DepartmentID = c.DepartmentID
    JOIN CourseOfferings co ON c.CourseID = co.CourseID
    WHERE co.Semester = 'Fall' AND co.AcademicYear = 2024
    MINUS
    SELECT d2.DepartmentID
    FROM Enrollments e
    JOIN CourseOfferings co2 ON e.OfferingID = co2.OfferingID
    JOIN Courses c2 ON co2.CourseID = c2.CourseID
    JOIN Departments d2 ON c2.DepartmentID = d2.DepartmentID
    WHERE e.StudentID = s.StudentID AND co2.Semester = 'Fall' AND co2.AcademicYear = 2024
)
ORDER BY StudentName;

-- Query 43
SELECT c.CourseCode, c.CourseName, co.Semester, co.AcademicYear
FROM Courses c
JOIN CourseOfferings co ON c.CourseID = co.CourseID
LEFT JOIN CoursePrerequisites cp ON c.CourseID = cp.CourseID
WHERE co.Semester = 'Spring' AND co.AcademicYear = 2025 AND cp.PrerequisiteID IS NULL
ORDER BY c.CourseCode;

-- Query 44
SELECT d.DepartmentName, COUNT(DISTINCT co.CourseID) AS UniqueCourses
FROM Departments d
JOIN Courses c ON d.DepartmentID = c.DepartmentID
JOIN CourseOfferings co ON c.CourseID = co.CourseID
WHERE co.Semester = 'Fall' AND co.AcademicYear = 2024
GROUP BY d.DepartmentName
ORDER BY UniqueCourses DESC
FETCH FIRST 1 ROWS ONLY;

-- Query 45
SELECT s.FirstName || ' ' || s.LastName AS StudentName, f.FirstName || ' ' || f.LastName AS FacultyName,
       COUNT(DISTINCT co.Semester || co.AcademicYear) AS SemesterCount
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN CourseOfferings co ON e.OfferingID = co.OfferingID
JOIN Faculty f ON co.FacultyID = f.FacultyID
GROUP BY s.StudentID, s.FirstName, s.LastName, f.FacultyID, f.FirstName, f.LastName
HAVING COUNT(DISTINCT co.Semester || co.AcademicYear) > 1
ORDER BY StudentName, FacultyName;

-- Query 46
SELECT c.CourseCode, c.CourseName, co.CurrentEnrollment, cl.Capacity,
       ROUND((co.CurrentEnrollment / cl.Capacity) * 100, 2) AS CapacityPercentage
FROM Courses c
JOIN CourseOfferings co ON c.CourseID = co.CourseID
JOIN Classrooms cl ON co.ClassroomID = cl.ClassroomID
WHERE co.Semester = 'Fall' AND co.AcademicYear = 2024 AND co.CurrentEnrollment < (cl.Capacity * 0.5)
ORDER BY CapacityPercentage;

-- Query 47
SELECT f.FirstName || ' ' || f.LastName AS FacultyName, d.DepartmentName
FROM Faculty f
JOIN Departments d ON f.DepartmentID = d.DepartmentID
WHERE NOT EXISTS (
    SELECT 1
    FROM CourseOfferings co
    JOIN Courses c ON co.CourseID = c.CourseID
    JOIN CoursePrerequisites cp ON c.CourseID = cp.CourseID
    WHERE co.FacultyID = f.FacultyID
)
ORDER BY FacultyName;

-- Query 48
SELECT d.DepartmentName, ROUND(AVG(SUM(t.CreditsEarned)), 2) AS AvgCreditsPerStudent
FROM Departments d
JOIN Students s ON d.DepartmentID = s.DepartmentID
JOIN Transcripts t ON s.StudentID = t.StudentID
GROUP BY d.DepartmentName
ORDER BY AvgCreditsPerStudent DESC;

-- Query 49
SELECT c.CourseCode, c.CourseName, co1.CurrentEnrollment AS Fall2024Enrollment, co2.CurrentEnrollment AS Spring2025Enrollment
FROM Courses c
JOIN CourseOfferings co1 ON c.CourseID = co1.CourseID
JOIN CourseOfferings co2 ON c.CourseID = co2.CourseID
WHERE co1.Semester = 'Fall' AND co1.AcademicYear = 2024 AND co2.Semester = 'Spring' AND co2.AcademicYear = 2025
  AND co2.CurrentEnrollment > co1.CurrentEnrollment
ORDER BY c.CourseCode;

-- Query 50
SELECT s.FirstName || ' ' || s.LastName AS StudentName, co.Schedule, COUNT(co.OfferingID) AS CourseCount,
       LISTAGG(c.CourseCode, ', ') WITHIN GROUP (ORDER BY c.CourseCode) AS Courses
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN CourseOfferings co ON e.OfferingID = co.OfferingID
JOIN Courses c ON co.CourseID = c.CourseID
WHERE co.Semester = 'Spring' AND co.AcademicYear = 2025
GROUP BY s.StudentID, s.FirstName, s.LastName, co.Schedule
HAVING COUNT(co.OfferingID) > 1
ORDER BY StudentName, co.Schedule;
