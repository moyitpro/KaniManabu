//
//  DeckViewCell.m
//  WaniManabu
//
//  Created by 丈槍由紀 on 1/10/22.
//

#import "DeckViewCell.h"
#import "DeckManager.h"

@implementation DeckViewCell

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)awakeFromNib {
    self.autoresizingMask = NSViewWidthSizable|NSViewHeightSizable;
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveNotification:) name:@"CardAdded" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveNotification:) name:@"CardRemoved" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveNotification:) name:@"CardModified" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveNotification:) name:@"ReviewEnded" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveNotification:) name:@"LearnEnded" object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveNotification:) name:@"TimerFired" object:nil];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
- (IBAction)startLearnSession:(id)sender {
    if (_learningcount.stringValue.intValue > 0) {
        [NSNotificationCenter.defaultCenter postNotificationName:@"StartLearning" object:_deckMeta];
    }
    else {
        [NSNotificationCenter.defaultCenter postNotificationName:@"StartLearning" object:[NSNull null]];
    }
}
- (IBAction)startReviewSession:(id)sender {
    if (_reviewcount.stringValue.intValue > 0) {
        [NSNotificationCenter.defaultCenter postNotificationName:@"StartReviewing" object:_deckMeta];
    }
    else {
        [NSNotificationCenter.defaultCenter postNotificationName:@"StartReviewing" object:[NSNull null]];
    }
}

- (void)receiveNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:@"CardAdded"]||[notification.name isEqualToString:@"CardRemoved"]||[notification.name isEqualToString:@"CardModified"]||[notification.name isEqualToString:NSPersistentStoreRemoteChangeNotification] || [notification.name isEqualToString:@"ReviewEnded"] || [notification.name isEqualToString:@"TimerFired"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Reload
            [self reloadQueueCount];
        });
    }
}

- (void)setDeckTypeLabel {
    switch (((NSNumber *)[_deckMeta valueForKey:@"deckType"]).intValue) {
        case DeckTypeKana:
            _decktypestr.stringValue = @"かな";
            break;
        case DeckTypeKanji:
            _decktypestr.stringValue = @"漢字";
            break;
        case DeckTypeVocab:
            _decktypestr.stringValue = @"単語";
            break;
        default:
            break;
    }
}

- (void)reloadQueueCount {
    if (((NSNumber *)[_deckMeta valueForKey:@"enabled"]).boolValue) {
        _totalreviewitemcount = [DeckManager.sharedInstance getQueuedReviewItemsCountforUUID:[_deckMeta valueForKey:@"deckUUID"] withType:((NSNumber *)[_deckMeta valueForKey:@"deckType"]).intValue];
        _totallearnitemcount = [DeckManager.sharedInstance getQueuedLearnItemsCountforUUID:[_deckMeta valueForKey:@"deckUUID"] withType:((NSNumber *)[_deckMeta valueForKey:@"deckType"]).intValue];
        _reviewcount.stringValue = @(_totalreviewitemcount).stringValue;
        _learningcount.stringValue = @(_totallearnitemcount).stringValue;
        [NSNotificationCenter.defaultCenter postNotificationName:@"AddToQueueCount" object:@{@"learncount" : @(_totallearnitemcount), @"reviewcount" : @(_totalreviewitemcount)}];
        _learnbtn.enabled = YES;
        _reviewbtn.enabled = YES;
    }
    else {
        _reviewcount.stringValue = @"-";
        _learningcount.stringValue = @"-";
        _learnbtn.enabled = NO;
        _reviewbtn.enabled = NO;
    }
}
- (IBAction)addCard:(id)sender {
    [NSNotificationCenter.defaultCenter postNotificationName:@"ActionAddCard" object:_deckMeta];
}
- (IBAction)deletedeck:(id)sender {
    [NSNotificationCenter.defaultCenter postNotificationName:@"ActionDeleteDeck" object:_deckMeta];
}
- (IBAction)openoptions:(id)sender {
    [NSNotificationCenter.defaultCenter postNotificationName:@"ActionShowDeckOptions" object:_deckMeta];
}

@end