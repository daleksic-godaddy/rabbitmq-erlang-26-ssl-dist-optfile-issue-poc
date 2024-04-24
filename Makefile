.PHONY: all
all: setup start

.PHONY: setup
setup:
	@echo "Setup git submodules"
	git submodule update --init
	@echo "Setup certificates"
	make -C $(CURDIR)/tls-gen/basic CN=rabbitmq.mydomain.local
	chmod 666 $(CURDIR)/tls-gen/basic/result/*

.PHONY: start
start:
	docker compose up --build

.PHONY: stop
stop:
	docker compose down

.PHONY: start_recreated
start_recreated:
	docker compose up --build --force-recreate

.PHONY: test_erlang25_rmq312
test_erlang25_rmq312:
	openssl s_client -connect localhost:25272 || true

.PHONY: test_erlang26_rmq312
test_erlang26_rmq312:
	openssl s_client -connect localhost:26272 || true

.PHONY: test_erlang26_rmq313
test_erlang26_rmq313:
	openssl s_client -connect localhost:36272 || true

.PHONY: clean
clean:
	docker compose down
	cd tls_gen && git clean -xfd
