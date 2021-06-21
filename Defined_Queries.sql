
-- 2. <A student> list all instructors who has an average review rating higher than 3.8
SELECT CONCAT(i.first_name, ' ', i.last_name) as 'Instructor Name', AVG(rating)
FROM (
		SELECT * 
		FROM course 
	) as c, 
	(
		SELECT enrolled.course_id as 'course_id', AVG(enrolled.feedback_rating) as 'rating'
        FROM enrolled
		GROUP BY enrolled.course_id
		HAVING AVG(enrolled.feedback_rating) > 3.8    
    ) as r,
    instructor as i
WHERE c.id = r.course_id AND i.id = c.instructor_id
GROUP BY c.instructor_id
ORDER BY AVG(rating) DESC;


-- 5. <A student> finds courses that release/update in the year 2020
SELECT * FROM course 
WHERE YEAR(course.release_date) = '2020' OR YEAR(course.update_date) = '2020';


-- 8. <A student> list all the courses in <Web Development> that offer a certificate on completion and have a  price less than $100
-- no longer has certificate function
SELECT *
FROM course
WHERE course.name LIKE '%Web Development%' AND REPLACE(course.course_fee,'$','') < 100;


-- 11. <A student> list all the top rated paid courses  <Data>
SELECT course.name as 'Course Name', course.course_fee as 'Course Fee', AVG(enrolled.feedback_rating) as 'Rating'
FROM course
LEFT JOIN enrolled ON course.id = enrolled.course_id
WHERE course.name LIKE '%Data%' AND course.course_fee IS NOT NULL
GROUP BY course.id
HAVING AVG(enrolled.feedback_rating) > 3.8;


-- 14. <A student> list all courses related to <Data> that not consist of any assignments
SELECT DISTINCT course.name, course.language, course.course_fee, course.release_date, course.update_date
FROM chapter
LEFT JOIN has_material ON chapter.id = has_material.chapter_id
LEFT JOIN material ON has_material.material_id = material.id
LEFT JOIN course ON chapter.course_id = course.id
WHERE material.type != 'Assignment' AND chapter.course_id IN  ( SELECT id FROM course WHERE course.name LIKE '%Data%' );


-- 17. <Dr.Chutiporn Anutariya> list all students who enrolled <Data Analytics>
SELECT student.id, 
	CONCAT(student.first_name, ' ' , CASE WHEN  student.last_name IS NOT NULL THEN  student.last_name ELSE '' END) as 'Student Name'
FROM student
INNER JOIN enrolled ON enrolled.student_id = student.id
WHERE enrolled.course_id = ( SELECT id FROM course WHERE course.name = 'Data Analytics' );

-- 20. <Instructor Andrew Ng> list all topics in <Course Name> that not contain a video
-- one topic may contain others materials, if just want chapter name use SELECT DISTINCT course.name
-- if want to see all possible SELECT *
SELECT DISTINCT chapter.section as 'Section', chapter.name as 'Chapter'
FROM chapter
LEFT JOIN has_material ON chapter.id = has_material.chapter_id
LEFT JOIN material ON has_material.material_id = material.id
WHERE material.type != 'Video' AND chapter.course_id =  ( SELECT course.id FROM course WHERE course.name = 'Machine Learning' )
ORDER BY chapter.section;

-- Reports
-- [3] The admin wants to know the most popular instructors so as to maintain the popularity of platform by offering various perks to the instructor.
SELECT CONCAT(instructor.first_name, ' ', instructor.last_name) as 'Instructor Name', AVG(enrolled.feedback_rating) as 'AVG Rating'
FROM enrolled
LEFT JOIN course ON enrolled.course_id = course.id
LEFT JOIN instructor ON course.instructor_id = instructor.id
GROUP BY enrolled.course_id
ORDER BY AVG(enrolled.feedback_rating) DESC;


-- [6] Admin might want to know which language do learners most prefer to learn in.
SELECT course.language as 'Language used in Courses', COUNT(course.language) as 'Number of Students'
FROM enrolled
LEFT JOIN course ON enrolled.course_id = course.id
GROUP BY course.language
ORDER BY COUNT(course.language) DESC;

SELECT course.language, COUNT(course.language) as 'Number of Courses'
FROM course
GROUP BY course.language;


-- [ 9 ] Admin wants to suggest courses to a new student
SELECT 	student.id as 'Student ID', 
		CONCAT(student.first_name, ' ', CASE WHEN  student.last_name IS NOT NULL THEN  student.last_name ELSE '' END) as 'Student Name', 
        career_path.name as 'Interested In', 
        course.name as 'Suggest Course'
FROM student
RIGHT JOIN interested_in ON student.id = interested_in.student_id
INNER JOIN career_path ON interested_in.career_path_id = career_path.id
INNER JOIN related_to ON related_to.career_path_id = career_path.id
INNER JOIN course ON related_to.course_id = course.id;

--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
-- Operations
-- [2] When a new user registers (case Instructor)
INSERT INTO instructors (first_name, last_name, email, registration_date, username, password, brief_introduction, qualification) 
VALUES (‘Andrew’, ‘Ng’, 'ang@stanford.com', CURDATE(),'ang0123', 'ang2543vd', 'currently at stanford','PhD');

UPDATE instructor
SET qualification = 'PhD'
WHERE instructor.id = 21;

DELETE FROM instructor 
WHERE instructor.id = 21;

-- [5] When a new course gets added to a career_path
INSERT into related_to(career_path_id, course_id) values(28,15);

-- Inquiries
-- [3] A student views all the chapters from Python course.
SELECT co.name as Course, ch.name as Chapter 
FROM Chapter ch 
INNER JOIN Course co ON ch.course_id = co.id AND co.name = "Python" ;

-- [6] Find the courses taught by Instructor Bobbie.
SELECT co.name AS CourseName, Concat(i.first_name, ' ' ,i.last_name) AS InstructorName FROM Course co 
INNER JOIN Instructor i ON i.id = co.instructor_id AND first_name = "Bobbie";

-- [9] Select courses that have feedback rating less than the average rating.
SELECT course.id, course.name as 'Course', AVG(enrolled.feedback_rating) as 'Rating'
FROM enrolled
LEFT JOIN course ON course.id = enrolled.course_id
GROUP BY enrolled.course_id
HAVING AVG(enrolled.feedback_rating) < (SELECT AVG(enrolled.feedback_rating) FROM enrolled);

-- [12] List all free courses
Select c.name as CourseName, c.course_fee as Price from course c where replace(c.course_fee, '$','' )= 0;

-- [15] Find the material for the Agile Development Course that is mandatory and has max_points above 40
SELECT c.name AS Course, ch.name AS Chapter, m.name AS MaterialName, m.max_points AS Marks 
FROM material m, course c, chapter ch, has_material h
WHERE c.id = ch.course_id AND ch.id = h.chapter_id AND m.id = h.material_id
AND c.name = 'Agile Project Development' and m.mandatory = 'True' AND m.max_points>40 ORDER BY MARKS;

-- Reports
-- [1] The admin wants to know the courses that the students registered for the most, so as to improve the courses
SELECT COUNT(e.student_id) AS NumberOfStudents, c.name AS CourseName, CONCAT(i.first_name, ' ', i.last_name) AS InstructorName 
FROM student s, enrolled e, course c, instructor i
WHERE s.id = e.student_id 
AND i.id = c.instructor_id 
AND c.id = e.course_id 
GROUP BY c.name 
ORDER BY NumberOfStudents DESC LIMIT 5;

-- [3] The admin wants to know the most popular instructors so as to maintain the popularity of platform by offering various perks to the instructor
SELECT CONCAT(i.first_name, ' ', i.last_name) AS InstructorName, c.name AS Course, AVG(e.feedback_rating) AS AVGRating
FROM enrolled e LEFT JOIN course c ON e.course_id = c.id
LEFT JOIN instructor i ON c.instructor_id = i.id
GROUP BY e.course_id ORDER BY(e.feedback_rating) DESC;

-- [4] Students from which country are using the platform the most
SELECT s.location AS Country, COUNT(e.student_id) AS NumberOfStudents 
FROM student s, enrolled e, course c 
WHERE s.id = e.student_id AND c.id = e.course_id GROUP BY s.location ORDER BY NumberOfStudents DESC LIMIT 3;

-- [7] Which course has the highest number of completed students
SELECT c.name AS Course, COUNT(e.student_id) AS CompletedStudents 
FROM student s, enrolled e, course c 
WHERE s.id = e.student_id AND c.id = e.course_id AND status="completed" GROUP BY c.name ORDER BY CompletedStudents DESC LIMIT 3;

-- [11] Recommend some courses for the career path Data Scientist
SELECT c.name AS Course , cp.careerpath_name AS Careerpath 
FROM (related_to r INNER JOIN career_path cp ON r.careerpath_id = cp.id)
INNER JOIN course c ON r.course_id = c.id WHERE cp.careerpath_name = "Data Scientist" ;



--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--- INQURIES
-- 21.To know the total count of feedback rating from the students who completed their course 
select count(feedback_rating) from enrolled 
where status = 'pass';
-- 22.List the course fee according to the highest rate
select * from course 
order by course_fee desc;
-- 23.Give the details of student using with instructor id
select a.id,a.first_name,a.location,b.first_name,b.email 
from student as a 
inner join instructor as b on a.id=b.id;
-- 24.List the same qualification instructors who teaches more than 2courses for students
select a.id,a.first_name,a.email,a.qualification from instructor as a 
group by a.qualification having count(a.id)>2;
-- 25.List the details of instructor who teaches more than two courses with same qualification
select a.first_name,b.email from instructor a, instructor b 
where a.qualification = b.qualification;
-- 26.List the names of courses whose name start or end with %h
select * from course where name like '_h%';
-- 27.List the courses which started in april-2018
select * from course where year(release_date) = 2018 and month (release_date) = 4;
-- 28.List out the course details according to the student and instructor id
select c.id,c.name,c.course_fee,c.language from course as c 
inner join student as s on s.id = c.id 
inner join instructor as i on i.id = c.id;
-- 29.Find out the minimum course fee with the release date by the student id
select c.id,c.name,min(c.course_fee) from course as c 
join student as s on c.id= s.id 
group by c.release_date;
-- 30.Find the average feedback rating of the enrolled students
select e.student_id, avg(e.feedback_rating) from enrolled as e 
left join student as s on e.student_id = s.id 
group by e.student_id;


--------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------
--- OPERATIONS

--- 3. Creating a new course/updating a course
insert into course(name, description, course_fee, language, release_date, update_date, instructor_id)
values ("Bayesian Statistics", "An introduction to a system for describing epistemological uncertainty using the mathematical language of probability.", "$70", "English", CURDATE(), null, 8);

update course
set update_date = curdate(), instructor_id = 1
where course.id = 3;

delete from course where course.id = 51;

--- 5. Enrolling into a course and giving feedback to a course
insert into enrolled(student_id, course_id, enrollment_date, status, feedback_rating, feedback_comment)
values (1,  4, CURDATE() , "in_progress", null, null);

update enrolled 
set feedback_rating = 5
where enrolled.student_id = 1 and course_id = 4;

delete from enrolled where student_id = 1 and course_id = 4;

--- INQUIRIES

--- 1. Listing all courses available on the platform
SELECT name FROM course;

--- 4. Finding courses that are less than $30
SELECT name, course_fee
FROM course
WHERE replace(course_fee, "$", "") <= 30;

--- 7. Listing the top 3 courses by <instructor Jaymie Rosenvasser>
SELECT course.name, course.id, avg(enrolled.feedback_rating)
FROM enrolled
INNER JOIN course ON course.id = enrolled.course_id 
WHERE course.instructor_id = (SELECT id FROM instructor WHERE first_name = "Jaymie" AND last_name = "Rosenvasser")
	GROUP BY course_id
	ORDER BY avg(feedback_rating) DESC
LIMIT 3;

--- 10. Listing all courses in which the number of students enrolled is greater than 20.
SELECT course.name, course.description, COUNT(*) AS number FROM course
RIGHT JOIN enrolled ON course.id = enrolled.course_id
GROUP BY enrolled.course_id
HAVING number > 20
ORDER BY number DESC;

--- 13. Listing all feedback comments which have rating score greater than 3 on the <Django> course by <Lyssa Gorioli>
SELECT feedback_comment AS comment, feedback_rating AS rating 
FROM enrolled 
WHERE course_id IN (SELECT course.id FROM course LEFT JOIN instructor ON course.instructor_id = instructor.id WHERE course.name = "Django" AND instructor.first_name = "Lyssa" AND instructor.last_name = "Gorioli")
AND feedback_rating > 3;

--- 16. Listing all Japaneses courses for <career_path Data Scientist>
SELECT career_path.name as "Career Path", course.name AS "Course Name", course.description AS "Course Description", course.course_fee AS "Course Fee" 
FROM related_to
LEFT JOIN career_path ON related_to.career_path_id = career_path.id
LEFT JOIN course ON course.id = related_to.course_id
WHERE career_path.name = "Data Scientist" AND course.language = "Japanese";

--- 18.  Listing all students who has learning_progress > 2% on a particular course.
select student_id, sum(case when status = "submitted" then 1 end)/(select count(*) from has_material left join material on material.id = has_material.material_id left join chapter on has_material.chapter_id = chapter.id where course_id = 2)*100 as learning_progress 
from assigned 
where material_id in (select material_id from has_material left join material on material.id = has_material.material_id left join chapter on has_material.chapter_id = chapter.id where course_id = 1) group by student_id having learning_progress > 2 ;

--- 19.Listing all the mandatory Materials in a Course
select chapter.name as "Chapter name", chapter.description as "Chapter description", material.name as "Material name" 
from has_material 
left join chapter on has_material.chapter_id = chapter.id 
left join material on has_material.material_id = material.id 
where chapter.course_id = 4 and mandatory = 'True' 
group by material_id 
order by material_id desc;

--- REPORTS

--- 2. The admin can get the insights about the platform based on the students feedback on specific courses.
select feedback_comment, feedback_rating 
from enrolled 
where course_id in (select id from course where name = 'Python' and instructor_id = 12);

--- 5. The completion rate for a specific course can give us insights about that course. 
select course.name as "Course name", sum(case when status = "completed" then 1 end)/count(*)*100 as "Completion Rate (%)" 
from enrolled 
inner join course on course.id = course_id 
where course_id = 1;

--- 8. The Average Performance for a particular Material in a Chapter of interest.
select (select name 
	from course 
	where id = (select course_id 
		from chapter 
        where id = 1)) as "Course",(select name from chapter where id = 1) as "Chapter", material.name as "Material", 
        avg(score)/(select max_points from material where id=19)*100 as "Average Percentage (%)" 
from assigned 
inner join material on material.id = assigned.material_id 
where material_id = 19;

--- 10. Admin wants to suggest courses based on the courses that the student already took
select (select concat(student.first_name, ' ', case when student.last_name is not null then student.last_name else '' end) 
	from student where student.id = 2) as "Student name", course.name as "Recommended Course", course.description as "Course description" 
from course
where id in (select course_id 
	from related_to 
	where career_path_id in (select career_path_id 
		from related_to 
        where course_id in (select course_id 
			from enrolled 
            where student_id = 2)));

--- 12. Total Earnings per course
select course.id,course.name,course.course_fee,count(*)  as "Number of students enrolled", 
	replace(course.course_fee, "$", '')*count(*) as "Total Earnings" 
from enrolled 
left join course on course.id = enrolled.course_id 
group by course.id 
order by course_id;

--- 13. Total Earnings per instructor
select instructor_id,concat(instructor.first_name,' ', case when instructor.last_name is not null then instructor.last_name else '' end) as "Instructor name", 
	sum(replace(course.course_fee,"$",'')) as "Total Revenue ($)",
	sum(replace(course.course_fee,"$",''))*0.8 as "Total Instructor Earnings ($)", 
    sum(replace(course.course_fee,"$",''))*0.2 as "Total Company Earnings ($)" 
from enrolled 
left join course on course.id = enrolled.course_id 
left join instructor on instructor_id = instructor.id 
group by instructor_id 
order by instructor_id;


