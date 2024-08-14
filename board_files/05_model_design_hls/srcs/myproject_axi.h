#ifndef MYPROJECT_AXI_H_
#define MYPROJECT_AXI_H_

#include "CustomLogic.h"
#include <iostream>
#include <fstream>
#include "ap_int.h"
#include "hls_stream.h"
#include "nnet_utils/nnet_helpers.h"
#include "nnet_utils/nnet_stream.h"
#include "myproject.h"

Metadata_t meta_data_proc(Metadata_t MetaIn);

void myproject_axi(hls::stream<video_if_t> &VideoIn, hls::stream<video_if_t> &VideoOut,
				 Metadata_t* MetaIn, Metadata_t* MetaOut, result_t::value_type &ModelOutFirst);

#endif




