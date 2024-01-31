#include "pix_threshold.h"

using namespace hls;


void pix_threshold_proc(stream<video_if_t> &VideoIn,stream<video_if_t> &VideoOut, pixMono8 threshold_value){
	bool inFrame;
	// Latch threshold value
	pixMono8 threshold = threshold_value;
	
	static video_if_t DataBuf;
	//Latch meta data as received as input image is identical
	//in size and format to output image

	//Reset input control signal
	DataBuf.User = 0;
	FrameLoop:
	do {
	#pragma HLS PIPELINE
	#pragma HLS LOOP_TRIPCOUNT min=480 max=1080
		bool InLine;

		//As long as the frame is not finish
		if (DataBuf.nEndOF) {
			//Read data
			VideoIn >> DataBuf;
			inFrame = true;
		}
		else{
			//If End of frame met reset inFrame flag
			inFrame = false;
			// And forward EOF if not sync with EOL
			if (DataBuf.nEndOL) {
				// Forward EOF if not sync with EOL
				video_if_t output_buf;
				output_buf.Data = 0;
				output_buf.User = DataBuf.User;
				VideoOut << output_buf;
			}
		}
		// If Start of frame is detected without Start Of Line
		if (DataBuf.SOF && DataBuf.nSOL) {
			// Forward SOF if not sync with SOL
			VideoOut << DataBuf;
		}
		// If Line Start
		if (DataBuf.SOL) {
			do{
				#pragma HLS PIPELINE
				
				video_if_t output_buf;
				//Process pixels
				Process_pixels:
				for (unsigned char i=0; i<MONO8PIX_NBR; i++) {
					output_buf.MONO8PIX(i) = DataBuf.MONO8PIX(i)>=threshold ? 255 : 0;
				}
				// Set output control signal
				output_buf.User = DataBuf.User;
				//Store the result in the output stream
				VideoOut << output_buf;

				// If line is not finish
				if (DataBuf.nEndOL) {
					//Keep reading
					InLine = true;
					VideoIn >> DataBuf;
				} else InLine = false;
			} while (InLine);
		}
	} while (inFrame);
}

Metadata_t meta_data_proc(Metadata_t MetaIn){
	static Metadata_t MetaTmp;
	MetaTmp = MetaIn;
	return MetaTmp;
}

void pix_threshold(stream<video_if_t> &VideoIn,stream<video_if_t> &VideoOut,
				 Metadata_t *MetaIn,Metadata_t *MetaOut, pixMono8 threshold_value) {

	// Set proper interface for CustomLogic
	#pragma HLS INTERFACE ap_none port=MetaOut
	#pragma HLS INTERFACE ap_none port=threshold_value
	#pragma HLS INTERFACE ap_vld register port=MetaIn
	// Meta Data valid signal needs to be connect on VideoIn AXI-Stream valid signal
	#pragma HLS INTERFACE axis depth=0 port=VideoIn
	#pragma HLS INTERFACE axis port=VideoOut

	(*MetaOut) = meta_data_proc((*MetaIn));
	pix_threshold_proc(VideoIn, VideoOut, threshold_value);
}
