//
//  getItemModel.h
//  IBM i item search
//
//  Created by Michael D Larsen on 3/18/18.
//  Copyright © 2018 Smash Alley, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol getItemModelProtocol <NSObject>

- (void)getItemsWS:(NSArray *)items;

@end

@interface getItemModel : NSObject <NSURLSessionDataDelegate>

@property (nonatomic, weak) id <getItemModelProtocol> delegate;

//- (void)downloadItems:(NSString *)parmItemClass withItemNumber:(NSString *)parmItemNumber;
- (void)downloadItems:(NSString *)parmItemClass;

@end
