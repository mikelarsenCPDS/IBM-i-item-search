//
//  getItemClassModel.m
//  IBM i item search
//
//  Created by Michael D Larsen on 3/11/18.
//  Copyright © 2018 Smash Alley, LLC. All rights reserved.
//

#import "getItemClassModel.h"
#import "getItemClassInfo.h"

// Notes:  you have to add this to Info.plist
// <key>NSAppTransportSecurity</key>
// <dict>
// <key>NSAllowsArbitraryLoads</key>
// <false/>
// <key>NSExceptionDomains</key>
// <dict>
// <key>i.techsoftinc.com</key>
// <dict>
// <key>NSIncludesSubdomains</key>
// <true/>
// <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
// <true/>
// <key>NSThirdPartyExceptionRequiresForwardSecrecy</key>
// <false/>
// <key>NSTemporaryExceptionMinimumTLSVersion</key>
// <string>TLSv1.1</string>
// </dict>
// </dict>
// </dict>

@interface getItemClassModel()

{
    NSMutableArray *_itemClasses;
}

@end

@implementation getItemClassModel

- (void)downloadItemClasses
{
    // all item classes retrieved from the web service will be loaded into this array
    
    _itemClasses = [[NSMutableArray alloc] init];
    
    // set up url configuration
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    sessionConfiguration.HTTPAdditionalHeaders = @{@"Current-Type" : @"application/x-www-form-urlencoded",
                                                   @"Accept" : @"application/json"};
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    // construct the url along with the parameter 'iten class' being sent
    
    NSString *strUrl = @"http://YOUR_URL:/YOUR_PORT/web/services/RTV_ITEMS/";
    
    NSURL *url = [NSURL URLWithString:strUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // GET differs from POST in that you don't need to send content length and http body with GET
    
    request.HTTPMethod = @"GET";
    
    // this section will initiate the consumption of the web service
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
        {
            // get reponse
            {
                if (!error)
                {
                    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                                                      
                    // check if the response is good
                    
                    if (httpResp.statusCode == 200)
                    {
                        NSError *jsonError;
                                                          
                        NSDictionary *statusJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                                   options:NSJSONReadingAllowFragments
                                                                                     error:&jsonError];
                        if (!jsonError)
                        {
                            // grab the item class list being passed from the web service
                            
                            NSArray *itemClassesArray = [statusJSON objectForKey:@"itemClasses"];
                            
                            // NOTE: the JSON structure being returned from this service is an array, so
                            //       we have to parse it as such.
                            //       Dictionaries are indicated by being enclosed with curly braces {}
                            //       Arrays are indicated by being enclosed with brackets []
                                                              
                            for (NSDictionary *theStatus in itemClassesArray)
                            {
                                // Create a new ItemClassInfo object and set its props to JsonElement properties
                                
                                getItemClassInfo *newItemClassInfo = [[getItemClassInfo alloc] init];
                
                                newItemClassInfo.strItemClass = theStatus[@"itemClass"];
                                newItemClassInfo.strItemClassDescription = theStatus[@"itemClassDesc"];
                                newItemClassInfo.WSResponseMessage = @"Successful connection to server";
                                                                  
                                // Add this to the itemClasses array
                                
                                [self->_itemClasses addObject:newItemClassInfo];
                            }
                        }
                    }
                    else
                    {
                        // bad response
                        
                        getItemClassInfo *newItemClassInfo = [[getItemClassInfo alloc] init];
                                                          
                        newItemClassInfo.WSResponseMessage = @"Can't connect to server";
                        [self->_itemClasses addObject:newItemClassInfo];
                    }
                }
            }
                                              
            [self.delegate getItemClassWS:self->_itemClasses];
                                              
        }];
    
    [postDataTask resume];
}

@end
