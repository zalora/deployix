#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <err.h>
#include <inttypes.h>

static char hex_to_nibble(char hex) {
  switch (hex) {
    case '0': return 0x0;
    case '1': return 0x1;
    case '2': return 0x2;
    case '3': return 0x3;
    case '4': return 0x4;
    case '5': return 0x5;
    case '6': return 0x6;
    case '7': return 0x7;
    case '8': return 0x8;
    case '9': return 0x9;
    case 'a': return 0xa;
    case 'b': return 0xb;
    case 'c': return 0xc;
    case 'd': return 0xd;
    case 'e': return 0xe;
    default:  return 0xf;
  }
}

/* UB if hash is shorter than sizeof(TARGET_ID_T) */
static TARGET_ID_T calculate_id(const char * hash) {
  size_t binary_hash_len = strlen(hash) / 2;

  char binary_hash[binary_hash_len];

  for (size_t i = 0; i < binary_hash_len; ++i)
    binary_hash[i] = (hex_to_nibble(hash[i * 2]) << 4) | hex_to_nibble(hash[i * 2 + 1]);

  TARGET_ID_T * result = (TARGET_ID_T *) binary_hash;

  return *result;
}

int main(int argc, char ** argv) {
  TARGET_ID_T id = calculate_id(argv[1]);

  FILE * out = fopen(getenv("out"), "w");

  /* No need to error check out: if it fails, fprintf will fail */

  if (fprintf(out, "%" TARGET_ID_T_FORMAT, id) < 0)
    err(1, "Writing to %s", getenv("out"));

  return 0;
}
