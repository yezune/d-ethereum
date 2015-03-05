module ethereum.common;

import std.bigint;

alias U256_T=BigInt;
alias S256_T=BigInt;
alias U160_T=BigInt;


alias Value = BigInt;	// for Ether value ( Wei,Szabo,Finny,Ether )
alias Address = BigInt;	// 160 bit address 
alias Account = BigInt;	// 256 bit account;


// The different number of units
const BigInt Douglas  = BigInt(10)^^42;
const BigInt Einstein = BigInt(10)^^21;
const BigInt Ether    = BigInt(10)^^18;
const BigInt Finney   = BigInt(10)^^15;
const BigInt Szabo    = BigInt(10)^^12;
const BigInt Shannon  = BigInt(10)^^9;
const BigInt Babbage  = BigInt(10)^^6;
const BigInt Ada      = BigInt(10)^^3;
const BigInt Wei      = BigInt( 1);


unittest{
	assert(Douglas  == BigInt("1000_000_000_000_000_000_000_000_000_000_000_000_000_000"));
	assert(Einstein == BigInt("1000_000_000_000_000_000_000"));
	assert(Ether    == BigInt("1000_000_000_000_000_000"));
	assert(Finney   == BigInt("1000_000_000_000_000"));
	assert(Szabo    == BigInt("1000_000_000_000"));
	assert(Shannon  == BigInt("1000_000_000"));
	assert(Babbage  == BigInt("1000_000"));
	assert(Ada      == BigInt("1000"));
	assert(Wei      == BigInt("1"));
}

