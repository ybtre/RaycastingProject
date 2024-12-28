build:
	gcc -std=c99 $(shell find ./src -type f -name *.c) $(shell sdl2-config --cflags --libs) -o raycast

run:
	./raycast

clean:
	rm raycast
