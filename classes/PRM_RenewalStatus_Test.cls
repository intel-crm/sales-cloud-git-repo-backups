@isTest
public class PRM_RenewalStatus_Test {
 @isTest()
    public static void setup(){
    	
         Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();

       
        PMP_Dashboard_Tab__mdt dash=[select PRM_Partner_Role_Txt__c,PRM_Entitlement_Txt__c,PMP_Benefit_Code_Txt__c from PMP_Dashboard_Tab__mdt limit 1];
        dash.PRM_Partner_Role_Txt__c='Seller';
        dash.PRM_Entitlement_Txt__c='Employee';
        dash.PMP_Benefit_Code_Txt__c='Gold';
        
       //supdate dash;
      //  
        Profile p = [SELECT Id FROM Profile WHERE Name='Partner'];
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        //newPagAccount.BillingCountryCode='IND';   
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        newPagAccount.Core_User_Defined_Website__c = 'as.yz';
        newPagAccount.Core_Geo__c = 'ASMO';
        newPagAccount.Core_Intel_Partner_Alliance_PartnerGroup__c = true;
        insert newPagAccount;
		
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas222';
        newAccount.BillingCity='City2';
        newAccount.BillingStreet='Street2';
        newAccount.BillingCountry='India';
        //newAccount.BillingCountryCode='IND';
        newAccount.BillingPostalCode='123456';
        newAccount.BillingState='';
        //newAccount.Core_IPA_Partner_Role__c='Distributor';
        newAccount.Core_IPA_Partner_Role__c='Guest';
        newAccount.Core_IPA_Badge_Tier__c='member';
        newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        newAccount.Core_OnePartnerID__c=newPagAccount.Id;
        newAccount.Core_User_Defined_Website__c = 'abz.yz';
        newAccount.Core_Geo__c = 'ASMO';
        newAccount.Core_Intel_Partner_Alliance_PartnerGroup__c =true;
        insert newAccount;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        //Test Data for Program
        //List<ChannelProgramLevel> cplList =new List<ChannelProgramLevel>();
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Member';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        ChannelProgramLevel cpl2=new ChannelProgramLevel(); //Channel Program Level
        cpl2.Name='Gold';
        cpl2.ProgramId=cp.Id;
        insert cpl2;
        
        ChannelProgramLevel cpl3=new ChannelProgramLevel(); //Channel Program Level
        cpl3.Name='Titanium';
        cpl3.ProgramId=cp.Id;
        insert cpl3;
        
      //  insert cplList;
        
        
        Contact cont = new Contact();  //Contact  
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.MailingCountry='USA';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        // cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        insert cont;
        
        Contact con2 = new Contact();
        con2.FirstName='Ivory';
        con2.LastName='Smithy';
        con2.Email='testivorysmithy@mailinator.com';
        con2.MailingCountry='USA';
        //con2.Phone='9999779791';
        con2.AccountId = newAccount.Id;
        con2.Core_Job_Function__c='Branch Manager';
        con2.Core_IPA_PartnerRole__c = 'Seller';
        con2.Core_eRPM_Language_Code__c='Eng';        
        con2.Core_Login_Id__c = 'tuv';
        insert con2;
        
        User u = new User(Alias = 'bblac', Email='testivorysmithy@mailinator.com',EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                      LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='samuel.robert2@peoplenet.com', contactid = con2.Id);
        	
        	 Core_ERPM_Engagement__c ee = new Core_ERPM_Engagement__c();//ERPM Engagement
            ee.Name = 'Intel Partner Alliance';
            ee.Core_Technical_Engagement_Code__c = 'Intel_Partner_Alliance';
            ee.Core_Engagement_Type__c = 'SEC';
            insert ee;
        
        	List<Core_Entitlement__c> entList = new List<Core_Entitlement__c>();
            Core_Entitlement__c ed=new Core_Entitlement__c(); //Entitlement
            ed.Name='Partner Admin Delegate';
            ed.Core_Display_Name__c='Partner Admin Delegate';
            ed.Core_ERPM_Engagement_Id__c=ee.id;
            entList.add(ed);
            Core_Entitlement__c ed1=new Core_Entitlement__c(); //Entitlement
            ed1.Name='Employee';
            ed1.Core_Display_Name__c='Employee';
            ed1.Core_ERPM_Engagement_Id__c=ee.id;
            entList.add(ed1);
            insert entList;
        
           	Core_Contact_Entitlement__c ce = new Core_Contact_Entitlement__c();
           	ce.Core_Entitlement_Id__c=entList[0].Id ;
            ce.Core_Contact_Id__c =con2.Id ;
            ce.Core_Status__c='complete';
            ce.Core_Selected__c = true;
            ce.Core_Source__c = 'Entitlement';
        	insert ce;
        	
        	PRM_AccountChannelMembership__c acm=new PRM_AccountChannelMembership__c();
            acm.PRM_Account_Id__c=newAccount.id;
            acm.PRM_Channel_Program_Id__c=cp.id;
            acm.PRM_Status_Nm__c='Approved';
        	acm.PRM_Channel_Program_Level_Id__c = cpl2.id;
            acm.PRM_Partner_Role__c='Seller';
            insert acm;
        
        	PRM_AccountChannelMembership__c acm1=new PRM_AccountChannelMembership__c();
            acm1.PRM_Account_Id__c=newAccount.id;
            acm1.PRM_Channel_Program_Id__c=cp.id;
            acm1.PRM_Status_Nm__c='Approved';
        	acm1.PRM_Channel_Program_Level_Id__c = cpl.id;
            acm1.PRM_Partner_Role__c='Seller';
            insert acm1;
        	
        	PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
            contRelation.Name='Partner Admin';
            contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
            contRelation.PRM_Channel_Program_Id__c = cp.Id;
            contRelation.PRM_Default_Relationship_Ind__c = true;
            insert contRelation;
        
        	PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
            acctContRel.PRM_Account_Id__c=newAccount.Id;
            acctContRel.PRM_Contact_Id__c=con2.Id;
            acctContRel.PRM_Relationship_Id__c=contRelation.Id;
            acctContRel.PRM_InActive_Ind__c=false;
            acctContRel.PRM_Status_Nm__c = 'Complete';
            insert acctContRel;
            acctContRel.PRM_Status_Nm__c = 'Complete';
			update acctContRel;
        
            Test.startTest();
            system.runas(u){
            PRM_RenewalStatus.showMessage();
            PRM_RenewalStatus.showLink();
                try{
                    PRM_RenewalStatus.showMessage();
                }catch(DMLException e){
                    PRM_AccountChannelMembership__c acm2=new PRM_AccountChannelMembership__c();
                    acm2.PRM_Account_Id__c=newAccount.id;
                    acm2.PRM_Channel_Program_Id__c=cp.id;
                    acm2.PRM_Status_Nm__c='Approved';
                    acm2.PRM_Channel_Program_Level_Id__c = null;
                    acm2.PRM_Partner_Role__c=null;
                    insert acm2;
                    system.assert(e.getMessage().containsIgnoreCase('false'));
                }   
            }
            Test.stopTest();
            
        }
   
}