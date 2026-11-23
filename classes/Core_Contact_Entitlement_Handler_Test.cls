@isTest
public class Core_Contact_Entitlement_Handler_Test {

  static testMethod void updateContactBTtrue_Test() {
        Test.startTest();
  
            ///////////////////
            
            List<Contact> lstContacts = new List<Contact>(); 
            List<Core_Contact_Entitlement__c> lstEnt = new  List<Core_Contact_Entitlement__c>();
            List<Contact_Business_Types__c> lstBT = new  List<Contact_Business_Types__c>();
            List<PRM_VXEnttlmntMatrix__c> entMatrix = new List<PRM_VXEnttlmntMatrix__c>();
                
            Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
        	insert testAccount;
        	System.assert(true,testAccount.Core_CNDA_Number__c != null);
        
        	Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                          AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
            //,Core_IPS_Active__c = true;
            insert testContact;
            
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer1', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
        	insert cee;
        	system.assertNOTEquals(null,cee.id);
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center for Secure Conten',Core_IsActive__c=true);
        	insert entitle;
            System.assert(true,entitle.Core_Category__c!= null);
            ////    entMatrix = [Select Id, Name,PRM_Entitlement_Id__c, PRM_Entitlement_Id__r.Name, Business_Types__c, Business_Types__r.Name
            
        	PRM_VXEnttlmntMatrix__c matrix = new PRM_VXEnttlmntMatrix__c(PRM_Entitlement_Id__c =entitle.id,
                                                                         PRM_Approval_Type_Nm__c = 'Manual', PRM_IsActive_Ind__c = true);
        	
        	insert matrix;
        	System.assertNotEquals(null, matrix.Id);
        	
        	Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Developer Zone Premier', Name='DZP', Is_Active__c = true);
        	
        	insert business;
        	System.assertNotEquals(null, business.Id);
        
        	Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact.Id, Business_Types__c= business.Id);
            
            insert bType;
      		lstBT.add(bType);
      
        	System.assertNotEquals(null, bType.Id);
        
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c=entitle.id,Core_Selected__c=true,Core_Status__c = 'Complete');
        	insert ce1; 
        	System.assertNotEquals(null, ce1.Id);
        
        Test.stopTest();
        
       
    }
    
  static testMethod void updateContactBTfalse_Test() {
       
              
      		Test.startTest();
            ///////////////////
            
            List<Contact> lstContacts = new List<Contact>(); 
            Map<id, Core_Contact_Entitlement__c> lstEnt = new  Map<id, Core_Contact_Entitlement__c>();
            List<Contact_Business_Types__c> lstBT = new  List<Contact_Business_Types__c>();
            List<PRM_VXEnttlmntMatrix__c> entMatrix = new List<PRM_VXEnttlmntMatrix__c>();
                
            Account testAccount = new Account(Name='testAccountSetup', Core_Sales_Group__c='Global Accounts',
                                          Core_Account_Type__c='Other', Industry='Others',
                                          BillingStreet='1234 testAccountSetup', BillingCity='testCity1', BillingState='OR',
                                          BillingCountry='USA', BillingPostalCode='12345',Core_CNDA_Number__c = '126545',Core_IPS_Active__c = true);
        	insert testAccount;
        	System.assert(true,testAccount.Core_CNDA_Number__c != null);
        
        	Contact testContact = new Contact(FirstName='testFirstName123',Core_Set_ERPM_Status_Bypass__c = true,LastName='testLastName', Email='test1234@testing.com.testsetup',
                                          AccountId=testAccount.id,Core_Personal_Email_Indicator__c = false,Core_Enterprise_Id__c='12345',Core_AGS_Integration_Status__c='Successful',Core_IPS_Intel_Support_Owner__c =UserInfo.getUserId());
            //,Core_IPS_Active__c = true;
            insert testContact;
            
            Core_ERPM_Engagement__c cee=new Core_ERPM_Engagement__c(Name  ='Partner File Transfer1', Core_Engagement_Type__c='SEC',Core_IsActive__c=true,Core_Technical_Engagement_Code__c='PFT');
        	insert cee;
        	system.assertNOTEquals(null,cee.id);
            
            Core_Entitlement__c entitle=new Core_Entitlement__c (name ='Resource & Design Center for Secure Content', Core_Category__c='Order Management',Core_Sub_Category__c='Web Reporting',Core_Help_Text__c='Help text',Core_ERPM_Engagement_Id__c=cee.id,Core_Display_Name__c='Resource & Design Center for Secure Conten',Core_IsActive__c=true);
        	insert entitle;
            System.assert(true,entitle.Core_Category__c!= null);
            ////    entMatrix = [Select Id, Name,PRM_Entitlement_Id__c, PRM_Entitlement_Id__r.Name, Business_Types__c, Business_Types__r.Name
            
        	PRM_VXEnttlmntMatrix__c matrix = new PRM_VXEnttlmntMatrix__c(PRM_Entitlement_Id__c =entitle.id,
                                                                         PRM_Approval_Type_Nm__c = 'Manual', PRM_IsActive_Ind__c = true);
        	
        	insert matrix;
        	System.assertNotEquals(null, matrix.Id);
        	
        	Business_Types__c business = new Business_Types__c(Business_Type_Code__c='Developer Zone Premier', Name='DZP', Is_Active__c = true);
        	
        	insert business;
        	System.assertNotEquals(null, business.Id);
        
        	Contact_Business_Types__c bType = new Contact_Business_Types__c(Contact__c = testContact.Id, Business_Types__c= business.Id);
            
            insert bType;
      		lstBT.add(bType);
        	System.assertNotEquals(null, bType.Id);
        
            Core_Contact_Entitlement__c ce1 = new Core_Contact_Entitlement__c(Core_Contact_Id__c=testContact.Id,Core_Entitlement_Id__c=entitle.id,Core_Selected__c= false,Core_Status__c = 'Complete');
        	insert ce1; 
      		
        	System.assertNotEquals(null, ce1.Id);
      		//lstEnt.add(ce1);

            
            Test.stopTest();
        
       
    }
  
}