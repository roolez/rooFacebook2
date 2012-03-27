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
 * iphone-specific implementation of the rooFacebook2 extension.
 * Add any platform-specific functionality here.
 */
/*
 * NOTE: This file was originally written by the extension builder, but will not
 * be overwritten (unless --force is specified) and is intended to be modified.
 */
#include "rooFacebook2_internal.h"
#import "FBConnect.h"
#import "rooFacebook2.h"
#include "s3eDebug.h"
#include "s3eEdk.h"
#include "s3eEdk_iphone.h"

#include "JSON.h"

@class FBSessionDelegateImpl;
@class FBDialogDelegateImpl;
@class FBRequestDelegateImpl;



enum rooFacebook_Callback{
    e_rooFacebook_session,
    e_rooFacebook_dialog,
    e_rooFacebook_request,
    e_rooFacebook_MAX
};



struct rooFacebook_Session{
    FBSessionDelegateImpl * delegate;
    Facebook *facebook;
};
struct rooFacebook_Dialog{
    FBDialogDelegateImpl * delegate;
    void * userData;
    rooFacebook_CallbackSpecific callback;
};
struct rooFacebook_Request{
    FBRequestDelegateImpl * delegate;
};


//-------------------------------------------------------
// delegates
//-------------------------------------------------------


@interface FBSessionDelegateImpl : NSObject <FBSessionDelegate>
{
@public
    rooFacebook_Session * m_external;
    Facebook *facebook;
@private

}

@property (nonatomic, retain) Facebook *facebook;

-(id) init;

-(id) initWithExternal:(rooFacebook_Session*) external;

-(id) initWithSession:(Facebook *)session appId:(NSString *)appId;
-(void) logout;
-(void) callCallback:(void*) systemData size:(int) size;
-(void) handleOpenURL:(NSURL *)URL;


- (void)fbDidLogin;
- (void)fbDidNotLogin:(BOOL)cancelled;
- (void)fbDidLogout;

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

- (void)fbSessionInvalidated;

@end

//-------------------------------------------------------
@interface FBDialogDelegateImpl : NSObject <FBDialogDelegate>
{
@public
    rooFacebook_Dialog * m_external;
@private

}

-(id) initWithExternalDialog:(rooFacebook_Dialog*) external;


-(void) callCallback:(void*) systemData size:(int) size;


/**
 * Called when the dialog succeeds and is about to be dismissed.
 */
- (void)dialogDidComplete:(FBDialog *)dialog;

/**
 * Called when the dialog succeeds with a returning url.
 */
- (void)dialogCompleteWithUrl:(NSURL *)url;

/**
 * Called when the dialog get canceled by the user.
 */
- (void)dialogDidNotCompleteWithUrl:(NSURL *)url;

/**
 * Called when the dialog is cancelled and is about to be dismissed.
 */
- (void)dialogDidNotComplete:(FBDialog *)dialog;

/**
 * Called when dialog failed to load due to an error.
 */
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error;

/**
 * Asks if a link touched by a user should be opened in an external browser.
 *
 * If a user touches a link, the default behavior is to open the link in the Safari browser,
 * which will cause your app to quit.  You may want to prevent this from happening, open the link
 * in your own internal browser, or perhaps warn the user that they are about to leave your app.
 * If so, implement this method on your delegate and return NO.  If you warn the user, you
 * should hold onto the URL and once you have received their acknowledgement open the URL yourself
 * using [[UIApplication sharedApplication] openURL:].
 */
- (BOOL)dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL *)url;


@end
//-------------------------------------------------------
@interface FBRequestDelegateImpl : NSObject <FBRequestDelegate>
{
@public
    rooFacebook_Request * m_external;
@private
}

-(id) initWithExternalRequest:(rooFacebook_Request*) external;


-(void) callCallback:(void*) systemData size:(int) size;


/**
 * Called just before the request is sent to the server.
 */
- (void)requestLoading:(FBRequest *)request;

/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response;

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error;

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)request:(FBRequest *)request didLoad:(id)result;

/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data;
@end
//-------------------------------------------------------
//-------------------------------------------------------
//-------------------------------------------------------



//-------------------------------------------------------
//  implementation
//-------------------------------------------------------



@implementation FBSessionDelegateImpl

//@synthesize session = m_session;
//@synthesize loggedIn = m_loggedIn;

@synthesize facebook;

-(id) init
{
    s3eDebugOutputString("init");
    if (!(self = [super init]))
        return nil;
    return self;
}

-(id) initWithExternal:(rooFacebook_Session*) external
{
    s3eDebugOutputString("initWithExternal");
    if (!(self = [super init]))
        return nil;
    m_external = external;
    return self;
}

-(id) initWithSession:(Facebook *)session appId:(NSString *)appId
{

}

- (void)dealloc
{

    s3eDebugOutputString("dealloc");

    [super dealloc];
}

-(void) logout
{
    s3eDebugOutputString("logout");
    [m_external->facebook logout:self];
}

-(void) callCallback:(void *)systemData size:(int) size
{
    char * buf = (char*)malloc(size + 1);
    memcpy(buf, systemData, size);
    buf[size] = 0;

    s3eEdkCallbacksEnqueue(S3E_EXT_ROOFACEBOOK2_HASH
                           , e_rooFacebook_session
                           //                           , systemData
                           //                           , size
                           , buf
                           , size + 1
                           , m_external
                           , S3E_FALSE
                           );
    free(buf);
}

- (void)handleOpenURL:(NSURL *)URL;
{
    s3eDebugOutputString("handleOpenURL");
    BOOL handled = [m_external->facebook handleOpenURL:URL];
}

- (void)fbDidLogin
{



    s3eDebugOutputString("fbDidLogin");
    s3eDebugOutputString([[m_external->facebook accessToken] UTF8String]);
    s3eDebugOutputString([[[m_external->facebook expirationDate] description] UTF8String]);



    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[m_external->facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[m_external->facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];



    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"fbDidLogin", @"rooPlatMethod",
                          @"ok", @"rooStatus",
                          nil ];

    NSString * s = [dic JSONRepresentation];
    const char * data = [s UTF8String];
    int size = strlen(data);

    [self callCallback:(void*)data size: size];

}

- (void)fbDidNotLogin:(BOOL)cancelled;
{
    s3eDebugOutputString("fbDidNotLogin");


    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"fbDidNotLogin", @"rooPlatMethod",
                          @"error", @"rooStatus",
                          cancelled ? @"true" : @"false", @"cancelled",
                          nil ];

    NSString * s = [dic JSONRepresentation];
    const char * data = [s UTF8String];
    int size = strlen(data);

    [self callCallback:(void*)data size: size];


}

- (void)fbDidLogout
{
    s3eDebugOutputString("fbDidLogout");
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    s3eDebugOutputString("application handleOpenURL");
    return [facebook handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    s3eDebugOutputString("application openURL");
    return [facebook handleOpenURL:url];
}
- (void)fbSessionInvalidated{
    s3eDebugOutputString("fbSessionInvalidated");

    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                          @"fbSessionInvalidated", @"rooPlatMethod",
                          @"error", @"rooStatus",
                          nil ];

    NSString * s = [dic JSONRepresentation];
    const char * data = [s UTF8String];
    int size = strlen(data);

    [self callCallback:(void*)data size: size];
}

@end

//----------------------------------------------------------------------------

@implementation FBDialogDelegateImpl

-(id) initWithExternalDialog:(rooFacebook_Dialog*) external
{
    m_external = external;


    return self;
}


-(void) callCallback:(void *)systemData size:(int) size
{
    char * buf = (char*)malloc(size + 1);
    memcpy(buf, systemData, size);
    buf[size] = 0;

    s3eEdkCallbacksEnqueue(S3E_EXT_ROOFACEBOOK2_HASH
                           , e_rooFacebook_dialog
                           //                           , systemData
                           //                           , size
                           , buf
                           , size + 1
                           , m_external
                           , S3E_FALSE
                           );
    free(buf);
}



- (void)dialogDidComplete:(FBDialog *)dialog{
    s3eDebugOutputString("dialogDidComplete");
    if(m_external->callback){
        //m_external->callback(0, "{ \"rooPlatMethod\": \"dialogDidComplete\" }", m_external->userData);

        const char * data = "{ \"rooPlatMethod\": \"dialogDidComplete\", \"rooStatus\": \"ok\" }";
        int size = strlen(data);
        
        [self callCallback:(void*)data size: size];
        
    }
}


- (void)dialogCompleteWithUrl:(NSURL *)url{
    s3eDebugOutputString("dialogCompleteWithUrl");
    if(m_external){
        s3eDebugOutputString("m_external");
        if(m_external->callback){
            s3eDebugOutputString("callback");
            //m_external->callback(0, "{ \"rooPlatMethod\": \"dialogCompleteWithUrl\" }", m_external->userData);
            
            NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"dialogCompleteWithUrl", @"rooPlatMethod",
                                  @"ok", @"rooStatus",
                                  [url absoluteString], @"url",
                                  nil ];
            
            NSString * s = [dic JSONRepresentation];
            //const char * data = "{ \"rooPlatMethod\": \"dialogCompleteWithUrl\" }";
            const char * data = [s UTF8String];
            int size = strlen(data);
            
            [self callCallback:(void*)data size: size];
            
            
        }
    }
}


- (void)dialogDidNotCompleteWithUrl:(NSURL *)url{
    s3eDebugOutputString("dialogDidNotCompleteWithUrl");
    if(m_external){
        s3eDebugOutputString("m_external");
        if(m_external->callback){
            s3eDebugOutputString("callback");
            //m_external->callback(0, "{ \"rooPlatMethod\": \"dialogCompleteWithUrl\" }", m_external->userData);
            
            NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"dialogDidNotCompleteWithUrl", @"rooPlatMethod",
                                  @"error", @"rooStatus",
                                  [url absoluteString], @"url",
                                  nil ];
            
            NSString * s = [dic JSONRepresentation];
            //const char * data = "{ \"rooPlatMethod\": \"dialogCompleteWithUrl\" }";
            const char * data = [s UTF8String];
            int size = strlen(data);
            
            [self callCallback:(void*)data size: size];

            
        }
    }
}


- (void)dialogDidNotComplete:(FBDialog *)dialog{
    s3eDebugOutputString("dialogDidNotComplete");
    if(m_external->callback){
        //m_external->callback(0, "{ \"rooPlatMethod\": \"dialogDidComplete\" }", m_external->userData);

        const char * data = "{ \"rooPlatMethod\": \"dialogDidNotComplete\", \"rooStatus\": \"error\" }";
        int size = strlen(data);
        
        [self callCallback:(void*)data size: size];
        
    }
}


- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error{
    s3eDebugOutputString("dialog didFailWithError");
    if(m_external){
        s3eDebugOutputString("m_external");
        if(m_external->callback){
            s3eDebugOutputString("callback");
            //m_external->callback(0, "{ \"rooPlatMethod\": \"dialogCompleteWithUrl\" }", m_external->userData);

            NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"didFailWithError", @"rooPlatMethod",
                                  @"error", @"rooStatus",
                                  @"lol", @"rooHehe",
                                  //                              [error code], @"code",
                                  [error domain], @"domain",
                                  //                              [error userInfo], @"userInfo",
                                  [error localizedDescription], @"localizedDescription",
                                  //                              [error localizedRecoveryOptions], @"localizedRecoveryOptions",
                                  //                              [error localizedRecoverySuggestion], @"localizedRecoverySuggestion",
                                  [error localizedFailureReason], @"localizedFailureReason",
                                  nil ];




            NSString * s = [dic JSONRepresentation];
            //const char * data = "{ \"rooPlatMethod\": \"dialogCompleteWithUrl\" }";
            const char * data = [s UTF8String];
            int size = strlen(data);
            
            [self callCallback:(void*)data size: size];
            
            
        }
    }
}


- (BOOL)dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL *)url{
    s3eDebugOutputString("dialog shouldOpenURLInExternalBrowser");
    if(m_external){
        s3eDebugOutputString("m_external");
        if(m_external->callback){
            s3eDebugOutputString("callback");
            //m_external->callback(0, "{ \"rooPlatMethod\": \"dialogCompleteWithUrl\" }", m_external->userData);
            
            NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"shouldOpenURLInExternalBrowser", @"rooPlatMethod",
                                  @"ok", @"rooStatus",
                                  [url absoluteString], @"url",
                                  nil ];

            NSString * s = [dic JSONRepresentation];
            //const char * data = "{ \"rooPlatMethod\": \"dialogCompleteWithUrl\" }";
            const char * data = [s UTF8String];
            int size = strlen(data);

            //[self callCallback:(void*)data size: size];


        }
    }
    return true;
}

@end



//----------------------------------------------------------------------------

@implementation FBRequestDelegateImpl


-(id) initWithExternalRequest:(rooFacebook_Request*) external{
    m_external = external;
    
    
    return self;
}


-(void) callCallback:(void*) systemData size:(int) size{
    char * buf = (char*)malloc(size + 1);
    memcpy(buf, systemData, size);
    buf[size] = 0;
    s3eEdkCallbacksEnqueue(S3E_EXT_ROOFACEBOOK2_HASH
                           , e_rooFacebook_request
//                           , systemData
//                           , size
                           , buf
                           , size + 1
                           , m_external
                           , S3E_FALSE
                           );
    free(buf);
}


/**
 * Called just before the request is sent to the server.
 */
- (void)requestLoading:(FBRequest *)request{
    s3eDebugOutputString("rooFB requestLoading");
    const char * data = "{ \"rooPlatMethod\": \"requestLoading\", \"rooStatus\": \"none\" }";
    int size = strlen(data);
    [self callCallback:(void*)data size: size];
}

/**
 * Called when the server responds and begins to send back data.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response{
    s3eDebugOutputString("rooFB request didReceiveResponse");
    const char * data = "{ \"rooPlatMethod\": \"request didReceiveResponse\", \"rooStatus\": \"none\" }";
    int size = strlen(data);
    [self callCallback:(void*)data size: size];
}

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error{
    s3eDebugOutputString("rooFB request didFailWithError");
    if(m_external){
        s3eDebugOutputString("m_external");
        s3eDebugOutputString("callback");
        //m_external->callback(0, "{ \"rooPlatMethod\": \"dialogCompleteWithUrl\" }", m_external->userData);

        //NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:

        /*

        NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"didFailWithError", @"rooPlatMethod",
                              @"error", @"rooStatus",
                              [error code], @"code",
                              [error domain], @"domain",
                              [error userInfo], @"userInfo",
                              [error localizedDescription], @"localizedDescription",
                              [error localizedRecoveryOptions], @"localizedRecoveryOptions",
                              [error localizedRecoverySuggestion], @"localizedRecoverySuggestion",
                              [error localizedFailureReason], @"localizedFailureReason",
                              nil ];

        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"5", @"social_karma",
                              @"1", @"badge_of_awesomeness",
                              nil];

         */



        NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"didFailWithError", @"rooPlatMethod",
                              @"error", @"rooStatus",
                              @"lol", @"rooHehe",
//                              [error code], @"code",
                              [error domain], @"domain",
//                              [error userInfo], @"userInfo",
                              [error localizedDescription], @"localizedDescription",
//                              [error localizedRecoveryOptions], @"localizedRecoveryOptions",
//                              [error localizedRecoverySuggestion], @"localizedRecoverySuggestion",
                              [error localizedFailureReason], @"localizedFailureReason",
                              nil ];



        s3eDebugOutputString("dic created");

        SBJSON *jsonWriter = [[SBJSON new] autorelease];
        //NSString * s = [dic JSONRepresentation];

        s3eDebugOutputString("jsonwriter");
       NSString *s = [jsonWriter stringWithObject:dic];
        s3eDebugOutputString("fot string");

        //const char * data = "{ \"rooPlatMethod\": \"dialogCompleteWithUrl\" }";
        const char * data = [s UTF8String];
        
        s3eDebugOutputString(data);
        
        int size = strlen(data);// + 1;

        s3eDebugOutputString("call callback");
        [self callCallback:(void*)data size: size];


    }
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array, a string, or a number,
 * depending on thee format of the API response.
 */
- (void)request:(FBRequest *)request didLoad:(id)result{

}

/**
 * Called when a request returns a response.
 *
 * The result object is the raw response from the server of type NSData
 */
- (void)request:(FBRequest *)request didLoadRawResponse:(NSData *)data{
    s3eDebugOutputString("request didLoadRawResponse");
    const void * b = [data bytes];
    int size = [data length];
    const char * text = (const char *)b;
    s3eDebugOutputString(text);
    char buf[100];
    snprintf(buf, sizeof(buf), "length: %d", size);
    s3eDebugOutputString(buf);
    [self callCallback:(void*)b size: size];
}
@end


//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------










const char * g_rooFacebook_str;





s3eResult rooFacebook2Init_platform()
{
    s3eDebugOutputString("rooFacebook2Init_platform");
    // Add any platform-specific initialisation code here
    g_rooFacebook_str = nil;
    return S3E_RESULT_SUCCESS;
}

void rooFacebook2Terminate_platform()
{
    s3eDebugOutputString("rooFacebook2Terminate_platform");
    if(g_rooFacebook_str)
        free((void*)g_rooFacebook_str);
    // Add any platform-specific termination code here
}

int32 rooFacebook_handleOpenURL(void* systemData, void* userData)
{
    s3eDebugOutputString("rooFacebook_handleOpenURL");

    NSURL * url = (NSURL *) systemData;
    rooFacebook_Session * external = (rooFacebook_Session *) userData;

    [external->delegate handleOpenURL:url];

    return 0;
}


rooFacebook_Session * rooFacebook_init_platform(const char* appId, rooFacebook_CallbackSpecific callback, void * userData)
{
    s3eDebugOutputString("rooFacebook_init_platform");
    NSString *nsAppId = [NSString stringWithUTF8String:appId];
    rooFacebook_Session * external = new rooFacebook_Session;
    external->delegate = [[FBSessionDelegateImpl alloc] initWithExternal:external];
    external->delegate->facebook = external->facebook = [[Facebook alloc] initWithAppId:nsAppId andDelegate:external->delegate];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    s3eDebugOutputString("checking defaults X)");
    if ([defaults objectForKey:@"FBAccessTokenKey"]
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        s3eDebugOutputString("defaults exist");
        external->facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        external->facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        s3eDebugOutputString([external->facebook.accessToken UTF8String]);
        s3eDebugOutputString([[external->facebook.expirationDate description] UTF8String]);
    }else{
        s3eDebugOutputString("no defaults");
    }


    s3eEdkCallbacksRegisterSpecific (S3E_EXT_ROOFACEBOOK2_HASH
                                     , e_rooFacebook_MAX
                                     , e_rooFacebook_session
                                     , callback
                                     , userData
                                     , S3E_FALSE
                                     , external);




    s3eEdkCallbacksRegisterInternal(
                                    S3E_EDK_INTERNAL,
                                    S3E_EDK_CALLBACK_MAX,
                                    S3E_EDK_IPHONE_HANDLEOPENURL,
                                    rooFacebook_handleOpenURL,
                                    external,
                                    false
                                    );
    s3eDebugOutputString("END rooFacebook_init_platform");

    return external;
}

rooFacebook_Session * rooFacebook_initWithUrlSchemeSuffix_platform(const char* appId, const char * urlSchemeSuffix, rooFacebook_CallbackSpecific callback, void * userData)
{
}

void rooFacebook_authorize_platform(rooFacebook_Session * facebook, const char * permissions)
{
    s3eDebugOutputString("rooFacebook_authorize_platform");
    if(facebook){
        s3eDebugOutputString("facebook exists");
    }


    if(facebook->facebook){
        s3eDebugOutputString("facebook->facebook exists");
    }else{
        s3eDebugOutputString("facebook->facebook nil");
    }

    if(facebook->facebook.accessToken != nil){
        s3eDebugOutputString("accessToken != nil");
    }else{
        s3eDebugOutputString("accessToken == nil");
    }
    if(facebook->facebook.expirationDate != nil){
        s3eDebugOutputString("expirationDate != nil");
    }else{
        s3eDebugOutputString("expirationDate == nil");
    }
    if(NSOrderedDescending == [facebook->facebook.expirationDate compare:[NSDate date]]){
        s3eDebugOutputString("NSOrderedDescending ==");
    }else{
        s3eDebugOutputString("NSOrderedDescending !=");
    }



    //if (![facebook->facebook isSessionValid])
    {
        s3eDebugOutputString("isSessionValid  !!!");
        //[facebook->facebook authorize:nil delegate:facebook->delegate];
        //[facebook->facebook authorize:nil delegate:facebook->delegate];

        s3eDebugOutputString(permissions);
        //SBJSON * parser = [[SBJSON new] autorelease];
        SBJSON * parser = [SBJSON new];
        //NSStream * json = [[NSString stringWithUTF8String:permissions] autorelease];
        NSStream * json = [NSString stringWithUTF8String:permissions];
        id result = [parser objectWithString:json error:nil];

        NSArray * arr = nil;

        if([result isKindOfClass:[NSArray class]]){
            s3eDebugOutputString("is NSArray");
            arr = result;
        }else{
            s3eDebugOutputString("NOT NS Array");
        }



        char buf[100];
        snprintf(buf, sizeof(buf), "size: %d", [arr count]);
        s3eDebugOutputString(buf);


        for(NSString * s in arr){
            s3eDebugOutputString([s UTF8String]);
        }

        [facebook->facebook authorize:arr];

        s3eDebugOutputString("authorized");
    }
    //    else{s3eDebugOutputString("NOT isSessionValid");}

    s3eDebugOutputString("end");
    /*


     NSArray *permissions = [[NSArray alloc] initWithObjects:
     @"user_likes",
     @"read_stream",
     nil];
     [facebook authorize:permissions];
     [permissions release];

     */
}

const char * rooFacebook_getAccessToken_platform(rooFacebook_Session * facebook)
{
    if(facebook->facebook.accessToken == nil)
        return nil;
    if([facebook->facebook.accessToken length] == 0)
        return nil;
    const char * s = [facebook->facebook.accessToken UTF8String];
    if(g_rooFacebook_str)
        free((void*)g_rooFacebook_str);
    return g_rooFacebook_str = strdup(s);
}

int rooFacebook_getAccessExpires_platform(rooFacebook_Session * facebook)
{
    s3eDebugOutputString("rooFacebook_getAccessExpires_platform");
    s3eDebugOutputString([[facebook->facebook.expirationDate description] UTF8String]);
    NSDate * date = facebook->facebook.expirationDate;
    int ae = [date timeIntervalSince1970];
    int64 mili = 1000L * ae;
    char buf[100];
    snprintf(buf, sizeof(buf), "ae: %lld %d", mili, ae);
    s3eDebugOutputString(buf);
    return ae;
}

void rooFacebook_setAccessToken_platform(rooFacebook_Session * facebook, const char * access_token)
{
    //NSString * nsaccess_token = [[NSString alloc] initWithUTF8String:access_token];
    NSString * nsaccess_token = [NSString stringWithUTF8String:access_token];
    //if(facebook->facebook.accessToken != nil)
    //    [facebook->facebook.accessToken release];
    facebook->facebook.accessToken = nsaccess_token;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook->facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults synchronize];

}

void rooFacebook_setAccessExpires_platform(rooFacebook_Session * facebook, int access_expires)
{
    s3eDebugOutputString("rooFacebook_setAccessExpires_platform");
    int ae = access_expires / 1000;
    char buf[100];
    snprintf(buf, sizeof(buf), "ae: %lld %d", access_expires, ae);
    s3eDebugOutputString(buf);


    NSDate * date = [NSDate dateWithTimeIntervalSince1970:access_expires];
    //if(facebook->facebook.expirationDate != nil)
    //    [facebook->facebook.expirationDate release];
    facebook->facebook.expirationDate = date;

    s3eDebugOutputString([[facebook->facebook.expirationDate description] UTF8String]);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook->facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];

}

void rooFacebook_extendAccessToken_platform(rooFacebook_Session * facebook)
{
    [facebook->facebook extendAccessToken];
}

void rooFacebook_extendAccessTokenIfNeeded_platform(rooFacebook_Session * facebook)
{
    [facebook->facebook extendAccessTokenIfNeeded];
}

void rooFacebook_logout_platform(rooFacebook_Session * facebook)
{
    [facebook->facebook logout];




    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];

}

void rooFacebook_deleteSession_platform(rooFacebook_Session * facebook)
{
    [facebook->facebook release];
    delete facebook;
}

int rooFacebook_isSessionValid_platform(rooFacebook_Session * facebook)
{
    return [facebook->facebook isSessionValid];
}

rooFacebook_Dialog * rooFacebook_dialog_platform(rooFacebook_Session * facebook, const char * action, rooFacebook_CallbackSpecific callback, void * userData)
{
    rooFacebook_Dialog * dialog = new rooFacebook_Dialog;
    dialog->userData = userData;
    dialog->callback = callback;
    dialog->delegate = [[FBDialogDelegateImpl alloc] initWithExternalDialog:dialog];

    s3eEdkCallbacksRegisterSpecific (S3E_EXT_ROOFACEBOOK2_HASH
                                     , e_rooFacebook_MAX
                                     , e_rooFacebook_dialog
                                     , callback
                                     , userData
                                     , S3E_FALSE
                                     , dialog);


    NSString * nsaction = [NSString stringWithUTF8String:action];
    [facebook->facebook dialog:nsaction andDelegate:dialog->delegate];
    return dialog;
}

rooFacebook_Dialog * rooFacebook_dialogAndParams_platform(rooFacebook_Session * facebook, const char * action, const char * params, rooFacebook_CallbackSpecific callback, void * userData)
{

    s3eDebugOutputString("rooFacebook_dialogAndParams_platform");

    SBJSON * parser = [SBJSON new];
    //NSStream * json = [[NSString stringWithUTF8String:permissions] autorelease];
    s3eDebugOutputString(params);
    NSStream * json = [NSString stringWithUTF8String:params];
    id result = [parser objectWithString:json];

    if(result == nil){
        s3eDebugOutputString("is nil");
    }


    NSArray * arr = nil;

    if([result isKindOfClass:[NSArray class]]){
        s3eDebugOutputString("is NSArray");
        arr = result;
    }else{
        s3eDebugOutputString("NOT NS Array");
    }


    NSMutableDictionary * dic = nil;

    if([result isKindOfClass:[NSMutableDictionary class]]){
        s3eDebugOutputString("is NSMutableDictionary");
        dic = result;
    }else{
        s3eDebugOutputString("NOT NS dic");
    }



    char buf[100];
    snprintf(buf, sizeof(buf), "size: %d", [dic count]);
    s3eDebugOutputString(buf);


    for(NSString * s in dic){
        s3eDebugOutputString([s UTF8String]);
        s3eDebugOutputString([[dic objectForKey:s] UTF8String]);
    }
    //NSMutableDictionary * mdic = [[NSMutableDictionary alloc] initWithDictionary:dic];

    s3eDebugOutputString("new rooFacebook_Dialog;");


    rooFacebook_Dialog * dialog = new rooFacebook_Dialog;
    dialog->userData = userData;
    dialog->callback = callback;
    dialog->delegate = [[FBDialogDelegateImpl alloc] initWithExternalDialog:dialog];


    s3eDebugOutputString("send message");

    s3eEdkCallbacksRegisterSpecific (S3E_EXT_ROOFACEBOOK2_HASH
                                     , e_rooFacebook_MAX
                                     , e_rooFacebook_dialog
                                     , callback
                                     , userData
                                     , S3E_FALSE
                                     , dialog);

    s3eDebugOutputString("show dialog");

    NSString * nsaction = [NSString stringWithUTF8String:action];
    //[facebook->facebook dialog:nsaction andDelegate:dialog->delegate];
    [facebook->facebook dialog:nsaction andParams:dic andDelegate:dialog->delegate];

    s3eDebugOutputString("END rooFacebook_dialogAndParams_platform");

    return dialog;
}

void rooFacebook_deleteDialog_platform(rooFacebook_Dialog * dialog)
{
    [dialog->delegate release];
    delete dialog;
}

rooFacebook_Request * rooFacebook_requestWithParams_platform(rooFacebook_Session * facebook, const char * params, rooFacebook_CallbackSpecific callback, void * userData)
{
    s3eDebugOutputString("rooFacebook_requestWithParams_platform");
    SBJSON * parser = [SBJSON new];
    NSStream * json = [NSString stringWithUTF8String:params];

    //id result = [parser objectWithString:json error:nil];
    //NSDictionary * dic = nil;
    //if([result isKindOfClass:[NSDictionary class]]){
    //    s3eDebugOutputString("is NSDictionary");
    //    dic = result;
    //}else{
    //    s3eDebugOutputString("NOT NS dic");
    //}
    //NSMutableDictionary * mdic = [NSMutableDictionary initWithDictionary:dic];


    s3eDebugOutputString("begin parsing");
    NSMutableDictionary * mdic = (NSMutableDictionary *)[parser objectWithString:json error:nil];
    s3eDebugOutputString("end parsing");

    rooFacebook_Request * request = new rooFacebook_Request;
    request->delegate = [[FBRequestDelegateImpl alloc] initWithExternalRequest:request];

    s3eEdkCallbacksRegisterSpecific (S3E_EXT_ROOFACEBOOK2_HASH
                                     , e_rooFacebook_MAX
                                     , e_rooFacebook_request
                                     , callback
                                     , userData
                                     , S3E_FALSE
                                     , request);


    [facebook->facebook requestWithParams:mdic andDelegate:request->delegate];
}

rooFacebook_Request * rooFacebook_requestWithMethodName_platform(rooFacebook_Session * facebook, const char * methodName, const char * params, const char * httpMethod, rooFacebook_CallbackSpecific callback, void * userData)
{
    s3eDebugOutputString("rooFacebook_requestWithMethodName_platform");

    SBJSON * parser = [SBJSON new];
    NSStream * json = [NSString stringWithUTF8String:params];
    //id result = [parser objectWithString:json error:nil];
    //NSDictionary * dic = nil;
    //if([result isKindOfClass:[NSDictionary class]]){
    //    s3eDebugOutputString("is NSDictionary");
    //    dic = result;
    //}else{
    //    s3eDebugOutputString("NOT NS dic");
    //}
    //NSMutableDictionary * mdic = [NSMutableDictionary initWithDictionary:dic];

    s3eDebugOutputString("begin parsing");
    NSMutableDictionary * mdic = (NSMutableDictionary *)[parser objectWithString:json error:nil];
    s3eDebugOutputString("end parsing");

    rooFacebook_Request * request = new rooFacebook_Request;
    request->delegate = [[FBRequestDelegateImpl alloc] initWithExternalRequest:request];

    s3eEdkCallbacksRegisterSpecific (S3E_EXT_ROOFACEBOOK2_HASH
                                     , e_rooFacebook_MAX
                                     , e_rooFacebook_request
                                     , callback
                                     , userData
                                     , S3E_FALSE
                                     , request);

    NSString * nsmethodName = [NSString stringWithUTF8String:methodName];
    //NSString * nsparams = [NSString stringWithUTF8String:params];
    NSString * nshttpdMethod = [NSString stringWithUTF8String:httpMethod];

    s3eDebugOutputString("calling method");
    [facebook->facebook requestWithMethodName:nsmethodName andParams:mdic andHttpMethod:nshttpdMethod andDelegate:request->delegate];

}

rooFacebook_Request * rooFacebook_requestWithGraphPath_platform(rooFacebook_Session * facebook, const char * graphPath, rooFacebook_CallbackSpecific callback, void * userData)
{
    rooFacebook_Request * request = new rooFacebook_Request;
    request->delegate = [[FBRequestDelegateImpl alloc] initWithExternalRequest:request];

    s3eEdkCallbacksRegisterSpecific (S3E_EXT_ROOFACEBOOK2_HASH
                                     , e_rooFacebook_MAX
                                     , e_rooFacebook_request
                                     , callback
                                     , userData
                                     , S3E_FALSE
                                     , request);

    NSString * nsgraphPath = [NSString stringWithUTF8String:graphPath];

    [facebook->facebook requestWithGraphPath:nsgraphPath andDelegate:request->delegate];

}

rooFacebook_Request * rooFacebook_requestWithGraphPathAndParams_platform(rooFacebook_Session * facebook, const char * graphPath, const char * params, rooFacebook_CallbackSpecific callback, void * userData)
{

    SBJSON * parser = [SBJSON new];
    NSStream * json = [NSString stringWithUTF8String:params];
    id result = [parser objectWithString:json error:nil];
    NSMutableDictionary * dic = nil;
    if([result isKindOfClass:[NSMutableDictionary class]]){
        s3eDebugOutputString("is NSMutableDictionary");
        dic = result;
    }else{
        s3eDebugOutputString("NOT NS dic");
    }
    //NSMutableDictionary * mdic = [NSMutableDictionary initWithDictionary:dic];

    rooFacebook_Request * request = new rooFacebook_Request;
    request->delegate = [[FBRequestDelegateImpl alloc] initWithExternalRequest:request];

    s3eEdkCallbacksRegisterSpecific (S3E_EXT_ROOFACEBOOK2_HASH
                                     , e_rooFacebook_MAX
                                     , e_rooFacebook_request
                                     , callback
                                     , userData
                                     , S3E_FALSE
                                     , request);

    NSString * nsgraphPath = [NSString stringWithUTF8String:graphPath];

    [facebook->facebook requestWithGraphPath:nsgraphPath andParams:dic andDelegate:request->delegate];
}

rooFacebook_Request * rooFacebook_requestWithGraphPathAndParamsAndHttpMethod_platform(rooFacebook_Session * facebook, const char * graphPath, const char * params, const char * httpMethod, rooFacebook_CallbackSpecific callback, void * userData)
{

    SBJSON * parser = [SBJSON new];
    NSStream * json = [NSString stringWithUTF8String:params];
    id result = [parser objectWithString:json error:nil];
    NSMutableDictionary * dic = nil;
    if([result isKindOfClass:[NSMutableDictionary class]]){
        s3eDebugOutputString("is NSMutableDictionary");
        dic = result;
    }else{
        s3eDebugOutputString("NOT NS dic");
    }
    //NSMutableDictionary * mdic = [[[NSMutableDictionary alloc] initWithDictionary:dic] autorelease];

    rooFacebook_Request * request = new rooFacebook_Request;
    request->delegate = [[FBRequestDelegateImpl alloc] initWithExternalRequest:request];

    s3eEdkCallbacksRegisterSpecific (S3E_EXT_ROOFACEBOOK2_HASH
                                     , e_rooFacebook_MAX
                                     , e_rooFacebook_request
                                     , callback
                                     , userData
                                     , S3E_FALSE
                                     , request);

    NSString * nsgraphPath = [NSString stringWithUTF8String:graphPath];
    NSString * nshttpdMethod = [NSString stringWithUTF8String:httpMethod];

    [facebook->facebook requestWithGraphPath:nsgraphPath andParams:dic andHttpMethod:nshttpdMethod andDelegate:request->delegate];
    //[mdic release];
}

void rooFacebook_deleteRequest_platform(rooFacebook_Request * request)
{
    [request->delegate release];
    delete request;
}
