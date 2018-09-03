//
//  getItemDetailModel.h
//  IBM i item search
//
//  Created by Michael D Larsen on 3/24/18.
//  Copyright © 2018 Smash Alley, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol getItemDetailModelProtocol <NSObject>

- (void)getItemDetailsWS:(NSArray *)itemDetail;

@end

@interface getItemDetailModel : NSObject <NSURLSessionDataDelegate>

@property (nonatomic, weak) id <getItemDetailModelProtocol> delegate;

- (void)downloadItemDetails:(NSString *)parmItemClass withItemNumber:(NSString *)parmItemNumber;

@end
