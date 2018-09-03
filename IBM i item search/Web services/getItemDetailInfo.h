//
//  getItemDetailInfo.h
//  IBM i item search
//
//  Created by Michael D Larsen on 3/24/18.
//  Copyright © 2018 Smash Alley, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface getItemDetailInfo : NSObject

@property (nonatomic, strong) NSString *strItemClassDetail;
@property (nonatomic, strong) NSString *strItemNumberDetail;
@property (nonatomic, strong) NSString *strItemNumberDescriptionDetail;
@property (nonatomic, strong) NSString *strUnitOfMeasureDetail;

@property (nonatomic, strong) NSString *WSResponseMessage;

@end
