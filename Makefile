# Vote BDE-UTC
# Under AGPL license
# @author Matthieu Guffroy

#OPA_bin=~/opa_bin/bin/
OPA=opa
OPT=--opx-dir _build_o --parser classic
OPT-js=--opx-dir _build_js --database mongo
FILES=$(shell find src -name '*.opa')
FILES-JS=$(shell find src_jslike -name '*.opa')
EXE=main.exe
EXE-MONGO=main.js.exe

all: $(FILES)
	$(OPA_bin)$(OPA) $^ -o $(EXE) $(OPT)

all-js: $(FILES-JS)
	$(OPA_bin)$(OPA) $^ -o $(EXE-JS) $(OPT-js)

run:
	./$(EXE) --db-local db/db --db-force-upgrade --pidfile resa.pid --base-url resa	--port 8081 &

run-mongo:
	./$(EXE-MONGO) --db-remote sql.mde.utc --pidfile resa-mongo.pid --base-url resa --port 8083 &

translate: $(FILES)
	opa-translate --parser classic --printer js-like $^ --build-dir src_jslike

stop:
	kill $(shell cat resa.pid)

stop-mongo:
	kill $(shell cat resa-mongo.pid)

reload: all stop run

clean:
	rm -rf *.opx *.opx.broken *.opp
	rm -f *.exe
	rm -rf doc
	rm -rf _build _tracks
	rm -f *.log
	rm -f *.apix
	rm -f src/*.api
	rm -rf *.opp
	rm -f src/*.api-txt
