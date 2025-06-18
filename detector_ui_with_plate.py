import tkinter as tk
from tkinter import filedialog, messagebox
from ultralytics import YOLO
import cv2
from PIL import Image, ImageTk

class LicensePlateDetectorApp:
    def __init__(self, root):
        self.root = root
        self.root.title("车牌检测器")
        self.root.geometry("800x600")

        # 加载训练好的模型
        self.model = YOLO("D:/Download/yolo_ccpd_10k/runs/detect/train3/weights/best.pt")

        # 创建 UI 组件
        self.label = tk.Label(root, text="请选择一张图像进行车牌检测", font=("Arial", 14))
        self.label.pack(pady=10)

        self.select_button = tk.Button(root, text="选择图像", command=self.select_image, font=("Arial", 12))
        self.select_button.pack(pady=5)

        self.detect_button = tk.Button(root, text="运行检测", command=self.detect_plate, font=("Arial", 12), state="disabled")
        self.detect_button.pack(pady=5)

        # 原图显示区域
        self.image_label = tk.Label(root, text="原图")
        self.image_label.pack(side=tk.LEFT, padx=10, pady=10)

        # 车牌显示区域
        self.plate_label = tk.Label(root, text="检测到的车牌")
        self.plate_label.pack(side=tk.RIGHT, padx=10, pady=10)

        self.image_path = None
        self.plate_image = None

    def select_image(self):
        # 打开文件对话框选择图像
        self.image_path = filedialog.askopenfilename(
            title="选择图像",
            filetypes=[("Image files", "*.jpg *.jpeg *.png *.bmp")]
        )
        if self.image_path:
            # 显示原始图像
            img = Image.open(self.image_path)
            img = img.resize((400, 300), Image.LANCZOS)
            photo = ImageTk.PhotoImage(img)
            self.image_label.config(image=photo, text="原图")
            self.image_label.image = photo  # 保持引用
            self.detect_button.config(state="normal")
            self.label.config(text=f"已选择图像: {self.image_path.split('/')[-1]}")
            # 清空车牌区域
            self.plate_label.config(image=None, text="检测到的车牌")
            self.plate_image = None
        else:
            self.label.config(text="未选择图像，请重新选择")

    def detect_plate(self):
        if not self.image_path:
            messagebox.showwarning("警告", "请先选择一张图像！")
            return

        # 读取图像并运行检测
        img = cv2.imread(self.image_path)
        results = self.model(img, device="0")  # 使用 GPU 检测

        # 绘制检测结果并提取车牌
        plate_detected = False
        for result in results:
            boxes = result.boxes.xyxy
            for box in boxes:
                x_min, y_min, x_max, y_max = map(int, box)
                # 绘制边界框
                cv2.rectangle(img, (x_min, y_min), (x_max, y_max), (0, 255, 0), 2)
                cv2.putText(img, "License Plate", (x_min, y_min - 10), 
                            cv2.FONT_HERSHEY_SIMPLEX, 0.9, (0, 255, 0), 2)
                # 提取车牌区域
                plate_img = img[y_min:y_max, x_min:x_max]
                plate_detected = True
                break  # 只显示第一个检测到的车牌

        # 显示原图
        img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        img_pil = Image.fromarray(img_rgb)
        img_pil = img_pil.resize((400, 300), Image.LANCZOS)
        photo = ImageTk.PhotoImage(img_pil)
        self.image_label.config(image=photo, text="检测结果")
        self.image_label.image = photo

        # 显示车牌（如果检测到）
        if plate_detected:
            plate_rgb = cv2.cvtColor(plate_img, cv2.COLOR_BGR2RGB)
            plate_pil = Image.fromarray(plate_rgb)
            # 调整车牌图像大小，保持比例
            plate_pil.thumbnail((200, 150), Image.LANCZOS)  # 限制最大尺寸
            plate_photo = ImageTk.PhotoImage(plate_pil)
            self.plate_label.config(image=plate_photo, text="检测到的车牌")
            self.plate_label.image = plate_photo  # 保持引用
            self.plate_image = plate_photo
        else:
            self.plate_label.config(image=None, text="未检测到车牌")

        # 更新提示信息并保存结果
        self.label.config(text="检测完成！")
        cv2.imwrite("output_image.jpg", img)
        messagebox.showinfo("提示", "检测结果已保存为 output_image.jpg")

if __name__ == "__main__":
    root = tk.Tk()
    app = LicensePlateDetectorApp(root)
    root.mainloop()