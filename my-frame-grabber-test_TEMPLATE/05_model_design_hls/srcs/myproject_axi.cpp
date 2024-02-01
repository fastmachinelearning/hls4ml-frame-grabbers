#include "myproject_axi.h"


/**
 * @brief Process metadata
 * 
 * @param MetaIn Metadata input struct
 * @return Metadata_t 
 */
Metadata_t meta_data_proc(Metadata_t MetaIn){
  static Metadata_t MetaTmp;
  MetaTmp = MetaIn;
  return MetaTmp;
}

/**
 * @brief Top level HLS function
 * 
 * @param VideoIn CustomLogic input stream
 * @param VideoOut CustomLogic output stream
 * @param MetaIn Metadata input
 * @param MetaOut Metadata output
 * @param ModelOutLast Final model output, used for benchmarking
 */
void myproject_axi(hls::stream<video_if_t> &VideoIn, hls::stream<video_if_t> &VideoOut,
         Metadata_t* MetaIn, Metadata_t* MetaOut, result_t::value_type &ModelOutLast) {

  #pragma HLS INTERFACE ap_vld register port=ModelOutLast

  // Set proper interface for CustomLogic
  #pragma HLS INTERFACE ap_none port=MetaOut
  #pragma HLS INTERFACE ap_vld register port=MetaIn
  // Meta Data valid signal needs to be connect on VideoIn AXI-Stream valid signal
  #pragma HLS INTERFACE axis depth=0 port=VideoIn
  #pragma HLS INTERFACE axis port=VideoOut

  (*MetaOut) = meta_data_proc((*MetaIn));

  // Call neural network
  myproject(VideoIn, VideoOut, ModelOutLast);

}