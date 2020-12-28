## 一、添加升级库
### 请将`RTKLEFoundation.framework`、`RTKOTASDK.framework`拖动到项目
## 二、配置升级库
### 1、在`General`->`Frameworks,Libraries,and Enabedded Content`中，将：`RTKLEFoundation.framework`、`RTKOTASDK.framework`设置为：`Embed & Sign`
### 2、在`Build Setting`中，将`Enable Bitcode`设为`NO`
## 三、其他项目配置
### 3、在info.plist中配置蓝牙权限
#### `Privacy - Bluetooth Peripheral Usage Description`
#### `Privacy - Bluetooth Always Usage Description`
### 4、升级文件：将测试文件夹“firmwares”copy到App沙盒中（AppData/Documents路径下）
