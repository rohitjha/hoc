CC=gcc
YACC=yacc
YFLAGS=-d	# force creation of y.tab.h
TGT=hoc4
OBJS=y.tab.o code.o init.o math.o symbol.o
#CSRC=y.tab.c
YACCSRC=hoc.y

${TGT}:	${OBJS}
	${CC} ${OBJS} -o ${TGT} -lm

y.tab.o:	y.tab.c y.tab.h
	${CC} -c y.tab.c

code.o:	y.tab.h
	${CC} -c code.c

init.o:	y.tab.h
	${CC} -c init.c

symbol.o:	y.tab.h
	${CC} -c symbol.c

math.o:	math.c
	${CC} -c math.c -lm

y.tab.h y.tab.c:	hoc.y
	${YACC} ${YFLAGS} hoc.y

clean:
	rm ${OBJS} ${TGT} y.tab.[ch]
