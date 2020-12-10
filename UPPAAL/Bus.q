//This file was generated from (Commercial) UPPAAL 4.0.15 rev. CB6BB307F6F681CB, November 2019

/*

*/
E<> (busBooking.Seat_Availability or busBooking.Info_Saved_Exit)

/*

*/
E[] (busBooking.Seat_Availability imply busBooking.Trip_Info)

/*

*/
E[] (busBooking.Seat_Availability imply busBooking.TripLogin)

/*

*/
E<> (busBooking.TripLogin imply busBooking.Seat_Availability)

/*

*/
A<> not (busBooking.Card_Details && timeOut>limit)

/*

*/
E[] not(tripServer.Info_Saved_Exit and timeOut<limit)

/*

*/
E<> (tripServer.Info_Saved_Exit and timeOut>=limit)

/*

*/
E[] (busBooking.Card_Details imply busBooking.Trip_Info)

/*

*/
A[] not deadlock

/*

*/
E[] not (tripServer.Seat_Availability && busBooking.Seat_Availability && timeOut>limit)

/*

*/
A[] (busBooking.TripLogin imply not tripServer.Seat_Availability)

/*

*/
E[] (busBooking.Personal_Details imply busBooking.Seat_Preference)\

