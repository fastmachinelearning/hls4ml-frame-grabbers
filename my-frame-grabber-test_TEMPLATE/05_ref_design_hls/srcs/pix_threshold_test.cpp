#include <stdio.h>
#include "CustomLogic.h"
#include "pix_threshold.h"

int main(int argc, char *argv[])
{
	unsigned int i,j,k,l;
	unsigned err_cnt = 0, check_dots = 0;
	hls::stream<video_if_t> in_stream("InputDataStream");
	hls::stream<video_if_t> out_stream;
	video_if_t tmp;
	Metadata_t in_meta;
	Metadata_t out_meta;

	in_meta.Timestamp = 1;

	Mono8 *buf_in;
	buf_in = (Mono8*)(&(tmp.Data));

	// Test parameters
	int NbrOfFrame = 4;
	bool SOFEOFSyncToLine = false;
	bool printInFrame = true;
	bool printOutFrame = false;


	// Construct to images
	for (l=0;l<NbrOfFrame;l++) {
		int line_cnt = 0;
		printf("Construct frame %d\r\n", l);
		if (!SOFEOFSyncToLine) {
			for (k=0; k<5;k++) {
				if (k == 0) {
					// SOF not sync with SOL
					tmp.User = 1;
					tmp.Data = 0;
					in_stream << tmp;
				}
				if (k>0 && k<5) {
					// blanking pixel
					tmp.User = 0;
					tmp.Data = 0;
					in_stream << tmp;
				}
				if (printInFrame) {
					// Print control signal
					if (tmp.User(0,0) == 1)
						printf(" SOF ");
				}
			}
		}
		// for each line
		for (k=5;k<251;k++) {
			if (k>=5 && k<=250) {
				i = 0;
				while(i < 1920) {
					tmp.User = 0;
					// Set SOL
					if (i == 0) {
						tmp.User(1,1) = 1;
						line_cnt++;
						if (SOFEOFSyncToLine && k==5)
							tmp.User(0,0) = 1;
					}
					// Print source images data
					if (printInFrame) {
						if (tmp.User(0,0) == 1)
							printf(" SOF ");
						if (tmp.User(1,1) == 1)
							printf(" SOL ");
						printf("%d",(i & 0xff));
					}
					for (j=0; j<MONO8PIX_NBR; j++) {
						(*buf_in).Pixel[j] = (i & 0xFF);
						i++;
					}
					// Set EOL
					if (i>=1920) {
						tmp.User(2,2)=1;
						if (SOFEOFSyncToLine && k==250)
							tmp.User(3,3)=1;
					}
					in_stream << tmp;
				}
			}
			if (printInFrame) {
				// Print control signal
				if (tmp.User(0,0) == 1)
					printf(" SOF ");
				if (tmp.User(2,2) == 1)
					printf(" EOL ");
				if (tmp.User(3,3) == 1)
					printf(" EOF ");
				printf("\r\n");
			}
		}
		if (!SOFEOFSyncToLine) {
			for (k=251; k<256;k++) {
				if (k>250 && k<255) {
					// blanking pixel
					tmp.User = 0;
					tmp.Data = 0;
					in_stream << tmp;
				}
				if (k==255) {
					// EOF not sync with EOL
					tmp.User = 8;
					tmp.Data = 0;
					in_stream << tmp;
				}
				if (printInFrame) {
					// Print control signal
					if (tmp.User(3,3) == 1)
						printf(" EOF ");
					printf("\r\n");
				}
			}
		}
		// print number of line in the image
		printf("Line counter : %d\r\n", line_cnt);
	}

	// Start testing function
	printf("Testing DUT results\r\n");
	// For all images available
	for (l=0;l<NbrOfFrame-1;l++) {
		printf("Check pix_threshold on frame %d\r\n",l);
		if (!in_stream.empty())
			pix_threshold(in_stream, out_stream, &in_meta, &out_meta, 128);
		printf("Out empty %d\r\n", out_stream.empty() ? 1 : 0);
		printf("Meta_timestamp, in: %d, out: %d", in_meta.Timestamp, out_meta.Timestamp);
		in_meta.Timestamp += 1;
		// Check resulting output stream
		int line_cnt = 0;
		do{
			i = 0;
			// Print output data
			if (printOutFrame) {
				out_stream >> tmp;
				i++;
				j=0;
				if (tmp.User(0,0) == 1)
					printf(" SOF ");
				if (tmp.User(1,1) == 1) {
					printf(" SOL ");
					line_cnt++;
				}
				//for (j=0;j<16;j++) {
					std::cout << tmp.Data((8*j)+7,(8*j)) <<" ";
				//}

				if (tmp.User(2,2) == 1)
					printf(" EOL\r\n");
				if (tmp.User(3,3) == 1)
					printf(" EOF\r\n");
				if (tmp.User(3,3)==1) {
					printf("Finish at %d\r\n",i);
					break;
				}
			}
			else{
				out_stream >> tmp;
				if (tmp.User(1,1) == 1) {
					line_cnt++;
					do{
						for (j=0; j<16; j++) {
							buf_in = (Mono8*)(&(tmp.Data));
							/*
							//Check pixel value here
							if ((*buf_in).Pixel[j] != (i & 0xff)) {
								printf("Not inverted ");
								printf("Result %d -- Expected %d\r\n", (*buf_in).Pixel[j], (i&0xff));
								err_cnt++;
							}*/
							i++;
						}
						if (tmp.nEndOL)
							out_stream >> tmp;
					}while(i<1920);
				}
			}
		}while(tmp.User(3,3)==0);
		printf("Line counter : %d\r\n", line_cnt);
	}

	// Check if input stream is empty
	if (!in_stream.empty())
		printf("InStream not empty\r\n");
	bool frameStart;
	// If input stream is not empty check for presence of images
	while(!in_stream.empty()) {
		in_stream >> tmp;
		if (tmp.SOF) {
			frameStart = true;
			printf("Start of frame\r\n");
		}
		if (tmp.EndOF) {
			if (!frameStart) err_cnt++;
			printf("End of frame\r\n");
		}
	}
	printf("\r\n");

	// Print final status message
	if (err_cnt) {
		printf("!!! TEST FAILED - %d errors detected !!!\n", err_cnt);
	} else
		printf("*** Test Passed ***\n");

	// Only return 0 on success
	if (err_cnt)
		return 1;
	else
		return 0;
}
