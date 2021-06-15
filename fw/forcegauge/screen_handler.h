#pragma once 

typedef boolean (*Screen_Function)();

const typedef struct
{
    char text[16];
    Screen_Function func;
} ScreenItem;


class ScreenList {
private:
  ScreenItem *screenItems;
  uint8_t listSize;
public:
  ScreenItem* getItem(int index)
  {
    while (index < 0) {
      index += listSize;
    }
    return &(screenItems[index % listSize]);
  }
  
  ScreenList(ScreenItem* screenItems, uint8_t listSize)
  {
    this->screenItems = screenItems;
    this->listSize = listSize;
  }
  uint8_t getSize(){
    return listSize;
  }
};


class ScreenHandler {
private:
  int currentIndex=0;
  ScreenItem *activeScreen;
  ScreenList *screenList;
public:
  ScreenHandler(){
  }
  
  void nextScreen()
  {
    currentIndex++;
    if (currentIndex >= screenList->getSize())
    {
      currentIndex = 0;
    }
    setScreen(currentIndex);
  }

  void prevScreen()
  {
    currentIndex--;
    if (currentIndex < 0)
    {
      currentIndex = screenList->getSize()-1;
    }
    setScreen(currentIndex);
  }

  ScreenItem* setScreen(int index)
  {
    activeScreen = screenList->getItem(index);
    return activeScreen;
  }
  
  void buttonShortPress(int num)
  {
    if (num == 0) 
      prevScreen();
    if (num == 2) 
      nextScreen();
  }

  void buttonLongPress(int num)
  {
    
  }

  void buttonHold(int num)
  {
    
  }

  void buttonRelease(int num)
  {
    
  }
  
  void init(ScreenList* screenList)
  {
    this->screenList = screenList;
    setScreen(0);
  }
    
  void loop()
  {
    if (activeScreen != NULL)
    {
      activeScreen->func();
    }
  }
};
