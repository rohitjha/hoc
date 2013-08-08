CC=gcc
YACC=yacc
TGT=hoc2
OBJS=y.tab.o
CSRC=y.tab.c
YACCSRC=hoc.y

${TGT}:	${OBJS}
	${CC} ${OBJS} -o ${TGT}

${OBJS}:	${CSRC}
	${CC} -c ${CSRC}

${CSRC}:	${YACCSRC}
	${YACC} ${YACCSRC}

clean:
	rm ${OBJS} ${CSRC} ${TGT}
