.PHONY: all
all: setup start

.PHONY: setup
setup:
	@echo "Setup git submodules"
	git submodule update --init
	@echo "Setup certificates"
	cd ./tls-gen/basic; \
	make CN=rabbitmq.mydomain.local

.PHONY: start
start:
	docker-compose up --build

.PHONY: start_recreated
start_recreated:
	docker-compose up --build --force-recreate

.PHONY: test_erlang25
test_erlang25:
	openssl s_client -connect localhost:25272 || true

.PHONY: test_erlang26
test_erlang26:
	openssl s_client -connect localhost:26272 || true

.PHONY: clean
clean:
	cd tls_gen && git clean -xfd
