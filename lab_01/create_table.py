import psycopg2
from config import load_config

def create_table():
    commands=(
    """CREATE TABLE tiki_product (
   id BIGINT PRIMARY KEY,
   name TEXT,
   url_key TEXT,
   price NUMERIC,
   description TEXT,
   images TEXT
    )
    """
    )
    try:
        config=load_config()
        with psycopg2.connect(**config) as conn:
            with conn.cursor() as cur:
                cur.execute(commands)
    except (psycopg2.DatabaseError, Exception) as error:
        print(error)

if __name__=='__main__':
    create_table()