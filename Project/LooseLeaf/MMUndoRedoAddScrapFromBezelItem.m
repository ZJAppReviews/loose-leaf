//
//  MMUndoRedoAddScrapFromBezelItem.m
//  LooseLeaf
//
//  Created by Adam Wulf on 7/15/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMUndoRedoAddScrapFromBezelItem.h"
#import "MMUndoablePaperView.h"
#import "MMScrapSidebarContainerView.h"

@interface MMUndoRedoAddScrapFromBezelItem (Private)

@property (readonly) NSDictionary* properties;

@end

@implementation MMUndoRedoAddScrapFromBezelItem{
    NSString* scrapUUID;
    NSDictionary* properties;
}

@synthesize scrapUUID;

+(id) itemForPage:(MMUndoablePaperView*)_page andScrapUUID:(NSString*)scrapUUID andProperties:(NSDictionary*)scrapProperties{
    return [[MMUndoRedoAddScrapFromBezelItem alloc] initForPage:_page andScrapUUID:scrapUUID andProperties:scrapProperties];
}

-(id) initForPage:(MMUndoablePaperView*)_page andScrapUUID:(NSString*)_scrapUUID andProperties:(NSDictionary*)scrapProperties{
    __weak MMUndoRedoAddScrapFromBezelItem* weakSelf = self;
    if(self = [super initWithUndoBlock:^{
        MMScrapView* scrap = [weakSelf.page.scrapsOnPaperState scrapForUUID:weakSelf.scrapUUID];
        [weakSelf.page.bezelContainerView addScrapToBezelSidebar:scrap animated:YES];
    } andRedoBlock:^{
        MMScrapView* scrap = [weakSelf.page.scrapsOnPaperState scrapForUUID:weakSelf.scrapUUID];
        [weakSelf.page.bezelContainerView didTapOnScrapFromMenu:scrap withPreferredScrapProperties:weakSelf.properties];
    } forPage:_page]){
        scrapUUID = _scrapUUID;
        properties = scrapProperties;
    };
    return self;
}


#pragma mark - Serialize

-(NSDictionary*) asDictionary{
    NSMutableDictionary* propertiesDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:NSStringFromClass([self class]), @"class",
                                                 [NSNumber numberWithBool:self.canUndo], @"canUndo", nil];
    [propertiesDictionary setObject:scrapUUID forKey:@"scrapUUID"];
    [propertiesDictionary setObject:properties forKey:@"properties"];
    
    return propertiesDictionary;
}

-(id) initFromDictionary:(NSDictionary*)dict forPage:(MMUndoablePaperView*)_page{
    NSString* _scrapUUID = [dict objectForKey:@"scrapUUID"];
    NSDictionary* propertiesInDict = [dict objectForKey:@"properties"];
    if(self = [self initForPage:_page andScrapUUID:_scrapUUID andProperties:propertiesInDict]){
        canUndo = [[dict objectForKey:@"canUndo"] boolValue];
    }
    return self;
}

#pragma mark - Description

-(NSString*) description{
    return [NSString stringWithFormat:@"[%@ %@]", NSStringFromClass([self class]), scrapUUID];
}

#pragma mark - Private Properties

-(NSDictionary*) properties{
    return properties;
}

@end
