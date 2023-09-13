FROM public.ecr.aws/lambda/python:3.10

WORKDIR /opt

RUN pip3 install torch

RUN pip install openmim && \
    mim install "mmengine>=0.7.1" "mmcv>=2.0.0rc4"

RUN yum install -y git
RUN git clone https://github.com/open-mmlab/mmdetection.git
WORKDIR /opt/mmdetection
RUN pip3 install --no-cache-dir -e .

RUN yum install -y tar
RUN yum install -y mesa-libGL.x86_64

RUN mkdir -p /opt/mmdetection/checkpoints
RUN mim download mmdet --config yolox_l_8x8_300e_coco --dest /opt/mmdetection/checkpoints

COPY *.py /opt/mmdetection

CMD ["sh"]