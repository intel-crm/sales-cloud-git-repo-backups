@isTest
public class PMP_SearchTestDataFactory {

    public static Id Partner_Account_Record_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Core_Partner_Account_Group').getRecordTypeId();
    public static Id intel_Account_Record_Type = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
    public static Id intel_Contact_Record_Type = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Core_Intel_Contact').getRecordTypeId();
    
    public static User createUser(Boolean isInsert){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //UserRole ur = [Select Id, Name From UserRole limit 1];
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account',devRecordTypeId,true);
        Contact conObj = PMP_TestDataUtility.createContact(accObj.id,true);
        User testUser = new User(/**UserRoleId  = ur.Id,**/Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test', Contact = conObj);
        if(isInsert){
            
            insert testUser;
        }
        return testUser;
    }
    
    public static Account createIntelAccount(String accountName, Id accountRecordTypeId, Boolean isInsert){
        
        Account testAccount = new Account(Name = accountName , RecordTypeId = accountRecordTypeId,Core_Account_Type__c='Other',
                                          BillingCity='Bangalore', BillingCountry='IND', BillingStreet = 'TestStreet');
        if(isInsert){
            insert testAccount;
        }
        return testAccount;
    }
   /***************Partner and related objects **********************/ 
    public static PMP_Company__c createCompanyInformation(string companyName, Id accountId, Boolean isInsert){
        PMP_Company__c testCompany = new PMP_Company__c(Name=companyName,PMP_Account_Industry__c='Others',PMP_Account_Id__c=accountId);
        
        if(isInsert){
            insert testCompany;
        }           
        return testCompany;
    }	
    
    public static PMP_Company_Resource__c createCompanyResource(string resourceTitle, Id companyId, String resourceType, Boolean isInsert){
        PMP_Company_Resource__c testResource = new PMP_Company_Resource__c(Name=resourceTitle,PMP_Company_Id__c=companyId,PMP_Company_Resource_Type_Nm__c=resourceType);
        
        if(isInsert){
            insert testResource;
        }           
        return testResource;
    }
    
    public static PMP_Company_Region__c createCompanyRegion(Id companyId, String region, Boolean isInsert){
        PMP_Company_Region__c testRegion = new PMP_Company_Region__c(PMP_Company_Id__c=companyId,PMP_Specification_Id__c=region);
        
        if(isInsert){
            insert testRegion;
        }           
        return testRegion;
    }
    
   
    
    /**** Creates ContentVersions for Testing Image uploads ****/
    public static ContentVersion createCompanyDocuments(Id companyId, String contentTitle, Boolean isInsert){
        
        ContentVersion testContent = new ContentVersion(Title = contentTitle,
                                                        PathOnClient = 'testContent.jpg',
                                                        VersionData = Blob.valueOf('Test Content'),
                                                        IsMajorVersion = true);
        if(isInsert){
            insert testContent;
        }           
        return testContent;
                                                            
    }
    
    /***************Partner and related objects **********************/
    
    public static PMP_Partner_Offering__c createOffering(string offeringName, string offeringVisibility, string offeringDesc, Id cmpId, Boolean isInsert, String status, String tagline){
        PMP_Partner_Offering__c testOffering = new PMP_Partner_Offering__c(PMP_Partner_Offering_Visibility_Nm__c=offeringVisibility, 
                                                                           PMP_Partner_Offering_Dsc__c=offeringDesc,
                                                                           PMP_Partner_Offering_Nm__c=offeringName, 
                                                                           PMP_Company_Id__c=cmpId, PMP_Partner_Offering_Lifecycle_Status_Nm__c=status,
                                                                           PMP_Partner_Offering_Tag_Line_Txt__c=tagline);
        
        if(isInsert){
            insert testOffering;
        }
        system.debug('offering created'); 
        return testOffering;
    }
    
    public static Contact createContact(Id accountId,Boolean isInsert){
        Contact testContact = new Contact(Salutation = 'Mr',FirstName = 'Test',LastName='Contact',
                                          Email='testcontact'+String.valueOf(Math.random())+'@CorePMP.com',
                                          AccountId=accountId,Phone='123456798');       
        if(isInsert){
            insert testContact;
        }
        
        return testContact;
    }
    
    public static list<contentDocument> createContentDocument(Boolean isInsert) {
        ContentVersion contentVersion_1 = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        if(isInsert){
            insert contentVersion_1;
            ContentVersion contentVersion_2 = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion_1.Id LIMIT 1];
            list <contentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Id = :contentVersion_2.ContentDocumentId];
            return documents;
        }
        return null;
        
    }
    
    
    
    public static Id getOffering(){
        PMP_Partner_Offering__c newOffering = new PMP_Partner_Offering__c();
        newOffering.PMP_Partner_Offering_Nm__c = 'testOffering_1';    
        insert newOffering;
        
        return newOffering.Id;
    }
    
    
    public static PMP_Partner_Offering_Category__c getPMPOfferingCategory(Id newOfferingId){
        
        PMP_Category__c newCategory=getCategory('Application', 'NPP_01_APP','NPP Taxonomy', 'en_us');        
        PMP_Partner_Offering_Category__c newPMPOfferingCat=new PMP_Partner_Offering_Category__c();
        newPMPOfferingCat.Name='2-in-1';
        newPMPOfferingCat.PMP_Offering_Id__c=newOfferingId;
        newPMPOfferingCat.PMP_Ancestor_Category_Cd__c='NPP_01_TYPE|NPP_02_TYPE_Sys|NPP_03_TYPE_Sys_Laptop';
        newPMPOfferingCat.PMP_Offering_Category_External_Key__c='NPP_04_TYPE_Sys_Laptop_2in1';
        newPMPOfferingCat.PMP_Category_Id__c = newCategory.Id;
        insert newPMPOfferingCat;
        
        
        return newPMPOfferingCat;
    }
    //Added for US274100
    public static PMP_Partner_Offering_Category__c getActivatedOfferingCategory(Id newOfferingId){
        
        PMP_Category__c newCategory=getCategory('Application', 'NPP_01_APP','NPP Taxonomy', 'en_us');
        newCategory.PMP_Active_Ind__c=false;              
        PMP_Partner_Offering_Category__c newPMPOfferingCat=new PMP_Partner_Offering_Category__c();
        newPMPOfferingCat.Name='2-in-1';
        newPMPOfferingCat.PMP_Category_Id__c=newCategory.Id;
        newPMPOfferingCat.PMP_Offering_Id__c=newOfferingId;
        newPMPOfferingCat.PMP_Ancestor_Category_Cd__c='NPP_01_TYPE|NPP_02_TYPE_Sys|NPP_03_TYPE_Sys_Laptop';
        newPMPOfferingCat.PMP_Offering_Category_External_Key__c='NPP_04_TYPE_Sys_Laptop_2in1';
        insert newPMPOfferingCat;
        
        
        return newPMPOfferingCat;
    }
    
    public static PMP_Category__c getCategory(String name, String categoryId, String parentCategotyId, String locale){
        PMP_Category__c category=new PMP_Category__c();
        category.Name=name;
        category.PMP_Partner_Product_Category_Cd__c=categoryId;
        category.PMP_Partner_Product_Parent_Category_Cd__c=parentCategotyId;
        category.PMP_Active_Ind__c=true;
        //category.Core_PMP_Locale__c = locale;
        insert category;
        return category;
    }
    
    public static PMP_Partner_Offering_Specification__c getPMPOfferingSpecification(Id newOfferingId){
        //Added for US274100
        PMP_Specification__c newSpec=getSpecs();
        PMP_Specification_Value__c newSpecVal=getSpecVals();
        
        PMP_Partner_Offering_Specification__c newPMPOfferingSpec=new PMP_Partner_Offering_Specification__c();
        newPMPOfferingSpec.Name='2-in-1';
        newPMPOfferingSpec.PMP_Offering_Id__c=newOfferingId;
        newPMPOfferingSpec.PMP_Ancestor_Specification_Cd__c='NPP_01_TYPE|NPP_02_TYPE_Sys|NPP_IntelTechnologies';
        //Added for US274100
        newPMPOfferingSpec.PMP_Specification_Id__c=newSpec.Id;
        newPMPOfferingSpec.PMP_Specification_Value_Id__c=newSpecVal.Id;
        
        newPMPOfferingSpec.PMP_Specification_Nm__c='NPP_02_TYPE_Sys';
        newPMPOfferingSpec.PMP_Specification_Value_Cd__c='NPP_03_TYPE_Sys_Laptop';
        newPMPOfferingSpec.PMP_Product_Specification_Cd__c= 'NPP_IntelTechnologies';
        newPMPOfferingSpec.PMP_Display_Type_Nm__c= 'Checkbox';
        //newPMPOfferingSpec.PMP_Specification_Value_Id__c = 'Idle States';
        insert newPMPOfferingSpec;
        
        
        return newPMPOfferingSpec;
    }
    public static PMP_Partner_Offering_Resource__c getResources(Id documentId,Id offId){
        PMP_Partner_Offering_Resource__c offResource = new PMP_Partner_Offering_Resource__c();
        offResource.name = 'test ';
        offResource.PMP_Partner_Offering_Image__c = documentId;
        offResource.PMP_Offering_Id__c = offId;
        offResource.PMP_Resource_Type_Nm__c = 'Image';    
        insert offResource;
        return offResource;
    }
    
    public static PMP_Category_Specification_Association__c getCategorySpecs(Id categoryId,Id SpecId){
        PMP_Category_Specification_Association__c catSpec = new PMP_Category_Specification_Association__c();
        catSpec.name = 'test';
        catSpec.PMP_Specification_Id__c = SpecId;
        catSpec.PMP_Category_Id__c = categoryId;
        catSpec.PMP_Active_Ind__c = True;    
        insert catSpec;
        return catSpec;
    }
    
    public static PMP_Specification__c getSpecs(){
        PMP_Specification__c Spec = new PMP_Specification__c();
        Spec.name = 'test';
        Spec.PMP_Partner_Product_Specification_Id__c = 'Test|Test1';
        // Spec.PMP_Partner_Product_Specification_Id__c = 'NPP|03|TYPE|Sys';
        insert Spec;
        
        PMP_Specification__c Spec1 = new PMP_Specification__c();
        Spec1.name = 'test1';
        Spec1.PMP_Parent_Specification_Id__c = Spec.Id; 
        Spec1.PMP_Mandatory_Offering_Category_Nm__c = 'All';  
        insert Spec1;
        return Spec1;
    }
    
    //for US274100
    public static PMP_Specification_Value__c getSpecVals(){
        PMP_Specification_Value__c newSpecVal=new PMP_Specification_Value__c();
        
        newSpecVal.Name='Consumer';
        newSpecVal.PMP_Active_Ind__c=true;
        newSpecVal.PMP_Specification_Value_Chinese_Cd__c = 'chinese';
        newSpecVal.PMP_Specification_Value_Japanese_Cd__c = 'japanese';
        
        insert newSpecVal;
        return newSpecVal;
    }
    
    //for the class PMP_FetchOfferingFAEsTest 
    public static AccountTeamMember createAccountTeam(Id accountId,string accountAccess,string caseAccess,string opportunityAccess,string teamRole,Id userId,boolean isInsert){
        AccountTeamMember testTeam =new AccountTeamMember(AccountId=accountId,AccountAccessLevel=accountAccess,
                                                          CaseAccessLevel=caseAccess,OpportunityAccessLevel=opportunityAccess,
                                                          TeamMemberRole=teamRole,UserId=userId);
        if(isInsert){
            insert testTeam;
        }
        return testTeam;
    }
    
    public static PMP_Partner_Offering_Resource__c createResources(String name,String url, Id offeringId, String resourceType, String contentId){
        PMP_Partner_Offering_Resource__c resource=new PMP_Partner_Offering_Resource__c();
        resource.Name=name;
        resource.PMP_Offering_Id__c=offeringId;
        resource.PMP_Resource_Type_Nm__c=resourceType;
        if(resourceType=='Image')
            resource.PMP_Partner_Offering_Image__c=contentId;
        else
            resource.PMP_Partner_Offering_Resource_URL_Txt__c=url;
        insert resource;
        return resource;
    }
    
    public static PMP_Partner_Offering_Specification__c createOfferingSpecification(String name,Id newOfferingId, String ancestorId, String specName, String specValue, String specPIMId, String displayType){
        
        PMP_Partner_Offering_Specification__c newPMPOfferingSpec=new PMP_Partner_Offering_Specification__c();
        newPMPOfferingSpec.Name=name;
        newPMPOfferingSpec.PMP_Offering_Id__c=newOfferingId;
        newPMPOfferingSpec.PMP_Ancestor_Specification_Cd__c=ancestorId;
        newPMPOfferingSpec.PMP_Specification_Nm__c=specName;
        newPMPOfferingSpec.PMP_Specification_Value_Cd__c=specValue;
        newPMPOfferingSpec.PMP_Product_Specification_Cd__c= specPIMId;
        newPMPOfferingSpec.PMP_Display_Type_Nm__c=displayType;
        //newPMPOfferingSpec.PMP_Specification_Id__c='a3q0n0000007dHaAAI';
        
        
        
        insert newPMPOfferingSpec;
        
        
        return newPMPOfferingSpec;
    }
    /***************************************************************************************/
    public static PMP_Specification__c createSpecification(String specName ,String parentSpecId, String pimSpecId , String pimParentSpecId){
        PMP_Specification__c spec = new PMP_Specification__c();
        spec.PMP_Display_Type_Nm__c = 'Checkbox';
        spec.PMP_Active_Ind__c = true; 
        spec.PMP_Parent_Specification_Id__c = parentSpecId;
        spec.PMP_Product_Parent_Specification_Id__c = pimParentSpecId;
        spec.PMP_Partner_Product_Specification_Id__c = pimSpecId ; 
        spec.PMP_Partner_Product_Display_Sequence_Nbr__c	= 1001;
        spec.Name = specName;
        insert spec;
        return spec;
    }
    
    public static PMP_Specification_Value_Association__c createSpecValueAsc (String name,String catId,String specId,String specValueId,Boolean isInsert){
        PMP_Specification_Value_Association__c specValAsc = new PMP_Specification_Value_Association__c();
        specValAsc.PMP_Category_Id__c = catId;
        specValAsc.PMP_Active_Ind__c = true;
        specValAsc.PMP_Specification_Id__c = specId;
        specValAsc.PMP_Specification_Value_Id__c = specValueId ;
        if (isInsert){
            insert specValAsc;
        }
        return specValAsc;
    }
    
    public static 	PMP_Company_Translation__c getCompanyTranslation(String partnerId,String name, String fieldName ){
        PMP_Company_Translation__c trans = new PMP_Company_Translation__c();
        trans.Name = name;
        trans.PMP_Field_Nm__c = fieldName;
        trans.PMP_Company_Information_Id__c = partnerId;
        trans.PMP_Japanese_Txt__c = 'Test_Japanese';
        trans.PMP_English_Txt__c = 'Test_English';
        trans.PMP_Chinese_Txt__c= 'Test_Chinese';
        insert trans;
        return trans;
    }
    
    public static Core_Account_Group_Member__c createPAGMember(Id part_acc_id, Id intel_acc_id, Boolean is_MDA, Boolean is_inactive, Boolean isInsert){
        
		Core_Account_Group_Member__c group_mem = new Core_Account_Group_Member__c(Core_Partner_Account_Id__c = part_acc_id,
                                                                                  Core_Intel_Account_Id__c   = intel_acc_id,
                                                                                  Core_MDA_Ind__c            = is_MDA,
                                                                                  Core_Inactive_Ind__c       = is_inactive);
        if(isInsert){
            insert group_mem;
        }
        return group_mem;
    }

    public static Core_ERPM_Engagement__c createERPMEngagement(String name, Boolean isInsert){
        
		Core_ERPM_Engagement__c engagement = new Core_ERPM_Engagement__c(Name = name);
        
        if(isInsert){
            insert engagement;
        }
        return engagement;
    }      
    
    public static Core_Account_ERPM_Engagement__c createAccountERPMEngagement(Id intel_acc_id, Id eng_id, String attribute, Boolean isInsert){
        
		Core_Account_ERPM_Engagement__c acc_engagement = new Core_Account_ERPM_Engagement__c(Core_Account_Id__c = intel_acc_id,
                                                                                             Core_ERPM_Business_Attributes__c = attribute,
                                                                                             Core_ERPM_Engagement_Id__c = eng_id);
        
        if(isInsert){
            insert acc_engagement;
        }
        return acc_engagement;
    }     
}