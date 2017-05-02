import dotenv
import cx_Oracle

dotenv.load()

def create_cx_oracle_conn():
    dsnStr = cx_Oracle.makedsn(
        dotenv.get('POWERSCHOOL_HOST'),
        dotenv.get('POWERSCHOOL_PORT', '1521'),
        dotenv.get('POWERSCHOOL_DATABASE')
    )

    connection = cx_Oracle.connect(
        dotenv.get('POWERSCHOOL_USER'),
        dotenv.get('POWERSCHOOL_PASSWORD'),
        dsn=dsnStr
    )

    return connection
