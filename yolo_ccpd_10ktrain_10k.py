from ultralytics import YOLO

if __name__ == '__main__':
    # 加载模型
    model = YOLO("yolov8n.pt")

    # 明确指定 GPU 设备
    device = "0"

    # 开始训练
    model.train(
        data="D:/Download/yolo_ccpd_10k/ccpd_10k.yaml",
        epochs=100,
        imgsz=640,
        batch=32,
        device=device,
        workers=16,
        amp=True
    )

    print("训练完成！")