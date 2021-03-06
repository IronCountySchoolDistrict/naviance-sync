WITH student_race_ethnicity AS (
    SELECT
      studentid                            AS studentid,

      -- Parse the "White" out of "(W) White", etc.
      -- Use the min() function here with the GROUP BY studentid below to only show one Ethnicity value
      -- for each student. This will ensure there are no duplicate student records.
      min(trim(initcap(regexp_substr(psrw_student_race.description, '\(\w\)\s*(.*)', 1, 1, 'i',
                                     1)))) AS student_ethnicity
    FROM psrw_student_race
    WHERE psrw_student_race.description IS NOT NULL AND
          psrw_student_race.category_description <> '(T) Tribal Affiliation'
    GROUP BY studentid
)
SELECT
  trim(initcap(first_name))           AS first_name,
  trim(initcap(middle_name))          AS middle_name,
  trim(initcap(last_name))            AS last_name,
  sched_yearofgraduation              AS class_year,
  students.dcid                       AS student_id,
  school_number                       AS school_id,
  students.gender                     AS gender,
  students.student_number             AS fc_username,
  u_def_ext_students.stu_pass         AS fc_password,
  to_char(students.dob, 'MM-DD-YYYY') AS birthdate,
  -- The descriptions from PS don't exactly match what Naviance is expecting,
  -- so perform a "translation" to the Naviance format here
  CASE
  WHEN student_race_ethnicity.student_ethnicity = 'White'
    THEN 'White'
  WHEN student_race_ethnicity.student_ethnicity = 'Black Or African American'
    THEN 'Black/African American'
  WHEN student_race_ethnicity.student_ethnicity = 'Asian'
    THEN 'Asian'
  WHEN students.fedethnicity = 1
    THEN 'Hispanic/Latino'
  WHEN student_race_ethnicity.student_ethnicity = 'American Indian/Alaska Native'
    THEN 'American Indian/Alaska Native'
  WHEN student_race_ethnicity.student_ethnicity = 'Native Hawaiian/Pacific Islander'
    THEN 'Pacific Islander/Native Hawaii'
  WHEN student_race_ethnicity.student_ethnicity = 'Other'
    THEN 'Other' END                  AS ethnicity
FROM students
  JOIN schools ON students.schoolid = schools.school_number
  JOIN u_def_ext_students ON students.dcid = u_def_ext_students.studentsdcid
  JOIN student_race_ethnicity ON students.id = student_race_ethnicity.studentid
WHERE
  -- only include active students
  students.enroll_status = 0 AND

  -- include students from CHS, CVHS, PHS and SEA in sync with grade level >= 8
  students.schoolid IN (704, 708, 712, 750, 304, 308) AND
  students.grade_level >= 8