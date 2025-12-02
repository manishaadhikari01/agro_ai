from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

DATABASE_URL = "postgresql://agro_user:123456@localhost:5432/AgroAI"


engine = create_engine("postgresql://agro_user:123456@localhost:5432/AgroAI")

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()
