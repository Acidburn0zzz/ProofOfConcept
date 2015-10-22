CC	=	gcc
RM	=	rm -f
LIB_NAME=	algorithms.so

SRCS	=	levenshtein.c

CFLAGS +=	-Wextra -Wall -Werror
CFLAGS +=	-pedantic -std=gnu99

CFLAGS +=	-Wextra -Wall -Werror
CFLAGS +=	-pedantic -std=gnu99
CGLAGS +=	-fmax-errors=2

all:		$(LIB_NAME)

$(LIB_NAME):	
		$(CC) -shared -o $(LIB_NAME) -fPIC $(SRCS) $(CFLAGS)

clean:
		$(RM) $(LIB_NAME)

re:		clean all

.PHONY:		all clean re
