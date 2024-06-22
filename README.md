### Getting Started

A tutorial and reference design for machine learning inference on FPGA-based frame grabber devices in high-throughput imaging applications. This tutorial leverages the hls4ml package and the CustomLogic toolkit to deploy neural networks to Euresys frame grabber devices. Refer to ```hls4ml-frame-grabber-tutorial.ipynb``` to get started. See ```part9_YOLO_frame_grabbers.ipynb``` for a more advanced guide on implementing a YOLO-style model and taking advantage of the suite of optimizations hls4ml provides.


To install ```hls4ml_frame_grabber``` conda environment

- ```conda env create -f environment.yml```

- ```conda activate hls4ml_frame_grabber```

- ```ipython kernel install --user --name=hls4ml_frame_grabber```


### Acknowledgement

Primary development was completed by Fermi National Accelerator Laboratory and Northwestern University. This work resulted from the implementation described in this paper: https://arxiv.org/abs/2312.00128. Deepest thanks to Euresys for their assistance in this development.