from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required
from config.db import db
from models.review import Review, ReviewSchema

ruta_review = Blueprint("ruta_review", __name__)
review_schema = ReviewSchema()
reviews_schema = ReviewSchema(many=True)

@ruta_review.route("/reviews", methods=["GET"])
@jwt_required()
def get_reviews():
    reviews = Review.query.all()
    result = reviews_schema.dump(reviews)
    return jsonify(result)

@ruta_review.route("/review", methods=["POST"])
@jwt_required()
def add_review():
    contenido = request.json['contenido']
    fechayhora = request.json['fechayhora']
    calificacion = request.json['calificacion']
    id_usuario = request.json['id_usuario']
    id_sitio = request.json['id_sitio']
    new_review = Review(contenido, fechayhora, calificacion, id_usuario, id_sitio)
    db.session.add(new_review)
    db.session.commit()
    return review_schema.jsonify(new_review)

@ruta_review.route("/review/<id>", methods=["DELETE"])
@jwt_required()
def delete_review(id):
    review = Review.query.get(id)
    db.session.delete(review)
    db.session.commit()
    return review_schema.jsonify(review)
