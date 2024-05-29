from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from config.db import db
from models.site import Site, SiteSchema
from models.review import Review
from datetime import datetime

ruta_site = Blueprint("ruta_site", __name__)
site_schema = SiteSchema()
sites_schema = SiteSchema(many=True)

@ruta_site.route("/sites", methods=["GET"])
@jwt_required()
def get_sites():
    sites = Site.query.all()
    result = sites_schema.dump(sites)
    return jsonify(result)

@ruta_site.route("/site", methods=["POST"])
@jwt_required()
def add_site_and_comment():
    try:
        data = request.get_json()
        user_id = get_jwt_identity()

        # Save site
        nombre = data.get('site')['nombre']
        categoria = data.get('site')['categoria']
        descripcion = data.get('site')['descripcion']
        ubicacion = data.get('site')['ubicacion']
        abierto = data.get('site')['abierto']

        existing_site = Site.query.filter_by(nombre=nombre, ubicacion=ubicacion).first()
        if existing_site:
            site_id = existing_site.id
        else:
            new_site = Site(nombre=nombre, categoria=categoria, descripcion=descripcion, ubicacion=ubicacion, abierto=abierto)
            db.session.add(new_site)
            db.session.commit()
            site_id = new_site.id

        # Save comment
        contenido = data.get('comment')['contenido']
        fechayhora = datetime.utcnow()
        calificacion = data.get('comment')['calificacion']

        new_review = Review(contenido=contenido, fechayhora=fechayhora, calificacion=calificacion, id_usuario=user_id, id_sitio=site_id)
        db.session.add(new_review)
        db.session.commit()

        return jsonify({"msg": "Site and comment added successfully"}), 201
    except Exception as e:
        print(f"Error: {e}")
        return jsonify({"msg": "Failed to add site and comment"}), 500

@ruta_site.route("/site/<id>", methods=["DELETE"])
@jwt_required()
def delete_site(id):
    site = Site.query.get(id)
    db.session.delete(site)
    db.session.commit()
    return site_schema.jsonify(site)
