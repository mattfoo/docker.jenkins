JENKINS_SHA     = 12d820574c8f586f7d441986dd53bcfe72b95453
JENKINS_VERSION = 2.7.1
NAME            = jenkins
REGISTRY        = local

.PHONY: build clean

all: build

clean-all: clean

build:
	@docker build --build-arg JENKINS_SHA=$(JENKINS_SHA) \
				  --build-arg JENKINS_VERSION=$(JENKINS_VERSION) \
				  --rm=true -t $(REGISTRY)/$(NAME):$(JENKINS_VERSION) .
	@docker tag $(REGISTRY)/$(NAME):$(JENKINS_VERSION) $(REGISTRY)/$(NAME):latest
	@docker images $(REGISTRY)/$(NAME)

clean:
	@docker rmi $(REGISTRY)/$(NAME):$(JENKINS_VERSION)
	@docker rmi $(REGISTRY)/$(NAME):latest

default: build
