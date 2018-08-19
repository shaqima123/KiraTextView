//
//  ViewController.m
//  KiraTextView
//
//  Created by Kira on 2018/8/19.
//  Copyright © 2018 Kira. All rights reserved.
//

#import "ViewController.h"
#import "RSAddTextViewTextStorage.h"
#import "RSAddTextViewLayoutManager.h"
#import "Masonry.h"

const CGFloat minFontSize = 8.f;
const CGFloat maxFontSize = 30.f;
#define Height_Top_Addtion ((IS_IPHONE_X == YES) ? 44.0f : 0)
#define IS_IPHONE_X                 (CGRectGetHeight([UIScreen mainScreen].bounds) == 812)

@interface ViewController ()<
UITextViewDelegate
>
{
    CGRect _kbRect;
    RSAddTextViewTextStorage *storage;
    BOOL isDelete;
    int count;
}
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *bgButton;
@property (nonatomic, assign) RSAddTextBackGroundType bgType;
@property (nonatomic, strong) RSAddTextViewLayoutManager *layoutManager;
@property (nonatomic, assign) CGFloat fontSize;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];
    [self bgButton];
    [self.textView becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

#pragma mark get - set
- (UIButton *)bgButton {
    if (!_bgButton) {
        _bgButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [_bgButton setTitle:@"切换背景框" forState:UIControlStateNormal];
        [_bgButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_bgButton addTarget:self action:@selector(changeBG) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_bgButton];
        [_bgButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(Height_Top_Addtion + 10.f);
            make.right.equalTo(self.view).offset(-10.f);
        }];
    }
    return _bgButton;
}

- (UITextView *)textView {
    if (!_textView) {
        
        storage = [RSAddTextViewTextStorage new];
        
        self.layoutManager = [RSAddTextViewLayoutManager new];
        
        [storage addLayoutManager:self.layoutManager];
        
        NSTextContainer *container = [[NSTextContainer alloc] initWithSize:CGSizeZero];
        [self.layoutManager addTextContainer:container];
        
        _textView = [[UITextView alloc] initWithFrame:CGRectZero textContainer:container];
        _textView.userInteractionEnabled = YES;
        _textView.clipsToBounds = NO;
        _textView.textAlignment = NSTextAlignmentCenter;
        _textView.backgroundColor = [UIColor clearColor];
        
        CGFloat xMargin = 8, yMargin = 8;
        // 使用textContainerInset设置top、leaft、right
        _textView.textContainerInset = UIEdgeInsetsMake(yMargin, xMargin, yMargin, xMargin);
        
        self.fontSize = 30.f;
        self.bgType = RSAddTextBackGroundTypeNone;
        
        _textView.font = [UIFont systemFontOfSize:self.fontSize];
        
        _textView.textColor = [UIColor whiteColor];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 8.f;
        
        NSDictionary *attributes = @{
                                     NSFontAttributeName:[UIFont systemFontOfSize:self.fontSize],
                                     NSParagraphStyleAttributeName:style
                                     };
        _textView.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:attributes];
        _textView.contentInset = UIEdgeInsetsZero;
        
        _textView.editable = YES;
        _textView.scrollEnabled = NO;
        _textView.keyboardType = UIKeyboardTypeDefault;
        _textView.keyboardAppearance = UIKeyboardAppearanceDark;
        _textView.self.layoutManager.allowsNonContiguousLayout = NO;
        _textView.delegate = self;
        
        [self.view addSubview:_textView];
        [_textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(20);
            make.right.equalTo(self.view).offset(-20);
            make.centerY.equalTo(self.view);
            make.height.mas_equalTo(50);
        }];
    }
    return _textView;
}

#pragma mark private methods

- (void)changeBG {
    count ++;
    if (count % 3 == 0) {
        self.bgType = RSAddTextBackGroundTypeNone;
        self.textView.textColor = [UIColor whiteColor];
        self.layoutManager.useColor = [UIColor whiteColor];
    }
    if (count % 3 == 1) {
        self.bgType = RSAddTextBackGroundTypeSolid;
        self.textView.textColor = [UIColor blackColor];
        self.layoutManager.useColor = [UIColor whiteColor];
    }
    if (count % 3 == 2) {
        self.bgType = RSAddTextBackGroundTypeBorder;
        self.textView.textColor = [UIColor whiteColor];
        self.layoutManager.useColor = [UIColor whiteColor];
    }
    self.layoutManager.type = self.bgType;
}

#pragma mark UITextViewDelegate

- (CGFloat) heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@""]) {
        isDelete = YES;
    } else {
        isDelete = NO;
    }
    return YES;
}


- (void)textViewDidChange:(UITextView *)textView {
    CGFloat height = [self heightForString:textView andWidth:textView.bounds.size.width];
    
    if (height < textView.frame.size.height && isDelete) {
        //判断是否为删除并且view将要缩小
        if (self.fontSize < maxFontSize) {
            //放大字体适应textView
            while (self.fontSize < maxFontSize && [textView sizeThatFits:(CGSizeMake(textView.frame.size.width, FLT_MAX))].height < textView.frame.size.height) {
                self.fontSize += 0.1;
                [self.textView setFont:[UIFont systemFontOfSize:self.fontSize]];
            }
            
            [_textView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo([textView sizeThatFits:(CGSizeMake(textView.frame.size.width, FLT_MAX))].height).priority(750);
            }];
        } else {
            //否则更新textView的高度
            [_textView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(height).priority(750);
            }];
        }
        [textView scrollRangeToVisible:NSMakeRange(textView.text.length, 0)];
        [self.view layoutIfNeeded];
        return;
    }
    
    if (height > textView.frame.size.height) {
        //判断view是否要变大
        if (_textView.frame.origin.y <= Height_Top_Addtion + 56 + self.fontSize + 8) {
            //如果view达到最大，则缩小字体去适应view
            if ([textView sizeThatFits:(CGSizeMake(textView.frame.size.width, FLT_MAX))].height > textView.frame.size.height) {
                while (self.fontSize > minFontSize && [textView sizeThatFits:(CGSizeMake(textView.frame.size.width, FLT_MAX))].height >= textView.frame.size.height) {
                    self.fontSize -= 0.1;
                    [self.textView setFont:[UIFont systemFontOfSize:self.fontSize]];
                }
            }
            [_textView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo([textView sizeThatFits:(CGSizeMake(textView.frame.size.width, FLT_MAX))].height).priority(750);
            }];
        } else {
            //否则更新textView的高度
            [_textView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(height).priority(750);
            }];
        }
        [textView scrollRangeToVisible:NSMakeRange(textView.text.length, 0)];
        [self.view layoutIfNeeded];
        return;
    }
}


#pragma mark notification
- (void)keyboardWillShow:(NSNotification *)notification{
    NSDictionary *dict = notification.userInfo;
    _kbRect = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat height = [self heightForString:self.textView andWidth:self.textView.bounds.size.width];
    [self.textView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.greaterThanOrEqualTo(self.view).offset(Height_Top_Addtion + 56).priority(1000);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.height.mas_equalTo(height).priority(750);
        make.centerY.equalTo(self.view).offset(- self->_kbRect.size.height / 2);
    }];
}

@end
