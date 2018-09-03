//
//  getItemModel.m
//  IBM i item search
//
//  Created by Michael D Larsen on 3/18/18.
//  Copyright © 2018 Smash Alley, LLC. All rights reserved.
//

#import "getItemModel.h"
#import "getItemInfo.h"

// parameter being sent to the web service

//NSString *parmItemNumber;

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

@interface getItemModel()

{
    NSString *itemClass;
    //NSString *itemNumber;
    
    NSMutableArray *_items;
}

@end

@implementation getItemModel

//- (void)downloadItems:(NSString *)parmItemClass withItemNumber:(NSString *)parmItemNumber
- (void)downloadItems:(NSString *)parmItemClass
{
    itemClass = parmItemClass;
    //itemNumber = parmItemNumber;
    
    // all items retrieved from the web service will be loaded into this array
    
    _items = [[NSMutableArray alloc] init];
    
    // set up url configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    sessionConfiguration.HTTPAdditionalHeaders = @{@"Current-Type" : @"application/x-www-form-urlencoded",
                                                   @"Accept" : @"application/json"};
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    // construct the url along with the parameter 'item class' being sent
    
    //NSString *urlParmItemClass = [NSString stringWithFormat:@"itemclass/%@", itemClass];
    NSString *urlParmItemClass = [NSString stringWithFormat:@"/%@", itemClass];
    //NSString *urlParmItemNumber = [NSString stringWithFormat:@"itemnumber/%@", itemNumber];
    
    NSString *strUrl = @"http://YOUR_URL:/YOUR_PORT/web/services/RTV_ITEMS/";
    
    strUrl = [strUrl stringByAppendingString:urlParmItemClass];
    //strUrl = [strUrl stringByAppendingString:urlParmItemNumber];
    
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
                        // grab the items list being passed from the web service
                                                              
                        NSArray *itemsArray = [statusJSON objectForKey:@"itemNumbers"];
                        
                        // NOTE: the JSON structure being returned from this service is an array, so
                        //       we have to parse it as such.
                        //       Dictionaries are indicated by being enclosed with curly braces {}
                        //       Arrays are indicated by being enclosed with brackets []
                                                              
                        for (NSDictionary *theStatus in itemsArray)
                        {
                            // Create a new ItemClassInfo object and set its props to JsonElement properties
                                                                  
                            getItemInfo *newItemInfo = [[getItemInfo alloc] init];
                                                                  
                            newItemInfo.strItemNumber = theStatus[@"itemNumber"];
                            newItemInfo.strItemNumberDescription = theStatus[@"itemNumberDescription"];
                            newItemInfo.WSResponseMessage = @"Successful connection to server";
                                                                  
                            // Add this question to the items array
                                                                  
                            [self->_items addObject:newItemInfo];
                        }
                    }
                }
                else
                {
                // bad response
                                                          
                getItemInfo *newItemInfo = [[getItemInfo alloc] init];
                                                          
                newItemInfo.WSResponseMessage = @"Can't connect to server";
                    [self->_items addObject:newItemInfo];
                }
            }
        }
                                              
        [self.delegate getItemsWS:self->_items];
                                              
    }];
    
    [postDataTask resume];
}

@end
