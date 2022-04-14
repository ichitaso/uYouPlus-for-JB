#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Workaround for https://github.com/MiRO92/uYou-for-YouTube/issues/12

%hook YTAdsInnerTubeContextDecorator
- (void)decorateContext:(id)arg1 {
    %orig(nil);
}
%end


// YouRememberCaption: https://poomsmart.github.io/repo/depictions/youremembercaption.html

%hook YTColdConfig
- (BOOL)respectDeviceCaptionSetting {
    return NO;
}
%end


// YTClassicVideoQuality: https://github.com/PoomSmart/YTClassicVideoQuality

@interface YTVideoQualitySwitchOriginalController : NSObject
- (instancetype)initWithParentResponder:(id)responder;
@end

%hook YTVideoQualitySwitchControllerFactory

- (id)videoQualitySwitchControllerWithParentResponder:(id)responder {
    Class originalClass = %c(YTVideoQualitySwitchOriginalController);
    return originalClass ? [[originalClass alloc] initWithParentResponder:responder] : %orig;
}
%end


// YTNoCheckLocalNetwork: https://poomsmart.github.io/repo/depictions/ytnochecklocalnetwork.html

%hook YTHotConfig

- (BOOL)isPromptForLocalNetworkPermissionsEnabled {
    return NO;
}
%end

// YTNoHoverCards: https://github.com/level3tjg/YTNoHoverCards

@interface YTCollectionViewCell : UICollectionViewCell
@end

@interface YTSettingsCell : YTCollectionViewCell
@end

@interface YTSettingsSectionItem : NSObject
@property BOOL hasSwitch;
@property BOOL switchVisible;
@property BOOL on;
@property BOOL (^switchBlock)(YTSettingsCell *, BOOL);
@property int settingItemId;
+ (instancetype)switchItemWithTitle:(NSString *)title titleDescription:(NSString *)titleDescription accessibilityIdentifier:(NSString *)accessibilityIdentifier switchOn:(BOOL)switchOn switchBlock:(BOOL (^)(YTSettingsCell *, BOOL))switchBlock settingItemId:(int)settingItemId;
- (instancetype)initWithTitle:(NSString *)title titleDescription:(NSString *)titleDescription;
@end

%hook YTSettingsViewController
- (void)setSectionItems:(NSMutableArray <YTSettingsSectionItem *>*)sectionItems forCategory:(NSInteger)category title:(NSString *)title titleDescription:(NSString *)titleDescription headerHidden:(BOOL)headerHidden {
	if (category == 1) {
        NSUInteger defaultPiPIndex = [sectionItems indexOfObjectPassingTest:^BOOL (YTSettingsSectionItem *item, NSUInteger idx, BOOL *stop) {
            return item.settingItemId == 294;
        }];
        if (defaultPiPIndex == NSNotFound) {
            defaultPiPIndex = [sectionItems indexOfObjectPassingTest:^BOOL (YTSettingsSectionItem *item, NSUInteger idx, BOOL *stop) {
                return [[item valueForKey:@"_accessibilityIdentifier"] isEqualToString:@"id.settings.restricted_mode.switch"];
            }];
        }
        if (defaultPiPIndex != NSNotFound) {
            YTSettingsSectionItem *hoverCardItem = [%c(YTSettingsSectionItem) switchItemWithTitle:@"Show End screens hover cards" titleDescription:@"Allows creator End screens (thumbnails) to appear at the end of videos"
            accessibilityIdentifier:nil
            switchOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"hover_cards_enabled"]
            switchBlock:^BOOL (YTSettingsCell *cell, BOOL enabled) {
                [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hover_cards_enabled"];
                return YES;
            }
            settingItemId:0];
			[sectionItems insertObject:hoverCardItem atIndex:defaultPiPIndex + 1];
		}
	}
    %orig(sectionItems, category, title, titleDescription, headerHidden);
}
%end

%hook YTCreatorEndscreenView
- (void)setHidden:(BOOL)hidden {
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hover_cards_enabled"])
		hidden = YES;
	%orig;
}
%end


// YTSystemAppearance: https://poomsmart.github.io/repo/depictions/ytsystemappearance.html

%hook YTColdConfig
- (BOOL)shouldUseAppThemeSetting {
    return YES;
}
%end
