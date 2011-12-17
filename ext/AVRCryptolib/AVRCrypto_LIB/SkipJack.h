#ifndef __SKIPJACK_H__
#define __SKIPJACK_H__

#define SKIPJACK_BLOCK_SIZE 8
#define SKIPJACK_KEY_SIZE 10

void SkipJack_Enc(void* block, void* key);
void SkipJack_Dec(void* block, void* key);

#endif //__SKIPJACK_H__
