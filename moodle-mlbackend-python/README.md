# Moodle /lib/mlbackend

## mlbackend/python

Yêu cầu về Version settup:

![image](https://github.com/user-attachments/assets/dd50deac-b1e2-4120-b9ab-60a10d302c11)

Yêu cầu về Upgrade version: 

![image](https://github.com/user-attachments/assets/e4cc48b7-6e25-4344-9005-0b2c3d35c48e)

Yêu cầu chuẩn bị Settup Python / Ubuntu linux

![image](https://github.com/user-attachments/assets/f009c25e-50d6-47f6-b429-609cf4f8d63c)

Yêu cầu tham số Class xác định Host của Python Server / Ubuntu linux:

**- Check PIP requirement version: 3.0.5**

![image](https://github.com/user-attachments/assets/bb145abb-f2ed-4804-849f-c8be4aca4030)

```req
tensorflow==2.7.1,<2.8
scikit-learn>=0.21,<0.22
numpy>=1.19.2,<1.20
matplotlib>=3.0,<3.1
boto3>=1.9.0,<1.10
flask>=1.0.2,<1.1
pytest-flask
joblib>=0.13.0,<0.14
markupsafe<2.1.0
itsdangerous==2.0.1',
Jinja2>=3.0.1,<3.1',
```
**> Troubleshooting và FAQ:**
> Sau khi cài đặt python, bạn cần cài đặt gói mlbackend (bao gồm tensorflow) trên máy chủ python này.
> TensorFlow và Tensorboard đều đã được cài đặt, cũng như MoodlemlBackend. Moodle và Python đều đã được cài đặt trên cùng một máy chủ hoặc cài ở máy chủ riêng.
> 
> **FAQ:**
> vâng - nghe có vẻ như moodlemlbackend không chạy đúng - tên người dùng/mật khẩu mặc định được mã hóa cứng trong gói đó.
> 
> - Chúng tôi đã xây dựng các phiên bản gói của riêng mình và thả nó vào máy chủ bên ngoài thay vì trên máy cục bộ vì chúng tôi có nhiều giao diện web trên hầu hết các trang web của khách hàng.
>   
> - Chúng tôi cũng thay đổi mật khẩu mặc định _Tham khảo: Admins can change analytics settings and setup different machine learning backends (https://tracker.moodle.org/browse/MDLQA-11576)_

## Các bước cài đặt Python 3.8 trên ubuntu 22.04

## mlbackend/php


