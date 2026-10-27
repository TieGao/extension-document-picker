#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#include <hx/CFFI.h>
#include "DocumentPickerDelegate.h"

@implementation DocumentPickerDelegate

AutoGCRoot* callback = 0;

- (id) initWithCallback:(value)cb {
    if (callback != 0) {
        delete callback;
        callback = 0;
    }
    callback = new AutoGCRoot(cb);
    NSLog(@"initWithCallback");
    return self;
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if(urls != nil && urls.count > 0 && urls[0] != nil) {
        if (callback != NULL) val_call1(callback->get(), alloc_string([urls[0].path UTF8String]));
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    NSLog(@"documentPickerWasCancelled");
    if (callback != NULL) val_call1(callback->get(), alloc_null());
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    NSLog(@"documentPicker documentPicker");
}

@end