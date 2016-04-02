module specassert.core;

/++
+/
class Spec{
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
			string file()const nothrow @nogc{return _file;}
			size_t line()const nothrow @nogc{return _line;}
			string mod()const nothrow @nogc{return _mod;}
			string prettyFunction()const nothrow @nogc{return _prettyFunction;}
			string msg()const nothrow @nogc{return _msg;}
			bool isSuccess()const nothrow @nogc{return _isSuccess;}
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
}//class SpecCase

string[] parsedAssertCondition(in Spec s, bool willSpritArgs = true){
	import std.file;
	import std.conv;
	string source = read(s.file).to!string;
	
	import std.string;
	string[] lines = source.split("\n");
	
	import std.array;
	// if (willSpritArgs) {
		import specassert.parser;
		// return lines[s.line-1..$].join("\n").parseSource;
	// }else{
		import std.string;
		return [lines[s.line-1].strip];
	// }
}
unittest{
	// parsedAssertCondition(new Spec("source/specassert/core.d", 59, "hoge", "func", "msg", true)).writeln;
}

/++
+/
private class SpecCorrecter {
	public{
		alias T = Spec;
		void add(T test){
			_tests ~= test;
		}
		
		
		version(spec){
			bool isFailFast = false;
		}else{
			bool isFailFast = true;
		}
		
		void tally()const{
			import colorize;
			import std.conv;
			// writeln("tests:", _tests.length);
			const(T)[] errors;
			const(T)[] successes;
			import std.stdio;
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
					immutable statusColor = isSuccess?fg.green:fg.red;
					text(file, "(", line, ")").color(statusColor).writeln;
					
					if(test.parsedAssertCondition.length!=0){
						test.parsedAssertCondition[0].text.color(statusColor, bg.init, mode.bold).writeln;
					}
					if(msg!="")text(msg).color(statusColor).writeln;
					// text("mod     : ", mod).color(statusColor).writeln;
					// text("prettyFunction     : ", prettyFunction).color(statusColor).writeln;
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

private void processSpec(in string file, in int line, in string moduleName, in string prettyFunction, in bool isSuccess, in string message){
	
	import std.conv;
	if(testCorrector.isFailFast && !isSuccess){
		import core.exception;
		auto error = new AssertError(file, line);
		error.msg = message;
		throw error;
	}else{
		testCorrector.add(new Spec(file, line, moduleName, prettyFunction, message, isSuccess));
	}
}

bool specAssert(string file = __FILE__, int line = __LINE__,  string mod= __MODULE__, string prettyFunction = __PRETTY_FUNCTION__)(bool isSuccess){
	import core.exception;
	try{
		processSpec(file, line, mod, prettyFunction, isSuccess, "");
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
	import core.exception;
	try{
		processSpec(file, line, mod, prettyFunction, isSuccess, message);
	}catch(AssertError err){
		with(err){
			auto error = new AssertError(file, line);
			error.msg = message;
			throw error;
		}
	}
	return isSuccess;
}

bool specAssert(string Operator, L, R,  string file = __FILE__, int line = __LINE__,  string mod= __MODULE__, string prettyFunction = __PRETTY_FUNCTION__)(L left, R right){
	mixin("bool isSuccess =  left "~Operator~"right;" );
	import std.conv:text;
	string message = text(left, " ", Operator, " ", right);
	
	import core.exception;
	try{
		processSpec(file, line, mod, prettyFunction, isSuccess, message);
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
	private static __gshared testCorrector = new SpecCorrecter;
	
	void main(){
		testCorrector.tally;
	}
}

version(unittest){
	mixin SpecAssert;
}
