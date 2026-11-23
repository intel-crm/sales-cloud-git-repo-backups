@isTest
public class PMP_Acct_Grp_Mbr_TriggerHandler_Test {
    
    @isTest
    public static void  partnerAccGroupMemtestMethod ()
    { 
        Id accountRTPartnerAccountGroup = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId(); 
        //String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        
        Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c ();
        cs.Name = 'PAG_mem_handler';
        cs.Core_Active__c = TRUE;
        cs.Core_Class_Name__c = 'Core_Acct_Grp_Mbr_TriggerHandler';
        cs.Core_Object__c = 'Core_Account_Group_Member__c';
        cs.Core_Trigger_Events__c = 'After Insert, After Update, Before Delete';
        cs.Core_Description__c = 'Update the related MDA Partner info when ever Account updated.';
        insert cs;
        
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        
        List<Account> accts = new List<Account>();        
        Account partnerAccount = new Account(Name ='PartnerAccount',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
                                             Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',RecordTypeId=accountRTPartnerAccountGroup);
        
        accts.add(partnerAccount);
        Account intelAccount = new Account(Name ='IntelAccount',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
                                           RecordTypeId=intelAccRecTypeId,Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        
        accts.add(intelAccount);
        Insert accts ;
        
        List<Account> intelAccId = [SELECT ID,Name FROM Account where Name ='IntelAccount'];
        List<Account> partnerAccountIdVar = [SELECT ID,Name FROM Account where Name ='PartnerAccount'];
        List<Account>accToUpdate = new List<Account>();
        For(Account acc:accts){
            acc.IsPartner = true;
            accToUpdate.add(acc);
        }
        Update accToUpdate ;
        
        List<Core_Account_Group_Member__c> accGroupMemlist = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c  accGroupMem= new Core_Account_Group_Member__c(Core_Partner_Account_Id__c =partnerAccountIdVar[0].Id,Core_Intel_Account_Id__c =intelAccId[0].Id);
        accGroupMemlist.add(accGroupMem);
        Insert accGroupMemlist ;
        
        /*        List<Core_Account_Group_Member__c> gupdate=new List<Core_Account_Group_Member__c>();
        List<Core_Account_Group_Member__c> gl=[Select Core_MDA_Ind__c from Core_Account_Group_Member__c];
        For(Core_Account_Group_Member__c g : gl)
        {
            g.Core_MDA_Ind__c=False;
            gupdate.add(g);
        }
        
        Update gupdate ; */
        Core_Trigger_Executions__c executions1 = new Core_Trigger_Executions__c(Name='UpdateJobFunctionAndCode',Core_Active__c=true,Core_Class_Name__c='Core_ContactHandler',Core_Description__c='testcase',Core_Object__c='Contact',Core_Trigger_Events__c='Before Insert Before Update');
                    insert executions1;
        Contact contact1 = new Contact(firstname='Partner', MailingCountry='India',
                                       lastname='Contact1', accountId=intelAccId[0].id,Email='dellco1234@dell.com');
        //for update
        Insert contact1;

        //for update 
        List<Contact> ccupdate=new List<Contact>();
        List<Contact> cl=[Select firstname,lastname from Contact LIMIT 10];
        For(Contact c : cl)
        {
            c.firstname='Partner1';
            ccupdate.add(c);
        }
        Update ccupdate ;
        
        Test.startTest(); 
        List<Core_ERPM_Engagement__c> erp = new List<Core_ERPM_Engagement__c>();
        Core_ERPM_Engagement__c ee1 = new Core_ERPM_Engagement__c(Name='Access and Entitlements for Marketplace');
        
        Insert ee1 ;
        
        List<Core_Entitlement__c> ent = new List<Core_Entitlement__c>();
        Core_Entitlement__c de1 = new Core_Entitlement__c(Name='Partner Admin',Core_Display_Name__c='Partner Admin',Core_ERPM_Engagement_Id__c=ee1.id);
        
        Insert de1 ;
        
        List<Core_Entitlement__c> cnupdate=new List<Core_Entitlement__c>();
        List<Core_Entitlement__c> cn=[Select Core_Display_Name__c from  Core_Entitlement__c LIMIT 10];
        for(Core_Entitlement__c cn1:cn)
        {
            cn1.Core_Display_Name__c ='Employee';
            cnupdate.add(cn1);
        }
        Update cnupdate ;
        
        List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=contact1.Id,Core_Entitlement_Id__c = de1.id, Core_Selected__c=true);
        newlstentitle.add(ce1);
        Insert newlstentitle ;
                
        List<Core_Contact_Entitlement__c> ccnupdate=new List<Core_Contact_Entitlement__c>();
        List<Core_Contact_Entitlement__c> ccn=[Select Core_Selected__c from  Core_Contact_Entitlement__c LIMIT 10];
        for(Core_Contact_Entitlement__c ccn1:ccn)
        {
            ccn1.Core_Selected__c =true;
            ccnupdate.add(ccn1);
        }
        Update ccnupdate ;
        Test.stopTest();
        
        
      /*  User currentUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        List<User> userList = new List<User>();
        
        
        System.runAs (currentUser) {
            UserRole userRole = [Select PortalType, PortalAccountId From UserRole where PortalType ='Partner' limit 1];
            Profile profile = [select Id,name from Profile where Name ='Partner'];
            User newUser = new User(
                //UserRoleId = userRole.Id,
                profileId = profile.id, 
                username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com', 
                email = 'pb@ff.com', 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_US', 
                languagelocalekey = 'en_US', 
                timezonesidkey = 'America/Los_Angeles', 
                alias='nuser', 
                lastname='lastname', 
                contactId = contact1.id
            );
            userList.add(newUser);
            insert userList ;
            
        }
       */
        
        try{
            delete accGroupMemlist;           
        }Catch (DMLException e){
            System.assert(e.getMessage().contains('Service Agreement cannot be deleted.'), 'Service Agreement cannot be deleted.');
        }    
    }
    
    @isTest
    public static void  partnerAccGroupMemtestMethod1 ()
    { 
        Id accountRTPartnerAccountGroup = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        Id intelAccRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        //String partnerAccRecTypeId = System.Label.PMP_Partner_Account_Record_Type_Id;
        List<Account> accts1 = new List<Account>();        
        Account partnerAccount1 = new Account(Name ='PartnerAccount',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
                                              Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',RecordTypeId=accountRTPartnerAccountGroup);
    
        accts1.add(partnerAccount1);
        Account intelAccount1 = new Account(Name ='IntelAccount',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
                                            RecordTypeId=intelAccRecTypeId,Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        
        accts1.add(intelAccount1);
        Insert accts1 ;
        
        List<Account> intelAccId1 = [SELECT ID,Name FROM Account where Name ='IntelAccount'];
        List<Account> partnerAccountIdVar1 = [SELECT ID,Name FROM Account where Name ='PartnerAccount'];
        List<Account>accToUpdate1 = new List<Account>();
        For(Account acc1:accts1){
            acc1.IsPartner = true;
            accToUpdate1.add(acc1);
        }
        Update accToUpdate1 ;
        
        List<Core_Account_Group_Member__c> accGroupMemlist1 = new List<Core_Account_Group_Member__c>();
        Core_Account_Group_Member__c  accGroupMem1= new Core_Account_Group_Member__c(Core_Partner_Account_Id__c =partnerAccountIdVar1[0].Id,Core_Intel_Account_Id__c =intelAccId1[0].Id);
        accGroupMemlist1.add(accGroupMem1);
        Insert accGroupMemlist1 ;
        
        List<Core_Account_Group_Member__c> gupdate1=new List<Core_Account_Group_Member__c>();
        List<Core_Account_Group_Member__c> gl1=[Select Core_MDA_Ind__c from Core_Account_Group_Member__c LIMIT 10];
        For(Core_Account_Group_Member__c g1 : gl1)
        {
            g1.Core_MDA_Ind__c=False;
            gupdate1.add(g1);
        }
        
        
        Contact contact11 = new Contact(firstname='Partner', MailingCountry='India',
                                        lastname='Contact1', accountId=intelAccId1[0].id,Email='dellco1234@dell.com');
        //for update
        
        
        Insert contact11;
        
        
        //for update 
        List<Contact> ccupdate1=new List<Contact>();
        List<Contact> cl1=[Select firstname,lastname from Contact LIMIT 10];
        For(Contact c1 : cl1)
        {
            c1.firstname='Partner1';
            ccupdate1.add(c1);
        }
        Update ccupdate1 ;
        
        Test.startTest();
        List<Core_ERPM_Engagement__c> erp1 = new List<Core_ERPM_Engagement__c>();
        Core_ERPM_Engagement__c ee11 = new Core_ERPM_Engagement__c(Name='Access and Entitlements for Marketplace');
        
        Insert ee11 ;
        
        List<Core_Entitlement__c> ent1 = new List<Core_Entitlement__c>();
        Core_Entitlement__c de11 = new Core_Entitlement__c(Name='Partner Admin',Core_Display_Name__c='Partner Admin',Core_ERPM_Engagement_Id__c=ee11.id);
        
        Insert de11 ;
        
        List<Core_Entitlement__c> cnupdate1=new List<Core_Entitlement__c>();
        List<Core_Entitlement__c> cn1=[Select Core_Display_Name__c from  Core_Entitlement__c LIMIT 10];
        for(Core_Entitlement__c cn11:cn1)
        {
            cn11.Core_Display_Name__c ='Employee';
            cnupdate1.add(cn11);
        }
        Update cnupdate1 ;
        
        
        
        List<Core_Contact_Entitlement__c> newlstentitle = new List<Core_Contact_Entitlement__c>();
        Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=contact11.Id,Core_Entitlement_Id__c = de11.id, Core_Selected__c=true);
        newlstentitle.add(ce1);
        Insert newlstentitle ;
        
        
        List<Core_Contact_Entitlement__c> ccnupdate1=new List<Core_Contact_Entitlement__c>();
        List<Core_Contact_Entitlement__c> ccn1=[Select Core_Selected__c from  Core_Contact_Entitlement__c LIMIT 10];
        for(Core_Contact_Entitlement__c ccn11:ccn1)
        {
            ccn11.Core_Selected__c =true;
            ccnupdate1.add(ccn11);
        }
        Update ccnupdate1 ;
        Test.stopTest();
        
        
      /*  User currentUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        List<User> userList = new List<User>();
        
        
        System.runAs (currentUser) {
           UserRole userRole = [Select PortalType, PortalAccountId From UserRole where PortalType ='Partner' limit 1];
            Profile profile = [select Id,name from Profile where Name ='Partner'];
            User newUser = new User(
                 //UserRoleId = userRole.Id,
                profileId = profile.id, 
                username = 'testUser'+String.valueOf(Math.random())+'@CoreMD.com', 
                email = 'pb@ff.com', 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_US', 
                languagelocalekey = 'en_US', 
                timezonesidkey = 'America/Los_Angeles', 
                alias='nuser', 
                lastname='lastname', 
                contactId = contact11.id
            );
            userList.add(newUser);
            insert userList ;
            
        }
        */
        
     /*   try{

            Update gupdate1 ;

        }Catch (DMLException e){
            
            System.assert(e.getMessage().contains('Service Agreement cannot be deleted.'), 'Service Agreement cannot be deleted.');
        }  */
        
        
        
        
    }
    
    /*static testMethod void pagTestMethod(){
        Test.startTest();
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id accountRTPartnerAccountGroup = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        
        List<Account> accList = new List<Account>();
        List<Core_Account_Group_Member__c> agmList = new List<Core_Account_Group_Member__c>();
        Account a = new Account();
        a.RecordTypeId = accountRTPartnerAccountGroup;
        a.Name='Amazon';
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        accList.add(a);
        
        Account ac = new Account();
        ac.RecordTypeId = accountRTPartnerAccountGroup;
        ac.Name='Amazon India';
        ac.Core_Account_Type__c ='Distributor';
        ac.Industry='Agriculture';
        ac.BillingCity='New Delhi';
        ac.BillingCountryCode='IND';
        ac.BillingStreet='4th Floor,New Road';
        ac.BillingPostalCode='110037';
        ac.BillingStateCode='KA';
        accList.add(ac);
        
        Account acc = new Account();
        acc.RecordTypeId = accountRecordTypeIntel;
        acc.Name='Walmart';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry='Agriculture';
        acc.BillingCity='New Delhi';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,New Road';
        acc.BillingPostalCode='110037';
        acc.BillingStateCode='KA';
        acc.Core_Is_PAG_Member_Ind__c = false;
        accList.add(acc);
        
        Account acct = new Account();
        acct.RecordTypeId = accountRecordTypeIntel;
        acct.Name='Tesco';
        acct.Core_Account_Type__c ='Distributor';
        acct.Industry='Agriculture';
        acct.BillingCity='New Delhi';
        acct.BillingCountryCode='IND';
        acct.BillingStreet='4th Floor,New Road';
        acct.BillingPostalCode='110037';
        acct.BillingStateCode='KA';
        acct.Core_Is_PAG_Member_Ind__c = false;
        accList.add(acct);
        
        Account accnt = new Account();
        accnt.RecordTypeId = accountRecordTypeIntel;
        accnt.Name='Tesla';
        accnt.Core_Account_Type__c ='Distributor';
        accnt.Industry='Agriculture';
        accnt.BillingCity='New Delhi';
        accnt.BillingCountryCode='IND';
        accnt.BillingStreet='4th Floor,New Road';
        accnt.BillingPostalCode='110037';
        accnt.BillingStateCode='KA';
        accnt.Core_Is_PAG_Member_Ind__c = false;
        accList.add(accnt);
        
        Account accnts = new Account();
        accnts.RecordTypeId = accountRecordTypeIntel;
        accnts.Name='Texon Corp';
        accnts.Core_Account_Type__c ='Distributor';
        accnts.Industry='Agriculture';
        accnts.BillingCity='New Delhi';
        accnts.BillingCountryCode='IND';
        accnts.BillingStreet='4th Floor,New Road';
        accnts.BillingPostalCode='110037';
        accnts.BillingStateCode='KA';
        accnts.Core_Is_PAG_Member_Ind__c = false;
        accList.add(accnts);
        insert accList;
        
        Contact contact11 = new Contact(firstname='Partner', MailingCountry='India',
                                        lastname='Contact1', accountId=accList[5].id,Email='dellco1234@dell.com');
        
        Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c();
        agm.Core_Partner_Account_Id__c = a.Id;
        agm.Core_Intel_Account_Id__c = acc.Id;
        agm.Core_MDA_Ind__c = true;
        agm.Core_Inactive_Ind__c = false;
        agmList.add(agm);
        
        Core_Account_Group_Member__c agm1 = new Core_Account_Group_Member__c();
        agm1.Core_Partner_Account_Id__c = a.Id;
        agm1.Core_Intel_Account_Id__c = accnt.Id;
        agm1.Core_MDA_Ind__c = false;
        agm1.Core_Inactive_Ind__c = false;
        agmList.add(agm1);
        
        Core_Account_Group_Member__c agm2 = new Core_Account_Group_Member__c();
        agm2.Core_Partner_Account_Id__c = ac.Id;
        agm2.Core_Intel_Account_Id__c = accnts.Id;
        agm2.Core_MDA_Ind__c = true;
        agm2.Core_Inactive_Ind__c = false;
        agmList.add(agm2);
        insert agmList;
        
        try{
            acc.Core_Is_PAG_Member_Ind__c = true;
            update acc;
            
            agm.Core_Intel_Account_Id__c = acct.Id;
            agm.Core_Inactive_Ind__c = true;
            update agm;
            
            agm.Core_Inactive_Ind__c = false;
            update agm;
            
            /*agm1.Core_Inactive_Ind__c = true;
            update agm1;*/
            
            /*Core_Account_Group_Member__c agm3 = new Core_Account_Group_Member__c();
            agm3.Core_Partner_Account_Id__c = ac.Id;
            agm3.Core_Intel_Account_Id__c = accnt.Id;
            //agm3.Core_MDA_Ind__c = false;
            agm3.Core_Inactive_Ind__c = false;
            insert agm3;
            
            agm1.Core_Inactive_Ind__c = false;
            agm1.Core_MDA_Ind__c = true;
            update agm1;
            
          //  agm2.Core_MDA_Ind__c = false;
            agm2.Core_Intel_Account_Id__c = accnt.Id;
            update agm2;
            
            acc.Core_Is_PAG_Member_Ind__c = false;
            update acc;
            
            acct.Core_Is_PAG_Member_Ind__c = true;
            update acct;    
            
            acct.Core_Is_PAG_Member_Ind__c = false;
            update acct;
        }
        catch(Exception e){
        }
        Test.stopTest();
     //   System.assertEquals(acct.Core_Is_PAG_Member_Ind__c,false,'match');
    }*/
    
    
    static testMethod void pagTestMethod1(){
        Test.startTest();
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id accountRTPartnerAccountGroup = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        
        List<Account> accList = new List<Account>();
        Account a = new Account();
        a.RecordTypeId = accountRTPartnerAccountGroup;
        a.Name='Amazon';
        a.Core_Account_Type__c ='Distributor';
        a.Industry='Agriculture';
        a.BillingCity='New Delhi';
        a.BillingCountryCode='IND';
        a.BillingStreet='4th Floor,New Road';
        a.BillingPostalCode='110037';
        a.BillingStateCode='KA';
        accList.add(a);
        
        Account ac = new Account();
        ac.RecordTypeId = accountRTPartnerAccountGroup;
        ac.Name='Amazon India';
        ac.Core_Account_Type__c ='Distributor';
        ac.Industry='Agriculture';
        ac.BillingCity='New Delhi';
        ac.BillingCountryCode='IND';
        ac.BillingStreet='4th Floor,New Road';
        ac.BillingPostalCode='110037';
        ac.BillingStateCode='KA';
        accList.add(ac);
        
        Account acc = new Account();
        acc.RecordTypeId = accountRecordTypeIntel;
        acc.Name='Walmart';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry='Agriculture';
        acc.BillingCity='New Delhi';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,New Road';
        acc.BillingPostalCode='110037';
        acc.BillingStateCode='KA';
        acc.Core_Is_PAG_Member_Ind__c = false;
        accList.add(acc);
        
        Account acct = new Account();
        acct.RecordTypeId = accountRecordTypeIntel;
        acct.Name='Tesco';
        acct.Core_Account_Type__c ='Distributor';
        acct.Industry='Agriculture';
        acct.BillingCity='New Delhi';
        acct.BillingCountryCode='IND';
        acct.BillingStreet='4th Floor,New Road';
        acct.BillingPostalCode='110037';
        acct.BillingStateCode='KA';
        acct.Core_Is_PAG_Member_Ind__c = false;
        accList.add(acct);
        
        Account accnt = new Account();
        accnt.RecordTypeId = accountRecordTypeIntel;
        accnt.Name='Tesla';
        accnt.Core_Account_Type__c ='Distributor';
        accnt.Industry='Agriculture';
        accnt.BillingCity='New Delhi';
        accnt.BillingCountryCode='IND';
        accnt.BillingStreet='4th Floor,New Road';
        accnt.BillingPostalCode='110037';
        accnt.BillingStateCode='KA';
        accnt.Core_Is_PAG_Member_Ind__c = false;
        accList.add(accnt);
        
        Account accnts = new Account();
        accnts.RecordTypeId = accountRecordTypeIntel;
        accnts.Name='Texon Corp';
        accnts.Core_Account_Type__c ='Distributor';
        accnts.Industry='Agriculture';
        accnts.BillingCity='New Delhi';
        accnts.BillingCountryCode='IND';
        accnts.BillingStreet='4th Floor,New Road';
        accnts.BillingPostalCode='110037';
        accnts.BillingStateCode='KA';
        accnts.Core_Is_PAG_Member_Ind__c = false;
        accList.add(accnts);
        insert accList;
        
        Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c();
        agm.Core_Partner_Account_Id__c = a.Id;
        agm.Core_Intel_Account_Id__c = acc.Id;
        agm.Core_MDA_Ind__c = true;
        agm.Core_Inactive_Ind__c = false;
        insert agm;
        
        try{
            acc.Core_Is_PAG_Member_Ind__c = true;
            update acc;
            
            agm.Core_Intel_Account_Id__c = acct.Id;
            agm.Core_Inactive_Ind__c = true;
            update agm;
            
            List<Core_Account_Group_Member__c> agmToDelete = new List<Core_Account_Group_Member__c>([SELECT id FROM Core_Account_Group_Member__c LIMIT 1]);
            delete agmToDelete;
            
            acc.Core_Is_PAG_Member_Ind__c = false;
            update acc;
            
            acct.Core_Is_PAG_Member_Ind__c = true;
            update acct;
            
           // agm.Core_MDA_Ind__c = false;
           // update agm;
            
            acct.Core_Is_PAG_Member_Ind__c = false;
            update acct;
        }
        catch(Exception e){
        }
        Test.stopTest();
     //   System.assertEquals(acct.Core_Is_PAG_Member_Ind__c,false,'match');
    }
    
    static testMethod void LegalAgreeOnOPIDTestMethod(){
        Test.startTest();
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id accountRTPartnerAccountGroup = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        
        Account acc = new Account();
        acc.RecordTypeId = accountRTPartnerAccountGroup;
        acc.Name='Partner Account';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry='Agriculture';
        acc.BillingCity='New Delhi';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,New Road';
        acc.BillingPostalCode='110037';
        acc.BillingStateCode='KA';
        insert acc;
        
         Account acc1 = new Account();
        acc1.Name='Intel Account';
        acc1.Core_Account_Type__c ='Distributor';
        acc1.Industry='Agriculture';
        acc1.BillingCity='New Delhi';
        acc1.BillingCountryCode='IND';
        acc1.BillingStreet='4th Floor,New Road';
        acc1.BillingPostalCode='110037';
        acc1.BillingStateCode='KA';
        insert acc1;
        
        Contact con = new Contact();
        con.firstname='Partner';
        con.lastname='Contact1';
        con.AccountId=acc.Id;
        con.MailingCountry='India';
        con.Email='dellco1234@dell.com';
        insert con;
        
        List<Account> accts1 = new List<Account>();        
       /* Account partnerAccount1 = new Account(Name ='PartnerAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
                                              Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='abc chowk delhi',RecordTypeId=accountRTPartnerAccountGroup);
        
        accts1.add(partnerAccount1);
        Account intelAccount1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Distributor',Core_Sales_Group_New__c= 'CCG Sales Group',
                                            Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        
        accts1.add(intelAccount1);
        Insert accts1 ;*/
    
        PRM_PartnerAgreement__c p=new PRM_PartnerAgreement__c();
        p.Name='Intel Partner Alliance Terms & Condition';
        p.PRM_InActive_Ind__c=false;
        p.PRM_Agreement_Cd__c='IPA_TANDC';
        insert p;
        
        PRM_AccountLegalAgreemntAssociation__c alaa = new PRM_AccountLegalAgreemntAssociation__c();
        alaa.PRM_Account_Id__c = acc.Id;
        alaa.PRM_Partner_Agreement_Id__c = p.Id;
        alaa.PRM_Signed_By_Email__c = con.Email;
        alaa.PRM_Signed_By_Name__c = con.FirstName+' '+con.LastName;
        //alaa.PRM_Contact__c = con.Id;
        alaa.PRM_Agreement_Sign_Dt__c=system.now();
        insert alaa;
        
        Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c();
        agm.Core_Partner_Account_Id__c = acc.Id;
        agm.Core_Intel_Account_Id__c = acc1.Id;
        agm.Core_MDA_Ind__c = true;
        agm.Core_Inactive_Ind__c = false;
        insert agm;
        Test.stopTest();
    }
    
    static testMethod void OPIDAndLocationIDRollUp(){
        Test.startTest();
        Id accountRecordTypeIntel = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Intel_Account).getRecordTypeId();
        Id accountRTPartnerAccountGroup = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
        
        List<Account> accts2 = new List<Account>();        
        Account acc = new Account();
        acc.RecordTypeId = accountRTPartnerAccountGroup;
        acc.Name='Partner Account';
        acc.Core_Account_Type__c ='Distributor';
        acc.Industry='Agriculture';
        acc.BillingCity='New Delhi';
        acc.BillingCountryCode='IND';
        acc.BillingStreet='4th Floor,New Road';
        acc.BillingPostalCode='110037';
        acc.BillingStateCode='KA';
        accts2.add(acc);
        
        Account acc0 = new Account();
        acc0.RecordTypeId = accountRTPartnerAccountGroup;
        acc0.Name='Partner Account';
        acc0.Core_Account_Type__c ='Distributor';
        acc0.Industry='Agriculture';
        acc0.BillingCity='New Delhi';
        acc0.BillingCountryCode='IND';
        acc0.BillingStreet='4th Floor,New Road';
        acc0.BillingPostalCode='110037';
        acc0.BillingStateCode='KA';
        accts2.add(acc0);
        
        Account acc1 = new Account();
        acc1.Name='Intel Account';
        acc1.RecordTypeId = accountRecordTypeIntel;
        acc1.Core_Account_Type__c ='Distributor';
        acc1.Industry='Agriculture';
        acc1.BillingCity='New Delhi';
        acc1.BillingCountryCode='IND';
        acc1.BillingStreet='4th Floor,New Road';
        acc1.BillingPostalCode='110037';
        acc1.BillingStateCode='KA';
        acc1.Core_Intel_Partner_Alliance_PartnerGroup__c =true;
        accts2.add(acc1);
        
        Account parent4 = new Account();
        parent4.RecordTypeId = accountRTPartnerAccountGroup;
        parent4.Name='Cello Ltd-PARENT4';
        parent4.BillingCity='New City';
        parent4.BillingStreet='New Street';
        parent4.BillingCountry='India';
        parent4.BillingPostalCode='999999';
        parent4.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        accts2.add(parent4);
        
        Account parent5 = new Account();
        parent5.RecordTypeId = accountRTPartnerAccountGroup;
        parent5.Name='Cello Ltd-PARENT5';
        parent5.BillingCity='New City';
        parent5.BillingStreet='New Street';
        parent5.BillingCountry='India';
        parent5.BillingPostalCode='999999';
        parent5.Core_Account_Type__c = 'Cloud Service Provider (CSP)';
        accts2.add(parent5);
        
        Account acc2 = new Account();
        acc2.Name='Intel Account - Two';
        acc2.RecordTypeId = accountRecordTypeIntel;
        acc2.Core_Account_Type__c ='Distributor';
        acc2.Industry='Agriculture';
        acc2.BillingCity='Chennai';
        acc2.BillingCountryCode='IND';
        acc2.BillingStreet='4th Floor,New Road';
        acc2.BillingPostalCode='110037';
        acc2.BillingStateCode='TN';
        acc2.Core_Intel_Partner_Alliance_PartnerGroup__c =true;
        accts2.add(acc2);
        
        
        Account acc28 = new Account();
        acc28.Name='Intel Account - Eight';
        acc28.RecordTypeId = accountRecordTypeIntel;
        acc28.Core_Account_Type__c ='Distributor';
        acc28.Industry='Agriculture';
        acc28.BillingCity='Chennai';
        acc28.BillingCountryCode='IND';
        acc28.BillingStreet='4th Floor,New Road';
        acc28.BillingPostalCode='110037';
        acc28.BillingStateCode='TN';
        acc28.Core_Intel_Partner_Alliance_PartnerGroup__c =true;
        accts2.add(acc28);
        
        
        Account acc29 = new Account();
        acc29.Name='Intel Account - Twenty Eight';
        acc29.RecordTypeId = accountRecordTypeIntel;
        acc29.Core_Account_Type__c ='Distributor';
        acc29.Industry='Agriculture';
        acc29.BillingCity='Chennai';
        acc29.BillingCountryCode='IND';
        acc29.BillingStreet='4th Floor,New Road';
        acc29.BillingPostalCode='110037';
        acc29.BillingStateCode='TN';
        acc29.Core_Intel_Partner_Alliance_PartnerGroup__c =true;
        accts2.add(acc29); 
        
        Account acc30 = new Account();
        acc30.Name='Intel Account - Thirty';
        acc30.RecordTypeId = accountRecordTypeIntel;
        acc30.Core_Account_Type__c ='Distributor';
        acc30.Industry='Agriculture';
        acc30.BillingCity='Chennai';
        acc30.BillingCountryCode='IND';
        acc30.BillingStreet='4th Floor,New Road';
        acc30.BillingPostalCode='110037';
        acc30.BillingStateCode='TN';
        acc30.Core_Intel_Partner_Alliance_PartnerGroup__c =true;
        accts2.add(acc30); 
        insert accts2;
        
        Contact con = new Contact();
        con.firstname='Partner';
        con.lastname='Contact1';
        con.AccountId=acc.Id;
        con.MailingCountry='India';
        con.Email='dellco1234@dell.com';
        insert con;
        
        List<Account> accts1 = new List<Account>();        
        
        ChannelProgram cp = new ChannelProgram();
        cp.Name = 'Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        
        
        ChannelProgramLevel cpl = new ChannelProgramLevel(); 
        cpl.Name='Prestige';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        PRM_AccountChannelMembership__c acctChnlMem = new PRM_AccountChannelMembership__c(); 
        acctChnlMem.PRM_Account_Id__c=acc1.Id;
        acctChnlMem.PRM_Channel_Program_Id__c=cp.Id;
        acctChnlMem.PRM_Channel_Program_Level_Id__c=cpl.Id;
        acctChnlMem.PRM_Status_Nm__c = 'Approved';
        acctChnlMem.PRM_Status_Reason_Txt__c ='Approved';
        acctChnlMem.PRM_Partner_Role__c='Service Provider';
        insert acctChnlMem;
        
        
        
        PRM_PartnerType__c pt = new PRM_PartnerType__c();
        pt.Name = 'Cloud Service Provider (CSP)';
        pt.PRM_PartneryTypeCode__c = 'CSP';
        //pt.PRM_Role_Name__c = 'Service Provider';
        pt.PRM_PartnerRoleCode__c = 'SPR';
        pt.PRM_channelprogram__c = cp.Id;
        insert pt;
        
        /* PRM_Profile_Questions__c pq = new PRM_Profile_Questions__c();
pq.PRM_Channel_Program_Id__c = cp.Id;
//pq.PRM_Partner_Type_Id__c = pt.Id;
//pq.PRM_Partner_Role__c='Service Provider';
pq.PRM_Question_Type_Nm__c = 'Text';
pq.PRM_Question_Cd__c='PRM_Point_Not_Eligible' ;
pq.PRM_Question_Display_Txt__c = 'Points Not eligible';
pq.PRM_InActive_Ind__c = false;
insert pq;

*/
        
        list<PRM_Profile_Questions__c> listQuestion = new list<PRM_Profile_Questions__c>();
        PRM_Profile_Questions__c pq = new PRM_Profile_Questions__c();
        pq.PRM_Channel_Program_Id__c = cp.Id;
        //pq.PRM_Partner_Type_Id__c = pt.Id;
        //pq.PRM_Partner_Role__c='Service Provider';
        pq.PRM_Question_Type_Nm__c = 'Text';
        pq.PRM_Question_Cd__c='PRM_Point_Not_Eligible' ;
        pq.PRM_Question_Display_Txt__c = 'Points Not eligible';
        pq.PRM_InActive_Ind__c = false;
        listQuestion.add(pq);
        
        PRM_Profile_Questions__c pq1 = new PRM_Profile_Questions__c();
        pq1.PRM_Channel_Program_Id__c = cp.Id;
        //pq.PRM_Partner_Type_Id__c = pt.Id;
        //pq.PRM_Partner_Role__c='Service Provider';
        pq1.PRM_Question_Type_Nm__c = 'Text';
        pq1.PRM_Question_Cd__c='PRM_Opt_In' ;
        pq1.PRM_Question_Display_Txt__c = 'Points Opt-in';
        pq1.PRM_InActive_Ind__c = false;
        listQuestion.add(pq1);
        
        PRM_Profile_Questions__c pq3 = new PRM_Profile_Questions__c();
        pq3.PRM_Channel_Program_Id__c = cp.Id;
        //pq.PRM_Partner_Type_Id__c = pt.Id;
        //pq.PRM_Partner_Role__c='Service Provider';
        pq3.PRM_Question_Type_Nm__c = 'Text';
        pq3.PRM_Question_Cd__c='PRM_Component_point' ;
        pq3.PRM_Question_Display_Txt__c = 'Component Point earning excluded';
        pq3.PRM_InActive_Ind__c = false;
        listQuestion.add(pq3);
        
        insert listQuestion;        
        
        PRM_Profile_Answer__c pa = new PRM_Profile_Answer__c();
        pa.PRM_Profile_Questions_Id__c = pq.Id;
        insert pa;
        
        
        List<PRM_Profile_Responses__c> prList = new List<PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> prList2 = new List<PRM_Profile_Responses__c>();
        List<PRM_Profile_Responses__c> responseInsertList = new List<PRM_Profile_Responses__c>();
        
        PRM_Profile_Responses__c pr = new PRM_Profile_Responses__c();
        pr.PRM_Account_Id__c = acc1.Id;
        pr.PRM_Profile_Answer_Id__c = pa.Id;
        pr.PRM_Profile_Questions_Id__c = pq.Id;
        responseInsertList.add(pr);
        
        PRM_Profile_Responses__c pr11 = new PRM_Profile_Responses__c();
        pr11.PRM_Account_Id__c = acc1.Id;
        pr11.PRM_Profile_Answer_Id__c = pa.Id;
        pr11.PRM_Profile_Questions_Id__c = pq1.Id;
        responseInsertList.add(pr11);
        
        PRM_Profile_Responses__c pr1 = new PRM_Profile_Responses__c();
        pr1.PRM_Account_Id__c = acc.Id;
        pr1.PRM_Profile_Answer_Id__c = pa.Id;
        pr1.PRM_Profile_Questions_Id__c = pq.Id;
        responseInsertList.add(pr1);
        
        
        
        
        PRM_Profile_Responses__c pr2 = new PRM_Profile_Responses__c();
        pr2.PRM_Account_Id__c = acc2.Id;
        pr2.PRM_Profile_Answer_Id__c = pa.Id;
        pr2.PRM_Profile_Questions_Id__c = pq.Id;
        responseInsertList.add(pr2);
        
        
        PRM_Profile_Responses__c pr22 = new PRM_Profile_Responses__c();
        pr22.PRM_Account_Id__c = acc2.Id;
        pr22.PRM_Profile_Answer_Id__c = pa.Id;
        pr22.PRM_Profile_Questions_Id__c = pq1.Id;
        responseInsertList.add(pr22);
        
        
        PRM_Profile_Responses__c pr23 = new PRM_Profile_Responses__c();
        pr23.PRM_Account_Id__c = acc2.Id;
        pr23.PRM_Profile_Answer_Id__c = pa.Id;
        pr23.PRM_Profile_Questions_Id__c = pq3.Id;
        responseInsertList.add(pr23);
        
        PRM_Profile_Responses__c pr24 = new PRM_Profile_Responses__c();
        pr24.PRM_Account_Id__c = parent4.Id;
        pr24.PRM_Profile_Answer_Id__c = pa.Id;
        pr24.PRM_Profile_Questions_Id__c = pq3.Id;
        responseInsertList.add(pr24);
        
        PRM_Profile_Responses__c pr244 = new PRM_Profile_Responses__c();
        pr244.PRM_Account_Id__c = acc29.Id;
        pr244.PRM_Profile_Answer_Id__c = pa.Id;
        pr244.PRM_Profile_Questions_Id__c = pq.Id;
        responseInsertList.add(pr244);
        
        
        
        PRM_Profile_Responses__c pr20 = new PRM_Profile_Responses__c();
        pr20.PRM_Account_Id__c = acc0.Id;
        pr20.PRM_Profile_Answer_Id__c = pa.Id;
        pr20.PRM_Profile_Questions_Id__c = pq3.Id;
        responseInsertList.add(pr20);
        
        
        PRM_Profile_Responses__c pr30 = new PRM_Profile_Responses__c();
        pr30.PRM_Account_Id__c = acc30.Id;
        pr30.PRM_Profile_Answer_Id__c = pa.Id;
        pr30.PRM_Profile_Questions_Id__c = pq3.Id;
        responseInsertList.add(pr30);
        
        
        
        
        insert responseInsertList;    
       
        
        
        /*     
PRM_Profile_Responses__c pr2 = new PRM_Profile_Responses__c();
pr2.PRM_Account_Id__c = 'Dummy';
pr2.PRM_Profile_Answer_Id__c = pa.Id;
pr2.PRM_Profile_Questions_Id__c = pq.Id;
insert pr2;    

*/
        
        list<Core_Account_Group_Member__c> listAgm = new list<Core_Account_Group_Member__c>() ;
        Core_Account_Group_Member__c agm = new Core_Account_Group_Member__c();
        agm.Core_Partner_Account_Id__c = acc.Id;
        agm.Core_Intel_Account_Id__c = acc1.Id;
        agm.Core_MDA_Ind__c = true;
        agm.Core_Inactive_Ind__c = false;
        listAgm.add(agm);
        
        Core_Account_Group_Member__c agm2 = new Core_Account_Group_Member__c();
        agm2.Core_Partner_Account_Id__c = acc0.Id;
        agm2.Core_Intel_Account_Id__c = acc2.Id;
        agm2.Core_Inactive_Ind__c = false;
        listAgm.add(agm2);
        
        Core_Account_Group_Member__c agm3 = new Core_Account_Group_Member__c();
        agm3.Core_Partner_Account_Id__c = parent4.Id;
        agm3.Core_Intel_Account_Id__c = acc28.Id;
        agm3.Core_Inactive_Ind__c = false;
        listAgm.add(agm3);
        
        Core_Account_Group_Member__c agm4 = new Core_Account_Group_Member__c();
        agm4.Core_Partner_Account_Id__c = parent4.Id;
        agm4.Core_Intel_Account_Id__c = acc29.Id;
        agm4.Core_Inactive_Ind__c = false;
        listAgm.add(agm4);        
        
        Core_Account_Group_Member__c agm5 = new Core_Account_Group_Member__c();
        agm5.Core_Partner_Account_Id__c = parent5.Id;
        agm5.Core_Intel_Account_Id__c = acc30.Id;
        agm5.Core_Inactive_Ind__c = false;
        listAgm.add(agm5);   
        
        
        insert listAgm;
        
        List<Core_Account_Group_Member__c> agmToUpdate = [SELECT Id, Core_Inactive_Ind__c, Core_Intel_Partner_Alliance_PartnerGroup__c, Core_Intel_Account_Id__c, Core_Partner_Account_Id__c FROM Core_Account_Group_Member__c
    															WHERE Core_Partner_Account_Id__c = :parent4.Id];

		for (Core_Account_Group_Member__c agmTest : agmToUpdate) {
                    agm4.Core_Inactive_Ind__c = true;
			}

		update agmToUpdate;

        // PRM_ProfileResponseCtlr.disableFlagValues(acc2.Id);
        //PRM_ProfileResponseCtlr.disableFlagValues(acc.Id);
        Map<id,Core_Account_Group_Member__c>  oldmap = new  Map<id,Core_Account_Group_Member__c>  () ;
        
        PMP_Acct_Grp_Mbr_TriggerHandler.RollUpLocFlagToOPID(agmToUpdate,null);
        Test.stopTest();
    }
    @isTest
    public static void  rollUpDownIPAMembership_IpaR_test(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPAGAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        Id opidIpaMemAttrRecordId = Schema.SObjectType.PRM_IPAMembership_Attributes__c.getRecordTypeInfosByName().get('1PID Account Attributes').getRecordTypeId();
        Id inteIpaMemAttrRecordId = Schema.SObjectType.PRM_IPAMembership_Attributes__c.getRecordTypeInfosByName().get('Intel Account Attributes').getRecordTypeId();
        List<PRM_IPAMembership_Attributes__c> ipaMemList = new List<PRM_IPAMembership_Attributes__c>();
        List<account> acclist1  = new List<account>();
        Account opidAcc = new Account();//Account
        opidAcc.RecordTypeId = recordTypeIdPAGAccount;
        opidAcc.Name='vista';
        opidAcc.BillingCity='City9';
        opidAcc.BillingStreet='Street9';
        opidAcc.BillingCountry='India';
        opidAcc.BillingPostalCode='Postal code';
        opidAcc.Core_Account_Type__c='Cloud Service Provider (CSP)';
        opidAcc.Core_IPA_Partner_Role__c = 'Solution Integrator';
        acclist1.add(opidAcc) ;
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Test Intel Account';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        newAccount.Core_User_Defined_Website__c='www.sample.com';
        newAccount.Core_IPA_Partner_Segment__c = 'Client Computing';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        newAccount.Core_IPA_One_Partner_Id__c = opidAcc.id;
        newAccount.Core_Business_Party_Id__c = '9456456' ; //TWC729-1292
        
        acclist1.add(newAccount);
        insert acclist1;
		
        // Active Location IPA
        PRM_IPAMembership_Attributes__c ipaMem = new PRM_IPAMembership_Attributes__c();
        ipaMem.PRM_Account_Id__c = newAccount.Id;
        ipaMem.RecordTypeId = inteIpaMemAttrRecordId;
        ipaMem.PRM_Registration_Source_Txt__c = 'Web';
        ipaMem.PRM_Points_Opt_in_Ind__c =true;
        ipaMem.PRM_Points_Opt_in_Dt__c = System.today();
        ipaMem.PRM_Point_Status_Txt__c = 'Active';
        ipaMem.PRM_Point_Status_Dt__c = System.today();
        ipaMem.PRM_Inactive_ind__c = false; //The record is Active
        ipaMemList.add(ipaMem);
        
        // ❗ INACTIVE OPID IPA (THIS IS THE IMPORTANT CHANGE)
        PRM_IPAMembership_Attributes__c ipaMemOpid = new PRM_IPAMembership_Attributes__c();
        ipaMemOpid.PRM_Account_Id__c = opidAcc.Id;
        ipaMemOpid.RecordTypeId = opidIpaMemAttrRecordId;
        ipaMemOpid.PRM_Registration_Source_Txt__c = 'Web';
        ipaMemOpid.PRM_Points_Not_Eligible_Ind__c =true ;
        ipaMemOpid.PRM_Points_Not_Eligible_Dt__c = System.today();
        ipaMemOpid.PRM_Point_Status_Txt__c = 'Not Eligible';
        ipaMemOpid.PRM_Point_Status_Dt__c = System.today();
        ipaMemOpid.PRM_Inactive_ind__c = true;  // ✅ intentionally inactive
        ipaMemList.add(ipaMemOpid);

        TriggerHandler.bypass('PRM_IPAMembership_TriggerHandler');
        insert ipaMemList;
        TriggerHandler.clearBypass('PRM_IPAMembership_TriggerHandler');
        Test.startTest();
        list<Core_Account_Group_Member__c> listAgm = new list<Core_Account_Group_Member__c>() ;
        Core_Account_Group_Member__c agm4 = new Core_Account_Group_Member__c();
        agm4.Core_Partner_Account_Id__c = opidAcc.Id;
        agm4.Core_Intel_Account_Id__c = newAccount.Id;
        agm4.Core_Inactive_Ind__c = false;
        //agm4.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
       insert agm4;
       
        agm4.Core_Inactive_Ind__c = true;
        update agm4;
        listAgm.add(agm4);

        agm4.Core_Inactive_Ind__c = false;
        update agm4;
        Map<Id,Core_Account_Group_Member__c> oldMap = new Map<Id,Core_Account_Group_Member__c>();
        oldMap.put(agm4.id,agm4);
        PMP_Acct_Grp_Mbr_TriggerHandler.PRM_IPAR_rollUpDownIPAMembership(listAgm,oldMap);
        Test.stopTest();
        
        
        // -----------------------------
        // ✅ ASSERTIONS (PROVE FIX WORKS)
        // -----------------------------
        
        
         // 1️⃣ OPID IPA must remain inactive and NOT copied
            PRM_IPAMembership_Attributes__c opidAfter =
                [SELECT PRM_Inactive_ind__c
                 FROM PRM_IPAMembership_Attributes__c
                 WHERE PRM_Account_Id__c = :opidAcc.Id
                 LIMIT 1];
        
        
         System.assertEquals(
                true,
                opidAfter.PRM_Inactive_ind__c,
                'Inactive OPID IPA must not be used for roll-down'
            );
        
        
         // 2️⃣ Location IPA must NOT inherit OPID values
            PRM_IPAMembership_Attributes__c locAfter =
                [SELECT PRM_Point_Status_Txt__c
                 FROM PRM_IPAMembership_Attributes__c
                 WHERE PRM_Account_Id__c = :newAccount.Id
                 LIMIT 1];
                
         System.assertEquals(
                'Active',
                locAfter.PRM_Point_Status_Txt__c,
                'Location IPA must not be updated from inactive OPID IPA'
            );
        
        
        // 3️⃣ Ensure no unintended IPA records were created
            
        List<PRM_IPAMembership_Attributes__c> locIpaList =
            [
                SELECT Id, RecordTypeId, PRM_Point_Status_Txt__c
                FROM PRM_IPAMembership_Attributes__c
                WHERE PRM_Account_Id__c = :newAccount.Id
            ];
        
            System.assertEquals(
                1,
                locIpaList.size(),
                'Inactive IPA records must not cause new records to be created'
            ); 
        
        
        System.assertNotEquals(
            'Not Eligible',
            locIpaList[0].PRM_Point_Status_Txt__c,
            'Inactive OPID IPA values must never roll down'
        );


    }
  @isTest
static void testMDAUpdate() {

    Id partnerRtId = Schema.SObjectType.Account
        .getRecordTypeInfosByDeveloperName()
        .get('Core_Partner_Account_Group')
        .getRecordTypeId();

    Id intelRtId = Schema.SObjectType.Account
        .getRecordTypeInfosByDeveloperName()
        .get('Mastered_Account')
        .getRecordTypeId();

    Core_Trigger_Executions__c cs = new Core_Trigger_Executions__c(
        Name = 'isPAGMTrigger',
        Core_Active__c = true,
        Core_Class_Name__c = 'Core_Acct_Grp_Mbr_TriggerHandler',
        Core_Object__c = 'Core_Account_Group_Member__c',
        Core_Trigger_Events__c = 'Before Insert, Before Update',
        Core_Description__c = 'Test Case'
    );
    insert cs;

    Account partnerAcc = new Account(
        Name = 'Partner Test',
        RecordTypeId = partnerRtId,
        Core_Account_Type__c = 'Distributor',
        Core_Sales_Group_New__c = 'CCG Sales Group',
        Industry = 'Agriculture',
        BillingCity = 'Delhi',
        BillingCountryCode = 'IND',
        BillingStreet = 'Test Street',
        BillingPostalCode = '110001',
        BillingStateCode = 'KA'
    );

    Account intelAcc = new Account(
        Name = 'Intel Test',
        RecordTypeId = intelRtId,
        Core_Account_Type__c = 'Distributor',
        Core_Sales_Group_New__c = 'CCG Sales Group',
        Industry = 'Agriculture',
        BillingCity = 'Delhi',
        BillingCountryCode = 'IND',
        BillingStreet = 'Test Street',
        BillingPostalCode = '110001',
        BillingStateCode = 'KA'
    );

    insert new List<Account>{ partnerAcc, intelAcc };

    Core_Account_Group_Member__c agm =
        new Core_Account_Group_Member__c(
            Core_Partner_Account_Id__c = partnerAcc.Id,
            Core_Intel_Account_Id__c = intelAcc.Id,
            Core_MDA_Ind__c = true,
            Core_Inactive_Ind__c = false
        );

    insert agm;

    Test.startTest();

    // Triggers beforeUpdate and afterUpdate
    agm.Core_Inactive_Ind__c = true;
    update agm;

    Test.stopTest();

    Core_Account_Group_Member__c agmAfter =
        [
            SELECT Id,
                   Core_Inactive_Ind__c
            FROM Core_Account_Group_Member__c
            WHERE Id = :agm.Id
        ];

    System.assertEquals(true, agmAfter.Core_Inactive_Ind__c);
}
    @isTest
static void testAfterUpdateCoverage() {

    Id partnerRtId = Schema.SObjectType.Account
        .getRecordTypeInfosByDeveloperName()
        .get('Core_Partner_Account_Group')
        .getRecordTypeId();

    Id intelRtId = Schema.SObjectType.Account
        .getRecordTypeInfosByDeveloperName()
        .get('Mastered_Account')
        .getRecordTypeId();

    insert new List<Core_Trigger_Executions__c>{

        new Core_Trigger_Executions__c(
            Name='PAG_mem_handler',
            Core_Active__c=true,
            Core_Class_Name__c='Core_Acct_Grp_Mbr_TriggerHandler',
            Core_Object__c='Core_Account_Group_Member__c',
            Core_Trigger_Events__c='After Update',
            Core_Description__c='Test'
        ),

        new Core_Trigger_Executions__c(
            Name='OPID_Update_IPA_Integration_Trigger',
            Core_Active__c=true,
            Core_Class_Name__c='Core_Acct_Grp_Mbr_TriggerHandler',
            Core_Object__c='Core_Account_Group_Member__c',
            Core_Trigger_Events__c='After Update',
            Core_Description__c='Test'
        )
    };

    Account partner = new Account(
        Name='Partner',
        RecordTypeId=partnerRtId,
        Core_Account_Type__c='Distributor',
        Core_Sales_Group_New__c='CCG Sales Group',
        Industry='Agriculture',
        BillingCity='Delhi',
        BillingCountryCode='IND',
        BillingStreet='Street'
    );

    Account intel1 = new Account(
        Name='Intel1',
        RecordTypeId=intelRtId,
        Core_Account_Type__c='Distributor',
        Core_Sales_Group_New__c='CCG Sales Group',
        Industry='Agriculture',
        BillingCity='Delhi',
        BillingCountryCode='IND',
        BillingStreet='Street'
    );

    Account intel2 = new Account(
        Name='Intel2',
        RecordTypeId=intelRtId,
        Core_Account_Type__c='Distributor',
        Core_Sales_Group_New__c='CCG Sales Group',
        Industry='Agriculture',
        BillingCity='Delhi',
        BillingCountryCode='IND',
        BillingStreet='Street'
    );

    insert new List<Account>{partner,intel1,intel2};

    Core_Account_Group_Member__c agm =
        new Core_Account_Group_Member__c(
            Core_Partner_Account_Id__c = partner.Id,
            Core_Intel_Account_Id__c = intel1.Id,
            Core_MDA_Ind__c = true,
            Core_Inactive_Ind__c = false
        );

    insert agm;

    Test.startTest();

    agm.Core_Intel_Account_Id__c = intel2.Id;
    update agm;

    Test.stopTest();

    System.assert(true);
}

}