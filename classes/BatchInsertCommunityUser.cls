global class BatchInsertCommunityUser implements Database.Batchable<Contact>, Database.Stateful {
    
    global Integer startInt=10000;
        
    global Iterable<Contact> start(Database.BatchableContext info){ 
        return new ContactIterable();
    }     
    global void execute(Database.BatchableContext info, List<Contact> scope){
        insert scope;
        List<User> lstUser = new List<User>();
        Integer i=(startInt+1);
        for(Contact objCon : scope) {    
            User objUser = new User(
                ProfileID =  Label.Core_IPS_External_Customer_Profile_Id,
                UserName = objCon.FirstName + objCon.LastName + '@email.com',
                FirstName = objCon.FirstName,
                LastName = objCon.LastName,
                Email = objCon.Email,
                isActive = false,
                contactId = objCon.Id,
                Core_User_Country_Code__c = 'US',
                Alias = 'tct'+i, 
                EmailEncodingKey ='UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles'        
            );
            lstUser.add(objUser);
            i++;
        }
        insert lstUser;
        startInt += lstUser.size();
    }     
    global void finish(Database.BatchableContext info){     
    } 
}