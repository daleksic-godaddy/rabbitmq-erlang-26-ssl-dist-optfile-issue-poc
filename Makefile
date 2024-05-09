.PHONY: all
all: init start test_all

##
## ======== Setup
##

.PHONY: init
init:
	@echo "=> Init git submodules"
	git submodule update --init

	@echo "=> Init certificates"
	if [ ! -f "ansible/files/rmq312-er25.mydomain.local/ca_certificate.pem" ]; then \
		cd tls-gen/two_shared_intermediates && \
		make CN=rmq312-er25.mydomain.local; \
		cp -r result/* ../../ansible/files/rmq312-er25.mydomain.local; \
	fi

	if [ ! -f "ansible/files/rmq312-er26.mydomain.local/ca_certificate.pem" ]; then \
		cd tls-gen/two_shared_intermediates && \
		make CN=rmq312-er26.mydomain.local; \
		cp -r result/* ../../ansible/files/rmq312-er26.mydomain.local; \
	fi

	if [ ! -f "ansible/files/rmq313-er26.mydomain.local/ca_certificate.pem" ]; then \
		cd tls-gen/two_shared_intermediates && \
		make CN=rmq313-er26.mydomain.local; \
		cp -r result/* ../../ansible/files/rmq313-er26.mydomain.local; \
	fi

	if [ ! -f "ansible/files/_.mydomain.local/ca_certificate.pem" ]; then \
		cd tls-gen/two_shared_intermediates && \
		make CN=*.mydomain.local; \
		cp -r result/* ../../ansible/files/_.mydomain.local; \
	fi


.PHONY: start
start:
	@echo "=> Start vagrant"
	vagrant up --provision

##
## ======== Test
##

.PHONY: test_rmq312_er25
test_rmq312_er25:
	@echo "\\n"
	@echo "========================================="
	@echo "=> RABBITMQ 3.12 - ERLANG 25"
	@echo "========================================="
	@echo "\\n=> Test rmq312-er25: Check served certificate on inter-node communication port 25672"
	openssl s_client \
		-connect rmq312-er25.mydomain.local:25672 \
		-cert ansible/files/rmq312-er25.mydomain.local/client_certificate.pem \
		-key ansible/files/rmq312-er25.mydomain.local/client_key.pem \
		-CAfile ansible/files/rmq312-er25.mydomain.local/chained_ca_certificate.pem \
		-verify_depth 8 \
		-verify_hostname rmq312-er25.mydomain.local \
	|| true

	@echo "\\n=> Test rmq312-er25: Check rabbitmqctl status execution"
	vagrant ssh rmq312_er25 -c "sudo rabbitmqctl status" || true

.PHONY: test_rmq312_er26
test_rmq312_er26:
	@echo "\\n"
	@echo "========================================="
	@echo "      RABBITMQ 3.12 - ERLANG 26"
	@echo "========================================="
	@echo "\\n=> Test rmq312-er26: Check served certificate on inter-node communication port 25672"
	openssl s_client \
		-connect rmq312-er26.mydomain.local:25672 \
		-cert ansible/files/rmq312-er26.mydomain.local/client_certificate.pem \
		-key ansible/files/rmq312-er26.mydomain.local/client_key.pem \
		-CAfile ansible/files/rmq312-er26.mydomain.local/chained_ca_certificate.pem \
		-verify_depth 8 \
		-verify_hostname rmq312-er26.mydomain.local \
	|| true

	@echo "\\n=> Test rmq312-er26: Check rabbitmqctl status execution"
	vagrant ssh rmq312_er26 -c "sudo rabbitmqctl status" || true

.PHONY: test_rmq313_er26
test_rmq313_er26:
	@echo "\\n"
	@echo "========================================="
	@echo "=> RABBITMQ 3.13 - ERLANG 26"
	@echo "========================================="
	@echo "\\n=> Test rmq313-er26: Check served certificate on inter-node communication port 25672"
	openssl s_client \
		-connect rmq313-er26.mydomain.local:25672 \
		-cert ansible/files/rmq313-er26.mydomain.local/client_certificate.pem \
		-key ansible/files/rmq313-er26.mydomain.local/client_key.pem \
		-CAfile ansible/files/rmq313-er26.mydomain.local/chained_ca_certificate.pem \
		-verify_depth 8 \
		-verify_hostname rmq313-er26.mydomain.local \
	|| true

	@echo "\\n=> Test rmq313-er26: Check rabbitmqctl status execution"
	vagrant ssh rmq313_er26 -c "sudo rabbitmqctl status" || true

.PHONY: test_all
test_all: test_rmq312_er25 test_rmq312_er26 test_rmq313_er26