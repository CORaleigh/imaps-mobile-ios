//
//  SingletonData.m
//  iMAPSmobile
//
//  Created by Justin Greco on 10/8/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import "SingletonData.h"

@implementation SingletonData
@synthesize mapView;
@synthesize layersJson;
@synthesize baseLayer;
@synthesize labels;
@synthesize property;
@synthesize currentBaseType;
@synthesize aerialIndex;
@synthesize baseIndex;
@synthesize singleTapName;

#pragma mark Singleton Implementation
static SingletonData *sharedObject;
+(SingletonData*)sharedInstance
{
    if (sharedObject == nil) {
        sharedObject = [[super allocWithZone:NULL] init];
    }
    return sharedObject;
}

#pragma mark Shared Public Methods
+(AGSMapView *) getMapView {
    SingletonData *shared = [SingletonData sharedInstance];
    return shared.mapView;
}

+(void) setMapView:(AGSMapView *)mapView {
    SingletonData *shared = [SingletonData sharedInstance];
    shared.mapView = mapView;
}

+(NSMutableArray *) getLayersJson{
    SingletonData *shared = [SingletonData sharedInstance];
    return shared.layersJson;
}

+(void) setLayersJson:(NSMutableArray *)layersJson {
    SingletonData *shared = [SingletonData sharedInstance];
    shared.layersJson = layersJson;
}

+(NSDictionary *) getBaseLayer{
    SingletonData *shared = [SingletonData sharedInstance];
    return shared.baseLayer;
}

+(void) setBaseLayer:(NSDictionary *)baseLayer{
    SingletonData *shared = [SingletonData sharedInstance];
    shared.baseLayer = baseLayer;
}

+(AGSLayer *) getLabels{
    SingletonData *shared = [SingletonData sharedInstance];
    return shared.labels;
}

+(void) setLabels:(AGSLayer *)labels{
    SingletonData *shared = [SingletonData sharedInstance];
    shared.labels = labels;
}

+(AGSGraphic *) getProperty{
    SingletonData *shared = [SingletonData sharedInstance];
    return shared.property;
}

+(void) setProperty:(AGSGraphic *)property{
    SingletonData *shared = [SingletonData sharedInstance];
    shared.property = property;
}

+(NSString *) getCurrentBaseType{
    SingletonData *shared = [SingletonData sharedInstance];
    return shared.currentBaseType;
}

+(void) setCurrentBaseType:(NSString *)currentBaseType{
    SingletonData *shared = [SingletonData sharedInstance];
    shared.currentBaseType = currentBaseType;
}

+(NSUInteger) getBaseIndex{
    SingletonData *shared = [SingletonData sharedInstance];
    return shared.baseIndex;
}

+(void) setBaseIndex:(NSUInteger)baseIndex{
    SingletonData *shared = [SingletonData sharedInstance];
    shared.baseIndex = baseIndex;
}

+(NSUInteger) getAerialIndex{
    SingletonData *shared = [SingletonData sharedInstance];
    return shared.aerialIndex;
}

+(void) setAerialIndex:(NSUInteger)aerialIndex{
    SingletonData *shared = [SingletonData sharedInstance];
    shared.aerialIndex = aerialIndex;
}



+(NSString *) getSingleTapName {
    SingletonData *shared = [SingletonData sharedInstance];
    return shared.singleTapName;
}

+(void) setSingleTapName:(NSString *)singleTapName {
    SingletonData *shared = [SingletonData sharedInstance];
    shared.singleTapName = singleTapName;
}
@end
