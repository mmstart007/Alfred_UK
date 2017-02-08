

#import <UIKit/UIKit.h>
#import "AddBalanceView.h"
@interface WalletViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, AddBalanceDelegate>

@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UIButton *addBalance;
@property (weak, nonatomic) IBOutlet UITableView *cardsTableView;

@end
