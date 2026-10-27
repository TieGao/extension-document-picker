#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <hx/CFFI.h>

#include "DocumentPickerDelegate.h"

namespace extension_document_picker {
    void pick(value haxeAllowedUTIs, value callback) {
        int n = 0;
        if (haxeAllowedUTIs != NULL) {
            n = val_array_size(haxeAllowedUTIs);
        }

        NSMutableArray<NSString *> * allowedUTIs = [[NSMutableArray alloc] init];

        for (int i=0;i<n;++i) {
            [allowedUTIs addObject:[NSString stringWithUTF8String:val_string(val_array_i(haxeAllowedUTIs, i))]];
        }

        UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:allowedUTIs inMode:UIDocumentPickerModeImport];
        DocumentPickerDelegate * pickerDelegate = [[DocumentPickerDelegate alloc] initWithCallback: callback];

        picker.delegate = pickerDelegate;
        picker.modalPresentationStyle = UIModalPresentationFormSheet;

        // UIDocumentPickerViewController.delegate is weak: without a strong reference the delegate
        // dies when this scope ends and callbacks never fire (upstream relied on leaking it).
        #if __has_feature(objc_arc)
        static DocumentPickerDelegate * __strong currentDelegate = nil;
        currentDelegate = pickerDelegate;
        #else
        static DocumentPickerDelegate *currentDelegate = nil;
        [currentDelegate release];
        currentDelegate = [pickerDelegate retain];
        [pickerDelegate release];
        #endif

        // keyWindow is nil on iOS 13+ scene-based apps; walk connected scenes instead.
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState != UISceneActivationStateForegroundActive) continue;
                if ([scene isKindOfClass:[UIWindowScene class]]) {
                    for (UIWindow *w in ((UIWindowScene *)scene).windows) {
                        if (w.isKeyWindow) { window = w; break; }
                    }
                }
                if (window != nil) break;
            }
        }
        if (window == nil) window = [UIApplication sharedApplication].keyWindow;

        if (window != nil && window.rootViewController != nil) {
            [window.rootViewController presentViewController:picker animated:YES completion:nil];
        }

        #if !__has_feature(objc_arc)
        [allowedUTIs release];
        [picker release];
        #endif

    }
}