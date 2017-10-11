//
//  Dota
//  计时器
//  检测CPU流逝时间，精确到毫秒
//  前端采用[一次逻辑+一次渲染]所耗费的时间作为一个时间片段

//

#ifndef Dota_TPTimeManager_h
#define Dota_TPTimeManager_h

#include "cocos2d.h"
using namespace cocos2d;

#define TIMEB timeb
typedef long long TIME_T;

struct timeType {
    int year;   //年
    int month;  //月
    int day;    //天
	int hour;   //小时
	int minute; //分钟
	int second; //秒
};

class TPTimeManager
{
protected:
    TPTimeManager();
    // 静态单例
    static TPTimeManager* m_inst;
public:
    virtual ~TPTimeManager();
    //单例函数
    static TPTimeManager* getInstance();
    static void destroyInstance();

    
#pragma mark - 时间的操作函数
public:
   
    
    //返回一个毫秒级时间
    TIME_T getMilliscond();


};
#endif
