from config.db import db, app, ma

class User(db.Model):
    __tablename__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(100), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)
    username = db.Column(db.String(50), unique=True, nullable=False)

    def __init__(self, email, password, username):
        self.email = email
        self.password = password
        self.username = username

with app.app_context():
    db.create_all()

class UserSchema(ma.Schema):
    class Meta:
        fields = ('id', 'email', 'username')
