package com.rjfun.cordova.mopub;

import com.rjfun.cordova.ad.GenericAdPlugin;

import android.util.DisplayMetrics;
import android.view.View;

import com.mopub.mobileads.MoPubErrorCode;
import com.mopub.mobileads.MoPubInterstitial;
import com.mopub.mobileads.MoPubInterstitial.InterstitialAdListener;
import com.mopub.mobileads.MoPubView;
import com.mopub.mobileads.MoPubView.BannerAdListener;

public class MoPubPlugin extends GenericAdPlugin {
    private static final String LOGTAG = "MoPub";
    
    private static final String TEST_BANNER_ID 			= "47289d61e17f4a158efa5cc3bccdcb88";
    private static final String TEST_INTERSTITIAL_ID 	= "aebb4fad0e2a4d10abb370eff7012632";
    
    private static final String TEST_BANNER_ID2 		= "agltb3B1Yi1pbmNyDAsSBFNpdGUY8fgRDA";
    private static final String TEST_INTERSTITIAL_ID2	= "agltb3B1Yi1pbmNyDAsSBFNpdGUY6tERDA";
    
    private float screenDensity = 1.0f;
    
    @Override
    protected void pluginInitialize() {
    	super.pluginInitialize();
    	
    	DisplayMetrics metrics = new DisplayMetrics();
        cordova.getActivity().getWindowManager().getDefaultDisplay().getMetrics(metrics);
        screenDensity = metrics.density;
	}

	@Override
	protected String __getProductShortName() {
		return "MoPub";
	}

	@Override
	protected String __getTestBannerId() {
		return TEST_BANNER_ID;
	}

	@Override
	protected String __getTestInterstitialId() {
		return TEST_INTERSTITIAL_ID;
	}

	@Override
	protected View __createAdView(String adId) {
		if(isTesting) adId = TEST_BANNER_ID2;
		
		MoPubView ad = new MoPubView(getActivity());
        ad.setAdUnitId(adId);
        ad.setBannerAdListener(new BannerAdListener(){
			@Override
			public void onBannerClicked(MoPubView arg0) {
	           	fireAdEvent(EVENT_AD_LEAVEAPP, ADTYPE_BANNER);
			}

			@Override
			public void onBannerCollapsed(MoPubView arg0) {
	        	fireAdEvent(EVENT_AD_DISMISS, ADTYPE_BANNER);
			}

			@Override
			public void onBannerExpanded(MoPubView arg0) {
	        	fireAdEvent(EVENT_AD_PRESENT, ADTYPE_BANNER);
			}

			@Override
			public void onBannerFailed(MoPubView arg0, MoPubErrorCode arg1) {
	        	fireAdErrorEvent(EVENT_AD_FAILLOAD, arg1.ordinal(), arg1.toString(), ADTYPE_BANNER);
			}

			@Override
			public void onBannerLoaded(MoPubView arg0) {
				if((! bannerVisible) && autoShowBanner) {
					showBanner(adPosition, posX, posY);
				}
	        	fireAdEvent(EVENT_AD_LOADED, ADTYPE_BANNER);
			}
        });
        
		return ad;
	}

	@Override
	protected int __getAdViewWidth(View view) {
		if(view instanceof MoPubView) {
			MoPubView ad = (MoPubView) view;
			return (int) (ad.getAdWidth() * screenDensity);
		}
		return 320;
	}

	@Override
	protected int __getAdViewHeight(View view) {
		if(view instanceof MoPubView) {
			MoPubView ad = (MoPubView) view;
			return (int) (ad.getAdHeight() * screenDensity);
		}
		return 50;
	}

	@Override
	protected void __loadAdView(View view) {
		if(view instanceof MoPubView) {
			MoPubView ad = (MoPubView)view;
			ad.loadAd();
		}
	}

	@Override
	protected void __pauseAdView(View view) {
		if(view instanceof MoPubView) {
			MoPubView ad = (MoPubView)view;
			// ad.pause();
		}
	}

	@Override
	protected void __resumeAdView(View view) {
		if(view instanceof MoPubView) {
			MoPubView ad = (MoPubView)view;
			// ad.resume();
		}
	}

	@Override
	protected void __destroyAdView(View view) {
		if(view instanceof MoPubView) {
			MoPubView ad = (MoPubView)view;
			ad.destroy();
		}
	}

	@Override
	protected Object __createInterstitial(String adId) {
		if(isTesting) adId = TEST_INTERSTITIAL_ID2;
		MoPubInterstitial ad = new MoPubInterstitial(getActivity(), adId);
        ad.setInterstitialAdListener(new InterstitialAdListener(){

			@Override
			public void onInterstitialClicked(MoPubInterstitial arg0) {
				fireAdEvent(EVENT_AD_LEAVEAPP, ADTYPE_INTERSTITIAL);
			}

			@Override
			public void onInterstitialDismissed(MoPubInterstitial arg0) {
				fireAdEvent(EVENT_AD_DISMISS, ADTYPE_INTERSTITIAL);
			}

			@Override
			public void onInterstitialFailed(MoPubInterstitial arg0, MoPubErrorCode arg1) {
				fireAdErrorEvent(EVENT_AD_FAILLOAD, arg1.ordinal(), arg1.toString(), ADTYPE_INTERSTITIAL);
			}

			@Override
			public void onInterstitialLoaded(MoPubInterstitial arg0) {
	        	fireAdEvent(EVENT_AD_LOADED, ADTYPE_INTERSTITIAL);
				if(autoShowInterstitial) {
	            	showInterstitial();
	            }
			}

			@Override
			public void onInterstitialShown(MoPubInterstitial arg0) {
				fireAdEvent(EVENT_AD_PRESENT, ADTYPE_INTERSTITIAL);
			}
        });
        return ad;
	}

	@Override
	protected void __loadInterstitial(Object interstitial) {
		if(interstitial instanceof MoPubInterstitial) {
			MoPubInterstitial ad = (MoPubInterstitial) interstitial;
			ad.load();
		}
	}

	@Override
	protected void __showInterstitial(Object interstitial) {
		if(interstitial instanceof MoPubInterstitial) {
			MoPubInterstitial ad = (MoPubInterstitial) interstitial;
		 	if(ad.isReady()) ad.show();
		}
	}

	@Override
	protected void __destroyInterstitial(Object interstitial) {
		if(interstitial instanceof MoPubInterstitial) {
			MoPubInterstitial ad = (MoPubInterstitial) interstitial;
			ad.destroy();
		}
	}
}
