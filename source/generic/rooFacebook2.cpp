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
Generic implementation of the rooFacebook2 extension.
This file should perform any platform-indepedentent functionality
(e.g. error checking) before calling platform-dependent implementations.
*/

/*
 * NOTE: This file was originally written by the extension builder, but will not
 * be overwritten (unless --force is specified) and is intended to be modified.
 */


#include "rooFacebook2_internal.h"
s3eResult rooFacebook2Init()
{
    //Add any generic initialisation code here
    return rooFacebook2Init_platform();
}

void rooFacebook2Terminate()
{
    //Add any generic termination code here
    rooFacebook2Terminate_platform();
}

rooFacebook_Session * rooFacebook_init(const char* appId, rooFacebook_CallbackSpecific callback, void * userData)
{
	rooFacebook_init_platform(appId, callback, userData);
}

rooFacebook_Session * rooFacebook_initWithUrlSchemeSuffix(const char* appId, const char * urlSchemeSuffix, rooFacebook_CallbackSpecific callback, void * userData)
{
	rooFacebook_initWithUrlSchemeSuffix_platform(appId, urlSchemeSuffix, callback, userData);
}

void rooFacebook_authorize(rooFacebook_Session * facebook, const char * permissions)
{
	rooFacebook_authorize_platform(facebook, permissions);
}

const char * rooFacebook_getAccessToken(rooFacebook_Session * facebook)
{
	rooFacebook_getAccessToken_platform(facebook);
}

int rooFacebook_getAccessExpires(rooFacebook_Session * facebook)
{
	rooFacebook_getAccessExpires_platform(facebook);
}

void rooFacebook_setAccessToken(rooFacebook_Session * facebook, const char * access_token)
{
	rooFacebook_setAccessToken_platform(facebook, access_token);
}

void rooFacebook_setAccessExpires(rooFacebook_Session * facebook, int access_expires)
{
	rooFacebook_setAccessExpires_platform(facebook, access_expires);
}

void rooFacebook_extendAccessToken(rooFacebook_Session * facebook)
{
	rooFacebook_extendAccessToken_platform(facebook);
}

void rooFacebook_extendAccessTokenIfNeeded(rooFacebook_Session * facebook)
{
	rooFacebook_extendAccessTokenIfNeeded_platform(facebook);
}

void rooFacebook_logout(rooFacebook_Session * facebook)
{
	rooFacebook_logout_platform(facebook);
}

void rooFacebook_deleteSession(rooFacebook_Session * facebook)
{
	rooFacebook_deleteSession_platform(facebook);
}

int rooFacebook_isSessionValid(rooFacebook_Session * facebook)
{
	rooFacebook_isSessionValid_platform(facebook);
}

rooFacebook_Dialog * rooFacebook_dialog(rooFacebook_Session * facebook, const char * action, rooFacebook_CallbackSpecific callback, void * userData)
{
	rooFacebook_dialog_platform(facebook, action, callback, userData);
}

rooFacebook_Dialog * rooFacebook_dialogAndParams(rooFacebook_Session * facebook, const char * action, const char * params, rooFacebook_CallbackSpecific callback, void * userData)
{
	rooFacebook_dialogAndParams_platform(facebook, action, params, callback, userData);
}

void rooFacebook_deleteDialog(rooFacebook_Dialog * dialog)
{
	rooFacebook_deleteDialog_platform(dialog);
}

rooFacebook_Request * rooFacebook_requestWithParams(rooFacebook_Session * facebook, const char * params, rooFacebook_CallbackSpecific callback, void * userData)
{
	rooFacebook_requestWithParams_platform(facebook, params, callback, userData);
}

rooFacebook_Request * rooFacebook_requestWithMethodName(rooFacebook_Session * facebook, const char * methodName, const char * params, const char * httpMethod, rooFacebook_CallbackSpecific callback, void * userData)
{
	rooFacebook_requestWithMethodName_platform(facebook, methodName, params, httpMethod, callback, userData);
}

rooFacebook_Request * rooFacebook_requestWithGraphPath(rooFacebook_Session * facebook, const char * graphPath, rooFacebook_CallbackSpecific callback, void * userData)
{
	rooFacebook_requestWithGraphPath_platform(facebook, graphPath, callback, userData);
}

rooFacebook_Request * rooFacebook_requestWithGraphPathAndParams(rooFacebook_Session * facebook, const char * graphPath, const char * params, rooFacebook_CallbackSpecific callback, void * userData)
{
	rooFacebook_requestWithGraphPathAndParams_platform(facebook, graphPath, params, callback, userData);
}

rooFacebook_Request * rooFacebook_requestWithGraphPathAndParamsAndHttpMethod(rooFacebook_Session * facebook, const char * graphPath, const char * params, const char * httpMethod, rooFacebook_CallbackSpecific callback, void * userData)
{
	rooFacebook_requestWithGraphPathAndParamsAndHttpMethod_platform(facebook, graphPath, params, httpMethod, callback, userData);
}

void rooFacebook_deleteRequest(rooFacebook_Request * request)
{
	rooFacebook_deleteRequest_platform(request);
}
