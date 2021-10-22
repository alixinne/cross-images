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

all: images

images: $(TARGETS)
$(TARGETS):
	$(eval TARGET := $(patsubst docker-image-%,%,$@))
	$(DOCKER) build -t $(IMAGE_BASE):$(TARGET) targets/$(TARGET)

test: $(TEST_TARGETS)
$(TEST_TARGETS):
	$(eval TARGET := $(patsubst test-%,%,$@))
	test ! -f tests/$(TARGET)/c.sh || tests/$(TARGET)/c.sh
	test ! -f tests/$(TARGET)/rust.sh || tests/$(TARGET)/rust.sh

push: $(PUSH_TARGETS)
$(PUSH_TARGETS):
	$(eval TARGET := $(patsubst push-%,%,$@))
	$(DOCKER) tag $(IMAGE_BASE):$(TARGET) $(REGISTRY)/$(IMAGE_BASE):$(TARGET)
	$(DOCKER) push $(REGISTRY)/$(IMAGE_BASE):$(TARGET)

.PHONY: all images $(TARGETS) test $(TEST_TARGETS)
