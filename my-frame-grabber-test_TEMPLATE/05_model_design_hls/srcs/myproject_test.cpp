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
#include <fstream>
#include <iostream>
#include <algorithm>
#include <vector>
#include <map>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "myproject_axi.h"
#include "nnet_utils/nnet_helpers.h"

#define LIMIT 20

namespace nnet {
bool trace_enabled = false;
std::map<std::string, void *> *trace_outputs = NULL;
size_t trace_type_size = sizeof(double);
} // namespace nnet

unsigned find_index(unsigned target) {
    for (unsigned i = 0; i < NUM_STRIPES; i++) {
      if (stripe_order[i] == target) {
          return i;
      }
    }
    assert(0 && "Ensure stripe order is correctly calculated and defined.");
}

void reorder_stripes(hls::stream<video_if_t> &VideoInOrdered, hls::stream<video_if_t> &VideoIn){

  hls::stream<video_if_t> VideoInOrderedArr[NUM_STRIPES];

  // Construct and stream raw image to CoaxPress input in unordered pattern
  for(unsigned i = 0; i < IMAGE_HEIGHT; i++){
    for(unsigned j = 0; j < IMAGE_WIDTH / MONOPIX_NBR; j++){
      video_if_t data_packet;
      VideoInOrdered >> data_packet;
      VideoInOrderedArr[find_index(i/STRIPE_HEIGHT)] << data_packet;
    }
  }

  // Attach TUSER side-band info.
  for(unsigned i = 0; i < IMAGE_HEIGHT; i++){
    for(unsigned j = 0; j < IMAGE_WIDTH / MONOPIX_NBR; j++){
      video_if_t data_packet;
      VideoInOrderedArr[i/STRIPE_HEIGHT] >> data_packet;

      if(i == 0 && j == 0){ // start of frame, start of line
        data_packet.User = 0b0011;
      }else if(j == 0){ // start of line
        data_packet.User = 0b0010;
      }else if(i == (IMAGE_HEIGHT - 1) && j == ((IMAGE_WIDTH / MONOPIX_NBR) - 1)){ // end of frame, end of line
        data_packet.User = 0b1100; 
      }else if(j == ((IMAGE_WIDTH / MONOPIX_NBR) - 1)){ // end of line
        data_packet.User = 0b0100;
      }

      VideoIn << data_packet;
    }
  }  
}

// Copy testbench data to model input
void copy_image_data(std::vector<float> in, hls::stream<video_if_t> &VideoInOrdered){
  // #ifndef __SYNTHESIS__
  //   std::cout << "\n\nCaptured Image: \n";
  // #endif

  // Construct and stream raw image to CoaxPress input
  for(unsigned i = 0; i < IMAGE_HEIGHT; i++){
    for(unsigned j = 0; j < IMAGE_WIDTH / MONOPIX_NBR; j++){
      DataMono data_packet;

      // Pack pixels
      for(unsigned k=0; k < MONOPIX_NBR; k++){
        pixMono pixel_in = (pixMono)(in[(i*(IMAGE_WIDTH / MONOPIX_NBR) * MONOPIX_NBR) + (j*MONOPIX_NBR) + k]);
        data_packet.range((k * pixMono::width) + (pixMono::width - 1), k * (pixMono::width)) = pixel_in.range(pixMono::width - 1, 0);

        // #ifndef __SYNTHESIS__
        //   std::cout << pixel_in << " ";
        // #endif
      }

      video_if_t video_packet_in = {data_packet, 0};
      VideoInOrdered << video_packet_in;
    }
  }
}


int main(int argc, char **argv)
{

  //load input data from text file
  std::ifstream fin("../../../../tb_data/tb_input_features.dat");
  std::ifstream fpr("../../../../tb_data/tb_output_predictions.dat");

  std::ofstream fout("../../../../tb_data/csim_results.log");
  if (!fout.is_open()) {
      std::cerr << "Error opening prediction file." << std::endl;
      exit(1);
  }
  fout.close();

  std::string iline;
  int e = 0;

  if (fin.is_open()) {
    while ( std::getline(fin,iline)) {
      std::cout << "Processing input " << e << std::endl;
      char* cstr=const_cast<char*>(iline.c_str());
      char* current;
      std::vector<float> in;
      current=strtok(cstr," ");
      while(current!=NULL) {
        in.push_back(atof(current));
        current=strtok(NULL," ");
      }

      hls::stream<video_if_t> VideoInOrdered("VideoInOrdered");
      hls::stream<video_if_t> VideoOut("VideoOut");
      copy_image_data(in, VideoInOrdered);

      hls::stream<video_if_t> VideoIn("VideoIn");
      reorder_stripes(VideoInOrdered, VideoIn); // Reorder image stripes to replicate the order in which they come out of the camera

      Metadata_t MetaIn;
      Metadata_t MetaOut;
      result_t::value_type ModelOutFirst; // Packed model output

      myproject_axi(VideoIn, VideoOut, &MetaIn, &MetaOut, ModelOutFirst); // Instantiate neural network
          
      // std::cout << "\n\nReceived Image: \n";
      video_if_t video_packet_out;
      for(unsigned i = 0; i < IMAGE_HEIGHT; i++){
        for(unsigned j = 0; j < IMAGE_WIDTH / MONOPIX_NBR; j++){
          VideoOut >> video_packet_out;
          for(unsigned k = 0; k < MONOPIX_NBR; k++){
            pixMono pixel_out; 
            pixel_out.range(pixMono::width - 1, 0) = video_packet_out.MONOPIX(k);
            // std::cout << pixel_out << " ";
          }
        }
      }
    
      if(e == LIMIT-1) break;

      e++;
    }
    fin.close();
    fpr.close();
  }

  return 0;
}
