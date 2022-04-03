/***********************************************************************
 *
 * Program: readmar345	read an image in mar345 format
 *		 	No need for external libraries
 *			Program provides a simple 32-bit array of NX*NY 
 *			32-bit integers
 *
 * Copyright by:        Dr. Claudio Klein, marXperts GmbH
 *
 * Version:     	1.0
 *
 * Version	Date		Description
 * 1.0		26/08/2014	Original version based on readmar 3.0
 *
 ***********************************************************************/

#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>
#include <math.h>
#include <ctype.h>
#include <string.h>
#include <time.h>
#include <matrix.h>
#include <mex.h>

#define BYTE char
#define WORD short int
#define LONG int

#define PACKIDENTIFIER "\nCCP4 packed image, X: %04d, Y: %04d\n"
#define PACKBUFSIZ BUFSIZ
#define DIFFBUFSIZ 16384L
#define max(x, y) (((x) > (y)) ? (x) : (y)) 
#define min(x, y) (((x) < (y)) ? (x) : (y)) 
#define abs(x) (((x) < 0) ? (-(x)) : (x))
const LONG setbits[33] = {0x00000000L, 0x00000001L, 0x00000003L, 0x00000007L,
			  0x0000000FL, 0x0000001FL, 0x0000003FL, 0x0000007FL,
			  0x000000FFL, 0x000001FFL, 0x000003FFL, 0x000007FFL,
			  0x00000FFFL, 0x00001FFFL, 0x00003FFFL, 0x00007FFFL,
			  0x0000FFFFL, 0x0001FFFFL, 0x0003FFFFL, 0x0007FFFFL,
			  0x000FFFFFL, 0x001FFFFFL, 0x003FFFFFL, 0x007FFFFFL,
			  0x00FFFFFFL, 0x01FFFFFFL, 0x03FFFFFFL, 0x07FFFFFFL,
			  0x0FFFFFFFL, 0x1FFFFFFFL, 0x3FFFFFFFL, 0x7FFFFFFFL,
                          0xFFFFFFFFL};
#define shift_left(x, n)  (((x) & setbits[32 - (n)]) << (n))
#define shift_right(x, n) (((x) >> (n)) & setbits[32 - (n)])

#define VERSION 	1.0
#define FPOS(a) 	( (int)( a/8. + 0.875 )*64)
#define N		65535

char 			infile		[ 256] = {"\0"}; 
char 			outfile		[ 256] = {"\0"}; 
char 			str		[1024];

int 			main		(int, char **);
static void		usage		(void);
void 			swapint32	(unsigned char *, int);
int			*Getmar345	(char *, int *);

/*
 * Function prototypes
 */
void 		get_pck 	(int, unsigned char *,  WORD *);
static void 	unpack_word	(unsigned char *, int, int, WORD *);


/***************************************************************************
 * Function: get_pck
 *	     s is the total size in bytes of cimg
 *	     cimg is a uchar array containing the entire file
 *	     img is a 16-bit integer array with x*y pixels
 ***************************************************************************/
void get_pck(int s, unsigned char *cimg, WORD *img)
{ 
int x = 0, y = 0, i = 0, j=0, c = 0;
char header[BUFSIZ];
unsigned char	*ci;

	header[0] = '\n';
	header[1] = 0;

	ci = cimg;
	/*
	 * Scan file until PCK header is found
	 */
	while ((x == 0) || (y == 0)) {
		c = i = x = y = 0;
		while ((++i < BUFSIZ) && (c != '\n') && (x==0) && (y==0)) {
			if ((header[i] = c = *ci++ ) == '\n')
				sscanf(header, PACKIDENTIFIER, &x, &y);
			j++;
			if ( j >= s ) break;
		}
		if ( j >= s ) break;
	}
//	for (i=0;i<j;i++) printf("Header %d is %c\n", i, header[i]);
//x = 50;
//y = 50;
	unpack_word(s, ci, x, y, img);
	
}

/*****************************************************************************
 * Function: unpack_word
 * Unpacks a packed image into the WORD-array 'img'. 
 *****************************************************************************/
static void unpack_word(int s, unsigned char *cimg, int x, int y, WORD *img)
{ 
int 		valids = 0, spillbits = 0, usedbits, total = x * y;
LONG 		window = 0L, spill, pixel = 0, nextint, bitnum, pixnum;
static int 	bitdecode[8] = {0, 4, 5, 6, 7, 8, 16, 32};
int 		numimg = 0;

    //printf("X and Y are %d\n", s);
	while (pixel < total) {
	//while (pixel < total) {
	    if (valids < 6) {
			
    		if (spillbits > 0) {
      			window |= shift_left(spill, valids);
        		valids += spillbits;
        		spillbits = 0;
			} else {
				spill = (LONG) *(cimg+numimg);
				//printf("CCC i %d, spillbits %d, spill %d, valids %d, window %d\n", numimg, spillbits, spill, valids, window);
				numimg = numimg + 1;
        		spillbits = 8;
			}
	    } else {
    		pixnum = 1 << (window & setbits[3]);
      		window = shift_right(window, 3);
      		bitnum = bitdecode[window & setbits[3]];
      		window = shift_right(window, 3);
      		valids -= 6;
      		while ((pixnum > 0) && (pixel < total)) {
      		    if (valids < bitnum) {
					if (spillbits > 0) {
						window |= shift_left(spill, valids);
						if ((32 - valids) > spillbits) {
							valids += spillbits;
							spillbits = 0;
						}
						else {
							usedbits = 32 - valids;
							spill = shift_right(spill, usedbits);
							spillbits -= usedbits;
							valids = 32;
						}
					} else {
						//spill = (LONG) *cimg++;
						spill = (LONG) *(cimg+numimg);
						//printf("CCC i %d, spillbits %d, spill %d, valids %d, window %d\n", numimg, spillbits, spill, valids, window);
						numimg = numimg + 1;
						spillbits = 8;
					}
				} else {
					--pixnum;
					if (bitnum == 0)
							nextint = 0;
					else {
						nextint = window & setbits[bitnum];
							valids -= bitnum;
							window = shift_right(window, bitnum);
						if ((nextint & (1 << (bitnum - 1))) != 0)
							nextint |= ~setbits[bitnum];
					}
	//				if (pixel>total-20550) pixel = total-20551;
					if (pixel > x) {
						img[pixel] = (WORD) (nextint + (img[pixel-1] + img[pixel-x+1] +
										   img[pixel-x] + img[pixel-x-1] + 2) / 4);
						++pixel;
					}
					else if (pixel != 0) {
						img[pixel] = (WORD) (img[pixel - 1] + nextint);
							++pixel;
					}
					else 
							img[pixel++] = (WORD) nextint;
				}
			}
	    }
		//printf("Total is pixel %d / %d, %d\n", pixel, total, img[pixel-1]);
	}
	//printf("reading done\n");
}


/******************************************************************
 * Function: Getmar345
 ******************************************************************/
int *Getmar345(char *infile, int *NXNY)
{
FILE 		*fp;
int		head[3];
int		i,j,nx, ny, no, iadd, byteswap=0;
double		avg=0.0, sig=0.0;
int		*i4, *i4_image;
unsigned short 	*i2, *i2_image;
unsigned char 	*cimage;
extern void 	get_pck 	(int, unsigned char *, signed short *);
int t;

	/* Open file */

	fp  = fopen(  infile,  "r+" );
	if ( !fp  ) {
		printf( "Input file %s does not exist! \n",infile);
		exit(-1);
	}

	/* Read first 3 integers: 1234, NX, high intensity pixels */
	/* Check if byte_swapping is necessary */
	fread( head, sizeof( int ), 3, fp);
	
	//for (i=0;i<3;i++) printf("header info: %d\n", head[i]);
	//pritnf("Header info: %i\n", head[0]);

	// For mar345: first integer must be: 1234
	if ( head[0] != 1234 ) {
		byteswap = 1;
		swapint32( (unsigned char *)head, 3*sizeof(int) );
		if ( head[0] == 1234 ) {
			printf("ERROR: First integer must be 1234 but is %d\n", head[0]);
			exit(-1);
		}
		
	} 
		

	nx = ny = head[1];
	no = head[2];
	
	if ( nx < 10 || nx > 4000 || ny < 10 || ny > 4000 ||  no > 9999999 ) {
		printf("ERROR: Something wrong with header: size is %d\n",nx);
		return NULL;
	}

	/* Allocate memory */
	i4_image = (int *)malloc( nx*ny*sizeof(int));
	memset( (char *)i4_image, 0, sizeof(int)*nx*ny );

	// Read entire image into memory
	i = fseek( fp, 0,   SEEK_END );
	i = ftell( fp );
	cimage = (unsigned char *)malloc(2*i*sizeof(char));
	
	rewind( fp );
	//fclose(fp);
	//fp  = fopen(  infile,  "r+" );
	//fseek( fp, 0,   SEEK_SET );
	j = fread(cimage, sizeof(char), i, fp);
//	for(t=0;t<100;t++) printf("value = %d\n", (LONG) cimage[t+4500]);
//	printf("Second i is %d\n", i);
//	printf("sizeof char is %d\n", sizeof(char));
//	printf("%d bytes read from %s\n",j, infile);
    
	/* Read core of image into second half of i4_image array */
	i2_image= (unsigned short *)(i4_image+nx*ny/2);

	/* Go to first record */
	 get_pck( i, cimage, (signed short *)i2_image);
	// Release memeory for cimage
	free( cimage );

	/* Transform i2 array into i4 array */
	i4 = i4_image;
	i2 = i2_image;
	for ( i=0; i<nx*ny; i++, i2++, i4++ ) {
		*i4 = (int)*i2;
	}
	
	/* There are some high intensity values stored in the image */
	if ( no ) {
		/* Go to start of overflow record */
		i = fseek( fp, 4096,   SEEK_SET );
		/* 
		 * Read overflows. Read a pair of values ( strong ), where
		 * first  value = address of pixel in i4_image array
		 * second value = intensity of pixel (32-bit) 
		 * In order to save memory, we don't allocate a 32-bit array
		 * for all data, but a 16-bit array and an 8-bit array.
		 * The final intensity 24-bit intensity is stored as:
		 * 24-bit-value = 16-bit-value + (8-bit-value)*65535;
		 * Note: the maximum intensity the scanner may produce is 250.000
		 *       Beyond the saturation of the ADC, all saturated pixels
		 *       get an intensity of 999.999 !
		 */ 
		for(i=0;i<no; i++ ) {
			j = fread( head, sizeof(int), 2, fp);

			if ( byteswap) 
				swapint32( (unsigned char *)head, sizeof(int)*2 );

			iadd = head[0];
			if ( iadd >= (nx*ny) || iadd < 0 ) continue;

			i4_image[iadd] = head[1];
		}
	}

	/* Close input file */
	fclose( fp );

	// Do some simple stuff: avg and sigma 
	i4 = i4_image;
	avg = sig = 0.0;
	for ( i=j=0; i<nx*ny; i++, i4++ ) {
		if ( *i4 < 1 || *i4 > 250000 ) continue;
		avg+=(*i4);
		sig+=((*i4)*(*i4) );
		j++;
	}
	if ( j > 1 ) {
		avg /= (float)j;
		sig = sqrt( ( sig - j*(avg*avg) ) / (double)(j-1) );
	}
	printf("\n%s:  <Iavg> = %1.1f +/- %1.3f for %d out of %dx%d pixels > 0\n", infile, avg, sig,j,nx,ny);	

	NXNY[0] = nx; NXNY[1] = ny;

	return i4_image;
}

/******************************************************************
 * Function: swapint32 = swaps bytes of 32 bit integers
 ******************************************************************/
void swapint32(unsigned char *data, int nbytes)
{
int 		i;
unsigned char 	t1, t2, t3, t4;

        for(i=nbytes/4;i--;) {
                t1 = data[i*4+3];
                t2 = data[i*4+2];
                t3 = data[i*4+1];
                t4 = data[i*4+0];
                data[i*4+0] = t1;
                data[i*4+1] = t2;
                data[i*4+2] = t3;
                data[i*4+3] = t4;
        }
}

/*==================================================================*/
void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
    size_t s;					/* Compressed file length */
	int sd;						/* Side length of uncompressed image */
	char *cimg;					/* Compressed image */
    int *outImage;	/* Output image */
	int *data;
	int NXNY[2];
	int i;

	/* Get the length of the compressed data */
	s = mxGetNumberOfElements(prhs[0]);
    if (nrhs != 2) 
		sd = 3450;
	else {				
		/* Get the side length of the uncompressed image (sd) */
		sd = mxGetScalar(prhs[1]);
	}

	/* Get the compressed data (cimg) */
	/*cimg = mxGetChars(prhs[0]);*/
	cimg = mxArrayToString(prhs[0]);

    /* create the output matrix (img) */
    plhs[0] = mxCreateNumericMatrix((mwSize)sd, (mwSize)sd, mxINT32_CLASS, mxREAL);
	//plhs[0] = mxCreateDoubleMatrix(3450, 3450, mxREAL);

    /* get a pointer to the real data in the output matrix (img) */
    outImage = mxGetPr(plhs[0]);

    /* call the computational routine */
	/*printf("So far OK. Filename is %s\n", cimg);*/
//    get_data(cimg,outImage);
	/* Getmar345 returns a pointer to a 32-bit integer array*/

	data = Getmar345(cimg, NXNY);
	
	if ( data == NULL ) {
		printf("ERROR: no image obtained.\n");
	} else {
		printf("Size of img = %ld  %d x %d\n", sizeof(data), NXNY[0],NXNY[1]);
	}
	
	for (i=0;i<sd*sd;i++) {
		outImage[i]=data[i];
		//printf("%d\n", data[i]);
		}
	//outImage = data;
	mxFree(cimg);
}
