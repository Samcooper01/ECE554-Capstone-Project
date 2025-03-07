from ultralytics import YOLO

# Load a model
model = YOLO("yolo11n.yaml")  # build a new model from YAML

# Train the model
results = model.train(data="/Users/hmrdoll/ece554/ECE554-Capstone-Project/YOLO_harrison/YOLO-python-implementation/config.yaml", epochs=25, device="mps")