module specassert.parser;

private string[] spritedArgs(string argsSource){
	string[] args;
	int depth = 0;
	int argStart = 0;
	import std.string;
	foreach (int index, c; argsSource.strip) {
		if(c == '('){
			depth ++;
		}
		if(c == ')'){
			depth --;
		}
		if(depth == 0 && c == ','){
			args ~= argsSource[argStart..index].strip;
			argStart = index+1;
		}
		
		if(depth == 0 && index == argsSource.length-1){
			string detectedArg = argsSource[argStart..$].strip;
			if(detectedArg != "")args ~= detectedArg;
		}
	}
	
	return args;
}
unittest{
	import std.stdio;
	assert("a, b(), c(hoge(1, 2)), d".spritedArgs == ["a", "b()", "c(hoge(1, 2))", "d"]);
	assert( "a, b, c(),".spritedArgs == ["a", "b", "c()"]);
	assert( "a,\nb,\nc(),".spritedArgs == ["a", "b", "c()"]);
}

private string detectedFunctionArg(in string source, in string functionName){
	import std.string;
	int depth = 0;
	auto  functionHead = source.indexOf(functionName);
	if( functionHead == -1)assert(false);
	auto  bracketHead = source[functionHead..$].indexOf('(')+functionHead;
	if( bracketHead == -1)assert(false);
	auto openIndex= bracketHead;
	auto closeIndex = 0L;
	foreach (long index, c; source[bracketHead..$]) {
		
		if(c == '('){
			depth ++;
		}
		if(c == ')'){
			depth --;
		}
		if(depth == 0){closeIndex = index+bracketHead+1;break;}
	}
	return source[openIndex+1..closeIndex-1];
}
unittest{
	assert("    specAssert(b(a, ), c);aiueo;".detectedFunctionArg("specAssert") == "b(a, ), c");
}

string[] parseSource(in string source){
	string[] strings = source.detectedFunctionArg("specAssert").spritedArgs;
	return strings;
}
unittest{
	assert( "	    specAssert(hoge(), \"Faillue\", \"Success\");".parseSource == ["hoge()", "\"Faillue\"", "\"Success\""]);
}
