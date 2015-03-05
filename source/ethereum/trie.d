module ethereum.trie;

import leveldb;


unittest
{
	import std.file:remove;
    import std.stdio:writeln;

    auto opt = new Options;
    opt.create_if_missing = true;

    string dbFileName = "test_db_file_name";

    auto db = new DB(opt, dbFileName);
    
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


class Database{
    this(string path){
        m_path = path;
        initDatabase();
    }

private:
    void initDatabase(){
        auto opt = new Options;
        opt.create_if_missing = true;
        m_db = new DB(opt, dbFileName);        
    }

    string m_path;
    DB m_db;
}


struct Trie{


}


