# Python-To-C++-Converter
In this project, you will write a lex yacc program that will convert a python code to c++ code. We do not want you to handle all the possible python codes. The input python codes can contain only assignment and if/else statements. Your project is to convert the given assignment and if/else statements into c++ language.

<b>INPUT
```
x=5
y=7
z=3.14
if x<z:
	if y<z:
		result=z*x-y
		result=result/2
	else:
		result=z*x+y
		result=result/2
		if result>y:
			result=result/x
	y=x*2
elif y<x:
	result=z
else:
	result=z*x*x*y
x=y
```

<b>OUTPUT

```
void main()
{
	int x_int,y_int;
	float result_flt,z_flt;

	x_int = 5;
	y_int = 7;
	z_flt = 3.14;
	if( x_int < z_flt )
	{
		if( y_int < z_flt )
		{
			result_flt = z_flt * x_int - y_int;
			result_flt = result_flt / 2;
		}
		else
		{
			result_flt = z_flt * x_int + y_int;
			result_flt = result_flt / 2;
			if( result_flt > y_int )
			{
				result_flt = result_flt / x_int;
			}
		}
		y_int = x_int * 2;
	}
	else if ( y < x )
	{
		result_flt = z_flt;
	}
	else
	{
		result_flt = z_flt * x_int * x_int * y_int;
	}
	x_int = y_int;
}
```
