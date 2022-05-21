
#include <iostream>
#include <string>
#include "tabata.h"
#include "workout.h"
#include <time.h>
#include <unistd.h>

using namespace std;
string testJsonStr =
    "{\"name\":\"Test Tabata 2\", "
    "\"sets\":2,\"reps\":3,\"exerciseTime\":10,\"restTime\":20,\"breakTime\":60,\"startDelay\":20,"
    "\"warningBeforeBreakEndsTime\":10}";

void test_tabata(void)
{
  Tabata t1("Test Tabata", 2, 3, 10, 10, 60, 1, 10);
  cout << "Name: '" << t1.getName() << "'   total time: " << t1.getTotalTime() << " secs" << endl;
  cout << "Json:" << t1.toJson() << endl;

  Tabata t2(testJsonStr);
  cout << "Name: '" << t2.getName() << "'   total time: " << t2.getTotalTime() << " secs" << endl;

  Tabata t3(t1.toJson());
  t3.name = "My Tabata 3";
  cout << "Name: '" << t3.getName() << "'   total time: " << t3.getTotalTime() << " secs" << endl;
}

void test_workout()
{
  Tabata t1("Test Workout", 2, 3, 2, 3, 5, 3, 0);
  Workout workout(t1);
  workout.start();
  for (int i = 0; i < 100; i++)
  {

    workout.tick();
    // workout.printState();
    //  std::cout << workout.getTimeRemaining() << std::endl;
    sleep(1);
  }
}

int main()
{

  string mystr = "[" + testJsonStr + "," + testJsonStr + "," + testJsonStr + "]";
  DynamicJsonDocument doc(8096);
  cout << mystr.length() << endl;
  deserializeJson(doc, mystr);
  JsonArray array = doc.as<JsonArray>();
  for (JsonVariant v : array)
  {
    cout << "asd" << endl;
    Tabata t(v);
    cout << "Name: '" << t.getName() << "'   total time: " << t.getTotalTime() << " secs" << endl;
    cout << t.toJson() << endl;
  }

  // test_tabata();
  // test_workout();
}