import std.stdio;
import specassert.core;

/++
+/
class Timer(N) {
	public{
		void start(){};
		void stop(){};
	}//public

	private{
	}//private
}//class Timer

@spec unittest{
	specAssert(__traits(compiles, (){
		auto timer = new Timer!double;
	}));
	
	auto timer = new Timer!double;
	specAssert(__traits(hasMember, timer, "start"));
	specAssert(__traits(hasMember, timer, "stop"));
	specAssert(!__traits(hasMember, timer, "stop"));
}

version(unittest){
	mixin SpecAssert;
}else{
	void main(){}
}



