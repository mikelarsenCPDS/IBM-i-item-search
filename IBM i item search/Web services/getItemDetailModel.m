//
//  getItemDetailModel.m
//  IBM i item search
//
//  Created by Michael D Larsen on 3/24/18.
//  Copyright © 2018 Smash Alley, LLC. All rights reserved.
//

#import "getItemDetailModel.h"
#import "getItemDetailInfo.h"

@interface getItemDetailModel()

{
    NSString *itemClass;
    NSString *itemNumber;
    
    NSMutableArray *_itemDetails;
}

@end

@implementation getItemDetailModel

- (void)downloadItemDetails:(NSString *)parmItemClass withItemNumber:(NSString *)parmItemNumber
{
    itemClass = parmItemClass;
    itemNumber = parmItemNumber;
    
    // all items retrieved from the web service will be loaded into this array
    
    _itemDetails = [[NSMutableArray alloc] init];
    
    // set up url configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    sessionConfiguration.HTTPAdditionalHeaders = @{@"Current-Type" : @"application/x-www-form-urlencoded",
                                                   @"Accept" : @"application/json"};
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    // construct the url along with the parameter 'item class' being sent
    
    NSString *urlParmItemClass  = [NSString stringWithFormat:@"/%@", itemClass];
    NSString *urlParmItemNumber = [NSString stringWithFormat:@"/%@", itemNumber];
    
    NSString *strUrl = @"http://YOUR_URL:/YOUR_PORT/web/services/RTV_ITEMS/";
    
    // add parameters to the url
    
    strUrl = [strUrl stringByAppendingString:urlParmItemClass];
    strUrl = [strUrl stringByAppendingString:urlParmItemNumber];
    
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
                        // grab the item details being passed from the web service
                        
                        NSDictionary *itemDetailsDictionary = [statusJSON objectForKey:@"itemNumberDetails"];
                        {
                            // Create a new ItemDetailInfo object and set its props to JsonElement properties
                            
                            // NOTE: the JSON structure being returned from this service is a dictionary, so
                            //       we have to parse it as such.
                            //       Dictionaries are indicated by being enclosed with curly braces {}
                            //       Arrays are indicated by being enclosed with brackets []
                            
                            getItemDetailInfo *newItemDetailInfo = [[getItemDetailInfo alloc] init];
                            
                            newItemDetailInfo.strItemClassDetail = [itemDetailsDictionary objectForKey:@"itemClassDetail"];
                            newItemDetailInfo.strItemNumberDescriptionDetail = [itemDetailsDictionary objectForKey:@"itemDescriptionDetail"];
                            newItemDetailInfo.strItemNumberDetail = [itemDetailsDictionary objectForKey:@"itemNumberDetail"];
                            newItemDetailInfo.strUnitOfMeasureDetail = [itemDetailsDictionary objectForKey:@"unitOfMeasureDetail"];
                            
                            newItemDetailInfo.WSResponseMessage = @"Successful connection to server";
                                                                  
                            // Add this to the item details array
                                                                  
                            [self->_itemDetails addObject:newItemDetailInfo];
                        }
                    }
                }
                else
                {
                    
                // bad response
                                                          
                getItemDetailInfo *newItemDetailInfo = [[getItemDetailInfo alloc] init];
                                                          
                newItemDetailInfo.WSResponseMessage = @"Can't connect to server";
                    [self->_itemDetails addObject:newItemDetailInfo];
                }
            }
        }
                                              
        [self.delegate getItemDetailsWS:self->_itemDetails];
                                              
    }];
    
    [postDataTask resume];
}

@end
