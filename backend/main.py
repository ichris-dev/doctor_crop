from datetime import datetime
import shutil
from fastapi.staticfiles import StaticFiles
import numpy as np
from PIL import Image
import tensorflow as tf
from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI, File, Form, UploadFile, WebSocket, WebSocketDisconnect
import asyncpg
from pydantic import BaseModel
import os
from config import CROP_CONFIG
from typing import List
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input   #type: ignore
import ollama
from fastapi import FastAPI, WebSocket
import asyncio

class RegisterUser(BaseModel):
    full_name: str
    phone_number: str
    password: str
    location: str
    
    
class LoginUser(BaseModel):
    phone_number: str
    password: str
    



UPLOAD_DIR = "uploaded_images"
os.makedirs(UPLOAD_DIR, exist_ok=True)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount AFTER middleware
app.mount("/images", StaticFiles(directory="uploads"), name="images")

async def databse_connection():
    conn = await asyncpg.connect(
        user="postgres",
        password="2007",
        database="agroconnectDb",
        host="localhost"
    )
    
    return conn



@app.websocket("/chat")
async def chat(websocket: WebSocket):
    await websocket.accept()

    client = ollama.AsyncClient()

    while True:
        messages = await websocket.receive_json()

        async for chunk in await client.chat(
            model="smollm:360m",
            messages=messages,
            stream=True,
        ):
            delta = chunk["message"]["content"]
            await websocket.send_text(delta)
            await asyncio.sleep(0)  # ← yields control so the send actually flushes

        await websocket.send_text("[DONE]")
        
        
@app.post("/register")
async def register_user(user: RegisterUser):
    conn = await databse_connection()
    try:
        user_id = await conn.fetchval("""
            INSERT INTO agroconnectUsersTb
            (full_name, phone_number, password, location)
            VALUES ($1, $2, $3, $4)
            RETURNING user_id
        """,
            user.full_name,
            user.phone_number,
            user.password,
            user.location
        )

        return {
            "success": True,
            "message": "User registered successfully",
            "user_id": user_id
        }

    except Exception as e:
        print(e)
        return {
            "success": False,
            "message": "Registration failed",
            "user_id": None
        }
    finally:
        await conn.close()

@app.post("/login")
async def login_user(user: LoginUser):
    conn = await databse_connection()
    try:
        user_data = await conn.fetchrow("""
            SELECT user_id, full_name 
            FROM agroconnectUsersTb
            WHERE phone_number = $1 AND password = $2
        """, user.phone_number, user.password)

        if user_data is None:
            return {"success": False, "message": "Wrong phone number or password", "user_data": None}

        return {
            "success": True,
            "message": "User found successfully",
            "user_data": dict(user_data)  # single dict, not a list
        }
    except Exception as e:
        print(e)
        return {"success": False, "message": str(e), "user_data": None}
    finally:
        await conn.close()


MODELS = {}

for crop, config in CROP_CONFIG.items():
    model_path = config["model_path"]

    if os.path.exists(model_path):
        MODELS[crop] = tf.keras.models.load_model(
    model_path,
    custom_objects={"preprocess_input": preprocess_input},
    safe_mode=False,
)
        print(f"{crop} model loaded from {model_path}")
    else:
        print(f"WARNING: {crop} model not found at {model_path}")


def preprocess_image(image_path: str, target_size=(224, 224)):
    image = Image.open(image_path).convert("RGB")
    image = image.resize(target_size)

    image_array = np.array(image).astype("float32")

    image_array = np.expand_dims(image_array, axis=0)

    return image_array

def predict_crop_disease(crop: str, image_path: str):
    if crop not in CROP_CONFIG:
        raise ValueError(f"Unsupported crop: {crop}")

    if crop not in MODELS:
        raise ValueError(f"Model for {crop} is not loaded")

    model = MODELS[crop]
    class_names = CROP_CONFIG[crop]["class_names"]

    input_data = preprocess_image(image_path)

    predictions = model.predict(input_data)[0]

    # If model output is logits, softmax converts them to probabilities.
    # If your model already has softmax, this still usually works okay,
    # but ideally use softmax only if needed.
    if not np.isclose(np.sum(predictions), 1.0, atol=0.01):
        predictions = tf.nn.softmax(predictions).numpy()

    probabilities = []

    for class_name, probability in zip(class_names, predictions):
        probabilities.append({
            "disease": class_name,
            "probability": round(float(probability) * 100, 2),
        })

    probabilities = sorted(
        probabilities,
        key=lambda x: x["probability"],
        reverse=True,
    )

    top_prediction = probabilities[0]

    return {
        "top_disease": top_prediction["disease"],
        "top_probability": top_prediction["probability"],
        "all_probabilities": probabilities,
    }


@app.post("/upload-image")
async def upload_image(
    crop: str = Form(...),
    phone_path: str = Form(...),
    created_time: str = Form(...),
    image: UploadFile = File(...),
):
    now = datetime.now()
    safe_time = now.strftime("%Y_%m_%d_%H_%M_%S")

    file_extension = image.filename.split(".")[-1] if image.filename else "jpg"

    safe_crop_name = crop.replace(" ", "_")
    backend_filename = f"{safe_crop_name}_{safe_time}.{file_extension}"
    backend_path = os.path.join(UPLOAD_DIR, backend_filename)

    with open(backend_path, "wb") as buffer:
        shutil.copyfileobj(image.file, buffer)

    prediction_result = predict_crop_disease(crop, backend_path)

    return {
        "message": "Image received and analyzed successfully",
        "crop": crop,
        "phone_path": phone_path,
        "created_time_from_phone": created_time,
        "backend_filename": backend_filename,
        "backend_path": backend_path,
        "prediction": prediction_result,
    }



class AllUsersFetch(BaseModel):
    phone: str

@app.post("/fetch-all")
async def fetch_all(data: AllUsersFetch):
    conn = await databse_connection()
    try:
        fetched_users = await conn.fetch("""
            SELECT user_id, full_name, location, phone_number
            FROM agroconnectUsersTb
            WHERE phone_number != $1
        """, data.phone)

        my_id = await conn.fetchval("""
            SELECT user_id
            FROM agroconnectUsersTb
            WHERE phone_number = $1
        """, data.phone)

        chats = await conn.fetch("""
            SELECT 
                m.message_id,
                m.message,
                m.created_at,
                m.sender_id,
                m.receiver_id,
                u.full_name     AS sender_name,
                u.phone_number  AS sender_phone,
                u2.full_name    AS receiver_name,
                u2.phone_number AS receiver_phone,
                CASE WHEN m.sender_id = $1 THEN true ELSE false END AS is_mine
                FROM messages m
                JOIN agroconnectUsersTb u  ON u.user_id  = m.sender_id
                JOIN agroconnectUsersTb u2 ON u2.user_id = m.receiver_id
                WHERE m.sender_id = $1
                OR m.receiver_id = $1
                ORDER BY m.created_at ASC
            """, my_id)

        return {
            "success": True,
            "my_id": my_id,
            "users": [dict(u) for u in fetched_users],
            "chats": [dict(c) for c in chats]
        }

    except Exception as e:
        print("FETCH ALL ERROR:", e)
        return {"success": False, "my_id": None, "users": [], "chats": []}
    finally:
        await conn.close()
        



class SendMessage(BaseModel):
    sender_phone: str
    receiver_id: int
    message: str

@app.post("/send-message")
async def send_message(data: SendMessage):
    conn = await databse_connection()
    try:
        # Get sender's user_id from their phone number
        sender_id = await conn.fetchval("""
            SELECT user_id FROM agroconnectUsersTb
            WHERE phone_number = $1
        """, data.sender_phone)

        if sender_id is None:
            return {"success": False, "message": "Sender not found"}

        # Save the message
        message_id = await conn.fetchval("""
            INSERT INTO messages (sender_id, receiver_id, message, created_at)
            VALUES ($1, $2, $3, NOW())
            RETURNING message_id
        """, sender_id, data.receiver_id, data.message)

        return {
            "success": True,
            "message_id": message_id
        }

    except Exception as e:
        print("SEND MESSAGE ERROR:", e)
        return {"success": False, "message": str(e)}
    finally:
        await conn.close()
        

BASE_URL = "http://192.168.1.65:8000"

@app.get("/fetch-products")
async def fetch_all_products():
    conn = await databse_connection()
    try:
        products = await conn.fetch("""
            SELECT id, store_id, product_name, description, 
                   price_rwf, image_url, location, created_at::text
            FROM products
        """)
        
        result = []
        for p in products:
            product_dict = dict(p)
            # Convert relative path → full URL
            # uploads/store_1/bromex_f.png → http://192.168.1.65:8000/images/store_1/bromex_f.png
            raw_path = product_dict["image_url"]  # uploads/store_1/bromex_f.png
            filename = "/".join(raw_path.split("/")[1:])  # store_1/bromex_f.png
            product_dict["image_url"] = f"{BASE_URL}/images/{filename}"
            result.append(product_dict)
        
        return {"success": True, "content": result}

    except Exception as e:
        print("Error: {} occurred".format(e))
        return {"success": False, "content": []}
    finally:
        await conn.close()
        


@app.get("/debug-products")
async def debug_products():
    conn = await databse_connection()
    try:
        products = await conn.fetch("SELECT id, image_url FROM products")
        result = []
        for p in products:
            raw = p["image_url"]
            filename = "/".join(raw.split("/")[1:])
            full_url = f"http://192.168.1.65:8000/images/{filename}"
            result.append({
                "raw_from_db": raw,
                "converted_url": full_url
            })
        return result
    finally:
        await conn.close()
        

import httpx

@app.get("/weather")
async def get_weather(lat: float = -1.9441, lon: float = 30.0619):
    # Default is Kigali. Flutter can pass any lat/lon
    try:
        url = (
            f"https://api.open-meteo.com/v1/forecast"
            f"?latitude={lat}&longitude={lon}"
            f"&current=temperature_2m,relative_humidity_2m,"
            f"wind_speed_10m,precipitation_probability,weathercode"
            f"&hourly=temperature_2m,precipitation_probability,weathercode"
            f"&daily=temperature_2m_max,temperature_2m_min,"
            f"precipitation_probability_max,weathercode"
            f"&timezone=Africa%2FKigali"
            f"&forecast_days=7"
        )

        async with httpx.AsyncClient() as client:
            response = await client.get(url)
            data = response.json()

        current = data["current"]
        daily = data["daily"]
        hourly = data["hourly"]

        return {
            "success": True,
            "current": {
                "temperature":   current["temperature_2m"],
                "humidity":      current["relative_humidity_2m"],
                "wind_speed":    current["wind_speed_10m"],
                "rain_chance":   current["precipitation_probability"],
                "weather_code":  current["weathercode"],
            },
            "daily": [
                {
                    "date":        daily["time"][i],
                    "temp_max":    daily["temperature_2m_max"][i],
                    "temp_min":    daily["temperature_2m_min"][i],
                    "rain_chance": daily["precipitation_probability_max"][i],
                    "weather_code":daily["weathercode"][i],
                }
                for i in range(len(daily["time"]))
            ],
            "hourly": [
                {
                    "time":        hourly["time"][i],
                    "temperature": hourly["temperature_2m"][i],
                    "rain_chance": hourly["precipitation_probability"][i],
                    "weather_code":hourly["weathercode"][i],
                }
                for i in range(24)  # only first 24 hours
            ]
        }

    except Exception as e:
        print("WEATHER ERROR:", e)
        return {"success": False, "current": None, "daily": [], "hourly": []}
    
    

@app.post("/fetch-store")
async def fetch_store(data: AllUsersFetch):
    conn = await databse_connection()
    try:
        # 1. Get user_id from phone
        user_id = await conn.fetchval("""
            SELECT user_id FROM agroconnectUsersTb
            WHERE phone_number = $1
        """, data.phone)

        if user_id is None:
            return {"success": False, "store": None, "products": []}

        # 2. Check if this user owns a store
        store = await conn.fetchrow("""
            SELECT store_id, store_name, store_phone, store_location, created_at::text
            FROM stores
            WHERE user_id = $1
        """, user_id)

        if store is None:
            return {"success": True, "store": None, "products": []}

        store_dict = dict(store)
        store_id = store_dict["store_id"]

        # 3. Fetch all products for that store
        products = await conn.fetch("""
            SELECT id, store_id, product_name, description,
                   price_rwf, image_url, location, created_at::text
            FROM products
            WHERE store_id = $1
        """, store_id)

        result_products = []
        for p in products:
            pd = dict(p)
            raw_path = pd["image_url"]
            filename = "/".join(raw_path.split("/")[1:])
            pd["image_url"] = f"{BASE_URL}/images/{filename}"
            result_products.append(pd)

        return {
            "success": True,
            "store": store_dict,
            "products": result_products
        }

    except Exception as e:
        print("FETCH STORE ERROR:", e)
        return {"success": False, "store": None, "products": []}
    finally:
        await conn.close()