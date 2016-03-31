import std.stdio;
import specassert.core;

/++
+/
class Timer(N) {
	public{
		void start(){};
		void count(){};
		void stop(){};
		N time(){return _time;}
	}//public

	private{
		N _time;
	}//private
}//class Timer

@spec unittest{
	alias N = double;
	specAssert(__traits(compiles, (){
		auto timer = new Timer!N;
	}));
	
	auto timer = new Timer!N;
	specAssert(__traits(hasMember, timer, "start"));
	specAssert(__traits(hasMember, timer, "count"));
	specAssert(__traits(hasMember, timer, "stop"));
	
	specAssert(timer.time == N(0));
	timer.start;
	timer.count;
	timer.stop;
	specAssert(timer.time == N(1));
}

// if you write main block, describe "mixin SpecAssert" within conditional compile.
version(unittest){
}else{
	void main(){}
}



