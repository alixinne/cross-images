ifneq (, $(shell which podman))
	DOCKER=podman
else
	DOCKER=docker
endif

REGISTRY?=docker.io
IMAGE_BASE=vtavernier/cross
TARGETS=$(patsubst %,docker-image-%,$(patsubst targets/%,%,$(wildcard targets/*)))
TEST_TARGETS=$(patsubst %,test-%,$(patsubst targets/%,%,$(wildcard targets/*)))
PUSH_TARGETS=$(patsubst %,push-%,$(patsubst targets/%,%,$(wildcard targets/*)))

export DOCKER
export REGISTRY
export IMAGE_BASE

all: images

images: $(TARGETS)
$(TARGETS):
	$(eval export TARGET := $(patsubst docker-image-%,%,$@))
	(cd targets/$(TARGET) && ./build)

test: $(TEST_TARGETS)
$(TEST_TARGETS):
	$(eval TARGET := $(patsubst test-%,%,$@))
	test ! -f tests/$(TARGET)/c.sh || tests/$(TARGET)/c.sh
	test ! -f tests/$(TARGET)/rust.sh || tests/$(TARGET)/rust.sh

push: $(PUSH_TARGETS)
$(PUSH_TARGETS):
	$(eval export TARGET := $(patsubst push-%,%,$@))
	(cd targets/$(TARGET) && ./push)

.PHONY: all images $(TARGETS) test $(TEST_TARGETS)
