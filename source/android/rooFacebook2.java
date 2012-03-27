/*
The rooFacebook2 Copyright

All of the documentation and software included in the rooFacebook2 is copyrighted by Artem Babenko http://www.roolez.com/

Copyright 2011-2012 Artem Babenko http://www.roolez.com/. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
All advertising materials mentioning features or use of this software must display the following acknowledgement:
This product includes software developed by Artem Babenko http://www.roolez.com/ and its contributors.
Neither the name of the Artem Babenko http://www.roolez.com/ nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE Artem Babenko http://www.roolez.com/ AND CONTRIBUTORS ``AS IS''
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
Artem Babenko http://www.roolez.com/ OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/*
java implementation of the rooFacebook2 extension.

Add android-specific functionality here.

These functions are called via JNI from native code.
 */
/*
 * NOTE: This file was originally written by the extension builder, but will not
 * be overwritten (unless --force is specified) and is intended to be modified.
 */
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import java.util.ArrayList;

import android.app.LocalActivityManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;

import com.ideaworks3d.marmalade.LoaderActivity;
import com.ideaworks3d.marmalade.LoaderAPI;

import com.facebook.android.AsyncFacebookRunner;
import com.facebook.android.AsyncFacebookRunner.RequestListener;
import com.facebook.android.Facebook;
import com.facebook.android.FacebookError;
import com.facebook.android.DialogError;
import com.facebook.android.Util;

import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONStringer;

class rooFacebook2 {

	public native void AuthCallback(Object session, String json);

	public native void DialogCallback(Object dialog, String json);

	public native void RequestCallback(Object request, String json);

	public native void DebugLog(String log);

	class rooFacebook_Session {
		Facebook facebook;
		int activityCode;

		class FBActivityCallback implements
				LoaderActivity.IRoolezActivityResult {

			@Override
			public void onActivityResult(int requestCode, int resultCode,
					Intent data) {

				facebook.authorizeCallback(requestCode, resultCode, data);

			}

		}

		class FBSessionDelegateImpl implements Facebook.DialogListener {

			@Override
			public void onComplete(Bundle values) {
				DebugLog("DialogListener.onComplete");
				String json;

				SharedPreferences.Editor editor = LoaderActivity.m_Activity
						.getPreferences(Context.MODE_PRIVATE).edit();
				editor.putString("access_token", facebook.getAccessToken());
				editor.putLong("access_expires", facebook.getAccessExpires());
				editor.commit();

				DebugLog("access_token: " + facebook.getAccessToken());
				DebugLog("expires: " + facebook.getAccessToken());

				JSONObject o1 = new JSONObject();
				try {
					o1.put("rooPlatMethod", "DialogListener.onComplete");
					o1.put("rooStatus", "ok");
					o1.put("rooAuth", true);
					JSONArray arr = new JSONArray();
					for(String key : values.keySet()){
						JSONObject o2 = new JSONObject();
						String value = values.getString(key);
						o2.put("key", key);
						o2.put("value", value);
						arr.put(o2);
					}
					o1.put("data", arr);
				} catch (JSONException e) {
					e.printStackTrace();
				}
				json = o1.toString();
				AuthCallback(rooFacebook_Session.this, json);
			}

			@Override
			public void onFacebookError(FacebookError e) {
				DebugLog("DialogListener.onFacebookError");
				String json;
				JSONObject o1 = new JSONObject();
				try {
					o1.put("rooPlatMethod", "DialogListener.onFacebookError");
					o1.put("rooStatus", "error");
				} catch (JSONException ex) {
					e.printStackTrace();
				}
				json = o1.toString();
				AuthCallback(rooFacebook_Session.this, json);
			}

			@Override
			public void onError(DialogError e) {
				DebugLog("DialogListener.onError");
				String json;
				JSONObject o1 = new JSONObject();
				try {
					o1.put("rooPlatMethod", "DialogListener.onError");
					o1.put("rooStatus", "error");
				} catch (JSONException ex) {
					e.printStackTrace();
				}
				json = o1.toString();
				AuthCallback(rooFacebook_Session.this, json);
			}

			@Override
			public void onCancel() {
				DebugLog("DialogListener.onCancel");
				String json;
				JSONObject o1 = new JSONObject();
				try {
					o1.put("rooPlatMethod", "DialogListener.onCancel");
					o1.put("rooStatus", "error");
				} catch (JSONException e) {
					e.printStackTrace();
				}
				json = o1.toString();
				AuthCallback(rooFacebook_Session.this, json);
			}

		}

		class FBServiceDelegateImpl implements Facebook.ServiceListener {

			@Override
			public void onComplete(Bundle values) {
				DebugLog("ServiceListener.onComplete");
				String json;
				JSONObject o1 = new JSONObject();
				try {
					o1.put("rooPlatMethod", "ServiceListener.onComplete");
					o1.put("rooStatus", "ok");
					o1.put("rooAuth", true);
					JSONArray arr = new JSONArray();
					for(String key : values.keySet()){
						JSONObject o2 = new JSONObject();
						String value = values.getString(key);
						o2.put("key", key);
						o2.put("value", value);
						arr.put(o2);
					}
					o1.put("data", arr);
				} catch (JSONException e) {
					e.printStackTrace();
				}
				json = o1.toString();
				AuthCallback(rooFacebook_Session.this, json);
			}

			@Override
			public void onFacebookError(FacebookError e) {
				DebugLog("ServiceListener.onFacebookError");
				String json;
				JSONObject o1 = new JSONObject();
				try {
					o1.put("rooPlatMethod", "ServiceListener.onFacebookError");
					o1.put("rooStatus", "error");
				} catch (JSONException ex) {
					e.printStackTrace();
				}
				json = o1.toString();
				AuthCallback(rooFacebook_Session.this, json);
			}

			@Override
			public void onError(Error e) {
				DebugLog("ServiceListener.onError");
				String json;
				JSONObject o1 = new JSONObject();
				try {
					o1.put("rooPlatMethod", "ServiceListener.onError");
					o1.put("rooStatus", "error");
				} catch (JSONException ex) {
					e.printStackTrace();
				}
				json = o1.toString();
				AuthCallback(rooFacebook_Session.this, json);
			}

		}

		Facebook.DialogListener getDialogListener() {
			return new FBSessionDelegateImpl();
		}

		Facebook.ServiceListener getServiceListener() {
			return new FBServiceDelegateImpl();
		}

		LoaderActivity.IRoolezActivityResult getActivityResultCallback() {
			return new FBActivityCallback();
		}
	}

	class rooFacebook_Dialog {
		class FBDialogDelegateImpl implements Facebook.DialogListener {

			@Override
			public void onComplete(Bundle values) {
				DebugLog("D DialogListener.onComplete");
				String json;
				JSONObject o1 = new JSONObject();
				try {
					o1.put("rooPlatMethod", "D DialogListener.onComplete");
					o1.put("rooStatus", "ok");
					o1.put("rooAuth", true);
					JSONArray arr = new JSONArray();
					for(String key : values.keySet()){
						JSONObject o2 = new JSONObject();
						String value = values.getString(key);
						o2.put("key", key);
						o2.put("value", value);
						arr.put(o2);
					}
					o1.put("data", arr);
				} catch (JSONException e) {
					e.printStackTrace();
				}
				json = o1.toString();
				DialogCallback(rooFacebook_Dialog.this, json);
			}

			@Override
			public void onFacebookError(FacebookError e) {
				DebugLog("D DialogListener.onFacebookError");
				String json;
				JSONObject o1 = new JSONObject();
				try {
					o1.put("rooPlatMethod", "D DialogListener.onFacebookError");
					o1.put("rooStatus", "error");
				} catch (JSONException ex) {
					e.printStackTrace();
				}
				json = o1.toString();
				DialogCallback(rooFacebook_Dialog.this, json);
			}

			@Override
			public void onError(DialogError e) {
				DebugLog("D DialogListener.onError");
				String json;
				JSONObject o1 = new JSONObject();
				try {
					o1.put("rooPlatMethod", "D DialogListener.onError");
					o1.put("rooStatus", "error");
				} catch (JSONException ex) {
					e.printStackTrace();
				}
				json = o1.toString();
				DialogCallback(rooFacebook_Dialog.this, json);
			}

			@Override
			public void onCancel() {
				DebugLog("D DialogListener.onCancel");
				String json;
				JSONObject o1 = new JSONObject();
				try {
					o1.put("rooPlatMethod", "D DialogListener.onCancel");
					o1.put("rooStatus", "error");
				} catch (JSONException e) {
					e.printStackTrace();
				}
				json = o1.toString();
				DialogCallback(rooFacebook_Dialog.this, json);
			}

		}

		Facebook.DialogListener getListener() {
			return new FBDialogDelegateImpl();
		}
	}

	class rooFacebook_Request {
		public AsyncFacebookRunner afr;

		class FBRequestDelegateImpl implements
				AsyncFacebookRunner.RequestListener {

			@Override
			public void onComplete(String response, Object state) {
				DebugLog("RequestListener.onComplete");
				RequestCallback(rooFacebook_Request.this, response);
			}

			@Override
			public void onIOException(IOException e, Object state) {
				DebugLog("RequestListener.onIOException");
				String json;
				JSONObject o1 = new JSONObject();
				try {
					o1.put("rooPlatMethod", "RequestListener.onIOException");
					o1.put("rooStatus", "error");
				} catch (JSONException ex) {
					e.printStackTrace();
				}
				json = o1.toString();
				RequestCallback(rooFacebook_Request.this, json);

			}

			@Override
			public void onFileNotFoundException(FileNotFoundException e,
					Object state) {
				DebugLog("RequestListener.onFileNotFoundException");
				String json;
				JSONObject o1 = new JSONObject();
				try {
					o1.put("rooPlatMethod", "RequestListener.onFileNotFoundException");
					o1.put("rooStatus", "error");
				} catch (JSONException ex) {
					e.printStackTrace();
				}
				json = o1.toString();
				RequestCallback(rooFacebook_Request.this, json);

			}

			@Override
			public void onMalformedURLException(MalformedURLException e,
					Object state) {
				DebugLog("RequestListener.onMalformedURLException");
				String json;
				JSONObject o1 = new JSONObject();
				try {
					o1.put("rooPlatMethod", "RequestListener.onMalformedURLException");
					o1.put("rooStatus", "error");
				} catch (JSONException ex) {
					e.printStackTrace();
				}
				json = o1.toString();
				RequestCallback(rooFacebook_Request.this, json);

			}

			@Override
			public void onFacebookError(FacebookError e, Object state) {
				DebugLog("RequestListener.onFacebookError");
				String json;
				JSONObject o1 = new JSONObject();
				try {
					o1.put("rooPlatMethod", "RequestListener.onFacebookError");
					o1.put("rooStatus", "error");
				} catch (JSONException ex) {
					e.printStackTrace();
				}
				json = o1.toString();
				RequestCallback(rooFacebook_Request.this, json);

			}
		}

		public AsyncFacebookRunner.RequestListener getListener() {
			return new FBRequestDelegateImpl();
		}
	}

	public static final int FACEBOOK_DEFAULT_AUTH_ACTIVITY_CODE = 32665;

	rooFacebook_Session m_firstSession = null;

	public Object rooFacebook_init(String appId) {
		DebugLog("rooFacebook_init");
		rooFacebook_Session session = new rooFacebook_Session();

		session.facebook = new Facebook(appId);

		SharedPreferences mPrefs = LoaderActivity.m_Activity
				.getPreferences(Context.MODE_PRIVATE);
		String access_token = mPrefs.getString("access_token", null);
		long expires = mPrefs.getLong("access_expires", 0);
		if (access_token != null) {
			session.facebook.setAccessToken(access_token);
			DebugLog("access_token: " + access_token);
		}
		if (expires != 0) {
			session.facebook.setAccessExpires(expires);
			DebugLog("expires: " + expires);
		}

		// fb.
		if (m_firstSession == null) {
			m_firstSession = session;
			session.activityCode = FACEBOOK_DEFAULT_AUTH_ACTIVITY_CODE;
			LoaderActivity.m_Activity.registerRoolezActivity(
					session.activityCode, session.getActivityResultCallback());
		}
		return session;
	}

	public Object rooFacebook_initWithUrlSchemeSuffix(String appId,
			String urlSchemeSuffix) {
		DebugLog("rooFacebook_initWithUrlSchemeSuffix");
		return null;
	}

	public void rooFacebook_authorize(Object facebook, String permissions) {
		DebugLog("rooFacebook_authorize");
		rooFacebook_Session session = (rooFacebook_Session) facebook;

		try {
			JSONArray arr = new JSONArray(permissions);

			ArrayList<String> list = new ArrayList<String>();
			for (int i = 0; i < arr.length(); i++) {
				String s = arr.optString(i);
				if (s != null)
					list.add(s);
			}
			String[] arrperm = list.toArray(new String[list.size()]);
			session.facebook.authorize(LoaderActivity.m_Activity, arrperm,
					session.getDialogListener());
		} catch (JSONException ex) {

		}

	}

	public String rooFacebook_getAccessToken(Object facebook) {
		DebugLog("rooFacebook_extendAccessToken");
		rooFacebook_Session session = (rooFacebook_Session) facebook;

		return session.facebook.getAccessToken();
	}

	public long rooFacebook_getAccessExpires(Object facebook) {
		DebugLog("rooFacebook_extendAccessToken");
		rooFacebook_Session session = (rooFacebook_Session) facebook;

		return session.facebook.getAccessExpires();
	}

	public void rooFacebook_setAccessToken(Object facebook, String access_token) {
		DebugLog("rooFacebook_extendAccessToken");
		rooFacebook_Session session = (rooFacebook_Session) facebook;

		session.facebook.setAccessToken(access_token);
	}

	public void rooFacebook_setAccessExpires(Object facebook,
			long access_expires) {
		DebugLog("rooFacebook_extendAccessToken");
		rooFacebook_Session session = (rooFacebook_Session) facebook;

		session.facebook.setAccessExpires(access_expires);
	}

	public void rooFacebook_extendAccessToken(Object facebook) {
		DebugLog("rooFacebook_extendAccessToken");
		rooFacebook_Session session = (rooFacebook_Session) facebook;

		session.facebook.extendAccessToken(LoaderActivity.m_Activity,
				session.getServiceListener());
	}

	public void rooFacebook_extendAccessTokenIfNeeded(Object facebook) {
		DebugLog("rooFacebook_extendAccessTokenIfNeeded");
		rooFacebook_Session session = (rooFacebook_Session) facebook;

		session.facebook.extendAccessTokenIfNeeded(LoaderActivity.m_Activity,
				session.getServiceListener());

	}

	public void rooFacebook_logout(Object facebook) {
		DebugLog("rooFacebook_logout");
		rooFacebook_Session session = (rooFacebook_Session) facebook;

		try {
			session.facebook.logout(LoaderActivity.m_Activity);
		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

	}

	public void rooFacebook_deleteSession(Object facebook) {
		DebugLog("rooFacebook_deleteSession");
		rooFacebook_Session session = (rooFacebook_Session) facebook;

		if (session != null)
			LoaderActivity.m_Activity
					.unregisterRoolezActivity(session.activityCode);

	}

	public int rooFacebook_isSessionValid(Object facebook) {
		DebugLog("rooFacebook_isSessionValid");
		rooFacebook_Session session = (rooFacebook_Session) facebook;

		return session.facebook.isSessionValid() ? 1 : 0;
	}

	public Object rooFacebook_dialog(Object facebook, String action) {
		DebugLog("rooFacebook_dialog");
		rooFacebook_Session session = (rooFacebook_Session) facebook;

		rooFacebook_Dialog dialog = new rooFacebook_Dialog();

		session.facebook.dialog(LoaderActivity.m_Activity, action,
				dialog.getListener());
		return dialog;
	}

	public Object rooFacebook_dialogAndParams(Object facebook, String action,
			String params) {
		DebugLog("rooFacebook_dialogAndParams");
		rooFacebook_Session session = (rooFacebook_Session) facebook;

		rooFacebook_Dialog dialog = new rooFacebook_Dialog();

		Bundle bundle = new Bundle();

		try {
			JSONObject o1 = new JSONObject(params);
			JSONArray names = o1.names();
			for (int i = 0; i < names.length(); i++) {
				String key = names.optString(i);
				String value = o1.optString(key);
				bundle.putString(key, value);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}

		session.facebook.dialog(LoaderActivity.m_Activity, action, bundle,
				dialog.getListener());
		return dialog;
	}

	public void rooFacebook_deleteDialog(Object dialog) {
		DebugLog("rooFacebook_deleteDialog");

	}

	public Object rooFacebook_requestWithParams(Object facebook, String params) {
		DebugLog("rooFacebook_requestWithParams");
		rooFacebook_Session session = (rooFacebook_Session) facebook;

		rooFacebook_Request request = new rooFacebook_Request();
		request.afr = new AsyncFacebookRunner(session.facebook);

		Bundle bundle = new Bundle();

		try {
			JSONObject o1 = new JSONObject(params);
			JSONArray names = o1.names();
			for (int i = 0; i < names.length(); i++) {
				String key = names.optString(i);
				String value = o1.optString(key);
				bundle.putString(key, value);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}

		request.afr.request(bundle, request.getListener());

		return request;
	}

	public Object rooFacebook_requestWithMethodName(Object facebook,
			String methodName, String params, String httpMethod) {
		DebugLog("rooFacebook_requestWithMethodName");
		rooFacebook_Session session = (rooFacebook_Session) facebook;

		rooFacebook_Request request = new rooFacebook_Request();
		request.afr = new AsyncFacebookRunner(session.facebook);

		Bundle bundle = new Bundle();

		try {
			JSONObject o1 = new JSONObject(params);
			JSONArray names = o1.names();
			for (int i = 0; names != null && i < names.length(); i++) {
				String key = names.optString(i);
				String value = o1.optString(key);
				bundle.putString(key, value);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		bundle.putString("method", methodName);

		request.afr.request(bundle, request.getListener());

		return request;
	}

	public Object rooFacebook_requestWithGraphPath(Object facebook,
			String graphPath) {
		DebugLog("rooFacebook_requestWithGraphPath");
		rooFacebook_Session session = (rooFacebook_Session) facebook;

		rooFacebook_Request request = new rooFacebook_Request();
		request.afr = new AsyncFacebookRunner(session.facebook);

		request.afr.request(graphPath, request.getListener());

		return request;
	}

	public Object rooFacebook_requestWithGraphPathAndParams(Object facebook,
			String graphPath, String params) {
		DebugLog("rooFacebook_requestWithGraphPathAndParams");
		rooFacebook_Session session = (rooFacebook_Session) facebook;

		rooFacebook_Request request = new rooFacebook_Request();
		request.afr = new AsyncFacebookRunner(session.facebook);

		Bundle bundle = new Bundle();

		try {
			JSONObject o1 = new JSONObject(params);
			JSONArray names = o1.names();
			for (int i = 0; i < names.length(); i++) {
				String key = names.optString(i);
				String value = o1.optString(key);
				bundle.putString(key, value);
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}

		request.afr.request(graphPath, bundle, request.getListener());

		return request;
	}

	public Object rooFacebook_requestWithGraphPathAndParamsAndHttpMethod(
			Object facebook, String graphPath, String params, String httpMethod) {
		DebugLog("rooFacebook_requestWithGraphPathAndParamsAndHttpMethod");
		DebugLog(graphPath);
		DebugLog(params);
		DebugLog(httpMethod);

		rooFacebook_Session session = (rooFacebook_Session) facebook;

		rooFacebook_Request request = new rooFacebook_Request();
		request.afr = new AsyncFacebookRunner(session.facebook);

		Bundle bundle = new Bundle();

		DebugLog("pArAmS");
		try {
			JSONObject o1 = new JSONObject(params);
			JSONArray names = o1.names();
			for (int i = 0; i < names.length(); i++) {
				String key = names.optString(i);
				String value = o1.optString(key);
				DebugLog(key);
				DebugLog(value);
				bundle.putString(key, value);
				// try {
				// bundle.putByteArray(key, value.getBytes("UTF8"));
				// } catch (UnsupportedEncodingException e) {
				// // TODO Auto-generated catch block
				// e.printStackTrace();
				// }
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}

		request.afr.request(graphPath, bundle, httpMethod,
				request.getListener(), null);

		return request;
	}

	public void rooFacebook_deleteRequest(Object request) {
		DebugLog("rooFacebook_deleteRequest");
		rooFacebook_Request request1 = (rooFacebook_Request) request;
	}
}
