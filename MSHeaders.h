#import <UIKit/UIKit.h>

@interface TabDocument
-(BOOL)runJavaScriptConfirmPanelWithMessage:(id)msg initiatedByFrameWithURL:(id)url;
-(void)runJavaScriptAlertPanelWithMessage:(id)msg initiatedByFrameWithURL:(id)url;
-(id)webView;
@end

@interface TabDocumentWK2 <UIAlertViewDelegate>
-(id)URLString;
-(BOOL)runJavaScriptConfirmPanelWithMessage:(id)msg initiatedByFrameWithURL:(id)url;
-(void) webView:(id)web runJavaScriptAlertPanelWithMessage:(id)msg initiatedByFrame:(id)frame;
-(void) webView:(id)web runJavaScriptAlertPanelWithMessage:(id)msg initiatedByFrame:(id)frame completionHandler:(void (^)(NSString *param))completionBlock;
-(void)_forceStopLoading;
@end

@interface SafariWebView <UIAlertViewDelegate>
- (void)evaluateJavaScript:(NSString *)js completionHandler:(void (^)(id, NSError *))completion;
@end