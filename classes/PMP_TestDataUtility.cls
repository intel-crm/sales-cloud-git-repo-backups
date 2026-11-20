/****************************************************************************************************************************************
* Class Name  : PMP_TestDataUtility 
* Version     : 1.0 
* Created Date: 07-12-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Raj Dubey                    7/12/2018                    Utility Class to create test data.
*****************************************************************************************************************************************/
@isTest
public class PMP_TestDataUtility {
    
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
        
        Account testAccount = new Account();
        testAccount.RecordTypeId = PMP_TestDataUtility.intel_Account_Record_Type;
        testAccount.Name = accountName;       
        testAccount.Core_Account_Country__c='India';
        testAccount.Core_Sales_Group_New__c='US Sales Group';
        testAccount.Core_Account_Type__c='ODM';
        testAccount.BillingStreet='Bangalore Central';
        testAccount.BillingCity='Bangalore';
        testAccount.BillingCountry='IND';
        testAccount.BillingState='KA';
        testAccount.BillingPostalCode='560029';
        testAccount.Industry='Agriculture';
        
        if(isInsert){
            insert testAccount;
        }
        return testAccount;
    }
    
    public static Account createAccount(String accountName, Id accountRecordTypeId, Boolean isInsert){
        
        Account testAccount = new Account();
        testAccount.RecordTypeId = accountRecordTypeId;
        testAccount.Name = accountName;       
        testAccount.Core_Account_Country__c='India';
        testAccount.Core_Sales_Group_New__c='US Sales Group';
        testAccount.Core_Account_Type__c='ODM';
        testAccount.BillingStreet='Bangalore Central';
        testAccount.BillingCity='Bangalore';
        testAccount.BillingCountry='IND';
        testAccount.BillingState='KA';
        testAccount.BillingPostalCode='560029';
        testAccount.Industry='Agriculture';
        
        if(isInsert){
            insert testAccount;
        }
        return testAccount;
    }
    /* part of OPID Restructure - changes start on line 86
    public static PMP_Company__c createCompanyInformation(string companyName, Id accountId, Boolean isInsert){
        PMP_Company__c testCompany = new PMP_Company__c(Name=companyName,PMP_Account_Industry__c='Others',PMP_Account_Id__c=accountId
                                                       );
        testCompany.PMP_Is_Published_Ind__c=true;
        if(isInsert){
            insert testCompany;
        }           
        return testCompany;
    }
	*/
    public static PMP_Company__c createCompanyInformation(string companyName, Id accountId, Boolean isInsert){
	
	PMP_Company__c testCompany = new PMP_Company__c(Name=companyName, PMP_Account_Industry__c='Others');
	testCompany.PMP_Opid_Sfid_Txt__c = accountId;
    testCompany.PMP_Is_Published_Ind__c=true;
        
        if(isInsert){
            insert testCompany;
        }           
        return testCompany;
    }
    
    public static PMP_Company__c createCompanyInformationWithBenefit(string companyName, Id accountId, Boolean isInsert, String benefitType){
	
	PMP_Company__c testCompany = new PMP_Company__c(Name=companyName, PMP_Account_Industry__c='Others');
	testCompany.PMP_Opid_Sfid_Txt__c = accountId;
    testCompany.PMP_Is_Published_Ind__c=true;
    testCompany.PMP_Partner_Benefit_Type__c = benefitType;   
        if(isInsert){
            insert testCompany;
        }           
        return testCompany;
    }
    /*public static PMP_Company__c createCompanyInformation(string companyName, Boolean isInsert){
        PMP_Company__c testCompany = new PMP_Company__c(Name=companyName,PMP_Account_Industry__c='Others');
        testCompany.PMP_Is_Published_Ind__c=true;
        if(isInsert){
            insert testCompany;
        }           
        return testCompany;
    }*/
    public static PMP_OPID_MPI_Rel__c createJunctionMPItoOPID(Id opid, Id mpi, Boolean isInsert){
        PMP_OPID_MPI_Rel__c testJuncRec = new PMP_OPID_MPI_Rel__c(PMP_One_Partner_ID__c=opid,PMP_Marketing_Profile_Id__c=mpi);
        testJuncRec.Is_Active__c = true;
        if(isInsert){
            insert testJuncRec;
        }           
        return testJuncRec;
    }

    // public static PMP_Partner_Offering__c createOffering(string offeringName, string offeringVisibility, string offeringDesc, String cmpId, Boolean isInsert, String status, String tagline){
    //     PMP_Partner_Offering__c testOffering = new PMP_Partner_Offering__c(PMP_Partner_Offering_Visibility_Nm__c=offeringVisibility, 
    //                                                        PMP_Partner_Offering_Dsc__c=offeringDesc,
    //                                                        Name=offeringName, 
    //                                                        PMP_Company_Id__c=cmpId, PMP_Partner_Offering_Lifecycle_Status_Nm__c=status,
    //                                                       PMP_Partner_Offering_Tag_Line_Txt__c=tagline,PMP_Partner_Offering_Nm__c=offeringName);
        
    //     if(isInsert){
    //         insert testOffering;
    //     }
    //     //system.debug('offering created'); 
    //     return testOffering;
    // }
    
    public static Contact createContact(Id accountId,Boolean isInsert){
        Contact testContact = new Contact(Salutation = 'Mr',FirstName = 'Test',LastName='Contact',
                                          Email='testcontact'+String.valueOf(Math.random())+'@CorePMP.com',
                                          AccountId=accountId,Phone='123456798',MailingCountry='India');       
        if(isInsert){
            insert testContact;
        }
        
        return testContact;
    }
    
    public static list<contentDocument> createContentDocument(Boolean isInsert) {
        list <contentDocument> emptyList = new list <contentDocument>();
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
        return emptyList;
        
    }
    
    

    // public static Id getOffering(){
    //      PMP_Partner_Offering__c newOffering = new PMP_Partner_Offering__c();
    //     newOffering.Name = 'testOffering_1';
    //     newOffering.PMP_Partner_Offering_Nm__c = newOffering.Name;
    //     insert newOffering;

    //     return newOffering.Id;
    // }
    
    
    // public static PMP_Partner_Offering_Category__c getPMPOfferingCategory(Id newOfferingId){

    //     PMP_Category__c newCategory=getCategory(system.label.PMP_application, 'NPP_01_APP','NPP Taxonomy', 'en_us'); // value change from Application to Use Cases       
    //     PMP_Partner_Offering_Category__c newPMPOfferingCat=new PMP_Partner_Offering_Category__c();
    //     newPMPOfferingCat.Name='2-in-1';
    //     newPMPOfferingCat.PMP_Offering_Id__c=newOfferingId;
    //     newPMPOfferingCat.PMP_Ancestor_Category_Cd__c='NPP_01_TYPE|NPP_02_TYPE_Sys|NPP_03_TYPE_Sys_Laptop';
    //     newPMPOfferingCat.PMP_Offering_Category_External_Key__c='NPP_04_TYPE_Sys_Laptop_2in1';
    //     newPMPOfferingCat.PMP_Category_Id__c = newCategory.Id;
    //     insert newPMPOfferingCat;

        
    //     return newPMPOfferingCat;
    // }
    //     //Added for US274100
    //     public static PMP_Partner_Offering_Category__c getActivatedOfferingCategory(Id newOfferingId){
        
    //     PMP_Category__c newCategory=getCategory(system.label.PMP_application, 'NPP_01_APP','NPP Taxonomy', 'en_us'); // value change from Application to Use Cases 
    //     newCategory.PMP_Active_Ind__c=false;              
    //     PMP_Partner_Offering_Category__c newPMPOfferingCat=new PMP_Partner_Offering_Category__c();
    //     newPMPOfferingCat.Name='2-in-1';
    //     newPMPOfferingCat.PMP_Category_Id__c=newCategory.Id;
    //     newPMPOfferingCat.PMP_Offering_Id__c=newOfferingId;
    //     newPMPOfferingCat.PMP_Ancestor_Category_Cd__c='NPP_01_TYPE|NPP_02_TYPE_Sys|NPP_03_TYPE_Sys_Laptop';
    //     newPMPOfferingCat.PMP_Offering_Category_External_Key__c='NPP_04_TYPE_Sys_Laptop_2in1';
    //     insert newPMPOfferingCat;

        
    //     return newPMPOfferingCat;
    // }
    
    public static PMP_Category__c getCategory(String application, String categoryId, String parentCategotyId, String locale){
        PMP_Category__c category=new PMP_Category__c();
        category.Name=application;
        category.PMP_Category_Chinese_Nm__c='askljkfihsdk';
        category.PMP_Category_Japanese_Nm__c='jpasd8dajn';
        category.PMP_Partner_Product_Category_Cd__c=categoryId;
        category.PMP_Partner_Product_Parent_Category_Cd__c=parentCategotyId;
        category.PMP_Active_Ind__c=true;
        //category.Core_PMP_Locale__c = locale;
        insert category; //Avoid insert - insert in the test class where it is used, in this way it will be more generic
        //and handy if we are creating some data in a loop to generate more records.
        return category;
    }
    public static PMP_Category__c getCategory(String application, String categoryId, String parentCategotyId, String locale, boolean isInsert){
        PMP_Category__c category=new PMP_Category__c();
        category.Name=application;
        category.PMP_Category_Chinese_Nm__c='askljkfihsdk';
        category.PMP_Category_Japanese_Nm__c='jpasd8dajn';
        category.PMP_Partner_Product_Category_Cd__c=categoryId;
        category.PMP_Partner_Product_Parent_Category_Cd__c=parentCategotyId;
        category.PMP_Active_Ind__c=true;
        //category.Core_PMP_Locale__c = locale;
        if(isInsert==true){
            insert category;
        } //Avoiding the insert - insert in the test class where it is used, in this way it will be more generic
        //and handy if we are creating some data in a loop to generate more records.
        return category;
    }
    
    // public static PMP_Partner_Offering_Specification__c getPMPOfferingSpecification(Id newOfferingId){
    //     //Added for US274100
    //     PMP_Specification__c newSpec=getSpecs();
    //     PMP_Specification_Value__c newSpecVal=getSpecVals();
        
    //     PMP_Partner_Offering_Specification__c newPMPOfferingSpec=new PMP_Partner_Offering_Specification__c();
    //     newPMPOfferingSpec.Name='2-in-1';
    //     newPMPOfferingSpec.PMP_Offering_Id__c=newOfferingId;
    //     newPMPOfferingSpec.PMP_Ancestor_Specification_Cd__c='NPP_01_TYPE|NPP_02_TYPE_Sys|NPP_IntelTechnologies';
    //     //Added for US274100
    //     newPMPOfferingSpec.PMP_Specification_Id__c=newSpec.Id;
    //     newPMPOfferingSpec.PMP_Specification_Value_Id__c=newSpecVal.Id;
         
    //     newPMPOfferingSpec.PMP_Specification_Nm__c='NPP_02_TYPE_Sys';
    //     newPMPOfferingSpec.PMP_Specification_Value_Cd__c='NPP_03_TYPE_Sys_Laptop';
    //     newPMPOfferingSpec.PMP_Product_Specification_Cd__c= 'NPP_IntelTechnologies';
    //     newPMPOfferingSpec.PMP_Is_Pre_Release_Item_Ind__c= false;
    //     //newPMPOfferingSpec.PMP_Specification_Value_Id__c = 'Idle States';
    //     insert newPMPOfferingSpec;

        
    //     return newPMPOfferingSpec;
    // }
    // public static PMP_Partner_Offering_Resource__c getResources(Id documentId,Id offId){
    //     PMP_Partner_Offering_Resource__c offResource = new PMP_Partner_Offering_Resource__c();
    //     offResource.name = 'test ';
    //     offResource.PMP_Partner_Offering_Image__c = documentId;
    //     offResource.PMP_Offering_Id__c = offId;
    //     offResource.PMP_Resource_Type_Nm__c = 'Image';    
    //     insert offResource;
    //     return offResource;
    // }
    
    // public static List<PMP_Partner_Offering_Resource__c> getResourcesinList(Id documentId,Id offId){
    //     List<PMP_Partner_Offering_Resource__c> offResource = new List<PMP_Partner_Offering_Resource__c>();
    //     PMP_Partner_Offering_Resource__c offResource1 = new PMP_Partner_Offering_Resource__c();
    //     offResource1.name = 'test ';
    //     offResource1.PMP_Partner_Offering_Image__c = documentId;
    //     offResource1.PMP_Offering_Id__c = offId;
    //     offResource1.PMP_Resource_Type_Nm__c = 'Image';    
    //     insert offResource1;
    //     offResource.add(offResource1);
    //     PMP_Partner_Offering_Resource__c offResource2 = new PMP_Partner_Offering_Resource__c();
    //     offResource2.name = 'test ';
    //     offResource2.PMP_Partner_Offering_Image__c = documentId;
    //     offResource2.PMP_Offering_Id__c = offId;
    //     offResource2.PMP_Offering_Gallery_Video_Ind__c = true;
    //     offResource2.PMP_Delete_BrightCove_Video_Ind__c = false;
    //     offResource2.PMP_BrightCoveVideoAccountID__c = '1dfwdf';
    //     offResource2.PMP_BrightCoveVideoId__c = '324820';
    //     offResource2.PMP_Resource_Description_Txt__c = 'dff';
    //     offResource2.PMP_BrightCoveVideoThumbnail_URL__c = documentId+'_'+offId;
    //     offResource2.PMP_Resource_Type_Nm__c = 'VIDEO';    
    //     insert offResource2;
    //     offResource.add(offResource2);
    //     PMP_Partner_Offering_Resource__c offResource3 = new PMP_Partner_Offering_Resource__c();
    //     offResource3.name = 'test ';
    //     offResource3.PMP_Partner_Offering_Image__c = documentId;
    //     offResource3.PMP_Offering_Id__c = offId;
    //     offResource3.PMP_Offering_Gallery_Video_Ind__c = false;
    //     offResource3.PMP_Delete_BrightCove_Video_Ind__c = false;
    //     offResource3.PMP_BrightCoveVideoAccountID__c = '1dfwdf';
    //     offResource3.PMP_BrightCoveVideoId__c = '324820';
    //     offResource3.PMP_Resource_Description_Txt__c = 'dff';
    //     offResource3.PMP_BrightCoveVideoThumbnail_URL__c = documentId+'_'+offId;
    //     offResource3.PMP_Resource_Type_Nm__c = 'VIDEO';  
    //     insert offResource3;
    //     offResource.add(offResource3);
    //     PMP_Partner_Offering_Resource__c offResource4 = new PMP_Partner_Offering_Resource__c();
    //     offResource4.name = 'test ';
    //     offResource4.PMP_Partner_Offering_Image__c = documentId;
    //     offResource4.PMP_Offering_Id__c = offId;
    //     offResource4.PMP_Offering_Gallery_Video_Ind__c = false;
    //     offResource4.PMP_Delete_BrightCove_Video_Ind__c = false;
    //     offResource4.PMP_BrightCoveVideoAccountID__c = '1dfwdf';
    //     offResource4.PMP_BrightCoveVideoId__c = '324820';
    //     offResource4.PMP_Resource_Description_Txt__c = 'dff';
    //     offResource4.PMP_BrightCoveVideoThumbnail_URL__c = documentId+'_'+offId;
    //     offResource4.PMP_Resource_Type_Nm__c = 'Product Brief';  
    //     insert offResource4;
    //     offResource.add(offResource4);
    //     return offResource;
    // }
    
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
        Spec.PMP_Specification_Name__c = 'test1';
        Spec.PMP_Partner_Product_Specification_Id__c = 'Test|Test1';
       // Spec.PMP_Partner_Product_Specification_Id__c = 'NPP|03|TYPE|Sys';
        insert Spec;
        
        PMP_Specification__c Spec1 = new PMP_Specification__c();
        Spec1.name = 'test1';
        Spec1.PMP_Specification_Name__c = 'test1';
        Spec1.PMP_Parent_Specification_Id__c = Spec.Id; 
        //Spec1.PMP_Mandatory_Offering_Category_Nm__c = 'All';  
        insert Spec1;
        return Spec1;
    }
    
    //for US274100
    public static PMP_Specification_Value__c getSpecVals(){
        PMP_Specification_Value__c newSpecVal=new PMP_Specification_Value__c();
        newSpecVal.PMP_Partner_Off_Roadmap_Ind__c=True;
        newSpecVal.Name='Consumer';
        newSpecVal.PMP_Active_Ind__c=false;
        newSpecVal.PMP_Specification_Value_Nm__c='Consumer';
        newSpecVal.PMP_Product_Status__c ='Launched';
         
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
    
    // public static PMP_Partner_Offering_Resource__c createResources(String name,String url, Id offeringId, String resourceType, String contentId){
    //     PMP_Partner_Offering_Resource__c resource=new PMP_Partner_Offering_Resource__c();
    //     resource.Name=name;
    //     resource.PMP_Offering_Id__c=offeringId;
    //     resource.PMP_Resource_Type_Nm__c=resourceType;
    //     if(resourceType=='Image')
    //         resource.PMP_Partner_Offering_Image__c=contentId;
    //     else
    //         resource.PMP_Partner_Offering_Resource_URL_Txt__c=url;
    //     insert resource;
    //     return resource;
    // }
    
    // public static PMP_Partner_Offering_Specification__c createOfferingSpecification(String name,Id newOfferingId, String ancestorId, String specName, String specValue, String specPIMId, String displayType){
    //     PMP_Specification__c newSpec=getSpecs();
    //     PMP_Specification_Value__c newSpecVal=getSpecVals();
        
    //     PMP_Partner_Offering_Specification__c newPMPOfferingSpec=new PMP_Partner_Offering_Specification__c();
    //     newPMPOfferingSpec.Name=name;
    //     newPMPOfferingSpec.PMP_Offering_Id__c=newOfferingId;
    //     newPMPOfferingSpec.PMP_Ancestor_Specification_Cd__c=ancestorId;
    //     newPMPOfferingSpec.PMP_Specification_Nm__c=specName;
    //     newPMPOfferingSpec.PMP_Specification_Value_Cd__c=specValue;
    //     newPMPOfferingSpec.PMP_Product_Specification_Cd__c= specPIMId;
    //     newPMPOfferingSpec.PMP_Display_Type_Nm__c=displayType;
    //     newPMPOfferingSpec.PMP_Specification_Id__c=newSpec.Id;
    //     newPMPOfferingSpec.PMP_Specification_Value_Id__c=newSpecVal.Id;
                                                                               
                                                                               
                                                                               
    //     insert newPMPOfferingSpec;

        
    //     return newPMPOfferingSpec;
    // }
    // //Added by Abhishek. Needed for UI generator, Tab1, Tab2, Tab3 service class coverage.       
    // public static List<PMP_SpecificationController.Core_PMP_OfferingSpecs> getSpecWrapperList(integer count,string displayType){
    //     List<PMP_SpecificationController.Core_PMP_OfferingSpecs> specWrapperList = New List<PMP_SpecificationController.Core_PMP_OfferingSpecs>();
        
    //     for(integer i=0; i<= count; i++ ){
            
            
    //        string  specName = 'Test + i + specName'  ;          
    //        string  specId = 'Test' + i + 'id';
    //        string parentId = null;
    //        string  categoryId = 'Testcat' + i + 'Id';
    //        string  ancestorSpecName = null;
    //         string specValue='Test'+ i + 'specValue';
    //         string specValueId='Test' + i + 'specValueId';
    //         boolean mandatoryCheck = false;
    //         string specRecordId = 'testSpecrecId' + i; 
    //         PMP_SpecificationController.Core_PMP_OfferingSpecs spec1 = New PMP_SpecificationController.Core_PMP_OfferingSpecs(
    //                                                                     specName,specId,parentId,categoryId,displayType,ancestorSpecName,
    //                                                                     mandatoryCheck,null,null,null,specRecordId,null,null,null,null); 
    //         specWrapperList.add(spec1);
    //     }
        
    //     return specWrapperList;
    // }
    // public static PMP_SpecificationController.Core_PMP_OfferingSpecs getSpecWrapperList(string displayType){
    //     List<PMP_SpecificationController.Core_PMP_OfferingSpecs> specWrapperList = New List<PMP_SpecificationController.Core_PMP_OfferingSpecs>();
        
    //        string  specName = 'TestspecName'  ;          
    //        string  specId = 'Test ID' ;
    //        string parentId = null;
    //        string  categoryId = 'TestcatId' ;
    //        string  ancestorSpecName = null;
    //         string specValue='TestspecValue';
    //         string specValueId='TestspecValueId';
    //         boolean mandatoryCheck = false;
    //         string specRecordId = 'testSpecrecId' ; 
    //         PMP_SpecificationController.Core_PMP_OfferingSpecs spec = New PMP_SpecificationController.Core_PMP_OfferingSpecs(
    //                                                                     specName,specId,parentId,categoryId,displayType,ancestorSpecName,
    //                                                                     mandatoryCheck,null,null,null,specRecordId,null,null,null,null); 
       
    //     return spec;
    // }
    // public static List<PMP_SpecificationController.Core_PMP_OfferingSpecsValues> getSpecValueWrapper(integer count, string displayType){
    //     List<PMP_SpecificationController.Core_PMP_OfferingSpecsValues> specValueWrapperList = New List<PMP_SpecificationController.Core_PMP_OfferingSpecsValues>();
        
    //     for(integer i=0; i<= count; i++ ){
            
    //         string specId = 'Test' + i + 'id';
            
    //         string categoryId = 'Testcat' + i + 'Id';       
    //         displayType = displaytype;
    //         string specValue='Test'+ i + 'specValue';
    //         string  specValueId='Test' + i + 'specValueId';
    //         boolean preReleased = false;
    //         PMP_SpecificationController.Core_PMP_OfferingSpecsValues specValueWrapper = New PMP_SpecificationController.Core_PMP_OfferingSpecsValues(
    //                                                                     specId,categoryId,specValueId, specValue,displayType,
    //                                                                         null,null,null,null,null,null,null,preReleased );
    //         specValueWrapperList.add(specValueWrapper);
    //     }
        
    //     return specValueWrapperList ;
    // }
    //  public static PMP_SpecificationController.Core_PMP_OfferingSpecsValues getSpecValueWrapper(string displayType){
            
    //         string specId = 'Test'  + 'id';
            
    //         string categoryId = 'Testcat' + 'Id';       
    //         displayType = displaytype;
    //         string specValue='Test' + 'specValue';
    //         string  specValueId='Test'+ 'specValueId';
    //         boolean preReleased = false;
    //         PMP_SpecificationController.Core_PMP_OfferingSpecsValues specValueWrapper = New PMP_SpecificationController.Core_PMP_OfferingSpecsValues(
    //                                                                     specId,categoryId,specValueId, specValue,displayType,
    //                                                                         null,null,null,null,null,null,null,preReleased );
            
       
        
    //     return specValueWrapper ;
    // }
    
    public static User createTestUser(Profile p) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
         User u = new User(Alias = 'standt', Email=uniqueName + '@' + 'Intel'+ '.com', 
                             EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                             LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName=uniqueName + '@test' + orgId + '.org');
         return u;
    }
    
    public static ContentDocumentLink createContentDocumentLink(Id linkId, Id ContentDocumentId){
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = ContentDocumentId;
        cl.LinkedEntityId = linkId;
        cl.ShareType = 'V';
        
        insert cl;
        return cl;
    }
    
    // public static PMP_Partner_Offering_Resource__c createOfferingResourceInstance(String name,String url, Id offeringId, String resourceType, String contentId){
    //     PMP_Partner_Offering_Resource__c resource=new PMP_Partner_Offering_Resource__c();
    //     resource.Name=name;
    //     resource.PMP_Offering_Id__c=offeringId;
    //     resource.PMP_Resource_Type_Nm__c=resourceType;
    //     if(resourceType=='Image' || resourceType == PMP_StaticConstants_Offering.THUMBNAIL_IMAGE) // added thumbnail image condition also
    //         resource.PMP_Partner_Offering_Image__c=contentId;
    //     else
    //         resource.PMP_Partner_Offering_Resource_URL_Txt__c=url;

    //     return resource;    
    // }
    
    // public static PMP_Partner_Offering_Translation__c createOfferingTranslation(Id offId, string transName){
    //     PMP_Partner_Offering_Translation__c trans = new PMP_Partner_Offering_Translation__c();
    //     trans.PMP_Partner_Offering_Id__c = offId;
    //     trans.Name = transName;
        
    //     return trans;
        
    // }
    public static Document createDocument(){
        Document document = new Document();
        document.Body = Blob.valueOf('Some Text');
        document.ContentType = 'application/pdf';
        document.DeveloperName = 'my_document';
        document.IsPublic = true;
        document.Name = 'IntelLogo';
        document.FolderId = [select id from folder where name = 'PMP_Marketplace_Images'].id;
        insert document;
        return document;
    }
    
    //method to retrun content version instances
    public static List<ContentVersion> getContentVersions(Boolean isInsert,Integer totalCount) {
        List<ContentVersion> versions = new List<ContentVersion>();
        for(Integer i=1; i<=totalCount; i++) {
            ContentVersion version = new ContentVersion(
                Title = i + '-' + 'Test',
                PathOnClient = i + '-' + 'Test.jpg',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            versions.add(version);
        }
        if(isInsert){
            insert versions;
        }
        return versions;
    }
    
    //Added by Shahrukh : This method creates offering translations with particular fields
    // public static PMP_Partner_Offering_Translation__c createOfferingTranslationsWithFieldNames(Id offId, string transName, string fieldName, string fieldValue){
    //     PMP_Partner_Offering_Translation__c trans = new PMP_Partner_Offering_Translation__c();
    //     trans.PMP_Partner_Offering_Id__c = offId;
    //     trans.Name = transName;
    //     trans.PMP_English_Txt__c = fieldValue;
    //     trans.PMP_Chinese_Txt__c = fieldValue;
    //     trans.PMP_Japanese_Txt__c = fieldValue;
    //     trans.PMP_Field_Nm__c = fieldName;
    //     return trans;
        
    // }
    //Added by shahrukh to resolve new validations added on account object : 23/07/2020   
    public static User createAdminUser(Boolean isInsert){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole testUserRole = [select id from UserRole where DeveloperName='Admin' Limit 1];
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        //Contact conObj = PMP_TestDataUtility.createContact(AccId,true);
        
        User testUser = new User(UserRoleId=testUserRole.Id,Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercore@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test');
        if(isInsert){
            
            insert testUser;
        }
        return testUser;
    }
    //Added by shahrukh to resolve new validations added on account object : 23/07/2020   
    public static User createUserNew(Boolean isInsert,Id AccId){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        Contact conObj = PMP_TestDataUtility.createContact(AccId,true);
        
        User testUser = new User(Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='User'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test', Contact = conObj);
        if(isInsert){
            
            insert testUser;
        }
        return testUser;
    }
    public static User createInactiveUser(Boolean isInsert){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        //UserRole ur = [Select Id, Name From UserRole limit 1];
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        
        Account accObj = PMP_TestDataUtility.createIntelAccount('test class Account1',devRecordTypeId,true);
        Contact conObj = PMP_TestDataUtility.createContact(accObj.id,true);
        User testUser = new User(/**UserRoleId  = ur.Id,**/Alias = String.valueOf(datetime.now()).substring(0,8), Email='testUsercoreMDF@intel.com',
                                 EmailEncodingKey='UTF-8', LastName='User1234'+String.valueOf(date.today()), LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id,isActive=false,
                                 TimeZoneSidKey='America/Los_Angeles', UserName='testUser1234'+String.valueOf(Math.random())+'@CoreMDF.com',FirstName='Test', Contact = conObj);
        if(isInsert){
            
            insert testUser;
        }
        return testUser;
    }
}