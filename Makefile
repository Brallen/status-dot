PREFIX ?= /usr/local
BINARY_NAME = status-dot-daemon
CLI_NAME = status-dot
LAUNCH_AGENT_LABEL = com.statusdot.agent
LAUNCH_AGENT_DIR = $(HOME)/Library/LaunchAgents
LAUNCH_AGENT_PLIST = $(LAUNCH_AGENT_DIR)/$(LAUNCH_AGENT_LABEL).plist
LOG_DIR = $(HOME)/Library/Logs
LOG_PATH = $(LOG_DIR)/status-dot-daemon.log

.PHONY: build install uninstall start stop restart status clean

build:
	swift build -c release

install: build
	@mkdir -p $(PREFIX)/bin
	cp .build/release/$(BINARY_NAME) $(PREFIX)/bin/$(BINARY_NAME)
	cp bin/$(CLI_NAME) $(PREFIX)/bin/$(CLI_NAME)
	chmod +x $(PREFIX)/bin/$(CLI_NAME)
	@mkdir -p $(LAUNCH_AGENT_DIR)
	@mkdir -p $(LOG_DIR)
	sed -e 's|__DAEMON_PATH__|$(subst &,\&,$(PREFIX))/bin/$(BINARY_NAME)|g' \
	    -e 's|__LOG_PATH__|$(subst &,\&,$(LOG_PATH))|g' \
	    com.statusdot.agent.plist > $(LAUNCH_AGENT_PLIST)

uninstall: stop
	rm -f $(PREFIX)/bin/$(BINARY_NAME)
	rm -f $(PREFIX)/bin/$(CLI_NAME)
	rm -f $(LAUNCH_AGENT_PLIST)

start:
	launchctl load $(LAUNCH_AGENT_PLIST) 2>/dev/null || true
	launchctl start $(LAUNCH_AGENT_LABEL) 2>/dev/null || true

stop:
	launchctl stop $(LAUNCH_AGENT_LABEL) 2>/dev/null || true
	launchctl unload $(LAUNCH_AGENT_PLIST) 2>/dev/null || true

restart: stop start

status:
	@launchctl list | grep $(LAUNCH_AGENT_LABEL) && echo "Running" || echo "Not running"

clean:
	swift package clean
	rm -rf .build
