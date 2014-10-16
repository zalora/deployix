#include <stddef.h>

struct activation_header_sizes {
  size_t filename_size;
  size_t symbol_size;
};

#define activation_header(f_sz, s_sz) \
  struct { \
    struct activation_header_sizes sizes; \
    char filename[(f_sz)]; \
    char symbol[(s_sz)]; \
  }

