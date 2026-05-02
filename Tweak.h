#import <UIKit/UIKit.h>

#define RTLog(...) NSLog(@"[iMessageRetweet] [%s:%d] %@", __FILE__, __LINE__, [NSString stringWithFormat:__VA_ARGS__])

@interface IMMessageItem : NSObject
@end

@interface IMMessage : NSObject
@property (copy, nonatomic) NSString *threadIdentifier;
@property (retain, nonatomic) IMMessage *threadOriginator;
@end

@interface CKChatItem : NSObject
@end

@interface CKMessagePartChatItem : CKChatItem
@end

@interface CKUtilities : NSObject
+ (IMMessage *)imMessageForIMMessageItem:(IMMessageItem *)messageItem;
+ (NSString *)threadIdentifierForMessagePart:(CKMessagePartChatItem *)part;
+ (IMMessageItem *)threadOriginatorForMessagePart:(CKMessagePartChatItem *)part;
@end

@interface CKComposition : NSObject
- (instancetype)initWithText:(NSAttributedString *)text subject:(NSString *)subject;
@end

@interface CKConversation : NSObject
- (NSArray <IMMessage *> *)messagesFromComposition:(CKComposition *)composition;
- (void)sendMessage:(IMMessage *)message newComposition:(BOOL)composition;
@end

@interface CKCoreChatController : UIViewController
@property (nonatomic, retain) CKConversation *conversation;
@end

@interface CKChatController : CKCoreChatController
@end

@interface CKChatController (Retweet)
- (UIAction *)_iMRT_retweetMenuActionForChatItem:(CKMessagePartChatItem *)chatItem;
@end