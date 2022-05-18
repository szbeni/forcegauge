

#include <string>
#include "tabata.h"

using namespace std;

std::string testJsonStr = "{""}";

int main() {
  Tabata t1("Test Tabata", 2, 3, 10, 10, 60, 1, 10);
  std::cout << "Name: '" << t1.getName() << "'   total time: " << t1.getTotalTime() << " secs" << std::endl;

  // Tabata t2(testJsonStr);
}