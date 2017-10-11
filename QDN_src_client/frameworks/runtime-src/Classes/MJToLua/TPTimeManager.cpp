//
//  TPTimeManager.cpp
//

#include "TPTimeManager.h"

#include "cocos2d.h"

TPTimeManager* TPTimeManager::m_inst = NULL;

TPTimeManager::TPTimeManager()
{
}

TPTimeManager::~TPTimeManager()
{

}

TPTimeManager* TPTimeManager::getInstance()
{
    if ( !m_inst ) {
        m_inst = new TPTimeManager();
    }
    return m_inst;
}

void TPTimeManager::destroyInstance()
{
    CC_SAFE_DELETE(m_inst);
}


TIME_T TPTimeManager::getMilliscond()
{
    struct timeval tvStart;
    gettimeofday(&tvStart,NULL);
    TIME_T tStart = (TIME_T)1000000*tvStart.tv_sec+tvStart.tv_usec;
    return (tStart/1000);
}
