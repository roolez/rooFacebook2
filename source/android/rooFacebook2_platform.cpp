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
 * android-specific implementation of the rooFacebook2 extension.
 * Add any platform-specific functionality here.
 */
/*
 * NOTE: This file was originally written by the extension builder, but will not
 * be overwritten (unless --force is specified) and is intended to be modified.
 */
#include "rooFacebook2_internal.h"

#include "s3eEdk.h"
#include "s3eEdk_android.h"
#include <jni.h>
#include "IwDebug.h"


const char * g_Str = NULL;

enum rooFacebook_Callback{
    e_rooFacebook_session,
    e_rooFacebook_dialog,
    e_rooFacebook_request,
    e_rooFacebook_MAX
};

static jobject g_KnownObjects[64] = {0};
//Java object handles are not unique, so we need to be able to
//get a unique handle to each object for the purposes of callbacks
jobject getKnownObject(jobject obj)
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    IwTrace(FACEBOOK_VERBOSE, ("Getting known object %p", obj));
    for (uint i=0;i<sizeof(g_KnownObjects)/sizeof(g_KnownObjects[0]);i++)
    {
        if (g_KnownObjects[i])
            IwTrace(FACEBOOK_VERBOSE, ("Comparing with %p", g_KnownObjects[i]));
        if (env->IsSameObject(obj, g_KnownObjects[i]))
            return g_KnownObjects[i];
    }

    return NULL;
}

void addKnownObject(jobject obj)
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    IwTrace(FACEBOOK_VERBOSE, ("Adding known object %p", obj));
    if (getKnownObject(obj))
        return;

    for (uint i=0;i<sizeof(g_KnownObjects)/sizeof(g_KnownObjects[0]);i++)
    {
        if (!g_KnownObjects[i])
        {
            g_KnownObjects[i] = obj;
            return;
        }
    }

    IwAssertMsg(FACEBOOK, false, ("Out of known object storage!"));
}

void removeKnownObejct(jobject obj)
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    for (uint i=0;i<sizeof(g_KnownObjects)/sizeof(g_KnownObjects[0]);i++)
    {
        if (env->IsSameObject(obj, g_KnownObjects[i]))
        {
            g_KnownObjects[i] = NULL;
        }
    }
}




static void rooFacebook_AuthCallback(JNIEnv *env, jobject _this, jobject session, jstring json);
static void rooFacebook_DialogCallback(JNIEnv *env, jobject _this, jobject dialog, jstring json);
static void rooFacebook_(JNIEnv *env, jobject _this, jobject request, jstring json);

void rooFacebook_AuthCallback(JNIEnv *env, jobject _this, jobject session, jstring json)
{
	s3eDebugOutputString("rooFacebook_AuthCallback");

	void* m_external = (void*)getKnownObject(session);
    IwAssert(FACEBOOK, m_external);

    jboolean free;
    const char* systemData = env->GetStringUTFChars(json, &free);
    int size = strlen(systemData);

	s3eDebugOutputString(systemData);

    s3eEdkCallbacksEnqueue(S3E_EXT_ROOFACEBOOK2_HASH
                           , e_rooFacebook_session
                           , (void*)systemData
                           , size
                           , m_external
                           , S3E_FALSE
                           );

    env->ReleaseStringUTFChars(json, systemData);
}


void rooFacebook_DialogCallback(JNIEnv *env, jobject _this, jobject dialog, jstring json)
{
	s3eDebugOutputString("rooFacebook_DialogCallback");

    void* m_external = (void*)getKnownObject(dialog);
    IwAssert(FACEBOOK, m_external);

    jboolean free;
    const char* systemData = env->GetStringUTFChars(json, &free);
    int size = strlen(systemData);

	s3eDebugOutputString(systemData);

    s3eEdkCallbacksEnqueue(S3E_EXT_ROOFACEBOOK2_HASH
                           , e_rooFacebook_dialog
                           , (void*)systemData
                           , size
                           , m_external
                           , S3E_FALSE
                           );

    env->ReleaseStringUTFChars(json, systemData);


}


void rooFacebook_RequestCallback(JNIEnv *env, jobject _this, jobject request, jstring json)
{
	s3eDebugOutputString("rooFacebook_RequestCallback");

    void* m_external = (void*)getKnownObject(request);
    IwAssert(FACEBOOK, m_external);

    jboolean free;
    const char* systemData = env->GetStringUTFChars(json, &free);
    int size = strlen(systemData);

	s3eDebugOutputString(systemData);

    s3eEdkCallbacksEnqueue(S3E_EXT_ROOFACEBOOK2_HASH
                           , e_rooFacebook_request
                           , (void*)systemData
                           , size
                           , m_external
                           , S3E_FALSE
                           );

    env->ReleaseStringUTFChars(json, systemData);


}

void rooFacebook_DebugLog(JNIEnv *env, jobject _this, jstring json)
{
    jboolean free;
    const char* systemData = env->GetStringUTFChars(json, &free);
    s3eDebugOutputString(systemData);
    env->ReleaseStringUTFChars(json, systemData);
}

static jobject g_Obj;
static jmethodID g_rooFacebook_init;
static jmethodID g_rooFacebook_initWithUrlSchemeSuffix;
static jmethodID g_rooFacebook_authorize;
static jmethodID g_rooFacebook_getAccessToken;
static jmethodID g_rooFacebook_getAccessExpires;
static jmethodID g_rooFacebook_setAccessToken;
static jmethodID g_rooFacebook_setAccessExpires;
static jmethodID g_rooFacebook_extendAccessToken;
static jmethodID g_rooFacebook_extendAccessTokenIfNeeded;
static jmethodID g_rooFacebook_logout;
static jmethodID g_rooFacebook_deleteSession;
static jmethodID g_rooFacebook_isSessionValid;
static jmethodID g_rooFacebook_dialog;
static jmethodID g_rooFacebook_dialogAndParams;
static jmethodID g_rooFacebook_deleteDialog;
static jmethodID g_rooFacebook_requestWithParams;
static jmethodID g_rooFacebook_requestWithMethodName;
static jmethodID g_rooFacebook_requestWithGraphPath;
static jmethodID g_rooFacebook_requestWithGraphPathAndParams;
static jmethodID g_rooFacebook_requestWithGraphPathAndParamsAndHttpMethod;
static jmethodID g_rooFacebook_deleteRequest;

s3eResult rooFacebook2Init_platform()
{
	s3eDebugOutputString("rooFacebook2Init_platform");
    // Get the environment from the pointer
    JNIEnv* env = s3eEdkJNIGetEnv();
    jobject obj = NULL;
    jmethodID cons = NULL;

    // Get the extension class
    jclass cls = s3eEdkAndroidFindClass("rooFacebook2");
    if (!cls)
        goto fail;

    // Get its constructor
    cons = env->GetMethodID(cls, "<init>", "()V");
    if (!cons)
        goto fail;

    // Construct the java class
    obj = env->NewObject(cls, cons);
    if (!obj)
        goto fail;

    // Get all the extension methods
    g_rooFacebook_init = env->GetMethodID(cls, "rooFacebook_init", "(Ljava/lang/String;)Ljava/lang/Object;");
    if (!g_rooFacebook_init)
        goto fail;

    g_rooFacebook_initWithUrlSchemeSuffix = env->GetMethodID(cls, "rooFacebook_initWithUrlSchemeSuffix", "(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;");
    if (!g_rooFacebook_initWithUrlSchemeSuffix)
        goto fail;

    g_rooFacebook_authorize = env->GetMethodID(cls, "rooFacebook_authorize", "(Ljava/lang/Object;Ljava/lang/String;)V");
    if (!g_rooFacebook_authorize)
        goto fail;

    g_rooFacebook_getAccessToken = env->GetMethodID(cls, "rooFacebook_getAccessToken", "(Ljava/lang/Object;)Ljava/lang/String;");
    if (!g_rooFacebook_getAccessToken)
        goto fail;

    g_rooFacebook_getAccessExpires = env->GetMethodID(cls, "rooFacebook_getAccessExpires", "(Ljava/lang/Object;)J");
    if (!g_rooFacebook_getAccessExpires)
        goto fail;

    g_rooFacebook_setAccessToken = env->GetMethodID(cls, "rooFacebook_setAccessToken", "(Ljava/lang/Object;Ljava/lang/String;)V");
    if (!g_rooFacebook_setAccessToken)
        goto fail;

    g_rooFacebook_setAccessExpires = env->GetMethodID(cls, "rooFacebook_setAccessExpires", "(Ljava/lang/Object;J)V");
    if (!g_rooFacebook_setAccessExpires)
        goto fail;

    g_rooFacebook_extendAccessToken = env->GetMethodID(cls, "rooFacebook_extendAccessToken", "(Ljava/lang/Object;)V");
    if (!g_rooFacebook_extendAccessToken)
        goto fail;

     g_rooFacebook_extendAccessTokenIfNeeded = env->GetMethodID(cls, "rooFacebook_extendAccessTokenIfNeeded", "(Ljava/lang/Object;)V");
    if (!g_rooFacebook_extendAccessTokenIfNeeded)
        goto fail;

    g_rooFacebook_logout = env->GetMethodID(cls, "rooFacebook_logout", "(Ljava/lang/Object;)V");
    if (!g_rooFacebook_logout)
        goto fail;

    g_rooFacebook_deleteSession = env->GetMethodID(cls, "rooFacebook_deleteSession", "(Ljava/lang/Object;)V");
    if (!g_rooFacebook_deleteSession)
        goto fail;

    g_rooFacebook_isSessionValid = env->GetMethodID(cls, "rooFacebook_isSessionValid", "(Ljava/lang/Object;)I");
    if (!g_rooFacebook_isSessionValid)
        goto fail;

    g_rooFacebook_dialog = env->GetMethodID(cls, "rooFacebook_dialog", "(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;");
    if (!g_rooFacebook_dialog)
        goto fail;

    g_rooFacebook_dialogAndParams = env->GetMethodID(cls, "rooFacebook_dialogAndParams", "(Ljava/lang/Object;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;");
    if (!g_rooFacebook_dialogAndParams)
        goto fail;

    g_rooFacebook_deleteDialog = env->GetMethodID(cls, "rooFacebook_deleteDialog", "(Ljava/lang/Object;)V");
    if (!g_rooFacebook_deleteDialog)
        goto fail;

    g_rooFacebook_requestWithParams = env->GetMethodID(cls, "rooFacebook_requestWithParams", "(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;");
    if (!g_rooFacebook_requestWithParams)
        goto fail;

    g_rooFacebook_requestWithMethodName = env->GetMethodID(cls, "rooFacebook_requestWithMethodName", "(Ljava/lang/Object;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;");
    if (!g_rooFacebook_requestWithMethodName)
        goto fail;

    g_rooFacebook_requestWithGraphPath = env->GetMethodID(cls, "rooFacebook_requestWithGraphPath", "(Ljava/lang/Object;Ljava/lang/String;)Ljava/lang/Object;");
    if (!g_rooFacebook_requestWithGraphPath)
        goto fail;

    g_rooFacebook_requestWithGraphPathAndParams = env->GetMethodID(cls, "rooFacebook_requestWithGraphPathAndParams", "(Ljava/lang/Object;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;");
    if (!g_rooFacebook_requestWithGraphPathAndParams)
        goto fail;

    g_rooFacebook_requestWithGraphPathAndParamsAndHttpMethod = env->GetMethodID(cls, "rooFacebook_requestWithGraphPathAndParamsAndHttpMethod", "(Ljava/lang/Object;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/Object;");
    if (!g_rooFacebook_requestWithGraphPathAndParamsAndHttpMethod)
        goto fail;

    g_rooFacebook_deleteRequest = env->GetMethodID(cls, "rooFacebook_deleteRequest", "(Ljava/lang/Object;)V");
    if (!g_rooFacebook_deleteRequest)
        goto fail;

    {
		const JNINativeMethod nativeMethodDefs[] =
		{
			{"AuthCallback",        "(Ljava/lang/Object;Ljava/lang/String;)V",        (void *)&rooFacebook_AuthCallback},
			{"DialogCallback",        "(Ljava/lang/Object;Ljava/lang/String;)V",        (void *)&rooFacebook_DialogCallback},
			{"RequestCallback",        "(Ljava/lang/Object;Ljava/lang/String;)V",        (void *)&rooFacebook_RequestCallback},
			{"DebugLog",        "(Ljava/lang/String;)V",        (void *)&rooFacebook_DebugLog},
		};

		env->RegisterNatives(cls, nativeMethodDefs, sizeof(nativeMethodDefs)/sizeof(nativeMethodDefs[0]));
    }
    IwTrace(ROOFACEBOOK2, ("ROOFACEBOOK2 init success"));
    g_Obj = env->NewGlobalRef(obj);
    env->DeleteLocalRef(obj);
    env->DeleteGlobalRef(cls);

    // Add any platform-specific initialisation code here
    return S3E_RESULT_SUCCESS;

fail:
    jthrowable exc = env->ExceptionOccurred();
    if (exc)
    {
        env->ExceptionDescribe();
        env->ExceptionClear();
        IwTrace(rooFacebook2, ("One or more java methods could not be found"));
    }
    return S3E_RESULT_ERROR;

}

void rooFacebook2Terminate_platform()
{
	s3eDebugOutputString("rooFacebook2Terminate_platform");
    // Add any platform-specific termination code here
}

rooFacebook_Session * rooFacebook_init_platform(const char* appId, rooFacebook_CallbackSpecific callback, void * userData)
{
	s3eDebugOutputString("rooFacebook_init_platform");

    JNIEnv* env = s3eEdkJNIGetEnv();
    jstring appId_jstr = env->NewStringUTF(appId);
    jobject ret = env->CallObjectMethod(g_Obj, g_rooFacebook_init, appId_jstr);
    ret = env->NewGlobalRef(ret);
    addKnownObject(ret);



    s3eEdkCallbacksRegisterSpecific (S3E_EXT_ROOFACEBOOK2_HASH
                                     , e_rooFacebook_MAX
                                     , e_rooFacebook_session
                                     , callback
                                     , userData
                                     , S3E_FALSE
                                     , ret);


    return (rooFacebook_Session*)ret;
}

rooFacebook_Session * rooFacebook_initWithUrlSchemeSuffix_platform(const char* appId, const char * urlSchemeSuffix, rooFacebook_CallbackSpecific callback, void * userData)
{
	s3eDebugOutputString("rooFacebook_initWithUrlSchemeSuffix_platform");

    JNIEnv* env = s3eEdkJNIGetEnv();
    jstring appId_jstr = env->NewStringUTF(appId);
    jstring urlSchemeSuffix_jstr = env->NewStringUTF(urlSchemeSuffix);
    jobject ret = env->CallObjectMethod(g_Obj, g_rooFacebook_init, appId_jstr, urlSchemeSuffix_jstr);
    ret = env->NewGlobalRef(ret);
    addKnownObject(ret);



    s3eEdkCallbacksRegisterSpecific (S3E_EXT_ROOFACEBOOK2_HASH
                                     , e_rooFacebook_MAX
                                     , e_rooFacebook_session
                                     , callback
                                     , userData
                                     , S3E_FALSE
                                     , ret);


    return (rooFacebook_Session*)ret;

}

void rooFacebook_authorize_platform(rooFacebook_Session * facebook, const char * permissions)
{
	s3eDebugOutputString("rooFacebook_authorize_platform");
	s3eDebugOutputString(permissions);
    JNIEnv* env = s3eEdkJNIGetEnv();
    jstring permissions_jstr = env->NewStringUTF(permissions);
    env->CallVoidMethod(g_Obj, g_rooFacebook_authorize, (jobject)facebook, permissions_jstr);
}

const char * rooFacebook_getAccessToken_platform(rooFacebook_Session * facebook)
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    jobject ret = env->CallObjectMethod(g_Obj, g_rooFacebook_getAccessToken, (jobject)facebook);
    jstring s = (jstring)ret;

    jboolean b;
    const char* str = env->GetStringUTFChars(s, &b);

    if(g_Str)
    	free((void*)g_Str);
    g_Str = strdup(str);

    env->ReleaseStringUTFChars(s, str);

    return g_Str;
}

int rooFacebook_getAccessExpires_platform(rooFacebook_Session * facebook)
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    return (int)env->CallLongMethod(g_Obj, g_rooFacebook_getAccessExpires, (jobject)facebook);
}

void rooFacebook_setAccessToken_platform(rooFacebook_Session * facebook, const char * access_token)
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    jstring access_token_jstr = env->NewStringUTF(access_token);
    env->CallVoidMethod(g_Obj, g_rooFacebook_setAccessToken, (jobject)facebook, access_token_jstr);
}

void rooFacebook_setAccessExpires_platform(rooFacebook_Session * facebook, int access_expires)
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    env->CallVoidMethod(g_Obj, g_rooFacebook_setAccessExpires, (jobject)facebook, access_expires);
}

void rooFacebook_extendAccessToken_platform(rooFacebook_Session * facebook)
{
    JNIEnv* env = s3eEdkJNIGetEnv();
    env->CallVoidMethod(g_Obj, g_rooFacebook_extendAccessToken, (jobject)facebook);
}

void rooFacebook_extendAccessTokenIfNeeded_platform(rooFacebook_Session * facebook)
{
	s3eDebugOutputString("rooFacebook_extendAccessTokenIfNeeded_platform");
    JNIEnv* env = s3eEdkJNIGetEnv();
    env->CallVoidMethod(g_Obj, g_rooFacebook_extendAccessTokenIfNeeded, (jobject)facebook);
}

void rooFacebook_logout_platform(rooFacebook_Session * facebook)
{
	s3eDebugOutputString("rooFacebook_logout_platform");
    JNIEnv* env = s3eEdkJNIGetEnv();
    env->CallVoidMethod(g_Obj, g_rooFacebook_logout, (jobject)facebook);
}

void rooFacebook_deleteSession_platform(rooFacebook_Session * facebook)
{
	s3eDebugOutputString("rooFacebook_deleteSession_platform");
    JNIEnv* env = s3eEdkJNIGetEnv();
    env->CallVoidMethod(g_Obj, g_rooFacebook_deleteSession, (jobject)facebook);
    removeKnownObejct((jobject)facebook);
    env->DeleteGlobalRef((jobject)facebook);
}

int rooFacebook_isSessionValid_platform(rooFacebook_Session * facebook)
{
	s3eDebugOutputString("rooFacebook_isSessionValid_platform");
    JNIEnv* env = s3eEdkJNIGetEnv();
    return (int)env->CallIntMethod(g_Obj, g_rooFacebook_isSessionValid, (jobject)facebook);
}

rooFacebook_Dialog * rooFacebook_dialog_platform(rooFacebook_Session * facebook, const char * action, rooFacebook_CallbackSpecific callback, void * userData)
{
	s3eDebugOutputString("rooFacebook_dialog_platform");
    JNIEnv* env = s3eEdkJNIGetEnv();
    jstring action_jstr = env->NewStringUTF(action);
    jobject ret = env->CallObjectMethod(g_Obj, g_rooFacebook_dialog, (jobject)facebook, action_jstr);
    ret = env->NewGlobalRef(ret);
    addKnownObject(ret);



    s3eEdkCallbacksRegisterSpecific (S3E_EXT_ROOFACEBOOK2_HASH
                                     , e_rooFacebook_MAX
                                     , e_rooFacebook_dialog
                                     , callback
                                     , userData
                                     , S3E_FALSE
                                     , ret);


    return (rooFacebook_Dialog*)ret;
}

rooFacebook_Dialog * rooFacebook_dialogAndParams_platform(rooFacebook_Session * facebook, const char * action, const char * params, rooFacebook_CallbackSpecific callback, void * userData)
{
	s3eDebugOutputString("rooFacebook_dialogAndParams_platform");
    JNIEnv* env = s3eEdkJNIGetEnv();
    jstring action_jstr = env->NewStringUTF(action);
    jstring params_jstr = env->NewStringUTF(params);
    jobject ret = env->CallObjectMethod(g_Obj, g_rooFacebook_dialogAndParams, (jobject)facebook, action_jstr, params_jstr);
    ret = env->NewGlobalRef(ret);
    addKnownObject(ret);



    s3eEdkCallbacksRegisterSpecific (S3E_EXT_ROOFACEBOOK2_HASH
                                     , e_rooFacebook_MAX
                                     , e_rooFacebook_dialog
                                     , callback
                                     , userData
                                     , S3E_FALSE
                                     , ret);


    return (rooFacebook_Dialog*)ret;
}

void rooFacebook_deleteDialog_platform(rooFacebook_Dialog * dialog)
{
	s3eDebugOutputString("rooFacebook_deleteDialog_platform");
    JNIEnv* env = s3eEdkJNIGetEnv();
    env->CallVoidMethod(g_Obj, g_rooFacebook_deleteDialog, (jobject)dialog);
    removeKnownObejct((jobject)dialog);
    env->DeleteGlobalRef((jobject)dialog);
}

rooFacebook_Request * rooFacebook_requestWithParams_platform(rooFacebook_Session * facebook, const char * params, rooFacebook_CallbackSpecific callback, void * userData)
{
	s3eDebugOutputString("rooFacebook_requestWithParams_platform");
    JNIEnv* env = s3eEdkJNIGetEnv();
    jstring params_jstr = env->NewStringUTF(params);
    jobject ret = env->CallObjectMethod(g_Obj, g_rooFacebook_requestWithParams, (jobject)facebook, params_jstr);
    ret = env->NewGlobalRef(ret);
    addKnownObject(ret);



    s3eEdkCallbacksRegisterSpecific (S3E_EXT_ROOFACEBOOK2_HASH
                                     , e_rooFacebook_MAX
                                     , e_rooFacebook_request
                                     , callback
                                     , userData
                                     , S3E_FALSE
                                     , ret);


    return (rooFacebook_Request*)ret;
}

rooFacebook_Request * rooFacebook_requestWithMethodName_platform(rooFacebook_Session * facebook, const char * methodName, const char * params, const char * httpMethod, rooFacebook_CallbackSpecific callback, void * userData)
{
	s3eDebugOutputString("rooFacebook_requestWithMethodName_platform");
    JNIEnv* env = s3eEdkJNIGetEnv();
    jstring methodName_jstr = env->NewStringUTF(methodName);
    jstring params_jstr = env->NewStringUTF(params);
    jstring httpMethod_jstr = env->NewStringUTF(httpMethod);
    jobject ret = env->CallObjectMethod(g_Obj, g_rooFacebook_requestWithMethodName, (jobject)facebook, methodName_jstr, params_jstr, httpMethod_jstr);
    ret = env->NewGlobalRef(ret);
    addKnownObject(ret);



    s3eEdkCallbacksRegisterSpecific (S3E_EXT_ROOFACEBOOK2_HASH
                                     , e_rooFacebook_MAX
                                     , e_rooFacebook_request
                                     , callback
                                     , userData
                                     , S3E_FALSE
                                     , ret);


    return (rooFacebook_Request*)ret;
}

rooFacebook_Request * rooFacebook_requestWithGraphPath_platform(rooFacebook_Session * facebook, const char * graphPath, rooFacebook_CallbackSpecific callback, void * userData)
{
	s3eDebugOutputString("rooFacebook_requestWithGraphPath_platform");
    JNIEnv* env = s3eEdkJNIGetEnv();
    jstring graphPath_jstr = env->NewStringUTF(graphPath);
    jobject ret = env->CallObjectMethod(g_Obj, g_rooFacebook_requestWithGraphPath, (jobject)facebook, graphPath_jstr);
    ret = env->NewGlobalRef(ret);
    addKnownObject(ret);



    s3eEdkCallbacksRegisterSpecific (S3E_EXT_ROOFACEBOOK2_HASH
                                     , e_rooFacebook_MAX
                                     , e_rooFacebook_request
                                     , callback
                                     , userData
                                     , S3E_FALSE
                                     , ret);


    return (rooFacebook_Request*)ret;
}

rooFacebook_Request * rooFacebook_requestWithGraphPathAndParams_platform(rooFacebook_Session * facebook, const char * graphPath, const char * params, rooFacebook_CallbackSpecific callback, void * userData)
{
	s3eDebugOutputString("rooFacebook_requestWithGraphPathAndParams_platform");
    JNIEnv* env = s3eEdkJNIGetEnv();
    jstring graphPath_jstr = env->NewStringUTF(graphPath);
    jstring params_jstr = env->NewStringUTF(params);
    jobject ret = env->CallObjectMethod(g_Obj, g_rooFacebook_requestWithGraphPathAndParams, (jobject)facebook, graphPath_jstr, params_jstr);
    ret = env->NewGlobalRef(ret);
    addKnownObject(ret);



    s3eEdkCallbacksRegisterSpecific (S3E_EXT_ROOFACEBOOK2_HASH
                                     , e_rooFacebook_MAX
                                     , e_rooFacebook_request
                                     , callback
                                     , userData
                                     , S3E_FALSE
                                     , ret);


    return (rooFacebook_Request*)ret;
}

rooFacebook_Request * rooFacebook_requestWithGraphPathAndParamsAndHttpMethod_platform(rooFacebook_Session * facebook, const char * graphPath, const char * params, const char * httpMethod, rooFacebook_CallbackSpecific callback, void * userData)
{
	s3eDebugOutputString("rooFacebook_requestWithGraphPathAndParamsAndHttpMethod_platform");
    JNIEnv* env = s3eEdkJNIGetEnv();
    jstring graphPath_jstr = env->NewStringUTF(graphPath);
    jstring params_jstr = env->NewStringUTF(params);
    jstring httpMethod_jstr = env->NewStringUTF(httpMethod);
    jobject ret = env->CallObjectMethod(g_Obj, g_rooFacebook_requestWithGraphPathAndParamsAndHttpMethod, (jobject)facebook, graphPath_jstr, params_jstr, httpMethod_jstr);
    ret = env->NewGlobalRef(ret);
    addKnownObject(ret);



    s3eEdkCallbacksRegisterSpecific (S3E_EXT_ROOFACEBOOK2_HASH
                                     , e_rooFacebook_MAX
                                     , e_rooFacebook_request
                                     , callback
                                     , userData
                                     , S3E_FALSE
                                     , ret);


    return (rooFacebook_Request*)ret;
}

void rooFacebook_deleteRequest_platform(rooFacebook_Request * request)
{
	s3eDebugOutputString("rooFacebook_deleteRequest_platform");
    JNIEnv* env = s3eEdkJNIGetEnv();
    env->CallVoidMethod(g_Obj, g_rooFacebook_deleteRequest, (jobject)request);
    removeKnownObejct((jobject)request);
    env->DeleteGlobalRef((jobject)request);
}
