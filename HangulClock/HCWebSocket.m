/**
 * Project. Hangul Clock Desktop Widget for Mac
 * User: MR.LEE(leeshoon1344@gmail.com)
 * Based on uebersicht
 * License GPLv3
 * Original Copyright (c) 2013 Felix Hageloh.
 */

#import "HCWebSocket.h"

@implementation HCWebSocket {
    NSMutableArray* listeners;
    NSMutableArray* queuedMessages;
    SRWebSocket* ws;
    NSURL* url;
}


+ (id)sharedSocket {
    static HCWebSocket* sharedSocket = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSocket = [[self alloc] init];
    });
    return sharedSocket;
}

- (id)init {

    if (self = [super init]) {
        listeners = [[NSMutableArray alloc] init];
        queuedMessages = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)send:(id)message
{
    if (ws && ws.readyState == SR_OPEN) {
        [ws send:message];
    } else {
        [queuedMessages addObject: message];
    }
}

- (void)listen:(void (^)(id))listener
{
    [listeners addObject:listener];
}

- (void)open:(NSURL*)aUrl
{
    if (ws) {
        return;
    }
    
    url = aUrl;
    ws = [[SRWebSocket alloc]
        initWithURLRequest:[NSURLRequest requestWithURL:url]
    ];
    ws.delegate = self;
    [ws open];
}

- (void)close
{
    if (ws) {
        ws.delegate = nil;
        [ws close];
        ws = nil;
        url = nil;
    }
}

- (void)reopen
{
    [self close];
    if (url) {
        [self open:url];
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    for (id message in queuedMessages) {
        [ws send:message];
    }
    
    [queuedMessages removeAllObjects];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    for (void (^listener)(id) in listeners) {
        listener(message);
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    [webSocket close];
    [self
        performSelector:@selector(reopen)
        withObject:nil
        afterDelay: 0.1
    ];
}

- (void)webSocket:(SRWebSocket *)webSocket
    didCloseWithCode:(NSInteger)code
    reason:(NSString *)reason
    wasClean:(BOOL)wasClean
{

    [self
        performSelector:@selector(reopen)
        withObject:nil
        afterDelay: 0.1
    ];
}

@end
