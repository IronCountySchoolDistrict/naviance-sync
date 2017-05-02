from naviance import Naviance
from db import create_cx_oracle_conn
import argparse

import dotenv

dotenv.load()

def results_to_csv_str(results, cursor):
    csv_results = ''
    csv_results += ','.join([column[0] for column in cursor.description])
    csv_results += '\n'
    csv_results += '\n'.join(','.join(str(i) for i in result) for result in results)
    return csv_results

def import_students(client):
    student_sql = open('sql/student.sql').read()
    cursor = create_cx_oracle_conn().cursor()
    cursor.execute(student_sql)
    student_results = cursor.fetchall()

    csv_results = results_to_csv_str(student_results, cursor)
    naviance_response = client.import_students(csv_results)

    return naviance_response


def import_parents(client):
    student_sql = open('sql/parent.sql').read()
    cursor = create_cx_oracle_conn().cursor()
    cursor.execute(student_sql)
    parent_results = cursor.fetchall()

    csv_results = results_to_csv_str(parent_results, cursor)

    naviance_response = client.import_parents(csv_results)

    return naviance_response

def import_course_data(client):
    student_sql = open('sql/student_course.sql').read()
    cursor = create_cx_oracle_conn().cursor()
    cursor.execute(student_sql)
    course_data_results = cursor.fetchall()

    csv_results = results_to_csv_str(course_data_results, cursor)

    naviance_response = client.import_student_course(csv_results)

    return naviance_response


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Perform Naviance Sync process')
    parser.add_argument('import_type', metavar='student|parent|student_course', nargs=1)
    args = parser.parse_args()

    naviance_client = Naviance(account=dotenv.get('NAVIANCE_ACCOUNT'),
                               username=dotenv.get('NAVIANCE_USERNAME'),
                               email=dotenv.get('NAVIANCE_EMAIL'),
                               data_import_key=dotenv.get('NAVIANCE_DATA_IMPORT_KEY'),
                               has_header=dotenv.get('NAVIANCE_HAS_HEADER'))

    if args.import_type[0] == 'student':
        response = import_students(naviance_client)
    if args.import_type[0] == 'parent':
        response = import_parents(naviance_client)
    if args.import_type[0] == 'student_course':
        response = import_course_data(naviance_client)

    print(response.text)