//
//  SingletonData.h
//  iMAPSmobile
//
//  Created by Justin Greco on 10/8/13.
//  Copyright (c) 2013 City of Raleigh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface SingletonData : NSObject {
    AGSMapView *mapView;
}

@property (nonatomic, retain) AGSMapView *mapView;
@property (nonatomic, retain) NSMutableArray *layersJson;
@property (nonatomic, retain) NSDictionary *baseLayer;
@property (nonatomic, retain) AGSLayer *labels;
@property (nonatomic, retain) AGSGraphic *property;
@property (nonatomic, retain) NSString *currentBaseType;
@property NSUInteger aerialIndex;
@property NSUInteger baseIndex;
@property NSString *singleTapName;

+(SingletonData *) sharedInstance;

+(AGSMapView *) getMapView;
+(void) setMapView:(AGSMapView *)layersJson;

+(NSMutableArray *) getLayersJson;
+(void) setLayersJson:(NSMutableArray *)layersJson;

+(NSDictionary *) getBaseLayer;
+(void) setBaseLayer:(NSDictionary *)baseLayer;

+(AGSLayer *) getLabels;
+(void) setLabels:(AGSLayer *)labels;

+(AGSGraphic *) getProperty;
+(void) setProperty:(AGSGraphic *)property;

+(NSString *) getCurrentBaseType;
+(void) setCurrentBaseType:(NSString *)currentBaseType;

+(NSUInteger) getAerialIndex;
+(void) setAerialIndex:(NSUInteger)aerialIndex;

+(NSUInteger) getBaseIndex;
+(void) setBaseIndex:(NSUInteger)baseIndex;


+(NSString *) getSingleTapName;
+(void) setSingleTapName:(NSString *) singleTapName;
@end
