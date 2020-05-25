//This program is written by Munther Gdeisat and Miguel Arevallilo Herra´ez to program the two-dimensional unwrapper
//entitled "Fast two-dimensional phase-unwrapping algorithm based on sorting by 
//reliability following a noncontinuous path"
//by  Miguel Arevallilo Herra´ez, David R. Burton, Michael J. Lalor, and Munther A. Gdeisat
//published in the Applied Optics, Vol. 41, No. 35, pp. 7437, 2002.
//This program is written on 15th August 2007
//The wrapped phase map is floating point data type. Also, the unwrapped phase map is foloating point
//The mask is unsigned char data type. 
//When the mask is 255 this means that the pixel is valid 
//When the mask is 0 this means that the pixel is invalid (noisy or corrupted pixel)
#include <malloc.h>
#include<stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mex.h"   //--This one is required

static float PI = 3.141592654;
static float TWOPI = 6.283185307;
int No_of_edges = 0;

//PIXELM information
struct PIXELM
{
	//int x;					//x coordinate of the pixel
    //int y;					//y coordinate
    int increment;			//No. of 2*pi to add to the pixel to unwrap it
    int number_of_pixels_in_group;	//No. of pixel in the pixel group
    float value;			//value of the pixel
	float reliability;
	unsigned char input_mask;				//0 pixel is masked. 255 pixel is not masked
	unsigned char extended_mask;				//0 pixel is masked. 255 pixel is not masked
    int group;				//group No.
    int new_group;
    struct PIXELM *head;		//pointer to the first pixel in the group in the linked list
    struct PIXELM *last;		//pointer to the last pixel in the group
    struct PIXELM *next;		//pointer to the next pixel in the group
};

//the EDGE is the line that connects two pixels.
//if we have S pixels, then we have S horizental edges and S vertical edges
struct EDGE
{    
	float reliab;			//reliabilty of the edge and it depends on the two pixels
	PIXELM *pointer_1;		//pointer to the first pixel
    PIXELM *pointer_2;		//pointer to the second pixel
    int increment;			//No. of 2*pi to add to one of the pixels to unwrap it with respect to the second 
}; 

void read_data(char *inputfile,float *Data, int length)
{
	printf("Reading the Wrapped Values form Binary File.............>");
	FILE *ifptr;
	ifptr = fopen(inputfile,"rb");
	if(ifptr == NULL) printf("Error opening the file\n");
	fread(Data,sizeof(float),length,ifptr);
	fclose(ifptr);
	printf(" Done.\n");
}

void write_data(char *outputfile,float *Data,int length)
{
	printf("Writing the Unwrapped Values to Binary File.............>");
	FILE *ifptr;
	ifptr = fopen(outputfile,"wb");
	if(ifptr == NULL) printf("Error opening the file\n");
	fwrite(Data,sizeof(float),length,ifptr);
	fclose(ifptr);
	printf(" Done.\n");
}

void read_mask(char *inputfile,unsigned char *Data, int length)
{
	printf("Reading the mask form Binary File.............>");
	FILE *ifptr;
	ifptr = fopen(inputfile,"rb");
	if(ifptr == NULL) printf("Error opening the file\n");
	fread(Data,sizeof(char),length,ifptr);
	fclose(ifptr);
	printf(" Done.\n");
}

//another version of Mixtogether but this function should only be use with the sort program
void  Mix(EDGE *Pointer1, int *index1, int *index2, int size)
{
	int counter1 = 0;
	int counter2 = 0;
	int *TemporalPointer = index1;

	int *Result = (int *) calloc(size * 2, sizeof(int));
	int *Follower = Result;

	while ((counter1 < size) && (counter2 < size))
	{
		if ((Pointer1[*(index1 + counter1)].reliab <= Pointer1[*(index2 + counter2)].reliab))
		{
			*Follower = *(index1 + counter1);
			Follower++;
			counter1++;
		} 
		else
        {
			*Follower = *(index2 + counter2);
			Follower++;
			counter2++;
        }
	}//while

	if (counter1 == size)
	{
		memcpy(Follower, (index2 + counter2), sizeof(int)*(size-counter2));
	} 
	else
	{
		memcpy(Follower, (index1 + counter1), sizeof(int)*(size-counter1));
	}

	Follower = Result;
	index1 = TemporalPointer;

	int i;
	for (i=0; i < 2 * size; i++)
	{
		*index1 = *Follower;
		index1++;
		Follower++;
	}

	free(Result);
}

//this is may be the fastest sort program; 
//see the explination in quickSort function below
void  sort(EDGE *Pointer, int *index, int size)
{
	if (size == 2)
	{
		if ((Pointer[*index].reliab) > (Pointer[*(index+1)].reliab))
		{
			int Temp;
			Temp = *index;
			*index = *(index+1);
			*(index+1) = Temp;
		}
	} 
	else if (size > 2)
    {
		sort(Pointer, index, size/2);
		sort(Pointer, (index + (size/2)), size/2);
		Mix(Pointer, index, (index + (size/2)), size/2);
    }
}

//this function tries to implement a nice idea explained below
//we need to sort edge array. Each edge element conisists of 16 bytes.
//In normal sort program we compare two elements in the array and exchange
//their place under some conditions to do the sorting. It is very probable
// that an edge element may change its place hundred of times which makes 
//the sorting a very time consuming operation. The idea in this function 
//is to give each edge element an index and move the index not the edge
//element. The edge need 4 bytes which makes the sorting operation faster.
// After finishingthe sorting of the indexes, we know the position of each index. 
//So we know how to sort edges
void  quick_sort(EDGE *Pointer, int size)
{
	int *index = (int *) calloc(size, sizeof(int));
	int i;

	for (i=0; i<size; ++i)
		index[i] = i;

	sort(Pointer, index, size);

	EDGE * a = (EDGE *) calloc(size, sizeof(EDGE));
	for (i=0; i<size; ++i)
		a[i] = Pointer[*(index + i)];

	memcpy(Pointer, a, size*sizeof(EDGE));

	free(index);
	free(a);
}

//---------------start quicker_sort algorithm --------------------------------
#define swap(x,y) {EDGE t; t=x; x=y; y=t;}
#define order(x,y) if (x.reliab > y.reliab) swap(x,y)
#define o2(x,y) order(x,y)
#define o3(x,y,z) o2(x,y); o2(x,z); o2(y,z)

typedef enum {yes, no} yes_no;

yes_no find_pivot(EDGE *left, EDGE *right, float *pivot_ptr)
{
	EDGE a, b, c, *p;

	a = *left;
	b = *(left + (right - left) /2 );
	c = *right;
	o3(a,b,c);

	if (a.reliab < b.reliab)
	{
		*pivot_ptr = b.reliab;
		return yes;
	}

	if (b.reliab < c.reliab)
	{
		*pivot_ptr = c.reliab;
		return yes;
	}

	for (p = left + 1; p <= right; ++p)
	{
		if (p->reliab != left->reliab)
		{
			*pivot_ptr = (p->reliab < left->reliab) ? left->reliab : p->reliab;
			return yes;
		}
		return no;
	}
}

EDGE *partition(EDGE *left, EDGE *right, float pivot)
{
	while (left <= right)
	{
		while (left->reliab < pivot)
			++left;
		while (right->reliab >= pivot)
			--right;
		if (left < right)
		{
			swap (*left, *right);
			++left;
			--right;
		}
	}
	return left;
}

void quicker_sort(EDGE *left, EDGE *right)
{
	EDGE *p;
	float pivot;

	if (find_pivot(left, right, &pivot) == yes)
	{
		p = partition(left, right, pivot);
		quicker_sort(left, p - 1);
		quicker_sort(p, right);
	}
}

//--------------end quicker_sort algorithm -----------------------------------

//--------------------start initialse pixels ----------------------------------
//initialse pixels. See the explination of the pixel class above.
//initially every pixel is a gorup by its self
void  initialisePIXELs(float *WrappedImage, unsigned char *input_mask, unsigned char *extended_mask, PIXELM *pixel, int image_width, int image_height)
{
	PIXELM *pixel_pointer = pixel;
	float *wrapped_image_pointer = WrappedImage;
	unsigned char *input_mask_pointer = input_mask;
	unsigned char *extended_mask_pointer = extended_mask;
	int i, j;

    for (i=0; i < image_height; i++)
	{
		for (j=0; j < image_width; j++)
        {
			//pixel_pointer->x = j;
  			//pixel_pointer->y = i;
			pixel_pointer->increment = 0;
			pixel_pointer->number_of_pixels_in_group = 1;		
  			pixel_pointer->value = *wrapped_image_pointer;
			pixel_pointer->reliability = 9999999 + rand();
			pixel_pointer->input_mask = *input_mask_pointer;
			pixel_pointer->extended_mask = *extended_mask_pointer;
			pixel_pointer->head = pixel_pointer;
  			pixel_pointer->last = pixel_pointer;
			pixel_pointer->next = NULL;			
            pixel_pointer->new_group = 0;
            pixel_pointer->group = -1;
            pixel_pointer++;
            wrapped_image_pointer++;
			input_mask_pointer++;
			extended_mask_pointer++;
         }
	}
}
//-------------------end initialise pixels -----------

//gamma finction in the paper
float wrap(float pixel_value)
{
	float wrapped_pixel_value;
	if (pixel_value > PI)	wrapped_pixel_value = pixel_value - TWOPI;
	else if (pixel_value < -PI)	wrapped_pixel_value = pixel_value + TWOPI;
	else wrapped_pixel_value = pixel_value;
	return wrapped_pixel_value;
}

// pixelL_value is the left pixel,	pixelR_value is the right pixel
int find_wrap(float pixelL_value, float pixelR_value)
{
	float difference; 
	int wrap_value;
	difference = pixelL_value - pixelR_value;

	if (difference > PI)	wrap_value = -1;
	else if (difference < -PI)	wrap_value = 1;
	else wrap_value = 0;

	return wrap_value;
} 

void extend_mask(unsigned char *input_mask, unsigned char *extended_mask, int image_width, int image_height)
{
	int i,j;
	int image_width_plus_one = image_width + 1;
	int image_width_minus_one = image_width - 1;
	unsigned char *IMP = input_mask    + image_width + 1;	//input mask pointer
	unsigned char *EMP = extended_mask + image_width + 1;	//extended mask pointer

	//extend the mask for the image except borders
	for (i=1; i < image_height - 1; ++i)
	{
		for (j=1; j < image_width - 1; ++j)
		{
			if ( (*IMP) == 255 && (*(IMP + 1) == 255) && (*(IMP - 1) == 255) && 
				(*(IMP + image_width) == 255) && (*(IMP - image_width) == 255) &&
				(*(IMP - image_width_minus_one) == 255) && (*(IMP - image_width_plus_one) == 255) &&
				(*(IMP + image_width_minus_one) == 255) && (*(IMP + image_width_plus_one) == 255) )
			{		
				*EMP = 255;
			}
			++EMP;
			++IMP;
		}
		EMP += 2;
		IMP += 2;
	}
}

void calculate_reliability(float *wrappedImage, PIXELM *pixel, int image_width, int image_height)
{
	int image_width_plus_one = image_width + 1;
	int image_width_minus_one = image_width - 1;
	PIXELM *pixel_pointer = pixel + image_width_plus_one;
	float *WIP = wrappedImage + image_width_plus_one; //WIP is the wrapped image pointer
	float H, V, D1, D2;
	int i, j;
	
	for (i = 1; i < image_height -1; ++i)
	{
		for (j = 1; j < image_width - 1; ++j)
		{
			if (pixel_pointer->input_mask == 255)
			{
				H = wrap(*(WIP - 1) - *WIP) - wrap(*WIP - *(WIP + 1));
				V = wrap(*(WIP - image_width) - *WIP) - wrap(*WIP - *(WIP + image_width));
				D1 = wrap(*(WIP - image_width_plus_one) - *WIP) - wrap(*WIP - *(WIP + image_width_plus_one));
				D2 = wrap(*(WIP - image_width_minus_one) - *WIP) - wrap(*WIP - *(WIP + image_width_minus_one));
				pixel_pointer->reliability = H*H + V*V + D1*D1 + D2*D2;
			}
			pixel_pointer++;
			WIP++;
		}
		pixel_pointer += 2;
		WIP += 2;
	}
}

//calculate the reliability of the horizental edges of the image
//it is calculated by adding the reliability of pixel and the relibility of 
//its right neighbour
//edge is calculated between a pixel and its next neighbour
void  horizentalEDGEs(PIXELM *pixel, EDGE *edge, int image_width, int image_height)
{
	int i, j;
	EDGE *edge_pointer = edge;
	PIXELM *pixel_pointer = pixel;
	
	for (i = 0; i < image_height; i++)
	{
		for (j = 0; j < image_width - 1; j++) 
		{
			if (pixel_pointer->input_mask == 255 && (pixel_pointer + 1)->input_mask == 255)
			{
				edge_pointer->pointer_1 = pixel_pointer;
				edge_pointer->pointer_2 = (pixel_pointer+1);
				edge_pointer->reliab = pixel_pointer->reliability + (pixel_pointer + 1)->reliability;
				edge_pointer->increment = find_wrap(pixel_pointer->value, (pixel_pointer + 1)->value);
				edge_pointer++;
				No_of_edges++;
			}
			pixel_pointer++;
		}
		pixel_pointer++;
	}
}

//calculate the reliability of the vertical edges of the image
//it is calculated by adding the reliability of pixel and the relibility of 
//its lower neighbour in the image.
void  verticalEDGEs(PIXELM *pixel, EDGE *edge, int image_width, int image_height)
{
	int i, j;
	PIXELM *pixel_pointer = pixel;
	EDGE *edge_pointer = edge + No_of_edges; 

	for (i=0; i < image_height - 1; i++)
	{
		for (j=0; j < image_width; j++) 
		{
			if (pixel_pointer->input_mask == 255 && (pixel_pointer + image_width)->input_mask == 255)
			{
				edge_pointer->pointer_1 = pixel_pointer;
				edge_pointer->pointer_2 = (pixel_pointer + image_width);
				edge_pointer->reliab = pixel_pointer->reliability + (pixel_pointer + image_width)->reliability;
				edge_pointer->increment = find_wrap(pixel_pointer->value, (pixel_pointer + image_width)->value);
				edge_pointer++;
				No_of_edges++;
			}
			pixel_pointer++;
		} //j loop
	} // i loop
}

//gather the pixels of the image into groups 
void  gatherPIXELs(EDGE *edge, int image_width, int image_height)
{
	int k;
	PIXELM *PIXEL1;   
	PIXELM *PIXEL2;
	PIXELM *group1;
	PIXELM *group2;
	EDGE *pointer_edge = edge;
	int incremento;

	for (k = 0; k < No_of_edges; k++)
	{
		PIXEL1 = pointer_edge->pointer_1;
		PIXEL2 = pointer_edge->pointer_2;

		//PIXELM 1 and PIXELM 2 belong to different groups
		//initially each pixel is a group by it self and one pixel can construct a group
		//no else or else if to this if
		if (PIXEL2->head != PIXEL1->head)
		{
			//PIXELM 2 is alone in its group
			//merge this pixel with PIXELM 1 group and find the number of 2 pi to add 
			//to or subtract to unwrap it
			if ((PIXEL2->next == NULL) && (PIXEL2->head == PIXEL2))
			{
				PIXEL1->head->last->next = PIXEL2;
				PIXEL1->head->last = PIXEL2;
				(PIXEL1->head->number_of_pixels_in_group)++;
				PIXEL2->head=PIXEL1->head;
				PIXEL2->increment = PIXEL1->increment-pointer_edge->increment;
			}

			//PIXELM 1 is alone in its group
			//merge this pixel with PIXELM 2 group and find the number of 2 pi to add 
			//to or subtract to unwrap it
			else if ((PIXEL1->next == NULL) && (PIXEL1->head == PIXEL1))
			{
				PIXEL2->head->last->next = PIXEL1;
				PIXEL2->head->last = PIXEL1;
				(PIXEL2->head->number_of_pixels_in_group)++;
				PIXEL1->head = PIXEL2->head;
				PIXEL1->increment = PIXEL2->increment+pointer_edge->increment;
			} 

			//PIXELM 1 and PIXELM 2 both have groups
			else
            {
				group1 = PIXEL1->head;
                group2 = PIXEL2->head;
				//the no. of pixels in PIXELM 1 group is large than the no. of pixels
				//in PIXELM 2 group.   Merge PIXELM 2 group to PIXELM 1 group
				//and find the number of wraps between PIXELM 2 group and PIXELM 1 group
				//to unwrap PIXELM 2 group with respect to PIXELM 1 group.
				//the no. of wraps will be added to PIXELM 2 grop in the future
				if (group1->number_of_pixels_in_group > group2->number_of_pixels_in_group)
				{
					//merge PIXELM 2 with PIXELM 1 group
					group1->last->next = group2;
					group1->last = group2->last;
					group1->number_of_pixels_in_group = group1->number_of_pixels_in_group + group2->number_of_pixels_in_group;
					incremento = PIXEL1->increment-pointer_edge->increment - PIXEL2->increment;
					//merge the other pixels in PIXELM 2 group to PIXELM 1 group
					while (group2 != NULL)
					{
						group2->head = group1;
						group2->increment += incremento;
						group2 = group2->next;
					}
				} 

				//the no. of pixels in PIXELM 2 group is large than the no. of pixels
				//in PIXELM 1 group.   Merge PIXELM 1 group to PIXELM 2 group
				//and find the number of wraps between PIXELM 2 group and PIXELM 1 group
				//to unwrap PIXELM 1 group with respect to PIXELM 2 group.
				//the no. of wraps will be added to PIXELM 1 grop in the future
				else
                {
					//merge PIXELM 1 with PIXELM 2 group
					group2->last->next = group1;
					group2->last = group1->last;
					group2->number_of_pixels_in_group = group2->number_of_pixels_in_group + group1->number_of_pixels_in_group;
					incremento = PIXEL2->increment + pointer_edge->increment - PIXEL1->increment;
					//merge the other pixels in PIXELM 2 group to PIXELM 1 group
					while (group1 != NULL)
					{
						group1->head = group2;
						group1->increment += incremento;
						group1 = group1->next;
					} // while

                } // else
            } //else
        } //if
        pointer_edge++;
	}
}

//unwrap the image 
void  unwrapImage(PIXELM *pixel, int image_width, int image_height)
{
	int i;
	int image_size = image_width * image_height;
	PIXELM *pixel_pointer=pixel;

	for (i = 0; i < image_size; i++)
	{
		pixel_pointer->value += TWOPI * (float)(pixel_pointer->increment);
        pixel_pointer++;
    }
}

//set the masked pixels (mask = 0) to the minimum of the unwrapper phase
void  maskImage(PIXELM *pixel, unsigned char *input_mask, int image_width, int image_height)
{
	int image_width_plus_one  = image_width + 1;
	int image_height_plus_one  = image_height + 1;
	int image_width_minus_one = image_width - 1;
	int image_height_minus_one = image_height - 1;

	PIXELM *pointer_pixel = pixel;
	unsigned char *IMP = input_mask;	//input mask pointer
	float min=99999999.;
	int i, j;
	int image_size = image_width * image_height;

	//find the minimum of the unwrapped phase
	for (i = 0; i < image_size; i++)
	{
		if ((pointer_pixel->value < min) && (*IMP == 255)) 
			min = pointer_pixel->value;

		pointer_pixel++;
		IMP++;
	}

	pointer_pixel = pixel;
	IMP = input_mask;	

	//set the masked pixels to minimum
	for (i = 0; i < image_size; i++)
	{
		if ((*IMP) == 0)
		{
			pointer_pixel->value = min;
		}
		pointer_pixel++;
		IMP++;
	}
}

//the input to this unwrapper is an array that contains the wrapped phase map. 
//copy the image on the buffer passed to this unwrapper to over write the unwrapped 
//phase map on the buffer of the wrapped phase map.
void  returnImage(PIXELM *pixel, float *unwrappedImage, int image_width, int image_height)
{
	int i;
	int image_size = image_width * image_height;
    float *unwrappedImage_pointer = unwrappedImage;
    PIXELM *pixel_pointer = pixel;

    for (i=0; i < image_size; i++) 
	{
        *unwrappedImage_pointer = pixel_pointer->value;
        pixel_pointer++;
		unwrappedImage_pointer++;
	}
}

//the main function of the unwrapper
// int main()
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{  
	float *WrappedImage = (float *)mxGetData(prhs[0]);
	unsigned char *input_mask = (unsigned char *)mxGetData(prhs[1]);
	int image_width = mxGetM(prhs[0]);
	int image_height = mxGetN(prhs[0]);

	//declare a place to store the unwrapped image and return it to Matlab
	const mwSize *dims = mxGetDimensions(prhs[0]);
	plhs[0] = mxCreateNumericArray(2, dims, mxSINGLE_CLASS, mxREAL);
	float *UnwrappedImage = (float *)mxGetPr(plhs[0]);

	// unsigned char *extended_mask = (unsigned char *)mxGetData(plhs[1]);

	int i, j; 
	int image_size = image_height * image_width;
	int No_of_Edges_initially = (image_width)*(image_height-1) + (image_width-1)*(image_height);

	unsigned char *extended_mask = (unsigned char *) calloc(image_size, sizeof(unsigned char));

	PIXELM *pixel = (PIXELM *) calloc(image_size, sizeof(PIXELM));
	EDGE *edge = (EDGE *) calloc(No_of_Edges_initially, sizeof(EDGE));;
	// PIXELM *pixel = (PIXELM *) mxCalloc(image_size, sizeof(PIXELM));
	// EDGE *edge = (EDGE *) mxCalloc(No_of_Edges_initially, sizeof(EDGE));;

	extend_mask(input_mask, extended_mask, image_width, image_height);
	
	initialisePIXELs(WrappedImage, input_mask, extended_mask, pixel, image_width, image_height);

	calculate_reliability(WrappedImage, pixel, image_width, image_height);

	horizentalEDGEs(pixel, edge, image_width, image_height);

	verticalEDGEs(pixel, edge, image_width, image_height);

	//sort the EDGEs depending on their reiability. The PIXELs with higher relibility (small value) first
	//if your code stuck because of the quicker_sort() function, then use the quick_sort() function
	//run only one of the two functions (quick_sort() or quicker_sort() )
	// quick_sort(edge, No_of_edges);
	quicker_sort(edge, edge + No_of_edges - 1);

	//gather PIXELs into groups
	gatherPIXELs(edge, image_width, image_height);

	unwrapImage(pixel, image_width, image_height);

	maskImage(pixel, input_mask, image_width, image_height);

	//copy the image from PIXELM structure to the unwrapped phase array passed to this function
	returnImage(pixel, UnwrappedImage, image_width, image_height);

	free(edge);
	free(pixel);
	free(extended_mask);	

	return;
}
