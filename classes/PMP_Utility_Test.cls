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
        
        
    }

    @isTest
    public static void getAdminTest(){
    
      Group grp=[SELECT Id FROM Group where Name='All Users - IPA Internal PMP Admin' LIMIT 1];
      
      List<GroupMember> groupMembers=[SELECT UserOrGroupId FROM GroupMember where GroupId=:grp.Id];
      
      User u = [Select id, name, email from User where id=: UserInfo.getUserId()];
      List<ID> contentDocumentIds = new List<ID>();
      User uObj = PMP_TestDataUtility.createUser(true);
      List<PMP_Company__c> companyList = new List<PMP_Company__c>();
        PMP_Company__c companyInfo = PMP_TestDataUtility.createCompanyInformation('test intel company', uObj.Contact.AccountId, true);
        companyList.add(companyInfo);
        PMP_Partner_Offering__c offObj = PMP_TestDataUtility.createOffering('test offering for test class',
                                                                           'public content','Test desc',companyInfo.Id,true,'Draft','test tagline');
		PMP_Utility.isUserUnderSamePartner(offObj); 
      system.runAs(u){
          boolean isAdmin = PMP_Utility.isLoggedInUserAdmin();         
      }
      List<ContentDistribution> contentDistributionList1 = PMP_Utility.getContentDownloadUrls(contentDocumentIds);
      List<ContentDistribution> contentDistributionList2 = PMP_Utility.getContentDownloadUrlData(contentDocumentIds);
      //Boolean isUserInSameCompany = PMP_Utility.isUserInSameCompany(offObj);
              
      PMP_Utility.isIntelEmployee();
      Boolean isLoggedInUserAnonymous = PMP_Utility.isLoggedInUserAnonymous();
      Map<String,String> getLocaleFields = PMP_Utility.getLocaleFields('Partner Offering','en_US');
      List<PMP_Locale_To_FieldAPINm_Mapping__mdt> getLocaleToFieldMdtRecordsByField = PMP_Utility.getLocaleToFieldMdtRecordsByField('en_US','Field');
      Map<String,Object> mapSpec = new Map<String,Object>();
      Integer getLeafNode = PMP_Utility.getLeafNode(mapSpec);
      ContentDistribution content = new ContentDistribution();
      ContentVersion createContentVersion = PMP_Utility.createContentVersion(content,Blob.valueOf('Thumnail'));
      System.assertEquals(offObj.PMP_Company_Id__c, companyInfo.Id);
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
        Account intelAccountwithMDA = PMP_TestDataUtility.createIntelAccount('Intel Account10A',devRecordTypeId,true);
        Contact contactWithMDA = PMP_TestDataUtility.createContact(intelAccountwithMDA.id,true);
        //mda end
        
        //partner acc start
        devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner Account Group').getRecordTypeId();
        //Account partnerAccount = PMP_TestDataUtility.createIntelAccount('Partner Account10',devRecordTypeId,true);
        Account partnerAccount = new Account();
        partnerAccount.RecordTypeId = devRecordTypeId;
        partnerAccount.Name = 'Partner Account10';       
        partnerAccount.Core_Account_Country__c='India';
        partnerAccount.Core_Sales_Groups__c='US Sales Group';
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
        Core_Account_Group_Member__c pag=new Core_Account_Group_Member__c();
        pag.Core_Partner_Account_Id__c=partnerAccount.Id;
        pag.Core_MDA_Ind__c=false;
        pag.Core_Intel_Account_Id__c=intelAccount.Id;
        insert pag;
        system.debug('pag:'+pag.Id);
        system.debug('account2:'+pag.Core_Intel_Account_Id__c);
        
        
        //mda
        Core_Account_Group_Member__c pagMDA=new Core_Account_Group_Member__c();
        pagMDA.Core_Partner_Account_Id__c=partnerAccount.Id;
        pagMDA.Core_MDA_Ind__c=true;
        pagMDA.Core_Intel_Account_Id__c=intelAccountwithMDA.Id;
        insert pagMDA;
        
        /*Core_Account_Group_Member__c pag1=new Core_Account_Group_Member__c();
        pag1.Core_Partner_Account_Id__c=pagMDA.Core_Partner_Account_Id__c;
        pag1.Core_MDA_Ind__c=true;
        pag1.Core_Intel_Account_Id__c=intelAccount.Id;
        insert pag1;*/
        
        
        PMP_Company__c company=new PMP_Company__c();
        company.Name=partnerAccount.Name;
        company.PMP_Account_Id__c=partnerAccount.Id;
        company.PMP_Is_Published_Ind__c=true;
        insert company;
        
        PMP_Company__c cmp1 = PMP_TestDataUtility.createCompanyInformation('TestCompany1', intelAccount.Id, true);
        PMP_Partner_Offering__c offering1 = PMP_TestDataUtility.createOffering('TestDuplicateOffering','Public Content', 
                                                                               'TestDuplicate',cmp1.Id, true,'Published','');
       // offering1.PMP_Company_Id__c=intelAccount.Id;
       // update offering1;
        System.runAs(poeUser) {
            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name='PMP_External_Partner_Admin'];
            PermissionSetAssignment psa = new PermissionSetAssignment(
                AssigneeId = poeUser.Id,
                PermissionSetId = ps.Id
            );
            insert psa;
            
            Boolean isUnderSamePartner = PMP_Utility.isUserUnderSamePartner(offering1);
            System.assertEquals(false, isUnderSamePartner);
        }

        Test.stopTest();
    }
    
    static testMethod void getOfferingTranslationRecordsTest(){
        Test.startTest();
        Account acc1=PMP_TestDataUtility.createIntelAccount('account1',PMP_TestDataUtility.intel_Account_Record_Type,true);
        PMP_Company__c cmp1=PMP_TestDataUtility.createCompanyInformation('TestCompny1',acc1.Id,true);
        PMP_Partner_Offering__c off1=PMP_TestDataUtility.createOffering('offering1','Public Content','abc is xyz',cmp1.Id,true,'Draft','');
        PMP_Partner_Offering_Translation__c existingTranslation = PMP_TestDataUtility.createOfferingTranslation(off1.Id,'translatedName');
        insert existingTranslation;
        List<PMP_Partner_Offering_Translation__c> translationRecords = PMP_Utility.getOfferingTranslationRecords(off1.Id);
        System.debug('translist-->'+translationRecords);
        System.assertEquals('translatedName', translationRecords[0].Name);
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
        
        ContentDistribution cd = new ContentDistribution(Name='test0', ContentVersionId=contentVersion_2.Id);
        insert cd;
        
        System.debug('contentDocumentId-->'+contentDocumentIds);
        List<ContentDistribution> distributionData = [SELECT Id, Name, ContentVersionId, ContentDocumentId, RelatedRecordId, 
                                                        DistributionPublicUrl, ContentDownloadUrl FROM ContentDistribution 
                                                        WHERE ContentDocumentId IN :contentDocumentIds];
        //List<ContentDistribution> contentDistributionList2 = PMP_Utility.getContentDownloadUrlData(contentDocumentIds);
        System.debug('distributionrecords--->'+distributionData);
        PMP_Utility.creatFailedCalloutLogEntryRecord(distributionData[0].RelatedRecordId,'PMP_ImageResizeService','PMP','PMP_Partner_Offering_Resource__c');
        Test.stopTest();
    }
    
    static testMethod void getLoggedInUSersLanguageTest(){
        String language = PMP_Utility.getLoggedInUsersLanguage();
        
        System.assertEquals(userInfo.getLanguage(), language);
    }
    
    static testMethod void isTranslationRequired(){
        List<PMP_Partner_Offering__c> offList = New List<PMP_Partner_Offering__c >();
        PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('Testoffering', 'Public Content','off desc',null,false,'draft','taglineTest' );
		PMP_Business_Segments__mdt cmd = [SELECT DeveloperName FROM PMP_Business_Segments__mdt where DeveloperName='IoT'];
        offering.PMP_Business_Segment_Nm__c = 'IoT';
        insert offering;
        PMP_Utility.isTranslationRequired(offering);
    }
    
    static testMethod void queryAllFieldsTest(){
        String query = PMP_Utility.queryAllFields('PMP_Partner_Offering__c',true);        
        System.assertNotEquals(query, null);
    }
    
    static testMethod void getContentDocumentLinkInstanceTest(){
        PMP_Partner_Offering__c offering = PMP_TestDataUtility.createOffering('Testoffering', 'Public Content','off desc',null,true,'draft','taglineTest' );
        List<ContentDocument> docs = PMP_TestDataUtility.createContentDocument(true);
        
        ContentDocumentLink cdl = PMP_Utility.getContentDocumentLinkInstance(docs[0].Id, offering.Id);
        System.assertEquals(cdl.ContentDocumentId, docs[0].Id);
        
    }
    
    static testMethod void getSpecificationSequenceNumberTest(){
        
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
    }
 }