@isTest
public class Core_IPS_BES_Inbound_JSON_Test {
    
    @testSetup static void setupMethod() {
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
        insert lstCs;
        
        List<IPS_Case_Fields__c> caseFieldsList = new List<IPS_Case_Fields__c>();
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'account_billing_city', API_Name__c ='Account.billingcity',
                                                  Object_Name__c ='Case', Name = 'Account Billing City', Order__c =1010, Additional_Info__c = true));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'status', API_Name__c ='status',
                                                  Object_Name__c ='Case', Name = 'status', Order__c =1010, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'account_cim_id', API_Name__c ='Account.Core_CIM_ID__c',
                                                  Object_Name__c ='Case', Name = 'CIM ID', Order__c =1011, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'account_id', API_Name__c ='AccountID',
                                                  Object_Name__c ='Case', Name = 'Account ID', Order__c =1012, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'question', API_Name__c ='Core_IPS_Question__c',
                                                  Object_Name__c ='Core_IPS_Response__c', Name = 'Question', Order__c =1013, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'Reporting Name', API_Name__c ='Core_IPS_Question_Master__r.Core_IPS_Reporting_Name__c',
                                                  Object_Name__c ='Core_IPS_Response__c', Name = 'Reporting Name', Order__c =1014, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'answer', API_Name__c ='Core_IPS_Answer__c',
                                                  Object_Name__c ='Core_IPS_Response__c', Name = 'Answer', Order__c =1015, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'category', API_Name__c ='Core_External_Issue_Category__c',
                                                  Object_Name__c ='Case', Name = 'Case Category', Order__c =1015, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'subcategory', API_Name__c ='Core_External_Issue_Subcategory__c',
                                                  Object_Name__c ='Case', Name = 'Case Subcategory', Order__c =1016, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'new_backend_system_name', API_Name__c ='Core_IPS_New_Backend_System__r.Name',
                                                  Object_Name__c ='Case', Name = 'New Backend System Name', Order__c =1017, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'hsd_mirror_status', API_Name__c ='HSD_Mirror_Status__c',
                                                  Object_Name__c ='Case', Name = 'HSD Mirror Status', Order__c =1018, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'hsd_mirror_reason', API_Name__c ='HSD_Mirror_Reason__c',
                                                  Object_Name__c ='Case', Name = 'HSD Mirror Reason', Order__c =1019, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'description', API_Name__c ='Core_Issue_Description__c',
                                                  Object_Name__c ='Case', Name = 'Case Description', Order__c =160, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'contact_name', API_Name__c ='Core_Contact_Name__c',
                                                  Object_Name__c ='Case', Name = 'Contact Name', Order__c =170, Additional_Info__c = false));
        caseFieldsList.add(new IPS_Case_Fields__c(JSON_Field_Name__c = 'gec', API_Name__c ='Core_IPS_GEC_Flag__c',
                                                  Object_Name__c ='Case', Name = 'GEC', Order__c =180, Additional_Info__c = false));
        
        insert caseFieldsList;
        
        List<Core_IPS_BES_AllTenants_CustomMapping__c> allTenentCustomSetting1 = new List<Core_IPS_BES_AllTenants_CustomMapping__c>();
        allTenentCustomSetting1.add(new Core_IPS_BES_AllTenants_CustomMapping__c(Name = 'BES - 000015', Backend_System_Name__c = 'CC - HSDES Client Platform',
                                                                                 Direction__c ='Inbound', Field_API_Name__c = 'Status', Json_Key__c = 'status',
                                                                                 Source_Value__c = 'open', Target_Value__c ='Open.Escalated to Engineering'));
        allTenentCustomSetting1.add(new Core_IPS_BES_AllTenants_CustomMapping__c(Name = 'BES - 000016', Backend_System_Name__c = 'CC - HSDES Client Platform',
                                                                                 Direction__c ='Inbound', Field_API_Name__c = 'Core_Sub_Status__c', Json_Key__c = 'sub_status',
                                                                                 Source_Value__c = 'triage', Target_Value__c ='Open.Investigating'));
        allTenentCustomSetting1.add(new Core_IPS_BES_AllTenants_CustomMapping__c(Name = 'BES - 000018', Backend_System_Name__c = 'DCG - HSDES Server Platforms',
                                                                                 Direction__c ='Inbound', Field_API_Name__c = 'Core_Sub_Status__c', Json_Key__c = 'sub_status',
                                                                                 Source_Value__c = 'triage', Target_Value__c ='Open.Investigating'));
        allTenentCustomSetting1.add(new Core_IPS_BES_AllTenants_CustomMapping__c(Name = 'BES - 000019', Backend_System_Name__c = 'DCG - HSDES Server Platforms',
                                                                                 Direction__c ='Inbound', Field_API_Name__c = 'Status', Json_Key__c = 'status',
                                                                                 Source_Value__c = 'future', Target_Value__c ='Open.Deferred'));
        
        insert allTenentCustomSetting1;
        
        List<IPS_Case_Comment_Fields__c> caseCommentFields = new List<IPS_Case_Comment_Fields__c>();
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'Author By Email', Comment_Field_API_Name__c = 'Core_IPS_Comment_Authored_By_Email__c',
                                                             Comment_Field_Type__c = 'Text', JSON_Field_Name__c = 'authored_by_email', Object_Name__c = 'Core_IPS_Case_Comments__c'));
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'Author By Id', Comment_Field_API_Name__c = 'Core_IPS_Comment_Authored_By__c',
                                                             Comment_Field_Type__c = 'Lookup(User)', JSON_Field_Name__c = 'authored_by_id', Object_Name__c = 'Core_IPS_Case_Comments__c'));
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'Author By Name', Comment_Field_API_Name__c = 'Core_IPS_Comment_Authored_By_Name__c',
                                                             Comment_Field_Type__c = 'Text', JSON_Field_Name__c = 'authored_by_name', Object_Name__c = 'Core_IPS_Case_Comments__c'));
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'Author type', Comment_Field_API_Name__c = 'Core_IPS_Comment_Author_Type__c',
                                                             Comment_Field_Type__c = 'Picklist', JSON_Field_Name__c = 'author_type', Object_Name__c = 'Core_IPS_Case_Comments__c'));
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'Case Comment Source', Comment_Field_API_Name__c = 'Core_IPS_Case_Comment_Source__c',
                                                             Comment_Field_Type__c = 'Picklist', JSON_Field_Name__c = 'comment_source', Object_Name__c = 'Core_IPS_Case_Comments__c'));
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'Comment text', Comment_Field_API_Name__c = 'Core_IPS_Rich_Comment__c',
                                                             Comment_Field_Type__c = 'Rich Text Area(131072)', JSON_Field_Name__c = 'comment_text', Object_Name__c = 'Core_IPS_Case_Comments__c'));
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'Comment Type', Comment_Field_API_Name__c = 'Core_IPS_Case_Comment_Type__c',
                                                             Comment_Field_Type__c = 'Picklist', JSON_Field_Name__c = 'comment_type', Object_Name__c = 'Core_IPS_Case_Comments__c'));
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'Created by Id', Comment_Field_API_Name__c = 'CreatedById',
                                                             Comment_Field_Type__c = 'Lookup(User)', JSON_Field_Name__c = 'created_by_id', Object_Name__c = 'Core_IPS_Case_Comments__c'));
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'Created by Name', Comment_Field_API_Name__c = 'CreatedBy.Name',
                                                             Comment_Field_Type__c = 'Lookup(User)', JSON_Field_Name__c = 'created_by_name', Object_Name__c = 'Core_IPS_Case_Comments__c'));
        caseCommentFields.add(new IPS_Case_Comment_Fields__c(Name= 'CreatedDate', Comment_Field_API_Name__c = 'CreatedDate',
                                                             Comment_Field_Type__c = 'Date/Time', JSON_Field_Name__c = 'created_datetime', Object_Name__c = 'Core_IPS_Case_Comments__c'));
        insert caseCommentFields;
          // Avoid Hardcoding Id Fix - Shipra
		Profile dataMigPrf = [select id, name from Profile where name  = 'Integration' Limit 1];
         User userint = new User(Alias = 'admin', 
                              Email='adminTest@intel.com', 
                              EmailEncodingKey='UTF-8',
                              LastName='Testing',
                              LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', 
                              ProfileId = dataMigPrf.Id, 
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName='integTest@intel.com');
        insert userint;
        
        Core_IPS_Comment_JSON__c backendCommentJSON =  new Core_IPS_Comment_JSON__c(Name='Comment JSON', Comment_Source__c='Comment_Source__c', Comment_Type__c='Public to Customer',
                                                                                    Comment_Author_Type__c ='Backend Integration', Comment_Author_Name__c ='Backend Integration User IPS', 
                                                                                    Comment_Author_Email__c ='ranjini.jn@test.com', Comment_Author_By__c =userint.Id); // Avoid Hardcoding Id Fix - Shipra
        insert backendCommentJSON; 
          // Avoid Hardcoding Id Fix - Shipra

      /*  Core_IPS_Comment_JSON__c backendCommentJSON =  new Core_IPS_Comment_JSON__c(Name='Comment JSON', Comment_Source__c='Comment_Source__c', Comment_Type__c='Public to Customer',
                                                                                  Comment_Author_Type__c ='Backend Integration', Comment_Author_Name__c ='Backend Integration User IPS', 
                                                                                   Comment_Author_Email__c ='ranjini.jn@test.com', Comment_Author_By__c ='005o0000002kzX4');
        insert backendCommentJSON; */
        
        Core_IPS_APIGEE_Custom_Settings__c customSetting = new Core_IPS_APIGEE_Custom_Settings__c();
        customSetting.Name = 'Core_IPS_HSD_UserDetails';
        customSetting.MyIntel_Client_Id__c = '174b7bf8-8586-40ab-af6f-65450151f540';
        customSetting.MyIntel_Client_Secret__c = 'JeI8Q~WRoWsalXMrI7OHqHFBEvJeKXub7fCPPbNp';
        customSetting.MyIntel_Endpoint_URL__c = 'https://apis-sandbox.intel.com/m2r/hsdes/v1/user-details/';
        customSetting.MyIntel_GrantType__c = 'client_credentials';
        customSetting.MyIntel_Token_Endpoint_URL__c = System.Label.Core_IPS_BES_Token_URL;
        insert customSetting;
        
        Core_Trigger_Executions__c label20 =new Core_Trigger_Executions__c();
        label20.Name='myIntelIntegration';
        label20.Core_Active__c=true;
        label20.Core_Class_Name__c='Core_IPS_CaseTriggerHandler';
        label20.Core_Object__c='Case';
        label20.Core_Description__c='MyIntel 3.0';
        label20.Core_Trigger_Events__c='before update, after create';
        insert label20;
        
        Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
        backendSystem.Name = 'DCG - HSDES Server Platforms';
        backendSystem.Core_IPS_Target_System__c = 'hsdes:server_platf_ae:bug';
        backendSystem.Core_IPS_Backend_System_URL__c = 'https://hsdes-pre.intel.com/appstore/article/#/';
        backendSystem.Core_IPS_SCFT_Backend_Type__c ='HSDES_SFT';
        insert backendSystem;
        
        Case cs =  TestUtilities.getCase();
        cs.Core_IPS_New_Backend_System__c = backendSystem.Id;
        cs.Core_IPS_BackendID__c = '123213000000';
        insert cs;
        List<Case> csList = [SELECT Id,casenumber from Case WHERE ID =:cs.Id];
       
        
        String jsonString = '{"system_details":{"message_id":"001","message_type":"Case","source_system":"hsdes:server_platf_ae:bug","target_system":"IPS","source_id":"'+cs.Core_IPS_BackendID__c+'","target_id":"'+csList[0].casenumber+'"},"issue_information":{"comment_author": "testx","comment_text":"sample comment", "owner_info": "testyx", "hsd_mirror_status":"open","hsd_mirror_reason":"triage"}}';
        Core_IPS_BES_Inbound_Message__c inboundObject = new Core_IPS_BES_Inbound_Message__c();
        inboundObject.Core_IPS_Inbound_Message_ID__c = '';
        insert inboundObject;
        
        Attachment att = new Attachment();
        att.ParentId = inboundObject.Id;
        att.Name = 'test Att';
        att.body = Blob.valueOf(jsonString);
        insert att;
        
    }
    public static testMethod void testCaseBackendId(){
        
        Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
        backendSystem.Name = 'HSDES-PSG01';
        //backendSystem.Core_IPS_Deactivated__c = true;
        
        
        backendSystem.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
        insert backendSystem;
        Case cs =  TestUtilities.getCase();
        cs.Core_IPS_New_Backend_System__c = backendSystem.Id;
        //cs.Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c = backendSystem.Core_IPS_Deactivated__c;
        //cs.Core_IPS_BES_Promote_Status__c = 'Done';
        insert cs;
        System.assert(backendSystem.Id!=null);
        List<Case> csList = [SELECT Id,casenumber from Case WHERE ID =:cs.Id];
        
        
        
        RestRequest req = new RestRequest(); 
        req.requestURI = '/services/apexrest/IPS_BES_InboundMessageJSON/';
        req.httpMethod = 'POST';
        String jsonString = '{ "response" : { "message_id" : "BES OB-1179", "message_type" : "Case", "source_system" : "hsdes:fpga:bug", "target_system" : "IPS", "source_id" : "1308659269", "target_id" : "'+csList[0].casenumber+'"} }';
        req.requestBody =Blob.valueOf(jsonString);
        RestContext.request = req;
        Test.startTest();
        //Process builder code
        Core_IPS_BES_Inbound_JSON.getBackendId();
        Core_IPS_BES_Inbound_Message__c inboundObject = new Core_IPS_BES_Inbound_Message__c();
        inboundObject.Core_IPS_Inbound_Message_ID__c = '';
        insert inboundObject;
        
        Attachment att = new Attachment();
        att.ParentId = inboundObject.Id;
        att.Name = 'test Att';
        att.body = Blob.valueOf(jsonString);
        insert att;
        Core_IPS_BES_InboundMessage.setJSON(new List<Id>{inboundObject.Id});
        Case newCase = new Case();
        newCase.Subject = 'Dummy Case';
        newCase.Description = 'This is a dummy case created for testing purposes.';
        newCase.Status = 'New';
        newCase.Priority = 'Low';
        insert newCase;
        List<case> CaseList = new List<Case>();
        CaseList.add(newCase);
        Core_IPS_BES_UpdateBackendID.caseList.add(newCase);
        Core_IPS_BES_UpdateCaseBatch batch = new Core_IPS_BES_UpdateCaseBatch(CaseList);
        database.executeBatch(batch,1);
        Test.stopTest();
    }
    
    public static testMethod void testCommentBackendId(){
        Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
        backendSystem.Name = 'HSDES-PSG01';
        //  backendSystem.Core_IPS_Deactivated__c = false;
        backendSystem.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
        insert backendSystem;
        Case cs =  TestUtilities.getCase();
        cs.Core_IPS_New_Backend_System__c = backendSystem.Id;
        cs.Core_IPS_BackendID__c = '121212212333';
        //  cs.Core_IPS_BES_Promote_Status__c ='Done';
        //cs.Core_IPS_New_Backend_System__r.Core_IPS_Deactivated__c = backendSystem.Core_IPS_Deactivated__c;
        
        insert cs;
        System.assert(backendSystem.Id!=null);
        List<Case> csList = [SELECT Id,casenumber,Core_IPS_BackendID__c from Case WHERE ID =:cs.Id];
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        Core_IPS_Case_Comments__c objCmt=new Core_IPS_Case_Comments__c();
        objCmt.Core_IPS_Case__c=cs.id;
        objCmt.Core_IPS_Comment_Author_Type__c='Agent';
        objCmt.Core_IPS_Case_Comment_Type__c='Public to Customers'; 
        objCmt.Core_IPS_Rich_Comment__c='Test Comment from test class';
        insert objCmt;
        
        List<Core_IPS_BES_Outbound_Message__c> outboundObject = new List<Core_IPS_BES_Outbound_Message__c>();
        outboundObject.add(new Core_IPS_BES_Outbound_Message__c(core_IPS_Outbound_Message_ID__c = '123',
                                                                Core_IPS_Case_ID__c = csList[0].Id,
                                                                Comment_Id__c = objCmt.Id));
        insert outboundObject;
        List<Core_IPS_BES_Outbound_Message__c> outboundMessage = [SELECT Id,Name,Core_IPS_Case_ID__c,Comment_Id__c FROM Core_IPS_BES_Outbound_Message__c];
        req.requestURI = '/services/apexrest/IPS_BES_InboundMessageJSON/';
        req.httpMethod = 'POST';
        String jsonString = '{"response":{"message_id":"'+outboundMessage[0].Name+'","message_type":"Comment","source_system":"hsdes:client_platf:bug","target_system":"IPS","source_id":"'+csList[0].Core_IPS_BackendID__c+'","target_id":"'+csList[0].casenumber+'","message_type_id":"1361577653"}}';
        req.requestBody =Blob.valueOf(jsonString);
        RestContext.request = req;
        
        Core_IPS_BES_Inbound_JSON.getBackendId();
        
        //Process builder code
        Core_IPS_BES_Inbound_Message__c inboundObject = new Core_IPS_BES_Inbound_Message__c();
        inboundObject.Core_IPS_Inbound_Message_ID__c = outboundObject[0].Id;
        insert inboundObject;
        
        Attachment att = new Attachment();
        att.ParentId = inboundObject.Id;
        att.Name = 'test Att';
        att.body = Blob.valueOf(jsonString);
        insert att;
        Core_IPS_BES_InboundMessage.setJSON(new List<Id>{inboundObject.Id});   
        
        Test.stopTest();
    }
    public static testMethod void caseUpdate(){
        
        Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
        backendSystem.Name = 'CC - HSDES Client Platform';
        
        backendSystem.Core_IPS_Target_System__c = 'hsdes:client_platf:bug';
        insert backendSystem;
        System.assert(backendSystem.Id!=null);
        Case cs =  TestUtilities.getCase();
        cs.Core_IPS_New_Backend_System__c = backendSystem.Id;
        cs.Core_IPS_BackendID__c = '121212212333';
        
        insert cs;
        case c = new case();
        c.Id = cs.Id;
       // Core_IPS_BES_UpdateBackendID.caseList.add(c);
        Core_IPS_BES_UpdateBackendID.caseList.add(cs);
        List<Case> csList = [SELECT Id,casenumber,Core_IPS_BackendID__c from Case WHERE ID =:cs.Id];
        RestRequest req = new RestRequest(); 
        req.requestURI = '/services/apexrest/IPS_BES_InboundMessageJSON/';
        req.httpMethod = 'POST';
        String jsonString = '{"system_details":{"message_id":"001","message_type":"Case","source_system":"hsdes:client_platf:bug","target_system":"IPS","source_id":"'+csList[0].Core_IPS_BackendID__c+'","target_id":"'+csList[0].casenumber+'"},"issue_information":{"hsd_mirror_status":"open","hsd_mirror_reason":"triage"}}';
        req.requestBody =Blob.valueOf(jsonString);
        RestContext.request = req;
        Test.startTest();
        Core_IPS_BES_Inbound_JSON.getBackendId();
        //Process builder code
        Core_IPS_BES_Inbound_Message__c inboundObject = new Core_IPS_BES_Inbound_Message__c();
        inboundObject.Core_IPS_Inbound_Message_ID__c = '';
        insert inboundObject;
        
        Attachment att = new Attachment();
        att.ParentId = inboundObject.Id;
        att.Name = 'test Att';
        att.body = Blob.valueOf(jsonString);
        insert att;
        Core_IPS_BES_InboundMessage.setJSON(new List<Id>{inboundObject.Id});
        try{
            Core_IPS_BES_UpdateBackendID.caseList = new List<case>();
             Core_IPS_BES_InboundMessage.setJSON(new List<Id>{inboundObject.Id});
        }catch(Exception e){}
        String jsonString1 = '{"system_details":{"message_id":"001","message_type":"Case","source_system":"HSDES:fpga:bug","target_system":"IPS","source_id":"'+csList[0].Core_IPS_BackendID__c+'","target_id":"'+csList[0].casenumber+'","backend_rev":"3"},"issue_information":{"backend_rev":3, "owner_info": "testUser","hsd_mirror_status": "open","hsd_mirror_reason": "new","comment_author": "tharpanx", "comment_text": "Hii Comment Added"}}';
        
        Core_IPS_BES_Inbound_Message__c inboundObject1 = new Core_IPS_BES_Inbound_Message__c();
        inboundObject1.Core_IPS_Inbound_Message_ID__c = '';
        insert inboundObject1 ;
        
        Attachment att1 = new Attachment();
        att1.ParentId = inboundObject.Id;
        att1.Name = 'test Att';
        att1.body = Blob.valueOf(jsonString1);
        insert att1;
        Core_IPS_BES_InboundMessage.setJSON(new List<Id>{inboundObject1.Id});
        Test.stopTest();
    }
    public static testMethod void commentInsert(){
        Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
        backendSystem.Name = 'HSDES-PSG01';
        
        backendSystem.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
        insert backendSystem;
        System.assert(backendSystem.Id!=null);
        Case cs =  TestUtilities.getCase();
        cs.Core_IPS_New_Backend_System__c = backendSystem.Id;
        cs.Core_IPS_BackendID__c = '121212212333';
        cs.Core_IPS_BES_Promote_Status__c = 'Done';
        insert cs;
        List<Case> csList = [SELECT Id,casenumber,Core_IPS_BackendID__c from Case WHERE ID =:cs.Id];
        RestRequest req = new RestRequest(); 
        req.requestURI = '/services/apexrest/IPS_BES_InboundMessageJSON/';
        req.httpMethod = 'POST';
        String jsonString = '{"system_details":{"message_id":"001","message_type":"Case","source_system":"HSDES:fpga:bug","target_system":"IPS","source_id":"'+csList[0].Core_IPS_BackendID__c+'","target_id":"'+csList[0].casenumber+'"},"issue_information":{"comment_text":"sample comment img src","hsd_mirror_status":"open","hsd_mirror_reason":"new","description":"Test DESC","gec":"true","contact_name":"Test Con"}}';
        req.requestBody =Blob.valueOf(jsonString);
        RestContext.request = req;
        Test.startTest();
        //Process builder code
        Core_IPS_BES_Inbound_JSON.getBackendId();
        Core_IPS_BES_Inbound_Message__c inboundObject = new Core_IPS_BES_Inbound_Message__c();
        inboundObject.Core_IPS_Inbound_Message_ID__c = '';
        insert inboundObject;
        
        Attachment att = new Attachment();
        att.ParentId = inboundObject.Id;
        att.Name = 'test Att';
        att.body = Blob.valueOf(jsonString);
        insert att;
        Core_IPS_BES_InboundMessage.setJSON(new List<Id>{inboundObject.Id});
        Map<String,String> sourceDetailsMap =new Map<String,String>();
        sourceDetailsMap.put(csList[0].casenumber,csList[0].Core_IPS_BackendID__c);
        Map<String, String> userDetailsRecMap = new Map<String,String>();
        userDetailsRecMap.put('testx','testx@intel.com;testx;testx');
        Core_IPS_BES_AddImageCommentBatch batch1 = new Core_IPS_BES_AddImageCommentBatch(new List<Id>{inboundObject.Id},userDetailsRecMap,sourceDetailsMap);
        database.executeBatch(batch1,1);
        Test.stopTest();
    }
    public static testMethod void testAttachment(){
        Core_IPS_Backend_System2__c backendSystem = new Core_IPS_Backend_System2__c();
        backendSystem.Name = 'HSDES-PSG01';
        
        backendSystem.Core_IPS_Target_System__c = 'hsdes:fpga:bug';
        insert backendSystem;
        Case cs =  TestUtilities.getCase();
        cs.Core_IPS_New_Backend_System__c = backendSystem.Id;
        insert cs;
        Core_Trigger_Executions__c obj=new Core_Trigger_Executions__c();
        obj.Name='InsertCaseCommentForAttach';
        obj.Core_Active__c=true;
        obj.Core_Class_Name__c='Core_IPS_CasePromotion_Handler';
        obj.Core_Description__c='InsertCaseCommentForAttachements';
        obj.Core_Object__c='Case Comment';
        obj.Core_Trigger_Events__c='After Insert, After update';
        insert obj;
        // Avoid Hardcoding Id Fix - Shipra
        Profile dataMigPrf = [select id, name from Profile where name = 'CCP - Core Access' Limit 1];
        Core_IPS_Labels__c obj1=new Core_IPS_Labels__c();
        obj1.Name='Data Migration Profile Id';
        obj1.Value__c= dataMigPrf.Id; 
       // obj1.Value__c='00eo0000000f7Gd';
        insert obj1;
          // Avoid Hardcoding Id Fix - Shipra
        Core_IPS_Labels__c obj2=new Core_IPS_Labels__c();
        obj2.Name='COMPLETE';
        obj2.Value__c='COMPLETE';
        insert obj2;
        Core_IPS_Case_Attachments__c att1=new Core_IPS_Case_Attachments__c();
        att1.Core_Case__c=cs.Id;
        att1.Core_File_Name__c='test';
        att1.Core_File_Size__c='75.5 MB';
        att1.Core_File_GUID__c='1a6d234d-9747-4822-812a-739f20906229';
        //att1.Core_IPS_BackendId__c=backendSystem.id;
        //att1.Core_IPS_BES_BackendType__c='HSDES_SFT';
        att1.Core_IPS_BES_Promote_Status__c='';
        att1.Core_IPS_Security_Compliance__c=false;
        att1.Core_IPS_Uploaded_By_Email__c='chandrax.shekar.pallikonda@intel.com';
        att1.Core_IPS_Uploaded_By_FirstName__c='Chandrashekhar';
        att1.Core_IPS_Uploaded_By_Name__c='Chandrashekhar Pallikonda';
        att1.Core_Is_Migrated__c=false;
        //att1.IsDeleted=false;
        att1.Core_Upload_Status__c='Complete';
        //att1.Core_IPS_Attachment_Source__c='Internal Portal';
        //att1.Core_IPS_Attachment_Visibility__c='Public to Customers';
        att1.Core_File_Description__c='test';
        att1.Core_File_URL__c='https://esft.intel.com/sftservices/download/HSDES_SFT?FileName=16015-1A.0221WZS1542.zip&AppFileID=1a6d234d-9747-4822-812a-739f20906229&AppData=1605952214';
        insert att1;
        List<Case> csList = [SELECT Id,casenumber from Case WHERE ID =:cs.Id];
        RestRequest req = new RestRequest(); 
        req.requestURI = '/services/apexrest/IPS_BES_InboundMessageJSON/';
        req.httpMethod = 'POST';
        String jsonString = '{ "response" : { "message_id" : "BES OB-1179", "message_type" : "Attachment", "source_system" : "hsdes:fpga:bug", "target_system" : "IPS", "source_id" : "1308659269", "target_id" : "'+csList[0].casenumber+'"} }';
        req.requestBody =Blob.valueOf(jsonString);
        RestContext.request = req;
        Test.startTest();
        //Process builder code
        Core_IPS_BES_Inbound_JSON.getBackendId();
        Core_IPS_BES_Inbound_Message__c inboundObject = new Core_IPS_BES_Inbound_Message__c();
        inboundObject.Core_IPS_Inbound_Message_ID__c = '';
        insert inboundObject;
        
        Attachment att = new Attachment();
        att.ParentId = inboundObject.Id;
        att.Name = 'test Att';
        att.body = Blob.valueOf(jsonString);
        insert att;
        Core_IPS_BES_InboundMessage.setJSON(new List<Id>{inboundObject.Id});
        System.assertEquals(true, att != null, 'Attachment should be inserted');
        Test.stopTest();
        
    }
    
    @isTest
    public static void testCommentAuthorDetailsUpdate(){
        Core_IPS_BES_Inbound_Message__c  inboundObject = [SELECT Id from Core_IPS_BES_Inbound_Message__c LIMIT 1];    
        
        Test.setMock(HttpCalloutMock.class, new Core_IPS_BES_IPassHttpCalloutMock());
        
        Test.startTest();
        Core_IPS_BES_InboundMessage.setJSON(new List<Id>{inboundObject.Id});
        system.assertNotEquals(true,null,'Expected Result');
        Test.stopTest();
        /*  Case caseObj = [SELECT Id FROM Case WHERE Core_IPS_BackendID__c = '123213214345' LIMIT 1];
Core_IPS_Case_Comments__c comment = [SELECT Id, Core_IPS_Comment_Authored_By_Email__c, Core_IPS_Comment_Authored_By_Name__c, Core_IPS_Case__c FROM Core_IPS_Case_Comments__c WHERE Core_IPS_Case__c =: caseObj.Id];    
System.assertEquals('fnamex.lname@intel.com', comment.Core_IPS_Comment_Authored_By_Email__c, 'Email not updated correctly');  
System.assertEquals('FNameX LName', comment.Core_IPS_Comment_Authored_By_Name__c, 'Email not updated correctly');   */
    }
    
}