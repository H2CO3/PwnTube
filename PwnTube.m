//
// PwnTube.m
// PwnTube
//
// Created by Árpád Goretity, 2011.
// Licensed under a CreativeCommons Attribution NonCommercial 3.0 Unported License
//

#import <objc/runtime.h>
#import <substrate.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <YouTube/YouTube.h>
#import "YTVideoRelatedView.h"
#import "PTDelegate.h"

static IMP _original_$_YTVideoRelatedView_$_tableView_numberOfRowsInSection_;
static IMP _original_$_YTVideoRelatedView_$_tableView_cellForRowAtIndexPath_;
static IMP _original_$_YTVideoRelatedView_$_tableView_didSelectRowAtIndexPath_;
static IMP _original_$_YTVideorelatedView_$_tableView_accessoryButtonTappedForRowWithIndexPath_;
static IMP _original_$_YTApplication_$_applicationDidFinishLaunching_;

int _modified_$_YTVideoRelatedView_$_tableView_numberOfRowsInSection_(id _self, SEL _cmd, UITableView *tv, int section) {
	int res = 0;
	if (section == 0) {
		res = (int)_original_$_YTVideoRelatedView_$_tableView_numberOfRowsInSection_(_self, _cmd, tv, section) + 1;
	} else {
		res = (int)_original_$_YTVideoRelatedView_$_tableView_numberOfRowsInSection_(_self, _cmd, tv, section);
	}
	return res;
}

UITableViewCell *_modified_$_YTVideoRelatedView_$_tableView_cellForRowAtIndexPath_(id _self, SEL _cmd, UITableView *tv, NSIndexPath *indexPath) {
	UITableViewCell *cell = nil;
	if (indexPath.section == 0) {
		if (indexPath.row == [tv numberOfRowsInSection: indexPath.section] - 1) {
			YTVideoRelatedView *vrv = (YTVideoRelatedView *)_self;
			cell = [[PTDelegate sharedInstance] customCellForVideo: vrv.video];
		} else {
			cell = (UITableViewCell *)_original_$_YTVideoRelatedView_$_tableView_cellForRowAtIndexPath_(_self, _cmd, tv, indexPath);
		}
	} else {
		cell = (UITableViewCell *)_original_$_YTVideoRelatedView_$_tableView_cellForRowAtIndexPath_(_self, _cmd, tv, indexPath);
	}
	return cell;
}

void _modified_$_YTVideoRelatedView_$_tableView_didSelectRowAtIndexPath_(id _self, SEL _cmd, UITableView *tv, NSIndexPath *indexPath) {
	if (indexPath.section == 0) {
		if (indexPath.row == [tv numberOfRowsInSection: indexPath.section] - 1) {
			[tv deselectRowAtIndexPath: indexPath animated: YES];
			YTVideoRelatedView *relatedView = (YTVideoRelatedView *)_self;
			[[PTDelegate sharedInstance] downloadVideo: relatedView.video];
		} else {
			_original_$_YTVideoRelatedView_$_tableView_didSelectRowAtIndexPath_(_self, _cmd, tv, indexPath);
		}
	} else {
		_original_$_YTVideoRelatedView_$_tableView_didSelectRowAtIndexPath_(_self, _cmd, tv, indexPath);
	}
}

void _modified_$_YTVideorelatedView_$_tableView_accessoryButtonTappedForRowWithIndexPath_(id _self, SEL _cmd, UITableView *tv, NSIndexPath *indexPath) {
	if (indexPath.section == 0) {
		if (indexPath.row == [tv numberOfRowsInSection: indexPath.section] -1) {
			[[PTDelegate sharedInstance] showVideoActions];
		} else {
			_original_$_YTVideorelatedView_$_tableView_accessoryButtonTappedForRowWithIndexPath_(_self, _cmd, tv, indexPath);
		}
	} else {
		_original_$_YTVideorelatedView_$_tableView_accessoryButtonTappedForRowWithIndexPath_(_self, _cmd, tv, indexPath);
	}	
}

void _modified_$_YTApplication_$_applicationDidFinishLaunching_(id _self, SEL _cmd, id sender) {
	_original_$_YTApplication_$_applicationDidFinishLaunching_(_self, _cmd, sender);
	[[PTDelegate sharedInstance] showDonateAlertIfNeeded];
}

__attribute__((constructor)) extern void init() {
	MSHookMessageEx(objc_getClass("YTVideoRelatedView"), @selector(tableView:numberOfRowsInSection:), (IMP)_modified_$_YTVideoRelatedView_$_tableView_numberOfRowsInSection_, &_original_$_YTVideoRelatedView_$_tableView_numberOfRowsInSection_);
	MSHookMessageEx(objc_getClass("YTVideoRelatedView"), @selector(tableView:cellForRowAtIndexPath:), (IMP)_modified_$_YTVideoRelatedView_$_tableView_cellForRowAtIndexPath_, &_original_$_YTVideoRelatedView_$_tableView_cellForRowAtIndexPath_);
	MSHookMessageEx(objc_getClass("YTVideoRelatedView"), @selector(tableView:didSelectRowAtIndexPath:), (IMP)_modified_$_YTVideoRelatedView_$_tableView_didSelectRowAtIndexPath_, &_original_$_YTVideoRelatedView_$_tableView_didSelectRowAtIndexPath_);
	MSHookMessageEx(objc_getClass("YTVideoRelatedView"), @selector(tableView:accessoryButtonTappedForRowWithIndexPath:), (IMP)_modified_$_YTVideorelatedView_$_tableView_accessoryButtonTappedForRowWithIndexPath_, &_original_$_YTVideorelatedView_$_tableView_accessoryButtonTappedForRowWithIndexPath_);
	MSHookMessageEx(objc_getClass("YTApplication"), @selector(applicationDidFinishLaunching:), (IMP)_modified_$_YTApplication_$_applicationDidFinishLaunching_, &_original_$_YTApplication_$_applicationDidFinishLaunching_);
}

