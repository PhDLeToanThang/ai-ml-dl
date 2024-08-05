# Ai-ML-DL (AI / Machine Learning / Deep Learn)

## Phần 1. Dựng AI trên Local Windows PC:
Cach cai LLama + python 3.10.6 stable-diffusion-webgui (no gpu): Goi cai python 3.10.6  https://www.python.org/downloads/release/python-3106/
B1. Download vs install git for windows
https://git-scm.com/download/win

B2. Install python-3.10.6 from link:
 https://www.python.org/downloads/release/python-3106/
 https://www.python.org/ftp/python/3.10.6/python-3.10.6-amd64.exe

https://www.python.org/ftp/python/3.12.4/python-3.12.4-arm64.exe (no support, no download)

Downoad ve thu muc c:\ai va cai C:\Python310

python -m pip install --upgrade pip

B3. Download clone vao thu muc Local c:\ai   
cd c:\ai
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
Luu y: dung VPN keet noi git clone hay bi loi timeout, nen dung internet ket noi.

B4. Truy cap trang github repository ckpt link
https://huggingface.co/runwayml/stable-diffusion-v1-5
Download ve file: https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.ckpt   (- 4.27GB, ema-only weight. uses less VRAM - suitable for inference)

va https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned.ckpt (ema+non-ema weights. uses more VRAM - suitable for fine-tuning)

luu ve C:\ai\stable-diffusion-webui\models\Stable-diffusion\ 
								+ v1-5-pruned-emaonly.ckpt
								+ v1-5-pruned.ckpt


B5. Mo bang notepad++ sua file C:\ai\stable-diffusion-webui\webui-user.bat

@echo off
set PYTHON=
set GIT=
set VENV_DIR=
set COMMANDLINE_ARGS=--lowvram --precision full --no-half --skip-torch-cuda-test
call webui.bat


Sau khi them doan tham so phia sau set COMMANDLINE_ARGS=--lowvram --precision full --no-half --skip-torch-cuda-test
Tham khao: https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Command-Line-Arguments-and-Settings
Chung ta cho chay file bat:
c:\ai\stable-diffusion-webui>webui-user.bat  (click thang vao file nay cho chay)

----> errror:
Looking in indexes: https://pypi.org/simple, https://download.pytorch.org/whl/cu121
ERROR: Could not find a version that satisfies the requirement torch==2.1.2 (from versions: 2.2.0, 2.2.0+cu121, 2.2.1, 2.2.1+cu121, 2.2.2, 2.2.2+cu121, 2.3.0, 2.3.0+cu121, 2.3.1, 2.3.1+cu121, 2.4.0, 2.4.0+cu121)
ERROR: No matching distribution found for torch==2.1.2

pip install torch==2.1.2 torchvision==0.16.2 --extra-index-url https://download.pytorch.org/whl/cu121"
--> pip install torch torchvision --extra-index-url https://download.pytorch.org/whl/cu121"

Successfully installed MarkupSafe-2.1.5 filelock-3.15.4 fsspec-2024.6.1 jinja2-3.1.4 mpmath-1.3.0 networkx-3.3 numpy-2.0.1 pillow-10.4.0 setuptools-72.1.0 sympy-1.13.1 torch-2.4.0+cu121 torchvision-0.19.0+cu121 typing-extensions-4.12.2

-- Doi voi Windows C:\ai\stable-diffusion-webui\venv\pyvenv.cfg
can cai ban python3.10.6 va sua cau hinh thanh:
home = C:\Python310
include-system-site-packages = false
version = 3.10.6
executable = C:\Python310\python.exe
command = C:\Python310\python.exe -m venv c:\ai\stable-diffusion-webui\venv

-----------
python -m pip install torch==2.1.2 torchvision==0.16.2
python -m pip install torch==2.3.1 torchvision==0.18.1

export COMMANDLINE_ARGS="--skip-torch-cuda-test --upcast-sampling --no-half-vae --use-cpu interrogate"




-------------  Here's how I fixed it: dung cho Ubuntu 20/22/24.04:
https://github.com/AUTOMATIC1111/stable-diffusion-webui/issues/15667

sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt install python-3.11-venv
sudo apt install python3.10 python3.10-venv python3.10-dev 

source venv/bin/activate
cd venv
Change symlinks in bin/
By default, the python, python3 binaries are actually just symlinks to /usr/bin/python3, which will be 3.12 in Ubuntu 24.04. Install version 3.10 and use ln -sf /path/to/new/3.10 python on both binaries.
Ensure pip using python -m ensurepip
Run webui.sh
---------------
pip install torch torchvision torchaudio
Currently, PyTorch on Windows only supports Python 3.8-3.11; Python 2.x is not supported. Source (https://pytorch.org/get-started/locally/#windows-python)

You need to downgrade your python to 3.11 as @Dr.Snoopy commented.
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118  (https://download.pytorch.org/whl/cu121)



## Phần 2. Cách dựng ML trên Local Ubuntu Server: 
-Cai OLLAMA in windows: Xây dựng ChatGPT trên Local Python Jupyter để Chatbot FAQ:

https://github.com/PhDLeToanThang/BA_DA_CI-CD_copilot/wiki/Ch%C6%B0%C6%A1ng-4_Trang-1_X%C3%A2y-d%E1%BB%B1ng-ChatGPT-tr%C3%AAn-Local-Python-Jupyter-%C4%91%E1%BB%83-Chatbot-FAQ

Ollama - Llama 3 how to install more model: If you're opening this Notebook on colab, you will probably need to install LlamaIndex.
!pip install llama-index-llms-ollama

!pip install llama-index

##############################################################
##  What's new Python 3.12.3 with OLLAMA in Ubuntu 24.04    ##
##############################################################

!/bin/bash -e

# Phần 1. Các bước cài Python trên Unix/Linux OS: 
## Install Ollama:
## Open a terminal on your Ubuntu server.
## Run the following command to install Ollama: 

curl -fsSL [^1^][4] | sh

## This will download and install Ollama along with its supported open-source language models.

## Verify Installation:

## Confirm that Ollama is installed by running 

## in the terminal.
ollama --version 

## You should see the version information if the installation was successful.

## Run Language Models:

## Use Ollama to download and run specific language models. For example:

## To run the Mistral 7B model, use: ollama run Mistral

## Explore other models supported by Ollama as needed.

# Phần 2- Optional: Web Interface (Open WebUI):
## If you prefer a web-based interface, you can install Ollama WebUI:
## Install Snapd (if not already installed):

sudo apt update && sudo apt install snapd -y

## Install Ollama WebUI: 
sudo snap install ollama-webui --beta
## Access the WebUI at http://localhost:8080/auth/ in your browser.

# Phần 3-Install model ollama3
snap install ollama
ollama pull llama3
## ref: https://github.com/ollama/ollama/blob/main/README.md#import-from-gguf
## list models on ollama: https://ollama.com/library

ollama pull medllama2
ollama pull sqlcoder
ollama pull gemma:7b

## https://ollama.com/library/sqlcoder
## https://ollama.com/library/medllama2
## curl -X POST http://localhost:11434/api/generate -d '{
##  "model": "medllama2",
##  "prompt":"A 35-year-old woman presents with a persistent dry cough, shortness of breath, and fatigue. She is initially suspected of having asthma, but her spirometry results do not improve with bronchodilators. What could be the diagnosis?"
## }'
