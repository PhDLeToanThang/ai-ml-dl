# Card GPU for AI/ML/DL

>> 1 Card NVIDIA A30 24GGPU mà cài và cắm chỉ trên 1 Server vSphere 7x / 8x thì có thể chia làm 4 phần tài nguyên Q để cho 4 VMs có được không ? ví dụ có giải pháp NVIDIA vGPU hoặc MIG nhưng cần có Driver NVIDIA vGPU?

Có thể chia 1 card NVIDIA A30 24GB GPU thành 4 phần tài nguyên để sử dụng cho 4 VMs trên vSphere 7.x / 8.x, nhưng cần chọn đúng chế độ vGPU hoặc MIG và cài đặt driver NVIDIA vGPU phù hợp2.

🔹 Các chế độ GPU có thể sử dụng:
✅ NVIDIA vGPU (Virtual GPU):

- Chia sẻ GPU theo cách động, giúp nhiều VMs sử dụng GPU cùng lúc.

- Bộ nhớ GPU được phân vùng cố định, nhưng tài nguyên tính toán được chia sẻ theo thời gian.

- Cần NVIDIA vGPU Manager cài trên vSphere ESXi và vGPU Driver trên từng VM.

✅ NVIDIA MIG (Multi-Instance GPU):

- Chia GPU thành các phần riêng biệt, mỗi VM có phần tài nguyên cố định.

- Bộ nhớ và nhân xử lý được phân vùng cứng, không chia sẻ theo thời gian.

- Phù hợp với AI, Machine Learning, nhưng không linh hoạt bằng vGPU.

🔹 Yêu cầu để triển khai vGPU hoặc MIG

📌 Cần cài đặt NVIDIA vGPU Manager trên ESXi để quản lý GPU.
 
📌 Cần driver NVIDIA vGPU trên từng VM để nhận diện GPU ảo hóa. 

📌 Kiểm tra license NVIDIA vGPU để đảm bảo tính năng hoạt động đầy đủ.

Tham khảo thêm tài liệu từ  NVIDIA AI Enterprise and NVIDIA vGPU (C-Series) https://docs.nvidia.com/ai-enterprise/release-6/latest/appendix/vgpu.html
-
MIG or vGPU Mode for NVIDIA Ampere GPU: Which One Should I Use? (Part 1 of 3)
https://blogs.vmware.com/performance/2021/09/mig-or-vgpu-part1.html
NVIDIA Ampere Architecture: https://www.nvidia.com/en-us/data-center/ampere-architecture/
NVIDIA Ampere GA102 GPU Architecture: https://www.nvidia.com/content/PDF/nvidia-ampere-ga-102-gpu-architecture-whitepaper-v2.pdf


# Thông số kỹ thuật:
🔹 Yêu cầu kỹ thuật để triển khai vGPU và MIG trên vSphere
Việc triển khai NVIDIA vGPU và MIG (Multi-Instance GPU) trên VMware vSphere 7.x / 8.x yêu cầu một số điều kiện kỹ thuật quan trọng, bao gồm license vSphere, license NVIDIA vGPU, driver MIG, và có thể cần VMware Appliance VM license nếu sử dụng các giải pháp như Bitfusion.

✅ 1. Yêu cầu về vSphere License

📌 VMware vSphere 7.x / 8.x cần có Enterprise Plus License để hỗ trợ vGPU và MIG. 

📌 vSphere 7 Update 1 trở lên hỗ trợ MIG, nhưng cần kiểm tra khả năng tương thích với GPU NVIDIA.
 
📌 VMware vCenter phải được cài đặt để quản lý tài nguyên GPU trên nhiều ESXi hosts.

🔹 Tham khảo chi tiết về vSphere và MIG tại đây.

✅ 2. Yêu cầu về NVIDIA vGPU License

📌 NVIDIA vGPU yêu cầu license phần mềm để kích hoạt tính năng chia sẻ GPU. 

📌 Các loại license phổ biến:

- NVIDIA AI Enterprise (cho AI/ML workloads).

- NVIDIA vGPU Standard (cho ứng dụng đồ họa).

- NVIDIA vGPU Compute (cho ứng dụng HPC và AI). 

📌 License vGPU có thể được quản lý thông qua NVIDIA License Server.

🔹 Chi tiết về NVIDIA vGPU License tại đây.

✅ 3. Yêu cầu về MIG Driver của NVIDIA

📌 MIG (Multi-Instance GPU) yêu cầu driver NVIDIA vGPU phiên bản R450 trở lên. 

📌 MIG hỗ trợ trên các GPU như A30, A100, H100, với các cấu hình phân vùng khác nhau. 

📌 MIG giúp chia GPU thành các phần riêng biệt, mỗi VM có tài nguyên cố định.

🔹 Hướng dẫn cài đặt MIG Driver tại đây.

✅ 4. Có cần VMware Appliance VM License như Bitfusion không?

📌 VMware Bitfusion là một giải pháp GPU virtualization, giúp chia sẻ GPU theo yêu cầu. 

📌 Bitfusion yêu cầu license riêng, nhưng không bắt buộc nếu chỉ dùng vGPU hoặc MIG. 

📌 Nếu muốn GPU-as-a-Service, Bitfusion có thể giúp tối ưu hóa tài nguyên GPU trên nhiều VMs.

🔹 Tổng kết

✅ vSphere Enterprise Plus License cần thiết để hỗ trợ vGPU/MIG. 

✅ NVIDIA vGPU License bắt buộc để kích hoạt chia sẻ GPU. 

✅ MIG Driver NVIDIA cần phiên bản R450+ để hoạt động trên vSphere. 

✅ VMware Bitfusion không bắt buộc, nhưng hữu ích nếu muốn GPU-as-a-Service.

VMware vSphere 7 with NVIDIA Multi-Instance GPUs (MIG) for Machine Learning Applications:
https://blogs.vmware.com/vsphere/2020/09/vmware-vsphere-7-u1-with-nvidia-multi-instance-gpus-mig-for-machine-learning-applications.html

vSphere 7 with Multi-Instance GPUs (MIG) on the NVIDIA A100 for Machine Learning Applications – Part 1: Introduction
https://blogs.vmware.com/apps/2020/09/vsphere-7-0-u1-with-multi-instance-gpus-mig-on-the-nvidia-a100-for-machine-learning-applications-part-1-introduction.html

Using GPUs with Virtual Machines on vSphere – Part 2: VMDirectPath I/O
https://blogs.vmware.com/apps/2018/09/using-gpus-with-virtual-machines-on-vsphere-part-2-vmdirectpath-i-o.html

vSphere 7 with Multi-Instance GPUs (MIG) on the NVIDIA A100 for Machine Learning Applications – Part 2 : Profiles and Setup
https://blogs.vmware.com/apps/2020/09/vsphere-7-0-u1-with-multi-instance-gpus-mig-on-the-nvidia-a100-for-machine-learning-applications-part-1-introduction.html

Using GPUs with Virtual Machines on vSphere – Part 3: Installing the NVIDIA Virtual GPU Technology
https://blogs.vmware.com/apps/2018/09/using-gpus-with-virtual-machines-on-vsphere-part-3-installing-the-nvidia-grid-technology.html

Using GPUs with Virtual Machines on vSphere – Part 4: Working with Bitfusion
https://blogs.vmware.com/apps/2018/10/using-gpus-with-virtual-machines-on-vsphere-part-4-working-with-bitfusion-flexdirect.html

Outline Architecture for MIG showing multiple GPU Instances on one physical GPU device Source: The NVIDIA MIG User Guide
https://docs.nvidia.com/datacenter/tesla/mig-user-guide/
