from ultralytics import YOLO

model = YOLO("./runs/detect/train/weights/best.pt") # load the weights from the custom trained model
model.export(format="onnx", imgsz=(640, 640)) # export the model to onnx format
onnx_model = YOLO("./runs/detect/train/weights/best.onnx") # path to the onnx model

# run inference on the onnx export
results = onnx_model("./videos/paper_airplane.mp4", save=True) # run inference on the video 
