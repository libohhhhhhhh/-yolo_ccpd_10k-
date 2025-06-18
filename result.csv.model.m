% CSV文件训练日志分析程序

% 1. 读取CSV文件
[filename, pathname] = uigetfile({'*.csv','CSV Files (*.csv)'},'选择训练日志CSV文件');
if filename == 0
    return;
end

% 读取CSV文件内容
data = readtable(fullfile(pathname, filename), 'VariableNamingRule', 'preserve');

% 2. 提取数据
epochs = data.epoch;
time = data.time;

% 提取训练损失数据（根据列名分割）
losses = strsplit(data.Properties.VariableNames{3}, '/');
box_loss = data{:, 3};  % train/box_train
cls_loss = data{:, 4};  % train/cls_train
dfl_loss = data{:, 5};  % train/dfl_metrics
total_loss = box_loss + cls_loss + dfl_loss;

% 提取评估指标
precision = data{:, 6};  % metrics/precision
recall = data{:, 7};     % metrics/recall
mAP50 = data{:, 8};      % metrics/mAP50
mAP50_95 = data{:, 9};   % metrics/mAP50-95

% 创建两个图窗
figure('Name', '训练分析 - 2D视图', 'Position', [100 100 1200 800]);
figure('Name', '训练分析 - 3D视图', 'Position', [150 150 1200 800]);

% === 第一个图窗：原有的2D图表 ===
figure(1);
% 损失曲线 - 使用时间作为横坐标
subplot(2,2,1);
plot(time, box_loss, 'LineWidth', 2, 'DisplayName', 'Box Loss');
hold on;
plot(time, cls_loss, 'LineWidth', 2, 'DisplayName', 'Cls Loss');
plot(time, dfl_loss, 'LineWidth', 2, 'DisplayName', 'DFL Loss');
plot(time, total_loss, 'LineWidth', 2, 'DisplayName', 'Total Loss');
xlabel('训练时间 (s)');
ylabel('Loss');
title('训练损失曲线');
legend('Location', 'best');
grid on;

% 准确率和召回率
subplot(2,2,2);
plot(time, precision, 'LineWidth', 2, 'DisplayName', 'Precision');
hold on;
plot(time, recall, 'LineWidth', 2, 'DisplayName', 'Recall');
xlabel('训练时间 (s)');
ylabel('值');
title('准确率和召回率');
legend('Location', 'best');
grid on;

% mAP曲线
subplot(2,2,3);
plot(time, mAP50, 'LineWidth', 2, 'DisplayName', 'mAP50');
hold on;
plot(time, mAP50_95, 'LineWidth', 2, 'DisplayName', 'mAP50-95');
xlabel('训练时间 (s)');
ylabel('mAP');
title('mAP评估指标');
legend('Location', 'best');
grid on;

% 5. 计算并显示最终性能
subplot(2,2,4);
final_metrics = [precision(end), recall(end), mAP50(end), mAP50_95(end)];
bar(final_metrics);
set(gca, 'XTickLabel', {'Precision', 'Recall', 'mAP50', 'mAP50-95'});
title('最终模型性能');
ylabel('值');
grid on;

% 6. 保存分析结果
results = struct();
results.epochs = epochs;
results.time = time;
results.box_loss = box_loss;
results.cls_loss = cls_loss;
results.dfl_loss = dfl_loss;
results.total_loss = total_loss;
results.precision = precision;
results.recall = recall;
results.mAP50 = mAP50;
results.mAP50_95 = mAP50_95;

save('training_analysis.mat', 'results');

% 7. 输出最终性能指标
fprintf('\n最终模型性能指标：\n');
fprintf('训练时长: %.2f秒\n', time(end));
fprintf('Precision: %.4f\n', precision(end));
fprintf('Recall: %.4f\n', recall(end));
fprintf('mAP50: %.4f\n', mAP50(end));
fprintf('mAP50-95: %.4f\n', mAP50_95(end));
fprintf('最终总损失: %.4f\n', total_loss(end));

% === 第二个图窗：新增3D可视化 ===
figure(2);

% 3D损失曲线
subplot(2,2,1);
plot3(time, box_loss, cls_loss, 'LineWidth', 2);
hold on;
plot3(time, box_loss, dfl_loss, 'LineWidth', 2);
grid on;
xlabel('时间 (s)');
ylabel('Box Loss');
zlabel('Cls/DFL Loss');
title('损失函数3D关系');
legend('Box-Cls关系', 'Box-DFL关系');
view(45, 30);

% 精确度-召回率-时间 3D图
subplot(2,2,2);
plot3(time, precision, recall, 'LineWidth', 2, 'Color', 'r');
grid on;
xlabel('时间 (s)');
ylabel('Precision');
zlabel('Recall');
title('PR曲线时间演化');
view(45, 30);

% mAP50-mAP50_95-时间 3D图
subplot(2,2,3);
plot3(time, mAP50, mAP50_95, 'LineWidth', 2, 'Color', 'g');
grid on;
xlabel('时间 (s)');
ylabel('mAP50');
zlabel('mAP50-95');
title('mAP指标时间演化');
view(45, 30);

% 3D性能指标综合展示
subplot(2,2,4);
plot3(precision, recall, mAP50, 'LineWidth', 2);
hold on;
scatter3(precision, recall, mAP50, 50, time, 'filled');
colorbar;
grid on;
xlabel('Precision');
ylabel('Recall');
zlabel('mAP50');
title('性能指标综合关系');
view(45, 30);

% 添加交互性
for i = 1:4
    subplot(2,2,i);
    rotate3d on;  % 启用3D旋转功能
end

% 添加一些额外的统计信息
fprintf('\n训练过程分析：\n');
fprintf('平均训练速度: %.2f秒/轮\n', mean(diff(time)));
fprintf('损失下降速率: %.4f/秒\n', (total_loss(1) - total_loss(end))/time(end));
fprintf('mAP50提升速率: %.4f/秒\n', (mAP50(end) - mAP50(1))/time(end));

% 创建动态3D视图（可选）
figure('Name', '训练过程动态视图');
h = plot3(precision(1), recall(1), mAP50(1), 'ro');
xlabel('Precision');
ylabel('Recall');
zlabel('mAP50');
title('训练过程动态展示');
grid on;
view(45, 30);

% 动画展示训练过程
for i = 1:length(time)
    set(h, 'XData', precision(1:i), 'YData', recall(1:i), 'ZData', mAP50(1:i));
    drawnow;
    pause(0.01);
end