PKG_BUILD     = 1
PKG_REVISION ?= $(shell git describe --all)
PKG_VERSION	 ?= 1.7.0
PKG_ID        = topup-gateway-$(PKG_VERSION)
PKG_BASE_DIR  = package
REBAR        ?= rebar3

.PHONY: all rel rel-dev rel-prod

###-----------------------------------------------------------------------------
### COMMON TARGETS
###-----------------------------------------------------------------------------
all: rel

clean:
	$(REBAR) clean

clean-all:
	rm -rf _build
	rm -rf apps/**/_gen
	rm -rf $(PKG_BASE_DIR)
	rm -rf packages
	rm topup-gateway-dbgsym_$(PKG_VERSION)-$(PKG_BUILD)_amd64.ddeb
	rm topup-gateway_$(PKG_VERSION)-$(PKG_BUILD)_amd64.build
	rm topup-gateway_$(PKG_VERSION)-$(PKG_BUILD)_amd64.buildinfo
	rm topup-gateway_$(PKG_VERSION)-$(PKG_BUILD)_amd64.changes

compile:
	$(REBAR) compile

distclean: clean
	rm -rf _build
	@rm -rf $(PKG_ID).tar.gz

get-deps:
	$(REBAR) get-deps

rel: rel-default

rel-default: REL_PROFILE = default
rel-default: release

rel-dev: REL_PROFILE = dev
rel-dev: release

rel-local: REL_PROFILE = local
rel-local: release

rel-prod: REL_PROFILE = prod
rel-prod: release

rel-test: REL_PROFILE = test
rel-test: release

release:
	$(REBAR) as $(REL_PROFILE) release

###-----------------------------------------------------------------------------
### LOCAL BALANCE DATABASE TARGETS
###-----------------------------------------------------------------------------
bdb-up:
	(cd apps/balance_db/scripts/ && ./local_mongo_db.sh up)

bdb-down:
	(cd apps/balance_db/scripts/ && ./local_mongo_db.sh down)
###-----------------------------------------------------------------------------
### PACKAGING TARGETS
###-----------------------------------------------------------------------------
.PHONY: package package-dev package-prod
export PKG_BUILD PKG_ID PKG_VERSION

package: package-prod

package-dev: PKG_PROFILE = dev
package-dev: PKG_REL = rel-dev
package-dev: pkg

package-prod: PKG_PROFILE = prod
package-prod: PKG_REL = rel-prod
package-prod: pkg

pkg: pkgclean
	$(eval export PKG_PROFILE)
	mkdir -p $(PKG_BASE_DIR)
	rm -rf $(PKG_BASE_DIR)/$(PKG_ID)
	git archive --format=tar --prefix=$(PKG_ID)/ $(PKG_REVISION)| (cd $(PKG_BASE_DIR) && tar -xf -)
	${MAKE} -C $(PKG_BASE_DIR)/$(PKG_ID) $(PKG_REL)
	tar -C $(PKG_BASE_DIR) -czf $(PKG_BASE_DIR)/$(PKG_ID).tar.gz $(PKG_ID)
	$(REBAR) node_package

pkgclean: distclean
	rm -rf $(PKG_BASE_DIR)
	rm -rf rebar.lock

###-----------------------------------------------------------------------------
### TEST TARGETS
###-----------------------------------------------------------------------------
.PHONY: test

cover: test
	$(REBAR) cover --verbose
	open _build/test/cover/index.html

test: test-balance test-tsira test-apirest # test-multinode

test-apirest: test-clean
	$(REBAR) ct --cover $(VERBOSE_PARAM) --cover_export_name=apirestcover --dir=apps/apirest/test/ \
	--name='node1@127.0.0.1' --spec=apps/apirest/test/conf/test.spec

test-apirest-verbose: VERBOSE_PARAM = --verbose
test-apirest-verbose: test-apirest

test-balance: test-clean
	$(REBAR) ct --cover $(VERBOSE_PARAM) --cover_export_name=balancecover --dir=apps/balance_db/test/ \
	--name='node1@127.0.0.1' --spec=apps/balance_db/test/conf/test.spec

test-balance-verbose: VERBOSE_PARAM = --verbose
test-balance-verbose: test-balance

test-clean:
	rm -rf _build/test
	rm -rf apps/**/_gen

test-tsira: test-clean
	$(REBAR) ct --cover $(VERBOSE_PARAM) --cover_export_name=tsiracover --dir=apps/tsira/test/ \
	--name='node1@127.0.0.1' --spec=apps/tsira/test/conf/test.spec

test-tsira-verbose: VERBOSE_PARAM = --verbose
test-tsira-verbose: test-tsira

test-verbose: test-balance-verbose test-tsira-verbose test-apirest-verbose # test-multinode

###-----------------------------------------------------------------------------
### OLD TARGETS
###-----------------------------------------------------------------------------
BASE_DIR      = $(shell pwd)
ERLANG_BIN    = $(shell dirname $(shell which erl))
OVERLAY_VARS ?=

test-multinode: test-clean test-multinode-up test-multinode-down

test-multinode-up: test-clean
	mkdir -p test/multinode/docker/logs
	mkdir -p test/multinode/docker/balance_mongo4
	$(REBAR) as test docker-build -b multinode-test-ubuntu20-erlang23
	cd apps/tsira/test/stubs/tsira_server && $(REBAR) docker-build -b ubuntu20-erlang23 && cd -
	docker-compose -f test/multinode/docker/docker-compose.yml up -d --force-recreate
	sleep 40
	test/multinode/scripts/multinode_tests
	test/multinode/scripts/multinode_show_logs

test-multinode-logs:
	test/multinode/scripts/multinode_show_logs

test-multinode-down:
	docker-compose -f test/multinode/docker/docker-compose.yml down

run-stub-rel:
	rm -rf _build/stub
	${MAKE} stub
	rm -rf _build/stub/rel/topup-gateway/etc/topup-gateway.conf
	cp test/stub-topup-gateway.conf _build/stub/rel/topup-gateway/etc/topup-gateway.conf
	_build/stub/rel/topup-gateway/bin/topup-gateway console

stub:
	$(REBAR) as stub release

.PHONY: package
export BASE_DIR ERLANG_BIN REBAR OVERLAY_VARS

stub-package.src: pkgclean
	$(eval PKG_PROFILE = default)
	$(eval export PKG_PROFILE)
	mkdir -p $(PKG_BASE_DIR)
	rm -rf $(PKG_BASE_DIR)/$(PKG_ID)
	git archive --format=tar --prefix=$(PKG_ID)/ $(PKG_REVISION)| (cd $(PKG_BASE_DIR) && tar -xf -)
	${MAKE} -C $(PKG_BASE_DIR)/$(PKG_ID) stub
	tar -C $(PKG_BASE_DIR) -czf $(PKG_BASE_DIR)/$(PKG_ID).tar.gz $(PKG_ID)

stub-package: stub-package.src
	$(REBAR) node_package

rel_stub:
	cd apps/tsira/test/stubs/tsira_server && \
	$(REBAR) release && \
	cd -

start_stub: rel_stub
	cd apps/tsira/test/stubs/tsira_server && \
	_build/default/rel/tsira_server/bin/tsira_server daemon && \
	cd -

stop_stub:
	cd apps/tsira/test/stubs/tsira_server && \
	_build/default/rel/tsira_server/bin/tsira_server stop && \
	cd -

local_start:
	_build/default/rel/topup-gateway/bin/topup-gateway foreground &

local_attach:
	_build/default/rel/topup-gateway/bin/topup-gateway remote_console

local_stop:
	_build/default/rel/topup-gateway/bin/topup-gateway stop

start_graylog:
	docker-compose -f test/ci/docker-compose-graylog.yml up

stop_graylog:
	docker-compose -f test/ci/docker-compose-graylog.yml down

local_deploy: start_stub rel local_start

local_undeploy: local_stop stop_stub

bdb-up-ci:
	(cd test/ci/ && ./ci_mongo_db.sh up)

bdb-down-ci:
	(cd test/ci/ && ./ci_mongo_db.sh down)