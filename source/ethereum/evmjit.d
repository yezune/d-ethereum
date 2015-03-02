module ethereum.evmjit;

import std.bigint;
import std.format;

nothrow extern (C)
{

void* evmjit_create();
int   evmjit_run(void* _jit, void* _data, void* _env);
void  evmjit_destroy(void* _jit);

}


unittest {

	//auto jit = evmjit_create();
	//auto data = null;
	//auto ret = evmjit_run(jit, data, null);
	//evmjit_destroy(jit);

}