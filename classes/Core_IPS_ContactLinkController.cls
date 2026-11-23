public class Core_IPS_ContactLinkController
{    
       
    public static list<Contact> con{set;get;}
    
    public Core_IPS_ContactLinkController(){
       showActiveUsers(); 
    }
       
    public void showActiveUsers()
    {       
        
         //'0053F000000RP8A' 
         //:userinfo.getuserid()
         Map<Id,Contact> conMap = NEW Map<Id,Contact>([Select id , AccountId From Contact WHERE AccountId IN (Select AccountId FROM User WHERE Id =:userinfo.getuserid())]);
           List<User> userList = [Select Id , ContactId FROM User WHERE ContactId IN: conMap.Keyset() ];
              Set<id> contactsIds = NEW Set<id>();
              for(User u : userList){
                  contactsIds.add(u.ContactId);
              }
         con=[SELECT Id,FirstName,LastName,Email FROM Contact WHERE ( AccountID In (SELECT AccountID FROM User WHERE id=:userinfo.getuserid()) AND
                                              Id IN:contactsIds 
                                             and (Core_IPS_Active__c=true)) ];
    }   
  }