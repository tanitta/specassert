specassert
====

A lightweight spec assert in D programming language.

	unittest{
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

![ScreenShot](https://github.com/tanitta/specassert/blob/master/ss.png)

#Usage

1. set spec buildType to your project's sdl file.(cf. examples/timer/dub.sdl)
2. write spec unittests.(cf. examples/timer/dub.sdl)
3. test with command `dub run --build=spec`
