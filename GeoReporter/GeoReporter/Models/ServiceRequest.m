//
//  ServiceRequest.m
//  GeoReporter
//
//  Created by Cliff Ingham on 2/4/13.
//  Copyright (c) 2013 City of Bloomington. All rights reserved.
//

#import "ServiceRequest.h"
#import "Preferences.h"
#import "Strings.h"
#import "Open311.h"

@implementation ServiceRequest

// Intialize a new, empty service request
//
// This does not load any user-submitted data and should only
// be used for initial startup.  Subsequent loads should be done
// using the String version
- (id)initWithService:(NSDictionary *)service
{
    self = [super init];
    if (self) {
        _service  = service;
        
        if ([_service[kOpen311_Metadata] boolValue]) {
            Open311 *open311 = [Open311 sharedInstance];
            _serviceDefinition = open311.serviceDefinitions[_service[kOpen311_ServiceCode]];
        }
        
        _postData = [[NSMutableDictionary alloc] init];
        _postData[kOpen311_ServiceCode] = _service[kOpen311_ServiceCode];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *firstname = [prefs stringForKey:kOpen311_FirstName];
        NSString *lastname  = [prefs stringForKey:kOpen311_LastName];
        NSString *email     = [prefs stringForKey:kOpen311_Email];
        NSString *phone     = [prefs stringForKey:kOpen311_Phone];
        if (firstname != nil) { _postData[kOpen311_FirstName] = firstname; }
        if (lastname  != nil) { _postData[kOpen311_LastName]  = lastname; }
        if (email     != nil) { _postData[kOpen311_Email]     = email; }
        if (phone     != nil) { _postData[kOpen311_Phone]     = phone; }
    }
    return self;
}

// Looks up the attribute definition at the index and returns the key value
//
// This method only works for SingleValueList and MultiValueList attributes
// since they're the only attributes that have value lists
- (NSString *)attributeValueForKey:(NSString *)key atIndex:(NSInteger)index
{
    NSDictionary *attribute = _serviceDefinition[kOpen311_Attributes][index];
    if (   [attribute[kOpen311_Datatype] isEqualToString:kOpen311_SingleValueList]
        || [attribute[kOpen311_Datatype] isEqualToString:kOpen311_MultiValueList]) {
        for (NSDictionary *value in attribute[kOpen311_Values]) {
            if ([value[kOpen311_Key] isEqualToString:key]) {
                return value[kOpen311_Name];
            }
        }
    }
    return nil;
}

@end
