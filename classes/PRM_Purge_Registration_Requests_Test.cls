@isTest
public class PRM_Purge_Registration_Requests_Test {
    //Commenting as Registration request purging no more needed
    @isTest
    public static void validateRegRequests(){
        Test.startTest();
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        System.debug('Channel Prog '+cp);
        
        PRM_Registration_Request__c regRequest = new PRM_Registration_Request__c();
        regRequest.RecordTypeId=Schema.getGlobalDescribe().get('PRM_Registration_Request__c').getDescribe().getRecordTypeInfosByDeveloperName().get(System.Label.PRM_Email_Verification_Request).getRecordTypeId();
        regRequest.Name = 'RR1';
        regRequest.PRM_First_Name__c = 'Test Request';
        regRequest.PRM_Last_Name__c = 'New';
        regRequest.PRM_Email_ID__c = 'testrequest@mailinator.com';
        regRequest.PRM_Preferred_Language__c='ENG';
        regRequest.createdDate = Datetime.newInstance(2020, 10, 15);
        regRequest.PRM_Channel_Program__c = cp.id;
        regRequest.PRM_Email_Verification_Criteria__c = 'PENDING';
        regRequest.PRM_Status__c = 'New';
        insert regRequest;
        System.debug('regRequest-> '+regRequest);
        System.debug('regRequest.CreatedDate '+regRequest.CreatedDate);
        System.debug('regRequest.PRM_Email_Verification_Criteria__c '+regRequest.PRM_Email_Verification_Criteria__c);
        System.debug('regRequest.PRM_Status__c '+regRequest.PRM_Status__c);
        System.debug('regRequest.PRM_Channel_Program__r.Name '+regRequest.PRM_Channel_Program__r.Name);
        List<PRM_Registration_Request__c> purgeRegreqsList = new List<PRM_Registration_Request__c>([select id, PRM_Status__c, 
                                                                                                    PRM_Email_Verification_Criteria__c, PRM_Channel_Program__c, 
                                                                                                    PRM_Channel_Program__r.name from PRM_Registration_Request__c 
                                                                                                    where CreatedDate < LAST_N_DAYS:46 
                                                                                                    and PRM_Email_Verification_Criteria__c = 'Pending' and PRM_Status__c = 'New']);
        System.debug('purgeRegreqsList Size '+purgeRegreqsList.size()+' purgeRegreqsList '+purgeRegreqsList);
        regRequest.PRM_Email_Verification_Criteria__c = 'PENDING';
        update regRequest;
        List<PRM_Registration_Request__c> regReqList=new List<PRM_Registration_Request__c>();
        regReqList.add(regRequest);
        //PRM_Purge_RegReq_Schedular testsche = new PRM_Purge_RegReq_Schedular();
        //String sch = '0 0 12 * * ?';
        //system.schedule('Test status Check', sch, testsche );
        PRM_Purge_Registration_Requests.purgeRecords(regReqList);
        Test.stopTest();
    }
    
    @isTest
    public static void validateACRandACMRecords(){
        Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        
        Account newAccount = new Account();//Account
        newAccount.RecordTypeId = recordTypeIdAccount;
        newAccount.Name='Greg Thomas';
        newAccount.BillingCity='City';
        newAccount.BillingStreet='Street';
        newAccount.BillingCountry='India';
        newAccount.BillingPostalCode='Postal code';
        newAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newAccount;
        
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        insert newPagAccount;
        system.assertEquals('Greg Thomas',newPagAccount.Name);
        
        /*Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
coreAccnt.Core_Intel_Account_Id__c = newAccount.id;
insert coreAccnt;*/
        
        Contact cont = new Contact();  //Contact  
        cont.AccountId=newAccount.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        // cont.Core_IPA_Partner_Role__c = 'Service Provider';
        cont.Core_IPA_PartnerRole__c = 'Service Provider';
        cont.MailingCountry='USA';
        insert cont;
        
        ChannelProgram cp = new ChannelProgram(); //Channel Program
        cp.Name='Intel Partner Alliance';
        cp.PRM_programCode__c='IPA';
        insert cp;
        
        ChannelProgramLevel cpl=new ChannelProgramLevel(); //Channel Program Level
        cpl.Name='Titanium';
        cpl.ProgramId=cp.Id;
        insert cpl;
        
        
        Profile pId = [select id from Profile where Name ='IT Admin' ];
        User u = new User(Alias = 'imavgim', Email='testuserim@apttus.com', LastName='Man', FirstName='Iron',
        EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles',
        UserName='testuserim@avenger.com', ProfileId = pId.Id);
        insert u;
        
        
        PRM_ContactRelationships__c contRelation = new PRM_ContactRelationships__c();   //Contact Relationship
        System.runAs(u){
            contRelation.Name='Primary Contact';
            contRelation.PRM_Contact_Relationship_Cd__c ='RELTNPRCTC';
            contRelation.PRM_Channel_Program_Id__c = cp.Id;
            contRelation.PRM_Default_Relationship_Ind__c = true;
            insert contRelation;
            contRelation.Name='Primary Contact1';
        	update contRelation;
        }
        
		
        
        PRM_Account_Contact_Relationship__c acctContRel=new PRM_Account_Contact_Relationship__c(); //Account Contact Relationship
        acctContRel.PRM_Account_Id__c=newAccount.Id;
        acctContRel.PRM_Contact_Id__c=cont.Id;
        acctContRel.PRM_Relationship_Id__c=contRelation.Id;
        acctContRel.PRM_InActive_Ind__c=false;
        acctContRel.PRM_Status_Nm__c ='Pending Action';
        acctcontRel.createdDate = Datetime.newInstance(2020, 10, 15);
        insert acctContRel;
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        System.runAs(u){
            acm.PRM_Account_Id__c=newAccount.id;
            acm.PRM_Status_Nm__c='Pending';
            acm.PRM_Channel_Program_Id__c=cp.Id;
            acm.PRM_Channel_Program_Level_Id__c=cpl.Id;
            acm.PRM_Partner_Role__c='Service Provider';
            acm.PRM_Status_Nm__c = 'Pending';
            insert acm;
            acm.PRM_Partner_Role__c='Distributor';
            update acm;
        }

     	Datetime acmrecDate = System.now().addDays(-25);
        Test.setCreatedDate(acm.Id, acmrecDate);
        
        Test.startTest();
        PRM_AccountChannelMembership__c acct1 = [Select Id, CreatedDate, LastModifiedDate from PRM_AccountChannelMembership__c where Id=:acm.id];
        System.debug('test' +acct1.CreatedDate);
        PRM_AccountChannelMembership__c acct = [Select Id, CreatedDate, LastModifiedDate from PRM_AccountChannelMembership__c where Id=:acm.id];
        System.debug('test' +acct);
        List<PRM_Account_Contact_Relationship__c> acrReqList=new List<PRM_Account_Contact_Relationship__c>();
        acrReqList.add(acctContRel);
        PRM_Purge_PCR_ACM_Requests.purgeRecords(acrReqList);
        PRM_Purge_PCR_ACM_Requests_Batch testsche = new PRM_Purge_PCR_ACM_Requests_Batch();
        String sch = '0 0 12 * * ?';
        system.schedule('Test status Check', sch, testsche );
        try{
           PRM_Purge_PCR_ACM_Requests.purgeRecords(null); 
        }catch(exception ex){
            System.debug('exception'+ex);
        }
        
        Test.stopTest();
    }
    
}