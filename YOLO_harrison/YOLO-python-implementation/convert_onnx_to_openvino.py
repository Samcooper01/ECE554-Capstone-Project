import openvino as ov 

model = ov.convert_model('./runs/detect/train/weights/best.onnx')

ov.save_model(model, './models/paper_airplane_detector.xml')