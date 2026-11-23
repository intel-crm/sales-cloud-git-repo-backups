public class SudhirDataSetup {
    
    public static void createCommunityUsers(String fn,String Ln,  Integer contCnt, Integer commUsers,  String contFname, String conLName){

        //String Ln = 'SKSep21';
        //String fn = 'Acct1 ';
        String temp = '';
        
        Account acct = new Account();
        acct.Name = fn+' '+Ln;
        acct.RecordTypeId  = [SELECT Id ,Name, DeveloperName FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Mastered_Account'].ID;
        acct.Core_Account_Type__c  = 'Distributor';
        acct.Core_CNDA_Number__c =  '123123';
        acct.Core_Sales_Group__c  = 'Global Accounts';
        acct.Industry = 'Agriculture';
        acct.Core_CIM_ID__c ='268234';
        acct.BillingStreet = '123 '+temp+' Street'; 
        acct.BillingCity = 'Rochester';
        acct.BillingPostalCode = '12456';
        acct.BillingState = 'NY';
        acct.BillingCountry = 'USA';
        
        if(temp.contains('NonODM')){
            acct.Core_IsODM__c = false;    
        }else{
            acct.Core_IsODM__c = true;
        }
        insert acct;
        System.debug('+++++++++++++++++++ Account Id '+acct.id);
        List<Contact> cl = new List<Contact>();
        //UserLicense ul = [Select u.SystemModstamp, u.Name, u.LicenseDefinitionKey, u.Id From UserLicense u where Name ='Custom Community Plus'];
        
        
        
        for(Integer i=0; i< contCnt;i++){
            
            Contact c = new Contact();
            c.RecordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Core_Intel_Contact'].Id;
            c.LastName = conLName;
            c.FirstName = contFname+String.valueOf(i);
            //c.email = c.LastName+'Cont'+String.valueOf(i)+'@test'+Ln.replaceAll('_','').replaceAll(' ','')+fn.replaceAll('_','').replaceAll(' ','')+'.com';
            c.email = fn+Ln+String.valueOf(i)+'@'+Ln+'.com';
            c.Core_IPS_Active__c = true;
            c.Core_IPS_Intel_Support_Owner__c  = [Select Id FROM User where Name = 'Sudhir Kathula'].Id;
            c.AccountId = acct.Id;
            cl.add(c);
            
            
            
        }
        insert cl;
        
        Profile p = [Select Id, Name from Profile where Name ='IPS External Customer' ];
        
        List<User> usrList = new List<User>();
        Integer i=0;
        for(Contact c: cl){
            User u = new User();
            u.FirstName = c.FirstName;
            u.LastName = c.LastName;
            u.ContactId = c.Id;
            u.Username = 'u'+c.Email;
            u.Email = c.Email;
            u.CommunityNickname = String.valueOf(system.now().hour())+String.valueOf(system.now().minute())+String.valueOf(i);
            u.Alias = '';
            u.TimeZoneSidKey = 'America/Phoenix'; // Required
            u.LocaleSidKey = 'en_US'; // Required
            u.EmailEncodingKey = 'ISO-8859-1'; // Required
            u.LanguageLocaleKey = 'en_US'; // Required
            u.ProfileId = p.Id;

            String tmp = String.ValueOf(i)+c.FirstName;
            u.Alias = (tmp.length() >6 ? tmp.substring(0, 6) : tmp);
            usrList.add(u);
            i+=1;
            if(i<=commUsers)
                break;
        }
        insert usrList;
        
        
    }
    
    
    public static void enablePortal(String aid, Integer commUsers){
        Account acct = [Select Id, Name from Account where id=:aid];
        Profile p = [Select Id, Name from Profile where Name ='IPS External Customer' ];
        UserRole ur = [Select Id, Name from UserRole where Name =: acct.Name+' Customer User'];
        UserLicense ul = [SELECT Id, Name FROM UserLicense where Name = 'Customer Community Plus'];
        List<Contact> cl = [Select FirstName, LastName, Email, Id 
                                  FROM Contact where AccountId =: aid 
                                  AND ID NOT IN (Select ContactId FROM User WHERE  Contact.AccountId =:aid )];
        System.debug(' ur '+ur);
        System.debug(' contList '+cl.size());
        List<User> usrList = new List<User>();
        Integer i=100;
        Integer totCommUser = i+commUsers; 
        for(Contact c: cl){
            User u = new User();
            u.FirstName = c.FirstName;
            u.LastName = c.LastName;
            u.ContactId = c.Id;
            u.Username = 'u'+c.Email;
            u.Email = c.Email;
            u.CommunityNickname = String.valueOf(system.now().hour())+String.valueOf(system.now().minute())+String.valueOf(i);
            u.Alias = '';
            u.TimeZoneSidKey = 'America/Phoenix'; // Required
            u.LocaleSidKey = 'en_US'; // Required
            u.EmailEncodingKey = 'ISO-8859-1'; // Required
            u.LanguageLocaleKey = 'en_US'; // Required
            u.ProfileId = p.Id;
            u.UserRoleId = ur.Id;
            String tmp = String.ValueOf(i)+c.FirstName;
            u.Alias = (tmp.length() >7 ? tmp.substring(0, 7) : tmp);
            
            usrList.add(u);
            i+=1;
            if(i>totCommUser)
                break;
        }
        System.debug(' usrList '+usrList.size());
        insert usrList;
        
    }
    
    public static void disablePortal(String aid){
        Set<Id> cids = new  Set<Id>();
        for(Contact c : [Select Id FROM contact where AccountId =:aid] )
            cids.add(c.Id);
        
        List<User> ul = [Select Id, Name, isPortalEnabled from User where contactId IN : cids];
        for(User u:ul)
            u.isPortalEnabled = false;
        update ul;
        
        deleteAccount(aid);
    }
    
    @future
    public static void deleteAccount(String aid){
        deleteAccounts(aid);
    }
    
    
    public static void deleteAccounts(String aid){
        
        /*
        Delete [Select Id From Asset where Core_IPS_Project__c  IN (select  Core_IPS_Project__c  FROM Core_IPS_Account__c  where Core_Account__c  =:aid) AND AccountId = Null ];
        
        List<Core_IPS_Product__c> ipl =  [Select Id, Core_IPS_Product_Status__c ,Status__c  FROM Core_IPS_Product__c where Status__c ='Submitted' AND Core_IPS_Project__c  IN (select  Core_IPS_Project__c  FROM Core_IPS_Account__c  where Core_Account__c  =:aid)];
        for(Core_IPS_Product__c ip :ipl){
            ip.Status__c ='Approved';
            ip.Core_IPS_Product_Status__c = 'InActive';
        }
            
        update ipl; */
        List<Core_IPS_Project__c> ipsProjList = [Select Id, Core_Status__c  FROM Core_IPS_Project__c where ID IN (select  Core_IPS_Project__c  FROM Core_IPS_Account__c  where Core_Account__c  =:aid) ];
        for(Core_IPS_Project__c ip: ipsProjList)
            ip.Core_Status__c = 'InActive';
        update ipsProjList;
        
        //delete [Select Id FROM Core_IPS_Project__c where ID IN (select  Core_IPS_Project__c  FROM Core_IPS_Account__c  where Core_Account__c  =:aid) ];
        delete [select Id FROM contact where AccountId =:aid];
        delete [select Id, Name from Entitlement where Accountid  =:aid];
        delete [select Id from account where id  =:aid];
    }
    
}