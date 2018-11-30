#!/usr/bin/env bash

CUDA_PATH=/usr/local/cuda/

python3 setup.py build_ext --inplace
rm -rf build

# Choose cuda arch as you need
CUDA_ARCH="-gencode arch=compute_30,code=sm_30 \
           -gencode arch=compute_35,code=sm_35 \
           -gencode arch=compute_50,code=sm_50 \
           -gencode arch=compute_52,code=sm_52 \
           -gencode arch=compute_60,code=sm_60 \
           -gencode arch=compute_61,code=sm_61 "
#          -gencode arch=compute_70,code=sm_70 "

# compile DCN
cd model/dcn/src
echo "Compiling dcn kernels by nvcc..."
nvcc -c -o deform_conv_cuda_kernel.cu.o deform_conv_cuda_kernel.cu -x cu -Xcompiler -fPIC -std=c++11
cd ../
CC=g++ python3 build.py

# compile NMS
cd ../../
cd model/nms/src
echo "Compiling nms kernels by nvcc..."
nvcc -c -o nms_cuda_kernel.cu.o nms_cuda_kernel.cu \
	 -D GOOGLE_CUDA=1 -x cu -Xcompiler -fPIC $CUDA_ARCH

cd ../
python3 build.py

# compile roi_pooling
cd ../../
cd model/roi_pooling/src
echo "Compiling roi pooling kernels by nvcc..."
nvcc -c -o roi_pooling.cu.o roi_pooling_kernel.cu \
	 -D GOOGLE_CUDA=1 -x cu -Xcompiler -fPIC $CUDA_ARCH
cd ../
python3 build.py

# # compile roi_align
# cd ../../
# cd model/roi_align/src
# echo "Compiling roi align kernels by nvcc..."
# nvcc -c -o roi_align_kernel.cu.o roi_align_kernel.cu \
# 	 -D GOOGLE_CUDA=1 -x cu -Xcompiler -fPIC $CUDA_ARCH
# cd ../
# python build.py

# compile roi_crop
cd ../../
cd model/roi_crop/src
echo "Compiling roi crop kernels by nvcc..."
nvcc -c -o roi_crop_cuda_kernel.cu.o roi_crop_cuda_kernel.cu \
	 -D GOOGLE_CUDA=1 -x cu -Xcompiler -fPIC $CUDA_ARCH
cd ../
python3 build.py

# compile Poolpointsinterp
cd ../../
cd model/pool_points_interp/src
echo "Compiling pool points interp kernels by nvcc..."
nvcc -c -o pool_points_interp_kernel.cu.o pool_points_interp_kernel.cu \
     -D GOOGLE_CUDA=1 -x cu -Xcompiler -fPIC $CUDA_ARCH
cd ../
python3 build.py

# compile roi_align (based on Caffe2's implementation)
cd ../../
cd modeling/roi_xfrom/roi_align/src
echo "Compiling roi align kernels by nvcc..."
nvcc -c -o roi_align_kernel.cu.o roi_align_kernel.cu \
	 -D GOOGLE_CUDA=1 -x cu -Xcompiler -fPIC $CUDA_ARCH
cd ../
python3 build.py

# compile roi_mask_align (based on Caffe2's implementation and py-RFCN-priv's implementation)
cd ../
cd roi_mask_align/src
echo "Compling roi mask align kernels by nvcc..."
nvcc -c -o roi_mask_align_kernel.cu.o roi_mask_align_kernel.cu \
         -D GOOGLE_CUDA=1 -x cu -Xcompiler -fPIC $CUDA_ARCH
cd ../
python3 build.py
