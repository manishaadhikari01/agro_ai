import psycopg2

def test_connection():
    try:
        # Update credentials if you changed user/password
        conn = psycopg2.connect(
            dbname="AgroAI",
            user="agro_user",
            password="123456",   # your agro_user password
            host="localhost",
            port="5432"
        )
        cur = conn.cursor()

        # Create table if not exists
        cur.execute("""
            CREATE TABLE IF NOT EXISTS farmers (
                farmer_id SERIAL PRIMARY KEY,
                name VARCHAR(100) NOT NULL,
                location VARCHAR(150),
                phone VARCHAR(20) UNIQUE
            );
        """)
        conn.commit()

        # Insert a test farmer
        cur.execute("""
            INSERT INTO farmers (name, location, phone)
            VALUES (%s, %s, %s)
            ON CONFLICT (phone) DO NOTHING;
        """, ("Ramesh Kumar", "Punjab", "9876543210"))
        conn.commit()

        # Fetch data back
        cur.execute("SELECT * FROM farmers;")
        rows = cur.fetchall()
        print("✅ Farmers in DB:")
        for row in rows:
            print(row)

        cur.close()
        conn.close()
        print("✅ Database connection successful")

    except Exception as e:
        print("❌ Database connection failed:", e)


if __name__ == "__main__":
    test_connection()
