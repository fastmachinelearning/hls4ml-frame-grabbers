#ifndef CUSTOMLOGIC_H_
#define CUSTOMLOGIC_H_
#include <stdio.h>
#include "ap_int.h"

typedef struct Metadata_struct {
    unsigned char StreamId;
    unsigned short SourceTag;
    ap_int<24>     Xsize;
    ap_int<24>     Xoffs;
    ap_int<24>     Ysize;
    ap_int<24>     Yoffs;
    ap_int<24>     DsizeL;
    unsigned short PixelF;
    unsigned short TapG;
    unsigned char Flags;
    unsigned int Timestamp;
	unsigned char PixProcessingFlgs;
	unsigned int ModPixelF;
	unsigned int Status;
} Metadata_t;

typedef ap_uint<8> pixMono8;
#define MONO8PIX_NBR 32
#define MONO8PIX(j) Data((8*(j))+7,(8*(j)))
#define MONO8INDEXPIX(j) ((8*(j))+7,(8*(j)))

typedef ap_uint<MONO8PIX_NBR*8> DataMono8;
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
	DataMono8 Data;
	ap_uint<4> User;
} video_if_t;

typedef struct pix_fmt_mono8{
	unsigned char Pixel[MONO8PIX_NBR];
}Mono8;

#endif 
