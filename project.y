%{
	#include <stdio.h>
	#include <iostream>
	#include <string>
	#include <vector>
	#include <map>
	#include <string.h>
	#include <algorithm>
	using namespace std;
	#include "y.tab.h"
	extern FILE *yyin;
	extern int yylex();
	void yyerror(string s);

	extern int linenum;
	extern int tabCounter;
  	int tempCounter = 0;
	
    struct Types 
    {
        bool closed;
		int tabCount;
		string type;
    };
	vector<Types> vec;
	vector<string> vec2;

	struct Variables 
    {
        string name;
		string type;
    };
    vector<Variables> vec3;
    vector<string> typeVec;
%}

%union
{
	int value;
	char * str;
}

%token <str> OPERATOR COLON COMPARISON IF ELIF ELSE EQUAL DIGIT IDENTIFIER FLOAT NEWLINE STRING OPENPARANTHESE CLOSEPARANTHESE TAB 
%type<str> assignment operand if elseif else print commands ifelse
%%


commands:
		print commands
		|
		print
		{	

			int i = 0;
			while (i < vec3.size()) 
			{
			    int j = i + 1;
			    while (j < vec3.size()) 
			    {
			        if (vec3[i].name == vec3[j].name && vec3[i].type == vec3[j].type) 
			        {
			            vec3.erase(vec3.begin() + j);
			        } 
			        else 
			        {
			            j++;
			        }
			    }
			    i++;
			}	

			cout << "void main()\n{\n\t";

			vector<string> intVector;
			vector<string> floatVector;
			vector<string> stringVector;

			for(int i=0; i<vec3.size(); i++)
			{
				if(vec3[i].type == "int")
				{
					string combined = vec3[i].name + "_" + vec3[i].type;
					intVector.push_back(combined);
				}

				if(vec3[i].type == "flt")
				{
					string combined = vec3[i].name + "_" + vec3[i].type;
					floatVector.push_back(combined);
				}

				if(vec3[i].type == "str")
				{
					string combined = vec3[i].name + "_" + vec3[i].type;
					stringVector.push_back(combined);
				}
			}

			if(intVector.size() > 0)
			{
				cout<< "int ";  
				for(int i=0; i<intVector.size(); i++)
				{
			       	cout << intVector[i];
			        if (i != intVector.size() - 1) 
			        {
			            cout << ",";
			        }
			        else 
			        {
			            cout << ";";
			        }
				}
				cout<<endl<<"\t";
			}

			if(floatVector.size() > 0)
			{
				cout<< "float ";  
				for(int i=0; i<floatVector.size(); i++)
				{
			       	cout << floatVector[i];
			        if (i != floatVector.size() - 1) 
			        {
			            cout << ",";
			        }
			        else 
			        {
			            cout << ";";
			        }
				}
				cout<<endl<<"\t";
			}

			if(stringVector.size() > 0)
			{
				cout<< "string ";  
				for(int i=0; i<stringVector.size(); i++)
				{
			       	cout << stringVector[i];
			        if (i != stringVector.size() - 1) 
			        {
			            cout << ",";
			        }
			        else 
			        {
			            cout << ";";
			        }
				}
				cout<<endl<<"\t";
			}
			cout << endl << "\t";

			vector<string> tabbed_strings;
		  	for (const string& s : vec2) 
		  	{
		    	string tabbed_string = s;
		    	size_t pos = 0;
		    	while ((pos = tabbed_string.find("\n", pos)) != string::npos) 
		    	{
		      		tabbed_string.replace(pos, 1, "\n\t");
		      		pos += 1;
		    	}
		    	tabbed_strings.push_back(tabbed_string);
		  	}
			
			vector<string> delete_t;
			if(vec.empty() == 0)
			{
				for(int i = vec.size()-1; i>=0; i--)
				{
					string s = "";
					if(vec[i].closed == false)
					{
						for(int j = vec[i].tabCount; j>0; j--)
						{
							s+= "\t";
						}
						s+= "}\n\t";
						delete_t.push_back(s);
						vec[i].closed = true;
					}
				}
			}
			
			if(delete_t.empty()==0)
			{
				delete_t.back().erase(remove(delete_t.back().begin(), delete_t.back().end(), '\t'), delete_t.back().end());
				
				for(int i = 0; i<tabbed_strings.size(); i++)
				{
					cout << tabbed_strings[i];
				}
				for(int i = 0; i<delete_t.size(); i++)
				{
					cout << delete_t[i];
				}
			}
			else
			{
				if(tabbed_strings.empty()==0)
				{
					tabbed_strings[tabbed_strings.size()-1].pop_back();

					for(int i = 0; i<tabbed_strings.size(); i++)
					{
						cout <<tabbed_strings[i];
					}
				}
			}
			cout << "}" << endl;
		}
	;


print:
		assignment
		{
			if(tempCounter < tabCounter)
			{
				cout << "tab inconsistency in line "<< linenum << endl;
				exit(0);
			}

			if(vec.empty() == 0)
			{
				if((vec[vec.size()-1].type == "if" || vec[vec.size()-1].type == "elif" || vec[vec.size()-1].type == "else") && !(vec[vec.size()-1].tabCount==tabCounter-1) && vec[vec.size()-1].closed == false)
				{
					cout << "error in line " << linenum << ": at least one line should be inside if/elif/else block "<< endl;
					exit(0);
				}
			}

			string combined = "";
			if(vec.empty() == 0)
			{
				for(int i = vec.size()-1; i>=0; i--)
				{
					if(vec[i].closed == false && vec[i].tabCount>=tabCounter && (vec[i].type == "if" || vec[i].type == "elif" || vec[i].type == "else"))
					{
						for(int j = vec[i].tabCount; j>0; j--)
						{
							combined += string("\t");
						}
						combined += string("}\n");
						vec[i].closed = true;
					}
				}
			}
			combined += string($1) + "\n";

			Types temp;
			temp.tabCount = tabCounter;
			temp.type = "assignment";
			temp.closed = true;
			vec.push_back(temp);

			$$ = strdup(combined.c_str());
			vec2.push_back($$);
			tabCounter = 0;
		}
		|
		ifelse
		{
			tempCounter = tabCounter + 1;
			tabCounter = 0;
		}
		|
		NEWLINE
	;


ifelse:
		if
		{
			if(vec.empty() == 0)
			{
				if((vec[vec.size()-1].type == "if" || vec[vec.size()-1].type == "elif" || vec[vec.size()-1].type == "else") && !(vec[vec.size()-1].tabCount==tabCounter-1) && vec[vec.size()-1].closed == false)
				{
					cout << "error in line " << linenum <<": at least one line should be inside if/elif/else block "<< endl;
					exit(0);
				}
			}

			string combined = "";
			if(vec.empty() == 0)
			{
				for(int i = vec.size()-1; i>=0; i--)
				{
					if(vec[i].closed == false && vec[i].tabCount>=tabCounter)
					{
						for(int j = vec[i].tabCount; j>0; j--)
						{
							combined += string("\t");
						}
						combined += string("}\n");
						vec[i].closed = true;
					}
				}
			}

			Types temp;
			temp.tabCount = tabCounter;
			temp.type = "if";
			temp.closed = false;
			vec.push_back(temp);

			combined = combined + string($1) + "\n";
			$$ = strdup(combined.c_str());
			vec2.push_back($$);
		}
		|
		elseif
		{
			if(vec.empty() == 0)
			{
				if((vec[vec.size()-1].type == "if" || vec[vec.size()-1].type == "elif" || vec[vec.size()-1].type == "else") && !(vec[vec.size()-1].tabCount==tabCounter-1) && vec[vec.size()-1].closed == false)
				{
					cout << "error in line " << linenum <<": at least one line should be inside if/elif/else block " << endl;
					exit(0);
				}
			}

			string combined = "";
			bool flag = 0;

			if(vec.empty() == 0)
			{
				for(int i = vec.size()-1; i>=0; i--)
				{
					if( (vec[i].tabCount == tabCounter && (vec[i].type == "if" || vec[i].type == "elif") && vec[i].closed == 0) )
					{
						flag = 1;
					}

					if(vec[i].closed == false && vec[i].tabCount>=tabCounter)
					{
						for(int j = vec[i].tabCount; j>0; j--)
						{
							combined += string("\t");
						}
						combined += string("}\n");
						vec[i].closed = true;
					}
				}				
			}

			if(flag==0)
			{
				cout << "elif after else in line " << linenum << endl;
				exit(0);
			}

			Types temp;
			temp.tabCount = tabCounter;
			temp.type = "elif";
			temp.closed = false;
			vec.push_back(temp);

			combined = combined + string($1) + "\n";
			$$ = strdup(combined.c_str());
			vec2.push_back($$);
		}
		|
		else
		{
			if(vec.empty() == 0)
			{
				if((vec[vec.size()-1].type == "if" || vec[vec.size()-1].type == "elif" || vec[vec.size()-1].type == "else") && !(vec[vec.size()-1].tabCount==tabCounter-1) && vec[vec.size()-1].closed == false)
				{
					cout << "error in line " << linenum <<": at least one line should be inside if/elif/else block "<< endl;
					exit(0);
				}
			}

			string combined = "";
			bool flag = 0;

			if(vec.empty() == 0)
			{				
				for(int i = vec.size()-1; i>=0; i--)
				{
					if((vec[i].tabCount == tabCounter && (vec[i].type == "if" || vec[i].type == "elif") && vec[i].closed == 0))
					{
						flag = 1;
					}

					if(vec[i].closed == false && vec[i].tabCount>=tabCounter)
					{
						for(int j = vec[i].tabCount; j>0; j--)
						{
							combined += string("\t");
						}
						combined += string("}\n");
						vec[i].closed = true;
					}
				}
			}

			if(flag==0)
			{
				cout << "else without if in line " << linenum << endl;
				exit(0);
			}

			Types temp;
			temp.tabCount = tabCounter;
			temp.type = "else";
			temp.closed = false;
			vec.push_back(temp);

			combined = combined + string($1) + "\n";
			$$ = strdup(combined.c_str());
			vec2.push_back($$);
		}
	;


assignment:
		IDENTIFIER EQUAL assignment
		{
			string check;
			bool flag = 1;

			if(!typeVec.empty()) 
			{
			  	check = typeVec[0];
			  	for(int i = 1; i < typeVec.size(); ++i) 
			  	{
			    	if(typeVec[i] != check) 
			    	{
			      		if((typeVec[i] == "flt" && check == "int") || (typeVec[i] == "int" && check == "flt") ) 
			      		{
			       	 		check = "flt";
			      		}	
			      		else 
			      		{
			        		flag = 0;
			      		}
			    	}
			  	}
			}

			if(flag == 0)
			{
				cout << "type mismatch in line " << linenum << endl;
				exit(0);
			}

			Variables temp;
			temp.name = string($1);
			temp.type = check;
			vec3.insert(vec3.begin(),temp);
			typeVec.clear();

			string combined = string($1) + "_" + temp.type + " " + string($2) + " " + string($3) + ";";
			$$ = strdup(combined.c_str());
		}
		|
		assignment OPERATOR assignment
		{
			string combined = string($1) + " " + string($2) + " " + string($3);
			$$ = strdup(combined.c_str());
		}
		|
		TAB assignment
		{
			string combined = string("\t") + string($2);
			$$ = strdup(combined.c_str());
		}
		|
		operand
	;
	

operand:
		IDENTIFIER
		{
			string combined = string($1);
			bool flag = 0;

			if(vec3.empty() == 0)
			{
				int i = 0;
				while (i < vec3.size())
				{
				    if(vec3[i].name == $1)
				    {
				    	flag = 1;
				        typeVec.push_back(vec3[i].type);
				        combined += "_" + vec3[i].type;
				        break;
				    }
				    i++;
				}
			}

			if(flag == 0)
			{
				cout << "not declared in line " << linenum << endl;
				exit(0);
			}

			$$ = strdup(combined.c_str());
		}
		|
		DIGIT
		{
			$$ = strdup($1);
			typeVec.push_back("int");
		}
		|
		FLOAT
		{
			$$ = strdup($1);
			typeVec.push_back("flt");
		}
		|
		STRING
		{
			$$ = strdup($1);
			typeVec.push_back("str");
		}
		|
		OPERATOR operand
		{
			string combined = string($1) + string($2);
			$$ = strdup(combined.c_str());
		}
	;


if: 
		IF operand COMPARISON operand COLON
		{
			string combined = string($1) + "(" + " " + string($2) + " " + string($3) + " " + string($4) + " " + ")" + "\n";
			for( int i=0; i<tabCounter; i++ )
			{
				combined += "\t";
			}
			combined += "{";

			int i = 0;
			string temp = typeVec[0];
			while (i < typeVec.size()) 
			{
			  if((temp =="flt" && typeVec[i] == "int") || (temp =="int" && typeVec[i] == "flt"))
			  {
			    temp = "flt";
			  }
			  else if(typeVec[i] != temp)
			  {
			    cout<<"comparison type mismatch in line "<<linenum<<endl;
			    exit(0);
			  }
			  i++;
			}
			$$ = strdup(combined.c_str());
			typeVec.clear();
		}
		|
		TAB if
		{
			string combined = string("\t") + string($2);
			$$ = strdup(combined.c_str());
		}
	;
	
	
elseif: 
		ELIF operand COMPARISON operand COLON
		{
			string combined = string($1) + "(" + " " + string($2) + " " + string($3) + " " + string($4) + " " + ")" + "\n";
			for( int i=0; i<tabCounter; i++ )
			{
				combined += "\t";
			}
			combined += "{";

			int i = 0;
			string temp = typeVec[0];
			while (i < typeVec.size()) 
			{
			  if((temp =="flt" && typeVec[i] == "int") || (temp =="int" && typeVec[i] == "flt"))
			  {
			    temp = "flt";
			  }
			  else if(typeVec[i] != temp)
			  {
			    cout << "comparison type mismatch in line "<< linenum << endl;
			    exit(0);
			  }
			  i++;
			}
			$$ = strdup(combined.c_str());
			typeVec.clear();
		}
		|
		TAB elseif
		{
			string combined = string("\t") + string($2);
			$$ = strdup(combined.c_str());
		}
	;
		
		
else: 
		ELSE COLON
		{
			string combined = string($1) + "\n";
			for( int i=0; i<tabCounter; i++ )
			{
				combined += "\t";
			}
			combined += "{";
			$$ = strdup(combined.c_str());
		}
		|
		TAB else
		{
			string combined = string("\t") + string($2);
			$$ = strdup(combined.c_str());
		}
	;
	
	
%%
void yyerror(string s)
{
	cerr<<"Error..."<<endl;
}
int yywrap()
{
	return 1;
}
int main(int argc, char *argv[])
{
    /* Call the lexer, then quit. */
    yyin=fopen(argv[1],"r");
    yyparse();
    fclose(yyin);
    return 0;
}