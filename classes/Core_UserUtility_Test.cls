@isTest
public class Core_UserUtility_Test {
    @isTest
    public static void InactivateAcrOnContactTest(){
        Test.startTest();       
        Account newAccount = new Account();//Account
        newAccount.Name='John Rick';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Cloud Service Provider (CSP)';
        insert newAccount;
        
        System.debug('first account'+newAccount);
        
        List<Contact> con = new List<Contact>();
        Contact cont = new Contact();  //Contact
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='lms.contact1@intel.com.crm.testclass';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.Core_Login_Id__c = 'abc';
        cont.Core_Enterprise_Id__c = '23456';
        insert cont;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs ( thisUser ) {
            User User1 = new User(UserName = 'lms.contact1@intel.com.crm.testclass', LastName = 'Grill', Email = 'lms.contact1@intel.com.crm.testclass',
                                  Alias = 'tlms1', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'UTF-8',
                                  ProfileId = Label.Core_Partner_Profile_Id, LanguageLocaleKey = 'en_US', CommunityNickname = 'LMSUser1',
                                  PortalRole = 'Manager', ContactId = cont.id, IsActive = True, Core_Login_Id__c = 'lms');
            
            insert User1;
            
            
            ChannelProgram cp = new ChannelProgram();
            cp.Name='Intel Partner Alliance';
            cp.PRM_programCode__c='IPA';
            insert cp;
            
            List<PRM_ContactRelationships__c> crList = new List<PRM_ContactRelationships__c>();
            
            PRM_ContactRelationships__c cr1=new PRM_ContactRelationships__c();
            cr1.Name=System.Label.PRM_Primary_Contact;
            cr1.PRM_Contact_Relationship_Cd__c='RELTNPRCTC';
            cr1.PRM_Default_Relationship_Ind__c = false;
            cr1.PRM_Mandatory_Relationship_Ind__c = true;
            cr1.PRM_Channel_Program_Id__c=cp.Id;
            cr1.PRM_InActive_Ind__c = false;
            crList.add(cr1);
            
            PRM_ContactRelationships__c cr2=new PRM_ContactRelationships__c();
            cr2.Name=System.Label.PRM_WorksFor;
            cr2.PRM_Contact_Relationship_Cd__c='WORKSFOR';
            cr2.PRM_Default_Relationship_Ind__c = true;
            cr2.PRM_Mandatory_Relationship_Ind__c = false;
            cr2.PRM_InActive_Ind__c = false;
            cr2.PRM_Channel_Program_Id__c=cp.Id;
            crList.add(cr2);
            insert crList;
            
            ChannelProgramLevel cpl=new ChannelProgramLevel();
            cpl.Name='Member';
            cpl.ProgramId=cp.Id;
            insert cpl;
            
            PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c();
            acm.PRM_Account_Id__c=newAccount.id;
            acm.PRM_Status_Nm__c='Approved';
            acm.PRM_Channel_Program_Id__c=cp.Id;
            acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
            acm.PRM_Partner_Role__c='Seller';
            insert acm;
            
            PRM_Account_Contact_Relationship__c acr=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
            acr.PRM_InActive_Ind__c= false;
            acr.PRM_Account_Id__c=newAccount.Id;
            acr.PRM_Relationship_Id__c = crList[0].Id;
            acr.PRM_Contact_Id__c=cont.Id;
            acr.PRM_execute_trigger__c=true;
            acr.PRM_Start_Date_Dt__c= system.today()-2; 
            acr.PRM_End_Date_Dt__c= acr.PRM_Start_Date_Dt__c+1;  
            insert acr;
            System.debug('acr--1>'+acr); 
            
            PRM_Account_Contact_Relationship__c acr1=new PRM_Account_Contact_Relationship__c();//Account Contact Relationship
            acr1.PRM_InActive_Ind__c= false;
            acr1.PRM_Account_Id__c=newAccount.Id;
            acr1.PRM_Relationship_Id__c = crList[1].Id;
            acr1.PRM_Contact_Id__c=cont.Id;
            acr1.PRM_execute_trigger__c=true;
            insert acr1;

            List<User>lstUserToUpdate = new List<User>();
            try{    
                User1.IsActive = False;
                User1.Core_Login_Id__c = '';
                //update User1;
                lstUserToUpdate.add(User1);
                update lstUserToUpdate;
                Core_UserUtility.InactivateAcrOnContact(lstUserToUpdate);
        
            }
            catch(Exception e){
                System.debug('Exception Occured');
            }
            
            Test.stopTest();
            
            System.assertEquals(acr.PRM_Account_Id__c,newAccount.Id,'Value does not match');   
        }
    }
}