WITH reenrollments_with_current AS (
  SELECT
    studentid AS student_id,
    entrydate,
    exitdate,
    reenrollments.grade_level
  FROM reenrollments
  UNION
  SELECT
    students.id AS student_id,
    entrydate,
    exitdate,
    students.grade_level
  FROM students
)
SELECT
  students.dcid                                             AS student_id,
  students.lastfirst                                        AS lastfirst,
  sections.course_number                                    AS course_id,
  reenrollments_with_current.grade_level                    AS grade_level,
  courses.course_name                                       AS course_name,
  teachers.first_name || ' ' || teachers.last_name          AS teacher,
  CASE
  WHEN pgfinalgrades.startdate <= SYSDATE AND pgfinalgrades.enddate >= SYSDATE
    THEN 'Completed'
  ELSE 'In Progress' END                                    AS course_status,
  terms.name || ' (' || pgfinalgrades.finalgradename || ')' AS term,
  courses.credit_hours                                      AS credits_earned,
  pgfinalgrades.grade                                       AS letter_grade,
  pgfinalgrades.percent                                     AS number_grade


FROM pgfinalgrades
  JOIN sections ON pgfinalgrades.sectionid = sections.id
  JOIN students ON pgfinalgrades.studentid = students.id
  JOIN courses ON sections.course_number = courses.course_number
  JOIN terms ON sections.termid = terms.id AND terms.isyearrec = 1 AND terms.schoolid = students.schoolid
  JOIN reenrollments_with_current ON students.id = reenrollments_with_current.student_id AND
                                     pgfinalgrades.startdate >= reenrollments_with_current.entrydate AND
                                     pgfinalgrades.enddate <= reenrollments_with_current.exitdate
  JOIN teachers ON sections.teacher = teachers.id
WHERE sections.schoolid IN (704, 708, 712) AND
      students.enroll_status = 0