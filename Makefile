CC=gcc
CCFLAGS=-O3
YACC=yacc
YFLAGS=-d	# force creation of y.tab.h
TGT=hoc4
OBJS=y.tab.o code.o init.o math.o symbol.o
YACCSRC=hoc.y

${TGT}:	${OBJS}
	${CC} ${CCFLAGS} ${OBJS} -o ${TGT} -lm

y.tab.o:	y.tab.c y.tab.h
	${CC} ${CCFLAGS} -c y.tab.c

code.o:	y.tab.h
	${CC} ${CCFLAGS} -c code.c

init.o:	y.tab.h
	${CC} ${CCFLAGS} -c init.c

symbol.o:	y.tab.h
	${CC} ${CCFLAGS} -c symbol.c

math.o:	math.c
	${CC} ${CCFLAGS} -c math.c -lm

y.tab.h y.tab.c:	hoc.y
	${YACC} ${YFLAGS} hoc.y

clean:
	rm ${OBJS} ${TGT} y.tab.[ch]
