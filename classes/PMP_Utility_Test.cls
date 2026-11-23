/****************************************************************************************************************************************
* Class Name  : PMP_Utility_Test 
* Version     : 1.0 
* Created Date: 25-06-2019
* Modification Log :
*
* Developer      Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Shahrukh     25-06-2019                    Test class of PMP_Utility
*****************************************************************************************************************************************/

@isTest
public class PMP_Utility_Test{

   @testSetup static void setup() {
       EmailTemplate validEmailTemplate = new EmailTemplate();
            validEmailTemplate.isActive = true;
            validEmailTemplate.Name = 'name';
            validEmailTemplate.Body = 'test email body';
            validEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere';
            validEmailTemplate.TemplateType = 'text';
            validEmailTemplate.FolderId = UserInfo.getUserId();
            
            insert validEmailTemplate;
        // Create common test accounts
        Group gp = new Group(Name = 'All Users - IPA Internal PMP Admin');
        insert gp;
        
        GroupMember gpm = new GroupMember();
        gpm.GroupId = gp.Id;
        gpm.UserOrGroupId = userinfo.getUserId();
        Database.insert(gpm);
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User u = PMP_TestDataUtility.createTestUser(profileId);
       
        insert u;
       
        GroupMember gpm2 = new GroupMember();
        gpm2.GroupId = gp.Id;
        gpm2.UserOrGroupId = u.id;
        Database.insert(gpm2);
         
      //User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
      
      
       
    }

    @isTest
    public static void getAdminTest(){
    Test.startTest();
      Group grp=[SELECT Id FROM Group where Name='All Users - IPA Internal PMP Admin' LIMIT 1];
      
      List<GroupMember> groupMembers=[SELECT UserOrGroupId FROM GroupMember where GroupId=:grp.Id];
      
      User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
      List<ID> contentDocumentIds = new List<ID>();
      User uObj = PMP_TestDataUtility.createUser(true);
      List<PMP_Company__c> companyList = new List<PMP_Company__c>();
        PMP_Company__c companyInfo = PMP_TestDataUtility.createCompanyInformation('test intel company', uObj.Contact.AccountId, true);
        companyList.add(companyInfo);
        //PMP_Partner_Offering__c offObj = PMP_TestDataUtility.createOffering('test offering for test class',
                                                                           //'public content','Test desc',companyInfo.Id,true,'Draft','test tagline');
       // gg//PMP_Utility.isUserUnderSamePartner(offObj); 
      system.runAs(u){
          boolean isAdmin = PMP_Utility.isLoggedInUserAdmin();  
          PMP_Utility.intelAdminGrpMembers();
      }
      //List<ContentDistribution> contentDistributionList1 = PMP_Utility.getContentDownloadUrls(contentDocumentIds);
      //List<ContentDistribution> contentDistributionList2 = PMP_Utility.getContentDownloadUrlData(contentDocumentIds);
      //Boolean isUserInSameCompany = PMP_Utility.isUserInSameCompany(offObj);
              
      PMP_Utility.isIntelEmployee();
      Boolean isLoggedInUserAnonymous = PMP_Utility.isLoggedInUserAnonymous();
      Map<String,String> getLocaleFields = PMP_Utility.getLocaleFields('Partner Offering','en_US');
      List<PMP_Locale_To_FieldAPINm_Mapping__mdt> getLocaleToFieldMdtRecordsByField = PMP_Utility.getLocaleToFieldMdtRecordsByField('en_US','Field');
      Map<String,Object> mapSpec = new Map<String,Object>();
      Integer getLeafNode = PMP_Utility.getLeafNode(mapSpec);
      //ContentDistribution content = new ContentDistribution();
      //ContentVersion createContentVersion = PMP_Utility.createContentVersion(content,Blob.valueOf('Thumnail'));
    //  System.assertEquals(offObj.PMP_Company_Id__c, companyInfo.Id);
        Test.stopTest();
    }
    
    static testMethod void getLeafNodeTest(){
        
        Test.startTest();
        String jsonStr ='';
        StaticResource srObject = [select id,body from StaticResource Where Name = 'PMP_FPGA_Attribute_Test'];
        jsonStr = srObject.body.toString();        
        
        Map<String, Object> mapSpec = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        
        Integer leafLevel = PMP_Utility.getLeafNode(mapSpec);
        System.assertEquals(3, leafLevel);
        Test.stopTest();
    }
    
    static testMethod void isUserUnderSamePartnerTest(){
        Test.startTest();
        //populate (Offered By:Company information) for Admin and Partner Users 
        //Partner USer
        
        //User context
        UserRole ur = [Select Id,PortalType, PortalAccountId From UserRole where Name='Admin' limit 1];
        User thisUSer=[Select Id,UserRoleId  from User where Id=:UserInfo.getUserId()];
        thisUSer.UserRoleId=ur.Id;
        //update thisUSer; 
        //non-mda start
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account intelAccount;
        Contact conObj;
        User poeUser;
        System.runAs(thisUser){
            update thisUSer; 
            intelAccount = PMP_TestDataUtility.createIntelAccount('Intel Account10B',devRecordTypeId,true);
            conObj = PMP_TestDataUtility.createContact(intelAccount.id,true);
            Profile prf2=[SELECT Id  FROM Profile WHERE name='Partner' limit 1];
            
            
            poeUser = new User(/*UserRoleId  = ur.Id,*/ Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                               EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                               LocaleSidKey='en_US', ProfileId = prf2.Id,
                               TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',
                               FirstName='Test'
                              );
            poeUser.ContactId=conObj.Id;
            insert poeUser;
            
            
        }

        //non-mda end
        
        
        
        //mda start
        /*Account intelAccountwithMDA = PMP_TestDataUtility.createIntelAccount('Intel Account10A',devRecordTypeId,true);
        Contact contactWithMDA = PMP_TestDataUtility.createContact(intelAccountwithMDA.id,true);*/
        //mda end
        
        //partner acc start
        devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        //Account partnerAccount = PMP_TestDataUtility.createIntelAccount('Partner Account10',devRecordTypeId,true);
        Account partnerAccount = new Account();
        partnerAccount.RecordTypeId = devRecordTypeId;
        partnerAccount.Name = 'Partner Account10';       
        partnerAccount.Core_Account_Country__c='India';
        partnerAccount.Core_Sales_Group_New__c='US Sales Group';
        partnerAccount.Core_Account_Type__c='ODM';
        partnerAccount.BillingStreet='Bangalore Central';
        partnerAccount.BillingCity='Bangalore';
        partnerAccount.BillingCountry='IND';
        partnerAccount.BillingState='KA';
        partnerAccount.BillingPostalCode='560029';
        partnerAccount.Industry='Agriculture';
        insert partnerAccount;
        //partner acc end
        
        //non-MDA
      /*  Core_Account_Group_Member__c pag=new Core_Account_Group_Member__c();
        pag.Core_Partner_Account_Id__c=partnerAccount.Id;
        //pag.Core_MDA_Ind__c=false;
        pag.Core_Intel_Account_Id__c=intelAccount.Id;
        insert pag;
        system.debug('pag:'+pag.Id);
        system.debug('account2:'+pag.Core_Intel_Account_Id__c);
        */
        
        //mda
       /* Core_Account_Group_Member__c pagMDA=new Core_Account_Group_Member__c();
        pagMDA.Core_Partner_Account_Id__c=partnerAccount.Id;
        pagMDA.Core_MDA_Ind__c=true;
        pagMDA.Core_Intel_Account_Id__c=intelAccountwithMDA.Id;
        insert pagMDA;
        
        Core_Account_Group_Member__c pag1=new Core_Account_Group_Member__c();
        pag1.Core_Partner_Account_Id__c=pagMDA.Core_Partner_Account_Id__c;
        pag1.Core_MDA_Ind__c=true;
        pag1.Core_Intel_Account_Id__c=intelAccount.Id;
        insert pag1;
        
        PMP_Company__c company=new PMP_Company__c();
        company.Name=partnerAccount.Name;
        company.PMP_Account_Id__c=partnerAccount.Id;
        company.PMP_Is_Published_Ind__c=true;
        insert company;*/
        
        prm_skip_trigger__c rec = new prm_skip_trigger__c(); //added to skip trigger error
        rec.Name = 'ABA_Trigger';
        rec.inactive__c = false;
        insert rec;
        
          PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c(); //Custom Batch Setting
        cust.Name='BatchFieldValues';
        cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
        cust.PRM_PartnerRole__c= 'Service Provider';
        cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';      
        insert cust;
        
        ChannelProgram cpIPA = new ChannelProgram(); //Channel Program
        cpIPA.Name='Intel Partner Alliance';
        cpIPA.PRM_programCode__c='IPA';
        insert cpIPA;

        ChannelProgramLevel cplTitanium=new ChannelProgramLevel(); //Channel Program Level
        cplTitanium.Name='Titanium';
        cplTitanium.ProgramId=cpIPA.Id;
        insert cplTitanium;
       
       PMP_Static_Constants__c p = new PMP_Static_Constants__c();
        p.name = 'PMP_BENEFIT_BASIC_ACCESS_CODE';
        p.PMP_Value__c = 'BNFTSMBA';
        insert p;
        
         PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=partnerAccount.Id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        insert acm;
        
        PMP_Company__c cmp1=new PMP_Company__c();
        cmp1.Name=intelAccount.Name;
        cmp1.PMP_Benefit_Update_Ind__c=False;
        cmp1.PMP_Partner_Inactive_Ind__c = False;
        cmp1.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        cmp1.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced; //IPA2.0 - TWC729-7885
        cmp1.PMP_Is_Published_Ind__c=true;
        insert cmp1;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = partnerAccount.Id;
        coreAccnt.Core_Intel_Account_Id__c = intelAccount.Id; 
        insert coreAccnt;
        
        
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= partnerAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= cmp1.Id;
        jun.Is_Active__c=true;     
        insert jun;
       // PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering','Public Content', 
         //                                                                      'TestDuplicate',cmp1.Id, true,'Published','');
        List<PMP_Company__c> compInfoList = new  List<PMP_Company__c>();
        compInfoList.add(cmp1);
          List<PermissionSetAssignment> lstcurrentUserPerSet =    [   SELECT Id, PermissionSet.Name,AssigneeId
                                                                 FROM PermissionSetAssignment
                                                                 WHERE AssigneeId = :Userinfo.getUserId() ];
       List<String> pslist = new List<String>();
        for(PermissionSetAssignment ps :lstcurrentUserPerSet){
            pslist.add(ps.PermissionSet.Name);
        }
       // offering1.PMP_Company_Id__c=intelAccount.Id;
       // update offering1;
        System.runAs(poeUser) {
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='PMP_External_Partner_Admin'];
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = poeUser.Id,
                PermissionSetId = ps.Id
            );
            insert psa;
            PMP_Utility.fetchUsersMapFromPagMember(compInfoList,pslist);
            PMP_Utility.fetchUsersMapForBasicAccessPartners(compInfoList,pslist);
            
            List<PermissionSetAssignment> ActiveUserOfPermissionSet = PMP_Utility.getActiveUserOfPermissionSet(new Set<Id>{intelAccount.Id},new List<String>{'PMP_External_Partner_Admin'});
           // Boolean isUnderSamePartner = PMP_Utility.isUserUnderSamePartner(offering1);
            //System.assertEquals(False, isUnderSamePartner);
        }

        Test.stopTest();
    }
    
    static testMethod void getOfferingTranslationRecordsTest(){
        Test.startTest();
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        //PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
       // PMP_Partner_Offering_Translation__c existingTranslation = PMP_TestDataUtility.createOfferingTranslation(off1.Id,'translatedName');
       // insert existingTranslation;
       // List<PMP_Partner_Offering_Translation__c> translationRecords = PMP_Utility.getOfferingTranslationRecords(off1.Id);
        //System.debug('translist-->'+translationRecords);
        //System.assertEquals('translatedName', translationRecords[0].Name);
        Test.stopTest();
    }
    
    static testMethod void creatFailedCalloutLogEntryRecordTest(){
        Test.startTest();
        List<ID> contentDocumentIds = new List<ID>();
        list<contentDocument> docs = PMP_TestDataUtility.createContentDocument(true);
        for(contentDocument cd : docs){
            contentDocumentIds.add(cd.Id);
        }
        
        ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = :contentDocumentIds[0] LIMIT 1];
        
          // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(400);
        //IPA2.0:US-4497-1631_OfferingEOL
        /*PMP_Utility.creatFailedCalloutLogEntryRecord(contentVersion_2.id,'PMP_ImageResizeService','PMP','PMP_Partner_Offering_Resource__c',
                                                     'Investigating',res,'parentId','parentName');
        Core_Log_Failed_Callout_Entry__c response = [select id,Core_Origin__c from Core_Log_Failed_Callout_Entry__c where Core_Origin__c='PMP_ImageResizeService' limit 1];
        
        system.assertEquals(response.Core_Origin__c,'PMP_ImageResizeService','Successful');*/
        PMP_Utility.creatFailedCalloutLogEntryRecord(contentVersion_2.id,'PMP_CompanyImageResizeService','PMP','PMP_Partner_Offering_Resource__c',
                                                     'Investigating',res,'parentId','parentName');
        Core_Log_Failed_Callout_Entry__c response = [select id,Core_Origin__c from Core_Log_Failed_Callout_Entry__c where Core_Origin__c='PMP_CompanyImageResizeService' limit 1];
        
        system.assertEquals(response.Core_Origin__c,'PMP_CompanyImageResizeService','Successful');
        Test.stopTest();
    }
    
    static testMethod void getLoggedInUSersLanguageTest(){
        Test.startTest();
        String language = PMP_Utility.getLoggedInUsersLanguage();
        
        System.assertEquals(userInfo.getLanguage(), language);
        Test.stopTest();
    }
    
    /*static testMethod void isTranslationRequired(){
        Test.startTest();
        List<PMP_Partner_Offering__c> offList = New List<PMP_Partner_Offering__c >();
        PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('Testoffering', 'Public Content','off desc',null,false,'draft','taglineTest' );
        PMP_Business_Segments__mdt cmd = [SELECT DeveloperName FROM PMP_Business_Segments__mdt where DeveloperName='IoT'];
        offering.PMP_Business_Segment_Nm__c = 'IoT';
        insert offering;
        Boolean response = PMP_Utility.isTranslationRequired(offering);
        system.assertEquals(response,true,'successful');
    	Test.stopTest();
    }*/
    
    static testMethod void queryAllFieldsTest(){
        Test.startTest();
        String query = PMP_Utility.queryAllFields('PMP_Partner_Offering__c',true);        
        System.assertNotEquals(query, null);
        Test.stopTest();
    }
    
    static testMethod void getContentDocumentLinkInstanceTest(){
        Test.startTest();
        //PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('Testoffering', 'Public Content','off desc',null,true,'draft','taglineTest' );
        List<ContentDocument> docs = PMP_TestDataUtility.createContentDocument(true);
        
        //ContentDocumentLink cdl = PMP_Utility.getContentDocumentLinkInstance(docs[0].Id, offering.Id);
        //System.assertEquals(cdl.ContentDocumentId, docs[0].Id);
        Test.stopTest();
    }
    
    static testMethod void getSpecificationSequenceNumberTest(){
        Test.startTest();
        String jsonStr = '';
        Map<String, Object> specsByLanguageCode = new Map<String, Object>();
        StaticResource NUCsStaticResource = [select id,body from StaticResource Where Name = 'NUC_Attribute_Test'];//test resource name can be moved to static constant masterdata
        jsonStr = NUCsStaticResource.body.toString();
        
        specsByLanguageCode = (Map<String, Object>)JSON.deserializeUntyped(jsonStr);//deserializing string and storing it in a Map<String, Object>
        List<Object> specNodes = (List<Object>)specsByLanguageCode.get('en_US');//get the list of specifications associated with the current language code
        Map<String, Object> specNodeByAttribute = (Map<String, Object>)specNodes[0];//fetch specNodes and use diiferent attributes to create spec and specValue records
        if(!specNodeByAttribute.isEmpty() && specNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.ChildCategories)){//if spec node is not empty and it has child specs
            List<Object> childSpecifications = (List<Object>)specNodeByAttribute.get(PMP_StaticConstants_MasterData.ChildCategories);//get all the child specs
            Map<String, Object> childSpecsByAttribute = (Map<String, Object>)childSpecifications[0];//store child specs in a map
            //if specNodeByAttribute map contains sequence and childSpecsByAttribute contains SpecValueSequence use them to create sequence number of specification 
            if(specNodeByAttribute.containsKey(PMP_StaticConstants_MasterData.Sequence) && childSpecsByAttribute.containsKey(PMP_StaticConstants_MasterData.SpecValueSequence)){
                Integer sequence = PMP_Utility.getSpecificationSequenceNumber(specNodeByAttribute, childSpecsByAttribute);
                System.assertEquals(120, sequence);
            }
        }
        Test.stopTest();
    }
    
    static testMethod void logErrorExceptionTest(){
        Test.startTest();
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        try{
            insert acc1;
        }catch(exception e){
            system.assertNotEquals(acc1.Id,Null);
            PMP_Utility.logError(e,'TestClassError');   
        }
        Test.stopTest();
    }
    
    @isTest
    static Void getBaseCommunityUrlTest(){
        String CommuntiyURL = PMP_Utility.getBaseCommunityUrl();
        system.assertNotEquals(CommuntiyURL,Null);        
    }
    
    @isTest
    static void getEmailTemplateTest(){
        EmailTemplate validEmailTemplate = [select id ,DeveloperName  from EmailTemplate where DeveloperName = 'unique_name_addSomethingSpecialHere'];
       
                    
        EmailTemplate testTemplate = PMP_Utility.getEmailTemplate(validEmailTemplate.DeveloperName);
        System.assertEquals('test email body', testTemplate.Body, 'Email body Not as expected');
    }
    @isTest
    static void getReplacedWithDynamicValue(){
        String replacedLabel = PMP_Utility.getReplacedWithDynamicValue('View all {0}  Participants', 'Test Event');
        System.assertEquals(replacedLabel, 'View all Test Event  Participants');
    }
    @isTest
    Static Void sendEmailAndLogDataTest(){
        Test.startTest();
       EmailTemplate validEmailTemplate = [select id ,DeveloperName from EmailTemplate where DeveloperName = 'unique_name_addSomethingSpecialHere'];
           
                    
        EmailTemplate testTemplate = PMP_Utility.getEmailTemplate(validEmailTemplate.DeveloperName);
        User u = [select id from user where id =:UserInfo.getUserId()];
         Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        //PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        List<PMP_Company__c> compInfoList = new  List<PMP_Company__c>();
        compInfoList.add(cmp1);
        
         //partner acc start
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        //Account partnerAccount = PMP_TestDataUtility.createIntelAccount('Partner Account10',devRecordTypeId,true);
        Account partnerAccount = new Account();
        partnerAccount.RecordTypeId = devRecordTypeId;
        partnerAccount.Name = 'Partner Account10';       
        partnerAccount.Core_Account_Country__c='India';
        partnerAccount.Core_Sales_Group_New__c='US Sales Group';
        partnerAccount.Core_Account_Type__c='ODM';
        partnerAccount.BillingStreet='Bangalore Central';
        partnerAccount.BillingCity='Bangalore';
        partnerAccount.BillingCountry='IND';
        partnerAccount.BillingState='KA';
        partnerAccount.BillingPostalCode='560029';
        partnerAccount.Industry='Agriculture';
        insert partnerAccount;
        
        Core_Account_Group_Member__c acGmp=new Core_Account_Group_Member__c();
        acGmp.Core_Intel_Account_Id__c=acc1.Id;
        acGmp.Core_Partner_Account_Id__c =partnerAccount.id;
        insert acGmp;
        
        Map<id,id> userWhatIDMap = new map<id,id>();
        Map<id,List<id>> userWhatIDListMap= new Map<id,List<id>>();
        //userWhatIDMap.put(u.id, off1.id);
        //userWhatIDListMap.put(u.id, new List<Id> {off1.id});
        userWhatIDMap.put(u.id, partnerAccount.id);
        userWhatIDListMap.put(u.id, new List<Id> {partnerAccount.id});
        List<PermissionSetAssignment> lstcurrentUserPerSet =    [   SELECT Id, PermissionSet.Name,AssigneeId
                                                                 FROM PermissionSetAssignment
                                                                 WHERE AssigneeId = :Userinfo.getUserId() ];
       List<String> pslist = new List<String>();
        for(PermissionSetAssignment ps :lstcurrentUserPerSet){
            pslist.add(ps.PermissionSet.Name);
        }
        //System.assertEquals('test email body', testTemplate.Body, 'Email body Not as expected');
        PMP_Utility.sendEmailAndLogData(validEmailTemplate.DeveloperName,userWhatIDMap);
        PMP_Utility.sendEmailAndLogDataWithBulkification(validEmailTemplate.DeveloperName,userWhatIDListMap);
        
       u.IsActive = false;
        //userWhatIDMap.put(u.id, off1.id);
        Set<Id> userList= new Set<Id>();
        userList.add(u.Id);
        PMP_Utility.removeInactiveUsers(userWhatIDMap);
        PMP_Utility.showContactPartnerButton();
        Set<Id> accId = new Set<Id>();
        accId.add(acc1.id);
        PMP_Utility.fetchUsersFromPagMember(accId,pslist);
        //PMP_Utility.getAlertToEmailSettingData('No_update_for_six_months_Profile');
        PMP_Utility.fetchUsersMapFromPagMember(compInfoList,pslist);
        system.assertNotEquals(accId.size(),0,'Successful');
        PMP_Utility.getActiveUsers(userList);
		Test.stopTest();
    }
    
    //Gireesh K
    @isTest
    Static Void getCompanyInfoForOpidTest(){
        Test.startTest();
        prm_skip_trigger__c rec = new prm_skip_trigger__c(); //added to skip trigger error
        rec.Name = 'ABA_Trigger';
        rec.inactive__c = false;
        insert rec;
        
        PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c(); //Custom Batch Setting
        cust.Name='BatchFieldValues';
        cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
        //cust.PRM_MP_Benefits__c='Sales';
        //cust.PRM_PartnerRole__c= 'Service Provider';
        cust.PRM_PartnerRole__c= 'Solution Integrator';
        cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';      
        insert cust;
        
        ChannelProgram cpIPA = new ChannelProgram(); //Channel Program
        cpIPA.Name='Intel Partner Alliance';
        cpIPA.PRM_programCode__c='IPA';
        insert cpIPA;

        ChannelProgramLevel cplTitanium=new ChannelProgramLevel(); //Channel Program Level
        //cplTitanium.Name='Titanium';
        cplTitanium.Name='Prestige';
        cplTitanium.ProgramId=cpIPA.Id;
        insert cplTitanium;
        
        PMP_Static_Constants__c p = new PMP_Static_Constants__c();
        p.name = 'PMP_BENEFIT_BASIC_ACCESS_CODE';
        p.PMP_Value__c = 'BNFTSMBA';
        insert p;

        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId(); //added
        Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account',devRecordTypeId,true);
                
        List<Account> accts = new List<Account>();
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        accts.add(newPagAccount);
        insert accts;
        
        List<PMP_Company__c> comp = new List<PMP_Company__c>();
        PMP_Company__c company=new PMP_Company__c();
        company.Name=accObj.Name;
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        company.PMP_Benefit_Update_Ind__c=False;
        company.PMP_Partner_Inactive_Ind__c = False;
        company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced; //IPA2.0 - TWC729-7885
        company.PMP_Is_Published_Ind__c=true;
        insert company;
        System.assertNotEquals(company, Null);
        
        comp.add(company);
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newPagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm.PRM_Status_Reason_Txt__c='Test';
        //acm.PRM_Partner_Role__c='Service Provider';
		acm.PRM_Partner_Role__c='Solution Integrator';
        insert acm;
        
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = accObj.id; 
        insert coreAccnt;
       
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= newPagAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true;     
        insert jun;
        
        PMP_Utility.getLoggedInUser();
        PMP_Utility.getCompanyInfoForOpid(jun.PMP_One_Partner_ID__c);
        PMP_Utility u = new PMP_Utility();
         Map<Id,List<Account>> AllAccountRelatedToMPIActive = u.getAllAccountRelatedToMPIActive(comp);
        
        Map<Id,Set<Id>> AllAccountRelatedToMPI           = u.getAllAccountRelatedToMPI(new List<Id>{company.Id});
       Map<Id,Set<Id>> AllAccountRelatedToMPIActive1     = u.getAllAccountRelatedToMPIActive(new List<Id>{company.Id});
       Map<Id,Set<Id>> AllAccountRelatedToMPIActiveList = u.getAllAccountRelatedToMPIActiveList(new List<Id>{company.Id});
        
        jun.Is_Active__c=false;     
        update jun;
       Map<Id,Set<Id>> AllAccountRelatedToMPINotActive  = u.getAllAccountRelatedToMPINotActive(new List<Id>{company.Id});
        Test.stopTest();
    }
    
    //Joydeep
     @isTest
    Static Void getListMpiIdsTest(){
        
        prm_skip_trigger__c rec = new prm_skip_trigger__c(); //added to skip trigger error
        rec.Name = 'ABA_Trigger';
        rec.inactive__c = false;
        insert rec;
        
        PRM_BatchCustomSetting__c cust = New PRM_BatchCustomSetting__c(); //Custom Batch Setting
        cust.Name='BatchFieldValues';
        cust.PRM_MP_Benefits__c='Solution Marketplace Enhanced';
        cust.PRM_PartnerRole__c= 'Service Provider';
        cust.PRM_PartnerType__c= 'Cloud Service Provider (CSP)';      
        insert cust;
        
        ChannelProgram cpIPA = new ChannelProgram(); //Channel Program
        cpIPA.Name='Intel Partner Alliance';
        cpIPA.PRM_programCode__c='IPA';
        insert cpIPA;

        ChannelProgramLevel cplTitanium=new ChannelProgramLevel(); //Channel Program Level
        //cplTitanium.Name='Titanium';
        cplTitanium.Name='Prestige';
        cplTitanium.ProgramId=cpIPA.Id;
        insert cplTitanium;
        
        PMP_Static_Constants__c p = new PMP_Static_Constants__c();
        p.name = 'PMP_BENEFIT_BASIC_ACCESS_CODE';
        p.PMP_Value__c = 'BNFTSMBA';
        insert p;

        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Id recordTypeIdPagAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId(); //added
        Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account',devRecordTypeId,true);
                
        List<Account> accts = new List<Account>();
        Account newPagAccount = new Account();//Account
        newPagAccount.RecordTypeId = recordTypeIdPagAccount;
        newPagAccount.Name='Greg Thomas';
        newPagAccount.BillingCity='City';
        newPagAccount.BillingStreet='Street';
        newPagAccount.BillingCountry='India';
        newPagAccount.BillingPostalCode='Postal code';
        newPagAccount.Core_Account_Type__c='Intel Authorized Distributor (IAD);Intel Approved Device Supplier (IADS)';
        accts.add(newPagAccount);
        insert accts;
        
         PMP_Company__c partner_wc = new PMP_Company__c(Name='workingPartner', 
                                                       PMP_Is_Working_Copy_Ind__c = true,
                                                       PMP_Is_Enabled_Lead_Gen_Nm__c = 'true',
                                                       PMP_Is_Lead_Gen_Limited_Nm__c = 'true',
                                                       PMP_Company_Lead_Gen_Language_Nm__c = 'English',
                                                       PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Admin_Review);
        insert partner_wc;
        
        PMP_Company__c Partner_pc = new PMP_Company__c(Name='pubPartner', 
                                                       PMP_Is_Published_Ind__c=true, 
                                                       PMP_Working_Copy_Id__c=partner_wc.Id,
                                                       PMP_Company_Lifecycle_Status_Nm__c = PMP_StaticConstants_Partner.Approved,
                                                       PMP_Is_Working_Copy_Ind__c = false);
        insert Partner_pc;
        partner_wc.PMP_Published_Copy_Id__c = Partner_pc.Id;
        update partner_wc;
        
        
        PMP_Company__c company=new PMP_Company__c();
        company.Name=accObj.Name;
        //company.PMP_Account_Id__c=accObj.id;
        //company.PMP_One_Partner_ID__c = newPagAccount.id; //linked pag with intel account
        company.PMP_Benefit_Update_Ind__c=False;
        company.PMP_Partner_Inactive_Ind__c = False;
        company.PMP_Company_Lifecycle_Status_Nm__c =PMP_StaticConstants_Partner.Published;
        company.PMP_Partner_Benefit_Type__c = PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced; //IPA2.0 - TWC729-7885
        company.PMP_Is_Published_Ind__c=true;
        company.PMP_Published_Copy_Id__c=Partner_pc.Id;
        company.PMP_Working_Copy_Id__c=partner_wc.Id;
        insert company;
        System.assertNotEquals(company, Null);
        
        PRM_AccountChannelMembership__c acm= new PRM_AccountChannelMembership__c(); //Account Channel Membership
        acm.PRM_Account_Id__c=newPagAccount.id;
        acm.PRM_Status_Nm__c='Approved';
        acm.PRM_Channel_Program_Id__c=cpIPA.Id;
        acm.PRM_Channel_Program_Level_Id__c=cplTitanium.Id;
        acm.PRM_Partner_Role__c='Service Provider';
        insert acm;
        
        Contact cont = new Contact(); //Contact
        cont.AccountId=accObj.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.MailingCountry='IND';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        insert cont;
        
        /*Id p = [SELECT id FROM profile WHERE Name='Partner'].Id;
        String conId = [SELECT Id FROM Contact LIMIT 1].Id;
            
        User user = new User(alias = 'test123', email='test123@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p, country='United States',IsActive =true,
        ContactId = conId,
        timezonesidkey='America/Los_Angeles', username='q32@noemail.com'
        );

        insert user;
        
        Set<Id> permission = new Set<Id>();
        List<String> pName = new List<String>();
        PermissionSet psEmployee = [SELECT id, Name from PermissionSet where Name = 'PMP_External_Partner_Admin'];
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = user.Id;
        psa.PermissionSetId = psEmployee.Id;
        insert psa;
        permission.add(accObj.Id);
        pName.add(psEmployee.Name);*/
                
        Set<Id> core = new Set<Id>();
        Core_Account_Group_Member__c coreAccnt = new Core_Account_Group_Member__c();
        coreAccnt.Core_Partner_Account_Id__c = newPagAccount.id;
        coreAccnt.Core_Intel_Account_Id__c = accObj.id; 
        insert coreAccnt;
        core.add(coreAccnt.Core_Partner_Account_Id__c);
            
        List<PMP_OPID_MPI_Rel__c> junction= new List<PMP_OPID_MPI_Rel__c>();
        Set<Id> s = new Set<Id>();
        PMP_OPID_MPI_Rel__c jun= new PMP_OPID_MPI_Rel__c();
        jun.PMP_One_Partner_ID__c= newPagAccount.Id;
        jun.PMP_Marketing_Profile_Id__c= company.Id;
        jun.Is_Active__c=true;
        junction.add(jun);
        insert junction;
        s.add(jun.PMP_One_Partner_ID__c);
        
        PMP_Utility.getLoggedInUser();
        PMP_Utility.getJunctionAccountToMpiByCompanyId(s);
        //PMP_Utility.getActiveUserOfPermissionSet(permission,pName);
        PMP_Utility.getListMpiIds(junction);
        PMP_Utility.getAllMpiIds(junction);
        PMP_Utility.getMapMpiToListAccountActive(junction);
        PMP_Utility.getJunctionAccToMpiByCompanyId(jun.PMP_Marketing_Profile_Id__c);
        PMP_Utility u = new PMP_Utility();
        u.getAllAccountRelatedToMPI_WCandPC(junction);
        u.getAccountRelatedMPIRecord(s);
        List<PMP_Company__c> mpiList = [Select Id from PMP_Company__c limit 10];
        u.getAllAccountRelatedToMPI(mpiList);
        PMP_Utility.getPagMembers(core);
    }

    //Joydeep
  /*  @isTest
    Static void FileSizeToStringTest(){
        
       // PMP_Utility.FileSizeToString(-400);
        PMP_Utility.FileSizeToString(400);
        PMP_Utility.FileSizeToString(4000);
        PMP_Utility.FileSizeToString(1049600);
        PMP_Utility.FileSizeToString(1074790400);
        
    }*/
    
    @isTest
    Static Void sendEmailAndLogDataTestForBulkification(){
       EmailTemplate validEmailTemplate = [select id ,DeveloperName from EmailTemplate where DeveloperName = 'unique_name_addSomethingSpecialHere'];
           
                    
        EmailTemplate testTemplate = PMP_Utility.getEmailTemplate(validEmailTemplate.DeveloperName);
        User u = [select id from user where id =:UserInfo.getUserId()];
         Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        //PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        List<PMP_Company__c> compInfoList = new  List<PMP_Company__c>();
        compInfoList.add(cmp1);
        
         //partner acc start
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        //Account partnerAccount = PMP_TestDataUtility.createIntelAccount('Partner Account10',devRecordTypeId,true);
        Account partnerAccount = new Account();
        partnerAccount.RecordTypeId = devRecordTypeId;
        partnerAccount.Name = 'Partner Account10';       
        partnerAccount.Core_Account_Country__c='India';
        partnerAccount.Core_Sales_Group_New__c='US Sales Group';
        partnerAccount.Core_Account_Type__c='ODM';
        partnerAccount.BillingStreet='Bangalore Central';
        partnerAccount.BillingCity='Bangalore';
        partnerAccount.BillingCountry='IND';
        partnerAccount.BillingState='KA';
        partnerAccount.BillingPostalCode='560029';
        partnerAccount.Industry='Agriculture';
        insert partnerAccount;
        
        Core_Account_Group_Member__c acGmp=new Core_Account_Group_Member__c();
        acGmp.Core_Intel_Account_Id__c=acc1.Id;
        acGmp.Core_Partner_Account_Id__c =partnerAccount.id;
        insert acGmp;
        
        Map<id,id> userWhatIDMap = new map<id,id>();
        Map<id,List<id>> userWhatIDListMap= new Map<id,List<id>>();
        //userWhatIDMap.put(u.id, off1.id);
        //userWhatIDListMap.put(u.id, new List<Id> {off1.id});
        List<PermissionSetAssignment> lstcurrentUserPerSet =    [   SELECT Id, PermissionSet.Name,AssigneeId
                                                                 FROM PermissionSetAssignment
                                                                 WHERE AssigneeId = :Userinfo.getUserId() ];
       List<String> pslist = new List<String>();
        for(PermissionSetAssignment ps :lstcurrentUserPerSet){
            pslist.add(ps.PermissionSet.Name);
        }
        //System.assertEquals('test email body', testTemplate.Body, 'Email body Not as expected');
       // PMP_Utility.sendEmailAndLogData(validEmailTemplate.DeveloperName,userWhatIDMap);
        PMP_Utility.sendEmailAndLogDataWithBulkification(validEmailTemplate.DeveloperName,userWhatIDListMap);
        PMP_Utility.sendEmailAndLogDataWithBulkification(null,null);
        integer emailLogcount = [Select count() from Core_Apex_EmailNotification__c limit 10];
        System.assertEquals(emailLogcount,0);    
        
    }
    static testMethod void clearTaxonomyPlatformCacheTest(){
        PMP_Utility.clearTaxonomyPlatformCache();
        String cacheFlag = PMP_Utility.getValue('Taxonomy_CacheFlag');
        System.assertNotEquals(Null, cacheFlag,'cacheFlag');
    }
    
    @isTest
    Static Void fetchEmailTemplateTest(){
       EmailTemplate validEmailTemplate = [select id ,DeveloperName from EmailTemplate where DeveloperName = 'unique_name_addSomethingSpecialHere'];
       EmailTemplate template = PMP_Utility.fetchEmailTemplate(validEmailTemplate.DeveloperName);
       System.assertNotEquals(Null, template,'template');
    }
    
    @isTest
    Static Void getApexEmailRecordTest(){
        Core_Apex_EmailNotification__c cnot =  New Core_Apex_EmailNotification__c();
        cnot.Name = 'test';
        cnot.Core_IsActive_Ind__c=true;
        cnot.Core_IsRecurring_Ind__c=false;
        insert cnot; 
        
       Core_Apex_EmailNotification__c notification = PMP_Utility.getApexEmailRecord('test');
       System.assertNotEquals(Null, notification,'template');
    }
    
    
    @isTest
    static void replaceLabelWithDynamicValueTest(){
        String replacedLabel = PMP_Utility.replaceLabelWithDynamicValue('View all {0}  Participants', 'Test Event');
        System.assertEquals(replacedLabel, 'View all Test Event  Participants','success');
    }
    
    
    @isTest
    static void getObjectFieldsTest(){
        DescribeSObjectResult offFields = pmp_partner_offering__c.getSObjectType().getDescribe();
        String returnQuery = PMP_Utility.getObjectFields(offFields);
        System.assertNotEquals(returnQuery, Null,'success');
    }
    
    @isTest
    static void FileSizeToStringTest(){
        String resizedVal = PMP_Utility.FileSizeToString(1220);
        PMP_Utility.FileSizeToString(400);
        PMP_Utility.FileSizeToString(4000);
        PMP_Utility.FileSizeToString(1049600);
        PMP_Utility.FileSizeToString(1074790400);
        System.assertNotEquals(resizedVal, Null,'success');
    }
   	/*IPA2.0: US-TWC729-7976*/
    /*@isTest
    static void sendEmailToIOTReadyTest(){
       		ArdiraSurvey__Survey__c survey = new ArdiraSurvey__Survey__c();
            survey.Name='test proposal';
            insert survey;
            User adminUser = new User(Id = UserInfo.GetUserId());
            ArdiraSurvey__Survey_Result__c surveyResult1=new ArdiraSurvey__Survey_Result__c();
            surveyResult1.ArdiraSurvey__Assessment_Result__c='test1';
            surveyResult1.ArdiraSurvey__Assigned_To_User__c=adminUser.Id;
            surveyResult1.ArdiraSurvey__Survey__c=survey.Id;
            surveyResult1.PSS_Solution_Submitter_UserId_Id__c=adminUser.Id;
            surveyResult1.PSS_Company_Id__c=NULL;
            surveyResult1.PSS_Proposal_Name_Txt__c ='test proposal1';
            insert surveyResult1;
            EmailTemplate validEmailTemplate = [select id ,DeveloperName  from EmailTemplate where DeveloperName = 'unique_name_addSomethingSpecialHere'];
        	PMP_Utility.sendEmailToIOTReady(validEmailTemplate.DeveloperName,new List<Id> {surveyResult1.Id});
    }*/
      
    @isTest
    static void logDmlErrors_Test() {
        Account acc1=PMP_TestDataUtility.createIntelAccount('LogDmlErrors_Account',PMP_TestDataUtility.intel_Account_Record_Type,true);

        Contact cInvalid = new Contact();
        Database.SaveResult[] saveResults = Database.insert(new List<Contact>{ cInvalid }, false);

        Account aMissing = new Account(Id = acc1.Id, Website = 'not a url'); // invalid URL format
        Database.SaveResult[] updateResults = Database.update(new List<Account>{ aMissing }, false);

        Account upsertInvalid = new Account();
        upsertInvalid.Id = '001000000000000AAA';
        Database.UpsertResult[] upsertResults = Database.upsert(new List<Account>{ upsertInvalid }, Account.Id, false);

        Account toDelete = new Account(Id = '001000000000001AAA');
        Database.DeleteResult[] deleteResults = Database.delete(new List<Account>{ toDelete }, false);
        
        List<Object> mixedResults = new List<Object>();
        mixedResults.addAll(saveResults);
        mixedResults.addAll(updateResults);
        mixedResults.addAll(upsertResults);
        mixedResults.addAll(deleteResults);

        Test.startTest();
        PMP_Utility.logDmlErrors(mixedResults, 'PMP_Utility_Test-logDmlErrors_Test');
        Test.stopTest();

        // Verify Core_Log_Entry__c records were created
        List<Core_Log_Entry__c> logs = [
            SELECT Id, Core_Message__c, Core_Origin__c, Core_Scope__c, Core_Severity__c
            FROM Core_Log_Entry__c
            WHERE Core_Scope__c = 'PMP_Utility_Test-logDmlErrors_Test'
            LIMIT 50
        ];
        System.assert(logs.size() > 0, 'Expected at least one Core_Log_Entry__c created by logDmlErrors');
    }

    
     static testMethod void sendWelcomeEmailForMPTest(){
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        Contact cont = new Contact(); //Contact
        cont.AccountId=acc1.Id;
        cont.lastName='Grill';
        cont.FirstName='Adam';
        cont.MailingCountry='IND';
        cont.email='AdamGrill@rediff.com';
        cont.Core_Job_Function__c='Branch Manager';
        cont.Core_eRPM_Language_Code__c='Eng';
        insert cont;
        
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        
        PMP_Company__c WorkingCompany = new PMP_Company__c(Name='TestCompny1', PMP_Account_Industry__c='Others', 
                                                           PMP_Company_Lifecycle_Status_Nm__c = 'Draft', PMP_Is_Working_Copy_Ind__c = true, PMP_Published_Copy_Id__c= cmp1.Id);
        insert WorkingCompany;
                
		Set<Id> ContactIds = new Set<Id>();        
		ContactIds.add(cont.Id);
        Test.startTest();
        	PMP_Utility.sendWelcomeEmailForMP(ContactIds);
        Test.stopTest();        

    }
 }