CXX ?= g++
CFLAGS = -Wall -Wconversion -O3 -fPIC
SHVER = 2
OS = $(shell uname)
PREFIX = /usr/local

all: svm-train svm-predict svm-scale

lib: svm.o
	if [ "$(OS)" = "Darwin" ]; then \
		SHARED_LIB_FLAG="-dynamiclib -Wl,-install_name,libsvm.so.$(SHVER)"; \
	else \
		SHARED_LIB_FLAG="-shared -Wl,-soname,libsvm.so.$(SHVER)"; \
	fi; \
	$(CXX) $${SHARED_LIB_FLAG} svm.o -o libsvm.so.$(SHVER)

svm-predict: svm-predict.c svm.o
	$(CXX) $(CFLAGS) svm-predict.c svm.o -o svm-predict -lm
svm-train: svm-train.c svm.o
	$(CXX) $(CFLAGS) svm-train.c svm.o -o svm-train -lm
svm-scale: svm-scale.c
	$(CXX) $(CFLAGS) svm-scale.c -o svm-scale
svm.o: svm.cpp svm.h
	$(CXX) $(CFLAGS) -c svm.cpp
clean:
	rm -f *~ svm.o svm-train svm-predict svm-scale libsvm.so.$(SHVER)

install: all
	test -d $(PREFIX) || mkdir -p $(PREFIX)
	test -d $(PREFIX)/include || mkdir -p $(PREFIX)/include
	test -d $(PREFIX)/lib || mkdir -p $(PREFIX)/lib
	install -m 0644 svm.h $(PREFIX)/include
	install -m 0755 svm.o $(PREFIX)/lib

