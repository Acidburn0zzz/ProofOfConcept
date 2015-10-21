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
#include "copypeste.h"

#if defined(MD5_OPENSSL)
/* #include <openssl/ssl.h> */
#include <openssl/md5.h>
#endif /* MD5_OPENSSL */
#include "mdigest.h"

/*\* TYPEDEF *\*/
#if defined(MD5_OPENSSL)
typedef MD5_CTX cp_md5_ctx;
#else
typedef md_context cp_md5_ctx;
#endif /* MD5_OPENSSL */

/*\* DEFINES *\*/
#define MAX_CP_MD_LEN 16

/*\* PROTOTYPES *\*/
void cp_md5_init(cp_md5_ctx *ctx);
void cp_md5_update(cp_md5_ctx *ctx, const uchar *input, uint32 length);
void cp_md5_final(cp_md5_ctx *ctx, uchar *digest);
