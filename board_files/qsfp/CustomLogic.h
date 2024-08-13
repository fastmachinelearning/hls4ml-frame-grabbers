#ifndef CUSTOMLOGIC_H_
#define CUSTOMLOGIC_H_
#include <stdio.h>
#include "ap_int.h"
#include "ap_fixed.h"
#include "defines.h"

#define PIXEL_FORMAT  // CustomLogic: INSERT PIXEL FORMAT. VALID VALUES: 8,16

#define NORM_DIV  // CustomLogic: INSERT NORMALIZATION DIVISOR

#define IMAGE_WIDTH  // CustomLogic: INSERT ACQUISITION FRAME WIDTH
#define IMAGE_HEIGHT  // CustomLogic: INSERT ACQUISITION FRAME HEIGHT
#define CROP_START_X  // CustomLogic: INSERT ACQUISITION CROP START X COORDINATE (FROM TOP LEFT)
#define CROP_START_Y  // CustomLogic: INSERT ACQUISITION CROP START Y COORDINATE (FROM TOP LEFT)
#define CROP_WIDTH  // CustomLogic: INSERT DESIRED CROP WIDTH 
#define CROP_HEIGHT  // CustomLogic: INSERT DESIRED CROP HEIGHT

#define BLOCK_HEIGHT  // CustomLogic: INSERT BLOCK HEIGHT PARAMETER FROM EGRABBER

#define STREAM_DATA_WIDTH 256 // DO NOT CHANGE

typedef struct Metadata_struct {
  unsigned char   StreamId;
  unsigned short  SourceTag;
  ap_int<24>      Xsize;
  ap_int<24>      Xoffs;
  ap_int<24>      Ysize;
  ap_int<24>      Yoffs;
  ap_int<24>      DsizeL;
  unsigned short  PixelF;
  unsigned short  TapG;
  unsigned char   Flags;
  unsigned int    Timestamp;
  unsigned char   PixProcessingFlgs;
  unsigned int    ModPixelF;
  unsigned int    Status;
} Metadata_t;


typedef ap_uint<PIXEL_FORMAT> pixMono;
#define MONOPIX_NBR (STREAM_DATA_WIDTH/PIXEL_FORMAT)
#define MONOPIX(j) Data((PIXEL_FORMAT*(j))+(PIXEL_FORMAT-1),(PIXEL_FORMAT*(j)))
#define MONOINDEXPIX(j) ((PIXEL_FORMAT*(j))+(PIXEL_FORMAT-1),(PIXEL_FORMAT*(j)))
typedef nnet::array<input_t::value_type, MONOPIX_NBR> input_arr_t;
typedef ap_uint<MONOPIX_NBR*PIXEL_FORMAT> DataMono;
typedef ap_uint<4> User;

#define SOF User(0,0)==1
#define nSOF User(0,0)==0
#define SOL User(1,1)==1
#define nSOL User(1,1)==0
#define EndOL User(2,2)==1
#define nEndOL User(2,2)==0
#define EndOF User(3,3)==1
#define nEndOF User(3,3)==0

typedef struct video_struct{
  DataMono Data;
  ap_uint<4> User;
} video_if_t;

typedef struct pix_fmt_mono{
  unsigned char Pixel[MONOPIX_NBR];
}Mono;

static const unsigned PACKED_DEPTH =  ((IMAGE_WIDTH * IMAGE_HEIGHT) / MONOPIX_NBR);
static const unsigned UNPACKED_DEPTH = (CROP_WIDTH * CROP_HEIGHT);
static const unsigned NUM_STRIPES = IMAGE_HEIGHT/(BLOCK_HEIGHT/2); // Number of stripes in image
static const unsigned stripe_order[NUM_STRIPES] = /* CustomLogic: INSERT STRIPE ORDER HERE */ ; 
static const unsigned STRIPE_HEIGHT = BLOCK_HEIGHT/2; // Stripe height in pixels
static const unsigned PACKETS_PER_IMAGE = (IMAGE_HEIGHT * IMAGE_WIDTH) / MONOPIX_NBR; // Number of CoaXPress packets per image
static const unsigned PACKETS_PER_STRIPE = ((IMAGE_HEIGHT * IMAGE_WIDTH) / MONOPIX_NBR) / (IMAGE_HEIGHT/(BLOCK_HEIGHT/2)); // Number of CoaXPress packets per stripe

#endif 
