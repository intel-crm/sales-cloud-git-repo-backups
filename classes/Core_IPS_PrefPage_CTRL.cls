public without sharing  class Core_IPS_PrefPage_CTRL {
    
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
        Usr = [Select id, Name, ContactId,Contact.Name, TimeZoneSidKey from User where id=:UserInfo.getUserId()];
        return  Usr;    
    }
    
    @Auraenabled(cacheable=true)
    public static List<Contact> Core_IPS_CommEmailOptController(){
        EmailOptOut = false;
        SelectedChoice = new List<String>();
        
        Usr = [Select id, Name, ContactId,Contact.Name, TimeZoneSidKey from User where id=:UserInfo.getUserId()];
        
        contactInContext = [Select id, Name,Core_IPS_Email_Opt_Out__c,Core_MINDS__c,Core_Country_Region__c  from Contact where id=: Usr.Contactid];
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
        return  contactInContext;    
    }
    
    @Auraenabled
    public static void SubmitChoice(String countryValue,Boolean radioCheckbox,Boolean EmailOpt,String timeZoneValue){
        
        List<Contact>  userContact = new List<Contact>();   
        List<User>  Users = new List<User>();    
        List<user> usrRecord = [SELECT Id,TimeZoneSidKey, ContactId FROM User where id =:UserInfo.getUserId()   ];
        
        userContact = [SELECT Id,Name,AccountId,Account.Name,Core_IPS_Email_Opt_Out__c,Core_MINDS__c,Core_Country_Region__c From Contact where id =:usrRecord[0].ContactId  ]; 
        
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
        
        Users=[SELECT Id,TimeZoneSidKey,Username,LastName,Email,Alias,LocaleSidKey,EmailEncodingKey,ProfileId,LanguageLocaleKey FROM User where id =:UserInfo.getUserId()];
        User us = new User(
            Id=Users[0].Id,
            Username=Users[0].Username,
            LastName=Users[0].LastName,
            Email=Users[0].Email,
            Alias=Users[0].Alias,
            EmailEncodingKey=Users[0].EmailEncodingKey,
            ProfileId=Users[0].ProfileId,
            LanguageLocaleKey=Users[0].LanguageLocaleKey,
            TimeZoneSidKey=timeZoneValue
        );
        update us;
        upsert con;
    } 
}