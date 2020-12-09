#define NUM_CLIENTS 1
#define size 16

chan sender = [size] of { mtype ,mtype, int };
chan receiver[2] = [size] of { int };

mtype = {NONE, REQREGISTRATION};
show mtype request = REQREGISTRATION;

mtype = {validate0, validate1, registration0, registration1, login0, login1};

typedef USER {
	mtype registration;
	mtype login;
	mtype validate;
}

USER users [2];

active proctype server()
{
mtype r, v;
int uid;
PROCESS:	do
			:: request == REQREGISTRATION ->		
				sender?r, v, uid -> 
					do
					:: (v == validate1 & r == registration1) -> users [uid]. login = login1; receiver[uid]!1; break;  
					:: (v == validate0 & r == registration1) -> users [uid]. login = login0; receiver[uid]!0; break; 
					od;
				:: timeout -> break;
			od;
}

active[NUM_CLIENTS] proctype client1()
{
	atomic{
		request == REQREGISTRATION ->
		sender!users [0]. registration, users [0]. validate, 0; 
	}
		do
		:: receiver [0]?1 -> printf("Succesfully logged in.\n"); printf("%e", users [0]. login); assert(users[0].login == login1);
		:: receiver [0]?0 -> printf("Uhoh. There is an error to get logged in.\n"); printf("%e", users [0]. login); assert(users[0].login == login1);
		od;
}

active[NUM_CLIENTS] proctype client2()
{
	atomic{
		request == REQREGISTRATION ->	
		sender!users [1]. registration, users [1]. validate, 1; 
	}
		do
		:: receiver [1]?1 -> printf("Succesfully logged in.\n"); printf("%e", users [1]. login); assert(users[1].login == login1);
		:: receiver [1]?0 -> printf("Uhoh. There is an error to get logged in.\n"); printf("%e", users [1]. login); assert(users[1].login == login0);
		od;
}

init{
atomic {
	users [0]. registration = registration1;
	users [0]. validate = validate1;
	users [1]. registration = registration1;
	users [1]. validate = validate0;
}
}

ltl p1 { <> ( len(receiver[0]) > 0 -> receiver[0]?[1] ) }
ltl p2 { <> ( len(receiver[1]) > 0 -> receiver[1]?[0] ) }
ltl p3 { <> ( len(sender) > 0 -> sender?[registration1,validate1,0] ) }
ltl p4 { <> ( len(sender) > 0 -> sender?[registration1,validate0,1] ) }
ltl p5 { ! <> ( sender?[registration0,validate0,1] ) }
ltl p6 { ! <> ( sender?[registration0,validate0,0] ) }