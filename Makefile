.PHONY: all
all: setup start

.PHONY: perms
perms:
	sudo chown -R "$$(id -u):$$(id -g)" .

.PHONY: setup
setup:
	@echo "Setup git submodules"
	git submodule update --init
	@echo "Setup certificates"
	make -C $(CURDIR)/tls-gen/basic CN=rabbitmq.mydomain.local
	chmod 666 $(CURDIR)/tls-gen/basic/result/*
	sudo chown root:root $(CURDIR)/docker/config/00-rabbitmq-sudo

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
	echo Q | openssl s_client -connect localhost:25272 \
		-CAfile $(CURDIR)/tls-gen/basic/result/ca_certificate.pem \
		-cert $(CURDIR)/tls-gen/basic/result/client_rabbitmq.mydomain.local_certificate.pem \
		-key $(CURDIR)/tls-gen/basic/result/client_rabbitmq.mydomain.local_key.pem \
		-servername rabbitmq.mydomain.local

.PHONY: test_erlang26_rmq312
test_erlang26_rmq312:
	echo Q | openssl s_client -connect localhost:26272 \
		-CAfile $(CURDIR)/tls-gen/basic/result/ca_certificate.pem \
		-cert $(CURDIR)/tls-gen/basic/result/client_rabbitmq.mydomain.local_certificate.pem \
		-key $(CURDIR)/tls-gen/basic/result/client_rabbitmq.mydomain.local_key.pem \
		-servername rabbitmq.mydomain.local

.PHONY: test_erlang26_rmq313
test_erlang26_rmq313:
	echo Q | openssl s_client -connect localhost:36272 \
		-CAfile $(CURDIR)/tls-gen/basic/result/ca_certificate.pem \
		-cert $(CURDIR)/tls-gen/basic/result/client_rabbitmq.mydomain.local_certificate.pem \
		-key $(CURDIR)/tls-gen/basic/result/client_rabbitmq.mydomain.local_key.pem \
		-servername rabbitmq.mydomain.local

.PHONY: clean
clean:
	docker compose down
	cd tls-gen && git clean -xfd
