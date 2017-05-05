gcc overflow-detect.c `pkg-config --cflags --libs glib-2.0 libvmi` -g -lm -o overflow-detect.o
gcc mem-event.c `pkg-config --cflags --libs glib-2.0 libvmi` -g -lm -o mem-event.o
