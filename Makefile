CC=gcc
YACC=yacc
YFLAGS=-d	# force creation of y.tab.h
TGT=hoc3
OBJS=y.tab.o init.o math.o symbol.o
CSRC=y.tab.c
YACCSRC=hoc.y

${TGT}:	${OBJS}
	${CC} ${OBJS} -o ${TGT} -lm

#need to check hoc.o
hoc.o:	y.tab.c y.tab.h hoc.h
	${CC} -c y.tab.c y.tab.h hoc.h

init.o:	init.c hoc.h y.tab.h
	${CC} -c init.c

symbol.o:	symbol.c hoc.h y.tab.h
	${CC} -c symbol.c

math.o:	math.c
	${CC} -c math.c -lm

y.tab.h y.tab.c:	hoc.y
	${YACC} ${YFLAGS} hoc.y

clean:
	rm ${OBJS} ${TGT} y.tab.[ch]
