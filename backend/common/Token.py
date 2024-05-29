import jwt
from datetime import datetime, timedelta, timezone

def generar_fecha_vencimiento(dias=0, horas=0, minutos=0, segundos=0):
    fecha_actual = datetime.now(tz=timezone.utc)
    tiempo_vencimiento = timedelta(days=dias, hours=horas, minutes=0, seconds=segundos)
    fecha_vencimiento = datetime.timestamp(fecha_actual + tiempo_vencimiento)
    return {"error": False, "token": fecha_vencimiento}

def generar_token(user_token, pass_token):
    try:
        fecha_vencimiento = generar_fecha_vencimiento(segundos=240)["token"]
        payload = {
            "exp": fecha_vencimiento,
            "user_id": user_token,
            "user_pass": pass_token,
        }
        token = jwt.encode(payload, "supersecretkey", algorithm="HS256")
        return {"error": False, "mensaje": "Token generado exitosamente", "token": token}

    except Exception as err:
        return {"error": True, "mensaje": str(err)}

def verificar_token(token):
    try:
        token_verif = jwt.decode(token, "supersecretkey", algorithms=["HS256"])
        return {"error": False, "mensaje": "Token válido"} if token_verif else {"error": True, "mensaje": "Token Inválido"}
    except jwt.ExpiredSignatureError:
        return {"error": True, "mensaje": "Token expirado"}
    except jwt.InvalidSignatureError:
        return {"error": True, "mensaje": "Firma de Token inválida"}
    except jwt.InvalidTokenError:
        return {"error": True, "mensaje": "Token inválido"}
    except jwt.DecodeError:
        return {"error": True, "mensaje": "No se pudo decodificar el token"}
    except jwt.InvalidKeyError:
        return {"error": True, "mensaje": "Llave secreta de Token inválida"}
    except jwt.InvalidAlgorithmError:
        return {"error": True, "mensaje": "Algoritmo de Token inválido"}
