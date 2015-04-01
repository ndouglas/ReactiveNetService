//
//  RNSNetServiceBrowserDelegate.Private.h
//  ReactiveNetService
//
//  Created by Nathan Douglas on 02/04/15.
//  Released into the public domain.
//  See LICENSE for details.
//

#import "RNSNetServiceBrowserDelegate.h"

@class RACReplaySubject;

@interface RNSNetServiceBrowserDelegate () {
    RACReplaySubject *subject;
    NSMutableArray *services;
}
@property (strong, nonatomic, readwrite) RACReplaySubject *subject;
@property (strong, nonatomic, readwrite) NSMutableArray *services;
@end
