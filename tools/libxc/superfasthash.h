#ifndef SUPERFASTHASH_H
#define SUPERFASTHASH_H

#include <stdint.h>

uint32_t hash(unsigned char * data, int len);
uint32_t hash_inc(unsigned char * data, int len, uint32_t hash);

#endif
