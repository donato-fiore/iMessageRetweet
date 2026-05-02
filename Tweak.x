#import "Tweak.h"

%group Common

%hook CKChatController

%new
- (UIAction *)_iMRT_retweetMenuActionForChatItem:(CKMessagePartChatItem *)chatItem {
    if (![chatItem isKindOfClass:%c(CKChatItem)] || ![chatItem respondsToSelector:@selector(IMChatItem)]) {
        return nil;
    }

    return [%c(UIAction) actionWithTitle:@"Retweet"
                                   image:[UIImage systemImageNamed:@"arrow.2.squarepath"]
                              identifier:@"com.apple.mobileSMS.fiore.retweetChatItem"
                                 handler:^(__kindof UIAction * _Nonnull action) {
            CKConversation *conversation = [self conversation];

            NSAttributedString *text = [[NSAttributedString alloc] initWithString:@"rt"];
            CKComposition *composition = [[%c(CKComposition) alloc] initWithText:text subject:nil];
            NSArray <IMMessage *> *messages = [conversation messagesFromComposition:composition];
            if (messages.count == 0) return;

            IMMessage *retweetMessage = [messages firstObject];

            IMMessageItem *originator = [%c(CKUtilities) threadOriginatorForMessagePart:chatItem];
            NSString *threadID = [%c(CKUtilities) threadIdentifierForMessagePart:chatItem];

            if (!threadID || !originator) {
                RTLog(@"Failed to create retweet message: missing thread ID (%@) or originator (%@)", threadID, originator);
                return;
            }

            retweetMessage.threadIdentifier = threadID;
            retweetMessage.threadOriginator = [%c(CKUtilities) imMessageForIMMessageItem:originator];
            
            [conversation sendMessage:retweetMessage newComposition:NO];
    }];
}

%end

%end

%group iOS16

%hook CKChatController

- (UIMenu *)_menuForChatItem:(CKMessagePartChatItem *)chatItem {
    UIMenu *menu = %orig;
    NSMutableArray *actions = [menu.children mutableCopy] ?: [NSMutableArray array];

    UIAction *pinAction = [self _iMRT_retweetMenuActionForChatItem:chatItem];
    if (!pinAction) return menu;

    NSUInteger insertIndex = actions.count > 0 ? actions.count - 1 : 0;
    [actions insertObject:pinAction atIndex:insertIndex];

    return [UIMenu menuWithTitle:menu.title children:actions];
}

%end

%end

%group iOS17

%hook CKChatController

- (UIMenu *)_menuForChatItem:(CKMessagePartChatItem *)chatItem
          withParentChatItem:(id)parentChatItem {
    UIMenu *menu = %orig;
    NSMutableArray *actions = [menu.children mutableCopy] ?: [NSMutableArray array];

    UIAction *pinAction = [self _iMRT_retweetMenuActionForChatItem:chatItem];
    if (!pinAction) return menu;

    NSUInteger insertIndex = actions.count > 0 ? actions.count - 1 : 0;
    [actions insertObject:pinAction atIndex:insertIndex];

    return [UIMenu menuWithTitle:menu.title children:actions];
}

%end

%end

%group iOS18

%hook CKChatController

- (UIMenu *)_menuForChatItem:(CKMessagePartChatItem *)chatItem
          withParentChatItem:(id)parentChatItem
              menuAppearance:(NSInteger)menuAppearance {
    UIMenu *menu = %orig;
    NSMutableArray *actions = [menu.children mutableCopy] ?: [NSMutableArray array];

    UIAction *pinAction = [self _iMRT_retweetMenuActionForChatItem:chatItem];
    if (!pinAction) return menu;

    NSUInteger insertIndex = actions.count > 0 ? actions.count - 1 : 0;
    [actions insertObject:pinAction atIndex:insertIndex];

    return [UIMenu menuWithTitle:menu.title children:actions];
}

%end

%end

%ctor {
    @autoreleasepool {
        %init(Common);

        NSInteger major = NSProcessInfo.processInfo.operatingSystemVersion.majorVersion;

        switch (major) {
            case 14:
            case 15:
            case 16:
                %init(iOS16);
                break;
            case 17:
                %init(iOS17);
                break;
            case 18:
                %init(iOS18);
                break;
            default:
                break;
        }
    }
}