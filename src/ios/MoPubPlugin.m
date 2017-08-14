//
//  MoPubPlugin.m
//  TestAdPlugins
//
//  Created by Xie Liming on 14-11-11.
//
//

#import "MoPubPlugin.h"

#import "MPAdView.h"
#import "MPInterstitialAdController.h"

#define DEFAULT_BANNER_ID       @"420866d662fa4036b04a8cd5b12f525b"
#define DEFAULT_INTERSTITIAL_ID @"b4c9cf91042d409ba8b275409c993c15"

#define TEST_BANNER_ID          @"agltb3B1Yi1pbmNyDAsSBFNpdGUY8fgRDA"
#define TEST_INTERSTITIAL_ID    @"agltb3B1Yi1pbmNyDAsSBFNpdGUYsckMDA"

@interface MoPubPlugin()<MPAdViewDelegate, MPInterstitialAdControllerDelegate, CLLocationManagerDelegate>

@property (assign) CGSize adSize;
@property (assign) BOOL locationEnabled;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *lastKnownLocation;

- (CGSize)__AdSizeFromString:(NSString *)str;
- (void)__enableLocationSupport:(BOOL)shouldEnable;

@end


@implementation MoPubPlugin

- (CGSize)__AdSizeFromString:(NSString *)str {
    if ([str isEqualToString:@"BANNER"]) {
        return MOPUB_BANNER_SIZE;
    } else if ([str isEqualToString:@"SMART_BANNER"]) {
        return MOPUB_BANNER_SIZE;
    } else if ([str isEqualToString:@"FULL_BANNER"]) {
        return MOPUB_BANNER_SIZE;
    } else if ([str isEqualToString:@"MEDIUM_RECTANGLE"]) {
        return MOPUB_MEDIUM_RECT_SIZE;
    } else if ([str isEqualToString:@"LEADERBOARD"]) {
        return MOPUB_LEADERBOARD_SIZE;
    } else if ([str isEqualToString:@"SKYSCRAPER"]) {
        return MOPUB_WIDE_SKYSCRAPER_SIZE;
    } else {
        return MOPUB_BANNER_SIZE;
    }
}

- (void) __enableLocationSupport:(BOOL)shouldEnable
{
    if( self.locationEnabled == shouldEnable )
        return;
    
    self.locationEnabled = shouldEnable;
    
    // are we stopping or starting location use?
    if( self.locationEnabled )
    {
        // autorelease and retain just in case we have an old one to avoid leaking
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 100;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // Make sure the user has location on in settings
        if( self.locationManager.locationServicesEnabled ) {
            // Only start updating if we can get location information
            [self.locationManager startUpdatingLocation];
        } else {
            self.locationEnabled = NO;
            self.locationManager = nil;
        }
    }
    else // turning off
    {
        [self.locationManager stopUpdatingLocation];
        self.locationManager.delegate = nil;
        self.locationManager = nil;
    }
}


- (void)pluginInitialize
{
    [super pluginInitialize];
}

- (void) parseOptions:(NSDictionary *)options
{
    [super parseOptions:options];
    
    NSString* str = [options objectForKey:OPT_AD_SIZE];
    if(str) self.adSize = [self __AdSizeFromString:str];
}

- (NSString*) __getProductShortName
{
    return @"MoPub";
}

- (NSString*) __getDefaultBannerId
{
    return DEFAULT_BANNER_ID;
}

- (NSString*) __getDefaultInterstitialId
{
    return DEFAULT_INTERSTITIAL_ID;
}

- (UIView*) __createAdView:(NSString*)adId;
{
    if(self.isTesting) adId = TEST_BANNER_ID;
    
    MPAdView* ad = [[MPAdView alloc] initWithAdUnitId:adId size:self.adSize];
    if(self.locationEnabled && self.lastKnownLocation) {
        ad.location = self.lastKnownLocation;
    }
    ad.delegate = self;
    
    return ad;
}

- (int) __getAdViewWidth:(UIView*)view
{
    if([view class] == [MPAdView class]) {
        MPAdView* ad = (MPAdView*) view;
        return ad.frame.size.width;
    }
    return 320;
}

- (int) __getAdViewHeight:(UIView*)view
{
    if([view class] == [MPAdView class]) {
        MPAdView* ad = (MPAdView*) view;
        return ad.frame.size.height;
    }
    return 50;
}

- (void) __loadAdView:(UIView*)view
{
    if([view isKindOfClass:[MPAdView class]]) {
        MPAdView* ad = (MPAdView*) view;
        [ad loadAd];
    }
}

- (void) __pauseAdView:(UIView*)view
{
    if([view isKindOfClass:[MPAdView class]]) {
        //MPAdView* ad = (MPAdView*) view;
        // [ad pause];
    }
}

- (void) __resumeAdView:(UIView*)view
{
    if([view isKindOfClass:[MPAdView class]]) {
        //MPAdView* ad = (MPAdView*) view;
        // [ad resume];
    }
}

- (void) __destroyAdView:(UIView*)view
{
    if([view isKindOfClass:[MPAdView class]]) {
        //MPAdView* ad = (MPAdView*) view;
        //[ad destroy];
    }
}

- (NSObject*) __createInterstitial:(NSString*)adId
{
    if(self.isTesting) adId = TEST_INTERSTITIAL_ID;
    
    MPInterstitialAdController* ad = [MPInterstitialAdController interstitialAdControllerForAdUnitId:adId];
    if(self.locationEnabled && self.lastKnownLocation) {
        ad.location = self.lastKnownLocation;
    }
    ad.delegate = self;
    
    return ad;
}

- (void) __loadInterstitial:(NSObject*)interstitial
{
    if([interstitial isKindOfClass:[MPInterstitialAdController class]]) {
        MPInterstitialAdController* ad = (MPInterstitialAdController*) interstitial;
        [ad loadAd];
    }
}

- (void) __showInterstitial:(NSObject*)interstitial
{
    if([interstitial isKindOfClass:[MPInterstitialAdController class]]) {
        MPInterstitialAdController* ad = (MPInterstitialAdController*) interstitial;
        [ad showFromViewController:[self getViewController]];
    }
}

- (void) __destroyInterstitial:(NSObject*)interstitial
{
    if([interstitial isKindOfClass:[MPInterstitialAdController class]]) {
        // MPInterstitialAdController* ad = (MPInterstitialAdController*) interstitial;
        // nothing to do
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager*)manager
    didUpdateToLocation:(CLLocation*)newLocation
           fromLocation:(CLLocation*)oldLocation
{
    self.lastKnownLocation = newLocation;
    
    // update our locations
    
    if(self.banner) {
        MPAdView* ad = (MPAdView*) self.banner;
        ad.location = newLocation;
    }
    
    if(self.interstitial) {
        MPInterstitialAdController* ad = (MPInterstitialAdController*) self.interstitial;
        ad.location = newLocation;
    }
}

#pragma mark MPAdViewDelegate implementation

- (void)adViewDidLoadAd:(MPAdView*)view
{
    [self fireAdEvent:EVENT_AD_LOADED withType:ADTYPE_BANNER];
    
    if((! self.bannerVisible) && self.autoShowBanner) {
        [self __showBanner:self.adPosition atX:self.posX atY:self.posY];
    }
}

- (void)adViewDidFailToLoadAd:(MPAdView*)view
{
    [self fireAdErrorEvent:EVENT_AD_FAILLOAD withCode:-1 withMsg:@"Fail to load Ad" withType:ADTYPE_BANNER];
}

- (void)willPresentModalViewForAd:(MPAdView*)view
{
    [self fireAdEvent:EVENT_AD_PRESENT withType:ADTYPE_BANNER];
}

- (void)didDismissModalViewForAd:(MPAdView*)view
{
    [self fireAdEvent:EVENT_AD_DISMISS withType:ADTYPE_BANNER];
}

- (void)adViewShouldClose:(MPAdView*)view
{
    // TODO:
}

#pragma mark - MPInterstitialAdControllerDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self getViewController];
}

- (void)interstitialDidLoadAd:(MPInterstitialAdController*)interstitial
{
    [self fireAdEvent:EVENT_AD_LOADED withType:ADTYPE_INTERSTITIAL];
    
    if(self.autoShowInterstitial) {
        [self __showInterstitial:self.interstitial];
    }
}


- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController*)interstitial
{
    [self fireAdErrorEvent:EVENT_AD_FAILLOAD
                  withCode:-1
                   withMsg:@"Fail to load Ad"
                  withType:ADTYPE_INTERSTITIAL];
}


- (void)interstitialDidExpire:(MPInterstitialAdController*)interstitial
{
    [self fireAdErrorEvent:EVENT_AD_FAILLOAD
                  withCode:-2
                   withMsg:@"Interstitial expired"
                  withType:ADTYPE_INTERSTITIAL];
}


/*
 * This callback notifies you that the interstitial is about to appear. This is a good time to
 * handle potential app interruptions (e.g. pause a game).
 */
- (void)interstitialWillAppear:(MPInterstitialAdController*)interstitial
{
    [self fireAdEvent:EVENT_AD_WILLPRESENT withType:ADTYPE_INTERSTITIAL];
}


- (void)interstitialWillDisappear:(MPInterstitialAdController*)interstitial
{
    [self fireAdEvent:EVENT_AD_WILLDISMISS withType:ADTYPE_INTERSTITIAL];
}


- (void)interstitialDidDisappear:(MPInterstitialAdController*)interstitial
{
    [self fireAdEvent:EVENT_AD_DISMISS withType:ADTYPE_INTERSTITIAL];
}

@end
