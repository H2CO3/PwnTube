TARGET = PwnTube.dylib

CC = gcc
LD = $(CC)
CFLAGS = -isysroot /User/sysroot -c -Wall
LDFLAGS = -isysroot /User/sysroot -w -dynamiclib -lobjc -lsubstrate -lipodimportclient -lcurl -framework CoreFoundation -framework Foundation -framework CoreGraphics -framework UIKit

OBJECTS = $(patsubst %.m, %.o, $(wildcard *.m))

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $^
	cp $@ /Library/MobileSubstrate/DynamicLibraries/

clean:
	rm $(OBJECTS) $(TARGET)

%.o: %.m
	$(CC) $(CFLAGS) -o $@ $^
