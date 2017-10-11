/****************************************************************************
 Copyright (c) 2008-2010 Ricardo Quesada
 Copyright (c) 2010-2012 cocos2d-x.org
 Copyright (c) 2011      Zynga Inc.
 Copyright (c) 2013-2014 Chukong Technologies Inc.

 http://www.cocos2d-x.org

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
package com.laiya.game.tianzhuMJ;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.json.JSONException;
import org.json.JSONObject;

import com.base.lua.Util;
import com.base.lua.WXHelper;
import com.tencent.gcloud.voice.GCloudVoiceEngine;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;

import android.content.BroadcastReceiver;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Build;
import android.os.Bundle;
import android.util.AndroidException;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;

public class AppActivity extends Cocos2dxActivity {
	public static AppActivity appThis;
	static String hostIPAdress = "0.0.0.0";

	// ���а��������
	private static ClipboardManager mClipboardManager;
	// ���а�Data����
	private static ClipData mClipData;
	private static Intent batteryStatus;

	private BroadcastReceiver bettrystatereceiver;
	private static float batteryPercent;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		appThis = this;
		hideBottomUIMenu();
		appThis.getWindow().getDecorView().setOnSystemUiVisibilityChangeListener(new View.OnSystemUiVisibilityChangeListener() {
            @Override
            public void onSystemUiVisibilityChange(int visibility) {
            	hideBottomUIMenu();
            }
        });
		GCloudVoiceEngine.getInstance().init(getApplicationContext(), this);

		getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON); 
		mClipboardManager = (ClipboardManager) getSystemService(CLIPBOARD_SERVICE);

		setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);

		batteryPercent = 0.1f;
		IntentFilter intentFilter = new IntentFilter(Intent.ACTION_BATTERY_CHANGED);
		bettrystatereceiver = new BroadcastReceiver() {
			@Override
			public void onReceive(Context context, Intent intent) {
				if (Intent.ACTION_BATTERY_CHANGED.equals(intent.getAction())) {
					// ��ȡ��ǰ����
					int leve_baterry = intent.getIntExtra("level", 0);
					// �������̶ܿ�
					int scale_baterry = intent.getIntExtra("scale", 100);
					batteryPercent = leve_baterry / (float) scale_baterry;
				}
			}
		};
		registerReceiver(bettrystatereceiver, intentFilter);
//		if (WXHelper.api == null)	{
//			WXHelper.api = WXAPIFactory.createWXAPI(this, Constants.APP_ID, false);
//			WXHelper.api.registerApp(Constants.APP_ID);
//		}
		if(WXHelper.api == null) {
			WXHelper.api = WXAPIFactory.createWXAPI(this, Constants.APP_ID, false);
			WXHelper.api.registerApp(Constants.APP_ID);
		}
		

		Log.d("asfasdf", "AppActivity----create!!!!");
	}

	public String getHostIpAddress() {
		WifiManager wifiMgr = (WifiManager) getSystemService(WIFI_SERVICE);
		WifiInfo wifiInfo = wifiMgr.getConnectionInfo();
		int ip = wifiInfo.getIpAddress();
		return ((ip & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF));
	}

	public static String getLocalIpAddress() {
		return hostIPAdress;
	}

	public static void hideBottomUIMenu() {
		appThis.runOnUiThread(new Runnable() {
			@Override
			public void run() {
				// 隐藏虚拟按键，并且全屏
				if (Build.VERSION.SDK_INT > 11 && Build.VERSION.SDK_INT < 19) { // lower api
					View v = appThis.getWindow().getDecorView();
					v.setSystemUiVisibility(View.GONE);
				} else if (Build.VERSION.SDK_INT >= 19) {
					// for new api versions.
					View decorView = appThis.getWindow().getDecorView();
					int uiOptions = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
							| View.SYSTEM_UI_FLAG_FULLSCREEN;
					decorView.setSystemUiVisibility(uiOptions);
				}
			}
		});
	}

	private static native boolean nativeIsLandScape();

	private static native boolean nativeIsDebug();

	public static boolean CopyText(String copyTxt) {
		Log.d("copyTxt==============", copyTxt);
		// ����һ���µ��ı�clip����
		mClipData = ClipData.newPlainText("Simple test", copyTxt);
		// ��clip������ڼ�������
		mClipboardManager.setPrimaryClip(mClipData);
		return true;
	}

	public static String getAppVersion() throws AndroidException {
		PackageInfo pInfo = getContext().getPackageManager().getPackageInfo(getContext().getPackageName(), 0);
		String version = pInfo.versionName;// +" "+ pInfo.versionCode;
		Log.d("version==============", version);
		return version;
	}

	public static void WxShareCallBack(final int kUrl) {
		System.out.println("Hello"+kUrl);
			new Thread() {
				@Override
				public void run() {					
					JSONObject jObject = new JSONObject();
					try {
						jObject.put("funId", "J2Lua_WeiXinShare");
					} catch (JSONException e) {
						e.printStackTrace();
					}
					try {
						jObject.put("data", kUrl);
					} catch (JSONException e) {
						e.printStackTrace();
					}
					final String args = jObject.toString();
					appThis.runOnGLThread(new Runnable() {
						@Override
						public void run() {
							Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("J2LuaSystem_CallBack", args);
						}
					});
				}
			}.start();
	}
	public static void WxLoginCallBack_GetAccessToken(final String kUrl) {
		System.out.println("kUrl=====" + kUrl);
		new Thread() {
			@Override
			public void run() {
				String res = ReqestWXAccessToken(kUrl);
				CallLuaFun("J2Lua_WeiXinAccess",res);
			}
		}.start();
	}

	public static String ReqestWXAccessToken(String code) {
		String url = "https://api.weixin.qq.com/sns/oauth2/access_token?";
		String param = String.format("appid=%s&secret=%s&code=%s&grant_type=authorization_code", Constants.APP_ID,
				Constants.AppSecret, code);
		String res = Util.sendGet(url + param);
		System.out.println("ReqestWXAccessToken=====" + res);
		return res;
	}

	public static float getBatteryPercent() {
		return batteryPercent;
	}
	
	public static void WxLoginErrorShow(int errCode,String errStr) {
		JSONObject jObject = new JSONObject();
		try {
			jObject.put("errCode",errCode);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		try {
			jObject.put("errStr", errStr);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		final String args = jObject.toString(); 
		CallLuaFun("J2Lua_WXLoginErrorShow",args);
	}
	public static void CallLuaFun(String funId,String data) {
		JSONObject jObject = new JSONObject();
		try {
			jObject.put("funId", funId);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		try {
			jObject.put("data", data);
		} catch (JSONException e) {
			e.printStackTrace();
		}
		final String args = jObject.toString();
		appThis.runOnGLThread(new Runnable() {
			@Override
			public void run() {
				Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("J2LuaSystem_CallBack", args);
//				Cocos2dxLuaJavaBridge.callLuaFunctionWithString("J2LuaSystem_CallBack", args);
			}
		});		
	}
}
