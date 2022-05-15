// int main() {

//     int timer0, timer1, numIntervals, currInterval;
//     int startTime = 20;
//     int breakTime = 10;

//     cout << "How many intervals do you want: ";
//     cin >> numIntervals;

//     cout << "Timer will start in 5 seconds\n";
//     sleep(1);

//     for ( int i = 5; i > 0; i-- ) {
//         cout << i << '\n';
//         sleep(1);
//     }

//     for ( currInterval = 0; currInterval < numIntervals; currInterval++ ) {
//         cout << "Interval " << currInterval + 1 << ':';
//         while ( startTime > 0 ) {
//                 cout << '\n' << startTime;
//             sleep(1);
//             if ( startTime == 20 ) {
//                 system( "aplay ./dialog-information.wav > /dev/null 2>&1" );
//             }
//             startTime--;
//         }
//         startTime = 20;
//         cout << '\n';

//         cout << "Break Interval " << currInterval + 1 << ':';
//         while ( breakTime > 0 ) {
//                 cout << '\n' << breakTime;
//             sleep(1);
//             if ( breakTime == 10 ) {
//                 system ( "aplay ./warning.wav > /dev/null 2>&1" );
//             }
//             breakTime--;
//         }
//         breakTime = 10;
//         cout << '\n';
//     }
//     system ( "aplay ./SchoolBell.wav > /dev/null 2>&1" );
//     cout << "Good Job!" << endl;

//     return 0;

// }