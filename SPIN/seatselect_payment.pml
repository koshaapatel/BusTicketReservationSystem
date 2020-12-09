#define NUM_CLIENTS 1
#define size 16

mtype = { NONE, REQTICKETSELECT, TA, TB, TC, TD, TE, REQPAYMENT };
show mtype request = REQTICKETSELECT;
show mtype request1 = REQPAYMENT;

mtype = {login0, login1, ts0, ts1, tsold0, tsold1, pay0, pay1};

chan sender = [size] of { mtype, mtype, mtype, byte };
chan receiver[3] = [size] of { mtype, int, int, byte };

chan paymentsender = [size] of { int, int, int };
chan paymentreceiver[3] = [size] of { int, int, mtype };

mtype alltickets [5];
mtype soldtickets [5];

typedef USER {
	mtype login [3];
	mtype ticketselected [3];
	int uid [3];
	mtype payment [3];
}

USER users [3];

active proctype ticketserver()
{
	mtype l, t;
	int uid, tid;
	do
		:: request == REQTICKETSELECT ->		
			printf("Processing ticket selection request type.\n");
			sender?l, t, uid, tid -> 
				do
					::alltickets[tid]==ts0 -> printf("%e	%e   %d		%d", l, t, uid, tid); receiver[uid]!t, uid, tid, 1; break;
				od;
	od;
}

active proctype paymentserver()
{
	int uid, tid, cost;
	do		
		:: request1 == REQPAYMENT -> 
			printf("Processing ticket payment request type.\n");
			paymentsender?uid, tid, 50 ->
				do
					::soldtickets[tid]==tsold0 -> soldtickets[tid]=tsold1; alltickets[tid]=ts1; printf("%d	%d	  %e   %e", uid, tid, soldtickets[tid], alltickets[tid]); users[uid].payment[uid]=pay1; paymentreceiver[uid]!uid, tid, 1; break; 
					::soldtickets[tid]==tsold1 -> printf("%d	%d	  %e   %e", uid, tid, soldtickets[tid], alltickets[tid]); paymentreceiver[uid]!uid, tid, 0; break; 
				od;
	od;
}

active[NUM_CLIENTS] proctype client1()
{
	users [0]. login [0] = login1;
	users [0]. uid [0] = 0;
	users [0]. ticketselected [0] = TA;
	users [0]. payment [0] = pay0;
	mtype t;
	int uid, tid;
	atomic{
		request == REQTICKETSELECT -> sender!users [0]. login [0], users [0]. ticketselected [0], users [0]. uid [0], 0; 
	}
	do
		::receiver[0]?t, uid, tid, 1 -> printf("seat %e is selected for user %d", t, uid); atomic { request1 == REQPAYMENT -> paymentsender!uid, tid, 50; }
		::paymentreceiver[0]?uid, tid, 1 -> printf("payment is done. %e",users [uid]. payment [uid]);
		::paymentreceiver[0]?uid, tid, 0 -> printf("payment isnt done. %e",users [uid]. payment [uid]);
	od;
}

active[NUM_CLIENTS] proctype client2()
{
	users [1]. login [1] = login1;
	users [1]. uid [1] = 1;
	users [1]. ticketselected [1] = TA;
	users [1]. payment [1] = pay0;
	mtype t;
	int uid, tid;
	atomic{
		request == REQTICKETSELECT -> sender!users [1]. login [1], users [1]. ticketselected [1], users [1]. uid [1], 0; 
	}
	do
		::receiver[1]?t, uid, tid, 1 -> printf("seat %e is selected for user %d", t, uid); atomic { request1 == REQPAYMENT -> paymentsender!uid, tid, 50; }
		::paymentreceiver[1]?uid, tid, 1 -> printf("payment is done. %e",users [uid]. payment [uid]);
		::paymentreceiver[1]?uid, tid, 0 -> printf("payment isnt done. %e",users [uid]. payment [uid]);
	od;
	
}

active[NUM_CLIENTS] proctype client3()
{
	users [2]. login [2] = login1;
	users [2]. uid [2] = 2;
	users [2]. ticketselected [2] = TB;
	users [2]. payment [2] = pay0;
	mtype t;
	int uid, tid;
	atomic{
		request == REQTICKETSELECT -> sender!users [2]. login [2], users [2]. ticketselected [2], users [2]. uid [2], 1; 
	}
	do
		::receiver[2]?t, uid, tid, 1 -> printf("seat %e is selected for user %d", t, uid); atomic { request1 == REQPAYMENT -> paymentsender!uid, tid, 50; }
		::paymentreceiver[2]?uid, tid, 1 -> printf("payment is done. %e",users [uid]. payment [uid]);
		::paymentreceiver[2]?uid, tid, 0 -> printf("payment isnt done. %e",users [uid]. payment [uid]);
	od;
	
}

init {
	atomic {
		alltickets[0]=ts0;
		alltickets[1]=ts0;
		alltickets[2]=ts0;
		alltickets[3]=ts0;
		alltickets[4]=ts0;
	
		soldtickets[0]=tsold0;
		soldtickets[1]=tsold0;
		soldtickets[2]=tsold0;
		soldtickets[3]=tsold0;
		soldtickets[4]=tsold0;
	}
}

ltl p1 { <> ( len(sender) > 0 -> sender?[login1,TA,0,0] ) }
ltl p2 { <> ( len(sender) > 0 -> sender?[login1,TA,1,0] ) }
ltl p3 { <> ( len(sender) > 0 -> sender?[login1,TB,2,1] ) }
ltl p4 { ! <> (sender?[login0,TC,0,0] ) }
ltl p5 { ! <> (sender?[login0,TC,1,0] ) }
ltl p6 { <> ( len(paymentsender) > 0 -> paymentsender?[0,0,50] ) }
ltl p7 { <> ( len(paymentsender) > 0 -> paymentsender?[1,0,50] ) }
ltl p8 { <> ( len(paymentsender) > 0 -> paymentsender?[2,1,50] ) }
ltl p9 { <> ( len(receiver[0]) > 0 -> receiver[0]?[TA,0,0,1] ) }
ltl p10 { <> ( len(receiver[1]) > 0 -> receiver[1]?[TA,1,0,1] ) }
ltl p11 { <> ( len(receiver[2]) > 0 -> receiver[2]?[TB,2,1,1] ) }
ltl p12 { <> ( len(paymentreceiver[0]) > 0 -> paymentreceiver[0]?[0,0,1] ) }
ltl p13 { <> ( len(paymentreceiver[1]) > 0 -> paymentreceiver[1]?[1,0,1] ) }
ltl p14 { <> ( len(paymentreceiver[2]) > 0 -> paymentreceiver[2]?[2,1,1] ) }