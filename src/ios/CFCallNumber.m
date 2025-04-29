#import <Cordova/CDVPlugin.h>
#import "CFCallNumber.h"

@implementation CFCallNumber

- (void) callNumber:(CDVInvokedUrlCommand*)command {

    [self.commandDelegate runInBackground:^{

        CDVPluginResult* pluginResult = nil;
        NSString* number = [command.arguments objectAtIndex:0];
        number = [number stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        if (![number hasPrefix:@"tel:"]) {
            number = [NSString stringWithFormat:@"tel:%@", number];
        }

        NSURL *phoneURL = [NSURL URLWithString:number];
        UIApplication *application = [UIApplication sharedApplication];

        if (![application canOpenURL:phoneURL]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"NoFeatureCallSupported"];
        }
        else {
            if (@available(iOS 10.0, *)) {
                [application openURL:phoneURL options:@{} completionHandler:^(BOOL success) {
                    if (success) {
                        CDVPluginResult* pluginResultSuccess = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                        [self.commandDelegate sendPluginResult:pluginResultSuccess callbackId:command.callbackId];
                    } else {
                        CDVPluginResult* pluginResultError = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"CouldNotCallPhoneNumber"];
                        [self.commandDelegate sendPluginResult:pluginResultError callbackId:command.callbackId];
                    }
                }];
                return; // Important: return immediately because completionHandler is async!
            } else {
                // iOS <10 fallback
                if (![application openURL:phoneURL]) {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"CouldNotCallPhoneNumber"];
                } else {
                    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
                }
            }
        }

        // Only send if not already sent inside completionHandler
        if (pluginResult != nil) {
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        }

    }];
}

@end
