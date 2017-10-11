#include "TPTest.h"
//#include "json/rapidjson.h"

TPTest* TPTest::m_inst = NULL;
TPTest::TPTest()
{
}

TPTest::~TPTest()
{
}

TPTest* TPTest::getInstance()
{
    if ( !m_inst ) {
        m_inst = new TPTest();
     
    }
    return m_inst;
}



// 调用一个有const char*返回值无参的静态函数
const char* TPTest::doTestMethod()
{
    return "toLua 成功";
}


