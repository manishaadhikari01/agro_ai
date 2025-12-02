from database import Base, engine, SessionLocal
from sqlalchemy import Column, Integer, String

# Define a sample model
class Farmer(Base):
    __tablename__ = "farmers"
    farmer_id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    location = Column(String(150))
    phone = Column(String(20), unique=True)


def test_connection():
    try:
        # Create tables
        Base.metadata.create_all(bind=engine)

        # Open session
        db = SessionLocal()

        # Insert a test farmer
        new_farmer = Farmer(name="Ramesh Kumar", location="Punjab", phone="9874543210")
        db.add(new_farmer)

        # Commit transaction
        db.commit()

        # Query farmers
        farmers = db.query(Farmer).all()
        print("✅ Farmers in DB:")
        for farmer in farmers:
            print(farmer.farmer_id, farmer.name, farmer.location, farmer.phone)

        db.close()
        print("✅ Database connection successful")

    except Exception as e:
        print("❌ Database connection failed:", e)


if __name__ == "__main__":
    test_connection()
