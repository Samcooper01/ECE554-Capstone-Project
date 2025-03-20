import supervision as sv
import numpy as np
from ultralytics import YOLO

# Load model
model = YOLO("./models/paper_airplane_detector.pt")

# results
results = model('./videos/paper_airplane.mp4', save=True)  # or .from_images() or .from_webcam()