# Vote BDE-UTC
# Under AGPL license
# @author Matthieu Guffroy

#OPA_bin=~/opa_bin/bin/
OPA=opa
OPT=--opx-dir _build_o --parser classic
FILES=$(shell find src -name '*.opa')
EXE=main.exe

all: $(FILES)
	$(OPA_bin)$(OPA) $^ -o $(EXE) $(OPT)

run:
	./$(EXE) --db-local db/db --db-force-upgrade --pidfile vote.pid --base-url vote	&

stop:
	kill $(shell cat vote.pid)
	sleep 4

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
