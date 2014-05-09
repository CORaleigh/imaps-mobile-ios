//
//  LegendCell.m
//  iMAPSmobile
//
//  Created by Justin Greco on 10/10/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "LegendCell.h"

@implementation LegendCell
@synthesize legendImage = _legendImage;
@synthesize legendLabel = _legendLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
