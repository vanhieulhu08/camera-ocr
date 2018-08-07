/********* ExpenseOCR.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "OCRViewController.h"
#import "NSData+Base64.h"
@interface ExpenseOCR : CDVPlugin<OCRViewControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    // Member variables go here.
    NSString *commandID;
}

- (void)coolMethod:(CDVInvokedUrlCommand*)command;
@end

@implementation ExpenseOCR

- (void)openCameraOCR:(CDVInvokedUrlCommand*)command
{
    if (!commandID || [commandID isEqualToString:@""]) {
        commandID = command.callbackId;
        [self openCamera];
    }
    
    
}

// Implement
- (void)openCamera{
    UIImagePickerController *standardPicker = [[UIImagePickerController alloc] init];
    standardPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    standardPicker.allowsEditing = NO;
    standardPicker.delegate = self;
    [self.viewController presentViewController:standardPicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    OCRViewController *vc = [[OCRViewController alloc] initWithNibName:@"OCRViewController" bundle:nil];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    vc.image = image;
    vc.delegate = self;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [picker dismissViewControllerAnimated:NO
                               completion:^{
                                   [self.viewController presentViewController:navi animated:YES completion:^{
                                       
                                   }];
                               }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)completeWithImage:(UIImage *)img dictionary:(NSDictionary *)dic{
    if (commandID && ![commandID isEqualToString:@""]) {
        CDVPluginResult* pluginResult = nil;
        
        if (img != nil) {
            NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:dic];
            [result setObject:[UIImagePNGRepresentation(img) base64EncodedString] forKey:@"image"];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:commandID];
        //commandID = @"";
    }
    
}

@end
