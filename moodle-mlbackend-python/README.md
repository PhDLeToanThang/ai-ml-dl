#1. Moodle /lib/mlbackend

##1.1. mlbackend/python

Yêu cầu về Version settup:

![image](https://github.com/user-attachments/assets/dd50deac-b1e2-4120-b9ab-60a10d302c11)

Yêu cầu về Upgrade version: 

![image](https://github.com/user-attachments/assets/e4cc48b7-6e25-4344-9005-0b2c3d35c48e)

Yêu cầu chuẩn bị Settup Python / Ubuntu linux

![image](https://github.com/user-attachments/assets/f009c25e-50d6-47f6-b429-609cf4f8d63c)

Yêu cầu tham số Class xác định Host của Python Server / Ubuntu linux:

**- Check PIP requirement version: 3.0.5**
pip           20.0.2
pkg-resources 0.0.0
setuptools    44.0.0
(open-webui) root@mdl:~# python3 -V
Python 3.8.10

![image](https://github.com/user-attachments/assets/bb145abb-f2ed-4804-849f-c8be4aca4030)

```req
# Step 5.1. install manual:
pip -V
pip install tensorflow==2.7
pip install numpy==1.19.5
pip install matplotlib==3.0
pip install urllib3==1.20
pip uninstall urllib3==2.2.3 
pip install urllib3==1.21.1
pip install boto3==1.9.253
pip install botocore==1.12.253
pip install flask==1.0.2
pip install joblib==0.13.0
pip install markupsafe==2.1.1
pip install pandas==1.3
pip install pytest-flask==1.3.0
pip install wheel==0.45.1
pip install twine==3.0.0
pip install jmespath==0.10.0
pip install docutils==0.15.2
pip install -U pip
pip install Cython==3.0.11
pip install scikit-learn==0.21.3

# check version supported
pip3 list

pip install moodlemlbackend
#pip install --upgrade --force-reinstall moodlemlbackend

pip show moodlemlbackend
```
**>1.1.1. Troubleshooting và FAQ:**
> Sau khi cài đặt python, bạn cần cài đặt gói mlbackend (bao gồm tensorflow) trên máy chủ python này.
> TensorFlow và Tensorboard đều đã được cài đặt, cũng như MoodlemlBackend. Moodle và Python đều đã được cài đặt trên cùng một máy chủ hoặc cài ở máy chủ riêng.
> 
> **1.1.2. FAQ:**
> vâng - nghe có vẻ như moodlemlbackend không chạy đúng - tên người dùng/mật khẩu mặc định được mã hóa cứng trong gói đó.
> 
> - Chúng tôi đã xây dựng các phiên bản gói của riêng mình và thả nó vào máy chủ bên ngoài thay vì trên máy cục bộ vì chúng tôi có nhiều giao diện web trên hầu hết các trang web của khách hàng.
>   
> - Chúng tôi cũng thay đổi mật khẩu mặc định _Tham khảo: Admins can change analytics settings and setup different machine learning backends (https://tracker.moodle.org/browse/MDLQA-11576)_

##1.1.3. Các bước cài đặt Python 3.8 trên ubuntu 22.04
_Tham khảo: https://github.com/moodlehq/moodle-mlbackend-python/tree/master_

Source code bash shell chạy lệnh cài toàn bộ gói moodle-mlbackend-python3 trên ubuntu linux:

##1.1.4. 
_Thamg khảo: https://flask.palletsprojects.com/en/stable/tutorial/deploy/_

##1.1.5. Cấu hình trên moodle 4.5:
_Tham khảo: https://docs.moodle.org/405/en/Analytics_settings_

![image](https://github.com/user-attachments/assets/9a9a8c9c-e82b-48c8-a057-925cf00ddd5b)


Use MOODLE_MLBACKEND_PYTHON_USERS environment var to set a list of users and password (comma-separated). 
The value is 'default:sshhhh' (user: default, password: sshhhh).


##1.2. mlbackend/php


