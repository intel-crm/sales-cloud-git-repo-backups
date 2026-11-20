@isTest
public class Core_IPS_BES_CaseOutbound_Test{
    static List<User> SysAdminUsr = new List<User> ();
    @testSetup static void setupMethod() {
        
        List<IPS_Case_Fields__c> caseFieldsList = new List<IPS_Case_Fields__c>();
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'account_billing_city', API_Name__c ='Account.billingcity',
                                                  Object_Name__c ='Case', Name = 'Account Billing City', Order__c =1010, Additional_Info__c = true));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'account_cim_id', API_Name__c ='Account.Core_CIM_ID__c',
                                                  Object_Name__c ='Case', Name = 'CIM ID', Order__c =1010, Additional_Info__c = true));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'account_id', API_Name__c ='AccountID',
                                                  Object_Name__c ='Case', Name = 'Account ID', Order__c =1011, Additional_Info__c = true));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'question', API_Name__c ='Core_IPS_Question__c',
                                                  Object_Name__c ='Core_IPS_Response__c', Name = 'Question', Order__c =1012, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'Reporting Name', API_Name__c ='Core_IPS_Question_Master__r.Core_IPS_Reporting_Name__c',
                                                  Object_Name__c ='Core_IPS_Response__c', Name = 'Reporting Name', Order__c =1013, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'answer', API_Name__c ='Core_IPS_Answer__c',
                                                  Object_Name__c ='Core_IPS_Response__c', Name = 'Answer', Order__c =1014, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'category', API_Name__c ='Core_External_Issue_Category__c',
                                                  Object_Name__c ='Case', Name = 'Case Category', Order__c =1015, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'subcategory', API_Name__c ='Core_External_Issue_Subcategory__c',
                                                  Object_Name__c ='Case', Name = 'Case Subcategory', Order__c =1016, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'new_backend_system_name', API_Name__c ='Core_IPS_New_Backend_System__r.Name',
                                                  Object_Name__c ='Case', Name = 'New Backend System Name', Order__c =1017, Additional_Info__c = false));
         caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'description', API_Name__c ='Core_Issue_Description__c',
                                                  Object_Name__c ='Case', Name = 'Case Description', Order__c =160, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'case_closure', API_Name__c ='Core_Case_Closure__c',
                                                  Object_Name__c ='Case', Name = 'Case Closure', Order__c =410, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'ext_source_url', API_Name__c ='Core_IPS_Case_URL__c',
                                                  Object_Name__c ='Case', Name = 'case url', Order__c =50, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'status', API_Name__c ='Status',
                                                  Object_Name__c ='Case', Name = 'Status', Order__c =1020, Additional_Info__c = false));
		caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'sub_status', API_Name__c ='Core_Sub_Status__c',
                                                  Object_Name__c ='Case', Name = 'Sub Status', Order__c =1030, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'severity_reason', API_Name__c ='Core_Severity_Reason__c',
                                                  Object_Name__c ='Case', Name = 'Severity Reason', Order__c =1051, Additional_Info__c = true));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'environment_details', API_Name__c ='Core_Environment_Details__c',
                                                  Object_Name__c ='Case', Name = 'environment_details', Order__c =1052, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'contact_name', API_Name__c ='Core_Contact_Name__c',
                                                  Object_Name__c ='Case', Name = 'Contact Name', Order__c =1052, Additional_Info__c = true));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'contact_first_name', API_Name__c ='Contact.FirstName',
                                                  Object_Name__c ='Case', Name = 'Contact First Name', Order__c =1052, Additional_Info__c = true));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'contact_last_name', API_Name__c ='Contact.LastName',
                                                  Object_Name__c ='Case', Name = 'Contact Last Name', Order__c =1052, Additional_Info__c = true));
        
        insert caseFieldsList;
        
        List<Core_IPS_BES_AllTenants_CustomMapping__c> allTenentMapping = new List<Core_IPS_BES_AllTenants_CustomMapping__c>();
        allTenentMapping.add(new Core_IPS_BES_AllTenants_CustomMapping__c(Name = 'BES - 00001', Backend_System_Name__c = 'CC - HSDES Client Platform', Field_API_Name__c = 'Core_External_Issue_Category__c',
                                                                          Source_Value__c = 'NOVA', Target_Value__c = 'ccg_cce_nova', Json_Key__c= 'submitter_org', Direction__c= 'Outbound'));
        allTenentMapping.add(new Core_IPS_BES_AllTenants_CustomMapping__c(Name = 'BES - 00002', Backend_System_Name__c = 'CC - HSDES Client Platform', Field_API_Name__c = 'Core_External_Issue_Subcategory__c',
                                                                          Source_Value__c = 'Graphics', Target_Value__c = 'ccg_cce_gse', Json_Key__c= 'submitter_org', Direction__c= 'Outbound'));
        allTenentMapping.add(new Core_IPS_BES_AllTenants_CustomMapping__c(Name = 'BES - 00003', Backend_System_Name__c = 'EMBED - HSDES IoT Platform', Field_API_Name__c = 'Status',
                                                                          Source_Value__c = 'Closed', Target_Value__c = 'complete', Json_Key__c= 'status', Direction__c= 'Outbound'));
        allTenentMapping.add(new Core_IPS_BES_AllTenants_CustomMapping__c(Name = 'BES - 00004', Backend_System_Name__c = 'EMBED - HSDES IoT Platform', Field_API_Name__c = 'Core_Sub_Status__c',
                                                                          Source_Value__c = 'Close-Pending', Target_Value__c = 'open.awaiting_customer', Json_Key__c= 'sub_status', Direction__c= 'Outbound'));
        allTenentMapping.add(new Core_IPS_BES_AllTenants_CustomMapping__c(Name = 'BES - 00005', Backend_System_Name__c = 'EMBED - HSDES IoT Platform', Field_API_Name__c = 'Core_External_Issue_Category__c',
                                                                          Source_Value__c = 'Firmware/BIOS', Target_Value__c = 'firmware', Json_Key__c= 'source_type', Direction__c= 'Outbound'));
        allTenentMapping.add(new Core_IPS_BES_AllTenants_CustomMapping__c(Name = 'BES - 00006', Backend_System_Name__c = 'EMBED - HSDES IoT Platform', Field_API_Name__c = 'Core_External_Issue_Category__c',
                                                                          Source_Value__c = 'Ethernet Wired LAN.Driver', Target_Value__c = 'software', Json_Key__c= 'source_type', Direction__c= 'Outbound'));

        
        insert allTenentMapping;
        
        List<Core_IPS_BES_CaseTypeMapping__c> allArticleMapping = new List<Core_IPS_BES_CaseTypeMapping__c>();
        allArticleMapping.add(new Core_IPS_BES_CaseTypeMapping__c(Name = 'BESCT - 0000001', Backend_System_Name__c	 = 'DCG - HSDES Server Platforms1', IPS_Case_Type__c = 'Design Review',
                                                                          HSD_Article_Type__c = 'design_services', Default_Status_Reason__c = 'open.assigned'));
        allArticleMapping.add(new Core_IPS_BES_CaseTypeMapping__c(Name = 'BESCT - 0000002', Backend_System_Name__c	 = 'DCG - HSDES Server Platforms1', IPS_Case_Type__c = 'Debug Request',
                                                                          HSD_Article_Type__c = 'debug_request', Default_Status_Reason__c = 'open.triage'));
        allArticleMapping.add(new Core_IPS_BES_CaseTypeMapping__c(Name = 'BESCT - 0000003', Backend_System_Name__c	 = 'DCG - HSDES Server Platforms1', IPS_Case_Type__c = 'Question',
                                                                          HSD_Article_Type__c = 'question', Default_Status_Reason__c = 'open.assigned'));
        insert allArticleMapping;

        list<Core_IPS_Labels__c> lstCs = new list<Core_IPS_Labels__c>();
        lstCs.add(new Core_IPS_Labels__c(name='Comment Source - Customer', value__c='Customer Portal'));
        lstCs.add(new Core_IPS_Labels__c(name='Comment Source - Internal', value__c='Internal Portal'));
        lstCs.add(new Core_IPS_Labels__c(name='Comment Source - B2B API', value__c='B2B API'));
        lstCs.add(new Core_IPS_Labels__c(name='Partner - Agent', value__c='Partner - Agent'));
        lstCs.add(new Core_IPS_Labels__c(Name = 'IPS Standard Entitlement', Value__c='IPS Standard Entitlement'));
        lstCs.add(new Core_IPS_Labels__c(Name = 'PRIVATE_TO_INTEL', Value__c = 'Private to Intel'));
        lstCs.add(new Core_IPS_Labels__c(Name = 'Agent', Value__c = 'Agent'));
        lstCs.add(new Core_IPS_Labels__c(Name = 'PUBLIC_TO_CUSTOMERS', Value__c = 'Public to Customers'));
        lstCs.add(new Core_IPS_Labels__c(Name = 'Customer', Value__c = 'Customer'));
        lstCs.add(new Core_IPS_Labels__c(name = 'Partner', value__c = 'Partner'));
        lstCs.add(new Core_IPS_Labels__c (name='FAE', value__c='FAE'));
        lstCs.add(new Core_IPS_Labels__c(name='Backend Integration', value__c='Backend Integration'));
        lstCs.add(new Core_IPS_Labels__c(name= 'Partner - DFAE', value__c= 'Partner - DFAE'));
        lstCs.add(new Core_IPS_Labels__c(name= 'Comment Source - Backend System', value__c='Backend System'));
        lstCs.add(new Core_IPS_Labels__c(name= 'Comment Source - Data Migration', value__c='Data Migration'));
        lstCs.add(new Core_IPS_Labels__c(name= 'Comment Source - Email', value__c='Email')); 
        lstCs.add(new Core_IPS_Labels__c(name= 'Comment Source - N/A', value__c='N/A'));
        lstCs.add(new Core_IPS_Labels__c(name= 'Data Migration', value__c='Data Migration'));
        lstCs.add(new Core_IPS_Labels__c(name= 'PRIVATE_TO_AGENTS', value__c='PRIVATE_TO_AGENTS'));
        lstCs.add(new Core_IPS_Labels__c(name= 'PRIVATE_TO_PARTNERS', value__c='PRIVATE_TO_PARTNERS'));
        lstCs.add(new Core_IPS_Labels__c(name= 'Core_IPS_additional_information', value__c='additional_information'));
        insert lstCs;
        List<Core_Trigger_Executions__c> excecutionsList = new List<Core_Trigger_Executions__c>();
        excecutionsList.add(new Core_Trigger_Executions__c(Name='myIntelIntegration',Core_Active__c =false,Core_Class_Name__c='test clas',
                                                          Core_Description__c = 'Obj', Core_Object__c = 'Case',Core_Trigger_Events__c='Update'));
        insert excecutionsList;

        
        List<string> profileNames = new List<string> {'System Administrator'};
        List<Account> accounts = new List<Account> ();
        List<User> internalSfUsers = new List<User> ();
        
        List<Core_IPS_Supported_Product__c> supportedProducts = new List<Core_IPS_Supported_Product__c>();
        List<Core_IPS_Project__c> ipsProjects = new List<Core_IPS_Project__c> ();
        Core_IPS_Project__c projectcase=new Core_IPS_Project__c();
        Core_IPS_Product_Issue_Category__c subCategory = new Core_IPS_Product_Issue_Category__c();
        Core_IPS_Product_Issue_Category__c caseCat = new Core_IPS_Product_Issue_Category__c();
       
          Map<String,ID> profilesByName = new Map<String,ID>();
        for(Profile prof : [select id, name from Profile where name IN: profileNames]){
            profilesByName.put(prof.name, prof.id);
        }
        SysAdminUsr = [SELECT Id FROM User WHERE Profile.Name = :System.Label.Core_System_Admin_Profile_Name AND IsActive = true LIMIT 1];
       
         UserRole role = new UserRole();
        role.name='CEO';
        
        System.RunAs(SysAdminUsr[0]){
            insert role;
        }
        internalSfUsers = TestUtilities.getListOfUser(1);
        internalSfUsers.get(0).ProfileID =  profilesByName.get('System Administrator');
        internalSfUsers.get(0).userroleid = role.id;
        // Creating SETUP OBJECT (USER) RECORD
        System.RunAs(SysAdminUsr[0]){
            insert internalSfUsers;
        }  
         Group testGroup = new Group(Name='IPS - Unassigned Cases', Type='Queue');
        insert testGroup;
        List<GroupMember> groupMembers = new List<GroupMember>(); 
         System.runAs(SysAdminUsr[0])
        {
            //Associating queue with group AND to the Case object
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
            GroupMember groupMember = new GroupMember();
            groupMember.GroupId = testGroup.Id;
            groupMember.UserOrGroupId =internalSfUsers[0].Id;
            groupMembers.add(groupMember);
            insert groupMembers;
        }
        Core_IPS_Labels__c ipsLabel = new Core_IPS_Labels__c(Name='CloseCaseEditPermission',Value__c='System Administrator');
        insert ipsLabel;
        Account accountRecord1 = TestUtilities.getAccount();
        accountRecord1.Core_IPS_Active__c = true;
        accountRecord1.ownerid = internalSfUsers.get(0).id;
        accountRecord1.Core_Military_Aerospace_and_Government__c = true;
        accounts.add(accountRecord1);
        insert accounts;
        List<Core_IPS_Labels__c>  labels = TestUtilities.getIPSLabel();
        insert labels;
        System.assert(accounts[0].Id != null, 'Account Record not created');
        
         List<Contact> contacts = TestUtilities.getListOfContact(1);
        contacts.get(0).Accountid = accounts.get(0).Id;
        contacts.get(0).Core_IPS_Intel_Support_Owner__c = internalSfUsers.get(0).id;
        contacts.get(0).ownerid = internalSfUsers.get(0).id;
        contacts.get(0).Core_IPS_Active__c =TRUE;
    	contacts.get(0).MailingCountry = 'India';
        insert contacts;

        List<Core_IPS_Product_Organization__c> supportOrganizations  = TestUtilities.getListOfSupportOrg(1);
        
        insert supportOrganizations;
        
        List<Product2> products = TestUtilities.getListOfProduct(1);
        insert products;
        
        supportedProducts = TestUtilities.getListOfSupportedProduct(1);
        supportedProducts.get(0).Core_Product__c = products.get(0).id;
        supportedProducts.get(0).Core_Product_Organization__c = supportOrganizations.get(0).id;
        insert supportedProducts;
        
        System.assert(supportedProducts[0].id != null,'Supported product Record not created');
        // Create Design Project Record
        ipsProjects = TestUtilities.getListOfIpsProjects(1);
        insert ipsProjects;
        System.assert(ipsProjects.get(0).Id != null, 'Design Project Record not created');
        // Create IPS Product Record
        List<Core_IPS_Product__c> ipsProducts = TestUtilities.getListOfIpsProducts(1);
        ipsProducts.get(0).Core_IPS_Project__c = ipsProjects.get(0).id;
        ipsProducts.get(0).Core_Supported_Product__c = supportedProducts.get(0).id;
        ipsProducts.get(0).Status__c = 'Submitted';
        insert ipsProducts;
        
        
        Core_IPS_Master_Issue_Category__c masterCaseCategory = TestUtilities.getMasterCaseCategories();
        masterCaseCategory.Core_type__c = 'Case Category';
        insert masterCaseCategory;
        
        Core_IPS_Master_Issue_Category__c masterCategory = TestUtilities.getMasterCaseCategories();
        masterCategory.Core_Master_Issue_Category__c = masterCaseCategory.id;            
        insert masterCategory;
        
         caseCat = TestUtilities.getCaseCategories();
        caseCat.Core_Issue_Category_Name__c = masterCategory.id;
        caseCat.Core_Type__c = 'Case Category';
        insert caseCat;
        
        subCategory = TestUtilities.getCaseCategories();
        subCategory.Core_Issue_Sub_Category_Name__c = masterCategory.id;
        subCategory.Core_Type__c = 'Case Subcategory';
        insert subCategory; 
        List<Core_IPS_Project__c> projList=new List<Core_IPS_Project__c>();
       
        projectcase=ipsProjects[0];
    }
    
    public static TestMethod void backendPromotionTest(){
        
        Core_Trigger_Executions__c triggerExecution = new Core_Trigger_Executions__c(Name= 'enableIPSCaseBackendRouting', Core_Active__c = true,
                                                                                     Core_Class_Name__c = 'Core_IPS_BES_CasePromotion_Handler', Core_Object__c = 'Case',
                                                                                    Core_Trigger_Events__c = 'Core_Trigger_Events__c', Core_Description__c = 'test desc');
        insert triggerExecution;
        List<Core_IPS_Supported_Product__c> supportedProduct = [SELECT Id from Core_IPS_Supported_Product__c LIMIT 999];
        Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
        backendSystem.Name = 'CC - HSDES Client Platform';

        backendSystem.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
        insert backendSystem;
        
        Core_IPS_Backend_System2__c backendSystem1 = new Core_IPS_Backend_System2__c();
        backendSystem1.Name = 'DCG - HSDES Server Platforms';

        backendSystem1.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
        insert backendSystem1;
        
        Core_IPS_Backend_Routing__c backendRoutingRule = new Core_IPS_Backend_Routing__c();
        backendRoutingRule.Core_IPS_Backend_Routing_Order__c = 1;
        backendRoutingRule.Core_IPS_Queue__c = 'IPS - Unassigned Cases';
        backendRoutingRule.Core_IPS_Routing_Casetype__c = 'Issue';
        backendRoutingRule.Core_IPS_Auto_Promote__c = true;
        backendRoutingRule.Core_IPS_New_Backend_System__c = backendSystem.Id;
        insert backendRoutingRule;
        
        List<Account> accounts = [SELECT Id from Account LIMIT 999];
         List<Contact> contacts = [SELECT Id from Contact LIMIT 999];
		  List<Core_IPS_Product_Organization__c> supportOrganizations = [SELECT Id from Core_IPS_Product_Organization__c LIMIT 999];
        List<Core_IPS_Product_Issue_Category__c> caseCat = [SELECT Id from Core_IPS_Product_Issue_Category__c LIMIT 999];
        List<Core_IPS_Product_Issue_Category__c> subCategory = [SELECT Id from Core_IPS_Product_Issue_Category__c LIMIT 999];
        
         List<Core_IPS_Question__c> lstCoreQuestion = TestUtilities.getlstCoreQuestion(9);    
        for(Core_IPS_Question__c objQues : lstCoreQuestion) {
            objQues.Core_IPS_Product_Organization__c = supportOrganizations.get(0).id;
        }
        lstCoreQuestion[1].Core_IPS_Datatype__c = 'Text Area';
        lstCoreQuestion[6].Core_IPS_Datatype__c = 'Text Area';
        lstCoreQuestion[2].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[4].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[7].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[3].Core_IPS_Datatype__c = 'Multiselect Picklist';
        lstCoreQuestion[8].Core_IPS_Datatype__c = 'Multiselect Picklist';
        lstCoreQuestion[1].Core_IPS_Reporting_Name__c = 'test112';
        lstCoreQuestion[2].Core_IPS_Reporting_Name__c = 'test112oo';
        
        
        insert lstCoreQuestion;
        System.assert(lstCoreQuestion[0].Id != null, 'Record not created');
        
        lstCoreQuestion[4].Core_IPS_Parent_Question__c = lstCoreQuestion[2].Id;
        update lstCoreQuestion[4];
        
        List<Core_IPS_Answer__c> lstAnswer = new List<Core_IPS_Answer__c>();
        Map<Id,List<Core_IPS_Answer__c>> mapQuesId2Ans = new Map<Id,List<Core_IPS_Answer__c>>();
        for(Core_IPS_Question__c objQues : lstCoreQuestion) {
            mapQuesId2Ans.put(objQues.Id,new List<Core_IPS_Answer__c>());
            for(Core_IPS_Answer__c objAns : TestUtilities.getCoreAnswers(2)) {
                objAns.Core_IPS_Question__c = objQues.Id;
                lstAnswer.add(objAns);
                mapQuesId2Ans.get(objQues.Id).add(objAns);
            }               
        }
               
        insert lstAnswer;
             Core_IPS_BES_Questions__c getBESQuestions = new Core_IPS_BES_Questions__c();
             getBESQuestions.Name ='Ques-00010075';
             getBESQuestions.Backend_System_Name__c= 'DCG - HSDES Server Platforms';
             getBESQuestions.Environmental_Detail_Question__c ='DefaultedValue';
            insert getBESQuestions;
        Map<string,string> quesAnsMap= new Map<string,string>();
        	quesAnsMap.put('DefaultedValue','Ans 1');
         Core_IPS_Project__c projectcase=new Core_IPS_Project__c();
        Case caseRecord = new Case();
        Case firstCaseRecord = new Case();
        Case selfAssignedCaseRecord = new Case();
        Case secondCaseRecord = new Case();
        caseRecord.AccountId=accounts.get(0).Id;
        caseRecord.ContactId=contacts.get(0).id;  
        caseRecord.Core_IPS_Product_Org1__c=supportOrganizations.get(0).id;
        caseRecord.Core_Case_Issue_Category__c = caseCat[0].id;
        caseRecord.Core_case_issue_sub_category__c = subCategory[0].id;
        caseRecord.Core_Issue_Description__c = 'test'; 
        caseRecord.Core_External_Issue_Category__c = 'Nova';
        caseRecord.Core_External_Issue_Subcategory__c = 'XMM7560';
        caseRecord.Subject='TestSubject';
        caseRecord.Core_CaseType__c='Issue';
        caseRecord.Core_IPS_Issue_source__c='n/a';
        caseRecord.core_ips_project_case__c=projectcase.id;
        //CaseRecord.Core_IPS_Backend_System__r.Name= backendSystem.Name;
        RecordType caseRecordType = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        caseRecord.recordTypeId = caseRecordType.Id;
        caseRecord.Core_IPS_EDQ_Filtering_Question__c ='bkc_or_sw_version';
        caseRecord.Core_IPS_Partner_Sup_Owner__c = userinfo.getuserid();
        RecordType selfAssignedCaseRecordType = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'Core_IPS_Case_Create_Self_Assigned'];
        selfAssignedCaseRecord = caseRecord.clone(false,true);
        selfAssignedCaseRecord.RecordTypeId = selfAssignedCaseRecordType.Id;
        selfAssignedCaseRecord.Core_IPS_New_Backend_System__c =backendSystem1.Id;
        selfAssignedCaseRecord.Status = 'Open';
        selfAssignedCaseRecord.Core_Sub_Status__c = 'Investigating';
        selfAssignedCaseRecord.HSD_Mirror_Status__c = 'open';
        selfAssignedCaseRecord.HSD_Mirror_Reason__c = 'new';
        selfAssignedCaseRecord.Core_Environment_Details__c ='DefaultedValue';
        secondCaseRecord.AccountId=accounts.get(0).Id;
        secondCaseRecord.ContactId=contacts.get(0).id;  
        secondCaseRecord.Core_IPS_Product_Org1__c=supportOrganizations.get(0).id;
        secondCaseRecord.Core_Case_Issue_Category__c = caseCat[0].id;
        secondCaseRecord.Core_case_issue_sub_category__c = subCategory[0].id;
        secondCaseRecord.Core_Issue_Description__c = 'test'; 
        secondCaseRecord.Core_External_Issue_Category__c = 'Nova';
        secondCaseRecord.Core_External_Issue_Subcategory__c = 'XMM7560';
        secondCaseRecord.Subject='TestSubject';
        secondCaseRecord.Core_CaseType__c='Issue';
        secondCaseRecord.Core_IPS_Issue_source__c='n/a';
        secondCaseRecord.core_ips_project_case__c=projectcase.id;
        //CaseRecord.Core_IPS_Backend_System__r.Name= backendSystem.Name;
        RecordType caseCreateRecordType = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        secondCaseRecord.recordTypeId = caseCreateRecordType.Id;
        secondCaseRecord.Core_IPS_BackendID__c = 'a1nDU000002e4LfYAI';
        secondCaseRecord.Core_IPS_EDQ_Filtering_Question__c ='bkc_or_sw_version';
        secondCaseRecord.Core_IPS_Partner_Sup_Owner__c = userinfo.getuserid();
        secondCaseRecord.Core_IPS_New_Backend_System__c =backendSystem1.Id;
        List<Case> caseList = new List<Case>();
        caseList.add(caseRecord);
        caseList.add(selfAssignedCaseRecord);
        //caseList.add(CaseRecord2);
        Test.startTest();
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            caseRecord.setOptions(dmo);
        	selfAssignedCaseRecord.setOptions(dmo);
        	secondCaseRecord.setOptions(dmo);
            insert caseList; //CaseRecord;
        	insert secondCaseRecord;
        List<Case> updateCaseRecs = new List<Case>();
        List<Case> caseRecords =[select id,Contact.Id,Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c,Core_IPS_BackendID__c, Core_IPS_BES_Promote_Status__c,Core_IPS_New_Backend_System__c from case where Id IN:caseList];
        for(Case caseRec:caseRecords){
            caseRec.Core_Case_Closure__c ='Customer>Duplicate';
            caseRec.Contact.Id = contacts[0].id;
            updateCaseRecs.add(caseRec);
        }
        update updateCaseRecs;
        
        selfAssignedCaseRecord.HSD_Mirror_Reason__c = 'awaiting_customer';
        update caseList;
       
            insertCoreResponse(caseList[0].Id);
        insertCoreResponse(secondCaseRecord.Id);
            List<Core_IPS_BES_Outbound_Message__c> outboundObject = new List<Core_IPS_BES_Outbound_Message__c>();
            outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
        	outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
        	outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
        	outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
            insert outboundObject;
           
            
        if(outboundObject!=null && outboundObject.size()>0){
            outboundObject[0].core_IPS_Outbound_Message_ID__c = '123';
            outboundObject[0].Core_IPS_Case_ID__c = caseList[0].Id; 
            outboundObject[0].Status__c = 'Apigee Success';
            outboundObject[1].core_IPS_Outbound_Message_ID__c = '1234';
            outboundObject[1].Core_IPS_Case_ID__c = caseList[1].Id; 
            outboundObject[1].Status__c = 'Apigee Success';
            outboundObject[2].core_IPS_Outbound_Message_ID__c = '123';
            outboundObject[2].Core_IPS_Case_ID__c = secondCaseRecord.Id; 
            outboundObject[2].Status__c = 'Apigee Success';
            outboundObject[2].Comment_Id__c = 'a1nDU000002e4LfYAI';
            outboundObject[3].core_IPS_Outbound_Message_ID__c = '1234';
            outboundObject[3].Core_IPS_Case_ID__c = secondCaseRecord.Id; 
            outboundObject[3].Status__c = 'Apigee Success';
            outboundObject[3].Comment_Id__c = 'a1nDU000002e4LfYAI';
            update outboundObject;
                Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[0].Id,outboundObject[1].Id});
           // Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[2].Id,outboundObject[3].Id});
            outboundObject[0].Status__c = 'Apigee Failed';
            outboundObject[1].Status__c = 'Apigee Failed';
            update outboundObject;
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[0].Id,outboundObject[1].Id});
            outboundObject[0].Status__c = 'IPS Failed';
            outboundObject[1].Status__c = 'IPS Failed';
            update outboundObject;
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[0].Id,outboundObject[1].Id});
            outboundObject[0].Status__c = 'IPass Failed';
            outboundObject[1].Status__c = 'IPass Failed';
            update outboundObject;
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[0].Id,outboundObject[1].Id});
            outboundObject[2].Status__c = 'Apigee Failed';
            outboundObject[3].Status__c = 'Apigee Failed';
            update outboundObject;
            
        }
        
        
        
        CaseHistory ch = new CaseHistory();
        ch.CaseId = caseList[1].Id;
        ch.Field = 'Core_Sub_Status__c';
        
        insert ch;
        //Core_IPS_BES_HSD_CustomLogic chL= new Core_IPS_BES_HSD_CustomLogic();
        Core_IPS_BES_HSD_CustomLogic.processDCGStatusReasonLogic(caseList[1].Id,new Map<String,CaseHistory>{caseList[1].Id+'Core_Sub_Status__c' => ch});
        //{'caseList[1].Id+\'Core_Sub_Status__c\'' => ch};
        
        Case c = new Case();
        c.Id = caseList[1].Id;
        c.Subject = 'Test Subject';
        c.Status = 'Open';
        c.Core_Sub_Status__c = 'Investigating';
        update c;
	
	List<Core_IPS_BES_Outbound_Message__c> outboundObjectRec = new List<Core_IPS_BES_Outbound_Message__c>();
            outboundObjectRec.add(new Core_IPS_BES_Outbound_Message__c());
        	insert outboundObjectRec;
        if(outboundObjectRec!=null && outboundObjectRec.size()>0){
            outboundObjectRec[0].core_IPS_Outbound_Message_ID__c = '12312';
            outboundObjectRec[0].Core_IPS_Case_ID__c = c.Id; 
            outboundObjectRec[0].Status__c = 'Apigee Success';
            update outboundObjectRec;
           
               // Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObjectRec[0].Id});   //commented by Tushar
        }
        
        Test.stopTest();
        //insert CaseRecordSA;
        //insert CaseRecord1;
      
    }
    //added by Rajashekar
	public static TestMethod void backendPromotionTest1(){
        
        Core_Trigger_Executions__c triggerExecution = new Core_Trigger_Executions__c(Name= 'enableIPSCaseBackendRouting', Core_Active__c = true,
                                                                                     Core_Class_Name__c = 'Core_IPS_BES_CasePromotion_Handler', Core_Object__c = 'Case',
                                                                                    Core_Trigger_Events__c = 'Core_Trigger_Events__c', Core_Description__c = 'test desc');
        insert triggerExecution;
        List<Core_IPS_Supported_Product__c> supportedProduct = [SELECT Id from Core_IPS_Supported_Product__c LIMIT 999];
        Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
        backendSystem.Name = 'CC - HSDES Client Platform';

        backendSystem.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
        insert backendSystem;
        
        Core_IPS_Backend_System2__c backendSystem1 = new Core_IPS_Backend_System2__c();
        backendSystem1.Name = 'DCG - HSDES Server Platforms';

        backendSystem1.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
        insert backendSystem1;
        
        Core_IPS_Backend_Routing__c backendRoutingRule = new Core_IPS_Backend_Routing__c();
        backendRoutingRule.Core_IPS_Backend_Routing_Order__c = 1;
        backendRoutingRule.Core_IPS_Queue__c = 'IPS - Unassigned Cases';
        backendRoutingRule.Core_IPS_Routing_Casetype__c = 'Issue';
        backendRoutingRule.Core_IPS_Auto_Promote__c = true;
        backendRoutingRule.Core_IPS_New_Backend_System__c = backendSystem.Id;
        insert backendRoutingRule;
        
        List<Account> accounts = [SELECT Id from Account LIMIT 999];
         List<Contact> contacts = [SELECT Id from Contact LIMIT 999];
        List<Core_IPS_Product_Organization__c> supportOrganizations = [SELECT Id from Core_IPS_Product_Organization__c LIMIT 999];
        List<Core_IPS_Product_Issue_Category__c> caseCat = [SELECT Id from Core_IPS_Product_Issue_Category__c LIMIT 999];
        List<Core_IPS_Product_Issue_Category__c> subCategory = [SELECT Id from Core_IPS_Product_Issue_Category__c LIMIT 999];
        
         List<Core_IPS_Question__c> lstCoreQuestion = TestUtilities.getlstCoreQuestion(9);    
        for(Core_IPS_Question__c objQues : lstCoreQuestion) {
            objQues.Core_IPS_Product_Organization__c = supportOrganizations.get(0).id;
        }
        lstCoreQuestion[1].Core_IPS_Datatype__c = 'Text Area';
        lstCoreQuestion[6].Core_IPS_Datatype__c = 'Text Area';
        lstCoreQuestion[2].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[4].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[7].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[3].Core_IPS_Datatype__c = 'Multiselect Picklist';
        lstCoreQuestion[8].Core_IPS_Datatype__c = 'Multiselect Picklist';
        lstCoreQuestion[1].Core_IPS_Reporting_Name__c = 'test112';
        lstCoreQuestion[2].Core_IPS_Reporting_Name__c = 'test112oo';
        
        
        insert lstCoreQuestion;
        System.assert(lstCoreQuestion[0].Id != null, 'Record not created');
        
        lstCoreQuestion[4].Core_IPS_Parent_Question__c = lstCoreQuestion[2].Id;
        update lstCoreQuestion[4];
        
        List<Core_IPS_Answer__c> lstAnswer = new List<Core_IPS_Answer__c>();
        Map<Id,List<Core_IPS_Answer__c>> mapQuesId2Ans = new Map<Id,List<Core_IPS_Answer__c>>();
        for(Core_IPS_Question__c objQues : lstCoreQuestion) {
            mapQuesId2Ans.put(objQues.Id,new List<Core_IPS_Answer__c>());
            for(Core_IPS_Answer__c objAns : TestUtilities.getCoreAnswers(2)) {
                objAns.Core_IPS_Question__c = objQues.Id;
                lstAnswer.add(objAns);
                mapQuesId2Ans.get(objQues.Id).add(objAns);
            }               
        }
               
        insert lstAnswer;
             Core_IPS_BES_Questions__c getBESQuestions = new Core_IPS_BES_Questions__c();
             getBESQuestions.Name ='Ques-00010075';
             getBESQuestions.Backend_System_Name__c= 'DCG - HSDES Server Platforms';
             getBESQuestions.Environmental_Detail_Question__c ='DefaultedValue';
            insert getBESQuestions;
        Map<string,string> quesAnsMap= new Map<string,string>();
        	quesAnsMap.put('DefaultedValue','Ans 1');
         Core_IPS_Project__c projectcase=new Core_IPS_Project__c();
        Case secondCaseRecord = new Case();
        secondCaseRecord.AccountId=accounts.get(0).Id;
        secondCaseRecord.ContactId=contacts.get(0).id;  
        secondCaseRecord.Core_IPS_Product_Org1__c=supportOrganizations.get(0).id;
        secondCaseRecord.Core_Case_Issue_Category__c = caseCat[0].id;
        secondCaseRecord.Core_case_issue_sub_category__c = subCategory[0].id;
        secondCaseRecord.Core_Issue_Description__c = 'test'; 
        secondCaseRecord.Core_External_Issue_Category__c = 'Nova';
        secondCaseRecord.Core_External_Issue_Subcategory__c = 'XMM7560';
        secondCaseRecord.Subject='TestSubject';
        secondCaseRecord.Core_CaseType__c='Issue';
        secondCaseRecord.Core_IPS_Issue_source__c='n/a';
        secondCaseRecord.core_ips_project_case__c=projectcase.id;
        //CaseRecord.Core_IPS_Backend_System__r.Name= backendSystem.Name;
        RecordType caseCreateRecordType = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        secondCaseRecord.recordTypeId = caseCreateRecordType.Id;
        secondCaseRecord.Core_IPS_BackendID__c = 'a1nDU000002e4LfYAI';
        secondCaseRecord.Core_IPS_EDQ_Filtering_Question__c ='bkc_or_sw_version';
        secondCaseRecord.Core_IPS_Partner_Sup_Owner__c = userinfo.getuserid();
        secondCaseRecord.Core_IPS_New_Backend_System__c =backendSystem1.Id;
        List<Case> caseList = new List<Case>();
        //caseList.add(CaseRecord2);
        Test.startTest();
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
        	secondCaseRecord.setOptions(dmo);
            insert caseList; //CaseRecord;
        	insert secondCaseRecord;
        List<Case> updateCaseRecs = new List<Case>();
        insertCoreResponse(secondCaseRecord.Id);
            List<Core_IPS_BES_Outbound_Message__c> outboundObject = new List<Core_IPS_BES_Outbound_Message__c>();
            outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
        	outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
        	outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
        	outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
            insert outboundObject;
           
            
        if(outboundObject!=null && outboundObject.size()>0){
            outboundObject[2].core_IPS_Outbound_Message_ID__c = '123';
            outboundObject[2].Core_IPS_Case_ID__c = secondCaseRecord.Id; 
            outboundObject[2].Status__c = 'Apigee Success';
            outboundObject[2].Comment_Id__c = 'a1nDU000002e4LfYAI';
            outboundObject[3].core_IPS_Outbound_Message_ID__c = '1234';
            outboundObject[3].Core_IPS_Case_ID__c = secondCaseRecord.Id; 
            outboundObject[3].Status__c = 'Apigee Success';
            outboundObject[3].Comment_Id__c = 'a1nDU000002e4LfYAI';
            update outboundObject;
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[2].Id,outboundObject[3].Id});
            outboundObject[2].Status__c = 'Apigee Failed';
            outboundObject[3].Status__c = 'Apigee Failed';
            update outboundObject;
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[2].Id,outboundObject[3].Id});
            outboundObject[2].Status__c = 'IPass Failed';
            outboundObject[3].Status__c = 'IPass Failed';
            update outboundObject;
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[2].Id,outboundObject[3].Id});
            outboundObject[2].Status__c = 'IPass Success';
            outboundObject[3].Status__c = 'IPass Success';
            update outboundObject;
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[2].Id,outboundObject[3].Id});
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[2].Id,outboundObject[3].Id});
            outboundObject[2].Status__c = 'IPS Failed';
            outboundObject[3].Status__c = 'IPS Failed';
            update outboundObject;
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[2].Id,outboundObject[3].Id});
            
            
        }
        //caseList[0].Subject='TestSubject';
        //caseList[1].Status = 'Open';
        //caseList[1].Core_Sub_Status__c = 'Investigating';
        
        //update caseList; 
        
        
        
        CaseHistory ch = new CaseHistory();
        ch.CaseId = secondCaseRecord.Id;
        ch.Field = 'Core_Sub_Status__c';
        
        insert ch;
        //Core_IPS_BES_HSD_CustomLogic chL= new Core_IPS_BES_HSD_CustomLogic();
        Core_IPS_BES_HSD_CustomLogic.processDCGStatusReasonLogic(secondCaseRecord.Id,new Map<String,CaseHistory>{secondCaseRecord.Id+'Core_Sub_Status__c' => ch});
        //{'caseList[1].Id+\'Core_Sub_Status__c\'' => ch};
        
        Case c = new Case();
        c.Id = secondCaseRecord.Id;
        c.Subject = 'Test Subject';
        c.Status = 'Open';
        c.Core_Sub_Status__c = 'Investigating';
        update c;
	
	    List<Core_IPS_BES_Outbound_Message__c> outboundObjectRec = new List<Core_IPS_BES_Outbound_Message__c>();
            outboundObjectRec.add(new Core_IPS_BES_Outbound_Message__c());
        	insert outboundObjectRec;
        if(outboundObjectRec!=null && outboundObjectRec.size()>0){
            outboundObjectRec[0].core_IPS_Outbound_Message_ID__c = '12312';
            outboundObjectRec[0].Core_IPS_Case_ID__c = c.Id; 
            outboundObjectRec[0].Status__c = 'Apigee Success';
            update outboundObjectRec;
           
                Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObjectRec[0].Id});
        }
        
        Test.stopTest();
        //insert CaseRecordSA;
        //insert CaseRecord1;
      
    }
    //added by Rajashekar
    public static TestMethod void backendPromotionTest2(){
         Map<String,ID> profilesByName = new Map<String,ID>();
        List<string> profileNames = new List<string> {'System Administrator'};
        for(Profile prof : [select id, name from Profile where name IN: profileNames]){
            profilesByName.put(prof.name, prof.id);
        }
        SysAdminUsr = TestUtilities.getListOfUser(1);
         SysAdminUsr.get(0).UserName = 'SysAdminUsr'+SysAdminUsr.get(0).UserName;
        SysAdminUsr.get(0).ProfileID =  profilesByName.get('System Administrator');
       //System.RunAs(SysAdminUsr[0]){ 
        Core_Trigger_Executions__c triggerExecution = new Core_Trigger_Executions__c(Name= 'enableIPSCaseBackendRouting', Core_Active__c = true,
                                                                                     Core_Class_Name__c = 'Core_IPS_BES_CasePromotion_Handler', Core_Object__c = 'Case',
                                                                                    Core_Trigger_Events__c = 'Core_Trigger_Events__c', Core_Description__c = 'test desc');
        insert triggerExecution;
        List<Core_IPS_Supported_Product__c> supportedProduct = [SELECT Id from Core_IPS_Supported_Product__c LIMIT 999];
        
        List<Account> accounts = [SELECT Id from Account LIMIT 999];
         List<Contact> contacts = [SELECT Id from Contact LIMIT 999];
        List<Core_IPS_Product_Organization__c> supportOrganizations = [SELECT Id from Core_IPS_Product_Organization__c LIMIT 999];
        List<Core_IPS_Product_Issue_Category__c> caseCat = [SELECT Id from Core_IPS_Product_Issue_Category__c LIMIT 999];
        List<Core_IPS_Product_Issue_Category__c> subCategory = [SELECT Id from Core_IPS_Product_Issue_Category__c LIMIT 999];
        
         List<Core_IPS_Question__c> lstCoreQuestion = TestUtilities.getlstCoreQuestion(9);    
        for(Core_IPS_Question__c objQues : lstCoreQuestion) {
            objQues.Core_IPS_Product_Organization__c = supportOrganizations.get(0).id;
        }
        lstCoreQuestion[1].Core_IPS_Datatype__c = 'Text Area';
        lstCoreQuestion[6].Core_IPS_Datatype__c = 'Text Area';
        lstCoreQuestion[2].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[4].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[7].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[3].Core_IPS_Datatype__c = 'Multiselect Picklist';
        lstCoreQuestion[8].Core_IPS_Datatype__c = 'Multiselect Picklist';
        lstCoreQuestion[1].Core_IPS_Reporting_Name__c = 'test112';
        lstCoreQuestion[2].Core_IPS_Reporting_Name__c = 'test112oo';
        
        
        insert lstCoreQuestion;
        System.assert(lstCoreQuestion[0].Id != null, 'Record not created');
        
        lstCoreQuestion[4].Core_IPS_Parent_Question__c = lstCoreQuestion[2].Id;
        update lstCoreQuestion[4];
        
        List<Core_IPS_Answer__c> lstAnswer = new List<Core_IPS_Answer__c>();
        Map<Id,List<Core_IPS_Answer__c>> mapQuesId2Ans = new Map<Id,List<Core_IPS_Answer__c>>();
        for(Core_IPS_Question__c objQues : lstCoreQuestion) {
            mapQuesId2Ans.put(objQues.Id,new List<Core_IPS_Answer__c>());
            for(Core_IPS_Answer__c objAns : TestUtilities.getCoreAnswers(2)) {
                objAns.Core_IPS_Question__c = objQues.Id;
                lstAnswer.add(objAns);
                mapQuesId2Ans.get(objQues.Id).add(objAns);
            }               
        }
               
        insert lstAnswer;
             Core_IPS_BES_Questions__c getBESQuestions = new Core_IPS_BES_Questions__c();
             getBESQuestions.Name ='Ques-00010075';
             getBESQuestions.Backend_System_Name__c= 'DCG - HSDES Server Platforms';
             getBESQuestions.Environmental_Detail_Question__c ='DefaultedValue';
            insert getBESQuestions;
        Map<string,string> quesAnsMap= new Map<string,string>();
        	quesAnsMap.put('DefaultedValue','Ans 1');
         Core_IPS_Project__c projectcase=new Core_IPS_Project__c();
        Case secondCaseRecord = new Case();
        secondCaseRecord.AccountId=accounts.get(0).Id;
        secondCaseRecord.ContactId=contacts.get(0).id;  
        secondCaseRecord.Core_IPS_Product_Org1__c=supportOrganizations.get(0).id;
        secondCaseRecord.Core_Case_Issue_Category__c = caseCat[0].id;
        secondCaseRecord.Core_case_issue_sub_category__c = subCategory[0].id;
        secondCaseRecord.Core_Issue_Description__c = 'test'; 
        secondCaseRecord.Core_External_Issue_Category__c = 'Nova';
        secondCaseRecord.Core_External_Issue_Subcategory__c = 'XMM7560';
        secondCaseRecord.Subject='TestSubject';
        //CaseRecord2.Core_IPS_New_Backend_System__c = null;
        secondCaseRecord.Core_CaseType__c='Issue';
        secondCaseRecord.Core_IPS_Issue_source__c='n/a';
        secondCaseRecord.core_ips_project_case__c=projectcase.id;
        RecordType caseCreateRecordType = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        secondCaseRecord.recordTypeId = caseCreateRecordType.Id;
        secondCaseRecord.Core_IPS_EDQ_Filtering_Question__c ='bkc_or_sw_version';
        secondCaseRecord.Core_IPS_Partner_Sup_Owner__c = userinfo.getuserid();
        List<Case> caseList = new List<Case>();
        Test.startTest();
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
        	secondCaseRecord.setOptions(dmo);
            insert caseList; //CaseRecord;
        	insert secondCaseRecord;
        List<Case> updateCaseRecs = new List<Case>();
        insertCoreResponse(secondCaseRecord.Id);
            List<Core_IPS_BES_Outbound_Message__c> outboundObject = new List<Core_IPS_BES_Outbound_Message__c>();
            outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
        	outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
        	outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
        	outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
            insert outboundObject;
           
            
        if(outboundObject!=null && outboundObject.size()>0){
            outboundObject[2].core_IPS_Outbound_Message_ID__c = '123';
            outboundObject[2].Core_IPS_Case_ID__c = secondCaseRecord.Id; 
            outboundObject[2].Status__c = 'Apigee Success';
            outboundObject[2].Comment_Id__c = 'a1nDU000002e4LfYAI';
            outboundObject[2].Core_IPS_BES_Depromote_Id__c = 'a1nDU000002e4LfYAI';
            outboundObject[3].core_IPS_Outbound_Message_ID__c = '1234';
            outboundObject[3].Core_IPS_Case_ID__c = secondCaseRecord.Id; 
            outboundObject[3].Status__c = 'Apigee Success';
            outboundObject[3].Comment_Id__c = 'a1nDU000002e4LfYAI';
            outboundObject[3].Core_IPS_BES_Depromote_Id__c = 'a1nDU000002e4LfYAI';
            update outboundObject;
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[2].Id,outboundObject[3].Id});
            outboundObject[2].Status__c = 'Apigee Failed';
            outboundObject[3].Status__c = 'Apigee Failed';
            update outboundObject;
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[2].Id,outboundObject[3].Id});
            outboundObject[2].Status__c = 'IPass Failed';
            outboundObject[3].Status__c = 'IPass Failed';
            update outboundObject;
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[2].Id,outboundObject[3].Id});
            outboundObject[2].Status__c = 'IPass Success';
            outboundObject[3].Status__c = 'IPass Success';
            update outboundObject;
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[2].Id,outboundObject[3].Id});
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[2].Id,outboundObject[3].Id});
            outboundObject[2].Status__c = 'IPS Failed';
            outboundObject[3].Status__c = 'IPS Failed';
            update outboundObject;
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[2].Id,outboundObject[3].Id});
            
            
        }
        
        Case c = new Case();
        c.Id = secondCaseRecord.Id;
        c.Subject = 'Test Subject';
        c.Status = 'Open';
        c.Core_Sub_Status__c = 'Investigating';
        update c;
	
	    List<Core_IPS_BES_Outbound_Message__c> outboundObjectRec = new List<Core_IPS_BES_Outbound_Message__c>();
            outboundObjectRec.add(new Core_IPS_BES_Outbound_Message__c());
        	insert outboundObjectRec;
        if(outboundObjectRec!=null && outboundObjectRec.size()>0){
            outboundObjectRec[0].core_IPS_Outbound_Message_ID__c = '12312';
            outboundObjectRec[0].Core_IPS_Case_ID__c = c.Id; 
            outboundObjectRec[0].Status__c = 'Apigee Success';
            update outboundObjectRec;
           
                Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObjectRec[0].Id});
        }
        
        Test.stopTest();
        //insert CaseRecordSA;
        //insert CaseRecord1;
       //}
    }
    //added by Rajashekar
    public static TestMethod void backendPromotionTest4(){
        
        Core_Trigger_Executions__c triggerExecution = new Core_Trigger_Executions__c(Name= 'enableIPSCaseBackendRouting', Core_Active__c = true,
                                                                                     Core_Class_Name__c = 'Core_IPS_BES_CasePromotion_Handler', Core_Object__c = 'Case',
                                                                                    Core_Trigger_Events__c = 'Core_Trigger_Events__c', Core_Description__c = 'test desc');
        insert triggerExecution;
        List<Core_IPS_Supported_Product__c> supportedProduct = [SELECT Id from Core_IPS_Supported_Product__c LIMIT 999];
        Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
        backendSystem.Name = 'CC - HSDES Client Platform';

        backendSystem.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
        insert backendSystem;
        
        Core_IPS_Backend_System2__c backendSystem1 = new Core_IPS_Backend_System2__c();
        backendSystem1.Name = 'DCG - HSDES Server Platforms';

        backendSystem1.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
        insert backendSystem1;
        
        Core_IPS_Backend_Routing__c backendRoutingRule = new Core_IPS_Backend_Routing__c();
        backendRoutingRule.Core_IPS_Backend_Routing_Order__c = 1;
        backendRoutingRule.Core_IPS_Queue__c = 'IPS - Unassigned Cases';
        backendRoutingRule.Core_IPS_Routing_Casetype__c = 'Issue';
        backendRoutingRule.Core_IPS_Auto_Promote__c = true;
        backendRoutingRule.Core_IPS_New_Backend_System__c = backendSystem.Id;
        insert backendRoutingRule;
        List<Account> accounts = [SELECT Id from Account LIMIT 999];
         List<Contact> contacts = [SELECT Id from Contact LIMIT 999];
        List<Core_IPS_Product_Organization__c> supportOrganizations = [SELECT Id from Core_IPS_Product_Organization__c LIMIT 999];
        List<Core_IPS_Product_Issue_Category__c> caseCat = [SELECT Id from Core_IPS_Product_Issue_Category__c LIMIT 999];
        List<Core_IPS_Product_Issue_Category__c> subCategory = [SELECT Id from Core_IPS_Product_Issue_Category__c LIMIT 999];
        
         List<Core_IPS_Question__c> lstCoreQuestion = TestUtilities.getlstCoreQuestion(9);    
        for(Core_IPS_Question__c objQues : lstCoreQuestion) {
            objQues.Core_IPS_Product_Organization__c = supportOrganizations.get(0).id;
        }
        lstCoreQuestion[1].Core_IPS_Datatype__c = 'Text Area';
        lstCoreQuestion[6].Core_IPS_Datatype__c = 'Text Area';
        lstCoreQuestion[2].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[4].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[7].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[3].Core_IPS_Datatype__c = 'Multiselect Picklist';
        lstCoreQuestion[8].Core_IPS_Datatype__c = 'Multiselect Picklist';
        lstCoreQuestion[1].Core_IPS_Reporting_Name__c = 'test112';
        lstCoreQuestion[2].Core_IPS_Reporting_Name__c = 'test112oo';
        
        
        insert lstCoreQuestion;
        System.assert(lstCoreQuestion[0].Id != null, 'Record not created');
        
        lstCoreQuestion[4].Core_IPS_Parent_Question__c = lstCoreQuestion[2].Id;
        update lstCoreQuestion[4];
        
        List<Core_IPS_Answer__c> lstAnswer = new List<Core_IPS_Answer__c>();
        Map<Id,List<Core_IPS_Answer__c>> mapQuesId2Ans = new Map<Id,List<Core_IPS_Answer__c>>();
        for(Core_IPS_Question__c objQues : lstCoreQuestion) {
            mapQuesId2Ans.put(objQues.Id,new List<Core_IPS_Answer__c>());
            for(Core_IPS_Answer__c objAns : TestUtilities.getCoreAnswers(2)) {
                objAns.Core_IPS_Question__c = objQues.Id;
                lstAnswer.add(objAns);
                mapQuesId2Ans.get(objQues.Id).add(objAns);
            }               
        }
               
        insert lstAnswer;
             Core_IPS_BES_Questions__c getBESQuestions = new Core_IPS_BES_Questions__c();
             getBESQuestions.Name ='Ques-00010075';
             getBESQuestions.Backend_System_Name__c= 'DCG - HSDES Server Platforms';
             getBESQuestions.Environmental_Detail_Question__c ='DefaultedValue';
            insert getBESQuestions;
        Map<string,string> quesAnsMap= new Map<string,string>();
        	quesAnsMap.put('DefaultedValue','Ans 1');
         Core_IPS_Project__c projectcase=new Core_IPS_Project__c();
        Case secondCaseRecord = new Case();
        secondCaseRecord.AccountId=accounts.get(0).Id;
        secondCaseRecord.ContactId=contacts.get(0).id;  
        secondCaseRecord.Core_IPS_Product_Org1__c=supportOrganizations.get(0).id;
        secondCaseRecord.Core_Case_Issue_Category__c = caseCat[0].id;
        secondCaseRecord.Core_case_issue_sub_category__c = subCategory[0].id;
        secondCaseRecord.Core_Issue_Description__c = 'test'; 
        secondCaseRecord.Core_External_Issue_Category__c = 'Nova';
        secondCaseRecord.Core_External_Issue_Subcategory__c = 'XMM7560';
        secondCaseRecord.Subject='TestSubject';
        secondCaseRecord.Core_CaseType__c='Issue';
        secondCaseRecord.Core_IPS_Issue_source__c='n/a';
        secondCaseRecord.core_ips_project_case__c=projectcase.id;
        //CaseRecord.Core_IPS_Backend_System__r.Name= backendSystem.Name;
        RecordType caseCreateRecordType = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        secondCaseRecord.recordTypeId = caseCreateRecordType.Id;
        secondCaseRecord.Core_IPS_BackendID__c = 'a1nDU000002e4LfYAI';
        secondCaseRecord.Core_IPS_EDQ_Filtering_Question__c ='bkc_or_sw_version';
        secondCaseRecord.Core_IPS_Partner_Sup_Owner__c = userinfo.getuserid();
        secondCaseRecord.Core_IPS_New_Backend_System__c =backendSystem1.Id;
        List<Case> caseList = new List<Case>();
        //caseList.add(CaseRecord2);
        Test.startTest();
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
        	secondCaseRecord.setOptions(dmo);
            insert caseList; //CaseRecord;
        	insert secondCaseRecord;
        Core_IPS_Case_Attachments__c attachmentRec = new Core_IPS_Case_Attachments__c();
        attachmentRec.Core_Case__c = secondCaseRecord.Id;
        attachmentRec.Core_IPS_BES_Promote_Status__c ='In Progress';
        attachmentRec.Core_File_Description__c = 'testAttachment';
        //insert attachmentRec;
        List<Case> updateCaseRecs = new List<Case>();
        insertCoreResponse(secondCaseRecord.Id);
            List<Core_IPS_BES_Outbound_Message__c> outboundObject = new List<Core_IPS_BES_Outbound_Message__c>();
            outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
        	outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
        	outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
        	outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
            insert outboundObject;
           
            
        if(outboundObject!=null && outboundObject.size()>0){
            outboundObject[2].core_IPS_Outbound_Message_ID__c = '123';
            outboundObject[2].Core_IPS_Case_ID__c = secondCaseRecord.Id; 
            outboundObject[2].Status__c = 'Apigee Success';
            outboundObject[2].Core_IPS_Attachment_ID__c = 'a1nDU000002e4LfYAI';
            outboundObject[3].core_IPS_Outbound_Message_ID__c = '1234';
            outboundObject[3].Core_IPS_Case_ID__c = secondCaseRecord.Id; 
            outboundObject[3].Status__c = 'Apigee Success';
            outboundObject[3].Core_IPS_Attachment_ID__c = 'a1nDU000002e4LfYAI';
            update outboundObject;
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[2].Id,outboundObject[3].Id});
            outboundObject[2].Status__c = 'Apigee Failed';
            outboundObject[3].Status__c = 'Apigee Failed';
            update outboundObject;
            /*Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[2].Id,outboundObject[3].Id});
            outboundObject[2].Status__c = 'IPass Failed';
            outboundObject[3].Status__c = 'IPass Failed';
            update outboundObject;
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[2].Id,outboundObject[3].Id});
            outboundObject[2].Status__c = 'IPass Success';
            outboundObject[3].Status__c = 'IPass Success';
            update outboundObject;
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[2].Id,outboundObject[3].Id});
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[2].Id,outboundObject[3].Id});
            outboundObject[2].Status__c = 'IPS Failed';
            outboundObject[3].Status__c = 'IPS Failed';
            update outboundObject;
            Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[2].Id,outboundObject[3].Id});*/
            
            
        }
        //caseList[0].Subject='TestSubject';
        //caseList[1].Status = 'Open';
        //caseList[1].Core_Sub_Status__c = 'Investigating';
        
        //update caseList; 
        
        
        
        CaseHistory ch = new CaseHistory();
        ch.CaseId = secondCaseRecord.Id;
        ch.Field = 'Core_Sub_Status__c';
        
        insert ch;
        //Core_IPS_BES_HSD_CustomLogic chL= new Core_IPS_BES_HSD_CustomLogic();
        Core_IPS_BES_HSD_CustomLogic.processDCGStatusReasonLogic(secondCaseRecord.Id,new Map<String,CaseHistory>{secondCaseRecord.Id+'Core_Sub_Status__c' => ch});
        //{'caseList[1].Id+\'Core_Sub_Status__c\'' => ch};
        
        Case c = new Case();
        c.Id = secondCaseRecord.Id;
        c.Subject = 'Test Subject';
        c.Status = 'Open';
        c.Core_Sub_Status__c = 'Investigating';
        update c;
	
	    List<Core_IPS_BES_Outbound_Message__c> outboundObjectRec = new List<Core_IPS_BES_Outbound_Message__c>();
            outboundObjectRec.add(new Core_IPS_BES_Outbound_Message__c());
        	insert outboundObjectRec;
        if(outboundObjectRec!=null && outboundObjectRec.size()>0){
            outboundObjectRec[0].core_IPS_Outbound_Message_ID__c = '12312';
            outboundObjectRec[0].Core_IPS_Case_ID__c = c.Id; 
            outboundObjectRec[0].Status__c = 'Apigee Success';
            update outboundObjectRec;
           
                Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObjectRec[0].Id});
        }
        
        Test.stopTest();
        //insert CaseRecordSA;
        //insert CaseRecord1;
      
    }
  
      public static TestMethod void backendPromotionTestGED(){
       
         Core_Trigger_Executions__c triggerExecution = new Core_Trigger_Executions__c(Name= 'enableIPSCaseBackendRouting', Core_Active__c = true,
                                                                                     Core_Class_Name__c = 'Core_IPS_BES_CasePromotion_Handler', Core_Object__c = 'Case',
                                                                                    Core_Trigger_Events__c = 'Core_Trigger_Events__c', Core_Description__c = 'test desc');
        insert triggerExecution;
        
        Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
        backendSystem.Name = 'CC - HSDES Client Platform';

        backendSystem.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
        insert backendSystem;
          
        Core_IPS_Backend_System2__c backendSystem1 = new Core_IPS_Backend_System2__c();
        backendSystem1.Name = 'HSDES-PSG0';
 
        backendSystem1.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
        insert backendSystem1;
        
        
        
        Core_IPS_Backend_Routing__c backendRoutingRule = new Core_IPS_Backend_Routing__c();
        backendRoutingRule.Core_IPS_Backend_Routing_Order__c = 1;
        backendRoutingRule.Core_IPS_Queue__c = 'IPS - Unassigned Cases';
        backendRoutingRule.Core_IPS_Routing_Casetype__c = 'Issue';
        backendRoutingRule.Core_IPS_Auto_Promote__c = true;
        backendRoutingRule.Core_IPS_New_Backend_System__c = backendSystem.Id;
        insert backendRoutingRule;
        
        List<Account> accounts = [SELECT Id from Account LIMIT 999];
         List<Contact> contacts = [SELECT Id from Contact LIMIT 999];
        List<Core_IPS_Product_Organization__c> supportOrganizations = [SELECT Id from Core_IPS_Product_Organization__c LIMIT 999];
        List<Core_IPS_Product_Issue_Category__c> caseCat = [SELECT Id from Core_IPS_Product_Issue_Category__c LIMIT 999];
        List<Core_IPS_Product_Issue_Category__c> subCategory = [SELECT Id from Core_IPS_Product_Issue_Category__c LIMIT 999];
        
         List<Core_IPS_Question__c> lstCoreQuestion = TestUtilities.getlstCoreQuestion(9);    
        for(Core_IPS_Question__c objQues : lstCoreQuestion) {
            objQues.Core_IPS_Product_Organization__c = supportOrganizations.get(0).id;
        }
        lstCoreQuestion[1].Core_IPS_Datatype__c = 'Text Area';
        lstCoreQuestion[6].Core_IPS_Datatype__c = 'Text Area';
        lstCoreQuestion[2].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[4].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[7].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[3].Core_IPS_Datatype__c = 'Multiselect Picklist';
        lstCoreQuestion[8].Core_IPS_Datatype__c = 'Multiselect Picklist';
        
        insert lstCoreQuestion;
        System.assert(lstCoreQuestion[0].Id != null, 'Record not created');
        
        lstCoreQuestion[4].Core_IPS_Parent_Question__c = lstCoreQuestion[2].Id;
        update lstCoreQuestion[4];
        
        List<Core_IPS_Answer__c> lstAnswer = new List<Core_IPS_Answer__c>();
        Map<Id,List<Core_IPS_Answer__c>> mapQuesId2Ans = new Map<Id,List<Core_IPS_Answer__c>>();
        for(Core_IPS_Question__c objQues : lstCoreQuestion) {
            mapQuesId2Ans.put(objQues.Id,new List<Core_IPS_Answer__c>());
            for(Core_IPS_Answer__c objAns : TestUtilities.getCoreAnswers(2)) {
                objAns.Core_IPS_Question__c = objQues.Id;
                lstAnswer.add(objAns);
                mapQuesId2Ans.get(objQues.Id).add(objAns);
            }               
        }
               
        insert lstAnswer;
        
        Core_IPS_Project__c projectcase=new Core_IPS_Project__c();
                 Case caseRecord = new Case();
                Case firstCaseRecord = new Case();
                Case selfAssignedCaseRecord = new Case();
                caseRecord.AccountId=accounts.get(0).Id;
                caseRecord.ContactId=contacts.get(0).id;  
                caseRecord.Core_IPS_Product_Org1__c=supportOrganizations.get(0).id;
                caseRecord.Core_Case_Issue_Category__c = caseCat[0].id;
                caseRecord.Core_case_issue_sub_category__c = subCategory[0].id;
                caseRecord.Core_Issue_Description__c = 'test';
                    caseRecord.Core_External_Issue_Category__c = 'Nova';
                caseRecord.Core_External_Issue_Subcategory__c = 'XMM7560';

        caseRecord.Subject='TestSubject';
        caseRecord.Core_CaseType__c='Issue';
        caseRecord.Core_IPS_Issue_source__c='n/a';
        caseRecord.core_ips_project_case__c=projectcase.id;
        RecordType caseRecordType = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'IPS_Case_Create'];
        caseRecord.recordTypeId = caseRecordType.Id;
        caseRecord.Core_IPS_Partner_Sup_Owner__c = userinfo.getuserid();
        RecordType selfAssignedCaseRecordType = [Select Name, Id From RecordType where sObjectType='Case' and DeveloperName = 'Core_IPS_Case_Create_Self_Assigned'];
        selfAssignedCaseRecord = caseRecord.clone(false,true);
        selfAssignedCaseRecord.RecordTypeId = selfAssignedCaseRecordType.Id;
        
        Test.startTest();
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            caseRecord.setOptions(dmo);
            insert caseRecord;
            
          
        
              caseRecord.Core_IPS_New_Backend_System__c = null;
          update caseRecord;
        
          Test.stopTest();
     }
    
    static void insertCoreResponse(Id caseId) {
        List<Core_IPS_Response__c> lstResponse = new List<Core_IPS_Response__c>();
        for(Core_IPS_Question__c objQues : [SELECT Id,Core_IPS_Datatype__c,(SELECT Id, Core_IPS_Answer__c FROM Core_Answers__r LIMIT 1) FROM Core_IPS_Question__c LIMIT 999]) { //ATHR Query limit fix
            for(Core_IPS_Answer__c objAns : objQues.Core_Answers__r) {
                Core_IPS_Response__c objResponse = new Core_IPS_Response__c();
                objResponse.Core_IPS_Case__c = caseId;
                if(String.isNotBlank(objQues.Core_IPS_Datatype__c) && String.valueOf(objQues.Core_IPS_Datatype__c).contains('Picklist')){
                    objResponse.Core_IPS_Answer_Master__c = objAns.Id;
                }
                objResponse.Core_IPS_Question_Master__c = objQues.Id;
                objResponse.Core_IPS_Answer__c = objAns.Core_IPS_Answer__c;
                lstResponse.add(objResponse);
            }
        }
        insert lstResponse;
        System.assertNotEquals(null, lstResponse[0].Id, 'The Account Id should not be null after insertion.');
    }

    @isTest
    public static void  testGetStatusReasonForIOT(){
       
        Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
        backendSystem.Name = 'EMBED - HSDES IoT Platform';
        backendSystem.Core_IPS_Target_System__c = 'hsdes:iot_platf:bug';
        insert backendSystem;
                    List<Core_IPS_Product_Organization__c> supportOrganizations = [SELECT Id from Core_IPS_Product_Organization__c LIMIT 999];
                List<Core_IPS_Supported_Product__c> supportedProducts = [SELECT Id from Core_IPS_Supported_Product__c LIMIT 999];
        Core_IPS_Backend_Routing__c backendRoutingRule = new Core_IPS_Backend_Routing__c();
        backendRoutingRule.Core_IPS_Backend_Routing_Order__c = 1;
        backendRoutingRule.Core_IPS_Supported_Product__c = supportedProducts[0].Id;
        backendRoutingRule.Core_IPS_Auto_Promote__c = true;
        backendRoutingRule.Core_IPS_New_Backend_System__c = backendSystem.Id;
        insert backendRoutingRule;
        
         List<Core_IPS_Question__c> lstCoreQuestion = TestUtilities.getlstCoreQuestion(9);    
        for(Core_IPS_Question__c objQues : lstCoreQuestion) {
            objQues.Core_IPS_Product_Organization__c = supportOrganizations.get(0).id;
        }
        lstCoreQuestion[1].Core_IPS_Datatype__c = 'Text Area';
        lstCoreQuestion[6].Core_IPS_Datatype__c = 'Text Area';
        lstCoreQuestion[2].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[4].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[7].Core_IPS_Datatype__c = 'Picklist';
        lstCoreQuestion[3].Core_IPS_Datatype__c = 'Multiselect Picklist';
        lstCoreQuestion[8].Core_IPS_Datatype__c = 'Multiselect Picklist';
        lstCoreQuestion[1].Core_IPS_Reporting_Name__c = 'test112';
        lstCoreQuestion[2].Core_IPS_Reporting_Name__c = 'test112oo';
        
        
        insert lstCoreQuestion;
        System.assert(lstCoreQuestion[0].Id != null, 'Record not created');
        
        lstCoreQuestion[4].Core_IPS_Parent_Question__c = lstCoreQuestion[2].Id;
        update lstCoreQuestion[4];
        
        List<Core_IPS_Answer__c> lstAnswer = new List<Core_IPS_Answer__c>();
        Map<Id,List<Core_IPS_Answer__c>> mapQuesId2Ans = new Map<Id,List<Core_IPS_Answer__c>>();
        for(Core_IPS_Question__c objQues : lstCoreQuestion) {
            mapQuesId2Ans.put(objQues.Id,new List<Core_IPS_Answer__c>());
            for(Core_IPS_Answer__c objAns : TestUtilities.getCoreAnswers(2)) {
                objAns.Core_IPS_Question__c = objQues.Id;
              
                lstAnswer.add(objAns);
                mapQuesId2Ans.get(objQues.Id).add(objAns);
            }               
        }
               
        insert lstAnswer;
        
        
             Core_IPS_BES_Questions__c getBESQuestions = new Core_IPS_BES_Questions__c();
             getBESQuestions.Name ='Ques-00010075';
             getBESQuestions.Backend_System_Name__c= 'DCG - HSDES Server Platforms';
             getBESQuestions.Environmental_Detail_Question__c ='DefaultedValue';
            insert getBESQuestions;
        Map<string,string> quesAnsMap= new Map<string,string>();
        	quesAnsMap.put('DefaultedValue','Ans 1');
        
        Case caseRecord = new Case();
        caseRecord.Status = 'Open';
        caseRecord.Core_Sub_Status__c = 'Close-Pending';
        caseRecord.Core_Issue_Description__c = 'test';
        caseRecord.Core_External_Issue_Category__c = 'Firmware/BIOS';
        caseRecord.Core_External_Issue_Subcategory__c = 'BIOS';
        caseRecord.Core_IPS_Supported_Product__c = supportedProducts[0].Id;
	    caseRecord.Core_IPS_New_Backend_System__c = backendSystem.Id;
        caseRecord.Core_Environment_Details__c = 'DefaultedValue';
        Map<String, List<Core_IPS_BES_AllTenants_CustomMapping__c>> customMapping = Core_IPS_BES_Generate_CaseJSON.prepareCustomSettingData();
        
        
        
        Test.startTest();
        String statusNReason = Core_IPS_BES_HSD_CustomLogic.getStatusNReasonForIOT(caseRecord, 'Core_Sub_Status__c', customMapping.get('EMBED - HSDES IoT Platform'));
        System.assertEquals('open.awaiting_customer', statusNReason, 'Status and reason returned are not correct');
        caseRecord.Status = 'Closed';
        caseRecord.Core_Sub_Status__c = 'Closed';
        
        insert caseRecord;
        
        List<Core_IPS_BES_Outbound_Message__c> outboundObject = new List<Core_IPS_BES_Outbound_Message__c>();
            outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
        	outboundObject.add(new Core_IPS_BES_Outbound_Message__c());
            insert outboundObject;
           
            
        if(outboundObject!=null && outboundObject.size()>0){
            outboundObject[0].core_IPS_Outbound_Message_ID__c = '123';
            outboundObject[0].Core_IPS_Case_ID__c = caseRecord.Id; 
            outboundObject[0].Status__c = 'Apigee Success';
            outboundObject[1].core_IPS_Outbound_Message_ID__c = '1234';
            outboundObject[1].Core_IPS_Case_ID__c = caseRecord.Id; 
            outboundObject[1].Status__c = 'Apigee Success';
            update outboundObject;
                Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[0].Id,outboundObject[1].Id});
        }
        statusNReason = Core_IPS_BES_HSD_CustomLogic.getStatusNReasonForIOT(caseRecord, 'Status', customMapping.get('EMBED - HSDES IoT Platform'));
        System.assertEquals('complete', statusNReason, 'Status and reason returned are not correct');
        caseRecord.Core_Environment_Details__c = '';
        update caseRecord;
         Core_IPS_BES_JSONTriggerHandler.getJson(new List<Id>{outboundObject[0].Id,outboundObject[1].Id});
        
        Test.stopTest();
    }

    @isTest
    public static void  testGetSourceType(){
        Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
        backendSystem.Name = 'EMBED - HSDES IoT Platform';
        backendSystem.Core_IPS_Target_System__c = 'hsdes:iot_platf:bug';
        insert backendSystem;
        
        Case caseRecord = new Case();
        caseRecord.Status = 'Open';
        caseRecord.Core_Sub_Status__c = 'Close-Pending';
        caseRecord.Core_Issue_Description__c = 'test';
        caseRecord.Core_External_Issue_Category__c = 'Firmware/BIOS';
        caseRecord.Core_External_Issue_Subcategory__c = 'BIOS';

        Map<String, List<Core_IPS_BES_AllTenants_CustomMapping__c>> customMapping = Core_IPS_BES_Generate_CaseJSON.prepareCustomSettingData();
        List<Core_IPS_BES_Error_Log__c> erList = new List<Core_IPS_BES_Error_Log__c>();

        Core_IPS_BES_Error_Log__c errorLog = new Core_IPS_BES_Error_Log__c(
            Core_IPS_Error_Description__c = 'test description',
            Core_IPS_Status__c = 'test status',
            Core_IPS_Outbound_Message_Id__c =null
        );
        
        Core_IPS_BES_Error_Log__c errorLog1 = new Core_IPS_BES_Error_Log__c(
            Core_IPS_Error_Description__c = 'test description',
            Core_IPS_Status__c = null
        );
        
        Core_IPS_BES_Error_Log__c errorLog2 = new Core_IPS_BES_Error_Log__c(
            Core_IPS_Error_Description__c = null,
            Core_IPS_Status__c = 'Test Status1'
        );
        
        erList.add(errorLog);
        erList.add(errorLog1);
        erList.add(errorLog2);
        
        insert erList;
        
        // Get list of inserted record IDs
        List<Id> errorLogIds = new List<Id>();
        for (Core_IPS_BES_Error_Log__c record : erList) {
            errorLogIds.add(record.Id);
        }

		System.debug(errorLogIds);
        //Core_IPS_BES_JSONTriggerHandler.getJsonInvockable(errorLogIds);
        Test.startTest();
        String statusNReason = Core_IPS_BES_HSD_CustomLogic.getSourceType(caseRecord, customMapping);
        System.assertEquals('firmware', statusNReason, 'source_type returned is not correct');
        
        caseRecord.Core_External_Issue_Category__c  = 'Ethernet Wired LAN';
        caseRecord.Core_External_Issue_Subcategory__c = 'Driver';
        statusNReason = Core_IPS_BES_HSD_CustomLogic.getSourceType(caseRecord, customMapping);
        System.assertEquals('software', statusNReason, 'source_type returned is not correct');
        Test.stopTest();
    }
}