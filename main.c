#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include "SDL.h"

#include "const.h"

void c_mandel(void* buffer, double zoom, double moveX, double moveY);
void asm_mandel(void* buffer, double zoom, double moveX, double moveY);

int main(void) {
    double x_shift = 0, y_shift = 0;
    int running = 1;
    double zoom = 1.0;
    SDL_Event event;
    SDL_Renderer *renderer;
    SDL_Window *window;
    SDL_Rect w_rect = {0, 0, WINDOW_WIDTH, WINDOW_HEIGHT};
    SDL_Surface* surface;
    SDL_Texture* texture;

    SDL_Init(SDL_INIT_VIDEO);
    SDL_CreateWindowAndRenderer(WINDOW_WIDTH, WINDOW_HEIGHT, 0, &window, &renderer);
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, 0);
    SDL_RenderClear(renderer);

    surface = SDL_CreateRGBSurface(0, WINDOW_WIDTH, WINDOW_HEIGHT, BIT_FORMAT, A_MASK, B_MASK, G_MASK, R_MASK);
    asm_mandel(surface->pixels, zoom, -0, 0);
    texture = SDL_CreateTextureFromSurface(renderer, surface);
    SDL_RenderCopy(renderer, texture, NULL, &w_rect);
    SDL_RenderPresent(renderer);

    while (running) 
    {
        while(SDL_PollEvent(&event))
		switch(event.type)
		{
			case SDL_QUIT:
				running = 0;
				break;
			case SDL_KEYUP:
				if(event.key.keysym.sym == SDLK_ESCAPE)
					running = 0;
				break;
			case SDL_MOUSEBUTTONUP:
				if(event.button.button == SDL_BUTTON_LEFT)
				{
					x_shift += (double)event.button.x/WINDOW_WIDTH -0.5;
					y_shift += (double)event.button.y/WINDOW_HEIGHT -0.5;
					zoom += 0.1;
				}
				else
				{
					x_shift -= (double)event.button.x/WINDOW_WIDTH -0.5;
					y_shift -= (double)event.button.y/WINDOW_HEIGHT -0.5;
					zoom -= 0.1;
				}
				asm_mandel(surface->pixels, zoom, x_shift, y_shift);
				SDL_DestroyTexture(texture);
				texture = SDL_CreateTextureFromSurface(renderer, surface);
				SDL_RenderCopy(renderer, texture, NULL, &w_rect);
				SDL_RenderPresent(renderer);
				break;
			default:
				break;
		}
    }

    SDL_FreeSurface(surface);
    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return EXIT_SUCCESS;

}

