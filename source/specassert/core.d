module specassert.core;
import std.stdio;

import core.exception;

enum spec;
/++
+/
private class TestCorrecter {
	public{
		alias T = Test;
		void add(T test){
			_tests ~= test;
		}
		
		
		version(spec){
			bool isFailFast = false;
		}else{
			bool isFailFast = true;
		}
		
		void tally(){
			import colorize;
			import std.conv;
			// writeln("tests:", _tests.length);
			T[] errors;
			T[] successes;
			writeln;
			foreach (test; _tests) {
				if(test.isSuccess){
					successes ~= test;
					write(".".color(fg.green, bg.init,  mode.bold));
				}else{
					errors ~= test;
					write("F".color(fg.red, bg.init,  mode.bold));
				}
			}
			writeln("\n");
			
			foreach (test; _tests) {
				with(test){
					auto statusColor = isSuccess?"green":"red";
					text(file, "(", line, ")").color(statusColor).writeln;
					text(msg).color(statusColor).writeln;
					text("mod     : ", mod).color(statusColor).writeln;
					text("prettyFunction     : ", prettyFunction).color(statusColor).writeln;
					"".writeln;
				}
			}
			
			string result = text(_tests.length, " examples, ", errors.length, " failure ( ", (successes.length.to!double)/_tests.length.to!double*100.0, "% completed )");
			if(errors.length==0){
				stdout.writeln(result.color(fg.green, bg.init,  mode.bold));
			}else{
				stderr.writeln(result.color(fg.red, bg.init,  mode.bold));
			}
		}
	}//public

	private{
		T[] _tests;
	}//private
}//class ErrorCorector



/++
+/
class Test{
	public{
		this(in string file, in size_t line, in string mod, in string prettyFunction, in string msg, in bool isSuccess){
			_file = file;
			_line = line;
			_mod= mod;
			_prettyFunction = prettyFunction;
			_msg = msg;
			_isSuccess = isSuccess;
		}
		@property{
			string file()const{return _file;}
			size_t line()const{return _line;}
			string mod()const{return _mod;}
			string prettyFunction()const{return _prettyFunction;}
			string msg()const{return _msg;}
			bool isSuccess()const{return _isSuccess;}
		}
	}//public

	private{
		string _file;
		size_t _line;
		string _mod;
		string _prettyFunction;
		string _msg;
		bool _isSuccess;
	}//private
}//class TestCase




private void processTest(in string file, in int line, in string moduleName, in string prettyFunction, in bool isSuccess, in string message){
	
	import std.conv;
	if(testCorrector.isFailFast && !isSuccess){
		auto error = new AssertError(file, line);
		error.msg = message;
		throw error;
	}else{
		testCorrector.add(new Test(file, line, moduleName, prettyFunction, message, isSuccess));
	}
}

import std.exception;
bool specAssert(string file = __FILE__, int line = __LINE__,  string mod= __MODULE__, string prettyFunction = __PRETTY_FUNCTION__)(bool isSuccess){
	try{
		processTest(file, line, mod, prettyFunction, isSuccess, "");
	}catch(AssertError err){
		with(err){
			auto error = new AssertError(file, line);
			error.msg = "";
			throw error;
		}
	}
	return isSuccess;
}

bool specAssert(string file = __FILE__, int line = __LINE__,  string mod= __MODULE__, string prettyFunction = __PRETTY_FUNCTION__)(bool isSuccess, string message){
	try{
		processTest(file, line, mod, prettyFunction, isSuccess, message);
	}catch(AssertError err){
		with(err){
			auto error = new AssertError(file, line);
			error.msg = message;
			throw error;
		}
	}
	return isSuccess;
}

mixin template SpecAssert(){
	void main(){
		foreach (spec; __traits(getUnitTests, spec)) {
			spec();
		}
		testCorrector.tally;
	}
}

static __gshared testCorrector = new TestCorrecter;
version(spec){
	mixin SpecAssert;
}
