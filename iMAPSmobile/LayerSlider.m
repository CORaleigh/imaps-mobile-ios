//
//  LayerSlider.m
//  iMAPSmobile
//
//  Created by Justin Greco on 10/10/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "LayerSlider.h"

@implementation LayerSlider
@synthesize layerName = _layerName;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(void)setLayerName:(NSString *)layerName {
    _layerName = layerName;
}
@end
