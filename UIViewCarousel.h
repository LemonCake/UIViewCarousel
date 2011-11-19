//
//  UIViewCarousel.h
//  Miso
//
//  Created by Joshua Wu on 8/29/11.
//  Copyright 2011 Miso. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol UIViewCarouselDataSource;

@interface UIViewCarousel : UIView <UIScrollViewDelegate> {
    NSMutableDictionary *_dequeueList;
    NSMutableArray *_activeViews;
    UIScrollView *_carousel;
    
    int _currentIndex;
    int _bufferSize;
    int _numViews;
    BOOL _enableViewBuffer;
    id<UIViewCarouselDataSource> _dataSource;
    id<UIScrollViewDelegate> _scrollDelegate;
    UIPageControl *_pageControl;
    BOOL _showPageControl;
    BOOL _enableWrap;
}

@property (nonatomic, assign) int currentIndex;
@property (nonatomic, assign) BOOL enableViewBuffer;
@property (nonatomic, assign) BOOL showPageControl;
@property (nonatomic, assign) id<UIViewCarouselDataSource> dataSource;
@property (nonatomic, assign) BOOL enableWrap;
@property (nonatomic, assign) BOOL customHackOn;
@property (nonatomic, assign) int bufferSize;
@property (nonatomic, retain) UIScrollView *carousel;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, assign) id<UIScrollViewDelegate> scrollDelegate;

- (void)reloadData;
- (id)dequeueReuseableViewWithClass:(id)klass;
- (void)setCurrentIndex:(int)currentIndex animated:(BOOL)animated;
- (UIView *)activeViewWithTag:(NSInteger)tag;
@end

@protocol UIViewCarouselDataSource <NSObject>

- (int)numberOfViewsInViewCarousel:(UIViewCarousel *)viewCarousel;
- (UIView *)viewCarousel:(UIViewCarousel *)viewCarousel viewAtIndex:(int)index;

@end