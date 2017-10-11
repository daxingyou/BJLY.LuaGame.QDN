#include "SocketUtil.h"
#include "proto/command.pb.h"
#include "proto/protocal/ProSMSgHead.h"
#include "tool/Tools.h"
#include "model/GamerData.h"
#include "controller/MainCommand.h"
#include "util/GameConst.h"

SocketUtil* SocketUtil::m_socketUtil = NULL;
int SocketUtil::index = 1;

ODSocket SocketUtil::cSocket;

bool g_haveThread = false;

std::map<Opcode,Opcode> SocketUtil::m_map;

bool SocketUtil::m_isConnected = false;
bool SocketUtil::m_isConnectedSend = false;
bool SocketUtil::m_bStop = false;
std::thread * SocketUtil::m_Tpoint = NULL;


SocketUtil* SocketUtil::getInstance() {
	if(m_socketUtil == NULL) {
		m_socketUtil = new SocketUtil();

		if(m_socketUtil && m_socketUtil->init()) {
			m_socketUtil->autorelease();
		}
		else {
			CC_SAFE_DELETE(m_socketUtil);
		}
	}

	return m_socketUtil;
}

bool SocketUtil::init()
{
	bool bRet = false;
	index = 1;
	m_Tpoint = NULL;
	do 
	{
		m_isConnected = false;
		bRet = true;
	} while (0);

	return bRet;
}

void* SocketUtil::recv( void* data ) 
{
	while(true)
	{
		if(m_bStop==true)
			break;
		/* 报文头 */
		char recvBufHead[54] = "";
		int iResult = cSocket.Recv(recvBufHead,54,0);
		if (iResult < 0)//掉线处理
		{
			//m_map.clear();
			//m_isConnected = false;
			//m_isConnectedSend = false;
			SocketUtil::getInstance()->StopConnect();
			CCLOG("=========================cSocket.Recv=%d",iResult);
			SEND_CUSTOM_MSG("net_offline"); 
			break;
		}
		if(iResult < 54)
		{
			continue;
		}	

		ProSMsgHead* msgHead = (ProSMsgHead*)recvBufHead;
		int opcode = SOCKET_INT_LTOB(msgHead->opcode);
		CCLOG("xian opcode %d:", opcode);
		std::map<Opcode,Opcode>::iterator it = m_map.find((Opcode)opcode);
		if(it != m_map.end())
		{ //找到
			m_map.erase(it);
		}
		int lens   = SOCKET_INT_LTOB(msgHead->len);
		lens = lens -4;
		if (lens<0)
		{
			continue;
		}
		char* buf = new char[lens];	

		int iLeftLen = lens;
		char * current = buf;
		iResult = 0;
		while(iLeftLen>0)
		{
			iResult = cSocket.Recv(current,iLeftLen,0);
			//CCLOG("xian recieve Total %d, return :%d:, left:%d", lens, iResult, iLeftLen);
			iLeftLen -= iResult;
			current += iResult;
		}

		MainCommand::getInstance()->sendMsg(opcode,buf,lens);	
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		Sleep(20);
#else
		usleep(20000);
#endif        
	}
	cSocket.Close();
	return NULL;
}

bool SocketUtil::connectServer()
{
	
	cSocket.Init();
	cSocket.Create(AF_INET,SOCK_STREAM,0);

	int port = GamerData::getInstance()->getServerPort();
	bool result = cSocket.Connect((GamerData::getInstance()->getServerIP()).c_str(), port);
	int retryTimes = 0;
	while(result == false && retryTimes < 0) 
	{
		log("retry connecting...");
		result = cSocket.Connect((GamerData::getInstance()->getServerIP()).c_str(), port);
		retryTimes++;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		Sleep(500);
#else
		usleep(500000);
#endif

	}

	if(result) 
	{
		m_isConnected = true;
		m_isConnectedSend = true;

		if (m_Tpoint!=NULL)
		{
			delete m_Tpoint;
			m_Tpoint = NULL;
		}
		m_bStop = false;
		m_Tpoint = new std::thread(&SocketUtil::recv,this);
		m_Tpoint->detach();
		g_haveThread = true;

	}	
	else
	{
		m_map.clear();
		m_isConnected = false;
		m_isConnectedSend = false;
		CCLOG("=========================can not connect to server");
		SEND_CUSTOM_MSG(CustomEvent::key_show_low_net_layer);
	}

	return result;
}
void SocketUtil::sendMsg(Opcode opcode, std::string buf,  int flags /*= 0*/ ) {		
	if (!m_isConnectedSend) 
	{
		m_map.clear();
		return;
	}
	std::map<Opcode,Opcode>::iterator it = m_map.find(opcode);
	if(opcode==1 || it == m_map.end())
	{ //没找到
		if (opcode==1 && it != m_map.end())
		{
			m_map.erase(it);
		}
		m_map.insert(std::make_pair(opcode,opcode));
	}
	else
	{ //找到

		return;
	}

	index++;
	char*pSend = new char[54+buf.size()];
	ProSMsgHead head;

	head.HEAD_0=char(78);
	head.HEAD_1=char(37);
	head.HEAD_2=char(38);
	head.HEAD_3=char(48);
	head.ProtoVersion=char(10);
	head.flag=char(0);
	head.ServerVersion=SOCKET_INT_LTOB(0);

	head.index=SOCKET_INT_LTOB(index);
	head.len=SOCKET_INT_LTOB(buf.size()+4);
	head.opcode=SOCKET_INT_LTOB(opcode);
	string accessStr = GamerData::getInstance()->getAccessKey();
	if (accessStr == "")
	{
		strcpy(head.accessID, "");
	}
	else
	{
		char szAccessStr[33] = {0};
		for (int i = 0; i < 32; i++)
		{
			szAccessStr[i] = accessStr[i];
		}
		memcpy(head.accessID, szAccessStr,32);
	}
	log("size%d",sizeof(head));
	memcpy(pSend, &head, sizeof(ProSMsgHead));
	char * pBody = pSend+sizeof(ProSMsgHead);
	for (int i = 0; i < buf.size() ; i++)
	{
		*pBody=buf[i];
		pBody++;
	}
    
    CCLOG("opcode == %d ,pSend == %s",opcode,pSend);
	cSocket.Send(pSend, 54+buf.size(), 0);
}

int SocketUtil::EndianConvertLToB(int InputNum) 
{

	unsigned char *p = (unsigned char*)&InputNum;

	return(((int)*p<<24)+((int)*(p+1)<<16)+

		((int)*(p+2)<<8)+(int)*(p+3));

}


int SocketUtil::EndianConvertBToL(int InputNum) 
{

	unsigned char *p = (unsigned char*)&InputNum;

	return(((int)*p)+((int)*(p+1)<<8)+

		((int)*(p+2)<<16)+(int)*(p+3)<<24);

}

bool SocketUtil::isConnected()
{
	if (!m_isConnected)m_map.clear();
	return m_isConnected;
}

void SocketUtil::StopConnect()
{	
	if (isConnected())
	{
		m_map.clear();
		m_isConnected= false;
		m_isConnectedSend = false;
		m_bStop = true;
		delete m_Tpoint;
		m_Tpoint = NULL;
		index=1;

		CCLOG("============cSocket.Close()=============");
		cSocket.Close();
	}	
}

void SocketUtil::SetIsConnected(bool bSet)
{
	m_isConnected= bSet;
}
void SocketUtil::SetIsConnectedSend(bool _bSet)
{
	m_isConnectedSend = _bSet;
}
void SocketUtil::test()
{
	cSocket.GetError();
	log("----test---");
}
