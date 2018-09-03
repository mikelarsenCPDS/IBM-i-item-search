//
//  getItemClassModel.h
//  IBM i item search
//
//  Created by Michael D Larsen on 3/11/18.
//  Copyright © 2018 Smash Alley, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol getItemClassModelProtocol <NSObject>

- (void)getItemClassWS:(NSArray *)itemClasses;

@end

@interface getItemClassModel : NSObject <NSURLSessionDataDelegate>

@property (nonatomic, weak) id <getItemClassModelProtocol> delegate;

- (void)downloadItemClasses;

@end
