/*--------------------------------------------------------------------*/
/*		     Epitech EIP 2017 groupe Copypeste		      */
/*								      */
/*			    Algo Levenshtein			      */
/* developed by :						      */
/* Edouard Marechal						      */
/* Amina Ourouba						      */
/*--------------------------------------------------------------------*/

#include "main.h"

int	main(int ac, char **av) {

  int result = levenshtein(av[1], av[2]);
  printf("result = %d\n", result);
}
