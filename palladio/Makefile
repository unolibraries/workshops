HANDOUTS := $(patsubst %.md,%.md.handout.pdf,$(wildcard *.md))

all : $(HANDOUTS)

%.md.handout.pdf : %.md
	pandoc $^ -o $@ 
		
clobber : 
	rm -f $(HANDOUTS)
