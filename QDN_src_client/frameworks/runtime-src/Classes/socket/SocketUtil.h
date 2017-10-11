#pragma once

#include "cocos2d.h"
#include "ODSocket.h"
#include "proto/opcode.pb.h"
USING_NS_CC;
using namespace pb;
using namespace std;

class SocketUtil : public cocos2d::Ref {
public:
    static SocketUtil* getInstance();
    virtual bool init();

    bool connectServer();   // 连接服务器
    void sendMsg(Opcode opcode,std::string buf,int flags = 0);         // 发送消息给服务器
    int  EndianConvertLToB(int InputNum);  // int小端转换为大端
    int  EndianConvertBToL(int InputNum);  // int大端转换为小端
    bool isConnected();
    void StopConnect();
    void SetIsConnected(bool bSet);
	void SetIsConnectedSend(bool _bSet);

	void test();

public:
    static SocketUtil* m_socketUtil;
    static int index;
    static ODSocket cSocket;
    static void* recv(void* data);
    static bool m_isConnected;
	static bool m_isConnectedSend;
    static map<Opcode,Opcode> m_map;
    static thread *m_Tpoint;
    static bool m_bStop;  
};
