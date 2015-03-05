module ethereum.rlp;

import std.array: appender ;
import std.bitmanip:nativeToBigEndian;
import std.format:formattedWrite;
import std.stdio:writeln,writefln;
import std.typecons:Tuple;
import std.conv:parse;

/**
Rlp(Recursive Length Prefix) 
   https://github.com/ethereum/wiki/wiki/Rlp
   also the formal information see Gavin Wood's yellow paper
   (http://gavwood.com/Paper.pdf - Appendix B.Recursive Length Prefix)

First byte of an encoded item
        0 <= x <= 0x7f(127)
             x: single byte, itself

0x80(128) <= x <= 0xb7(183)
             x: [0, 55] byte long string, x-0x80 == length
 
0xb8(184) <= x <= 0xbf(191)
             x: [56, ]  long string, x-0xb7 == length of the length

0xc0(192) <= x <= 0xf7(247)
             x: [0, 55] byte long list, x-0xc0 == length


0xf8(248) <= x <= 0xff(255)
             x: [56, ] long list, x-0xf7 == length of the length

*/

enum RlpType:ubyte {
    String = 0,
    Array  = 1
}

enum {
    ERlpMaxLenBytes     =   8, // 0x8
    ERlpDataImmLenCount =  56, // 0x38
    ERlpDataImmLenStart = 128, // 0x80
    ERlpDataIndLenZero  = 183, // 0xb7
    ERlpListStart       = 192, // 0xc0
    ERlpListImmLenCount =  56, // 0x38
    ERlpListIndLenZero  = 247  // 0xf7
}

alias PosTuple = Tuple!(RlpType,ulong, ulong);

struct Rlp {
    this(string _data){ opAssign(_data); }

    this(Rlp[] _array){ opAssign(_array); }

    this(string[] _array){ opAssign(_array); }

    Rlp opAssign(string _data)
    {
        m_data =  _data;
        m_type = RlpType.String;
        return this;
    }

    Rlp opAssign(string[] _array)
    {
        auto app = appender!(Rlp[]);
        foreach( item ; _array){
            app.put(Rlp(item));
        }
        m_list = app.data;
        m_type = RlpType.Array;

        return this;
    }

    Rlp opAssign(Rlp[] _array)
    {
        m_list =  _array;        
        m_type = RlpType.Array;

        return this;
    }

    bool opEquals(in Rlp rhs)
    {
        return (m_type == rhs.m_type) && (m_type==RlpType.Array) ? (m_list == rhs.m_list) : (m_data == rhs.m_data) ;
    }

    @property RlpType type() { return m_type; }
    @property Rlp[] list() { return m_list; }
    @property string data() { return m_data; }

    string toString() {

        auto v = encode(this);
        auto app = appender!string;
        
        immutable byte ASCII=127;

        foreach(c; v){
            if(c > ASCII){
                formattedWrite(app, "\\x%x", c);
            }else{
                app.put(c);
            }
        }
        
        return app.data;
    }
    
    string toRlpDataString(){
        return encode(this) ;
    }
    
    static Rlp fromRlpDataString(string rlpData){
        return decode(rlpData);
    }

 

private: 
   static string encode(Rlp rlpObj)
    {
        auto app = appender!string;

        if(rlpObj.type == RlpType.String){

            if( rlpObj.data.length < ERlpDataImmLenCount ){
                app.put(cast(char)(ERlpDataImmLenStart + rlpObj.data.length));
                app.put(rlpObj.data);
            }else{
                auto size = n2be(rlpObj.data.length);
                
                assert(size.length <= ERlpMaxLenBytes);
                
                app.put(cast(char)(ERlpDataIndLenZero + size.length));            
                app.put(cast(string)size);

                app.put(rlpObj.data);
            }
        
        }else if(rlpObj.type == RlpType.Array){

            auto dataApp = appender!string;

            foreach(item ; rlpObj.list){
                auto d = encode(item);
                dataApp.put(d);
            }

            if( dataApp.data.length < ERlpListImmLenCount ){
                app.put(cast(char)(ERlpListStart + dataApp.data.length));
                app.put(dataApp.data);
            }else{
                auto size = n2be(dataApp.data.length);

                assert(size.length <= ERlpMaxLenBytes);

                app.put(cast(char)(ERlpListIndLenZero + size.length));
                app.put(cast(string)size);
                app.put(dataApp.data);
            }

        }
        return app.data;
    }
    
    static Rlp decode(string data){

        PosTuple pt = decodePrefix(data);
        Rlp ret;

        final switch(pt[0]){
            case RlpType.String:
                ret = Rlp(data[pt[1] .. pt[2]]);
                break;
            case RlpType.Array:
                string ldata = data[pt[1] .. pt[2]];
                
                auto app = appender!(Rlp[]);

                while(ldata.length){
                    
                    pt = decodePrefix(ldata);

                    final switch(pt[0]){
                        case RlpType.String:
                            app.put( Rlp( ldata[pt[1] .. pt[2]]) );
                            break;

                        case RlpType.Array:
                            // Recursive call
                            app.put( decode(ldata) );
                            break;
                    }
                    
                    ldata = ldata[pt[2] .. $];
                }
                ret = Rlp(app.data);
                break;
        }
        return ret;
    }   

    static string n2be(ulong ln){
        auto v = nativeToBigEndian(ln);
        
        auto app = appender!string; 
        
        foreach(char b; v) 
            if(b) 
                formattedWrite(app,"%x",b);
        
        return app.data;
    }
    
    static ulong be2n(string be){       
        auto n = parse!uint(be, 16);        
        return n;
    }

    static PosTuple decodePrefix(string rlpData){
        
        string debugStr(char prefix, PosTuple p){
            auto app = appender!string;
            formattedWrite(app, "prefix(%x) and PosTuple(%d, %d, %d)", prefix, p[0], p[1], p[2]);
            return app.data;
        }

        ubyte b = rlpData[0];
        ulong len,dlen;

        PosTuple ret;

        switch(b){
            case 0: .. case 127:     // ascii
                ret = PosTuple(RlpType.String,0,1);

                //writefln("0..127: %s", debugStr(b,ret));
                break;
            
            case 128: .. case 183:   // string: length < 56
                len = b - 128; //0x80
                ret =PosTuple(RlpType.String,1,1+len);

                //writefln("128..183:%s",debugStr(b,ret));
                break;
            
            case 184: .. case 191:   // string: 56 < length <= 0xFF FF FF FF FF FF FF FF
                len = b - 183; //0xb7
                dlen = Rlp.be2n(rlpData[1 .. 1+len]);
                ret = PosTuple(RlpType.String, 1+len, 1+len+dlen);
                //writefln("184..191:%s",debugStr(b,ret));
                break;

            case 192: .. case 247:   // list: length < 56
                len = b - 192; //0xc0
                ret = PosTuple(RlpType.Array, 1, 1+len);
                //writefln("192..247:%s",debugStr(b,ret));
                break;

            case 248: .. case 255:   // list:  56 < length <= 0xFF FF FF FF FF FF FF FF
                len = b - 247; //0xf7
                dlen = Rlp.be2n(rlpData[1 .. 1+len]);
                ret = PosTuple(RlpType.Array, 1+len, 1+len+dlen);

                //writefln("248..255:%s",debugStr(b,ret));
                break;
            default:
                assert(0);
        }

        return ret; 
    }

    RlpType m_type=RlpType.String;
    union{
        string  m_data;
        Rlp[] m_list;        
    }
}

unittest{
    assert( Rlp.be2n("ff") == 0xff ); 
    assert( Rlp.be2n("ffffffff") == 0xffff_ffffUL ); 
    assert( Rlp.be2n("ffff0000") == 0xffff_0000UL ); 
}


unittest{ // string encode(Rlp val);
    
    Rlp v = "string"; // opAssign("="") 
    assert(v.type == RlpType.String);

    v = ["1","2"];
    assert(v.type == RlpType.Array);

    v = [Rlp(),Rlp()];
    assert(v.type == RlpType.Array);
    assert(Rlp().type == RlpType.String);
    assert(Rlp("string").type == RlpType.String);
    assert(Rlp(["1","2"]).type == RlpType.Array);
    assert(Rlp([Rlp()]).type == RlpType.Array);
  
    // short value test( < 56)
    v = Rlp([Rlp(""),Rlp("")]); // ["",""]
    //writefln("v is %s", v.toString() );
    assert( Rlp.encode(v) == "\xc2\x80\x80" ); 

    v = Rlp([Rlp("cat"),Rlp("dog")]);
    assert( Rlp.encode(v) == "\xc8\x83cat\x83dog" );

    v = Rlp([Rlp("cat"),Rlp([Rlp("dog"),Rlp("puppy")])]);
   
    string s1 = Rlp.encode(v);
    assert(s1 == "\xcf\x83cat\xca\x83dog\x85puppy" );

    // long value test( > 56)
    v = Rlp("123456789 123456789 123456789 123456789 123456789 1234567");
    assert(v.type == RlpType.String);
    assert(v.data.length == 57);
    s1 = Rlp.encode(v);
    //writefln("s1 dump: %s", v.toString() );
    assert(s1 == "\xb939123456789\x20123456789\x20123456789\x20123456789\x20123456789\x201234567");

    // long value test( > 56)
    v = Rlp([Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789")]);
    assert(v.type == RlpType.Array);
    assert(v.list.length == 6);
    s1 = Rlp.encode(v);    
    assert(s1 == "\xf93c\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789");

    // long value test( > 56)
    v = Rlp([
            Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"),
            Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"),
            Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"), Rlp("123456789"),
        ]); 
    assert(v.type == RlpType.Array);
    assert(v.list.length == 30);
    s1 = Rlp.encode(v);
    assert(s1 == "\xfa12c\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789");
}

unittest{
    auto s = "1";
    auto r = Rlp.decodePrefix(s);
    assert("1" == s[r[1]..r[2]]);

    s = "\x8a1234567890";
    r = Rlp.decodePrefix(s);
    //writefln("[%d .. %d]", r[1], r[2]);
    assert(r[0] == RlpType.String);
    assert(s[1 .. $] == s[r[1] .. r[2]]);

    s = "\xcf\x83cat\xca\x83dog\x85puppy";
    r = Rlp.decodePrefix(s);
    //writefln("[%d .. %d]", r[1], r[2]);
    assert(s[1 .. $] == s[r[1] .. r[2]]);
    assert( r[0] == RlpType.Array );
    assert( r[1] == 1 );
    assert( r[2] == s.length );

}

unittest{  // Rlp decode(string data);

    auto s1 = "a";
    auto rlp = Rlp.decode(s1);

    //writefln("decode: %s", rlp.data());
    assert( rlp == Rlp("a"));

    s1 = "\x83dog";
    rlp = Rlp.decode(s1);

    //writefln("decode: %s", rlp.data());
    assert( rlp == Rlp("dog"));

    auto ori = Rlp("123456789 123456789 123456789 123456789 123456789 123456");
    s1 = Rlp.encode(ori); 
    //writefln("s1 is %s", ori.toString());
    rlp = Rlp.decode(s1);
    //writefln("%s == %s", rlp.toString(), ori.toString());
    assert(rlp == ori);

    //s1 = Rlp([Rlp("123456789"),Rlp("123456789"),Rlp("123456789"),Rlp("123456789"),Rlp("123456789"),Rlp("123456")]).encode();
    s1 = "\xf939\x89123456789\x89123456789\x89123456789\x89123456789\x89123456789\x86123456";

    rlp = Rlp.decode(s1);
    assert(rlp.list.length == 6);
    assert(rlp.type == RlpType.Array);
    
    //writefln("decode: %s", rlp.toString());
    assert( Rlp.encode(rlp) == s1    );


    //s1 => ["123456789",[["123456789","123456789","123456789",],["123456789","123456"]]]
    s1 = "\xf93c\x89123456789\xf1\xde\x89123456789\x89123456789\x89123456789\xd1\x89123456789\x86123456";
    //writefln("encoded: %s", s1);
    rlp = Rlp.decode(s1);
    assert(rlp.list.length == 2);
    assert(rlp.type == RlpType.Array);
    
    //writefln("decode: %s", rlp.toString());
    assert( Rlp.encode(rlp) == s1    );
    
    //complex =>  ["01",["02",["03",["04",["05",["06",["07",["08",["09",["10"]]]]]]]]];
    //encode => "\xe6\x8201\xe2\x8202\xde\x8203\xda\x8204\xd6\x8205\xd2\x8206\xce\x8207\xca\x8208\xc6\x8209\x8210";
    auto complex =  Rlp([Rlp("01"),Rlp([Rlp("02"),Rlp([Rlp("03"),Rlp([Rlp("04"),Rlp([Rlp("05"),Rlp([Rlp("06"),Rlp([Rlp("07"),Rlp([Rlp("08"),Rlp([Rlp("09"),Rlp("10")])])])])])])])])]);
    //writefln("encode: %s", complex.toString());
    assert( Rlp.decode( Rlp.encode(complex) ) == complex);

}


