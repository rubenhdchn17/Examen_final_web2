from config.db import db, app, ma

class Site(db.Model):
    __tablename__ = 'sites'

    id = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(100), nullable=False)
    categoria = db.Column(db.String(50), nullable=False)
    descripcion = db.Column(db.Text, nullable=False)
    ubicacion = db.Column(db.String(100), nullable=False)
    abierto = db.Column(db.Boolean, default=True)

    def __init__(self, nombre, categoria, descripcion, ubicacion, abierto):
        self.nombre = nombre
        self.categoria = categoria
        self.descripcion = descripcion
        self.ubicacion = ubicacion
        self.abierto = abierto

with app.app_context():
    db.create_all()

class SiteSchema(ma.Schema):
    class Meta:
        fields = ('id', 'nombre', 'categoria', 'descripcion', 'ubicacion', 'abierto')
