//
//  RNSDefinitions.h
//  ReactiveNetService
//
//  Created by Nathan Douglas on 02/04/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "YOLO.h"

/**
 Returns an error constructed from an error dictionary.
 
 @param _errorDictionary The error dictionary.
 @return An error constructed from an error dictionary.
 */

NSError *RNSErrorForErrorDictionary(NSDictionary *errorDictionary);
