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
#import "Helper.h"

@implementation AddFriendController 
{
    PFUser* currentSuggestion;
    BOOL currentSuggestionAdded;
    BOOL currentSuggestionIsAlreadyFriend;
    
    NSMutableArray<NSMutableDictionary*> *myFriends;
    NSMutableArray<NSMutableDictionary*> *myContacts;
    
    
    NSMutableArray<NSMutableDictionary*> *allContacts;
    
    NSTimer *timer;
}



- (void)getSuggestions
{
    NSString* searchText = self.userSearchBar.text;
    
    GetSearchSuggestion(searchText, ^(PFUser *suggestion, NSArray* allFriends) {
        [self clearSuggestions];
        currentSuggestionIsAlreadyFriend = FALSE;
        currentSuggestion = suggestion;
       
        
        for (PFObject* friendship in allFriends) {
            PFUser* friend = [friendship valueForKey:@"user2"];

            if (friend) {
                NSString* name = [friend valueForKey:@"username"];
                NSString* email = [friend valueForKey:@"email"];
                
                if ([name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    [myFriends addObject:[@{
                         @"name": name,
                         @"email": email,
                         @"object": friend
                     } mutableCopy]];
                    
                    
                    if ([friend objectId] == [currentSuggestion objectId]) {
                        currentSuggestion = nil;
                        currentSuggestionAdded = FALSE;
                        currentSuggestionIsAlreadyFriend = TRUE;
                    }
                }
            }
        }
        
        
        
        for (NSDictionary* contact in allContacts) {
            NSString* name = [contact valueForKey:@"name"];
            NSString* phone = [contact valueForKey:@"phone"];
            NSString* cleanPhone = NumbersFromFormattedPhone(phone);


            if ([name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                
                NSMutableDictionary* entry = [@{
                    @"name": name,
                    @"phone": phone
                } mutableCopy];
                
                for (PFObject* friendship in allFriends) {
                    NSString* phoneId = [friendship valueForKey:@"phoneId"];
                    
                    if (phoneId && [phoneId isEqualToString:cleanPhone]) {
                        entry[@"justAddedFriend"] = @TRUE;
                        break;
                    }
                    
                }
                
                [myContacts addObject:entry];
            }
        }
        
        
        [self.searchResultTable reloadData];
        
    });
}

-(void) clearSuggestions {
    [myFriends removeAllObjects];
    [myContacts removeAllObjects];
    currentSuggestion = nil;
    currentSuggestionAdded = FALSE;
}


- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText
{
    if (timer) {
        [timer invalidate];
    }
    
    if ([searchText length] == 0) {
        [self clearSuggestions];
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
    
    myFriends = [NSMutableArray array];
    myContacts = [NSMutableArray array];
    allContacts = [NSMutableArray array];
    
    
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

            
            
            for (CNLabeledValue<CNPhoneNumber*>* phone in contact.phoneNumbers) {
                
                
                [allContacts addObject:[@{
                    @"name": name,
                    @"phone": phone.value.stringValue
                } mutableCopy]];
            }

        
        }
    }];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
   
    if ((section == 0) && ([self.userSearchBar.text length] != 0) && (!currentSuggestionIsAlreadyFriend)) {
        return @"Photopon users";
    }
    
    if ((section == 1) && ([myFriends count] != 0)) {
        return @"My Friends";
    }
    
    if ((section == 2) && ([myContacts count] != 0)) {
        return @"Users from Address Book";
    }
    return NULL;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (([self.userSearchBar.text length] == 0) || (currentSuggestionIsAlreadyFriend)) {
            return 0;
        }
        return 1;
    }
    
    if (section == 1) {
        return [myFriends count];
    }
    
    if (section == 2) {
        return [myContacts count];
    }
    return 0;
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger itemIndex = indexPath.item;
    NSInteger sectionIndex = indexPath.section;
    
    NSLog(@"%ld", (long)itemIndex);
    
    //NSDictionary *item = (NSDictionary *)[friendSuggestions objectAtIndex:dataIndex];
    
    
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
    
    UITableViewCell *cellAdded = [tableView dequeueReusableCellWithIdentifier:@"FriendSuggestionsCellIdentifierAdded"];
    if (cellAdded == nil) {
        cellAdded = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FriendSuggestionsCellIdentifierAdded"];
        cellAdded.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        CGRect frame = CGRectMake(0.0, 0.0, 20, 20);
        button.frame = frame;
        
        UIImage * buttonImage = [UIImage imageNamed:@"check.png"];

        [button setImage:buttonImage forState:UIControlStateNormal];
        
        [button addTarget:self action:@selector(checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        cellAdded.accessoryView = button;
        
    }

    
    UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:@"FriendSuggestionsCellIdentifier1"];
    if (cell1 == nil) {
        cell1 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FriendSuggestionsCellIdentifier1"];
        cell1.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    
    UIImage *theUserImage = [UIImage imageNamed:@"photopon-user.png"];
    UIImage *theContactImage = [UIImage imageNamed:@"contact-user.png"];
    PFUser* currentUser = [PFUser currentUser];

    if (sectionIndex == 0) {
        if (currentSuggestion) {
            
            if ([ [currentSuggestion objectId] isEqualToString:[currentUser objectId]]) {
                cell1.textLabel.text = [NSString stringWithFormat: @"%@ (me)", [currentSuggestion objectForKey:@"username"]];
                cell1.detailTextLabel.text = @"";
                cell1.imageView.image = theUserImage;
                return cell1;
            }
            
            if (currentSuggestionAdded) {
                cellAdded.textLabel.text = [currentSuggestion objectForKey:@"username"];
                cellAdded.detailTextLabel.text = @"is your friend now!";
                cellAdded.imageView.image = theUserImage;
                return cellAdded;
            }
            
            cell.textLabel.text = [currentSuggestion objectForKey:@"username"];
            cell.detailTextLabel.text = @"";
            cell.imageView.image = theUserImage;
            return cell;
        }
        
        cell1.textLabel.text = self.userSearchBar.text;
        cell1.detailTextLabel.text = @"";
        cell1.imageView.image = theUserImage;
        return cell1;
    }
    
    
    if (sectionIndex == 1) {
        NSDictionary *item = (NSDictionary *)[myFriends objectAtIndex:itemIndex];
        
        if ([[item objectForKey:@"removedFromFriend"] boolValue]) {
            cell.textLabel.text = [item objectForKey:@"name"];
            cell.detailTextLabel.text = @"removed from friend list";
            cell.imageView.image = theUserImage;
            return cell;
        }
        
        cellAdded.textLabel.text = [item objectForKey:@"name"];
        cellAdded.detailTextLabel.text = [item objectForKey:@"email"];
        cellAdded.imageView.image = theUserImage;
        return cellAdded;
    }

    
    if (sectionIndex == 2) {
        NSDictionary *item = (NSDictionary *)[myContacts objectAtIndex:itemIndex];
        
        if ([[item objectForKey:@"justAddedFriend"] boolValue]) {
            cellAdded.textLabel.text = [item objectForKey:@"name"];
            cellAdded.detailTextLabel.text = @"is your friend!";
            cellAdded.imageView.image = theContactImage;
            return cellAdded;
        }
        
        cell.textLabel.text = [item objectForKey:@"name"];
        cell.detailTextLabel.text = [item objectForKey:@"phone"];
        cell.imageView.image = theContactImage;
        return cell;
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



-(void) addFriend: (PFUser*)userToAdd {
    PFUser* thisUser = [PFUser currentUser];

    PFObject *friendObject = [PFObject objectWithClassName:@"Friends"];
    
    PFACL *acl = [PFACL ACL];
    [acl setPublicReadAccess:true];
    [acl setWriteAccess:true forUser:[PFUser currentUser]];
    [friendObject setACL:acl];
    
    friendObject[@"user1"] = thisUser;
    friendObject[@"user2"] = userToAdd;
    
    
    [friendObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.searchResultTable reloadData];
            CreateFriendRequestNotification(userToAdd);
        } else {
            //TODO: There was a problem, check error.description
        }
    }];

}

-(void) removeFriend: (PFUser*)userToRemove {
    PFUser* thisUser = [PFUser currentUser];

    PFQuery *query = [PFQuery queryWithClassName:@"Friends"];
    
    [query whereKey:@"user1" equalTo:thisUser];
    [query whereKey:@"user2" equalTo:userToRemove];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *result, NSError *error) {
        [result deleteInBackground];
        [self.searchResultTable reloadData];
    }];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{

    NSInteger itemIndex = indexPath.item;
    NSInteger section = indexPath.section;
    
    if (section == 0) {
        if (currentSuggestionAdded) {
            currentSuggestionAdded = FALSE;
            [self removeFriend:currentSuggestion];
        } else {
            currentSuggestionAdded = TRUE;
            [self addFriend:currentSuggestion];
        }
    }
    
    if (section == 1) {
        NSMutableDictionary *item = [myFriends objectAtIndex:itemIndex];
        if ([[item objectForKey:@"removedFromFriend"] boolValue]) {
            [item setObject:@FALSE forKey:@"removedFromFriend"];
            [self addFriend:item[@"object"]];
        } else {
            [item setObject:@TRUE forKey:@"removedFromFriend"];
            [self removeFriend:item[@"object"]];
        }

    }
    
    if (section == 2) {
        NSMutableDictionary *item = [myContacts objectAtIndex:itemIndex];
        NSString* phone = [item valueForKey:@"phone"];
        NSString* cleanPhone = NumbersFromFormattedPhone(phone);
        
        GetUserByPhone(cleanPhone, ^(PFUser *user, NSArray* dummy) {
            PFUser* thisUser = [PFUser currentUser];

            if (!user) {
                
                if ([[item objectForKey:@"justAddedFriend"] boolValue]) {
                    
                    [item setObject:@FALSE forKey:@"justAddedFriend"];

                    PFQuery *query = [PFQuery queryWithClassName:@"Friends"];
                    
                    [query whereKey:@"user1" equalTo:thisUser];
                    [query whereKey:@"phoneId" equalTo:cleanPhone];
                    
                    [query getFirstObjectInBackgroundWithBlock:^(PFObject *result, NSError *error) {
                        [result deleteInBackground];
                        [self.searchResultTable reloadData];
                    }];

                } else {
                    [item setObject:@TRUE forKey:@"justAddedFriend"];
                    
                    PFObject *friendObject = [PFObject objectWithClassName:@"Friends"];
                    
                    PFACL *acl = [PFACL ACL];
                    [acl setPublicReadAccess:true];
                    [acl setWriteAccess:true forUser:[PFUser currentUser]];
                    [friendObject setACL:acl];
                    
                    friendObject[@"user1"] = thisUser;
                    friendObject[@"phone"] = phone;
                    friendObject[@"phoneId"] = cleanPhone;
                    friendObject[@"name"] = item[@"name"];
                    
                    [friendObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [self.searchResultTable reloadData];
                    }];
                }
            
            
            } else {
        
                if ([[item objectForKey:@"justAddedFriend"] boolValue]) {
                    [item setObject:@FALSE forKey:@"justAddedFriend"];
                    [self removeFriend:user];
                } else {
                    [item setObject:@TRUE forKey:@"justAddedFriend"];
                    [self addFriend:user];
                }
            }
        });
    }

}


@end
