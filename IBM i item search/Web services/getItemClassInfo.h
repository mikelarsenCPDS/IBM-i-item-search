//
//  getItemClassInfo.h
//  IBM i item search
//
//  Created by Michael D Larsen on 3/11/18.
//  Copyright © 2018 Smash Alley, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface getItemClassInfo : NSObject

@property (nonatomic, strong) NSString *strItemClass;
@property (nonatomic, strong) NSString *strItemClassDescription;
@property (nonatomic, strong) NSString *WSResponseMessage;

@end
