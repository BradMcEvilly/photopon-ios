//
//  AddFriendController.m
//  Photopon
//
//  Created by Hayk Hayotsyan on 15/8/15.
//  Copyright (c) 2015 Photopon. All rights reserved.
//

@import Contacts;
#import "AddFriendController.h"
#import "Parse/Parse.h"
#import "LogHelper.h"
#import "DBAccess.h"

@implementation AddFriendController 
{
    NSMutableArray *friendSuggestions;
    NSMutableArray *myContacts;
    NSTimer *timer;
}



- (void)getSuggestions
{
    
    LogDebug(@"Get suggestions");

    NSString* searchText = self.userSearchBar.text;
    
    GetSearchSuggestions(searchText, ^(NSArray *results, NSError *error) {
        [friendSuggestions removeAllObjects];
        
        for (PFUser* object in results) {

            NSString* username = [object valueForKey:@"username"];
            NSString* email = [object valueForKey:@"email"];
            
            [friendSuggestions addObject:@{
               @"name": username,
               @"email": email,
               @"user": object,
               @"fromServer": @YES
            }];
        }
        
        
        for (NSDictionary* contact in myContacts) {
            NSString* name = [contact valueForKey:@"name"];
            NSString* email = [contact valueForKey:@"email"];
            NSString* phone = [contact valueForKey:@"phone"];

            if ( ([name rangeOfString:searchText].location != NSNotFound) || ([email rangeOfString:searchText].location != NSNotFound) ) {
                
                [friendSuggestions addObject:@{
                   @"name": [NSString stringWithFormat:@"%@ %@", name, phone],
                   @"email": email,
                   @"user": phone,
                   @"fromServer": @NO
                }];
            }
        }
        
        
        [self.searchResultTable reloadData];
        
    });
}

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText
{
    LogDebug(searchText);
    if (timer) {
        [timer invalidate];
    }
    
    if ([searchText length] == 0) {
        [friendSuggestions removeAllObjects];
        [self.searchResultTable reloadData];
        return;
    }

    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(getSuggestions) userInfo:nil repeats:NO];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.userSearchBar setDelegate:self];
    [self.searchResultTable setDelegate:self];
    [self.searchResultTable setDataSource:self];
    
    friendSuggestions = [NSMutableArray array];
    myContacts = [NSMutableArray array];
    
    
    CNContactStore *store = [[CNContactStore alloc] init];
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (!granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No permission"
                                                                message:@"I need your permission to be able to add friends from your contact list"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:nil];
                [alert show];

            });
            return;
        }
        
        NSMutableArray *contacts = [NSMutableArray array];
        
        NSError *fetchError;
        CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:@[CNContactIdentifierKey, CNContactEmailAddressesKey, CNContactPhoneNumbersKey, [CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName]]];
        
        BOOL success = [store enumerateContactsWithFetchRequest:request error:&fetchError usingBlock:^(CNContact *contact, BOOL *stop) {
            [contacts addObject:contact];
        }];
        if (!success) {
            NSLog(@"error = %@", fetchError);
        }
        
        CNContactFormatter *formatter = [[CNContactFormatter alloc] init];
        
        for (CNContact *contact in contacts) {
            NSString* name = [formatter stringFromContact:contact];
            NSArray* emails = [contact emailAddresses];
            
            for (CNLabeledValue<NSString*>* email in emails) {
                
                
                for (CNLabeledValue<CNPhoneNumber*>* phone in contact.phoneNumbers) {
                    
                    
                    [myContacts addObject:@{
                        @"name": name,
                        @"email": email.value,
                        @"phone": phone.value.stringValue
                    }];
                }

            }
        }
    }];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [friendSuggestions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FriendSuggestionsCellIdentifier"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FriendSuggestionsCellIdentifier"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];
        CGRect frame = CGRectMake(0.0, 0.0, 20, 20);
        button.frame = frame;
        
        [button addTarget:self action:@selector(checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        cell.accessoryView = button;
        
    }
    
    NSDictionary *item = (NSDictionary *)[friendSuggestions objectAtIndex:indexPath.row];
    cell.textLabel.text = [item objectForKey:@"name"];
    cell.detailTextLabel.text = [item objectForKey:@"email"];
    
    if ([item objectForKey:@"fromServer"] == @YES) {
        UIImage *theImage = [UIImage imageNamed:@"photopon-user.png"];
        cell.imageView.image = theImage;
    } else {
        UIImage *theImage = [UIImage imageNamed:@"contact-user.png"];
        cell.imageView.image = theImage;
    }
    return cell;
}

- (void)checkButtonTapped:(id)sender event:(id)event
{
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentTouchPosition = [touch locationInView:self.searchResultTable];
    NSIndexPath *indexPath = [self.searchResultTable indexPathForRowAtPoint: currentTouchPosition];
    if (indexPath != nil)
    {
        [self tableView: self.searchResultTable accessoryButtonTappedForRowWithIndexPath: indexPath];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    LogDebug([NSString stringWithFormat:@"%ld", indexPath.row ]);
    
    NSMutableDictionary *item = [friendSuggestions objectAtIndex:indexPath.row];
    
    PFUser* suggestedUser = [item objectForKey:@"user"];
    PFUser* thisUser = [PFUser currentUser];
    
    PFObject *friendRequest = [PFObject objectWithClassName:@"FriendRequests"];
    
    friendRequest[@"to"] = suggestedUser;
    friendRequest[@"from"] = thisUser;
    
    [friendRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [friendSuggestions removeObjectAtIndex:indexPath.row];
            [self.searchResultTable reloadData];
            CreateFriendRequestNotification(suggestedUser);
        } else {
            //TODO: There was a problem, check error.description
        }
    }];
    
}


@end
