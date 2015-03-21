module ethereum.evm;
/**
EVM(Ethereum Virtual Machine) 
   if you want a formal information then you see Gavin Wood's yellow paper.
   (http://gavwood.com/Paper.pdf - Appendix H. Virtual Machine Specification)
*/

import std.bigint:BigInt;
import ethereum.common;
//import std.string;

/// Virtual machine bytecode instruction.
enum OpCode:ubyte {
	STOP = 0x00,		///< halts execution
	ADD,				///< addition operation
	MUL,				///< mulitplication operation
	SUB,				///< subtraction operation
	DIV,				///< integer division operation
	SDIV,				///< signed integer division operation
	MOD,				///< modulo remainder operation
	SMOD,				///< signed modulo remainder operation
	ADDMOD,				///< unsigned modular addition
	MULMOD,				///< unsigned modular multiplication
	EXP,				///< exponential operation
	SIGNEXTEND,			///< extend length of signed integer

	LT = 0x10,			///< less-than comparision
	GT,					///< greater-than comparision
	SLT,				///< signed less-than comparision
	SGT,				///< signed greater-than comparision
	EQ,					///< equality comparision
	ISZERO,				///< simple not operator
	AND,				///< bitwise AND operation
	OR,					///< bitwise OR operation
	XOR,				///< bitwise XOR operation
	NOT,				///< bitwise NOT opertation
	BYTE,				///< retrieve single byte from word

	SHA3 = 0x20,		///< compute SHA3-256 hash

	ADDRESS = 0x30,		///< get address of currently executing account
	BALANCE,			///< get balance of the given account
	ORIGIN,				///< get execution origination address
	CALLER,				///< get caller address
	CALLVALUE,			///< get deposited value by the instruction/transaction responsible for this execution
	CALLDATALOAD,		///< get input data of current environment
	CALLDATASIZE,		///< get size of input data in current environment
	CALLDATACOPY,		///< copy input data in current environment to memory
	CODESIZE,			///< get size of code running in current environment
	CODECOPY,			///< copy code running in current environment to memory
	GASPRICE,			///< get price of gas in current environment
	EXTCODESIZE,		///< get external code size (from another contract)
	EXTCODECOPY,		///< copy external code (from another contract)

	BLOCKHASH = 0x40,	///< get hash of most recent complete block
	COINBASE,			///< get the block's coinbase address
	TIMESTAMP,			///< get the block's timestamp
	NUMBER,				///< get the block's number
	DIFFICULTY,			///< get the block's difficulty
	GASLIMIT,			///< get the block's gas limit

	POP = 0x50,			///< remove item from stack
	MLOAD,				///< load word from memory
	MSTORE,				///< save word to memory
	MSTORE8,			///< save byte to memory
	SLOAD,				///< load word from storage
	SSTORE,				///< save word to storage
	JUMP,				///< alter the program counter
	JUMPI,				///< conditionally alter the program counter
	PC,					///< get the program counter
	MSIZE,				///< get the size of active memory
	GAS,				///< get the amount of available gas
	JUMPDEST,			///< set a potential jump destination

	PUSH1 = 0x60,		///< place 1 byte item on stack
	PUSH2,				///< place 2 byte item on stack
	PUSH3,				///< place 3 byte item on stack
	PUSH4,				///< place 4 byte item on stack
	PUSH5,				///< place 5 byte item on stack
	PUSH6,				///< place 6 byte item on stack
	PUSH7,				///< place 7 byte item on stack
	PUSH8,				///< place 8 byte item on stack
	PUSH9,				///< place 9 byte item on stack
	PUSH10,				///< place 10 byte item on stack
	PUSH11,				///< place 11 byte item on stack
	PUSH12,				///< place 12 byte item on stack
	PUSH13,				///< place 13 byte item on stack
	PUSH14,				///< place 14 byte item on stack
	PUSH15,				///< place 15 byte item on stack
	PUSH16,				///< place 16 byte item on stack
	PUSH17,				///< place 17 byte item on stack
	PUSH18,				///< place 18 byte item on stack
	PUSH19,				///< place 19 byte item on stack
	PUSH20,				///< place 20 byte item on stack
	PUSH21,				///< place 21 byte item on stack
	PUSH22,				///< place 22 byte item on stack
	PUSH23,				///< place 23 byte item on stack
	PUSH24,				///< place 24 byte item on stack
	PUSH25,				///< place 25 byte item on stack
	PUSH26,				///< place 26 byte item on stack
	PUSH27,				///< place 27 byte item on stack
	PUSH28,				///< place 28 byte item on stack
	PUSH29,				///< place 29 byte item on stack
	PUSH30,				///< place 30 byte item on stack
	PUSH31,				///< place 31 byte item on stack
	PUSH32,				///< place 32 byte item on stack

	DUP1 = 0x80,		///< copies the highest item in the stack to the top of the stack
	DUP2,				///< copies the second highest item in the stack to the top of the stack
	DUP3,				///< copies the third highest item in the stack to the top of the stack
	DUP4,				///< copies the 4th highest item in the stack to the top of the stack
	DUP5,				///< copies the 5th highest item in the stack to the top of the stack
	DUP6,				///< copies the 6th highest item in the stack to the top of the stack
	DUP7,				///< copies the 7th highest item in the stack to the top of the stack
	DUP8,				///< copies the 8th highest item in the stack to the top of the stack
	DUP9,				///< copies the 9th highest item in the stack to the top of the stack
	DUP10,				///< copies the 10th highest item in the stack to the top of the stack
	DUP11,				///< copies the 11th highest item in the stack to the top of the stack
	DUP12,				///< copies the 12th highest item in the stack to the top of the stack
	DUP13,				///< copies the 13th highest item in the stack to the top of the stack
	DUP14,				///< copies the 14th highest item in the stack to the top of the stack
	DUP15,				///< copies the 15th highest item in the stack to the top of the stack
	DUP16,				///< copies the 16th highest item in the stack to the top of the stack

	SWAP1 = 0x90,		///< swaps the highest and second highest value on the stack
	SWAP2,				///< swaps the highest and third highest value on the stack
	SWAP3,				///< swaps the highest and 4th highest value on the stack
	SWAP4,				///< swaps the highest and 5th highest value on the stack
	SWAP5,				///< swaps the highest and 6th highest value on the stack
	SWAP6,				///< swaps the highest and 7th highest value on the stack
	SWAP7,				///< swaps the highest and 8th highest value on the stack
	SWAP8,				///< swaps the highest and 9th highest value on the stack
	SWAP9,				///< swaps the highest and 10th highest value on the stack
	SWAP10,				///< swaps the highest and 11th highest value on the stack
	SWAP11,				///< swaps the highest and 12th highest value on the stack
	SWAP12,				///< swaps the highest and 13th highest value on the stack
	SWAP13,				///< swaps the highest and 14th highest value on the stack
	SWAP14,				///< swaps the highest and 15th highest value on the stack
	SWAP15,				///< swaps the highest and 16th highest value on the stack
	SWAP16,				///< swaps the highest and 17th highest value on the stack

	LOG0 = 0xa0,		///< Makes a log entry, no topics.
	LOG1,				///< Makes a log entry, 1 topic.
	LOG2,				///< Makes a log entry, 2 topics.
	LOG3,				///< Makes a log entry, 3 topics.
	LOG4,				///< Makes a log entry, 4 topics.

	CREATE = 0xf0,		///< create a new account with associated code
	CALL,				///< message-call into an account
	CALLCODE,			///< message-call with another account's code only
	RETURN,				///< halt execution returning output data
	SUICIDE = 0xff		///< halt execution and register account for later deletion
}


string toString(OpCode)(OpCode op){

	final switch(op){
		// 0x0 range - arithmetic ops
		case OpCode.STOP:			return "STOP";
		case OpCode.ADD:			return "ADD";
		case OpCode.MUL:			return "MUL";
		case OpCode.SUB:			return "SUB";
		case OpCode.DIV:			return "DIV";
		case OpCode.SDIV:			return "SDIV";
		case OpCode.MOD:			return "MOD";
		case OpCode.SMOD:			return "SMOD";
		case OpCode.EXP:			return "EXP";
		case OpCode.NOT:			return "NOT";
		case OpCode.LT:				return "LT";
		case OpCode.GT:				return "GT";
		case OpCode.SLT:			return "SLT";
		case OpCode.SGT:			return "SGT";
		case OpCode.EQ:				return "EQ";
		case OpCode.ISZERO:			return "ISZERO";
		case OpCode.SIGNEXTEND:		return "SIGNEXTEND";

		// 0x10 range - bit ops
		case OpCode.AND:			return "AND";
		case OpCode.OR:				return "OR";
		case OpCode.XOR:			return "XOR";
		case OpCode.BYTE:			return "BYTE";
		case OpCode.ADDMOD:			return "ADDMOD";
		case OpCode.MULMOD:			return "MULMOD";

		// 0x20 range - crypto
		case OpCode.SHA3: 			return "SHA3";

		// 0x30 range - closure state
		case OpCode.ADDRESS:		return "ADDRESS";
		case OpCode.BALANCE:		return "BALANCE";
		case OpCode.ORIGIN:			return "ORIGIN";
		case OpCode.CALLER:			return "CALLER";
		case OpCode.CALLVALUE:		return "CALLVALUE";
		case OpCode.CALLDATALOAD:	return "CALLDATALOAD";
		case OpCode.CALLDATASIZE:	return "CALLDATASIZE";
		case OpCode.CALLDATACOPY:	return "CALLDATACOPY";
		case OpCode.CODESIZE:		return "CODESIZE";
		case OpCode.CODECOPY:		return "CODECOPY";
		case OpCode.GASPRICE:		return "TXGASPRICE";

		// 0x40 range - block operations
		case OpCode.BLOCKHASH:		return "BLOCKHASH";
		case OpCode.COINBASE:		return "COINBASE";
		case OpCode.TIMESTAMP:		return "TIMESTAMP";
		case OpCode.NUMBER:			return "NUMBER";
		case OpCode.DIFFICULTY:		return "DIFFICULTY";
		case OpCode.GASLIMIT:		return "GASLIMIT";
		case OpCode.EXTCODESIZE:	return "EXTCODESIZE";
		case OpCode.EXTCODECOPY:	return "EXTCODECOPY";

		// 0x50 range - 'storage' and execution
		case OpCode.POP:			return "POP";
		//case OpCode.DUP:			return "DUP";
		//case OpCode.SWAP:			return "SWAP";
		case OpCode.MLOAD:			return "MLOAD";
		case OpCode.MSTORE:			return "MSTORE";
		case OpCode.MSTORE8:		return "MSTORE8";
		case OpCode.SLOAD:			return "SLOAD";
		case OpCode.SSTORE:			return "SSTORE";
		case OpCode.JUMP:			return "JUMP";
		case OpCode.JUMPI:			return "JUMPI";
		case OpCode.PC:				return "PC";
		case OpCode.MSIZE:			return "MSIZE";
		case OpCode.GAS:			return "GAS";
		case OpCode.JUMPDEST:		return "JUMPDEST";

		// 0x60 range - push
		case OpCode.PUSH1:			return "PUSH1";
		case OpCode.PUSH2:			return "PUSH2";
		case OpCode.PUSH3:			return "PUSH3";
		case OpCode.PUSH4:			return "PUSH4";
		case OpCode.PUSH5:			return "PUSH5";
		case OpCode.PUSH6:			return "PUSH6";
		case OpCode.PUSH7:			return "PUSH7";
		case OpCode.PUSH8:			return "PUSH8";
		case OpCode.PUSH9:			return "PUSH9";
		case OpCode.PUSH10:			return "PUSH10";
		case OpCode.PUSH11:			return "PUSH11";
		case OpCode.PUSH12:			return "PUSH12";
		case OpCode.PUSH13:			return "PUSH13";
		case OpCode.PUSH14:			return "PUSH14";
		case OpCode.PUSH15:			return "PUSH15";
		case OpCode.PUSH16:			return "PUSH16";
		case OpCode.PUSH17:			return "PUSH17";
		case OpCode.PUSH18:			return "PUSH18";
		case OpCode.PUSH19:			return "PUSH19";
		case OpCode.PUSH20:			return "PUSH20";
		case OpCode.PUSH21:			return "PUSH21";
		case OpCode.PUSH22:			return "PUSH22";
		case OpCode.PUSH23:			return "PUSH23";
		case OpCode.PUSH24:			return "PUSH24";
		case OpCode.PUSH25:			return "PUSH25";
		case OpCode.PUSH26:			return "PUSH26";
		case OpCode.PUSH27:			return "PUSH27";
		case OpCode.PUSH28:			return "PUSH28";
		case OpCode.PUSH29:			return "PUSH29";
		case OpCode.PUSH30:			return "PUSH30";
		case OpCode.PUSH31:			return "PUSH31";
		case OpCode.PUSH32:			return "PUSH32";

		case OpCode.DUP1:			return "DUP1";
		case OpCode.DUP2:			return "DUP2";
		case OpCode.DUP3:			return "DUP3";
		case OpCode.DUP4:			return "DUP4";
		case OpCode.DUP5:			return "DUP5";
		case OpCode.DUP6:			return "DUP6";
		case OpCode.DUP7:			return "DUP7";
		case OpCode.DUP8:			return "DUP8";
		case OpCode.DUP9:			return "DUP9";
		case OpCode.DUP10:			return "DUP10";
		case OpCode.DUP11:			return "DUP11";
		case OpCode.DUP12:			return "DUP12";
		case OpCode.DUP13:			return "DUP13";
		case OpCode.DUP14:			return "DUP14";
		case OpCode.DUP15:			return "DUP15";
		case OpCode.DUP16:			return "DUP16";

		case OpCode.SWAP1:			return "SWAP1";
		case OpCode.SWAP2:			return "SWAP2";
		case OpCode.SWAP3:			return "SWAP3";
		case OpCode.SWAP4:			return "SWAP4";
		case OpCode.SWAP5:			return "SWAP5";
		case OpCode.SWAP6:			return "SWAP6";
		case OpCode.SWAP7:			return "SWAP7";
		case OpCode.SWAP8:			return "SWAP8";
		case OpCode.SWAP9:			return "SWAP9";
		case OpCode.SWAP10:			return "SWAP10";
		case OpCode.SWAP11:			return "SWAP11";
		case OpCode.SWAP12:			return "SWAP12";
		case OpCode.SWAP13:			return "SWAP13";
		case OpCode.SWAP14:			return "SWAP14";
		case OpCode.SWAP15:			return "SWAP15";
		case OpCode.SWAP16:			return "SWAP16";
		case OpCode.LOG0:			return "LOG0";
		case OpCode.LOG1:			return "LOG1";
		case OpCode.LOG2:			return "LOG2";
		case OpCode.LOG3:			return "LOG3";
		case OpCode.LOG4:			return "LOG4";

		// 0xf0 range
		case OpCode.CREATE:			return "CREATE";
		case OpCode.CALL:			return "CALL";
		case OpCode.RETURN:			return "RETURN";
		case OpCode.CALLCODE:		return "CALLCODE";

		// 0xff range - other
		case OpCode.SUICIDE:		return "SUICIDE";
	}
	assert(0, "never reach code!");
}

unittest{
	assert(toString(OpCode.SUICIDE) == "SUICIDE");
	assert(OpCode.CALL.toString() == "CALL");
	assert(OpCode.CREATE.toString() != "LOG4");

	OpCode op = OpCode.CALL;

	assert(op.toString() == "CALL");
}

class QueueException : Exception
{
    @safe pure nothrow
    this()
    {
        super("format error");
    }

    @safe pure nothrow
    this(string msg, string fn = __FILE__, size_t ln = __LINE__, Throwable next = null)
    {
        super(msg, fn, ln, next);
    }
}

struct Queue(T) {
	private {
		T[] m_data;
	}

	void push (T item){
		m_data ~= item;
	}

	@property T pop(){
		if (length == 0)
			throw new QueueException("Stack underflow!"); 
		T ret = m_data[$-1];
		m_data = m_data[0 .. $-1];
		return ret;
	}

	@property ulong length() nothrow pure @nogc { return m_data.length; }
}

//                                           100 000 000 000 000 000 000 000 000 000 000
//10 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000 000
unittest{
	import std.exception;


	auto stack = Queue!BigInt();

	stack.push(BigInt("123456789012345678901234567890"));
	stack.push(BigInt("0xabcdef"));
	stack.push(BigInt("1234567890"));

	assert(stack.length == 3);

	assert(stack.pop == BigInt("1234567890"));

	assert(stack.length == 2);

	assert(stack.pop == BigInt("0xabcdef"));

	assert(stack.length == 1);

	assert(stack.pop == BigInt("123456789012345678901234567890"));

	assert(stack.length == 0);

	assertThrown!QueueException(stack.pop);
	
	auto v = BigInt("0x1234567890_1234567890_1234567890_1234567890_1234567890");
	
	immutable uint MAX_STACK = 1_000_000; 

	for(int i=0; i < MAX_STACK; i++)
		stack.push(v+i);

	assert(stack.length == MAX_STACK);

	for(int i=0; i< MAX_STACK ; i++)
		stack.pop;

	assert(stack.length == 0);
}

// Gas Cost 

immutable (U256_T) Gstep = 1;	 
immutable (U256_T) Gbalance = 20;
immutable (U256_T) Gstop = 0;
immutable (U256_T) Gsuicide = 0;
immutable (U256_T) Gsload = 20;
immutable (U256_T) Gsset = 300;
immutable (U256_T) Gsreset = 100;
immutable (U256_T) Gsclear = 0;
immutable (U256_T) Rsclear = 100;
immutable (U256_T) Gcreate = 100;
immutable (U256_T) Gcreatedata = 5;
immutable (U256_T) Gcall = 20;
immutable (U256_T) Gexp = 1;
immutable (U256_T) Gexpbyte = 1;
immutable (U256_T) Gmemory = 1;
immutable (U256_T) Gtxdatazero = 1;
immutable (U256_T) Gtxdatanonzero = 5;
immutable (U256_T) Gtransaction = 500;
immutable (U256_T) Glog = 1;
immutable (U256_T) Glogdata = 1;
immutable (U256_T) Glogtopic = 1;
immutable (U256_T) Gsha3 = 10;
immutable (U256_T) Gsha3word = 10;
immutable (U256_T) Gcopy = 1;


struct RuntimeData
{
	enum Index
	{
		Gas,
		GasPrice,
		CallData,
		CallDataSize,
		Address,
		Caller,
		Origin,
		CallValue,
		CoinBase,
		Difficulty,
		GasLimit,
		Number,
		Timestamp,
		Code,
		CodeSize,

		SuicideDestAddress = Address,		///< Suicide balance destination address
		ReturnData 		   = CallData,		///< Return data pointer (set only in case of RETURN)
		ReturnDataSize 	   = CallDataSize,	///< Return data size (set only in case of RETURN)
	};

	S64_T 	gas = 0;
	S64_T 	gasPrice = 0;
	string  callData;
	U64_T 	callDataSize = 0;
	U256_T 	address;
	U256_T 	caller;
	U256_T 	origin;
	U256_T 	callValue;
	U256_T 	coinBase;
	U256_T 	difficulty;
	U256_T 	gasLimit;
	U64_T 	number = 0;
	S64_T 	timestamp = 0;
	string	code;
	U64_T 	codeSize = 0;
	U256_T	codeHash;
}

class Env {

}

class Vm {

	void run(RuntimeData data, Env env){
		return ; 
	}
}



