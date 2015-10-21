## Makefile
## Epitech EIP 2017 groupe Copypeste
## @by : Guillaume Krier

CC =		gcc

RM =		rm -f

CFLAGS +=	-Wextra -Wall -Werror
CFLAGS +=	-pedantic -std=gnu99
CFLAGS +=	-I./includes \
		-I./message_digest \
		-I./compare \
		-I./errno_copypeste \

NAME =		my_rsync

SRCS =		main.c \
\
		./compare/compare_files_match.c \
\
		./message_digest/mdfour.c \
		./message_digest/md5.c \
		./message_digest/cp_md5.c \

OBJS =		$(SRCS:.c=.o)

all:		$(NAME)

opo:		CFLAGS += -DONE_PER_ONE 
opo:		$(NAME)

md5:		CFLAGS += -DMD5_OPENSSL
md5:		MY_FLAGS = -lssl -lcrypto
md5:		$(NAME)

opo_md5:	CFLAGS += -DMD5_OPENSSL -DONE_PER_ONE
opo_md5:	MY_FLAGS = -lssl -lcrypto
opo_md5:	$(NAME)

$(NAME):	$(OBJS)
		$(CC) $(OBJS) -o $(NAME) $(MY_FLAGS)

clean:
		$(RM) $(OBJS)

fclean:		clean
		$(RM) $(NAME)

re:		fclean all

reopo:		fclean opo

remd5:		fclean md5

reopo_md5:	fclean opo_md5

.PHONY:		all clean fclean re
