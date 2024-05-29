from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required
from config.db import db
from models.user import User, UserSchema

ruta_user = Blueprint("ruta_user", __name__)
user_schema = UserSchema()
users_schema = UserSchema(many=True)

@ruta_user.route("/users", methods=["GET"])
@jwt_required()
def get_users():
    users = User.query.all()
    result = users_schema.dump(users)
    return jsonify(result)

@ruta_user.route("/register", methods=["POST"])
def register_user():
    try:
        data = request.get_json()
        email = data.get('email')
        username = data.get('username')
        password = data.get('password')  # Contraseña sin hashear

        # Verificar si el usuario ya existe
        if User.query.filter_by(email=email).first() or User.query.filter_by(username=username).first():
            return jsonify({"msg": "El usuario o email ya existe"}), 409

        new_user = User(email=email, username=username, password=password)
        db.session.add(new_user)
        db.session.commit()

        token = create_access_token(identity=new_user.id)
        return jsonify({'token': token}), 201
    except Exception as e:
        print(f"Error al registrar usuario: {e}")
        return jsonify({"msg": "Error al registrar usuario"}), 500

@ruta_user.route("/login", methods=["POST"])
def login_user():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    user = User.query.filter_by(username=username).first()
    if user and user.password == password:  # Comparación directa
        token = create_access_token(identity=user.id)
        return jsonify({'token': token}), 200
    return jsonify({"msg": "Invalid username or password"}), 401
