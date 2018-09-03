//
//  getItemInfo.h
//  IBM i item search
//
//  Created by Michael D Larsen on 3/17/18.
//  Copyright © 2018 Smash Alley, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface getItemInfo : NSObject

@property (nonatomic, strong) NSString *strItemNumber;
@property (nonatomic, strong) NSString *strItemNumberDescription;
@property (nonatomic, strong) NSString *WSResponseMessage;

@end
