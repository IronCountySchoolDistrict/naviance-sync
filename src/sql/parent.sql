SELECT
  trim(initcap(guardian.firstname))                             AS first_name,
  trim(initcap(guardian.lastname))                              AS last_name,
  initcap(trim(guardian.firstname || ' ' || guardian.lastname)) AS full_name,
  students.dcid                                                 AS student_id,
  pcas_account.pcas_accountid                                   AS parent_id,
  pcas_emailcontact.emailaddress                                AS email
FROM pcas_account
  JOIN pcas_service ON pcas_account.pcas_serviceid = pcas_service.pcas_serviceid
  JOIN pcas_emailcontact ON pcas_account.pcas_accountid = pcas_emailcontact.pcas_accountid
  JOIN guardian ON pcas_account.pcas_accounttoken = guardian.accountidentifier
  JOIN guardianstudent ON guardian.guardianid = guardianstudent.guardianid
  JOIN students ON guardianstudent.studentsdcid = students.dcid
WHERE servicename = 'PS Parent Portal' AND
      students.enroll_status = 0 AND
      schoolid IN (704, 708, 712)