//
//    rfnoc-hls-neuralnet: Vivado HLS code for neural-net building blocks
//
//    Copyright (C) 2017 EJ Kreinar
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
#include <iostream>

#include "myproject.h"
#include "parameters.h"


/**
 * @brief Unpacks image data and crops image. Forwards ROI to model input.
 * 
 * @param input_arr_split_reordered reordered camera data stream
 * @param input_1 model input stream
 */
void unpack_data(hls::stream<input_arr_t> (&input_arr_split_reordered)[NUM_STRIPES], hls::stream<input_t> &input_1){

  assert(((CROP_START_X >= 0) && (CROP_START_X <= IMAGE_WIDTH) && ((CROP_START_X + CROP_WIDTH) <= IMAGE_WIDTH) && (CROP_START_Y >= 0) && (CROP_START_Y <= IMAGE_HEIGHT) && ((CROP_START_Y + CROP_HEIGHT) <= IMAGE_HEIGHT)) && "CustomLogic: Your crop region must be inside the image!");
  
  unsigned curr_X = 0; // Current x position relative to raw image
  unsigned curr_Y = 0; // Current y position relative to raw image
  input_t temp_in; // NN input sample

  // #ifndef __SYNTHESIS__
  //   std::cout << "\n\nCropped Normalized Model Input: \n";
  // #endif

  InputSplitLoop: // Split input into stripe arrangement, this is inherent to the camera readout
  for(unsigned i = 0; i < PACKETS_PER_IMAGE; i++){
    #pragma HLS PIPELINE
    input_arr_t temp_arr_in = input_arr_split_reordered[curr_Y / STRIPE_HEIGHT].read(); // Read CoaxPress packet

    // Check if current packet holds any portion of the desired crop region
    if(((curr_X + MONOPIX_NBR) >= CROP_START_X) && (curr_X < (CROP_START_X + CROP_WIDTH)) && (curr_Y >= CROP_START_Y) && (curr_Y < (CROP_START_Y + CROP_HEIGHT))){

      unsigned rel_START_X; // Relative x start position within current packet which holds part of the desired crop region
      unsigned rel_END_X;   // Relative x end position

      if(curr_X < CROP_START_X){
        rel_START_X = CROP_START_X - curr_X;
      }else{
        rel_START_X = 0;
      }

      if((curr_X + MONOPIX_NBR) > (CROP_START_X + CROP_WIDTH)){
        rel_END_X = (CROP_START_X + CROP_WIDTH) - curr_X;
      }else{
        rel_END_X = MONOPIX_NBR;
      }

      // Unpack pixels and write to the NN input stream
      UnpackLoop:
      for(int j = rel_START_X; j < rel_END_X; j++){
        #pragma HLS UNROLL
        temp_in[0] = temp_arr_in[j];
        input_1.write(temp_in);

        // #ifndef __SYNTHESIS__
        //   std::cout << temp_arr_in[j] << " ";
        // #endif
      }
    }

    // Track position in frame
    if(curr_X == (IMAGE_WIDTH - MONOPIX_NBR)){
      curr_X = 0;
      curr_Y++;
    }else{
      curr_X = curr_X + MONOPIX_NBR;
    }
  }
}


/**
 * @brief Reads and duplicates CoaxPress image data into buffer and model input stream 
 * 
 * @param VideoIn CustomLogic input data stream from camera
 * @param VideoBuffer Buffer to attach predictions and forward to host
 */
void read_pixel_data(hls::stream<video_if_t> &VideoIn, hls::stream<video_if_t> &VideoBuffer, hls::stream<input_arr_t> (&input_arr_split_reordered)[NUM_STRIPES]){

  // Whether or not we're in the frame
  bool inFrame;

  static video_if_t DataBuf;
  //Latch meta data as received as input image is identical
  //in size and format to output image

  unsigned curr_Y = 0; // Current y position relative to raw image

  //Reset input control signal
  DataBuf.User = 0;
  FrameLoop:
  do {
    #pragma HLS PIPELINE
    bool InLine;

    //As long as the frame is not finish
    if (DataBuf.nEndOF) {
      //Read data
      VideoIn >> DataBuf; // Same as DataBuf = VideoIn.read()
      inFrame = true;
    } else{ // If frame has finished
      //If End of frame met, reset inFrame flag
      inFrame = false;
      // And forward EOF if not sync with EOL
      if (DataBuf.nEndOL) {
        // Forward EOF if not sync with EOL
        video_if_t output_buf;
        output_buf.Data = 0;
        output_buf.User = DataBuf.User;
        VideoBuffer << output_buf;
      }
    }
    // If Start of frame is detected without Start Of Line
    if (DataBuf.SOF && DataBuf.nSOL) {
      // Forward SOF if not sync with SOL
      VideoBuffer << DataBuf;
    }
    // If Line Start, do computation
    if (DataBuf.SOL) {

      WriteInLoop:
      do{
        #pragma HLS PIPELINE

        video_if_t output_buf;
        input_arr_t ctype;

        Process_pixel:
        for (unsigned char i = 0; i < MONOPIX_NBR; i++) {
          output_buf.MONOPIX(i) = DataBuf.MONOPIX(i);
          ctype[i] = ((ap_ufixed<32,pixMono::width>)DataBuf.MONOPIX(i)) / NORM_DIV; //Normalize pixel values and set input to model // TODO: Add functions for different methods of scaling.
        }

				// Set output control signal
				output_buf.User = DataBuf.User;
				//Store the result in the output stream
				VideoBuffer << output_buf;

        // Reorder image for input to model and write to output
        input_arr_split_reordered[stripe_order[curr_Y / STRIPE_HEIGHT]].write(ctype);

        // If line is not finish
        if (DataBuf.nEndOL) {
          //Keep reading
          InLine = true;
          VideoIn >> DataBuf;
        } else {
          InLine = false;
        }
      } while (InLine);
      
      curr_Y++;
    }
  } while (inFrame);
}


/**
 * @brief Insert neural network predictions to head of image output.
 * 
 * @param layer_out Model output stream
 * @param VideoBuffer Buffered image from camera
 * @param VideoOut CustomLogic output stream
 * @param ModelOutFirst Final model output, used to mark inference completion on TTL IO
 */
void attach_results(hls::stream<result_t> &layer_out, hls::stream<video_if_t> &VideoBuffer, hls::stream<video_if_t> &VideoOut){

  #ifndef __SYNTHESIS__
    std::ofstream fout("../../../../tb_data/csim_results.log", std::ios::app);
  #endif

  unsigned output_count = 0;

  static video_if_t DataOut;
  video_if_t output_buf;

  result_t temp;

  unsigned bits_left = STREAM_DATA_WIDTH;
  unsigned start_idx = result_t::value_type::width * result_t::size;
  bool overlap = false;

  for(unsigned i = 0; i < (IMAGE_HEIGHT * IMAGE_WIDTH) / MONOPIX_NBR; i++){
    #pragma HLS PIPELINE

    VideoBuffer >> DataOut;


    bits_left = STREAM_DATA_WIDTH;
  
    output_buf.User = DataOut.User;
    output_buf.Data = DataOut.Data;

    while(!layer_out.empty()){
      
      // Read new sample if there are no more bits to write
      if(!overlap){
        temp = layer_out.read();

        #ifndef __SYNTHESIS__
          for(unsigned i = 0; i < result_t::size; i++){
            std::cout << temp[i] << " ";
            fout << temp[i] << " ";
          }
        #endif

        output_count++;

        assert(((output_count * result_t::size * result_t::value_type::width) < (IMAGE_HEIGHT * IMAGE_WIDTH * pixMono::width)) && "CustomLogic: Your model output is too large!! The total size of your model output (in bits) is larger than the image."); // Check that size (in bits) of predictions are less than size of full image

        start_idx = result_t::value_type::width * result_t::size;
      }

      if(bits_left >= start_idx){ // If there is room to fit the entire model output in the current stream packet
        for(unsigned j = ((result_t::size-1) - ((start_idx-1) / result_t::value_type::width)); j < result_t::size; j++){
          #pragma HLS UNROLL
          if(j==0){
            output_buf.Data = (output_buf.Data << (((start_idx-1) % result_t::value_type::width)+1)) | temp[j].range((start_idx-1) % result_t::value_type::width, 0);
          }else{
            output_buf.Data = (output_buf.Data << (result_t::value_type::width)) | temp[j].range(result_t::value_type::width-1, 0);
          }
        }

        bits_left = bits_left - start_idx;
        overlap = false;
      }else{ // only bits_left bits left in current stream packet, but more bits in current model output

        for(unsigned j = 0; j < (((result_t::value_type::width * result_t::size) - bits_left) / result_t::value_type::width)+1; j++){
          #pragma HLS UNROLL
          if(j == (((result_t::value_type::width * result_t::size) - bits_left) / result_t::value_type::width)){
            output_buf.Data = (output_buf.Data << (bits_left % result_t::value_type::width)) | temp[j].range(result_t::value_type::width - 1, ((result_t::value_type::width * result_t::size) - bits_left) % result_t::value_type::width);
          }else{
            output_buf.Data = (output_buf.Data << result_t::value_type::width) | temp[j].range(result_t::value_type::width-1, 0);
          }
        }

        // start_idx = (result_t::value_type::width * result_t::size) - bits_left;
        start_idx = start_idx - bits_left;
        overlap = true;
        break;
      }
    }
    VideoOut << output_buf;
  }

  #ifndef __SYNTHESIS__
    std::cout << "\n";
    fout << "\n";
    fout.close();
  #endif
}

/**
 * @brief Send model output level to top level ap_vld for benchmarking
 * 
 * @param layer_out first result from model output stream
 * @param ModelOutFirst model output sample
 */
void benchmark_model(hls::stream<result_t> &layer_out, result_t::value_type &ModelOutFirst){
  ModelOutFirst = layer_out.read()[0];

  while(!layer_out.empty()){
    layer_out.read();
  }
}


/**
 * @brief network architecture and image stream processing 
 * 
 * @param VideoIn CustomLogic input stream
 * @param VideoOut CustomLogic output stream
 * @param ModelOutFirst Final model output, used for inference benchmarking
 */
void myproject(
    hls::stream<video_if_t> &VideoIn, 
    hls::stream<video_if_t> &VideoOut,
    result_t::value_type &ModelOutFirst // Output a model result so we can monitor inference latency
) {
    assert(((PIXEL_FORMAT == 8) || (PIXEL_FORMAT == 16)) && "CustomLogic: Pixel format must be set to 8 or 16 (for 12, set to 16)");

    assert((((IMAGE_HEIGHT * IMAGE_WIDTH * pixMono::width) % STREAM_DATA_WIDTH) == 0) && "CustomLogic: Your image size (in bits) must be a multiple of the stream depth (Octo: 128, Quad CXP-12: 256)");
    
    assert(((IMAGE_WIDTH % MONOPIX_NBR) == 0) && "CustomLogic: Your image width (in pixels) must be a multiple of the stream depth (in pixels, see value of MONOPIX_NBR)");
    
    assert(((IMAGE_HEIGHT % BLOCK_HEIGHT) == 0) && "CustomLogic: Block height must be a multiple of the image height");

    //hls-fpga-machine-learning insert IO
    #pragma HLS DATAFLOW 

    static const unsigned PACKED_DEPTH =  ((IMAGE_WIDTH * IMAGE_HEIGHT) / MONOPIX_NBR);
    static const unsigned UNPACKED_DEPTH = (CROP_WIDTH * CROP_HEIGHT);

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
    

    static const unsigned MODEL_OUT_DEPTH = /* CustomLogic: INSERT LAST NETWORK LAYER OUTPUT STREAM HERE */;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////


    hls::stream<result_t> layerfinal_out("layerfinal_out");
    #pragma HLS STREAM variable=layerfinal_out depth=MODEL_OUT_DEPTH

    hls::stream<result_t> layerfinal_out_cpy1("layerfinal_out_cpy1");
    #pragma HLS STREAM variable=layerfinal_out_cpy1 depth=MODEL_OUT_DEPTH

    hls::stream<result_t> layerfinal_out_cpy2("layerfinal_out_cpy2");
    #pragma HLS STREAM variable=layerfinal_out_cpy2 depth=MODEL_OUT_DEPTH

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
    

/* CustomLogic: INSERT MODEL WEIGHT LOAD STATEMENTS HERE */


/////////////////////////////////////////////////////////////////////////////////////////////////////////////

    hls::stream<input_arr_t> input_arr_split_reordered[NUM_STRIPES];

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
    

/* CustomLogic: INSESRT NETWORK SPLIT ARRAY HLS STREAM PRAGMAS HERE (from jupyter notebook) */


/////////////////////////////////////////////////////////////////////////////////////////////////////////////

    hls::stream<video_if_t> VideoBuffer; // Holds buffered unaltered image
    #pragma HLS STREAM variable=VideoBuffer depth=PACKED_DEPTH

    read_pixel_data(VideoIn, VideoBuffer, input_arr_split_reordered); // Read CoaXPress image data 

    hls::stream<input_t> input_1("input_1"); // Holds cropped image input to neural network
    #pragma HLS STREAM variable=input_1 depth=UNPACKED_DEPTH

    unpack_data(input_arr_split_reordered, input_1); // Crop image by unpacking only pixels which serve as input to model

/////////////////////////////////////////////////////////////////////////////////////////////////////////////


/* CustomLogic: INSESRT NEURAL NETWORK LAYERS HERE */


/////////////////////////////////////////////////////////////////////////////////////////////////////////////

    nnet::clone_stream<result_t, result_t, MODEL_OUT_DEPTH*result_t::size>(layerfinal_out, layerfinal_out_cpy1, layerfinal_out_cpy2); // Clone model output stream

    attach_results(layerfinal_out_cpy1, VideoBuffer, VideoOut); // Attach neural network predictions to image output

    benchmark_model(layerfinal_out_cpy2, ModelOutFirst); // Output one copy of model output to trigger ap_vld, enable easy benchmarking

}
