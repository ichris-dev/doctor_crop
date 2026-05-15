import os

MODEL_DIR = "models"

# Crop configuration
CROP_CONFIG = {
    "Beans": {
        "model_path": os.path.join(MODEL_DIR, "beans.keras"),
        "class_names": [
            "angular_leaf_spot",
            "bean_rust",
            "healthy",
        ],
    },
    "Maize": {
        "model_path": os.path.join(MODEL_DIR, "maize.keras"),
        "class_names": [
            "Blight",
            "Common_Rust",
            "Gray_Leaf_Spot",
            "Healthy",
        ],
    },
    "Potato": {
        "model_path": os.path.join(MODEL_DIR, "potato.keras"),
        "class_names": [
            "Potato___Early_blight",
            "Potato___Late_blight",
            "Potato___healthy",
        ],
    },

}
