YOLOv3 车牌检测与识别 (基于CCPD-10k数据集)这是一个基于 YOLOv3 和 PyTorch 实现的端到端中国车牌检测与识别项目。项目使用 CCPD (中国城市停车场数据集) 的10,000张图片作为训练样本，能够准确地从图片或视频中定位车牌并识别其号码。📖 主要功能高效的目标检测: 使用YOLOv3算法，快速、准确地在图像中定位车牌位置。端到端的识别: 在检测到车牌的同时，能够识别出车牌上的字符，无需两步操作。支持多种输入源: 可以对静态图片、视频文件以及实时摄像头画面进行检测。提供预训练模型: 项目内置了基于CCPD-10k数据集训练好的权重，方便用户直接进行测试和使用。易于训练: 提供了完整的训练脚本，用户可以使用自己的数据集进行模型的从零训练或微调。📸 效果演示项目运行在一个简洁的图形用户界面(GUI)中，可以方便地加载图片并进行检测。检测结果会同时在原图上用绿色框标出，并在右侧展示裁剪和放大后的车牌特写。(提示: 请在您的项目根目录下创建一个名为 assets 的文件夹，并将您的效果图（重命名为 demo.png）放入其中，以确保上图能正确显示。)🛠️ 技术栈Python 3.8+PyTorch 1.7+OpenCV-PythonNumPy📂 项目结构.
├── assets/       # (建议创建) 存放文档图片
│   └── demo.png
├── data/         # 存放数据集配置文件 (.data, .names)
├── models/       # 存放YOLOv3模型网络结构 (.cfg)
├── weights/      # 存放训练好的模型权重 (yolov3_10000.weights)
├── output/       # 存放检测结果的默认目录
├── utils/        # 工具函数模块 (数据集加载, 图像处理等)
├── detect.py     # 🔥 执行检测和识别的核心脚本
└── train.py      # 🔥 执行模型训练的脚本
⚙️ 环境配置克隆项目到本地git clone https://github.com/libohhhh/-yolo_ccpd_10k-.git
cd -yolo_ccpd_10k-
创建并激活Python虚拟环境 (推荐)python -m venv venv
# Windows
.\venv\Scripts\activate
# macOS / Linux
source venv/bin/activate
安装依赖库项目根目录下可以创建一个 requirements.txt 文件，内容如下:torch>=1.7.0
torchvision>=0.8.1
numpy>=1.18.5
opencv-python>=4.5.0
matplotlib>=3.3.0
然后通过pip进行安装：pip install -r requirements.txt
🚀 快速开始1. 车牌检测与识别使用 detect.py 脚本进行检测。项目已经内置了训练好的权重 weights/yolov3_10000.weights。检测单张图片:python detect.py --source /path/to/your/image.jpg
检测视频文件:python detect.py --source /path/to/your/video.mp4
使用摄像头实时检测:python detect.py --source 0
检测结果将默认保存在 output/ 文件夹下。您也可以通过 --weights 参数指定不同的权重文件，通过 --output 指定不同的输出路径。2. 模型训练 (可选)如果您想使用自己的数据集进行训练，可以使用 train.py 脚本。准备数据集: 按照YOLO格式组织您的数据集，并创建相应的数据配置文件（如 my_data.data）和类别文件（.names）。开始训练:python train.py --data data/ccpd.data --cfg models/yolov3.cfg --weights weights/yolov3_10000.weights --epochs 100
--data: 数据集配置文件路径。--cfg: 模型配置文件路径。--weights: 预训练权重路径（用于微调）。如果想从零开始训练，可以不指定此参数。--epochs: 训练的总轮数。📝 未来工作 (TODO)[ ] 增加数据增强策略以提升模型的鲁棒性。[ ] 测试并对比不同YOLO系列模型（如YOLOv5, YOLOv7）在该数据集上的性能。[ ] 封装成一个更易于调用的类或API。[ ] 增加一个简单的Web界面用于上传图片进行在线识别。🙏 致谢本项目基于 ultralytics/yolov3 的代码结构。数据集来源于 CCPD (Chinese City Parking Dataset)。📄 许可证本项目采用 MIT License 开源许可证。