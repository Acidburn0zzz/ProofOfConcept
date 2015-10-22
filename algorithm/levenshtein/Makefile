CC	=	gcc
RM	=	rm -f
LIB_NAME=	algorithms.so

SRCS	=	levenshtein.c

CFLAGS	+=	-std=c99 -Wall -Wextra -fmax-errors=2

all:		$(LIB_NAME)

$(LIB_NAME):	
		$(CC) -shared -o $(LIB_NAME) -fPIC $(SRCS) $(CFLAGS)

clean:
		$(RM) $(LIB_NAME)

re:		fclean all

.PHONY:		all clean re
