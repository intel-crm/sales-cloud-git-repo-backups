@IsTest
public class Core_IPS_Migrate_CustToPart_test 
{
                                   
public static testmethod void getCustomerUserIdTest() {

        
        Account accountRecord1 = new Account(Name = 'Dell Products test',Core_Account_Type__c = 'Distributor',Core_Sales_Segment__c = 'Compute',Industry = 'Banking',BillingCity = 'Delhi',BillingCountry = 'USA',billingState = 'AK',billingStreet = 'Bratislava 1',Core_IPS_Active__c = true);
        insert accountRecord1;
        
        contact con = new contact(FirstName = 'Customer',LastName='IPS',Email='customer@IPS.com',AccountId=accountRecord1.id, MailingCountry = 'India');
        insert con;
        
        Profile profile1 = [Select Id from Profile where name = 'IPS External Customer'];
        
        User user1=new User(username = 'newUser343434@yahoo.com',ProfileId = profile1.Id,ContactId = con.Id,email = 'ponneri2525@intel.com',emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='nuser',Firstname='BruceS',lastname='lastname2');      
        insert user1;
       
        ApexPages.StandardController sc = new ApexPages.standardController(con);
        Core_IPS_Migrate_CustToPartController obj = new Core_IPS_Migrate_CustToPartController(sc);
                
        List<User> userlst=[SELECT username,name,userroleid,contactid,profileid,Accountid,email,isactive from user where id=:user1.id ];
           
        Test.starttest();
        Case Caserec =  TestUtilities.getCase(); 
        insert Caserec;
        Caseshare cs=new CaseShare();
        cs.CaseAccessLevel='Edit';
        cs.CaseId=Caserec.id;        
        cs.RowCause='Manual';
        cs.UserOrGroupId =user1.id;
        insert cs;
        
        Asset Assetrec = TestUtilities.getAsset();
        insert Assetrec;
        
        AssetShare ashare = new AssetShare();
        ashare.AssetAccessLevel='Edit';
        ashare.AssetId=Assetrec.id;
        ashare.RowCause='Manual';
        ashare.UserOrGroupId=user1.id;
        insert ashare ;
        
        Core_IPS_Project__c projectrec = TestUtilities.getIpsProjectRecord();
        projectrec.Core_Status__c='Draft';
        insert projectrec;
        
        Core_IPS_Project__Share projectShare = new Core_IPS_Project__Share();
        projectShare.AccessLevel='Edit';
        projectShare.ParentId=projectrec.id;
        projectShare.RowCause='Manual';
        projectShare.UserOrGroupId=user1.id;
       
        insert projectShare;
        
        Core_IPS_Case_Interested_Party__c IntParty = new Core_IPS_Case_Interested_Party__c();
        IntParty.User__c = user1.id;  
        IntParty.Case__c = Caserec.id;                                      
        insert IntParty;
        system.assertNOTEquals(null,IntParty.id); 

        
        Core_IPS_Project__c ProjOwn = new Core_IPS_Project__c();
        ProjOwn.ownerid = user1.id;
        
        insert ProjOwn;
                
        Core_IPS_Project_Member__c ProjMem = new Core_IPS_Project_Member__c();
        ProjMem.Core_User__c = user1.id;
        ProjMem.Core_IPS_Project__c = projectrec.id;
        insert ProjMem;
        system.assertNOTEquals(null,ProjMem.id); 

        
        
        Core_Contact_Entitlement__c ce4 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=con.Id,
        Core_Entitlement_Id__c=Label.Core_Entitlement_IPS_Id,
        Core_Selected__c=true);
        insert ce4;
        system.assertNOTEquals(null,ce4.id); 
        obj.fetchCustomerRecords();      
        Test.stoptest();
     } 
     
    
                
     public static testmethod void getPartnerUserIdTest()  {

        Account accountRecord1 = new Account(Name = 'Dell Products test',Core_Account_Type__c = 'Distributor',Core_Sales_Segment__c = 'Compute',Industry = 'Banking',BillingCity = 'Delhi',BillingCountry = 'USA',billingState = 'AK',billingStreet = 'Bratislava 1',Core_IPS_Active__c = true);
        insert accountRecord1;
                      
        contact con = new contact(FirstName = 'Customer',LastName='IPS',Email='customer@IPS.com',AccountId=accountRecord1.id, MailingCountry = 'India');
        insert  con;   
        
        contact con2 = new contact(FirstName = 'Customer1',LastName='IPS2',Email='customer1@IPS2.com',AccountId=accountRecord1.id,  MailingCountry = 'India');             
        insert con2;
                                
        Profile profile1 = [Select Id from Profile where name = 'Partner'];
        
        Profile profile2 = [Select Id from Profile where name = 'IPS External Customer'];
        
        User user1=new User(username = 'newUser343434@yahoo.com',ProfileId = profile1.Id,ContactId = con.Id,email = 'ponneri2525@intel.com',emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='nuser',Firstname='BruceS',lastname='lastname2',FederationIdentifier='testFederation1',CommunityNickname ='TestCommunityName1',Core_Login_Id__c ='1234Test');      
        insert user1;      
                                       
        User user2=new User(username = 'newUser434343@yahoo.com',ProfileId = profile2.Id,ContactId = con2.Id,email = 'ponneri5252@intel.com',emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='nuser',Firstname='BruceS',lastname='lastname2',FederationIdentifier='testFederation2',CommunityNickname ='TestCommunityName2',Core_Login_Id__c ='4321Test');              
        insert user2; 
        system.assertNOTEquals(null,user2.id); 
                                            
                                                                       
        ApexPages.StandardController sc = new ApexPages.standardController(con);
        Core_IPS_Migrate_CustToPartController obj = new Core_IPS_Migrate_CustToPartController(sc);
        obj.CustUserId=user2.id;
        Test.starttest();
        Case Caserec = TestUtilities.getCase(); 
        insert Caserec;
         
        Core_IPS_Sobject_Share_Record__c sobjShare=new Core_IPS_Sobject_Share_Record__c();
        sobjShare.name='test';
        sobjShare.Core_IPS_Contact_Id__c=con.id;
        sobjShare.Core_IPS_Sobject_Type__c='CaseShare';
        sobjShare.Core_IPS_UserOrGroupId__c=user1.id;
        sobjShare.Core_IPS_Customer_User_Id__c=user2.id;
        sobjShare.Core_IPS_SobjectId__c=caseRec.id;
        sobjShare.Core_IPS_RowCause__c='Manual';
        sobjShare.Core_IPS_SobjectAccessLevel__c='Edit';
        insert sobjShare; 
       
        Asset Assetrec = TestUtilities.getAsset();
        insert Assetrec;
       
        Core_IPS_Sobject_Share_Record__c  sobjAssetShare = new Core_IPS_Sobject_Share_Record__c();
        sobjAssetShare.name='test2';
        sobjAssetShare.Core_IPS_Contact_Id__c=con.id;
        sobjAssetShare.Core_IPS_Sobject_Type__c='AssetShare';
        sobjAssetShare.Core_IPS_UserOrGroupId__c=user2.id;
        sobjAssetShare.Core_IPS_Customer_User_Id__c=user2.id;
        sobjAssetShare.Core_IPS_SobjectId__c = Assetrec.id;
        sobjAssetShare.Core_IPS_RowCause__c='Manual';
        sobjAssetShare.Core_IPS_SobjectAccessLevel__c='Edit';
        insert sobjAssetShare;
        system.assertNOTEquals(null,sobjAssetShare.id); 
        
        Core_IPS_Sobject_Share_Record__c  sobjconinfo = new Core_IPS_Sobject_Share_Record__c();
        sobjconinfo.name='test3';
        sobjconinfo.Core_IPS_Contact_Id__c=con.id;
        sobjconinfo.Core_IPS_Sobject_Type__c='CustomerUserinfo';
        sobjconinfo.Core_IPS_Customer_User_Id__c=user2.id;
        sobjconinfo.Core_IPS_SobjectId__c = con.id;
        insert sobjconinfo;
        system.assertNOTEquals(null,sobjconinfo.id); 
        
        
        Core_IPS_Project__c projectrec = TestUtilities.getIpsProjectRecord();
        projectrec.Core_Status__c='Draft';
        insert projectrec;
        
        
        Core_IPS_Case_Interested_Party__c IntParty = new Core_IPS_Case_Interested_Party__c();
        IntParty.User__c = user2.id;  
        IntParty.Case__c = Caserec.id;                              
        insert IntParty;
        
        Core_IPS_Project__c ProjOwn = new Core_IPS_Project__c();
        ProjOwn.ownerid = user2.id;
        
        Core_IPS_Project_Member__c ProjMem = new Core_IPS_Project_Member__c();
        ProjMem.Core_User__c = user2.id;
        ProjMem.Core_IPS_Project__c = projectrec.id;
      //  insert ProjMem;
        
        Core_IPS_Sobject_Share_Record__c  sobjProjShare = new Core_IPS_Sobject_Share_Record__c();
        sobjProjShare.name='test1';
        sobjProjShare.Core_IPS_Contact_Id__c=con.id;
        sobjProjShare.Core_IPS_Sobject_Type__c='ProjectShare';
        sobjProjShare.Core_IPS_UserOrGroupId__c=user1.id;
        sobjProjShare.Core_IPS_Customer_User_Id__c=user2.id;
        sobjProjShare.Core_IPS_RowCause__c='Manual';
        sobjProjShare.Core_IPS_SobjectId__c = projectrec.id;
        sobjProjShare.Core_IPS_SobjectAccessLevel__c='Edit';
        insert sobjProjShare;
        system.assertNOTEquals(null,sobjProjShare.id); 

        User thisUser = [ select Id from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        System.runAs ( thisUser ) {
            obj.updateUser();
        }
        obj.updateShareForPartner();
      
        try{
             obj.fetchCustomerRecords();
            
        }catch(Exception e){}
        
        Test.stoptest();    
        
        } 
public static testmethod void createPartnerTest() {

                                    
        Account accountRecord1 = new Account(Name = 'Dell Products test',Core_Account_Type__c = 'Distributor',Core_Sales_Segment__c = 'Compute',Industry = 'Banking',BillingCity = 'Delhi',BillingCountry = 'USA',billingState = 'AK',billingStreet = 'Bratislava 1',Core_IPS_Active__c = true);
        insert accountRecord1;
        
        contact con = new contact(FirstName = 'Customer1',LastName='IPS',Email='customer@inteltest.com',AccountId=accountRecord1.id,  MailingCountry = 'India');
        insert con;
         
        contact con3 = new contact(FirstName = 'Customer2',LastName='IPS2',Email='customer2@inteltest2.com',AccountId=accountRecord1.id,  MailingCountry = 'India');
        insert con3; 
                                                            
        Profile profile1 = [Select Id from Profile where name = 'IPS External Customer'];
        
        User user1=new User(username = 'newUser3434345@yahoo.com',ContactId = con.Id,ProfileId = profile1.Id,email = 'ponneri25256@intel.com',emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',timezonesidkey = 'America/Los_Angeles',alias='nuser',Firstname='BruceS',lastname='lastname2',IsActive=false);      
        insert user1;
                        
        ApexPages.StandardController sc = new ApexPages.standardController(con3);
        Core_IPS_Migrate_CustToPartController obj = new Core_IPS_Migrate_CustToPartController(sc);
        
    	
        Test.starttest();
        User thisUser = [ select Id from User where Profile.Name = 'System Administrator' and IsActive = true limit 1];
        System.runAs ( thisUser ) {
            obj.updateUser();
        }
        obj.fetchCustomerRecords();      
        Core_IPS_Sobject_Share_Record__c sobjShare=new Core_IPS_Sobject_Share_Record__c();
        sobjShare.Core_IPS_Contact_Id__c=con3.Id;
        sobjShare.Core_IPS_Sobject_Type__c='ProjectShare';
        sobjShare.Core_IPS_Customer_User_Id__c=user1.id;        
        sobjShare.Core_IPS_RowCause__c='Manual';
        sobjShare.Core_IPS_SobjectAccessLevel__c='Edit';
        sobjShare.Core_IPS_UserOrGroupId__c=user1.id;
        insert sobjShare; 
        system.assertNOTEquals(null,sobjShare.id); 

        obj.createPartner();
        
        Test.stoptest();
     }     
            
}