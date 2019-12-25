# dockerized environment
## devops: create a dockerized build environment 
devops:
	make -C services devops

## sh: log into dockerized build environment
sh: devops
	if docker container inspect tree3 >/dev/null 2>&1; then \
		docker exec -it tree3 /bin/bash; \
	else \
		docker run \
			--entrypoint /bin/bash -it --rm \
			--name tree3 \
			--volume $(CURDIR):/go/src/github.com/originalgremlin/tree3 \
			tree3/devops; \
	fi

# golang development
## build: build the application for various architectures
build: build/linux build/mac build/windows
build/linux: build/linux_386
build/mac: build/darwin_386
build/windows: build/windows_386
build/%:
	if [ -z "$?" ]; then \
		IFS=_ read GOOS GOARCH <<< $*; \
		echo Building for architecture $$GOOS\_$$GOARCH; \
		docker run \
			--rm \
			--env GOOS=$$GOOS \
			--env GOARCH=$$GOARCH \
			--volume $(CURDIR):/go/src/github.com/originalgremlin/tree3 \
			--volume $(CURDIR)/bin:/go/bin \
			tree3/devops \
			install github.com/originalgremlin/tree3/cmd/tree3; \
	fi

## clean: cleans binaries
clean:
	rm -rf $(CURDIR)/bin

## doc: runs "go doc"
doc:
	docker run \
		--rm \
		--volume $(CURDIR):/go/src/github.com/originalgremlin/tree3 \
		tree3/devops \
		doc

## fmt: runs "go fmt"
fmt:
	docker run \
		--rm \
		--volume $(CURDIR):/go/src/github.com/originalgremlin/tree3 \
		tree3/devops \
		fmt

## run: runs "go run main.go"
run:
	docker run \
		--rm \
		--volume $(CURDIR):/go/src/github.com/originalgremlin/tree3 \
		tree3/devops \
		run -race github.com/originalgremlin/tree3/cmd/tree3/main.go

## swarm: launch local development cluster
swarm:
	if ! docker info | grep "Swarm: active" >/dev/null; then \
		make -C services sshd; \
		docker swarm init >/dev/null; \
		docker stack deploy -c stacks/test.yml tree3; \
	fi

## test: runs test suite with default values
test: swarm
	go test -v -count=1 -race ./...

# makefile
## help: prints this help message
help:
	@echo "Usage:"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'
