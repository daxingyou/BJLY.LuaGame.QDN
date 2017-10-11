#ifndef _TEST_LUA_H_
#define _TEST_LUA_H_
#include "cocos2d.h"
using namespace cocos2d;
class TestLayer :public Layer
{
public:
	virtual bool init();
	CREATE_FUNC(TestLayer);
};
#endif