//
//  LBR_LibraryModel.h
//  Librarius
//
//  Created by Amitai Blickstein on 11/15/15.
//  Copyright © 2015 Amitai Blickstein, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBR_BookcaseLayout.h"

@class LBR_BookcaseModel;
@class Library;
@interface LBR_LibraryModel : NSObject

    //Inputs
@property (nonatomic, strong) Library *library;
@property (nonatomic, assign) LBRLayoutScheme *layoutScheme;

    //Outputs
@property (nonatomic, strong) NSArray <LBR_BookcaseModel*> *bookcaseModels;

    //State
@property (nonatomic) BOOL isProcessed;



-(instancetype)initWithLibrary:(Library*)library layoutScheme:(LBRLayoutScheme)layoutScheme;
-(instancetype)initWithLibrary:(Library*)library;
-(void)processLibrary;

@end
