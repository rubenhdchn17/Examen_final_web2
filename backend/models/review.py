from config.db import db, app, ma

class Review(db.Model):
    __tablename__ = 'reviews'

    id = db.Column(db.Integer, primary_key=True)
    contenido = db.Column(db.Text, nullable=False)
    calificacion = db.Column(db.Integer, nullable=False)
    id_usuario = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    id_sitio = db.Column(db.Integer, nullable=False)  # No es llave foránea

    def __init__(self, contenido, calificacion, id_usuario, id_sitio):
        self.contenido = contenido
        self.calificacion = calificacion
        self.id_usuario = id_usuario
        self.id_sitio = id_sitio

with app.app_context():
    db.create_all()

class ReviewSchema(ma.Schema):
    class Meta:
        fields = ('id', 'contenido', 'calificacion', 'id_usuario', 'id_sitio')
