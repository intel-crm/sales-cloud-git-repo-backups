/*****************************************************************************
Created By : PopcornApps 
Created Date : 19-August-2015
Note : This is copy of existing TestUtilities with changes and this is only for B2B RestAPI's.

TestUtilities Class is the Factory Util class to create all Test records which are needed to test the Apex Codes
Before changing any existing methods, remember that it may impact other test classes which are using it.
Provide proper Naming convention for the Method and variables.
Provide Method level comments and Parameters for every method, so that it will help other developers to use it
******************************************************************************/
@isTest public class Core_RestAPI_TestUtilities {
    
    public static final String REQUEST_TEMPLATE = '{"resourcePath":"/services/apexrest/v1.0/unitTest","requestURI":"/v1.0/unitTest","requestBody":"","remoteAddress":"170.178.140.170","params":{},"httpMethod":"GET","headers":{"X-Salesforce-SIP":"170.178.140.170","Accept-Language":"en-US,en;q=0.9","Accept-Encoding":"gzip, deflate, br","Postman-Token":"09c84838-c53c-e33a-34ed-1717086d6c9e","Host":"intel--crmdevcase.cs92.my.salesforce.com","User-Agent":"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.75 Safari/537.36","Connection":"keep-alive","CipherSuite":"ECDHE-RSA-AES256-GCM-SHA384 TLSv1.2 256-bits","Accept":"*/*","Cache-Control":"no-cache"}}';
    
 /*****************************************************************************
    Method Info : getAccountRecord Method returns Account Record
    ******************************************************************************/
    public static Account getAccountRecord(){ 
        Account accountRecord = new Account(
            recordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId(),
            Name = 'Dell Products',
            Core_Account_Type__c = 'Distributor',
            Core_Sales_Segment__c = 'Compute',
            Industry = 'Banking',
            BillingCity = 'Delhi',
            BillingCountry = 'USA',
            billingState = 'AK',
            billingStreet = 'Bratislava 1',
            Core_IPS_Active__c = true
          );
        return accountRecord;
    }
    
    /*****************************************************************************
    Method Info : getContact Method returns Contact Record
    ******************************************************************************/
    public static Contact getContact(){  
        Contact contactRecord = new Contact(
            FirstName = 'Ding Dong',
            Lastname = 'Dell',
            Email = 'Contact1Dell@gmail.com',
            recordTypeId = schema.sobjecttype.Contact.getrecordtypeinfosbyname().get('Outlook contact').getRecordTypeId(),
            Core_IPS_Active__c = true,
            Core_IPS_Intel_Support_Owner__c = UserInfo.getUserId()
        );
        return contactRecord;
    }
    
    
    public static User getCustomerUser(){
        Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
        Account acc = new Account (
        Name = 'newAcc1',
        BillingCity = 'folsom',
        BillingCountry = 'USA',
        BillingStreet = 'Creek Side Dr'
        );  
        insert acc;
        Contact con = new Contact (
        AccountId = acc.id,
        FirstName = 'portia',
        LastName  = 'portalTestUser'
        );
        insert con;
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
         User newUser;
        System.runAs ( thisUser ) {
        //UserRole ur = [Select PortalType, PortalAccountId From UserRole where PortalType =:'CustomerPortal' limit 1];
        Profile p = [select Id,name from Profile where UserType in :customerUserTypes limit 1];
         
        newUser = new User(
        //UserRoleId = ur.Id,
        profileId = p.id,
        username = 'newUser@yahoo.com',
        email = 'pb@ff.com',
        emailencodingkey = 'UTF-8',
        localesidkey = 'en_US',
        languagelocalekey = 'en_US',
        timezonesidkey = 'America/Los_Angeles',
        alias='nuser',
        lastname='lastname',
        contactId = con.id
        );
        insert newUser;  
        }
        return newUser;
    }
    
     /*****************************************************************************
    Method Info : getCustomerUser Method returns user Record with  profilID
    ******************************************************************************/
      public static User getCustomerUser(string  profileName){
      User thisUser = [ select Id from User where profile.Name = 'System Administrator' and userRoleId != null AND ISActive=true Limit 1];
        Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
        Account acc = new Account (
        Name = 'newAcc1',
        BillingCity = 'folsom',
        BillingCountry = 'USA',
        BillingStreet = 'Creek Side Dr',
        Ownerid =thisUser.id
        );  
        insert acc;
        Contact con = new Contact (
        AccountId = acc.id,
        FirstName = 'portia',
        LastName  = 'portalTestUser',
        email     = 'pb@ff.com'
        );
        insert con;
        
         User newUser;
        System.runAs ( thisUser ) {
       // UserRole ur = [Select PortalType, PortalAccountId From UserRole where PortalType =:'CustomerPortal' limit 1];
        Profile p =   [select Id,name from Profile where Name = :profileName limit 1];
         system.debug('>>>>>>>>>>>>>>>' + p);
        newUser = new User(
        //UserRoleId = ur.Id,
        profileId = p.id,
        username = 'newUser@yahoo.com',
        email = 'pb@ff.com',
        emailencodingkey = 'UTF-8',
        localesidkey = 'en_US',
        languagelocalekey = 'en_US',
        timezonesidkey = 'America/Los_Angeles',
        alias='nuser',
        lastname='lastname',
        contactId = con.id
        );
        system.debug(newUser);
        insert newUser;  
        system.debug('?>>>>' + newUser);
        }
        return newUser;
    }
    
    /*****************************************************************************
    Method Info : getIpsProjectRecord Method returns IPS Project (Core_IPS_Project__c) Record
    ******************************************************************************/
    public static Core_IPS_Project__c getIpsProjectRecord(){
        Core_IPS_Project__c ipsProjectRecord = new Core_IPS_Project__c(
            Name = 'ipsProjectName',
            Core_Status__c = 'Inactive',
            Core_MPNDA__c='12345'
        );
        return ipsProjectRecord;
    }
     /*****************************************************************************
    Method Info : getDocunmentRecord Method returns Document Record
    ******************************************************************************/
    public static Document getDocunmentRecord(string folderName,string DocumentName){
         Document Doc =  new Document();
       Doc.body = Blob.valueOf('Test data');
       Doc.Name = DocumentName;     
       Doc.FolderId =  [select Id,name from Folder where Name =:folderName].id   ;   
       insert Doc;
        return Doc;
    }
    /*****************************************************************************
    Method Info : getProduct Method returns Product (Product) Record
    ******************************************************************************/
    public static Product2 getProduct(){
        Product2 productRecord = new Product2(
            Name = 'Haswell EP',
            Core_Sales_Visible_Flag__c = false,
            Core_IPS_Visible_Flag_External__c = true,
            Core_IPS_Visible_Flag_Internal__c = 'Yes',
            IsActive = true,
            Core_Product_Org__c = 'IPS'//@@New Validation Rule!!!
        ); 
        return productRecord;
    }
    /*****************************************************************************
    Method Info : getProjectMember Method returns Project Member (Core_IPS_Project_Member__c) Record
    ******************************************************************************/
    public static Core_IPS_Project_Member__c getProjectMember(){
        Core_IPS_Project_Member__c projectMemberRecord = new Core_IPS_Project_Member__c(
        );
        return projectMemberRecord;
    }
    
    /*****************************************************************************
    Method Info : getAssetRecord Method returns Asset (Standard Asset object - Intel Product) Record
    ******************************************************************************/
    public static Asset getAssetRecord(){
        Asset AssetRecord = new Asset(
            name = 'Laptop',
            Status = 'Active'
        );
        return AssetRecord;
    }
     
    /*****************************************************************************
    Method Info : create Support Org Method creates Support Org (Custom object - Core_IPS_Product_Organization__c) Record
    ******************************************************************************/
    public static Core_IPS_Product_Organization__c getSupportOrg(){
        Core_IPS_Product_Organization__c ProductOrganization = new Core_IPS_Product_Organization__c(
            Core_IPS_Support_Org_Name__c = 'TestName',
            Core_Organization_Description__c = 'TestDescription'        
        );
        return ProductOrganization;
    }
    
    /*****************************************************************************
    Method Info : getSupportedProduct Method returns Supported Product (Core_IPS_Supported_Product__c) Record
    ******************************************************************************/
    public static Core_IPS_Supported_Product__c getSupportedProduct(){
        Core_IPS_Supported_Product__c SupportedProductRecord = new Core_IPS_Supported_Product__c(
            
            Core_EOIS__c = false,
            Core_Supported_Product_Name__c = 'Haswell EP'
        );
        return SupportedProductRecord;
    }
    /*****************************************************************************
    Method Info : getMapPar Method returns MAP/PAR  (Core_IPS_MAP_PAR__c) Record
    ******************************************************************************/
    public static Core_IPS_MAP_PAR__c getMapPar(){
        Core_IPS_MAP_PAR__c MapParRecord = new Core_IPS_MAP_PAR__c(
            Core_Name__c='test Par 1'//,
            //RecordTypeId = '012210000004IHY'
        );
        return MapParRecord;
    }
    
    /*****************************************************************************
    Method Info : getCase Method returns Case Record
    ******************************************************************************/
    public static Case getCase(){
        Case CaseRecord = new Case(
            Status = 'New',
            Origin = 'Web',
            Priority = 'High',
            Subject = 'TestSubject',
            Description = 'TestDescription'
        );
        return CaseRecord;
    }
    
    /**********************************************************************************
    Method Info : getUser Method returns User Record
    **********************************************************************************/
    // Create Standard profile User
    public static User getUser() {
        User userRecord = new User(
            Alias = 'StdUser', 
            Email = 'newuser@intel.com', 
            EmailEncodingKey ='UTF-8',
            LastName = 'Testing', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'newuser@intel.com',
            isActive = true
        );
       return userRecord;
    }
    /**********************************************************************************
    Method Info : getCoreBackendSystem Method returns Core_Backend_System__c Record
    **********************************************************************************/
/*    public static Core_Backend_System__c getCoreBackendSystem(){
        Core_Backend_System__c CoreBackendSystemRecord = new Core_Backend_System__c();
        CoreBackendSystemRecord.name='testCoreBackendSystem';
        CoreBackendSystemRecord.Core_Backend_Connection_String__c='test';
        CoreBackendSystemRecord.Core_Backend_System_Name__c='test system';
        CoreBackendSystemRecord.Core_Backend_System_URL__c='https://test.com';
        CoreBackendSystemRecord.Core_Deactivated__c=false;
        return CoreBackendSystemRecord;
    }*/
    /**********************************************************************************
    Method Info : getCoreBackendSupportedProductMap Method returns Core_Backend_Supported_Product_Map__c Record
    **********************************************************************************/
/*    
    public static Core_Backend_Supported_Product_Map__c getCoreBackendSupportedProductMap(){ 
        Core_Backend_Supported_Product_Map__c CoreBackendSupportedProductMapRecord = new Core_Backend_Supported_Product_Map__c();
        CoreBackendSupportedProductMapRecord.Core_Deactivated__c=false;
        return CoreBackendSupportedProductMapRecord;
    } */
    /**********************************************************************************
    Method Info : getEntitlementRecord Method returns Entitlement Record
    **********************************************************************************/
    public static Entitlement getEntitlementRecord(){
        Entitlement EntitlementRecord = new Entitlement();
        EntitlementRecord.Name = 'TestEntitlement'; 
        EntitlementRecord.StartDate = date.today();
        EntitlementRecord.EndDate = date.today();
        return EntitlementRecord;
    }
    /**********************************************************************************
    Method Info : getEntitlementContactRecord Method returns EntitlementContact Record
    **********************************************************************************/
    public static EntitlementContact getEntitlementContactRecord(){
        EntitlementContact EntitlementContactRecord = new EntitlementContact();
        return EntitlementContactRecord;
    }
    /**********************************************************************************
    Method Info : getSupportOrgAdmin Method returns Core_Product_Organization_Admin__c Record
    **********************************************************************************/
    public static Core_IPS_Product_Organization_Admin__c getSupportOrgAdmin(){
        Core_IPS_Product_Organization_Admin__c SupportOrgAdminRecord = new Core_IPS_Product_Organization_Admin__c ();
        return SupportOrgAdminRecord;
    }
    
    /**********************************************************************************
    Method Info : getQueue Method returns Queue Record
    **********************************************************************************/
    public static Group getQueue(){
        Group QueueRecord = new Group(
            Name='TestGroup',
            type='Queue'
        );
        return QueueRecord;
    }
    public static QueuesObject getMappingQueue(){
        QueuesObject MappingQueueRecord = new QueueSObject();
        return MappingQueueRecord;
    }
    
    
    /**********************************************************************************
    Method Info : getQueueXBizHours Method returns Core_IPS_Q_Biz_hours_mapping__c Record
    **********************************************************************************/
    public static Core_IPS_Q_Biz_hours_mapping__c getQueueXBizHours(){
        Core_IPS_Q_Biz_hours_mapping__c QueueXBizHours = new Core_IPS_Q_Biz_hours_mapping__c();
        QueueXBizHours.Active__c = true;
        QueueXBizHours.Name = 'Default';
        return QueueXBizHours;
    }
    
    /**********************************************************************************
    Method Info : getCoreIpsAccount Method returns core_ips_account__c Record
    **********************************************************************************/
    public static core_ips_account__c getCoreIpsAccount(){
        core_ips_account__c CoreIpsAccountRecord = new core_ips_account__c();
            CoreIpsAccountRecord.Core_Members__c = 'All';
            CoreIpsAccountRecord.Core_Status__c = 'Active';
        return CoreIpsAccountRecord;
    }
    
    /**********************************************************************************
    Method Info : getEnvironmentalDetailMaster Method returns Environmental Detail Master (Core_Environment_Variables__c) Record
    **********************************************************************************/
    public static Core_IPS_Environment_Variables__c getEnvironmentalDetailMaster () {
        Core_IPS_Environment_Variables__c EnvironmentalDetailMaster = new Core_IPS_Environment_Variables__c();
        EnvironmentalDetailMaster.Name = 'Issue Resolution List';
        EnvironmentalDetailMaster.Core_Answers__c = 'Intel';
        EnvironmentalDetailMaster.Core_Datatype__c = 'Text (255)';
        EnvironmentalDetailMaster.Core_Status__c = 'Active';
        return EnvironmentalDetailMaster;
    }
    
    /**********************************************************************************
    Method Info : getEnvironmentalDetailsOperational Method returns Environmental Details Operational (Core_Assigned_Environment_Variables__c) Record
    **********************************************************************************/
    public static Core_IPS_Assigned_Environment_Variables__c getEnvironmentalDetailsOperational () {
        Core_IPS_Assigned_Environment_Variables__c EnvironmentalDetailsOperational = new Core_IPS_Assigned_Environment_Variables__c ();
        EnvironmentalDetailsOperational.Core_Status__c = 'Active';
        EnvironmentalDetailsOperational.Core_Required__c = true;
        EnvironmentalDetailsOperational.Core_Agent_Only__c=false;
        return EnvironmentalDetailsOperational;
    }
    
    /**********************************************************************************
    Method Info : getListOfIpsErrorCodes Method returns IPS Error Codes (Core_IPS_Error_Code__c) Record - Custom Setting
    **********************************************************************************/
    
    public static List<Core_IPS_Error_Code__c> getListOfIpsErrorCodes(){
        List<String> ListofIpsErrorCodeNames = new List<String> {'I100','I101','I102','I103','I104','I105','I106','I107','I108','C100','C101','C102','C103','G100','G101','G102','G103','G104','G105','G106'};
        List<Core_IPS_Error_Code__c> ListofIpsErrorCodes = new List<Core_IPS_Error_Code__c> ();
        for(Integer i = 0;i < ListofIpsErrorCodeNames.size(); i++){
            Core_IPS_Error_Code__c  IpsErrorCodes = new Core_IPS_Error_Code__c();
            IpsErrorCodes.Name = ListofIpsErrorCodeNames.get(i);
            IpsErrorCodes.Core_Error_Message__c = 'ErrorMessage';
            IpsErrorCodes.Language__c='EN';
            IpsErrorCodes.Core_Locale__c = 'EN';
            ListofIpsErrorCodes.add(IpsErrorCodes);
        }
        return ListofIpsErrorCodes;
    }
    /**********************************************************************************
    Method Info : getIPSLabel Method returns IPS Labels (Core_IPS_Labels__c) Record - Custom Setting
    **********************************************************************************/   
    public static List<Core_IPS_Labels__c> getIPSLabel(){
        String entitlementProcessId = Core_IPS_Helper_utility.getIPSLabel('IPS Standard Entitlement Process ID');
        Map<string,string> MapofIpsLabelNames = new Map<string,string> {'Core_InactivatingProjMem_Error'=>'Core_InactivatingProjMem_Error','CoreStatus_SP'=>'CoreStatus_SP','Core_IPS_Bug/Fix_ErrMsg'=>'Core_IPS_Bug/Fix_ErrMsg','Core_IPS_Bug/Fix_StatusValue'=>'Closed','CoreStatus_SPtoActive_Error'=>'CoreStatus_SPtoActive_Error','Core_OneProjProdMem_Error'=>'Core_OneProjProdMem_Error','Core_IPS_MPNDA_ErrorMsg'=>'Core_IPS_MPNDA_ErrorMsg','CoreStatus_Draft'=>'Draft','IPS Standard Entitlement'=>'IPS Standard Entitlement','IPS_Case_Status_Investigating'=>'Investigating','IPS Standard Entitlement Process ID'=>'552210000004C9XAAU','AccessLevel_Edit'=>'Edit','CaseCategory'=>'Case Category','CaseCategoryObjectApi'=>'Core_IPS_Product_Issue_Category__c','CaseSubCategory'=>'Case Subcategory','CoreStatus_Active'=>'Active','CoreStatus_Inactive'=>'Inactive','CoreType_Issue_Sub_Category'=>'Issue Sub Category','CoreType_Product'=>'Product','EnvironmentalDetailMasterObjectApi'=>'Core_IPS_Environment_Variables__c','GEC_Status_Approved'=>'Approved','Rowcause_Owner'=>'Owner','RowCause_Team'=>'Team','SubStatus_Investigating'=>'Investigating','SubStatus_Waiting'=>'Waiting','SupportedProductObjectApi'=>'Core_IPS_Supported_Product__c','Assigned_Environment_Variables'=>'Core_IPS_Assigned_Environment_Variables__c','ProjectGroupPrefix'=>'ProjectGroupPrefix','AccessLevel_Read'=>'Read','TimeOfAlertMessageInSeconds'=>'30','Core_IPS_text_255'=>'Text (255)','Core_IPS_textarea_5000'=>'Text Area (5000)','Core_IPS_Picklist'=>'Picklist','Core_IPS_Multi_Select'=>'Multiselect Picklist','Core_IPS_Global_Asset_RT'=>'Core_IPS_Public_Product','Core_IPS_Close_Pending_SubStatus'=>'Close-Pending','Core_IPS_Insufficient_Privileges_Case'=>'Test Msg','Core_IPS_Case_Close_Pending_Msg'=>'test msg','Core_IPS_Error_Msg_Case_Comment' => 'test msg','Core_IPS_No_Ass_Contact_Case_RT'=>'Core_IPS_Case_Create_Self_Assigned','Core_IPS_Case_Closed_Status'=>'Closed','Core_IPS_Case_Status_Open'=>'Open','Core_IPS_Err_Msg_Agent_CaseClosure'=>'Err','PUBLIC_TO_CUSTOMERS'=>'PUBLIC_TO_CUSTOMERS','Customer'=>'Customer','Agent'=>'Agent','FAE'=>'FAE','Data Migration'=>'Data Migration','Core_IPS_Profile_IPS_Agent_Partner'=>'IPS Agent-Partner','Core_IPS_Insuff_Access_Req_CaseClosure'=>'testmsg'};
        List<string> ListofMapKeys = new List<string>(MapofIpsLabelNames.keySet());
        List<Core_IPS_Labels__c> ListofIpsLables = new List<Core_IPS_Labels__c> ();
        for(Integer i = 0;i < ListofMapKeys.size(); i++){
            Core_IPS_Labels__c  IpsLabels = new Core_IPS_Labels__c();
            IpsLabels.Name = ListofMapKeys.get(i);
            IpsLabels.Value__c = MapofIpsLabelNames.get(ListofMapKeys.get(i));
            
            ListofIpsLables.add(IpsLabels);
        }
        return ListofIpsLables;
    }
    
    /**********************************************************************************
    Method Info : getStandardActionRedirection Method returns Standard Action Redirection values (StandardActionRedirection__C) Record - Custom Setting
    **********************************************************************************/   
    public static List<StandardActionRedirection__C> getStandardActionRedirection(Integer numofAct){
        List<StandardActionRedirection__C> ListofStandardAction = new List<StandardActionRedirection__C> ();
        for(Integer i = 0;i < numofAct; i++){
            StandardActionRedirection__C  StandardAction = new StandardActionRedirection__C();
            StandardAction.Object__c = 'Case';
            ListofStandardAction.add(StandardAction);
        }
        return ListofStandardAction;
    }
    
    /**********************************************************************************
    Method Info : getMasterCaseCategories Method returns Master Case Categories (Core_Master_Issue_Category__c) Record
    **********************************************************************************/
    public static Core_IPS_Master_Issue_Category__c getMasterCaseCategories () {
        Core_IPS_Master_Issue_Category__c MasterCaseCategories = new Core_IPS_Master_Issue_Category__c();
        MasterCaseCategories.Name = 'Memory';
        MasterCaseCategories.Core_Status__c = 'Active';
        MasterCaseCategories.Core_Type__c = 'Case Subcategory';
        return MasterCaseCategories;
    }
    
    /**********************************************************************************
    Method Info : getCaseCategories Method returns Case Categories (Core_Product_Issue_Category__c) Record
    **********************************************************************************/
    public static Core_IPS_Product_Issue_Category__c getCaseCategories () {
        Core_IPS_Product_Issue_Category__c CaseCategories = new Core_IPS_Product_Issue_Category__c();
        CaseCategories.Core_Status__c = 'Active';
        CaseCategories.Core_Type__c = 'Case Subcategory';
        return CaseCategories;
    }
    public static Core_IPS_Product__c getIpsProduct(){
        Core_IPS_Product__c IpsProductRecord = new Core_IPS_Product__c ();
        return IpsProductRecord;
    }
    public static Account getAccount(){ 
        Account accountRecord = new Account();
        accountRecord.recordTypeId = [select id from Recordtype where Developername='Mastered_Account'].id;
        accountRecord.Name = 'Test Account';
        accountRecord.Core_Account_Type__c = 'Distributor';
        accountRecord.Core_Sales_Segment__c = 'Compute';
        accountRecord.Industry = 'Banking';
        accountRecord.BillingCity = 'Delhi';
        accountRecord.BillingCountry = 'USA';
        accountRecord.billingState = 'AK';
        accountRecord.billingStreet = '10street';
        return accountRecord;
    }
    public static Asset getAsset(){
        Asset assetRecord = new Asset();
        assetRecord.name = 'Laptop';
        assetRecord.Status = 'Active';
    return AssetRecord;
    }
    
    // Bulk Record creation Methods
    /*****************************************************************************
    Method Info : getListOfAccounts Method returns List of Account Records
    ******************************************************************************/
    public static List<Account> getListOfAccounts(integer NumOfRec){
        
        List<Account> ListOfAccounts = new List<Account> ();
        ID recordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId();
        UserRole role=new UserRole();
        role.name='CEO';
        
        insert role;
       
        profile prof = [select id, name from Profile where name = 'System Administrator' limit 1];
        List<user> userList = getListofuser(1);
        userlist[0].profileid=prof.id;
        userList[0].userroleid=role.id;
        userlist[0].username='portal.user@user.com';
        
        insert userlist;
        
        for(Integer i=1;i<=NumOfRec;i++){
            Account accountRecord = new Account(
                recordTypeId = recordTypeId,
                ownerid=userlist[0].id,
                Name = 'Dell Products '+i,
                Core_Account_Type__c = 'Distributor',
                Core_Sales_Segment__c = 'Compute',
                Industry = 'Banking',
                BillingCity = 'Delhi',
                BillingCountry = 'USA',
                billingState = 'AK',
                billingStreet = 'Bratislava 1',
                Core_IPS_Active__c = true
          );
            ListOfAccounts.add(accountRecord);
        }
        return ListOfAccounts;
    }
    /*****************************************************************************
    Method Info : getListOfContact Method returns List of Contact Record
    ******************************************************************************/
    public static List<Contact> getListOfContact(integer NumOfRec){
        List<Contact> ListOfContacts = new List<Contact> ();
        ID recordTypeId = schema.sobjecttype.Contact.getrecordtypeinfosbyname().get('Outlook contact').getRecordTypeId();
        User u = [select id from user where usertype='Standard' AND ISActive=true limit 1 ];
        for(Integer i=1;i<=NumOfRec;i++){
            Contact contactRecord = new Contact(
                FirstName = 'Ding Dong', 
                Lastname = 'Dell',
                Email = 'Contact1Dell@gmail.com',
                recordTypeId = recordTypeId,
                Core_IPS_Intel_Support_Owner__c=u.id,
                Core_IPS_Active__c = true
            );
            ListOfContacts.add(contactRecord);
        }
        return ListOfContacts;
    }
    /**********************************************************************************
    Method Info : getListOfUser Method returns User Record
    **********************************************************************************/
    public static List<User> getListOfUser(integer NumOfRec) {
        List<User> ListOfUser = new List<User> ();
        // Commented By Syed - Below Role is inserted and not used anywhere. 
        /* UserRole role = new UserRole();
        role.name='CEO';
        insert role; 
        */
        for(Integer i=1;i<=NumOfRec;i++){
            User userRecord = new User(
                Alias = 'StdUser', 
                Email = i+'newuser@intel.com', 
                EmailEncodingKey ='UTF-8',
                LastName = 'Testing'+i,
                FirstName = 'FName',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles', 
                UserName = i+'newuser123@intel.com',
                isActive = true
            );
            ListOfUser.add(userRecord);
        }
       return ListOfUser;
    }
    /*****************************************************************************
    Method Info : getListOfCases Method returns Case Record
    ******************************************************************************/
    public static List<Case> getListOfCases(integer NumOfRec){
        List<Case> ListOfCase = new List<Case> ();
        Map<string,ID> CaseRecordtype = new Map<string,ID>();
        for(Recordtype Rt:[Select ID,Name from Recordtype where sobjectType = 'Case'])
        {  
              CaseRecordtype.put(Rt.Name,Rt.ID);
        }  
        for(Integer i=1;i<=NumOfRec;i++){
            Case CaseRecord = new Case(
                Status = 'New',
                Origin = 'Web',
                Priority = 'High',
                Subject = 'TestSubject '+i,
                Description = 'TestDescription',
                RecordTypeId = CaseRecordtype.get('IPS Case Create')
            );
            ListOfCase.add(CaseRecord);
        }
        return ListOfCase;
    }
    /*****************************************************************************
    Method Info : getListOfIpsProjects Method returns List of IPS Project (Core_IPS_Project__c) Records
    ******************************************************************************/
    public static List<Core_IPS_Project__c> getListOfIpsProjects(integer NumOfRec){
        List<Core_IPS_Project__c> ListOfIpsProjects = new List<Core_IPS_Project__c> ();
        for(Integer i=1;i<=NumOfRec;i++){
            Core_IPS_Project__c ipsProjectRecord = new Core_IPS_Project__c(
                Name = 'ipsProjectName '+i,
                /*modified by Aayushi 06-11-2017 US79852*/
                Core_Status__c = 'Draft',
                Core_MPNDA__c='12345'
            );
            ListOfIpsProjects.add(ipsProjectRecord);
        }
        return ListOfIpsProjects;
    }
    /*****************************************************************************
    Method Info : getListOfIpsProducts Method returns List of IPS Product (Core_IPS_Product__c) Records
    ******************************************************************************/
    public static List<Core_IPS_Product__c> getListOfIpsProducts(integer NumOfRec){
        List<Core_IPS_Product__c> ListOfIpsProducts = new List<Core_IPS_Product__c> ();
        for(Integer i=1;i<=NumOfRec;i++){
            Core_IPS_Product__c ipsProductRecord = new Core_IPS_Product__c();
            ListOfIpsProducts.add(ipsProductRecord);
        }
        return ListOfIpsProducts;
    }
    /*****************************************************************************
    Method Info : getListOfIpsAccounts Method returns List of IPS Accounts (Core_IPS_Account__c) Records
    ******************************************************************************/
    public static List<Core_IPS_Account__c>  getListOfIpsAccounts(integer NumOfRec){
        List<Core_IPS_Account__c> ListOfIpsAccounts = new List<Core_IPS_Account__c>  ();
        for(Integer i=1;i<=NumOfRec;i++){
            Core_IPS_Account__c ipsAccountRecord = new Core_IPS_Account__c(
                Core_Status__c = 'Active',
                Core_Members__c='All'
            );
            ListOfIpsAccounts.add(ipsAccountRecord);
        }
        return ListOfIpsAccounts;
    }
    /*****************************************************************************
    Method Info : getAssetList Method returns List of Asset (Standard Asset object - Intel Product) Records
    ******************************************************************************/
    public static List<Asset> getAssetList(integer NumOfRec){
        List<Asset> AssetList = new List<Asset>();
    
        for(Integer i=1;i<=NumOfRec;i++){
            Asset AssetRecord = new Asset(
                name = 'AssetName '+i,
                Status = 'Active'
            );
            AssetList.add(AssetRecord);
        }
        return AssetList;
    }
    /*****************************************************************************
    Method Info : getListOfProduct Method returns List Of Product (Product) Records
    ******************************************************************************/
    public static List<Product2> getListOfProduct(integer NumOfRec){
        List<Product2> ListOfProducts = new List<Product2> ();
        for(Integer i=1;i<=NumOfRec;i++){
            Product2 productRecord = new Product2(
                Name = 'Haswell EP '+i,
                Core_Sales_Visible_Flag__c = false,
                Core_IPS_Visible_Flag_External__c= true,
                Core_IPS_Visible_Flag_Internal__c= 'Yes',
                Core_Product_Org__c = 'IPS',
                IsActive = true,
                Core_Unique_ID__c = 'Test'+i
            );
            ListOfProducts.add(productRecord);
        }
        return ListOfProducts;
    }
    /*****************************************************************************
    Method Info :  getListOfSupportOrg method returns List of Support Org(Custom object - Core_IPS_Product_Organization__c) Records
    ******************************************************************************/
    public static List<Core_IPS_Product_Organization__c> getListOfSupportOrg(integer NumOfRec){
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg = new List<Core_IPS_Product_Organization__c> ();
        for(Integer i=1;i<=NumOfRec;i++){
            Core_IPS_Product_Organization__c ProductOrganization = new Core_IPS_Product_Organization__c(
                Core_IPS_Support_Org_Name__c = 'TestName '+i,
                Core_Organization_Description__c = 'TestDescription'        
            );
            ListOfSupportOrg.add(ProductOrganization);
        }
        return ListOfSupportOrg;
    }
    /*****************************************************************************
    Method Info : getListOfSupportedProduct Method returns List Of Supported Product (Core_IPS_Supported_Product__c) Records
    ******************************************************************************/
    public static List<Core_IPS_Supported_Product__c> getListOfSupportedProduct(integer NumOfRec){
        List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = new List<Core_IPS_Supported_Product__c> ();
        for(Integer i=1;i<=NumOfRec;i++){
            Core_IPS_Supported_Product__c SupportedProductRecord = new Core_IPS_Supported_Product__c(
                Core_Flag_Status__c = 'Approval Required',
                Core_EOIS__c = false
                // Core_Supported_Product_Name__c = 'Haswell EP '+i,
                // Core_Unique_Supported_Product__c = 'Test'+i
            );
            ListOfSupportedProduct.add(SupportedProductRecord);
        }
        return ListOfSupportedProduct;
    }
    /*****************************************************************************
    Method Info : getListOfProjectMembers Method returns List Of Project Member (Core_IPS_Project_Member__c) Record
    ******************************************************************************/
    public static List<Core_IPS_Project_Member__c> getListOfProjectMembers(integer NumOfRec){
        List<Core_IPS_Project_Member__c> ListOfProjectMembers = new List<Core_IPS_Project_Member__c>();
        for(Integer i=1;i<=NumOfRec;i++){
            Core_IPS_Project_Member__c projectMemberRecord = new Core_IPS_Project_Member__c(
            );
            ListOfProjectMembers.add(projectMemberRecord);
        }
        return ListOfProjectMembers;
    }
   /**********************************************************************************
    Method Info : getFileUploadMasterRecord Method returns Core_IPS_File_Upload_Master__c Record
    **********************************************************************************/
    public static Core_IPS_File_Upload_Master__c getFileUploadMasterRecord(){
        Core_IPS_File_Upload_Master__c FileUploadMasterRecord = new Core_IPS_File_Upload_Master__c();
        FileUploadMasterRecord.Core_File_GUID__c = '92d2f462-d749-436a-9d76-e93bf9f69f9c'; 
        FileUploadMasterRecord.Core_File_Name__c = 'Test';
        FileUploadMasterRecord.Core_Upload_Status__c = 'Complete';
        FileUploadMasterRecord.Core_Expiration_Date__c = system.now();
        return FileUploadMasterRecord;
    }
    /**********************************************************************************
    Method Info : getListOfCoreMastIssCategory Method returns List Of Core Master Issue Category (Core_Master_Issue_Category__c) Records
    **********************************************************************************/
    public static List<Core_IPS_Master_Issue_Category__c> getListOfCoreMastIssCategory (integer NumOfRec) {
        List<Core_IPS_Master_Issue_Category__c> ListOfCoreMastIssCategory = new List<Core_IPS_Master_Issue_Category__c>();
        for(Integer i=1;i<=NumOfRec;i++){
            Core_IPS_Master_Issue_Category__c CoreMastIssCategory = new Core_IPS_Master_Issue_Category__c();
            CoreMastIssCategory.Name = 'Memory '+i;
            CoreMastIssCategory.Core_Status__c = 'Active';
            CoreMastIssCategory.Core_Type__c = 'Case Subcategory';
            ListOfCoreMastIssCategory.add(CoreMastIssCategory);
        }
        return ListOfCoreMastIssCategory;
    }
    /**********************************************************************************
    Method Info : getListOfCoreProdIssCategory Method returns List Of Core Product Issue Category (Core_Product_Issue_Category__c) Records
    **********************************************************************************/
    public static List<Core_IPS_Product_Issue_Category__c> getListOfCoreProdIssCategory (integer NumOfRec) {
        List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory = new List<Core_IPS_Product_Issue_Category__c> ();
      
      
        for(Integer i=0;i<NumOfRec;i++){
            Core_IPS_Product_Issue_Category__c CoreProdIssCategory = new Core_IPS_Product_Issue_Category__c();
         //   CoreProdIssCategory.Core_Supported_Product__c = listOfSupportedProduct[i].id;
            CoreProdIssCategory.Core_Status__c = 'Active';
            CoreProdIssCategory.Core_Type__c = 'Case Subcategory';
            ListOfCoreProdIssCategory.add(CoreProdIssCategory);
        }
        return ListOfCoreProdIssCategory;
    }
    /**********************************************************************************
    Method Info : getListOfEnDetailMaster Method returns List of Environmental Detail Master (Core_Environment_Variables__c) Records
    **********************************************************************************/
    public static List<Core_IPS_Environment_Variables__c> getListOfEnDetailMaster (integer NumOfRec) {
        List<Core_IPS_Environment_Variables__c> ListOfEnDetailMaster = new List<Core_IPS_Environment_Variables__c> ();
        for(Integer i=1;i<=NumOfRec;i++){
            Core_IPS_Environment_Variables__c EnvironmentalDetailMaster = new Core_IPS_Environment_Variables__c();
            EnvironmentalDetailMaster.Name = 'Issue Resolution List '+i;
            EnvironmentalDetailMaster.Core_Answers__c = 'Intel';
            EnvironmentalDetailMaster.Core_Datatype__c = 'Text (255)';
            EnvironmentalDetailMaster.Core_Status__c = 'Active';
            ListOfEnDetailMaster.add(EnvironmentalDetailMaster);
        }
        return ListOfEnDetailMaster;
    }
    
    /**********************************************************************************
    Method Info : getListOfEnvDetailsOperational Method returns List of Environmental Details Operational (Core_Assigned_Environment_Variables__c) Records
    **********************************************************************************/
    public static List<Core_IPS_Assigned_Environment_Variables__c> getListOfEnvDetailsOperational (integer NumOfRec) {
        List<Core_IPS_Assigned_Environment_Variables__c> ListOfEnvDetailsOperational = new List<Core_IPS_Assigned_Environment_Variables__c> ();
        for(Integer i=1;i<=NumOfRec;i++){
            Core_IPS_Assigned_Environment_Variables__c EnvironmentalDetailsOperational = new Core_IPS_Assigned_Environment_Variables__c();
            EnvironmentalDetailsOperational.Core_Status__c = 'Active';
            ListOfEnvDetailsOperational.add(EnvironmentalDetailsOperational);
        }
        return ListOfEnvDetailsOperational;
    }   
    /**********************************************************************************
    Method Info : getListOfEnvDetailsOperational Method returns List of Flat Product Hierarchy (Core_Flat_Product_Hierarchy__c) Records
    **********************************************************************************/
    public static List<Core_Flat_Product_Hierarchy__c> getListOfFlatProductHierarchy (integer NumOfRec) {
        List<Core_Flat_Product_Hierarchy__c> ListOfFlatProductHierarchy = new List<Core_Flat_Product_Hierarchy__c> ();
        for(Integer i=1;i<=NumOfRec;i++){
            Core_Flat_Product_Hierarchy__c FlatProductHierarchy = new Core_Flat_Product_Hierarchy__c ();
            FlatProductHierarchy.Core_EPM_Hierarchy_ID__c = 'EMP hierarchy ID '+i;
            FlatProductHierarchy.Core_L1_EPM_ID__c = 'L1 Id '+i;
            FlatProductHierarchy.Core_L1_EPM_Name__c = 'L1 Name '+i;
            FlatProductHierarchy.Core_L2_EPM_ID__c = 'L2 Id '+i;
            FlatProductHierarchy.Core_L2_EPM_Name__c = 'L2 Name '+i;
            FlatProductHierarchy.Core_L3_EPM_ID__c = 'L3 Id '+i;
            FlatProductHierarchy.Core_L3_EPM_Name__c = 'L31 Name '+i;
            FlatProductHierarchy.Core_L4_EPM_ID__c = 'L4 Id '+i;
            FlatProductHierarchy.Core_L4_EPM_Name__c = 'L4 Name '+i;
            FlatProductHierarchy.Core_L5_EPM_ID__c = 'L5 Id '+i;
            FlatProductHierarchy.Core_L5_EPM_Name__c = 'L5 Name '+i;
            ListOfFlatProductHierarchy.add(FlatProductHierarchy);
        }
        return ListOfFlatProductHierarchy;
    }
    
    /**********************************************************************************
    Method Info : getListOfTriggerExecutions Method returns Trigger Executions (Core_Trigger_Executions__c) Record - Custom Setting
    **********************************************************************************/
    public static List<Core_Trigger_Executions__c> getListOfTriggerExecutions(){
        List<String> ListofTriggerExecutionMethodNames = new List<String> {'inactivatingProjMem','activateProject','executeCaseAssignmentRule','caseSLAManagement','assignCaseInformation','assignEntitlementToCase','ProvideCaseAccess','provideCaseAccessToCreatedFAE','assignContactRule'};
        List<Core_Trigger_Executions__c> ListOfTriggerExecutions = new List<Core_Trigger_Executions__c> ();
        for(Integer i = 0;i < ListofTriggerExecutionMethodNames.size(); i++){
            Core_Trigger_Executions__c  TriggerExecution = new Core_Trigger_Executions__c();
            TriggerExecution.Name = ListofTriggerExecutionMethodNames.get(i);
            TriggerExecution.Core_Active__c = true;
            TriggerExecution.Core_Class_Name__c ='ClassName';
            TriggerExecution.Core_Description__c = 'MethodDescription';
            TriggerExecution.Core_Object__c = 'Account';
            TriggerExecution.Core_Trigger_Events__c = 'Before Insert';
            ListOfTriggerExecutions.add(TriggerExecution);
        }
        return ListOfTriggerExecutions;
    }
     /**********************************************************************************
    Method Info : getListOfEntitlement Method returns List of Entitlement Records
    **********************************************************************************/
    public static List<Entitlement> getListOfEntitlement(integer NumOfRec){
        List<Entitlement> ListOfEntitlement = new List<Entitlement>();
        for(Integer i=1;i<=NumOfRec;i++){
            Entitlement EntitlementRecord = new Entitlement();
            EntitlementRecord.Name = 'TestEntitlement '+i; 
            EntitlementRecord.StartDate = (system.today() - 2);
            EntitlementRecord.EndDate = (system.today() + 2);
            ListOfEntitlement.add(EntitlementRecord);
        }
        return ListOfEntitlement;
    }
    /**********************************************************************************
    Method Info : getListOfEntitlementContact Method returns List of EntitlementContact Record
    **********************************************************************************/
    public static List<EntitlementContact> getListOfEntitlementContact(integer NumOfRec){
        List<EntitlementContact> ListOfEntitlementContact = new List<EntitlementContact>();
        for(Integer i=1;i<=NumOfRec;i++){
            EntitlementContact EntitlementContactRecord = new EntitlementContact();
            ListOfEntitlementContact.add(EntitlementContactRecord);
        }
        return ListOfEntitlementContact;
    }
    
    
    public static List<Core_IPS_Environment_Variables__c> getEnvironmentVariables(integer NumOfRec){
        List<Core_IPS_Environment_Variables__c> ListOfEnvDetails = new List<Core_IPS_Environment_Variables__c>();
        Core_IPS_Product_Organization__c prodOrg = getSupportOrg();
        insert prodOrg;
        for(Integer i=1;i<=NumOfRec;i++){
            Core_IPS_Environment_Variables__c envDet= new Core_IPS_Environment_Variables__c();
            envDet.Core_Product_Organization__c = prodOrg.Id;
            envDet.Core_Datatype__c='text (255)';
            envDet.name='Test Question';
            envDet.Core_Type__c='test';
            envDet.Core_Status__c='Active';
            ListOfEnvDetails.add(envDet);
        }
        return ListOfEnvDetails;
    }
    
    /**********************************************************************************
    Method Info : getAccountsList Method returns List of Acccounts for MAP/PAR Handler Classes testing
    **********************************************************************************/
    public static List<Account> getAccountsList(integer NumOfRec){
        
        List<Account> ListOfAccounts = new List<Account> ();
        ID recordTypeId = schema.sobjecttype.Account.getrecordtypeinfosbyname().get('Intel Account').getRecordTypeId();

        for(Integer i=1;i<=NumOfRec;i++){
            Account accountRecord = new Account(
                recordTypeId = recordTypeId,
                Name = 'Dell Products '+i,
                Core_Account_Type__c = 'Distributor',
                Core_Sales_Segment__c = 'Compute',
                Industry = 'Banking',
                BillingCity = 'Delhi',
                BillingCountry = 'USA',
                billingState = 'AK',
                billingStreet = 'Bratislava 1',
                Core_IPS_Active__c = true
            );
            ListOfAccounts.add(accountRecord);
        }
        return ListOfAccounts;
    }
    
    /**********************************************************************************
    Method Info : getAccountTeamList Method returns List of Custom Acccount Team for Custom AccountTeam Handler Classes testing
    **********************************************************************************/
    public static List<Core_Account_Team__c> getEditableCustomAccountTeamList(integer NumOfRec){
        
        profile prof = [select id, name from Profile where name = 'Sales Rep-BB' limit 1];
        List<user> userList = getListofuser(1);
        userlist[0].profileid=prof.id;
        userlist[0].username='salesrep011231.abc@user.com';
        
        insert userlist;
        
        List<Core_Account_Team__c> ListOfCustomAccountTeam = new List<Core_Account_Team__c> ();
        
        for(Integer i=1;i<=NumOfRec;i++){
            Core_Account_Team__c accountTeamRecord = new Core_Account_Team__c(
                //Core_Account__c = accId,
                Core_Case_Access__c = 'Edit',
                Core_Team_Member__c = userlist[0].Id
            );
            ListOfCustomAccountTeam.add(accountTeamRecord);
        }
        return ListOfCustomAccountTeam;
    }
    
    /**********************************************************************************
    Method Info : getAccountTeamList Method returns List of Custom Acccount Team for Custom AccountTeam Handler Classes testing
    **********************************************************************************/
    public static List<Core_Account_Team__c> getReadCustomAccountTeamList(integer NumOfRec){
        
        profile prof = [select id, name from Profile where name = 'Sales Rep-BB' limit 1];
        List<user> userList = getListofuser(1);
        userlist[0].profileid=prof.id;
        userlist[0].username='salesrep02.abc@user.com';
        
        insert userlist;
        
        List<Core_Account_Team__c> ListOfCustomAccountTeam = new List<Core_Account_Team__c> ();
        
        for(Integer i=1;i<=NumOfRec;i++){
            Core_Account_Team__c accountTeamRecord = new Core_Account_Team__c(
                //Core_Account__c = accId,
                Core_Case_Access__c = 'Read',
                Core_Team_Member__c = userlist[0].Id
            );
            ListOfCustomAccountTeam.add(accountTeamRecord);
        }
        return ListOfCustomAccountTeam;
    }
    
    /**********************************************************************************
    Method Info : getAccountTeamList Method returns List of Custom Acccount Team for Custom AccountTeam Handler Classes testing
    **********************************************************************************/
    public static List<Core_Account_Team__c> getPrivateCustomAccountTeamList(integer NumOfRec){
        
        profile prof = [select id, name from Profile where name = 'Sales Rep-BB' limit 1];
        List<user> userList = getListofuser(1);
        userlist[0].profileid=prof.id;
        userlist[0].username='salesrep03.abc@user.com';
        
        insert userlist;
        
        List<Core_Account_Team__c> ListOfCustomAccountTeam = new List<Core_Account_Team__c> ();
        
        for(Integer i=1;i<=NumOfRec;i++){
            Core_Account_Team__c accountTeamRecord = new Core_Account_Team__c(
                //Core_Account__c = accId,
                Core_Case_Access__c = 'None',
                Core_Team_Member__c = userlist[0].Id
            );
            ListOfCustomAccountTeam.add(accountTeamRecord);
        }
        return ListOfCustomAccountTeam;
    }
    
    /**********************************************************************************
    Method Info : getIPSMAPAccount Method returns Core_IPS_MAP_Account__c Record
    **********************************************************************************/
    public static Core_IPS_MAP_Account__c getIPSMAPAccount(){
        Core_IPS_MAP_Account__c IPSMAPAccountRecord = new Core_IPS_MAP_Account__c();            
        return IPSMAPAccountRecord;
    }
    /**********************************************************************************
    Method Info : getIPSMAPAccount Method returns Core_IPS_MAP_Account__c Record
    **********************************************************************************/
    public static List<Core_IPS_MAP_Account__c> getIPSMAPAccountList(Integer NumOfRec){
        List<Core_IPS_MAP_Account__c> mapAccList = new List<Core_IPS_MAP_Account__c>();
        for(Integer i=1;i<=NumOfRec;i++){
            Core_IPS_MAP_Account__c IPSMAPAccountRecord = new Core_IPS_MAP_Account__c();            
            mapAccList.add(IPSMAPAccountRecord);
        }
        return mapAccList;
    }
    
    /*****************************************************************************
    Method Info : getMapPar Method returns MAP/PAR  (Core_IPS_MAP_PAR__c) Record
    ******************************************************************************/
    public static List<Core_IPS_MAP_PAR__c> getMapParList(Integer NumOfRec){
        List<Core_IPS_MAP_PAR__c> mapParList = new List<Core_IPS_MAP_PAR__c>();
        for(Integer i=1;i<=NumOfRec;i++){
            Core_IPS_MAP_PAR__c MapParRecord = new Core_IPS_MAP_PAR__c(
                Core_Name__c='test Par 1'//,
                //RecordTypeId = '012210000004IHY'
            );
            mapParList.add(MapParRecord);
        }
        return mapParList;
    }
    
    /*****************************************************************************
    Method Info : getMapPar Method returns MAP/PAR  (Core_IPS_MAP_PAR__c) Record
    ******************************************************************************/
    public static list<Core_IPS_Environment_Details__c> getEnvironmentDetailResponses(Integer NumOfRec){
        List<Core_IPS_Environment_Details__c> envResponses = new List<Core_IPS_Environment_Details__c>();
        for(Integer i=0;i<NumOfRec;i++){
            Core_IPS_Environment_Details__c det = new Core_IPS_Environment_Details__c();
            det.Core_Question__c='Test Question'+i;
            det.Core_Answer__c='Test Answer'+i;
            envResponses.add(det);
        }
        return envResponses;
    }
    
    /*****************************************************************************
    Method Info : getInternalInterestedParties Method returns interested parties records
    ******************************************************************************/
    public static list<Core_IPS_Case_Interested_Party__c> getInternalInterestedParties(Integer NumOfRec){
        List<Core_IPS_Case_Interested_Party__c> ip = new List<Core_IPS_Case_Interested_Party__c>();
        for(Integer i=0;i<NumOfRec;i++){
            Core_IPS_Case_Interested_Party__c ipObj = new Core_IPS_Case_Interested_Party__c();
            ipObj.Active__c = TRUE; 
            ip.add(ipObj);
        }
        return ip;
    }

    /*****************************************************************************
    Method Info : getInternalInterestedParties Method returns interested parties records basedon the parttyType(Internal or External)
    ******************************************************************************/
    public static list<Core_IPS_Case_Interested_Party__c> getInternalInterestedParties(Integer NumOfRec, String partyType){
        String recTypeName = '';
        RecordType recType = null;
        if('External'.equals(partyType)){
            recType = [SELECT Id FROM RecordType where SobjectType ='Core_IPS_Case_Interested_Party__c' AND isActive =true AND DeveloperName ='Cutomer' Limit 1];
        }else{
            recType = [SELECT Id FROM RecordType where SobjectType ='Core_IPS_Case_Interested_Party__c' AND isActive =true  AND DeveloperName ='Internal' Limit 1];
        }
        
        List<Core_IPS_Case_Interested_Party__c> ipList = new List<Core_IPS_Case_Interested_Party__c>();
        for(Integer i=0;i<NumOfRec;i++){
            Core_IPS_Case_Interested_Party__c ipObj = new Core_IPS_Case_Interested_Party__c();
            ipObj.Active__c = TRUE; 
            ipObj.RecordTypeId = recType.Id;
            if('External'.equals(partyType)){
                ipObj.Type__c = 'External';
            }else{
                ipObj.Type__c = 'Internal';
            }
            ipList.add(ipObj);
        }
        return ipList;
    }

    
    /*****************************************************************************
    Method Info : getOpportunityRecord Method returns Opportunity Record
    ******************************************************************************/
    
    public static Opportunity getOpportunityRecord(){
        Opportunity opportunityRecord = new Opportunity(
            recordTypeId = schema.sobjecttype.Opportunity.getrecordtypeinfosbyname().get('Design Opportunity').getRecordTypeId(),
            Name = 'Test Opportunity',
            StageName = 'Test Name',
            CloseDate = (system.today() + 2)
          );
        return opportunityRecord;
    
    }
    
    /*****************************************************************************
    Method Info : getCaseComments Method returns case RTF Record
    ******************************************************************************/
    
    public static List<Core_IPS_Case_Comments__c> getCaseComments(Integer numOfRecords){
        List<Core_IPS_Case_Comments__c> ipsComments = new List<Core_IPS_Case_Comments__c>();
        for(Integer i=0;i<numOfRecords;i++){            
            
            Core_IPS_Case_Comments__c caseComment = new Core_IPS_Case_Comments__c();  
            if(i==0){
                caseComment.Core_IPS_Case_Comment_Type__c=Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
            }else if(i==1){
                caseComment.Core_IPS_Case_Comment_Type__c=Core_IPS_Labels__c.getValues('PRIVATE_TO_AGENTS').value__c;  
            }else if(i==2){
                caseComment.Core_IPS_Case_Comment_Type__c=Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL').value__c;  
            }
            caseComment.Core_IPS_Rich_Comment__c= 'IPS Team testing';  
            caseComment.Core_IPS_Comment__c = 'Test Comment'+i;            
            ipsComments.add(caseComment);
        }
        return ipsComments;
    }
    
    
    public static BusinessHours getBusinessHours(){
        BusinessHours newHours = new BusinessHours(
            MondayStartTime = Time.newInstance(9, 0, 0, 0),
            MondayEndTime = Time.newInstance(17, 0, 0, 0),
            TuesdayStartTime = Time.newInstance(9, 0, 0, 0),
            TuesdayEndTime = Time.newInstance(17, 0, 0, 0),
            WednesdayStartTime = Time.newInstance(9, 0, 0, 0),
            WednesdayEndTime = Time.newInstance(17, 0, 0, 0),
            ThursdayStartTime = Time.newInstance(9, 0, 0, 0),
            ThursdayEndTime = Time.newInstance(17, 0, 0, 0),
            FridayStartTime = Time.newInstance(9, 0, 0, 0),
            FridayEndTime = Time.newInstance(17, 0, 0, 0),
            IsActive = true,
            IsDefault = true
        );
        return newHours;
    }
    
    
    /**********************************************************************************
    Method Info : getCustomerUsersWithAccountsAndContacts Used for testing IPSProject creation for external Customers
    Method creates a List of Accounts, pass zero of no contacts, or assets needed
    @params
    accName - account name for test accounts which appends 0-n based on the number of accounts
    noOfAccounts - No of Accounts.
    noOfContacts - No of Contacts for each Account
    noOfCommUsers - No of commuity Users for each Account
    noOfAssets - No of Assets for Each each.
    **********************************************************************************/
    public static void getCustomerUsersWithAccountsAndContacts(String accName, Integer noOfAccounts, Integer noOfIPSContacts,
                                                               Integer noOfNonIPSContacts, Integer noOfCommUsers, String communityProfileName,  Integer noOfAssets)
    {
       
        System.debug(' TestUtilities Setup data for getCustomerUsersWithAccountsAndContacts Entered');                                                           
        RecordType acctRT = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType='Account' AND Name ='Intel Account'];
        RecordType conRT = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType='Contact' AND Name ='Intel Contact'];
        
        
        User adminUser = [ select Id from User where profile.Name = 'System Administrator' and userRoleId != null AND ISActive=true Limit 1];
        Set<String> customerUserTypes = new Set<String> {'PowerCustomerSuccess'};
            String acctName = String.isBlank(accName) ? 'NewTestAcct': accName;
        List<Account> accts = new List<Account>();
        for(Integer i=0;i<noOfAccounts;i++){
            accts.add(new Account (Name = acctName+String.valueOf(i),BillingCity = 'folsom',RecordTypeId = acctRT.Id, 
                                   Core_Account_Type__c = 'Distributor',
                                   Core_Sales_Segment__c = 'Compute',
                                   Industry = 'Banking',Core_IPS_Active__c = true,
                                   BillingCountry = 'USA', BillingStreet = 'Creek Side Dr', Ownerid =adminUser.id));  
            
        }
        insert accts;
        System.debug(' Accounts '+Json.serialize(accts));
        
        List<Contact> contacts = new List<Contact>();
        for(Integer a = 0;a<accts.size();a++){
            Integer i = 0;
            for(Integer c=0;c< noOfIPSContacts;c++){
                String fname = 'Contact'+String.valueOf(i);
                contacts.add(new Contact (AccountId = accts[a].Id,FirstName = fname, LastName  = accts[a].Name,
                                          email = accts[a].Name+fname+'@unitTest.com',Core_IPS_Intel_Support_Owner__c= adminUser.id,
                                          Core_IPS_Active__c = true, RecordType = conRT));
                i+=1;
            }
            for(Integer c=0;c< noOfNonIPSContacts;c++){
                String fname = 'Contact'+String.valueOf(i);
                contacts.add(new Contact (AccountId = accts[a].Id,FirstName = fname, LastName  = accts[a].Name,
                                          email = accts[a].Name+fname+'@unitTest.com',Core_IPS_Intel_Support_Owner__c= adminUser.id,
                                          Core_IPS_Active__c = false, RecordType = conRT));
                i+=1;
            }
        }
        insert contacts;
        System.debug(' contacts '+Json.serialize(contacts));
        
        List<Account> allAccts = [Select Id, Name, (Select FirstName, LastName, email FROM Contacts) from Account];
        System.debug(' allAccts '+Json.serialize(allAccts));
        List<User> users = new List<User>();
        User commUser;
        Set<Id> allIds = new Set<Id>();
        System.runAs ( adminUser ) {
            Profile p =   [select Id,name from Profile where Name = :communityProfileName limit 1];
            system.debug('>>>>>>>>>>>>>>>' + p);            
            for(Account acct : allAccts){
                Integer i= 0;
                for(Contact cont: acct.contacts){
                    System.debug('+++++++ '+cont);
                    allIds.add(cont.Id);
                    commUser = new User(
                        //UserRoleId = ur.Id,
                        profileId = p.id,
                        username = cont.email,
                        email = cont.email,
                        emailencodingkey = 'UTF-8',
                        localesidkey = 'en_US',
                        languagelocalekey = 'en_US',
                        timezonesidkey = 'America/Los_Angeles',
                        alias = 'commUsr'+String.valueOf(i),
                        lastname = acct.Name,
                        firstname = 'CommUser'+String.valueOf(i),
                        contactId = cont.id
                    );
                    if(i>=noOfCommUsers)
                        break;
                    i=i+1;
                    users.add(commUser);
                }
                //System.debug(' Community User '+[Select Id, Name, ContactId, AccountId, UserType, UserRole.Name FROM User ]);
            }
            insert users;  
            getAssets(accts, noOfAssets);
            
        }
        System.debug(' TestUtilities Setup data for getCustomerUsersWithAccountsAndContacts Exiting');       
    }
    
    
    /**********************************************************************************
    Method Info : getAssets - Creates supported Org >Products-> suppoted products->Assets
    @accts - List of Accounts which needs assets
    @noOfAssets - No of Assets for Each Account.
    **********************************************************************************/
    public static List<Asset> getAssets(List<Account> accts, Integer noOfAssets){
        System.debug(' TestUtilities Setup data for getAssets Entered');       
        //Create Support Org
        Core_IPS_Product_Organization__c SupOrg = new Core_IPS_Product_Organization__c(); //SupportOrg
        SupOrg.Core_IPS_Support_Org_Name__c='Trident Solutions';
        SupOrg.Core_Organization_Description__c='This is from portal side';
        insert SupOrg;
        List<Product2> listOfProducts = getListOfProduct(noOfAssets);
        for(Product2 prod : listOfProducts){
            prod.Core_Product_Name_EPM_ID__c='75025';
            prod.IsActive = true;
            prod.Core_Code_Name_EPM_ID__c ='75025';
            prod.Core_Sales_Visible_Flag__c = false;
            prod.IsActive = true;
            prod.Core_Product_Status__c= 'Active';
            prod.Core_IPS_Visible_Flag_External__c = true;
            prod.Core_IPS_Visible_Flag_Internal__c = 'Yes';
            prod.Core_Product_Org__c = 'IPS';
            prod.Core_Hierarchy_ID__c = '43';
            prod.Core_Unique_ID__c = prod.Name;
        }
        insert listOfProducts;
        
        //Create Supported product Record
        List<Core_IPS_Supported_Product__c> listOfSupportedProduct = getListOfSupportedProduct(noOfAssets);
        for(Integer i=0 ;i< listOfSupportedProduct.size() ; i++){
            Core_IPS_Supported_Product__c sp = listOfSupportedProduct.get(i);
            sp.Core_Product__c = listOfProducts[i].id;
            sp.Core_Product_Organization__c = SupOrg.Id;
            //Below field API name is changed from Core_Is_Show_Variant__c to Core_IPS_Is_Show_Variant__c
            //sp.Core_IPS_Is_Show_Variant__c = true;
            sp.Core_Flag_Status__c = 'Auto Approve';
            sp.Core_Product_EPM_ID__c = '75025';
            sp.Core_Supported_Product_Name__c = listOfProducts[i].Name;
        }
        insert listOfSupportedProduct;
        
        RecordType asstRT = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType where SobjectType='Asset' AND Name ='IPS Asset'];
        
        List<Asset> listofAssets = new List<Asset>();
        for(Account acct : accts){
            for(Integer i=0;i<noOfAssets;i++){
                Asset asst = new Asset();
                asst.name = 'Haswell processor Asset'+String.valueOf(i);
                asst.Status = 'Active';
                asst.Product2Id = listOfProducts[i].id;
                asst.AccountId =  acct.id;
                asst.Core_Project_Asset_Status__c='Active';
                asst.status ='Active';
                asst.RecordTypeID= asstRT.id;
                asst.Core_IPS_Asset__c = true;
                asst.Core_Code_Name__c = 'false';
                asst.Core_Supported_Product__c = listOfSupportedProduct[i].id;
                asst.Core_Product_Organization__c =  SupOrg.Id;
                asst.InstallDate = system.today();
                listofAssets.add(asst);
            }
        }
        insert listofAssets;
        System.debug(' TestUtilities Setup data for getAssets Exiting');       
        return listofAssets;
    } 
    
    /*****************************************************************************
    Method Info : Created by Aayushi addAccMemProdToProject Method adds Account,Members and Supported Product 
    to IPS Project (Core_IPS_Project__c) Record
    Updated by Aayusi 01/09/2018
    ******************************************************************************/
    public static void addAccMemProdToProject(List<Core_IPS_Project__c> projList){
      
       
      //  System.runAs(ListOfUser.get(1)){
        Product2 prod = getProduct();
        insert prod;
        Account acctRecord=getAccountRecord();
        insert acctRecord;
     // start modified by Aayushi US90060  
        Contact contactRecord1,contactrecord2;
        List<Contact> contactList=new List<Contact>();
        contactRecord1 = getContact();
        contactRecord1.Accountid = acctRecord.id;
       // contactRecord.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
        contactRecord1.core_ips_Active__c=false;
        contactRecord1.Email = 'ContactDellTest@gmail.com';
        contactList.add(contactRecord1);
        contactRecord2 = getContact();
        contactRecord2.Accountid = acctRecord.id;
       // contactRecord.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
       // contactRecord2.core_ips_Active__c=false;
        contactRecord2.Email = 'ContactDellTesting@gmail.com';
        contactList.add(contactRecord2);
        insert contactList;
        System.debug('contactRecord '+contactRecord1);
       //end 
        Core_IPS_Product_Organization__c prodOrg = getSupportOrg();
        insert prodOrg;
        Core_IPS_Supported_Product__c sp=getSupportedProduct();
       /* Core_IPS_Supported_Product__c sp = new Core_IPS_Supported_Product__c();
        sp.Core_Flag_Status__c = 'Approval Required';
        sp.Core_EOIS__c = false;
        sp.Core_Supported_Product_Name__c = 'Haswell EP';*/
        sp.Core_Product__c = prod.id;
        sp.Core_Product_Organization__c = prodOrg.id;
        sp.Core_Flag_Status__c = 'Auto Approve';
        insert sp;
           System.debug('>>SP>>'+sp);
        for(Core_IPS_Project__c proj: projList){
        
        core_ips_account__c projAccount= getCoreIpsAccount();
        projAccount.Core_Account__c=acctRecord.Id;
        projAccount.Core_IPS_Project__c=proj.Id;
        insert projAccount;
        
        Core_IPS_Project_Member__c projectMember = getProjectMember();
        projectMember.core_ips_contact__c = contactList[0].id;   //modified by Aayushi US90060
        projectMember.Core_IPS_Project__c = proj.id;
        insert projectMember;
        //start added by Aayushi US90060    
        Core_IPS_Project_Member__c projectMember1 = getProjectMember();
        projectMember1.core_ips_contact__c = contactList[1].id;
        projectMember1.Core_IPS_Project__c = proj.id;
        insert projectMember1;
        //end    
        Core_IPS_Product__c projProduct=getIpsProduct();
        projProduct.Core_IPS_Project__c=proj.Id;
        projProduct.Core_Supported_Product__c=sp.Id;
        insert projProduct;
        System.debug('>>projProduct>>'+projProduct+'>>spId>>'+sp.Id);
        }
       // }   
    }
    public static List<Asset> getAssetList2(integer NumOfRec){
        List<Asset> AssetList = new List<Asset>();
      AssetList =[SELECT Core_IPS_Project_Name__c,Core_IPS_Project__c,core_Product_Application__c,Core_Supported_Product__r.Core_IPS_Public_Product__c, Core_Supported_Product__r.Core_Supported_Product_Name__c,Id FROM Asset];
        system.debug([SELECT Core_IPS_Project_Name__c,Core_IPS_Project__c,core_Product_Application__c,Core_Supported_Product__r.Core_IPS_Public_Product__c, Core_Supported_Product__r.Core_Supported_Product_Name__c,Id FROM Asset]);
      /*  for(Integer i=1;i<=NumOfRec;i++){
            Asset AssetRecord = new Asset(
                name = 'AssetName '+i,
                Status = 'Active'
            );
            AssetList.add(AssetRecord);
        }*/
        return AssetList;
    }
     public static List<Core_IPS_Product_Issue_Category__c> getCoreProdIssCategory (integer NumOfRec) {
        List<Core_IPS_Product_Issue_Category__c> ListOfCoreProdIssCategory = new List<Core_IPS_Product_Issue_Category__c> ();
      
      Product2 prod =getProduct();
      prod.Name='test';
      insert prod;
      
      Core_IPS_Supported_Product__c sp= getSupportedProduct();
      sp.Core_Product__c=prod.id;
      insert sp;
      system.debug('sp.id ===>>  '+sp.Id);
      List<Core_IPS_Supported_Product__c> str= [select Name from Core_IPS_Supported_Product__c where Id=: sp.id Limit 1];
      system.debug('str ===>>  '+str);
        for(Integer i=0;i<NumOfRec;i++){
            Core_IPS_Product_Issue_Category__c CoreProdIssCategory = new Core_IPS_Product_Issue_Category__c();
            CoreProdIssCategory.Core_Supported_Product__c = sp.id;
            CoreProdIssCategory.Core_Status__c = 'Active';
            CoreProdIssCategory.Core_Type__c = 'Case Subcategory';
            ListOfCoreProdIssCategory.add(CoreProdIssCategory);
        }
        return ListOfCoreProdIssCategory;
    }
    
     /*****************************************************************************
    Method Info : Get Core Response Records
    ******************************************************************************/
    public static list<Core_IPS_Response__c> getCoreResponseRecords(Integer NumOfRec){
        List<Core_IPS_Response__c> envResponses = new List<Core_IPS_Response__c>();
        for(Integer i=0;i<NumOfRec;i++){
            Core_IPS_Response__c det = new Core_IPS_Response__c();
            det.Core_IPS_Answer__c = 'Test Answer'+i;
            envResponses.add(det);
        }
        return envResponses;
    }
    
    public static void setupCustomSetting(){
        List<Core_IPS_Labels__c> ipsCustSettings = new List<Core_IPS_Labels__c>();
        Core_IPS_Labels__c ipsLabel = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS');
        if(ipsLabel == null){
            ipsLabel = new Core_IPS_Labels__c(Name= 'PUBLIC_TO_CUSTOMERS');
            ipsLabel.Value__c = 'Public to Customers';
            ipsCustSettings.add(ipsLabel);
        }
        ipsLabel = Core_IPS_Labels__c.getValues('PRIVATE_TO_AGENTS');
        if(ipsLabel == null){
            ipsLabel = new Core_IPS_Labels__c(Name= 'PRIVATE_TO_AGENTS');
            ipsLabel.Value__c = 'Private to Agents';
            ipsCustSettings.add(ipsLabel);
        }
        ipsLabel = Core_IPS_Labels__c.getValues('PRIVATE_TO_PARTNERS');
        if(ipsLabel == null){
            ipsLabel = new Core_IPS_Labels__c(Name= 'PRIVATE_TO_PARTNERS');
            ipsLabel.Value__c = 'Private to Partners';
            ipsCustSettings.add(ipsLabel);
        }
        ipsLabel = Core_IPS_Labels__c.getValues('PRIVATE_TO_INTEL');
        if(ipsLabel == null){
            ipsLabel = new Core_IPS_Labels__c(Name= 'PRIVATE_TO_INTEL');
            ipsLabel.Value__c = 'Private to Intel';
            ipsCustSettings.add(ipsLabel);
        }
        ipsLabel = Core_IPS_Labels__c.getValues('Customer');
        if(ipsLabel == null){
            ipsLabel = new Core_IPS_Labels__c(Name= 'Customer');
            ipsLabel.Value__c = 'Customer';
            ipsCustSettings.add(ipsLabel);
        }
        ipsLabel = Core_IPS_Labels__c.getValues('Agent');
        if(ipsLabel == null){
            ipsLabel = new Core_IPS_Labels__c(Name= 'Agent');
            ipsLabel.Value__c = 'Agent';
            ipsCustSettings.add(ipsLabel);
        }
        ipsLabel = Core_IPS_Labels__c.getValues('FAE');
        if(ipsLabel == null){
            ipsLabel = new Core_IPS_Labels__c(Name= 'FAE');
            ipsLabel.Value__c = 'FAE';
            ipsCustSettings.add(ipsLabel);
        }
         ipsLabel = Core_IPS_Labels__c.getValues('Data Migration');
        if(ipsLabel == null){
            ipsLabel = new Core_IPS_Labels__c(Name= 'Data Migration');
            ipsLabel.Value__c = 'Data Migration';
            ipsCustSettings.add(ipsLabel);
        }
         ipsLabel = Core_IPS_Labels__c.getValues('Backend Integration');
        if(ipsLabel == null){
            ipsLabel = new Core_IPS_Labels__c(Name= 'Backend Integration');
            ipsLabel.Value__c = 'Backend Integration';
            ipsCustSettings.add(ipsLabel);
        }
         ipsLabel = Core_IPS_Labels__c.getValues('Partner');
        if(ipsLabel == null){
            ipsLabel = new Core_IPS_Labels__c(Name= 'Partner');
            ipsLabel.Value__c = 'Partner';
            ipsCustSettings.add(ipsLabel);
        }
        ipsLabel = Core_IPS_Labels__c.getValues('Partner - DFAE');
        if(ipsLabel == null){
            ipsLabel = new Core_IPS_Labels__c(Name= 'Partner - DFAE');
            ipsLabel.Value__c = 'Partner - DFAE';
            ipsCustSettings.add(ipsLabel);
        }
        insert ipsCustSettings;
    }
    public static void setUpCustomSettingCaseAttachment(){
        List<Core_Trigger_Executions__c> ipsCustSettings = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c ipsLabel = Core_Trigger_Executions__c.getValues('InsertCaseCommentForAttach');
        if(ipsLabel == null){
            ipsLabel = new Core_Trigger_Executions__c(Name= 'InsertCaseCommentForAttach');
            ipsLabel.Core_Active__c= true;
            ipsLabel.Core_Class_Name__c = 'Test class Name';
            ipsLabel.Core_Description__c = 'Testing Core Description';
            ipsLabel.Core_Object__c = 'Core_IPS_Case_Attachments__c ';
            ipsLabel.Core_Trigger_Events__c = 'After Insert';
            ipsCustSettings.add(ipsLabel);
        }
        insert ipsCustSettings;
    }
    
    /**********************************************************************************
    Method Info : getCoreQuestion Method returns Environmental Detail Master (Core_IPS_Question__c) Record
    **********************************************************************************/
    public static Core_IPS_Question__c getCoreQuestion () {
        Core_IPS_Question__c EnvironmentalDetailMaster = new Core_IPS_Question__c();
        EnvironmentalDetailMaster.Core_IPS_Datatype__c = 'Text';
        EnvironmentalDetailMaster.Core_IPS_Question__c = 'test'; 
        EnvironmentalDetailMaster.Core_IPS_Status__c = 'Active';
        
        return EnvironmentalDetailMaster;
    }
    /**********************************************************************************
    Method Info : getCoreAnswers Method returns Environmental Detail Master (Core_IPS_Answer__c) Record
    **********************************************************************************/
    public static Core_IPS_Answer__c getCoreAnswer () {
        Core_IPS_Answer__c EnvironmentalDetailAnswer = new Core_IPS_Answer__c();
        EnvironmentalDetailAnswer.Core_IPS_Answer__c = 'test Answer'; 
        EnvironmentalDetailAnswer.Core_IPS_Status__c = 'Active';
        
        return EnvironmentalDetailAnswer;
    }
    
    /**********************************************************************************
    Method Info : getlstCoreQuestion Method returns list of Core_IPS_Question__c  Records
    **********************************************************************************/
    public static List<Core_IPS_Question__c> getlstCoreQuestion(Integer count) {
        List<Core_IPS_Question__c> lstCoreQuestion = new List<Core_IPS_Question__c>();
        for(Integer i=1;i<=count;i++) {
            Core_IPS_Question__c objQues = new Core_IPS_Question__c();
            objQues.Core_IPS_Datatype__c = 'Text';
            objQues.Core_IPS_Question__c = 'Question ' + i; 
            objQues.Core_IPS_Status__c = 'Active';
            objQues.Core_IPS_Order_No__c = i; 
            lstCoreQuestion.add(objQues);
        }
        return lstCoreQuestion;
    }
     /**********************************************************************************
    Method Info : getCoreAnswer Method returns Core_IPS_Answer__c Records
    **********************************************************************************/
    public static List<Core_IPS_Answer__c> getlstCoreAnswers(Integer count) {
        List<Core_IPS_Answer__c> lstAnswer = new List<Core_IPS_Answer__c>();
        for(Integer i=1;i<=count;i++) {
            Core_IPS_Answer__c objAnswer = new Core_IPS_Answer__c(
                Core_IPS_Answer__c = 'Ans ' + i,
                Core_IPS_Status__c = 'Active'
            );
            lstAnswer.add(objAnswer);
        }
        return lstAnswer;
    }
}