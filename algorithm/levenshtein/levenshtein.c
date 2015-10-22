/*--------------------------------------------------------------------*/
/*		     Epitech EIP 2017 groupe Copypeste		      */
/*								      */
/*			    Algo Levenshtein			      */
/* developed by :						      */
/* Edouard Marechal						      */
/* Amina Ourouba						      */
/*--------------------------------------------------------------------*/

#include <string.h>
#include <stdint.h>
#include "levenshtein.h"

int	levenshtein(char *string1, char *string2)
{
  int32_t	firstWord = strlen(string1);
  int32_t	secondWord = strlen(string2);
  int32_t	matrice[MAXWORD][MAXWORD];
  int32_t	i = 0;
  int32_t	j = 0;

  /* Il faudrait le faire 1 seule fois */  
  while (i < MAXWORD)
    {
      matrice[i][0] = i;
      matrice[0][i] = i;
      i++;
    }
  /**************************************/

  /* algo complet */
  i = 1;
  j = 1;
  while (i < firstWord+1) 
    {
      while (j < secondWord+1) 
	{
	  if (string1[i-1] == string2[j-1])
	    matrice[i][j] = matrice[i-1][j-1];
	  else if (matrice[i-1][j] <= matrice[i][j-1] && matrice[i-1][j] <= matrice[i-1][j-1])
	    matrice[i][j] = matrice[i-1][j] + 1;
	  else if (matrice[i][j-1] < matrice[i-1][j] && matrice[i][j-1] < matrice[i-1][j-1])
	    matrice[i][j] = matrice[i][j-1] + 1;
	  else
	    matrice[i][j] = matrice[i-1][j-1] + 1;
	  j++;
	}
      i++;
      j = 1;
    }
  return (matrice[firstWord][secondWord]);
}
