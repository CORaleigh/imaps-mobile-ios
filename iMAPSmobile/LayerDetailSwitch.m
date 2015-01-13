//
//  LayerDetailSwitch.m
//  iMAPSmobile
//
//  Created by Justin Greco on 10/14/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "LayerDetailSwitch.h"

@implementation LayerDetailSwitch
@synthesize layerId = _layerId;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)setLayerId:(NSNumber *)layerId {
    _layerId = layerId;
}

@end
