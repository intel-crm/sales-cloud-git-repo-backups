public with sharing  class Core_IPS_PrefPage_CTRL {// Changed by tushar because for vanuability changes
    
    @Auraenabled public static  User Usr{get;set;}
    @Auraenabled  public static Boolean EmailOptOut{get;set;}
    @Auraenabled  public static Boolean EmailOptIn{get;set;}
    @Auraenabled  public static Boolean Checkbox{get;set;}
    public static  List<Contact> contactInContext = new list<Contact>();
    @Auraenabled  public static String statusMessage{get;set;}
    @Auraenabled  public static List<String> SelectedChoice{get;set;}
    @Auraenabled  public static List<SelectOption> options{get;set;}
    
    @Auraenabled  public static String selectedCountry{get;set;}
    @Auraenabled public static Boolean radioCheckbox{get;set;}
    @Auraenabled(cacheable=true)
    public static User gettimezone(){
        // Venrublity Fix - Refering query to service class
        // Usr = [Select id, Name, ContactId,Contact.Name, TimeZoneSidKey from User where id=:UserInfo.getUserId()];
        List<User> userList = (List<User>) Core_IPS_QueryService.queryRecords(
            'Select id, Name, ContactId,Contact.Name, TimeZoneSidKey from User where id = :userId',
            new Map<String, Object>{ 'userId' => UserInfo.getUserId() }
        );
        if(!userList.isEmpty()){
            Usr = userList[0];
        }
        return  Usr;    
    }
    
    @Auraenabled(cacheable=true)
    public static List<Contact> Core_IPS_CommEmailOptController(){
        EmailOptOut = false;
        SelectedChoice = new List<String>();
        
        // Venrublity Fix - Refering query to service class
        // Usr = [Select id, Name, ContactId,Contact.Name, TimeZoneSidKey from User where id=:UserInfo.getUserId()];
        List<User> userList = (List<User>) Core_IPS_QueryService.queryRecords(
            'Select id, Name, ContactId,Contact.Name, TimeZoneSidKey from User where id = :userId',
            new Map<String, Object>{ 'userId' => UserInfo.getUserId() }
        );
        if(!userList.isEmpty()){
            Usr = userList[0];
        }
        
        // Venrublity Fix - Refering query to service class
        // contactInContext = [Select id, Name,Core_IPS_Email_Opt_Out__c,Core_MINDS__c,Core_Country_Region__c  from Contact where id=: Usr.Contactid];
        contactInContext = (List<Contact>) Core_IPS_QueryService.queryRecords(
            'Select id, Name,Core_IPS_Email_Opt_Out__c,Core_MINDS__c,Core_Country_Region__c from Contact where id = :contactId',
            new Map<String, Object>{ 'contactId' => Usr.Contactid }
        );
        if(contactInContext.size()>0)
        {
            selectedCountry = contactInContext[0].Core_Country_Region__c ;
            radioCheckbox = contactInContext[0].Core_MINDS__c;
            
            if(contactInContext[0].Core_IPS_Email_Opt_Out__c == true )
                EmailOptOut = true;
            else
                EmailOptIn = true;
            options = new List<SelectOption>();
            if(EmailOptOut == true)
                options.add(new SelectOption('OptIn', System.Label.Core_IPS_OptIn));
            if(EmailOptIn == true)
                options.add(new SelectOption('OptOut', System.Label.Core_IPS_OptOut));
        } // TWC745-9175 - Exceptional Handling - Phani End If Condition
        return  contactInContext;    
    }
    
    @Auraenabled
    public static void SubmitChoice(String countryValue,Boolean radioCheckbox,Boolean EmailOpt,String timeZoneValue){
        
        List<Contact>  userContact = new List<Contact>();   
        List<User>  users = new List<User>();    
        // Venrublity Fix - Refering query to service class
        List<user> usrRecord = [SELECT Id,TimeZoneSidKey, ContactId FROM User where id =:UserInfo.getUserId()   ];     
        // Venrublity Fix - Refering query to service class
        // userContact = [SELECT Id,Name,AccountId,Account.Name,Core_IPS_Email_Opt_Out__c,Core_MINDS__c,Core_Country_Region__c From Contact where id =:usrRecord[0].ContactId  ]; 
        userContact = (List<Contact>) Core_IPS_QueryService.queryRecords(
            'SELECT Id,Name,AccountId,Account.Name,Core_IPS_Email_Opt_Out__c,Core_MINDS__c,Core_Country_Region__c From Contact where id = :contactId',
            new Map<String, Object>{ 'contactId' => usrRecord[0].ContactId }
        );
        
        Contact con = new Contact();
        con.Id=userContact[0].Id;
        // Fixes add on 14/07/2022 -Suresh-// 
        if (Schema.sObjectType.Contact.fields.Core_Country_Region__c.isCreateable()||Schema.sObjectType.Contact.fields.Core_Country_Region__c.isUpdateable()) {
            con.Core_Country_Region__c=countryValue;  
        }
        // Fixes add on 14/07/2022 -Suresh-//
        if (Schema.sObjectType.Contact.fields.Core_MINDS__c.isCreateable()||Schema.sObjectType.Contact.fields.Core_MINDS__c.isUpdateable()) 
        {
            con.Core_MINDS__c=radioCheckbox; 
        }
        // Fixes add on 14/07/2022 -Suresh-//
        con.Core_IPS_Email_Opt_Out__c=EmailOpt;   
        
        // Venrublity Fix - Refering query to service class
        users=[SELECT Id,TimeZoneSidKey,Username,LastName,Email,Alias,LocaleSidKey,EmailEncodingKey,ProfileId,LanguageLocaleKey FROM User where id =:UserInfo.getUserId()];
        User us = new User(
            Id=users[0].Id,
            Username=users[0].Username,
            LastName=users[0].LastName,
            Email=users[0].Email,
            Alias=users[0].Alias,
            EmailEncodingKey=users[0].EmailEncodingKey,
            ProfileId=users[0].ProfileId,
            LanguageLocaleKey=users[0].LanguageLocaleKey,
            TimeZoneSidKey=timeZoneValue
        );
        // Venrublity Fix - Refering query to service class
        // update us;
        List<SObject> updatedUsers = Core_IPS_QueryService.updateRecords(new List<SObject>{ us });
        if(!updatedUsers.isEmpty()){
            us = (User)updatedUsers[0];
        }
        // Venrublity Fix - Refering query to service class
        // upsert con;
        List<SObject> upsertedContacts = Core_IPS_QueryService.upsertRecords(new List<SObject>{ con });
        if(!upsertedContacts.isEmpty()){
            con = (Contact)upsertedContacts[0];
        }
    } 
}