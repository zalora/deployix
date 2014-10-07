#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <err.h>
#include <inttypes.h>

struct hardcoded_id {
  TARGET_ID_T id;
  char * name;
};

struct hardcoded_id hardcodes[] = { HARDCODES_INIT };

static TARGET_ID_T calculate_id(const char * name) {
  for (size_t i = 0; i < (sizeof hardcodes)/(sizeof hardcodes[0]); ++i)
    if (strcmp(name, hardcodes[i].name) == 0)
      return hardcodes[i].id;

  TARGET_ID_T result = 0;

  size_t name_len = strlen(name);
  size_t result_len = sizeof result;
  size_t max = name_len < result_len ? name_len : result_len;
  for (size_t i = 0; i < max; ++i)
    result += ((TARGET_ID_T) name[i]) << i * 8;

  return result;
}

int main(int argc, char ** argv) {
  TARGET_ID_T id = calculate_id(argv[1]);

  FILE * out = fopen(getenv("out"), "w");

  if (!out)
    err(1, "Opening %s", getenv("out"));

  if (fprintf(out, TARGET_ID_T_FORMAT, id) < 0)
    err(1, "Writing to %s", getenv("out"));

  return 0;
}
