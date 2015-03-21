module ethereum.trie;

import ethereum.rlp;
import leveldb:DB,Options,Slice;


class TrieDb:DB 
{
    this(string fileName){
        auto opt = new Options;
        opt.create_if_missing = true;
        this(opt,fileName);
    }

    this(Options opt, string fileName){
        super(opt, fileName);
    }
}

unittest
{
	import std.file:rmdirRecurse;
    import std.stdio:writeln;

    string dbFileName = "test_db_file_name";

    auto db = new TrieDb(dbFileName);
    
    scope(exit){ rmdirRecurse(dbFileName); }

    db.put("Hello", "World");

    assert(db.get_slice("Hello").as!string == "World");

    db.put("PI", 3.14);

    foreach(Slice key, Slice value; db)
    {
        if(key.as!string == "PI")
            writeln(key.as!string, ": ", value.as!double);
        else
            writeln(key.as!string, ": ", value.as!string);
    }
}

class Hash{

}

class Trie {
    this(TrieDb db, Hash root){
        m_db = db;
        m_root = root;
    }

    Slice get(Slice key){
        return Slice();
    }

    void set(Slice key, Slice value){

    }
    
private:
    TrieDb m_db;
    Hash m_root;
}


unittest{

    import std.file:rmdirRecurse;

    string dbFileName = "trie_db_file_name";


    auto db = new TrieDb(dbFileName);
    scope(exit){ rmdirRecurse(dbFileName); }

    auto hash = new Hash;

    auto trie = new Trie(db, hash);
}
