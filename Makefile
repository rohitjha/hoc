hoc1:	y.tab.o
	cc y.tab.o -o hoc1

y.tab.o:	y.tab.c
	cc -c y.tab.c

y.tab.c:	hoc.y
	yacc hoc.y

clean:
	rm *.o y.tab.c hoc1
