#include "TestLuaLayer.h"
bool TestLayer::init()
{
   if(!Layer::init())
   {
	   return false;
   }
   return true;
}