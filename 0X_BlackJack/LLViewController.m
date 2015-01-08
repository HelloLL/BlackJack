//
//  LLViewController.m
//  0X_BlackJack
//
//  Created by LL on 8/17/14.
//  Copyright (c) 2014 Linjie Liu. All rights reserved.
//

#import "LLViewController.h"

#define kBlackjack 21

#define kPlayer 1
#define kDealer 0

#define kCardWidth      72
#define kCardHeight     96
#define kCardDistance   15
#define kViewMargin     50

#define kButtonWidth    100
#define KButtonHeight   30
#define kButtonMargin   20

#define kLabelWidth     120
#define kLabelHeight    30

#define kScreenWidth    self.view.bounds.size.width
#define kScreenHeight   self.view.bounds.size.height


@interface LLViewController ()

@property (nonatomic, strong) UIView *playerHandView;
@property (nonatomic, strong) UIView *dealerHandView;

@property (nonatomic, strong) UILabel *playerHandValueLabel;
@property (nonatomic, strong) UILabel *dealerHandValueLabel;

@property (nonatomic, strong) UIButton *hitButton;
@property (nonatomic, strong) UIButton *standButton;
@property (nonatomic, strong) UIButton *dealButton;

@property (nonatomic, strong) UILabel *resultLabel;

@property (nonatomic, strong) NSMutableArray *deck;

@property (nonatomic, assign) int chips;

@end

@implementation LLViewController

// 视图的懒加载
- (UIView *)playerHandView
{
    if (_playerHandView == nil) {
        _playerHandView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight-kViewMargin-kCardHeight, kScreenWidth, kCardHeight)];
        [self.view addSubview:_playerHandView];
    }
    return _playerHandView;
}

- (UIView *)dealerHandView
{
    if (_dealerHandView == nil) {
        _dealerHandView = [[UIView alloc] initWithFrame:CGRectMake(0, kViewMargin, kScreenWidth, kCardHeight)];
        [self.view addSubview:_dealerHandView];
    }
    return _dealerHandView;
}

- (UILabel *)playerHandValueLabel
{
    if (_playerHandValueLabel == nil) {
        _playerHandValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMinY(self.playerHandView.frame)-kLabelHeight, kScreenWidth, kLabelHeight)];
        _playerHandValueLabel.textAlignment = NSTextAlignmentCenter;
        _playerHandValueLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:_playerHandValueLabel];
    }
    return _playerHandValueLabel;
}

- (UILabel *)dealerHandValueLabel
{
    if (_dealerHandValueLabel == nil) {
        _dealerHandValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.dealerHandView.frame), kScreenWidth, kLabelHeight)];
        _dealerHandValueLabel.textAlignment = NSTextAlignmentCenter;
        _dealerHandValueLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:_dealerHandValueLabel];
    }
    return _dealerHandValueLabel;
}

- (UIButton *)hitButton
{
    if (_hitButton == nil) {
        _hitButton = [[UIButton alloc] initWithFrame:CGRectMake(kButtonMargin, kScreenHeight-KButtonHeight, kButtonWidth, KButtonHeight)];
        [_hitButton setBackgroundColor:[UIColor brownColor]];
        _hitButton.layer.cornerRadius = 10;
        [_hitButton setTitle:@"Hit" forState:UIControlStateNormal];
        [_hitButton addTarget:self action:@selector(hit) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_hitButton];
        _hitButton.hidden = YES;
    }
    return _hitButton;
}

- (UIButton *)standButton
{
    if (_standButton == nil) {
        _standButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-kButtonMargin-kButtonWidth, self.hitButton.frame.origin.y, kButtonWidth, KButtonHeight)];
        [_standButton setBackgroundColor:[UIColor brownColor]];
        _standButton.layer.cornerRadius = 10;
        [_standButton setTitle:@"Stand" forState:UIControlStateNormal];
        [_standButton addTarget:self action:@selector(stand) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_standButton];
        _standButton.hidden = YES;
    }
    return _standButton;
}

- (UIButton *)dealButton
{
    if (_dealButton == nil) {
        _dealButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kButtonWidth, KButtonHeight)];
        _dealButton.center = self.view.center;

        [_dealButton setTitle:@"Deal" forState:UIControlStateNormal];
        [_dealButton addTarget:self action:@selector(newGame) forControlEvents:UIControlEventTouchUpInside];
        [_dealButton setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:0.8]];
        [_dealButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _dealButton.layer.cornerRadius = 10;
        _dealButton.layer.shadowOpacity = 1;
        [self.view addSubview:_dealButton];
    }
    return _dealButton;
}

- (UILabel *)resultLabel
{
    if (_resultLabel == nil) {
        _resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth*0.5-kLabelWidth*0.5, CGRectGetMaxY(self.dealButton.frame)+kButtonMargin, kLabelWidth, kLabelHeight)];
        [self.view addSubview:_resultLabel];
        _resultLabel.textColor = [UIColor orangeColor];
        _resultLabel.textAlignment = NSTextAlignmentCenter;
        _resultLabel.alpha = 0.0;
    }
    return _resultLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self dealButton];
}


/**
 *  开始一个新游戏
 */
- (void)newGame
{
    
    // 重设分值label
    self.playerHandValueLabel.text = @"";
    self.dealerHandValueLabel.text = @"";
    
    
    [UIView animateWithDuration:0.5 animations:^{

        // 隐藏deal按钮和结果label
        self.dealButton.alpha = 0.0;
        self.resultLabel.alpha = 0.0;
        
        // 动画清空玩家和庄家的牌区
        [self removeCardsInView:self.playerHandView];
        [self removeCardsInView:self.dealerHandView];
        
    } completion:^(BOOL finished) {
        
        // 使用一副新的牌
        [self useNewDeck];
        
        // 给玩家和庄家各两张牌
        for (int i = 0; i < 2; i++) {
            [self addCardToView:self.playerHandView];
            [self addCardToView:self.dealerHandView];
        }
        
        // 计算玩家牌的分值并判断
        int playerValue = [self calculateValueInView:self.playerHandView];
        [self judgeValue:playerValue of:kPlayer];
        
    }];
    
}


/**
 *  清空view里的牌
 */
- (void)removeCardsInView:(UIView *)view
{
    for (UIView *card in view.subviews) {
        [UIView animateWithDuration:0.5 animations:^{
            card.frame = CGRectMake(view.bounds.size.width, 0, kCardWidth, kCardHeight);
            card.alpha = 0.0;
        } completion:^(BOOL finished) {
            [card removeFromSuperview];
        }];
    }
}


/**
 *  使用一副新的牌 (重新设置self.deck)
 */
- (void)useNewDeck
{
    // 说明: 用数字(字符串)来代表每张牌. 一副牌有52张.
    // 1~13分别代表红桃A~K, 14~26代表方块A~K, 27~39代表黑桃A~K, 40~52代表梅花A~K
    
    self.deck = [NSMutableArray arrayWithCapacity:52];
    for (int i = 0; i < 52; i++) {
        self.deck[i] = [NSString stringWithFormat:@"%d", i+1];
    }
}


/**
 *  随机取出一张牌
 */
- (NSString *)drawCard
{
    // 获取一个随机数
    int index = arc4random_uniform((int)self.deck.count);
    // 获取牌
    NSString *card = self.deck[index];
    // 把牌从deck中移除
    [self.deck removeObjectAtIndex:index];
    // 返回这张随机牌
    return card;
}


/**
 *  给玩家或者庄家发一张牌
 *
 *  @param view 玩家或庄家的牌区 (self.playerHandView 或 self.dealerHandView)
 */
- (void)addCardToView:(UIView *)view
{
    // 取出一张牌
    NSString *card = [self drawCard];
    
    // 为这张牌创建一张图片 (如果是庄家的第一张牌, 把图片设置成牌背)
    UIImageView *cardView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kCardWidth, kCardHeight)];
    if (view.subviews.count == 0 && view == self.dealerHandView) {
        cardView.image = [UIImage imageNamed:@"cardback"];
    } else {
        cardView.image = [UIImage imageNamed:card];
    }
    
    // 把这张牌的图片添加到相应的view中
    cardView.tag = card.intValue;
    [view addSubview:cardView];
    
    // 重新安排这个view中牌的位置, 使用动画
    [UIView animateWithDuration:0.5 animations:^{
        [self arrangeCardsInView:view];
    } completion:^(BOOL finished) {
        return;
    }];
}


/**
 *  把指定view中的所有卡牌(子view)居中排列
 */
- (void)arrangeCardsInView:(UIView *)view
{
    int subviewsCount = (int)view.subviews.count;
    
    float leftMargin = (view.bounds.size.width - kCardWidth - (subviewsCount-1)*kCardDistance) * 0.5;
    
    for (int i = 0; i < subviewsCount; i++) {
        // 设置每个子view的位置
        float x = leftMargin + i * kCardDistance;
        CGRect newPosition = CGRectMake(x, 0, kCardWidth, kCardHeight);
        UIView *subV = view.subviews[i];
        subV.frame = newPosition;
    }
}


/**
 *  计算某个view中所有牌的分值之和, 并更新相应的label
 */
- (int)calculateValueInView:(UIView *)view
{
    // 记录A的个数
    int ace_count = 0;
    
    // 计算所有牌的分值
    int value = 0;

    for (UIView *card in view.subviews) {
        
        int card_point = card.tag % 13;
        
        if (card_point == 0 || card_point > 10) {
            // J, Q, K 的值是0
            card_point = 10;
        } else if (card_point == 1) {
            // 有一张A
            ace_count++;
        }
        
        value += card_point;
    }
    
    // 设置分值label
    UILabel *label = (view == self.playerHandView) ? self.playerHandValueLabel : self.dealerHandValueLabel;
    label.text = [NSString stringWithFormat:@"%d", value];
    
    // 根据A的数目调整label的显示
    for (int i = 0; i < ace_count; i++) {
        value += 10;
        if (value <= 21) {
            label.text = [label.text stringByAppendingFormat:@" | %d", value];
        } else {
            value -= 10;
            break;
        }
    }
    
    return value;
}


/**
 *  判断分值, 根据分值不同, 调用不同的方法
 *
 *  @param value    牌的分值
 *  @param isPlayer 玩家或庄家
 */
- (void)judgeValue:(int)value of:(BOOL)isPlayer
{
    // 对分值做判断
    if (value == kBlackjack) {              // 正好21
        [self blackjackWithWinner:isPlayer];
        
    } else if (value > kBlackjack) {        // 超过21
        [self bustedWithLoser:isPlayer];

    } else {                                // 小于21

        if (isPlayer) {
            // 如果是玩家的牌, 允许hit和stand
            self.hitButton.hidden = NO;
            self.standButton.hidden = NO;
            
        } else {
            // 如果是庄家的牌, 如果分值小于17, 就要继续发牌, 直到庄家牌的分值大于或等于17为止
            if (value < 17)
                [self hit:kDealer];
            else {
                // 比较玩家和庄家的分值
                int playerValue = [self calculateValueInView:self.playerHandView];
                if (playerValue > value) {
                    NSLog(@"Win!");
                    self.resultLabel.text = @"You won!";
                } else if (playerValue < value) {
                    NSLog(@"Lost!");
                    self.resultLabel.text = @"You lost!";
                } else {
                    NSLog(@"Pushed!");
                    self.resultLabel.text = @"Pushed!";
                }
                
                // 隐藏按钮
                self.hitButton.hidden = YES;
                self.standButton.hidden = YES;
                // 显示结果标签和deal按钮
                [UIView animateWithDuration:0.5 animations:^{
                    self.resultLabel.alpha = 1.0;
                }];
                [UIView animateWithDuration:1.0 animations:^{
                    self.dealButton.alpha = 1.0;
                }];
            }
        }
    }
}


// 21点
- (void)blackjackWithWinner:(BOOL)isPlayer
{
    // 根据玩家还是庄家赢, 显示不同的结果
    NSLog(@"%d - blackjack!", isPlayer);
    self.resultLabel.text = @"Blackjack!";
    
    // 隐藏按钮
    self.hitButton.hidden = YES;
    self.standButton.hidden = YES;
    
    // 显示结果标签和deal按钮
    [UIView animateWithDuration:0.5 animations:^{
        self.resultLabel.alpha = 1.0;
    }];
    [UIView animateWithDuration:1.0 animations:^{
        self.dealButton.alpha = 1.0;
    }];

}


// 超过了21点
- (void)bustedWithLoser:(BOOL)isPlayer
{
    NSLog(@"%d - busted!", isPlayer);
    self.resultLabel.text = @"Busted!";
    
    // 隐藏按钮
    self.hitButton.hidden = YES;
    self.standButton.hidden = YES;
    
    // 显示结果标签和deal按钮
    [UIView animateWithDuration:0.5 animations:^{
        self.resultLabel.alpha = 1.0;
    }];
    [UIView animateWithDuration:1.0 animations:^{
        self.dealButton.alpha = 1.0;
    }];
}


/**
 *  hit 按钮的监听方法 - 给玩家发牌
 */
- (void)hit
{
    [self hit:kPlayer];
}


/**
 *  给玩家或庄家发一张牌, 并判断当前的分值
 *
 *  @param isPlayer 玩家或庄家
 */
- (void)hit:(BOOL)isPlayer
{
    UIView *view = isPlayer ? self.playerHandView : self.dealerHandView;
    
    // 发一张牌
    [self addCardToView:view];
    
    // 计算分值并判断
    int value = [self calculateValueInView:view];
    [self judgeValue:value of:isPlayer];
}


/**
 *  玩家点击了stand按钮
 */
- (void)stand
{
    // 禁用hit和stand按钮
    self.hitButton.hidden = YES;
    self.standButton.hidden = YES;
    
    // 庄家把第一张牌翻过来
    UIImageView *firstCard = (UIImageView *)self.dealerHandView.subviews[0];
    firstCard.image = [UIImage imageNamed:[NSString stringWithFormat:@"%d", (int)firstCard.tag]];
    
    // 计算并判断庄家的分值
    int dealerValue = [self calculateValueInView:self.dealerHandView];
    [self judgeValue:dealerValue of:kDealer];
}

@end
