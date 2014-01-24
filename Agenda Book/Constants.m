#ifdef STR_CONST
#undef STR_CONST
#endif
#define STR_CONST(name, value) NSString *const name = @value
#include "ConstantList.h"
