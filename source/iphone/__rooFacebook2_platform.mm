/*
 * iphone-specific implementation of the rooFacebook2 extension.
 * Add any platform-specific functionality here.
 */
/*
 * NOTE: This file was originally written by the extension builder, but will not
 * be overwritten (unless --force is specified) and is intended to be modified.
 */
#include "rooFacebook2_internal.h"

s3eResult rooFacebook2Init_platform()
{
    // Add any platform-specific initialisation code here
    return S3E_RESULT_SUCCESS;
}

void rooFacebook2Terminate_platform()
{
    // Add any platform-specific termination code here
}

rooFacebook_Session * rooFacebook_init_platform(const char* appId, rooFacebook_CallbackSpecific callback, void * userData)
{
}

rooFacebook_Session * rooFacebook_initWithUrlSchemeSuffix_platform(const char* appId, const char * urlSchemeSuffix, rooFacebook_CallbackSpecific callback, void * userData)
{
}

void rooFacebook_authorize_platform(rooFacebook_Session * facebook, const char * permissions)
{
}

void rooFacebook_extendAccessTokenIfNeeded_platform(rooFacebook_Session * facebook)
{
}

void rooFacebook_logout_platform(rooFacebook_Session * facebook)
{
}

void rooFacebook_deleteSession_platform(rooFacebook_Session * facebook)
{
}

int rooFacebook_isSessionValid_platform(rooFacebook_Session * facebook)
{
}

rooFacebook_Dialog * rooFacebook_dialog_platform(rooFacebook_Session * facebook, const char * action, rooFacebook_CallbackSpecific callback, void * userData)
{
}

rooFacebook_Dialog * rooFacebook_dialogAndParams_platform(rooFacebook_Session * facebook, const char * action, const char * params, rooFacebook_CallbackSpecific callback, void * userData)
{
}

void rooFacebook_deleteDialog_platform(rooFacebook_Dialog * dialog)
{
}

rooFacebook_Request * rooFacebook_requestWithParams_platform(rooFacebook_Session * facebook, const char * params, rooFacebook_CallbackSpecific callback, void * userData)
{
}

rooFacebook_Request * rooFacebook_requestWithMethodName_platform(rooFacebook_Session * facebook, const char * methodName, const char * params, const char * httpMethod, rooFacebook_CallbackSpecific callback, void * userData)
{
}

rooFacebook_Request * rooFacebook_requestWithGraphPath_platform(rooFacebook_Session * facebook, const char * graphPath, rooFacebook_CallbackSpecific callback, void * userData)
{
}

rooFacebook_Request * rooFacebook_requestWithGraphPathAndParams_platform(rooFacebook_Session * facebook, const char * graphPath, const char * params, rooFacebook_CallbackSpecific callback, void * userData)
{
}

rooFacebook_Request * rooFacebook_requestWithGraphPathAndParamsAndHttpMethod_platform(rooFacebook_Session * facebook, const char * graphPath, const char * params, const char * httpMethod, rooFacebook_CallbackSpecific callback, void * userData)
{
}

void rooFacebook_deleteRequest_platform(rooFacebook_Request * request)
{
}
