//
//  RSAddTextViewLayoutManager.h
//  RealSocial
//
//  Created by Kira on 2018/6/20.
//  Copyright © 2018 scnukuncai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, RSAddTextBackGroundType) {
    
    RSAddTextBackGroundTypeNone,
    
    RSAddTextBackGroundTypeBorder,
    
    RSAddTextBackGroundTypeSolid
};

@interface RSAddTextViewLayoutManager : NSLayoutManager

@property (nonatomic, strong) UIColor * useColor;
@property (nonatomic, assign) RSAddTextBackGroundType type;

@end

NS_ASSUME_NONNULL_END
