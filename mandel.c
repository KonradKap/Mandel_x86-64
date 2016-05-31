
#include <math.h>

#include "const.h"

void c_mandel(void* buffer, double zoom, double moveX, double moveY)
{
    const int maxIterations = 1000;
    double pr, pi;                   //real and imaginary part of the pixel p
    double newRe, newIm, oldRe, oldIm;   //real and imaginary parts of new and old z
    char* iterator = (char*)buffer;
    int i, x = 0, y = 0, brightness;
    double z;
    //loop through every pixel
	do
	{
		do
		{
        //calculate the initial real and imaginary part of z, based on the pixel location and zoom and position values
		    pr = 1.5 * (x - WINDOW_WIDTH / 2) / (0.5 * zoom * WINDOW_WIDTH) + moveX - 0.5;
		    pi = (y - WINDOW_HEIGHT / 2) / (0.5 * zoom * WINDOW_HEIGHT) + moveY;
		    newRe = newIm = oldRe = oldIm = 0; //these should start at 0,0
		    //"i" will represent the number of iterations
		    //start the iteration process
		    for(i = 0; i < maxIterations; ++i)
		    {
		        //remember value of previous iteration
		        oldRe = newRe;
		        oldIm = newIm;
		        //the actual iteration, the real and imaginary part are calculated
		        newRe = oldRe * oldRe - oldIm * oldIm + pr;
		        newIm = 2 * oldRe * oldIm + pi;
		        //if the point is outside the circle with radius 2: stop
		        if((newRe * newRe + newIm * newIm) > 4) break;
		    }

		    if(i == maxIterations)
			{  
				*iterator++=0;
				*iterator++=0;
				*iterator++=0;
				*iterator++=255;
			}
			else
		    {
				z = sqrt(newRe * newRe + newIm * newIm);
				brightness = 256. * log2(1.75 + i - log2(log2(z))) / log2((double)maxIterations);
				*iterator++=0;
				*iterator++=brightness;
				*iterator++=brightness;
				*iterator++=255;
		    }
			++x;
		} while (x < WINDOW_WIDTH);
		x = 0;
		++y;
	}while (y < WINDOW_HEIGHT);
    //}
}
