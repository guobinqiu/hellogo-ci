.PHONY: all build run stop clean

IMAGE_NAME=qiuguobin/hellogo
PORT=8000

all: build

build:
	@docker build -t $(IMAGE_NAME) -f Dockerfile .

run:
	@docker run -d -p $(PORT):$(PORT) $(IMAGE_NAME)

stop:
	@docker stop $$(docker ps -a -q --filter ancestor=$(IMAGE_NAME)) || true

clean:
	@docker rm $$(docker ps -a -q --filter ancestor=$(IMAGE_NAME)) || true