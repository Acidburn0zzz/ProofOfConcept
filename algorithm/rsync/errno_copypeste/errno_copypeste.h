/*--------------------------------------------------------------------*/
/*		     Epitech EIP 2017 groupe Copypeste		      */
/*								      */
/*			    Algo Levenshtein			      */
/*								      */
/* @by :	Guillaume Krier					      */
/* @created :	19/09/2015					      */
/* @update :	19/09/201					      */
/*--------------------------------------------------------------------*/
#pragma once

/*\* INCLUDES *\*/
#include <stdio.h>
#include <stdlib.h>

/*\* GLOBAL VARIABLES *\*/
extern int verbose_error; // TRUE
extern int verbose_message; // TRUE

/*\* DEFINES *\*/
#define CB_VERBOSE_ERR(verb) (verbose_error = verb)
#define CB_VERBOSE_MSG(verb) (verbose_message = verb)

#define MSG_ERROR "Error\n File:%s|Line:%d\n"

#define CP_errno_arg(error, ...) if (verbose_error) { fprintf( stderr, MSG_ERROR error, __FILE__, (__LINE__ - 1), ##__VA_ARGS__ ); }
#define CP_errno(error) CP_errno_arg("%s", "" error "")

#define CP_message_arg(msg, ...) if (verbose_message) { printf( msg, ##__VA_ARGS__ ); }
#define CP_message(msg) CP_message_arg("%s", "" msg ""); 
