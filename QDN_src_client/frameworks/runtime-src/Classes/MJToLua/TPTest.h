#include "cocos2d.h"

#ifndef _TPTPTest_H_
#define _TPTPTest_H_

using namespace cocos2d;

class TPTest
{

public:
    TPTest();


    virtual ~TPTest();
    static TPTest* m_inst;
    static TPTest* getInstance();
    const char* doTestMethod();


};


#endif //_TPTPTest_H_
