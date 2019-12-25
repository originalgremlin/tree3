## devops: create a dockerized build environment
devops: $(shell find devops/*)
	docker build -t tree3/devops devops
	touch $(shell find devops)

## sshd: create test images
sshd: $(shell find sshd/*)
	for distro in `basename -s .Dockerfile sshd/*.Dockerfile`; do \
		docker build -t tree3/sshd:$$distro -f sshd/$$distro.Dockerfile sshd; \
	done
	touch $(shell find sshd)

# makefile
## help: prints this help message
help:
	@echo "Usage:"
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'
