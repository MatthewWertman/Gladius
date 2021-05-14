
PYTHON := python3
MKDIR_P = mkdir -p

.PHONY: gladius

unpack_iso     := $(PYTHON) tools/ngciso-tool.py -unpack
unpack_bec     := $(PYTHON) tools/bec-tool.py -unpack
create_iso     := $(PYTHON) tools/ngciso-tool.py -pack
create_bec     := $(PYTHON) tools/bec-tool.py -pack

all: clean gladius

clean:
	rm -f build/*
	-rm gladius.iso

init:
	$(unpack_iso) ./baseiso.iso ./baseiso/ BaseISO_FileList.txt
	$(unpack_bec) ./baseiso/gladius.bec ./baseiso/gladius_bec/ gladius_bec_FileList.txt

init/sound.bec:
	$(unpack_bec) ./baseiso/audio.bec ./baseiso/audio_bec/ audio_bec_FileList.txt

sound.bec:
	$(MKDIR_P) build/
	$(create_bec) ./baseiso/audio_bec ./build/audio.bec ./baseiso/audio_bec/audio_bec_FileList.txt

data.bec:
	$(MKDIR_P) build/
	$(create_bec) ./baseiso/gladius_bec ./build/gladius.bec ./baseiso/gladius_bec/gladius_bec_FileList.txt

gladius: data.bec
	cp -v build/gladius.bec baseiso/
	-cp -v build/audio.bec baseiso/
	$(create_iso) ./baseiso ./baseiso/fst.bin ./baseiso/BaseISO_FileList.txt gladius.iso
	md5sum $@
