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
 * Internal header for the rooFacebook2 extension.
 *
 * This file should be used for any common function definitions etc that need to
 * be shared between the platform-dependent and platform-indepdendent parts of
 * this extension.
 */

/*
 * NOTE: This file was originally written by the extension builder, but will not
 * be overwritten (unless --force is specified) and is intended to be modified.
 */


#ifndef ROOFACEBOOK2_INTERNAL_H
#define ROOFACEBOOK2_INTERNAL_H

#include "s3eTypes.h"
#include "rooFacebook2.h"
#include "rooFacebook2_autodefs.h"


/**
 * Initialise the extension.  This is called once then the extension is first
 * accessed by s3eregister.  If this function returns S3E_RESULT_ERROR the
 * extension will be reported as not-existing on the device.
 */
s3eResult rooFacebook2Init();

/**
 * Platform-specific initialisation, implemented on each platform
 */
s3eResult rooFacebook2Init_platform();

/**
 * Terminate the extension.  This is called once on shutdown, but only if the
 * extension was loader and Init() was successful.
 */
void rooFacebook2Terminate();

/**
 * Platform-specific termination, implemented on each platform
 */
void rooFacebook2Terminate_platform();
rooFacebook_Session * rooFacebook_init_platform(const char* appId, rooFacebook_CallbackSpecific callback, void * userData);

rooFacebook_Session * rooFacebook_initWithUrlSchemeSuffix_platform(const char* appId, const char * urlSchemeSuffix, rooFacebook_CallbackSpecific callback, void * userData);

void rooFacebook_authorize_platform(rooFacebook_Session * facebook, const char * permissions);

const char * rooFacebook_getAccessToken_platform(rooFacebook_Session * facebook);

int rooFacebook_getAccessExpires_platform(rooFacebook_Session * facebook);

void rooFacebook_setAccessToken_platform(rooFacebook_Session * facebook, const char * access_token);

void rooFacebook_setAccessExpires_platform(rooFacebook_Session * facebook, int access_expires);

void rooFacebook_extendAccessToken_platform(rooFacebook_Session * facebook);

void rooFacebook_extendAccessTokenIfNeeded_platform(rooFacebook_Session * facebook);

void rooFacebook_logout_platform(rooFacebook_Session * facebook);

void rooFacebook_deleteSession_platform(rooFacebook_Session * facebook);

int rooFacebook_isSessionValid_platform(rooFacebook_Session * facebook);

rooFacebook_Dialog * rooFacebook_dialog_platform(rooFacebook_Session * facebook, const char * action, rooFacebook_CallbackSpecific callback, void * userData);

rooFacebook_Dialog * rooFacebook_dialogAndParams_platform(rooFacebook_Session * facebook, const char * action, const char * params, rooFacebook_CallbackSpecific callback, void * userData);

void rooFacebook_deleteDialog_platform(rooFacebook_Dialog * dialog);

rooFacebook_Request * rooFacebook_requestWithParams_platform(rooFacebook_Session * facebook, const char * params, rooFacebook_CallbackSpecific callback, void * userData);

rooFacebook_Request * rooFacebook_requestWithMethodName_platform(rooFacebook_Session * facebook, const char * methodName, const char * params, const char * httpMethod, rooFacebook_CallbackSpecific callback, void * userData);

rooFacebook_Request * rooFacebook_requestWithGraphPath_platform(rooFacebook_Session * facebook, const char * graphPath, rooFacebook_CallbackSpecific callback, void * userData);

rooFacebook_Request * rooFacebook_requestWithGraphPathAndParams_platform(rooFacebook_Session * facebook, const char * graphPath, const char * params, rooFacebook_CallbackSpecific callback, void * userData);

rooFacebook_Request * rooFacebook_requestWithGraphPathAndParamsAndHttpMethod_platform(rooFacebook_Session * facebook, const char * graphPath, const char * params, const char * httpMethod, rooFacebook_CallbackSpecific callback, void * userData);

void rooFacebook_deleteRequest_platform(rooFacebook_Request * request);


#endif /* !ROOFACEBOOK2_INTERNAL_H */