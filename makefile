CC=g++
CFLAGS=-Wall -O2 -std=gnu++11
LIBUSB_INC?=-I/usr/local/include
LDFLAGS=-L/usr/local/lib -lhidapi
PROGN=g810-led

.PHONY: all debug clean install uninstall

all: bin/$(PROGN)

bin/$(PROGN): src/classes/Keyboard.o src/main.o
	@mkdir -p bin
	$(CC) $(CFLAGS) $(LIBUSB_INC) -o $@ $^ $(LDFLAGS)

src/main.o: src/main.cpp src/classes/Keyboard.h
	$(CC) $(CFLAGS) $(LIBUSB_INC) -c -o $@ $<

src/classes/Keyboard.o: src/classes/Keyboard.cpp src/classes/Keyboard.h
	$(CC) $(CFLAGS) $(LIBUSB_INC) -c -o $@ $<

debug: CFLAGS += -g -Wextra -pedantic
debug: bin/$(PROGN)

clean:
	@rm -rf bin
	@rm -rf */*.o */**/*.o

install:
	@sudo mkdir -p /etc/$(PROGN)/samples
	@sudo cp sample_profiles/* /etc/$(PROGN)/samples
	@sudo cp udev/$(PROGN).rules /etc/udev/rules.d
	@sudo cp bin/$(PROGN) /usr/bin
	@sudo test -s /etc/$(PROGN)/profile || sudo cp /etc/$(PROGN)/samples/group_keys /etc/$(PROGN)/profile
	@sudo test -s /etc/$(PROGN)/reboot || sudo cp /etc/$(PROGN)/samples/all_off /etc/$(PROGN)/reboot
	@sudo cp systemd/$(PROGN).service /lib/systemd/system
	@sudo cp systemd/$(PROGN)-reboot.service /lib/systemd/system
	@sudo systemctl start $(PROGN)
	@sudo systemctl enable $(PROGN)
	@sudo systemctl enable $(PROGN)-reboot

uninstall:
	@sudo systemctl disable $(PROGN)
	@sudo systemctl disable $(PROGN)-reboot
	@sudo rm /lib/systemd/system/$(PROGN).service
	@sudo rm /lib/systemd/system/$(PROGN)-reboot.service
	@sudo rm /etc/udev/rules.d/$(PROGN).rules
	@sudo rm /usr/bin/$(PROGN)
	@sudo rm -R /etc/$(PROGN)
