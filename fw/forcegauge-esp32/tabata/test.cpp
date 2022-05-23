
#include <iostream>
#include <string>
#include <time.h>
#include <unistd.h>
#include "ArduinoJson.h"
// #include "tabata.h"
// #include "workout.h"
// #include "tabataHandler.h"

using namespace std;
string testJsonStr =
    "{\"name\":\"Test Tabata 2\", "
    "\"sets\":2,\"reps\":3,\"exerciseTime\":10,\"restTime\":20,\"breakTime\":60,\"startDelay\":20,"
    "\"warningBeforeBreakEndsTime\":10}";

// void test_tabata(void)
// {
//   Tabata t1("Test Tabata", 2, 3, 10, 10, 60, 1, 10);
//   cout << "Name: '" << t1.getName() << "'   total time: " << t1.getTotalTime() << " secs" << endl;
//   cout << "Json:" << t1.toJson() << endl;

//   Tabata t2(testJsonStr);
//   cout << "Name: '" << t2.getName() << "'   total time: " << t2.getTotalTime() << " secs" << endl;

//   Tabata t3(t1.toJson());
//   t3.name = "My Tabata 3";
//   cout << "Name: '" << t3.getName() << "'   total time: " << t3.getTotalTime() << " secs" << endl;
// }

// void test_workout()
// {
//   Tabata t1("Test Workout", 2, 3, 2, 3, 5, 3, 0);
//   Workout workout(t1);
//   workout.start();
//   for (int i = 0; i < 100; i++)
//   {

//     workout.tick();
//     // workout.printState();
//     //  std::cout << workout.getTimeRemaining() << std::endl;
//     sleep(1);
//   }
// }
void add(JsonObject obj)
{
  obj["name"] = "asd";
  obj["malac"] = 1;
}

int main()
{
  // StaticJsonDocument<CAPACITY> doc;
  DynamicJsonDocument doc(8192);

  // parse a JSON array
  deserializeJson(doc, "[{\"name\":\"malac\"},2,3]");

  add(doc.createNestedObject());
  cout << doc.size() << endl;
  cout << doc[3] << endl;
  // doc.remove(5);
  // cout << doc.size() << endl;

  // doc.add();

  // extract the values
  // JsonArray array = doc.as<JsonArray>();
  // auto t = array.get<JsonVariant>(2);
  // cout << t << endl;

  // for (JsonVariant v : array)
  // {
  //   cout << v.as<JsonObject>()["name"] << endl;
  // }

  // JsonArray _tabataArray;
  // cout << _tabataArray.size() << endl;

  // string mystr = "[" + testJsonStr + "," + testJsonStr + "," + testJsonStr + "]";
  // DynamicJsonDocument doc(8096);
  // cout << mystr.length() << endl;
  // deserializeJson(doc, mystr);
  // JsonArray array = doc.as<JsonArray>();
  // for (JsonVariant v : array)
  // {
  //   cout << "asd" << endl;
  //   Tabata t(v);
  //   cout << "Name: '" << t.getName() << "'   total time: " << t.getTotalTime() << " secs" << endl;
  //   cout << t.toJson() << endl;
  // }

  // // test_tabata();
  // // test_workout();
}