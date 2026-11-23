/********************************************************************************************************************
Apex Class Name:  Core_IPS_CasePromotion_Handler_Test
Version     : 1.0 
Created Date: 03 09 2015
Function    : Test class for Core_IPS_CasePromotion_Handler
Modification Log :
* Developer                             Date                   Description
* ----------------------------------------------------------------------------                 
* Kareem Unnisa                      03/09/2015              Original Version
* Shebin Kurian                      03/Feb/2016             Modification for code coverage
* Tanvi Chauhan                      26/May/2016             Modification for ReProcessBackendSystem code coverage
* Manoj Kumar                        06/Oct/2016             Modification for executeBackendFieldUpdate code coverage
* Manoj Kumar                        22/Mar/2017             Modified executeBackendRoutingTest method
*******************************************************************************************************************/

@isTest

Public class Core_IPS_CasePromotion_Handler_Test{
    static List<User> ListOfUser = new List<User> ();
    /****below methode is added to get coverage on issuecatorycriteria methodes by inserting single case record**********//****aswin*****/
    
    static testMethod void executeBackendRoutingTestissue()
    {
        List<Case> newList = new List<Case>();
        Map<Id,Case> newMap = new Map<Id, Case>();
        List<Case> oldList = new List<Case>();
        Map<Id, Case> oldMap = new Map<Id, Case>();
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        
        
        ListOfUser = TestUtilities.getListOfUser(10);
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert ListOfUser;
        system.assert(ListOfUser != null);
        if(ListOfUser<>null &&ListOfUser.size()<=10)
        {
            test.startTest();
            // start added by rajeswari for increase the code coverage 22 june 22
            Core_IPS_System_Credentails_Apigee__c label17 = new Core_IPS_System_Credentails_Apigee__c();
            label17.Name = 'Core_IPS_Case_Promote';
            label17.Core_IPS_EndPointURL__c = 'Test.org.com';
            insert label17;
            Core_IPS_System_Credentails_Apigee__c label18 = new Core_IPS_System_Credentails_Apigee__c();
            label18.Name = 'Core_IPS_Case_DePromote';
            label18.Core_IPS_EndPointURL__c = 'Test1.org.com';
            insert label18;
            
            Core_IPS_System_Credentails_Apigee__c label19 = new Core_IPS_System_Credentails_Apigee__c();
            label19.Name = 'Core_IPS_Case_FieldUpdate';
            label19.Core_IPS_EndPointURL__c = 'Test2.org.com';
            insert label19;
            
            Core_Trigger_Executions__c label20 =new Core_Trigger_Executions__c();
            label20.Name='myIntelIntegration';
            label20.Core_Active__c=true;
            label20.Core_Class_Name__c='Core_IPS_CaseTriggerHandler';
            label20.Core_Object__c='Case';
            label20.Core_Description__c='MyIntel 3.0';
            label20.Core_Trigger_Events__c='before update, after create';
            insert label20;
            Test.setMock(HttpCalloutMock.class, new IPS_APIGEE_BackendHttpCalloutMock());
            
            // end added by rajeswari for increase the code coverage 22 june 22
            
            List<Core_Trigger_Executions__c> triggerExecRecordList=new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c triggerExecRecord =new Core_Trigger_Executions__c(Core_Active__c=true,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This flag will allow to switch on and off the IPS Case Backend Routing',Core_Object__c='Case',Core_Trigger_Events__c='before insert, before update',Name='enableIPSCaseBackendRouting');
            Core_Trigger_Executions__c triggerExecRecord1 =new Core_Trigger_Executions__c(Core_Active__c=true,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This fl;ag allows to switch on and off IPS Case Attachment Backend Routing',Core_Object__c='Core_IPS_Case_Attachments__c',Core_Trigger_Events__c='after insert after update',Name='enableIPSCaseAttBackendRouting');
            Core_Trigger_Executions__c triggerExecRecord2 =new Core_Trigger_Executions__c(Core_Active__c=false,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This flag allows to switch on and off case comment trigger',Core_Object__c='Core_IPS_Case_Attachments__c',Core_Trigger_Events__c='before insert, before update',Name='enableIPSCaseCommentBackendRouting' );
            Core_Trigger_Executions__c triggerForResp =  new Core_Trigger_Executions__c(Core_Active__c = true,Name='updateEnvDetailsOnCaseFromCoreResponse',Core_Class_Name__c='Core_IPS_Response_Handler',Core_Description__c='This method is used to assign the Core_IPS_Answer__c Field on Core_IPS_Response__c Object From Core_IPS_Answer_Master__c Object',Core_Object__c='Core_IPS_Response__c',Core_Trigger_Events__c='Before Insert, Before Update');
            triggerExecRecordList.add(triggerExecRecord);
            triggerExecRecordList.add(triggerExecRecord1);
            triggerExecRecordList.add(triggerExecRecord2);
            triggerExecRecordList.add(triggerForResp);
            insert triggerExecRecordList;
            
            List<Core_IPSBackendPromoteReprocesing__c>configIdsList=new List<Core_IPSBackendPromoteReprocesing__c>();
            Core_IPSBackendPromoteReprocesing__c configIds=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='X',Name='OVERRIDE');
            Core_IPSBackendPromoteReprocesing__c configIds1=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='2015-08-13 00:00:00',Name='TODATE');
            Core_IPSBackendPromoteReprocesing__c configIds2=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='2015-08-12 00:00:00',Name='FROMDATE');
            configIdsList.add(configIds);
            configIdsList.add(configIds1);
            configIdsList.add(configIds2);
            insert configIdsList;
            case cs1=new Case();    
            
            List<Core_IPS_Product_Organization__c> suppOrgList = new List<Core_IPS_Product_Organization__c>();
            Core_IPS_Product_Organization__c suppOrg=Core_IPS_Backend_TestClass_Utility.getSupportOrg();
            Core_IPS_Product_Organization__c suppOrg1 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'dcg', Core_Organization_Description__c = 'Data Center Group'); 
            Core_IPS_Product_Organization__c suppOrg2 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'Ics', Core_Organization_Description__c = 'Intel customer Support');   
            Core_IPS_Product_Organization__c suppOrg3 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'Ics1', Core_Organization_Description__c = 'Intel customer Support1');   
            Core_IPS_Product_Organization__c suppOrg4 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'Ics2', Core_Organization_Description__c = 'Intel customer Support2');   
            suppOrgList.add(suppOrg);
            suppOrgList.add(suppOrg1);
            suppOrgList.add(suppOrg2);
            suppOrgList.add(suppOrg3);
            suppOrgList.add(suppOrg4);
            system.runas(ListOfUser[0])
            {
                insert suppOrgList; 
            }
            
            
            Id queRecordId= Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
            
            
            //Core_IPS_Environment_Variables__c eviSuppOrg= Core_IPS_Backend_TestClass_Utility.getEnvidetialsForSuppOrg();
            Core_IPS_Question__c envQuest =New Core_IPS_Question__c();
            envQuest.recordtypeId = queRecordId;
            envQuest.Core_IPS_Datatype__c = 'Text';
            envQuest.Core_IPS_Product_Organization__c = suppOrg.id;
            envQuest.Core_IPS_Question__c='operating system';
            //insert envQuest;
            
            //eviSuppOrg.Core_Product_Organization__c=suppOrg.id;
            
            
            Core_IPS_Question__c envQuest1 =New Core_IPS_Question__c();
            envQuest1.recordtypeId = queRecordId;
            envQuest1.Core_IPS_Datatype__c = 'Text';
            envQuest1.Core_IPS_Product_Organization__c = suppOrg.id;
            envQuest1.Core_IPS_Question__c='bkc_bsp_version';
            
            
            
            Core_IPS_Question__c envQuest2 =New Core_IPS_Question__c();
            envQuest2.recordtypeId = queRecordId;
            envQuest2.Core_IPS_Datatype__c = 'Text';
            envQuest2.Core_IPS_Product_Organization__c = suppOrg4.id;
            envQuest2.Core_IPS_Question__c='operating system';
            
            
            Core_IPS_Question__c envQuest3 =New Core_IPS_Question__c();
            envQuest2.recordtypeId = queRecordId;
            envQuest3.Core_IPS_Datatype__c = 'Text';
            envQuest3.Core_IPS_Product_Organization__c = suppOrg4.id;
            envQuest3.Core_IPS_Question__c='bkc_bsp_version';
            
            
            
            //List<Core_IPS_Environment_Variables__c> envList=new List<Core_IPS_Environment_Variables__c>();
            List<Core_IPS_Question__c> queList = new List<Core_IPS_Question__c>();
            queList.add(envQuest);
            queList.add(envQuest1);
            queList.add(envQuest2);
            queList.add(envQuest3);
            system.runas(ListOfUser[1])
            {
                insert queList;  
            }           
            
            Core_IPS_Answer__c answers =  new Core_IPS_Answer__c();
            answers.Core_IPS_Answer__c = 'chrome';
            answers.Core_IPS_Question__c =envQuest.id;
            answers.Core_IPS_Status__c = 'Active';
            
            Core_IPS_Answer__c answers1 =  new Core_IPS_Answer__c();
            answers1.Core_IPS_Answer__c = 'chrometest';
            answers1.Core_IPS_Question__c =envQuest1.id;
            answers1.Core_IPS_Status__c = 'Active';
            
            Core_IPS_Answer__c answers2 =  new Core_IPS_Answer__c();
            answers2.Core_IPS_Answer__c = 'chrome';
            answers2.Core_IPS_Question__c =envQuest2.id;
            answers2.Core_IPS_Status__c = 'Active';
            
            Core_IPS_Answer__c answers3 =  new Core_IPS_Answer__c();
            answers3.Core_IPS_Answer__c = 'chrometest';
            answers3.Core_IPS_Question__c =envQuest3.id;
            answers3.Core_IPS_Status__c = 'Active';
            
            List<Core_IPS_Answer__c> answerList = new list<Core_IPS_Answer__c>();
            answerList.add(answers);
            answerList.add(answers1);
            answerList.add(answers2);
            answerList.add(answers3);
            
            system.runas(ListOfUser[1])
            {
                insert answerList;  
            }           
            
            
            List<Product2> prodlist = new List<Product2>();
            
            
            Product2 prod4= new Product2(Name = 'SkyLake',Core_Sales_Visible_Flag__c = false, Core_IPS_Visible_Flag_External__c = true,IsActive = true );
            prod4.Core_Product_Org__c='IPS';
            
            prodList.add(prod4);
            system.runas(ListOfUser[3])
            {
                insert prodList;
            }
            
            List<Core_IPS_Supported_Product__c> suppProdList = new List<Core_IPS_Supported_Product__c>();
            
            
            Core_IPS_Supported_Product__c suppProd4 = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
            suppProd4.Core_Product__c=prod4.id;
            suppProd4.Core_Product_Organization__c=suppOrg4.id;
            suppProdList.add(suppProd4);
            
            
            system.runas(ListOfUser[4])
            {
                //insert suppProd;
                insert suppProdList;
            }
            
            Group testGroup = new Group(Name='test group', Type='Queue');
            insert testGroup;
            
            Core_IPS_Product_Issue_Category__c issueCat=Core_IPS_Backend_TestClass_Utility.getCategory();
            issueCat.Core_Supported_Product__c = suppProd4.id;
            
            System.runAs(ListOfUser[5])
            {
                QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
                insert testQueue;
                insert issueCat;
            }
            
            
            List<Core_IPS_Assigned_Environment_Variables__c> AssenvList = new List<Core_IPS_Assigned_Environment_Variables__c>();
            
            
            Core_IPS_Assigned_Environment_Variables__c AssEnv2=new Core_IPS_Assigned_Environment_Variables__c(Core_IPS_Question__c=envQuest2.Id,Core_Supported_Product__c=suppProd4.Id,Core_Product_Issue_Sub_Category__c=issueCat.id,Core_Type__c='Product');
            AssenvList.add(AssEnv2);
            
            Core_IPS_Assigned_Environment_Variables__c AssEnv3=new Core_IPS_Assigned_Environment_Variables__c(Core_IPS_Question__c=envQuest3.Id,Core_Supported_Product__c=suppProd4.Id,Core_Product_Issue_Sub_Category__c=issueCat.id, Core_Type__c='Product');
            AssenvList.add(AssEnv3);
            
            system.runas(ListOfUser[5])
            {
                insert AssEnvList;
            } 
            list<Core_IPS_Product_Issue_Category__c> issuList =  new list<Core_IPS_Product_Issue_Category__c >();           
            
            Core_IPS_Product_Issue_Category__c issueCat1=Core_IPS_Backend_TestClass_Utility.getCategory();
            issueCat1.Core_Supported_Product__c = suppProd4.id;
            issuList.add(issueCat1);
            system.runas(ListOfUser[6])
            {
                insert issuList; 
            }           
            
            List<Core_IPS_Backend_System__c> backendList = new List<Core_IPS_Backend_System__c>();
            
            
            Core_IPS_Backend_System__c backend3= Core_IPS_Backend_TestClass_Utility.getBackendSystem();
            backend3.name='test1111';
            backend3.Core_IPS_Routing_Technique__c = 'Product';
            backend3.Core_IPS_Support_Org__c=suppOrg4.id;
            backend3.Core_IPS_Support_Case_Field_Update__c=true;
            backendList.add(backend3);
            
            system.runas(ListOfUser[7])
            {
                insert backendList;
            }
            string bId = backend3.id;
            List<Core_IPSBackendPromoteReprocesing__c>configIdsList1=new List<Core_IPSBackendPromoteReprocesing__c>();
            Core_IPSBackendPromoteReprocesing__c configId1=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='Backend System',Core_Translate_Value__c=bId,Name=backend3.name);
            configIdsList1.add(configId1);
            insert configIdsList1;
            
            
            List <Core_IPS_Backend_Supported_Product_Map__c> backSPList = new List<Core_IPS_Backend_Supported_Product_Map__c>();
            
            Core_IPS_Backend_Supported_Product_Map__c back4= Core_IPS_Backend_TestClass_Utility.getBackendId();
            back4.Core_IPS_Supported_Product__c=suppProd4.id;
            back4.core_IPS_backend_System__c= backend3.id;
            back4.Core_IPS_Auto_Promote__c = true;
            backSpList.add(back4);
            
            system.runas(ListOfUser[8])
            {
                insert backSpList;
            }
            
            list<Core_IPS_Backend_Env_Details_Map__c > envMpList =  new list<Core_IPS_Backend_Env_Details_Map__c >();       
            
            
            Core_IPS_Backend_Env_Details_Map__c  backEnviMap1 =Core_IPS_Backend_TestClass_Utility.getBackendEnvironmentMap();
            
            // Question and answer
            backEnviMap1.Core_IPS_Backend_System__c=backend3.id; 
            backEnviMap1.Core_IPS_Backend_EnvQuestion__c=envQuest3.id;
            backEnviMap1.Core_IPS_Environment_Variable_Answer__c='chrometest';
            //backEnviMap1.Core_IPS_Backend_EnvQuestion__c=
            envMpList.add(backEnviMap1);
            
            
            system.runas(ListOfUser[9])
            {
                insert envMpList;
            }
            //--------------------------for checkIssueCategoriesCriteria----------------------
            Core_IPS_Master_Issue_Category__c masterIssueCat =Core_IPS_Backend_TestClass_Utility.getMasterIssueCategory();
            masterIssueCat.Name='Test'; //5th Feb- for check case external issue category name and master issue category name
            system.runas(ListOfUser[0])
            {
                insert masterIssueCat;
            }
            
            Core_IPS_Backend_Case_Categories_Map__c  backendCaseCate = Core_IPS_Backend_TestClass_Utility.getCaseCategories();
            backendCaseCate.Core_IPS_Case_Category__c=masterIssueCat.id;
            //commented below line by tchauhan
            //backendCaseCate.Core_IPS_Backend_SP_Map__c=back1.id;  
            backendCaseCate.Core_IPS_Backend_SP_Map__c = backSpList[0].id;
            system.runas(ListOfUser[1])
            {
                insert backendCaseCate;
            }
            
            
            
            RecordType rType =  [Select r.Name, r.DeveloperName,r.id From RecordType r where r.DeveloperName = 'Core_IPS_Case_Create_Self_Assigned' Limit 1];      
            
            
            
            
            
            Case cs15=new case();
            cs15.Core_IPS_Supported_Product__c= suppProd4.id;
            cs15.Core_IPS_Product_Org1__c=suppOrg4.id;
            cs15.productID=prod4.id;
            cs15.OwnerId = testGroup.Id;
            cs15.Core_severity__c= 'Low';
            cs15.recordtypeid=rType.id;
            cs15.Core_IPS_Restricted_Secret_Content__c = true;
            //Adding case Status and SubStatus -- Manoj Kumar
            cs15.Status='Open';
            cs15.Core_Sub_Status__c='Investigating';
            cs15.Core_Case_Issue_Category__c = issueCat1.id;
            cs15.Core_Case_Issue_Sub_Category__c = issueCat1.id;
            cs15.Core_External_Issue_Category__c = 'Test';
            
            system.runas(ListOfUser[3])
            {
                insert cs15;
            }
            
            
            
            Core_IPS_Response__c  cResp = new Core_IPS_Response__c ();
            cResp.Core_IPS_ANswer__c = 'chrome';
            cResp.Core_IPS_Question_Master__c = envQuest2.id;
            cResp.Core_IPS_Answer_Master__c = answers2.id;
            cResp.Core_IPS_Case__c =cs15.id; 
            
            Core_IPS_Response__c  cResp1 = new Core_IPS_Response__c ();
            cResp1.Core_IPS_ANswer__c = 'chrometest';
            cResp1.Core_IPS_Question_Master__c = envQuest3.id;
            cResp1.Core_IPS_Answer_Master__c = answers3.id;
            cResp1.Core_IPS_Case__c =cs15.id; 
            
            List<Core_IPS_Response__c> qResList =  new List<Core_IPS_Response__c>();
            
            
            qResList.add(cResp);
            qResList.add(cResp1);
            
            system.runas(ListOfUser[4])
            {
                insert qResList;
                
            }
            test.stopTest();
        }  
        
    }
    
    /***********environmnetal details diff**********/
    static testMethod void executeBackendRoutingTestissueEnv1()
    {
        List<Case> newList = new List<Case>();
        Map<Id,Case> newMap = new Map<Id, Case>();
        List<Case> oldList = new List<Case>();
        Map<Id, Case> oldMap = new Map<Id, Case>();
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        ListOfUser = TestUtilities.getListOfUser(10);
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert ListOfUser;
        system.assert(ListOfUser != null);
        if(ListOfUser<>null &&ListOfUser.size()<=10)
        {
            test.startTest();
            List<Core_Trigger_Executions__c> triggerExecRecordList=new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c triggerExecRecord =new Core_Trigger_Executions__c(Core_Active__c=true,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This flag will allow to switch on and off the IPS Case Backend Routing',Core_Object__c='Case',Core_Trigger_Events__c='before insert, before update',Name='enableIPSCaseBackendRouting');
            Core_Trigger_Executions__c triggerExecRecord1 =new Core_Trigger_Executions__c(Core_Active__c=true,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This fl;ag allows to switch on and off IPS Case Attachment Backend Routing',Core_Object__c='Core_IPS_Case_Attachments__c',Core_Trigger_Events__c='after insert after update',Name='enableIPSCaseAttBackendRouting');
            Core_Trigger_Executions__c triggerExecRecord2 =new Core_Trigger_Executions__c(Core_Active__c=false,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This flag allows to switch on and off case comment trigger',Core_Object__c='Core_IPS_Case_Attachments__c',Core_Trigger_Events__c='before insert, before update',Name='enableIPSCaseCommentBackendRouting' );
            Core_Trigger_Executions__c triggerForResp =  new Core_Trigger_Executions__c(Core_Active__c = true,Name='updateEnvDetailsOnCaseFromCoreResponse',Core_Class_Name__c='Core_IPS_Response_Handler',Core_Description__c='This method is used to assign the Core_IPS_Answer__c Field on Core_IPS_Response__c Object From Core_IPS_Answer_Master__c Object',Core_Object__c='Core_IPS_Response__c',Core_Trigger_Events__c='Before Insert, Before Update');
            triggerExecRecordList.add(triggerExecRecord);
            triggerExecRecordList.add(triggerExecRecord1);
            triggerExecRecordList.add(triggerExecRecord2);
            triggerExecRecordList.add(triggerForResp);
            insert triggerExecRecordList;
            
            List<Core_IPSBackendPromoteReprocesing__c>configIdsList=new List<Core_IPSBackendPromoteReprocesing__c>();
            Core_IPSBackendPromoteReprocesing__c configIds=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='X',Name='OVERRIDE');
            Core_IPSBackendPromoteReprocesing__c configIds1=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='2015-08-13 00:00:00',Name='TODATE');
            Core_IPSBackendPromoteReprocesing__c configIds2=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='2015-08-12 00:00:00',Name='FROMDATE');
            configIdsList.add(configIds);
            configIdsList.add(configIds1);
            configIdsList.add(configIds2);
            insert configIdsList;
            case cs1=new Case();    
            
            List<Core_IPS_Product_Organization__c> suppOrgList = new List<Core_IPS_Product_Organization__c>();
            Core_IPS_Product_Organization__c suppOrg=Core_IPS_Backend_TestClass_Utility.getSupportOrg();
            Core_IPS_Product_Organization__c suppOrg1 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'dcg', Core_Organization_Description__c = 'Data Center Group'); 
            Core_IPS_Product_Organization__c suppOrg2 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'Ics', Core_Organization_Description__c = 'Intel customer Support');   
            Core_IPS_Product_Organization__c suppOrg3 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'Ics1', Core_Organization_Description__c = 'Intel customer Support1');   
            Core_IPS_Product_Organization__c suppOrg4 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'Ics2', Core_Organization_Description__c = 'Intel customer Support2');   
            suppOrgList.add(suppOrg);
            suppOrgList.add(suppOrg1);
            suppOrgList.add(suppOrg2);
            suppOrgList.add(suppOrg3);
            suppOrgList.add(suppOrg4);
            system.runas(ListOfUser[0])
            {
                insert suppOrgList; 
            }
            
            
            Id queRecordId= Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
            
            
            //Core_IPS_Environment_Variables__c eviSuppOrg= Core_IPS_Backend_TestClass_Utility.getEnvidetialsForSuppOrg();
            Core_IPS_Question__c envQuest =New Core_IPS_Question__c();
            envQuest.recordtypeId = queRecordId;
            envQuest.Core_IPS_Datatype__c = 'Text';
            envQuest.Core_IPS_Product_Organization__c = suppOrg.id;
            envQuest.Core_IPS_Question__c='operating system';
            //insert envQuest;
            
            //eviSuppOrg.Core_Product_Organization__c=suppOrg.id;
            
            
            Core_IPS_Question__c envQuest1 =New Core_IPS_Question__c();
            envQuest1.recordtypeId = queRecordId;
            envQuest1.Core_IPS_Datatype__c = 'Text';
            envQuest1.Core_IPS_Product_Organization__c = suppOrg.id;
            envQuest1.Core_IPS_Question__c='bkc_bsp_version';
            
            
            
            Core_IPS_Question__c envQuest2 =New Core_IPS_Question__c();
            envQuest2.recordtypeId = queRecordId;
            envQuest2.Core_IPS_Datatype__c = 'Text';
            envQuest2.Core_IPS_Product_Organization__c = suppOrg4.id;
            envQuest2.Core_IPS_Question__c='operating system';
            
            
            Core_IPS_Question__c envQuest3 =New Core_IPS_Question__c();
            envQuest2.recordtypeId = queRecordId;
            envQuest3.Core_IPS_Datatype__c = 'Text';
            envQuest3.Core_IPS_Product_Organization__c = suppOrg4.id;
            envQuest3.Core_IPS_Question__c='bkc_bsp_version';
            
            
            
            //List<Core_IPS_Environment_Variables__c> envList=new List<Core_IPS_Environment_Variables__c>();
            List<Core_IPS_Question__c> queList = new List<Core_IPS_Question__c>();
            queList.add(envQuest);
            queList.add(envQuest1);
            queList.add(envQuest2);
            queList.add(envQuest3);
            system.runas(ListOfUser[1])
            {
                insert queList;  
            }           
            
            Core_IPS_Answer__c answers =  new Core_IPS_Answer__c();
            answers.Core_IPS_Answer__c = 'chrome';
            answers.Core_IPS_Question__c =envQuest.id;
            answers.Core_IPS_Status__c = 'Active';
            
            Core_IPS_Answer__c answers1 =  new Core_IPS_Answer__c();
            answers1.Core_IPS_Answer__c = 'chrometest';
            answers1.Core_IPS_Question__c =envQuest1.id;
            answers1.Core_IPS_Status__c = 'Active';
            
            Core_IPS_Answer__c answers2 =  new Core_IPS_Answer__c();
            answers2.Core_IPS_Answer__c = 'chrome';
            answers2.Core_IPS_Question__c =envQuest2.id;
            answers2.Core_IPS_Status__c = 'Active';
            
            Core_IPS_Answer__c answers3 =  new Core_IPS_Answer__c();
            answers3.Core_IPS_Answer__c = 'chrometest';
            answers3.Core_IPS_Question__c =envQuest3.id;
            answers3.Core_IPS_Status__c = 'Active';
            
            List<Core_IPS_Answer__c> answerList = new list<Core_IPS_Answer__c>();
            answerList.add(answers);
            answerList.add(answers1);
            answerList.add(answers2);
            answerList.add(answers3);
            
            system.runas(ListOfUser[1])
            {
                insert answerList;  
            }           
            
            
            List<Product2> prodlist = new List<Product2>();
            
            
            Product2 prod4= new Product2(Name = 'SkyLake',Core_Sales_Visible_Flag__c = false, Core_IPS_Visible_Flag_External__c = true,IsActive = true );
            prod4.Core_Product_Org__c='IPS';
            
            prodList.add(prod4);
            system.runas(ListOfUser[3])
            {
                insert prodList;
            }
            
            List<Core_IPS_Supported_Product__c> suppProdList = new List<Core_IPS_Supported_Product__c>();
            
            
            Core_IPS_Supported_Product__c suppProd4 = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
            suppProd4.Core_Product__c=prod4.id;
            suppProd4.Core_Product_Organization__c=suppOrg4.id;
            suppProdList.add(suppProd4);
            
            
            system.runas(ListOfUser[4])
            {
                //insert suppProd;
                insert suppProdList;
            }
            
            Group testGroup = new Group(Name='test group', Type='Queue');
            insert testGroup;
            
            Core_IPS_Product_Issue_Category__c issueCat=Core_IPS_Backend_TestClass_Utility.getCategory();
            issueCat.Core_Supported_Product__c = suppProd4.id;
            
            System.runAs(ListOfUser[5])
            {
                QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
                insert testQueue;
                insert issueCat;
            }
            
            
            List<Core_IPS_Assigned_Environment_Variables__c> AssenvList = new List<Core_IPS_Assigned_Environment_Variables__c>();
            
            
            Core_IPS_Assigned_Environment_Variables__c AssEnv2=new Core_IPS_Assigned_Environment_Variables__c(Core_IPS_Question__c=envQuest2.Id,Core_Supported_Product__c=suppProd4.Id,Core_Product_Issue_Sub_Category__c=issueCat.id,Core_Type__c='Product');
            AssenvList.add(AssEnv2);
            
            Core_IPS_Assigned_Environment_Variables__c AssEnv3=new Core_IPS_Assigned_Environment_Variables__c(Core_IPS_Question__c=envQuest3.Id,Core_Supported_Product__c=suppProd4.Id,Core_Product_Issue_Sub_Category__c=issueCat.id, Core_Type__c='Product');
            AssenvList.add(AssEnv3);
            
            system.runas(ListOfUser[5])
            {
                insert AssEnvList;
            } 
            list<Core_IPS_Product_Issue_Category__c> issuList =  new list<Core_IPS_Product_Issue_Category__c >();           
            
            Core_IPS_Product_Issue_Category__c issueCat1=Core_IPS_Backend_TestClass_Utility.getCategory();
            issueCat1.Core_Supported_Product__c = suppProd4.id;
            issuList.add(issueCat1);
            system.runas(ListOfUser[6])
            {
                insert issuList; 
            }           
            
            List<Core_IPS_Backend_System__c> backendList = new List<Core_IPS_Backend_System__c>();
            
            
            Core_IPS_Backend_System__c backend3= Core_IPS_Backend_TestClass_Utility.getBackendSystem();
            backend3.name='test1111';
            backend3.Core_IPS_Routing_Technique__c = 'Product';
            backend3.Core_IPS_Support_Org__c=suppOrg4.id;
            backend3.Core_IPS_Support_Case_Field_Update__c=true;
            backendList.add(backend3);
            
            system.runas(ListOfUser[7])
            {
                insert backendList;
            }
            string bId = backend3.id;
            List<Core_IPSBackendPromoteReprocesing__c>configIdsList1=new List<Core_IPSBackendPromoteReprocesing__c>();
            Core_IPSBackendPromoteReprocesing__c configId1=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='Backend System',Core_Translate_Value__c=bId,Name=backend3.name);
            configIdsList1.add(configId1);
            insert configIdsList1;
            
            
            List <Core_IPS_Backend_Supported_Product_Map__c> backSPList = new List<Core_IPS_Backend_Supported_Product_Map__c>();
            
            Core_IPS_Backend_Supported_Product_Map__c back4= Core_IPS_Backend_TestClass_Utility.getBackendId();
            back4.Core_IPS_Supported_Product__c=suppProd4.id;
            back4.core_IPS_backend_System__c= backend3.id;
            back4.Core_IPS_Auto_Promote__c = true;
            backSpList.add(back4);
            
            system.runas(ListOfUser[8])
            {
                insert backSpList;
            }
            
            list<Core_IPS_Backend_Env_Details_Map__c > envMpList =  new list<Core_IPS_Backend_Env_Details_Map__c >();       
            
            
            Core_IPS_Backend_Env_Details_Map__c  backEnviMap1 =Core_IPS_Backend_TestClass_Utility.getBackendEnvironmentMap();
            
            // Question and answer
            backEnviMap1.Core_IPS_Backend_System__c=backend3.id; 
            backEnviMap1.Core_IPS_Backend_EnvQuestion__c=envQuest3.id;
            backEnviMap1.Core_IPS_Environment_Variable_Answer__c='chrometest';
            //backEnviMap1.Core_IPS_Backend_EnvQuestion__c=
            envMpList.add(backEnviMap1);
            
            
            system.runas(ListOfUser[9])
            {
                insert envMpList;
            }
            //--------------------------for checkIssueCategoriesCriteria----------------------
            Core_IPS_Master_Issue_Category__c masterIssueCat =Core_IPS_Backend_TestClass_Utility.getMasterIssueCategory();
            masterIssueCat.Name='Test'; //5th Feb- for check case external issue category name and master issue category name
            system.runas(ListOfUser[0])
            {
                insert masterIssueCat;
            }
            
            Core_IPS_Backend_Case_Categories_Map__c  backendCaseCate = Core_IPS_Backend_TestClass_Utility.getCaseCategories();
            backendCaseCate.Core_IPS_Case_Category__c=masterIssueCat.id;
            //commented below line by tchauhan
            //backendCaseCate.Core_IPS_Backend_SP_Map__c=back1.id;  
            backendCaseCate.Core_IPS_Backend_SP_Map__c = backSpList[0].id;
            system.runas(ListOfUser[1])
            {
                //insert backendCaseCate;
            }
            
            
            
            RecordType rType =  [Select r.Name, r.DeveloperName,r.id From RecordType r where r.DeveloperName = 'Core_IPS_Case_Create_Self_Assigned' Limit 1];      
            
            
            
            
            
            Case cs15=new case();
            cs15.Core_IPS_Supported_Product__c= suppProd4.id;
            cs15.Core_IPS_Product_Org1__c=suppOrg4.id;
            cs15.productID=prod4.id;
            cs15.OwnerId = testGroup.Id;
            cs15.Core_severity__c= 'Low';
            cs15.recordtypeid=rType.id;
            cs15.Core_IPS_Restricted_Secret_Content__c = true;
            //Adding case Status and SubStatus -- Manoj Kumar
            cs15.Status='Open';
            cs15.Core_Sub_Status__c='Investigating';
            cs15.Core_Case_Issue_Category__c = issueCat1.id;
            cs15.Core_Case_Issue_Sub_Category__c = issueCat1.id;
            cs15.Core_External_Issue_Category__c = 'Test';
            
            system.runas(ListOfUser[3])
            {
                insert cs15;
            }
            
            
            
            
            
            
            Core_IPS_Response__c  cResp = new Core_IPS_Response__c ();
            //cResp.Core_IPS_ANswer__c = 'chrome';
            cResp.Core_IPS_Question_Master__c = envQuest2.id;
            cResp.Core_IPS_Answer_Master__c = answers2.id;
            cResp.Core_IPS_Case__c =cs15.id; 
            
            Core_IPS_Response__c  cResp1 = new Core_IPS_Response__c ();
            //cResp1.Core_IPS_ANswer__c = 'chrometest';
            cResp1.Core_IPS_Question_Master__c = envQuest3.id;
            cResp1.Core_IPS_Answer_Master__c = answers3.id;
            cResp1.Core_IPS_Case__c =cs15.id; 
            
            List<Core_IPS_Response__c> qResList =  new List<Core_IPS_Response__c>();
            
            
            qResList.add(cResp);
            qResList.add(cResp1);
            
            system.runas(ListOfUser[4])
            {
                insert qResList;
                
            }
            test.stopTest();
        }  
        
    }
    
    
    
    /***********************below methodes are already existing**********************/
    
    /*****************************************************************************************************************************************
******************************************************************************************************************************************/
    /******Commented to optimize executeBackendRoutingTest method for increasing 'Core_IPS_CasePromotion_Handler' code coverage -- Manoj 3/22/2017**/
    
    static testMethod void executeBackendRoutingTest()
    {
        List<Case> newList = new List<Case>();
        Map<Id,Case> newMap = new Map<Id, Case>();
        List<Case> oldList = new List<Case>();
        Map<Id, Case> oldMap = new Map<Id, Case>();
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        ListOfUser = TestUtilities.getListOfUser(10);
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert ListOfUser;
        if(ListOfUser<>null &&ListOfUser.size()<=10)
        {
            // start added by rajeswari for increase the code coverage 22 june 22
            Core_IPS_System_Credentails_Apigee__c label16 = new Core_IPS_System_Credentails_Apigee__c();
            label16.Name = 'Core_IPS_CaseComment_Update';
            label16.Core_IPS_EndPointURL__c = 'Test.org.com';
            insert label16;
            
            Core_IPS_System_Credentails_Apigee__c label17 = new Core_IPS_System_Credentails_Apigee__c();
            label17.Name = 'Core_IPS_Case_Promote';
            label17.Core_IPS_EndPointURL__c = 'Test.org.com';
            insert label17;
            Core_IPS_System_Credentails_Apigee__c label18 = new Core_IPS_System_Credentails_Apigee__c();
            label18.Name = 'Core_IPS_Case_DePromote';
            label18.Core_IPS_EndPointURL__c = 'Test1.org.com';
            insert label18;
            
            Core_IPS_System_Credentails_Apigee__c label19 = new Core_IPS_System_Credentails_Apigee__c();
            label19.Name = 'Core_IPS_Case_FieldUpdate';
            label19.Core_IPS_EndPointURL__c = 'Test2.org.com';
            insert label19;
            
            Core_Trigger_Executions__c label20 =new Core_Trigger_Executions__c();
            label20.Name='myIntelIntegration';
            label20.Core_Active__c=true;
            label20.Core_Class_Name__c='Core_IPS_CaseTriggerHandler';
            label20.Core_Object__c='Case';
            label20.Core_Description__c='MyIntel 3.0';
            label20.Core_Trigger_Events__c='before update, after create';
            insert label20;
            Test.setMock(HttpCalloutMock.class, new IPS_APIGEE_BackendHttpCalloutMock());
            
            // end added by rajeswari for increase the code coverage 22 june 22
            List<Core_Trigger_Executions__c> triggerExecRecordList=new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c triggerExecRecord =new Core_Trigger_Executions__c(Core_Active__c=true,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This flag will allow to switch on and off the IPS Case Backend Routing',Core_Object__c='Case',Core_Trigger_Events__c='before insert, before update',Name='enableIPSCaseBackendRouting');
            Core_Trigger_Executions__c triggerExecRecord1 =new Core_Trigger_Executions__c(Core_Active__c=true,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This fl;ag allows to switch on and off IPS Case Attachment Backend Routing',Core_Object__c='Core_IPS_Case_Attachments__c',Core_Trigger_Events__c='after insert after update',Name='enableIPSCaseAttBackendRouting');
            Core_Trigger_Executions__c triggerExecRecord2 =new Core_Trigger_Executions__c(Core_Active__c=false,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This flag allows to switch on and off case comment trigger',Core_Object__c='Core_IPS_Case_Attachments__c',Core_Trigger_Events__c='before insert, before update',Name='enableIPSCaseCommentBackendRouting' );
            Core_Trigger_Executions__c triggerForResp =  new Core_Trigger_Executions__c(Core_Active__c = true,Name='updateEnvDetailsOnCaseFromCoreResponse',Core_Class_Name__c='Core_IPS_Response_Handler',Core_Description__c='This method is used to assign the Core_IPS_Answer__c Field on Core_IPS_Response__c Object From Core_IPS_Answer_Master__c Object',Core_Object__c='Core_IPS_Response__c',Core_Trigger_Events__c='Before Insert, Before Update');
            triggerExecRecordList.add(triggerForResp);
            triggerExecRecordList.add(triggerExecRecord);
            triggerExecRecordList.add(triggerExecRecord1);
            triggerExecRecordList.add(triggerExecRecord2);
            
            insert triggerExecRecordList;
            
            List<Core_IPSBackendPromoteReprocesing__c>configIdsList=new List<Core_IPSBackendPromoteReprocesing__c>();
            Core_IPSBackendPromoteReprocesing__c configIds=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='X',Name='OVERRIDE');
            Core_IPSBackendPromoteReprocesing__c configIds1=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='2015-08-13 00:00:00',Name='TODATE');
            Core_IPSBackendPromoteReprocesing__c configIds2=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='2015-08-12 00:00:00',Name='FROMDATE');
            configIdsList.add(configIds);
            configIdsList.add(configIds1);
            configIdsList.add(configIds2);
            insert configIdsList;
            system.assert(configIdsList != null);
            case cs1=new Case();    
            
            List<Core_IPS_Product_Organization__c> suppOrgList = new List<Core_IPS_Product_Organization__c>();
            Core_IPS_Product_Organization__c suppOrg=Core_IPS_Backend_TestClass_Utility.getSupportOrg();
            Core_IPS_Product_Organization__c suppOrg1 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'dcg', Core_Organization_Description__c = 'Data Center Group'); 
            Core_IPS_Product_Organization__c suppOrg2 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'Ics', Core_Organization_Description__c = 'Intel customer Support');   
            Core_IPS_Product_Organization__c suppOrg3 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'Ics1', Core_Organization_Description__c = 'Intel customer Support1');   
            Core_IPS_Product_Organization__c suppOrg4 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'Ics2', Core_Organization_Description__c = 'Intel customer Support2');   
            suppOrgList.add(suppOrg);
            suppOrgList.add(suppOrg1);
            suppOrgList.add(suppOrg2);
            suppOrgList.add(suppOrg3);
            suppOrgList.add(suppOrg4);
            system.runas(ListOfUser[0])
            {
                insert suppOrgList; 
            }
            
            
            
            Id queRecordId= Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
            
            
            Core_IPS_Question__c envQuest =New Core_IPS_Question__c();
            envQuest.recordtypeId = queRecordId;
            envQuest.Core_IPS_Datatype__c = 'Text';
            envQuest.Core_IPS_Product_Organization__c = suppOrg.id;
            envQuest.Core_IPS_Question__c='operating system';
            
            
            
            
            Core_IPS_Question__c envQuest1 =New Core_IPS_Question__c();
            envQuest1.recordtypeId = queRecordId;
            envQuest1.Core_IPS_Datatype__c = 'Text';
            envQuest1.Core_IPS_Product_Organization__c = suppOrg.id;
            envQuest1.Core_IPS_Question__c='bkc_bsp_version';
            
            
            
            Core_IPS_Question__c envQuest2 =New Core_IPS_Question__c();
            envQuest2.recordtypeId = queRecordId;
            envQuest2.Core_IPS_Datatype__c = 'Text';
            envQuest2.Core_IPS_Product_Organization__c = suppOrg4.id;
            envQuest2.Core_IPS_Question__c='operating system';
            
            
            Core_IPS_Question__c envQuest3 =New Core_IPS_Question__c();
            envQuest2.recordtypeId = queRecordId;
            envQuest3.Core_IPS_Datatype__c = 'Text';
            envQuest3.Core_IPS_Product_Organization__c = suppOrg4.id;
            envQuest3.Core_IPS_Question__c='bkc_bsp_version';
            
            
            //List<Core_IPS_Environment_Variables__c> envList=new List<Core_IPS_Environment_Variables__c>();
            List<Core_IPS_Question__c> queList = new List<Core_IPS_Question__c>();
            queList.add(envQuest);
            queList.add(envQuest1);
            queList.add(envQuest2);
            queList.add(envQuest3);
            system.runas(ListOfUser[1])
            {
                insert queList;  
            }           
            
            Core_IPS_Answer__c answers =  new Core_IPS_Answer__c();
            answers.Core_IPS_Answer__c = 'chrome';
            answers.Core_IPS_Question__c =envQuest.id;
            answers.Core_IPS_Status__c = 'Active';
            
            Core_IPS_Answer__c answers1 =  new Core_IPS_Answer__c();
            answers1.Core_IPS_Answer__c = 'chrometest';
            answers1.Core_IPS_Question__c =envQuest1.id;
            answers1.Core_IPS_Status__c = 'Active';
            
            Core_IPS_Answer__c answers2 =  new Core_IPS_Answer__c();
            answers2.Core_IPS_Answer__c = 'chrome';
            answers2.Core_IPS_Question__c =envQuest2.id;
            answers2.Core_IPS_Status__c = 'Active';
            
            Core_IPS_Answer__c answers3 =  new Core_IPS_Answer__c();
            answers3.Core_IPS_Answer__c = 'chrometest';
            answers3.Core_IPS_Question__c =envQuest3.id;
            answers3.Core_IPS_Status__c = 'Active';
            
            List<Core_IPS_Answer__c> answerList = new list<Core_IPS_Answer__c>();
            answerList.add(answers);
            answerList.add(answers1);
            answerList.add(answers2);
            answerList.add(answers3);
            
            system.runas(ListOfUser[1])
            {
                insert answerList;  
            }           
            
            
            
            List<Product2> prodlist = new List<Product2>();
            Product2 prod=Core_IPS_Backend_TestClass_Utility.getProduct();
            prod.Core_Product_Org__c='IPS'; //3rd Feb 2016--Validation if we make IPS Flag visible without setting Core_Product_Org__c='IPS'
            Product2 prod1 = new Product2(Name = 'sofia',Core_Sales_Visible_Flag__c = false, Core_IPS_Visible_Flag_External__c = true,IsActive = true );
            prod1.Core_Product_Org__c='IPS';
            Product2 prod2 = new Product2(Name = 'Kits',Core_Sales_Visible_Flag__c = false, Core_IPS_Visible_Flag_External__c = true,IsActive = true );
            prod2.Core_Product_Org__c='IPS';
            Product2 prod3 = new Product2(Name = 'Server',Core_Sales_Visible_Flag__c = false, Core_IPS_Visible_Flag_External__c = true,IsActive = true );
            prod3.Core_Product_Org__c='IPS';
            Product2 prod4= new Product2(Name = 'SkyLake',Core_Sales_Visible_Flag__c = false, Core_IPS_Visible_Flag_External__c = true,IsActive = true );
            prod4.Core_Product_Org__c='IPS';
            prodList.add(prod);
            prodList.add(prod1);
            prodList.add(prod2);
            prodList.add(prod3);
            prodList.add(prod4);
            system.runas(ListOfUser[3])
            {
                insert prodList;
            }
            
            List<Core_IPS_Supported_Product__c> suppProdList = new List<Core_IPS_Supported_Product__c>();
            Core_IPS_Supported_Product__c suppProd = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
            suppProd.Core_Product__c=prod.id;
            suppProd.Core_Product_Organization__c=suppOrg.id;
            suppProdList.add(suppProd);
            
            Core_IPS_Supported_Product__c suppProd1 = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
            suppProd1.Core_Product__c=prod1.id;
            suppProd1.Core_Product_Organization__c=suppOrg1.id;
            suppProdList.add(suppProd1);  
            
            Core_IPS_Supported_Product__c suppProd2 = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
            suppProd2.Core_Product__c=prod2.id;
            suppProd2.Core_Product_Organization__c=suppOrg2.id;
            suppProdList.add(suppProd2); 
            
            Core_IPS_Supported_Product__c suppProd3 = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
            suppProd3.Core_Product__c=prod3.id;
            suppProd3.Core_Product_Organization__c=suppOrg3.id;
            suppProdList.add(suppProd3);
            
            Core_IPS_Supported_Product__c suppProd4 = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
            suppProd4.Core_Product__c=prod4.id;
            suppProd4.Core_Product_Organization__c=suppOrg4.id;
            suppProdList.add(suppProd4);
            
            
            system.runas(ListOfUser[4])
            {
                //insert suppProd;
                insert suppProdList;
            }
            
            Group testGroup = new Group(Name='test group', Type='Queue');
            insert testGroup;
            
            System.runAs(ListOfUser[5])
            {
                QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
                insert testQueue;
            }
            
            
            List<Core_IPS_Assigned_Environment_Variables__c> AssenvList = new List<Core_IPS_Assigned_Environment_Variables__c>();
            Core_IPS_Assigned_Environment_Variables__c AssEnv=new Core_IPS_Assigned_Environment_Variables__c(Core_IPS_Question__c=envQuest.Id,Core_Supported_Product__c=suppProd.Id, Core_Type__c='Product');
            AssenvList.add(AssEnv);
            Core_IPS_Assigned_Environment_Variables__c AssEnv1=new Core_IPS_Assigned_Environment_Variables__c(Core_IPS_Question__c=envQuest1.Id,Core_Supported_Product__c=suppProd.Id, Core_Type__c='Product');
            AssenvList.add(AssEnv1);
            
            Core_IPS_Assigned_Environment_Variables__c AssEnv2=new Core_IPS_Assigned_Environment_Variables__c(Core_IPS_Question__c=envQuest2.Id,Core_Supported_Product__c=suppProd4.Id, Core_Type__c='Product');
            AssenvList.add(AssEnv2);
            
            system.runas(ListOfUser[5])
            {
                insert AssEnvList;
            } 
            list<Core_IPS_Product_Issue_Category__c> issuList =  new list<Core_IPS_Product_Issue_Category__c >();           
            Core_IPS_Product_Issue_Category__c issueCat=Core_IPS_Backend_TestClass_Utility.getCategory();
            issueCat.Core_Supported_Product__c = suppProd.id;
            issuList.add(issueCat);
            Core_IPS_Product_Issue_Category__c issueCat1=Core_IPS_Backend_TestClass_Utility.getCategory();
            issueCat1.Core_Supported_Product__c = suppProd4.id;
            issuList.add(issueCat1);
            system.runas(ListOfUser[6])
            {
                insert issuList; 
            }           
            
            List<Core_IPS_Backend_System__c> backendList = new List<Core_IPS_Backend_System__c>();
            Core_IPS_Backend_System__c backend= Core_IPS_Backend_TestClass_Utility.getBackendSystem();
            backend.Core_IPS_Routing_Technique__c = 'Product';
            backend.name='test';
            backend.Core_IPS_Support_Org__c=suppOrg.id;
            backend.Core_IPS_Support_Case_Field_Update__c=true;
            backendList.add(backend);
            
            Core_IPS_Backend_System__c backend1= Core_IPS_Backend_TestClass_Utility.getBackendSystem();
            backend1.name='test111';
            backend1.Core_IPS_Routing_Technique__c = 'Product';
            backend1.Core_IPS_Support_Org__c=suppOrg1.id;
            backend1.Core_IPS_Support_Case_Field_Update__c=true;
            backendList.add(backend1); 
            
            Core_IPS_Backend_System__c backend2= Core_IPS_Backend_TestClass_Utility.getBackendSystem();
            backend2.name='testQueue';
            backend2.Core_IPS_Routing_Technique__c = 'Queue';
            //backend2.Core_IPS_Support_Org__c=suppOrg2.id;
            backend2.Core_IPS_Support_Case_Field_Update__c=true;
            backendList.add(backend2);
            
            system.runas(ListOfUser[7])
            {
                insert backendList;
            }
            string bid = backend.id;
            string b1id = backend1.id;
            string b2id = backend2.id;
            List<Core_IPSBackendPromoteReprocesing__c>configIdsList1=new List<Core_IPSBackendPromoteReprocesing__c>();
            Core_IPSBackendPromoteReprocesing__c configId1=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='Backend System',Core_Translate_Value__c=bid ,Name=backend.name);
            Core_IPSBackendPromoteReprocesing__c configId2=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='Backend System',Core_Translate_Value__c=b1id ,Name=backend1.name);
            Core_IPSBackendPromoteReprocesing__c configId3=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='Backend System',Core_Translate_Value__c=b2id ,Name=backend2.name);
            
            configIdsList1.add(configId1);
            configIdsList1.add(configId2);
            configIdsList1.add(configId3);
            insert configIdsList1;
            
            List <Core_IPS_Backend_Supported_Product_Map__c> backSPList = new List<Core_IPS_Backend_Supported_Product_Map__c>();
            Core_IPS_Backend_Supported_Product_Map__c back= Core_IPS_Backend_TestClass_Utility.getBackendId();
            back.Core_IPS_Supported_Product__c=suppProd.id;
            back.core_IPS_backend_System__c= backend.id;
            backSpList.add(back);
            
            Core_IPS_Backend_Supported_Product_Map__c back1= Core_IPS_Backend_TestClass_Utility.getBackendId();
            back1.Core_IPS_Supported_Product__c=suppProd1.id;
            back1.core_IPS_backend_System__c= backend1.id;
            back1.Core_IPS_Auto_Promote__c = false;
            backSpList.add(back1); 
            
            Core_IPS_Backend_Supported_Product_Map__c back2= Core_IPS_Backend_TestClass_Utility.getBackendId();
            //back2.Core_IPS_Supported_Product__c=suppProd1.id;
            back2.core_IPS_backend_System__c= backend2.id;
            back2.Core_IPS_Auto_Promote__c = false;
            back2.Core_IPS_Queue__c = 'test group';
            backSpList.add(back2);
            
            Core_IPS_Backend_Supported_Product_Map__c back3= Core_IPS_Backend_TestClass_Utility.getBackendId();
            //back2.Core_IPS_Supported_Product__c=suppProd1.id;
            back3.core_IPS_backend_System__c= backend2.id;
            back3.Core_IPS_Auto_Promote__c = false;
            back3.Core_IPS_Queue__c = 'test group';
            back3.Core_IPS_Default__c= true;
            backSpList.add(back3);
            
            
            
            system.runas(ListOfUser[8])
            {
                insert backSpList;
            }
            
            list<Core_IPS_Backend_Env_Details_Map__c > envMpList =  new list<Core_IPS_Backend_Env_Details_Map__c >();       
            Core_IPS_Backend_Env_Details_Map__c  backEnviMap =Core_IPS_Backend_TestClass_Utility.getBackendEnvironmentMap();
            
            // Question and answer
            backEnviMap.Core_IPS_Backend_System__c=backend.id; 
            backEnviMap.Core_IPS_Backend_EnvQuestion__c=envQuest.id;
            backEnviMap.Core_IPS_Environment_Variable_Answer__c='chrome';
            envMpList.add(backEnviMap);
            
            
            system.runas(ListOfUser[9])
            {
                insert envMpList;
            }
            //--------------------------for checkIssueCategoriesCriteria----------------------
            Core_IPS_Master_Issue_Category__c masterIssueCat =Core_IPS_Backend_TestClass_Utility.getMasterIssueCategory();
            masterIssueCat.Name='Test'; //5th Feb- for check case external issue category name and master issue category name
            system.runas(ListOfUser[0])
            {
                insert masterIssueCat;
            }
            
            Core_IPS_Backend_Case_Categories_Map__c  backendCaseCate = Core_IPS_Backend_TestClass_Utility.getCaseCategories();
            backendCaseCate.Core_IPS_Case_Category__c=masterIssueCat.id;
            //commented below line by tchauhan
            //backendCaseCate.Core_IPS_Backend_SP_Map__c=back1.id;  
            backendCaseCate.Core_IPS_Backend_SP_Map__c = backSpList[0].id;
            system.runas(ListOfUser[1])
            {
                insert backendCaseCate;
            }
            
            List<Core_IPS_Backend_Case_Categories_Map__c>  backendCaseCateList = new List<Core_IPS_Backend_Case_Categories_Map__c>();
            backendCaseCateList.add(backendCaseCate);
            
            RecordType rType =  [Select r.Name, r.DeveloperName,r.id From RecordType r where r.DeveloperName = 'Core_IPS_Case_Create_Self_Assigned' Limit 1];      
            
            Asset  Asst=new Asset(Core_Supported_Product__c=suppProd.id,Core_Product_Organization__c=suppOrg.id,Name='Asset1') ;
            system.runas(ListOfUser[2])
            {
                insert  Asst;  //For case is attached with asset
            }
            
            Case cs3=new case();
            cs3.assetid=Asst.id;
            cs3.recordtypeid=rType.id;
            
            Case cs4=new case();
            cs4.Core_IPS_Supported_Product__c= suppProd.id;
            cs4.Core_IPS_Product_Org1__c=suppOrg.id;
            cs4.productID=prod.id;
            cs4.Core_Case_Issue_Category__c = issueCat.id;
            cs4.Core_Case_Issue_Sub_Category__c = issueCat.id;
            cs4.Core_External_Issue_Category__c = 'Test';            
            cs4.Core_IPS_Backend_System__c=backendList[0].id;
            string idofback='1234';
            cs4.Core_IPS_Restricted_Secret_Content__c = true;
            cs4.Core_IPS_Backend_ID__c=idofback;
            cs4.Core_severity__c= 'Low';
            cs4.recordtypeid=rType.id;
            //Adding case Status and SubStatus -- Manoj Kumar
            cs4.Status='Open';
            cs4.Core_Sub_Status__c='Investigating';
            
            Case cs5=new case();
            cs5.Core_IPS_Supported_Product__c= suppProd.id;
            cs5.Core_IPS_Product_Org1__c=suppOrg.id;
            cs5.productID=prod.id;
            cs5.Core_Case_Issue_Category__c = issueCat.id;
            cs5.Core_Case_Issue_Sub_Category__c = issueCat.id;
            cs5.Core_External_Issue_Category__c = 'Test';            
            cs5.Core_IPS_Backend_System__c=backend.id;
            cs5.Core_IPS_Restricted_Secret_Content__c = true;
            cs5.Core_Promote_Status__c = 'In Progress';
            cs5.Core_IPS_Backend_ID__c = '0';
            cs5.recordtypeid=rType.id;
            
            Case cs6=new case();
            cs6.Core_IPS_Supported_Product__c= suppProd.id;
            cs6.Core_IPS_Product_Org1__c=suppOrg.id;
            cs6.productID=prod.id;
            cs6.Core_IPS_Restricted_Secret_Content__c = true;
            cs6.Core_Case_Issue_Category__c = issueCat.id;
            cs6.Core_Case_Issue_Sub_Category__c = issueCat.id;
            cs6.Core_External_Issue_Category__c = 'Test';            
            cs6.Core_IPS_Backend_System__c=backend.id;
            cs6.recordtypeid=rType.id;
            
            Case cs7=new case();
            cs7.Core_IPS_Supported_Product__c= suppProd.id;
            cs7.Core_IPS_Product_Org1__c=suppOrg.id;
            cs7.productID=prod.id;
            cs7.Core_Case_Issue_Category__c = issueCat.id;
            cs7.Core_Case_Issue_Sub_Category__c = issueCat.id;
            cs7.Core_External_Issue_Category__c = 'Test';            
            cs7.Core_IPS_Backend_System__c=backend.id;
            cs7.Core_IPS_Restricted_Secret_Content__c =true;
            cs7.Core_Promote_Status__c='Promote';
            cs7.recordtypeid=rType.id;
            
            //Case  cs1= new Case();          
            cs1.Core_IPS_Supported_Product__c= suppProd.id;
            cs1.Core_IPS_Product_Org1__c=suppOrg.id;
            cs1.productID=prod.id;
            cs1.Core_IPS_Backend_System__c=backendList[0].id;
            cs1.Core_Case_Issue_Category__c = issueCat.id;
            cs1.Core_Case_Issue_Sub_Category__c = issueCat.id;
            cs1.Core_External_Issue_Category__c = 'Test';
            cs1.Core_IPS_Restricted_Secret_Content__c = true;
            cs1.Core_Severity__c='Low';
            cs1.recordtypeid=rType.id;
            cs1.Status='Open';
            cs1.Core_Sub_Status__c='Investigating';
            
            
            
            Case cs8=new case();
            cs8.Core_IPS_Supported_Product__c= suppProd1.id;
            cs8.Core_IPS_Product_Org1__c = suppOrg1.id;
            cs8.productID= prod1.id;
            cs8.Core_IPS_Backend_System__c=backend1.id;
            //cs8.Core_Case_Issue_Category__c = issueCat.id;
            //cs8.Core_Case_Issue_Sub_Category__c = issueCat.id;
            //cs8.Core_External_Issue_Category__c = 'Test';
            cs8.Core_Severity__c='Low';
            cs8.recordtypeid=rType.id;
            
            
            
            
            Case cs13=new case();
            cs13.Core_IPS_Supported_Product__c= suppProd2.id;
            cs13.Core_IPS_Product_Org1__c=suppOrg2.id;
            cs13.productID=prod2.id;
            cs13.OwnerId = testGroup.Id;
            cs13.Core_severity__c= 'Low';
            cs13.recordtypeid=rType.id;
            //Adding case Status and SubStatus -- Manoj Kumar
            cs13.Status='Open';
            cs13.Core_Sub_Status__c='Investigating';
            
            Case cs14=new case();
            cs14.Core_IPS_Supported_Product__c= suppProd3.id;
            cs14.Core_IPS_Product_Org1__c=suppOrg2.id;
            cs14.productID=prod3.id;
            cs14.OwnerId = testGroup.Id;
            cs14.Core_severity__c= 'Low';
            cs14.recordtypeid=rType.id;
            //Adding case Status and SubStatus -- Manoj Kumar
            cs14.Status='Open';
            cs14.Core_Sub_Status__c='Investigating';
            
            
            
            newList.add(cs1);
            newList.add(cs3);
            newList.add(cs4);
            newList.add(cs5);
            newList.add(cs6);
            newList.add(cs7);
            newList.add(cs8);
            newList.add(cs13);
            newList.add(cs14);
            //newList.add(cs15);
            system.runas(ListOfUser[3])
            {
                insert(newList);
            }
            //case cs9 = new case();
            //cs9.id=cs4.id;
            cs4.Core_severity__c= 'High';
            
            List<Core_IPS_Environment_Details__c> environList=new List<Core_IPS_Environment_Details__c>();
            Core_IPS_Environment_Details__c  envi =Core_IPS_Backend_TestClass_Utility.getCaseEnvironmentalDetails();
            // Create environmental Response record with the question, answer and case ID  
            Core_IPS_Environment_Details__c envidet=new Core_IPS_Environment_Details__c(Core_Answer__c='chromeTest',Core_Question__c='bkc_bsp_version');  
            envi.Core_Case__c=cs1.id;    
            envidet.Core_Case__c=cs1.id;
            environList.add(envi);
            environList.add(envidet);
            
            Core_IPS_Response__c  cResp = new Core_IPS_Response__c ();
            //cResp.Core_IPS_ANswer__c = 'chrometest';
            cResp.Core_IPS_Question_Master__c = envQuest.id;
            cResp.Core_IPS_Answer_Master__c = answers.id;
            cResp.Core_IPS_Case__c =cs1.id; 
            
            Core_IPS_Response__c  cResp1 = new Core_IPS_Response__c ();
            //cResp1.Core_IPS_ANswer__c = 'chrometest';
            cResp1.Core_IPS_Question_Master__c = envQuest1.id;
            cResp1.Core_IPS_Answer_Master__c = answers1.id;
            cResp1.Core_IPS_Case__c =cs1.id; 
            
            List<Core_IPS_Response__c> qResList =  new List<Core_IPS_Response__c>();
            
            
            qResList.add(cResp);
            qResList.add(cResp1);
            
            
            system.runas(ListOfUser[4])
            {
                //insert environList;
                insert qResList;
            }  
            
            case cs11= new case();
            cs11 = cs4;
            
            oldList.add(cs11);
            oldMap.put(cs11.id,cs11);            
            //List<Core_Product_Issue_Category__c > issueCatList = new List<Core_Product_Issue_Category__c>();
            //issueCatList.add(issueCat);
            
            // newMap.put(cs1.id, cs1);
            
            
            //Start--3rd Feb 2016--
            test.startTest();
            List<Core_IPS_Backend_Field_Mapping__c> BackEndFieldList=new List<Core_IPS_Backend_Field_Mapping__c>();
            Core_IPS_Backend_Field_Mapping__c backEndField=new Core_IPS_Backend_Field_Mapping__c(Core_IPS_Backend_System__c=backendList[0].id,Core_IPS_Field_Object_Name__c='Case',Core_IPS_Field_Technical_name__c='Core_Severity__c',Core_IPS_Source_Field__c='customer_priority',Core_IPS_Target_Field__c='customfield_10300',Core_IPS_Support_Update__c = true);
            Core_IPS_Backend_Field_Mapping__c backEndField1=new Core_IPS_Backend_Field_Mapping__c(Core_IPS_Backend_System__c=backendList[0].id,Core_IPS_Field_Object_Name__c='Core_IPS_Environment_Details__c',Core_IPS_Field_Technical_name__c='bkc_bsp_version',Core_IPS_Source_Field__c='bkc_bsp_version',Core_IPS_Target_Field__c='customfield_14617',Core_IPS_Support_Update__c = true);
            
            //Creating Backend Field Mapping for SubStatus update routing through workflow -- Manoj Kumar
            Core_IPS_Backend_Field_Mapping__c backEndField2=new Core_IPS_Backend_Field_Mapping__c(Core_IPS_Backend_System__c=backendList[0].id,Core_IPS_Field_Object_Name__c='Case',Core_IPS_Field_Technical_name__c='Core_Sub_Status__c',Core_IPS_Source_Field__c='substatus',Core_IPS_Target_Field__c='substatus',Core_IPS_Support_Update__c = true);
            //backEndField.Core_IPS_Field_Object_Name__c='Case';
            //backEndField1.Core_IPS_Field_Object_Name__c='Core_IPS_Environment_Details__c';
            backEndField2.Core_IPS_Field_Object_Name__c='Case';
            BackEndFieldList.add(backEndField);
            BackEndFieldList.add(backEndField1);
            BackEndFieldList.add(backEndField2);
            system.runas(ListOfUser[5])
            {
                insert BackEndFieldList;
            }
            //Creating Backend Value Mapping for SubStatus update routing through workflow -- Manoj Kumar
            List<Core_IPS_Backend_Value_Mapping__c> BackEndValueList = new List<Core_IPS_Backend_Value_Mapping__c>();
            Core_IPS_Backend_Value_Mapping__c backendValue = new Core_IPS_Backend_Value_Mapping__c(Core_IPS_Backend_Field_Mapping__c=BackEndFieldList.get(2).Id, Core_IPS_Source_Value__c='Open.Investigating',Core_IPS_Target_Value__c='open.re-open',Core_IPS_Previous_Source_Value__c='Closed.Resolved');
            Core_IPS_Backend_Value_Mapping__c backendValue1 = new Core_IPS_Backend_Value_Mapping__c(Core_IPS_Backend_Field_Mapping__c=BackEndFieldList.get(2).Id, Core_IPS_Source_Value__c='Open.Deferred',Core_IPS_Target_Value__c='open.re-open',Core_IPS_Previous_Source_Value__c='closed');
            Core_IPS_Backend_Value_Mapping__c backendValue2 = new Core_IPS_Backend_Value_Mapping__c(Core_IPS_Backend_Field_Mapping__c=BackEndFieldList.get(2).Id, Core_IPS_Source_Value__c='Closed.Closed',Core_IPS_Target_Value__c='complete',Core_IPS_Previous_Source_Value__c='Open.Investigating');
            //Core_IPS_Backend_Value_Mapping__c backendValue2 = new Core_IPS_Backend_Value_Mapping__c(Core_IPS_Backend_Field_Mapping__c=BackEndFieldList.get(2).Id, Core_IPS_Source_Value__c='Open',Core_IPS_Target_Value__c='complete',Core_IPS_Previous_Source_Value__c='Closed.Resolved');
            
            BackEndValueList.add(backendValue);
            BackEndValueList.add(backendValue1);
            BackEndValueList.add(backendValue2);
            system.runas(ListOfUser[5])
            {
                insert BackEndValueList;
            }
            //End SubStatus update routing -- Manoj Kumar
            
            Set<ID> backIDList=new Set<ID>();
            backIDList.add(backendList[0].id);
            
            case cs2=new case();
            cs2.Status='Closed';
            cs1.Status='Closed';
            cs1.Core_jsonfield__c='{"Env Dtl Resp" : [ {"Qstn" : "bkc_bsp_version","Ansr" : "All in One M;"} ]}';
            cs2.Core_jsonfield__c='{"Env Dtl Resp" : [ {"Qstn" : "bkc_bsp_version","Ansr" : "All in One M;"} ]}';
            cs2.Core_Sub_Status__c='Closed';
            cs2.Core_IPS_Backend_Previous_Status__c = 'disassociate';
            cs2=cs1;
            
            
            cs4.Core_jsonfield__c='{"Env Dtl Resp" : [ {"Qstn" : "bkc_bsp_version","Ansr" : "All in One M;"} ]}';
            cs4.Core_Severity__c='Medium';
            //Updating case Status and SubStatus for routing through workflow -- Manoj Kumar
            cs4.Status='Closed';
            cs4.Core_Sub_Status__c='Closed';
            
            system.runas(ListOfUser[6])
            {
                update cs4;
                
            }
            newlist.clear();
            newList.add(cs2);
            newList.add(cs3);
            newList.add(cs4);
            newList.add(cs1);
            newMap.put(cs2.id,cs2);
            
            Set<String> envFieldSet = new Set<String>();
            Map<String, String> envFieldSetMap = new Map<String, String>();
            //           envFieldSet.add('Core_Severity__c');
            envFieldSet.add('bkc_bsp_version');
            //           envFieldSetMap.put('Core_Severity__c','Core_Severity__c');
            envFieldSetMap.put('bkc_bsp_version','bkc_bsp_version');
            String jasonStr = cs4.Core_jsonfield__c;
            
            system.runas(ListOfUser[7])
            {
                cs1.Core_Severity__c = 'High';
                cs1.Core_IPS_Supported_Product__c = suppProd1.id;
                update cs1;            }
            Core_IPS_CasePromotion_Handler.parseCaseJsonEnvDetString(jasonStr, envFieldSetMap);
            
            
            Core_IPS_CasePromotion_Handler.executeBackendRoutingfromCaseTrigger(oldList, newList, oldMap, newMap);
            Core_IPS_CasePromotion_Handler.executeBackendFieldUpdate(oldList, newList, oldMap, newMap,backIDList); //3rd Feb 2016--
            //End--3rd Feb 2016--
            Core_IPS_CasePromotion_Handler.checkIssueCategoriesCriteria(backendCaseCateList,suppProd.id,cs1);            
            Core_IPS_CasePromotion_Handler.checkIssueCategoryWithCase(backendCaseCateList,cs1);
            Core_IPS_CasePromotion_Handler.stampBackendID(backend.id,true,cs1,'Case');
            Core_IPS_CasePromotion_Handler.stampBackendID(backend1.id,false,cs8,'Case');
            Core_IPS_CasePromotion_Handler.executeBackendFieldUpdateFromCaseEnvDet(cs2,envFieldSet,envFieldSetMap,cs1);
            
            
            
            test.stopTest();
        }  
        //        update(cs);
    }
    
    /******************************************************************************************************************************************
************************************************End Of Comment****************************************************************************/
    
    
    /********************************************************************************************************************
Method Name    : executeBackendRoutingTest
Description    : To perform test coverage for executeBackendRouting logic
Modification Log :
* Developer                           Date                   Description
* ----------------------------------------------------------------------------                 
* Kareem Unnisa                      03/09/2015              Original Version
* Shebin Kurian                      03/Feb/2016             Modification for code coverage
* Tanvi Chauhan                      26/May/2016             Modification for ReProcessBackendSystem code coverage
* Manoj Kumar                        06/Oct/2016             Modification for executeBackendFieldUpdate code coverage
* Manoj Kumar                        22/Mar/2017             Modification of executeBackendRoutingTest method to increase code coverage
*******************************************************************************************************************/
    static testMethod void executeBackendRoutingTest1()
    {
        // List variables for inserting test data
        List<Case> newList = new List<Case>();
        List<Case> updateList = new List<Case>();
        List<Product2> prodlist = new List<Product2>();
        List<Core_IPS_Product_Organization__c> suppOrgList = new List<Core_IPS_Product_Organization__c>();
        List<Core_IPS_Supported_Product__c> suppProdList = new List<Core_IPS_Supported_Product__c>();
        List <Core_IPS_Backend_Supported_Product_Map__c> backSPList = new List<Core_IPS_Backend_Supported_Product_Map__c>();
        List<Core_IPS_Backend_System__c> backendList = new List<Core_IPS_Backend_System__c>();
        List<Core_IPS_Backend_Field_Mapping__c> BackEndFieldList=new List<Core_IPS_Backend_Field_Mapping__c>();
        List<Core_IPS_Backend_Value_Mapping__c> BackEndValueList = new List<Core_IPS_Backend_Value_Mapping__c>();
        //List<Core_IPS_Environment_Details__c> environList=new List<Core_IPS_Environment_Details__c>();
        //List<Core_IPS_Environment_Variables__c> envList=new List<Core_IPS_Environment_Variables__c>();
        List<Core_IPS_Assigned_Environment_Variables__c> AssenvList = new List<Core_IPS_Assigned_Environment_Variables__c>(); 
        //systmAdmin profile for creating test data
        
        String sysAdminProfileID = [select id, name from Profile where name = 'System Administrator' Limit 1].Id;
        
        User sysadmin = TestUtilities.getUser();
        sysadmin.username= 'inteltestuser@intel.com';
        sysadmin.ProfileID =  sysAdminProfileID;
        
        insert sysadmin; 
        
        //creating test data for product,productOrg,SupportedProduct,SupportProdMap,backendSystem,backendFieldMap,backendValueMap,
        //EnvironDetails,EnvironVariables,AssignEnvironVariables
        if(sysadmin<>null)
        {
            preptestdata();
            
            Product2 prod=Core_IPS_Backend_TestClass_Utility.getProduct();
            prod.Core_Product_Org__c='IPS'; //3rd Feb 2016--Validation if we make IPS Flag visible without setting Core_Product_Org__c='IPS'
            Product2 prod1 = new Product2(Name = 'Test123',Core_Product_Org__c='IPS',Core_Sales_Visible_Flag__c = false, Core_IPS_Visible_Flag_External__c = true,IsActive = true );
            
            prodList.add(prod);
            prodList.add(prod1);
            
            Core_IPS_Product_Organization__c suppOrg=Core_IPS_Backend_TestClass_Utility.getSupportOrg();
            Core_IPS_Product_Organization__c suppOrg1 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'dcg', Core_Organization_Description__c = 'Data Center Group');   
            suppOrgList.add(suppOrg);
            suppOrgList.add(suppOrg1);
            
            //creating test data as SysAdmin
            system.runas(sysadmin)
            {
                insert suppOrgList; 
                insert prodList;
                system.assert(prodList != null);
            }
            Core_IPS_Supported_Product__c suppProd = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
            suppProd.Core_Product__c=prod.id;
            suppProd.Core_Product_Organization__c=suppOrg.id;
            
            Core_IPS_Supported_Product__c suppProd1 = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
            suppProd1.Core_Product__c=prod1.id;
            suppProd1.Core_Product_Organization__c=suppOrg1.id;
            
            suppProdList.add(suppProd);
            suppProdList.add(suppProd1);
            
            Id queRecordId= Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
            
            
            Core_IPS_Question__c envQuest =New Core_IPS_Question__c();
            envQuest.recordtypeId = queRecordId;
            envQuest.Core_IPS_Datatype__c = 'Text';
            envQuest.Core_IPS_Product_Organization__c = suppOrg.id;
            envQuest.Core_IPS_Question__c='operating system';
            envQuest.Core_IPS_Survey_Type__c ='';
            
            
            Core_IPS_Question__c envQuest1 =New Core_IPS_Question__c();
            envQuest1.recordtypeId = queRecordId;
            envQuest1.Core_IPS_Datatype__c = 'Text';
            envQuest1.Core_IPS_Product_Organization__c = suppOrg.id;
            envQuest1.Core_IPS_Question__c='bkc_bsp_version';
            envQuest1.Core_IPS_Survey_Type__c ='';
            
            
            List<Core_IPS_Question__c> queList = new List<Core_IPS_Question__c>();
            queList.add(envQuest);
            queList.add(envQuest1);
            
            Core_IPS_Backend_System__c backend= Core_IPS_Backend_TestClass_Utility.getBackendSystem();
            backend.name='test';
            backend.Core_IPS_Support_Org__c=suppOrg.id;
            backend.Core_IPS_Support_Case_Field_Update__c=true;
            
            Core_IPS_Backend_System__c backend1= Core_IPS_Backend_TestClass_Utility.getBackendSystem();
            backend1.name='test111';
            backend1.Core_IPS_Support_Org__c=suppOrg1.id;
            backend1.Core_IPS_Support_Case_Field_Update__c=true;
            
            backendList.add(backend);
            backendList.add(backend1); 
            
            //--------------------------for checkIssueCategoriesCriteria----------------------
            Core_IPS_Master_Issue_Category__c masterIssueCat =Core_IPS_Backend_TestClass_Utility.getMasterIssueCategory();
            masterIssueCat.Name='Test'; //5th Feb- for check case external issue category name and master issue category name
            
            //creating test data as SysAdmin
            system.runas(sysadmin)
            {
                insert queList; 
                insert suppProdList;
                insert backendList; 
                insert masterIssueCat;
            }  
            
            Core_IPS_Answer__c answers =  new Core_IPS_Answer__c();
            answers.Core_IPS_Answer__c = 'chrome';
            answers.Core_IPS_Question__c =envQuest.id;
            answers.Core_IPS_Status__c = 'Active';
            
            Core_IPS_Answer__c answers1 =  new Core_IPS_Answer__c();
            answers1.Core_IPS_Answer__c = 'chrometest';
            answers1.Core_IPS_Question__c =envQuest1.id;
            answers1.Core_IPS_Status__c = 'Active';   
            
            List<Core_IPS_Answer__c> answerList = new list<Core_IPS_Answer__c>();
            answerList.add(answers);
            answerList.add(answers1);    
            
            system.runas(sysadmin)
            {
                insert answerList;  
            }  
            
            Core_IPS_Backend_Supported_Product_Map__c back= Core_IPS_Backend_TestClass_Utility.getBackendId();
            back.Core_IPS_Supported_Product__c=suppProd.id;
            back.core_IPS_backend_System__c= backend.id;
            
            Core_IPS_Backend_Supported_Product_Map__c back1= Core_IPS_Backend_TestClass_Utility.getBackendId();
            back1.Core_IPS_Supported_Product__c=suppProd1.id;
            back1.core_IPS_backend_System__c= backend1.id;
            back1.Core_IPS_Auto_Promote__c = false;
            
            Core_IPS_Backend_Supported_Product_Map__c back2= Core_IPS_Backend_TestClass_Utility.getBackendId();
            back2.Core_IPS_Supported_Product__c=suppProd.id;
            back2.core_IPS_backend_System__c= backend.id;
            back2.Core_IPS_Default__c = true;
            
            backSpList.add(back);
            backSpList.add(back1);
            backSpList.add(back2);
            
            Core_IPS_Product_Issue_Category__c issueCat=Core_IPS_Backend_TestClass_Utility.getCategory();
            issueCat.Core_Supported_Product__c = suppProd.id;
            insert issueCat;
            
            Core_IPS_Assigned_Environment_Variables__c AssEnv=new Core_IPS_Assigned_Environment_Variables__c(Core_IPS_Question__c=envQuest.Id,Core_Supported_Product__c=suppProd.Id,Core_Product_Issue_Sub_Category__c=issueCat.id,Core_Type__c='Product');
            Core_IPS_Assigned_Environment_Variables__c AssEnv1=new Core_IPS_Assigned_Environment_Variables__c(Core_IPS_Question__c=envQuest1.Id,Core_Supported_Product__c=suppProd.Id,Core_Product_Issue_Sub_Category__c=issueCat.id,Core_Type__c='Product');
            
            AssenvList.add(AssEnv);
            AssenvList.add(AssEnv1);
            
            Core_IPS_Backend_Env_Details_Map__c  backEnviMap =Core_IPS_Backend_TestClass_Utility.getBackendEnvironmentMap();
            
            backEnviMap.Core_IPS_Backend_System__c=backend.id; 
            backEnviMap.Core_IPS_Backend_EnvQuestion__c=envQuest.id;
            backEnviMap.Core_IPS_Environment_Variable_Answer__c='chrome';
            
            //creating test data as SysAdmin
            system.runas(sysadmin)
            {
                insert backEnviMap; 
                //insert issueCat;
                insert AssEnvList;
                insert backSpList;          
            }
            Core_IPS_Backend_Case_Categories_Map__c  backendCaseCate = Core_IPS_Backend_TestClass_Utility.getCaseCategories();
            backendCaseCate.Core_IPS_Case_Category__c=masterIssueCat.id;
            backendCaseCate.Core_IPS_Backend_SP_Map__c = backSpList[0].id;
            
            Asset  Asst=new Asset(Core_Supported_Product__c=suppProd.id,Core_Product_Organization__c=suppOrg.id,Name='Asset1') ;
            system.runas(sysadmin)
            {
                insert backendCaseCate;
                insert  Asst;  //For case is attached with asset
            }
            
            newList = Core_IPS_Backend_TestClass_Utility.getListOfCases(9,'IPS No Assigned Contact Case',prod,backend);
            for(Case cs : newList){
                
                cs.Core_IPS_Supported_Product__c= suppProd.id;
                cs.Core_IPS_Product_Org1__c=suppOrg.id;
                cs.Core_Case_Issue_Category__c = issueCat.id;
                cs.Core_Case_Issue_Sub_Category__c = issueCat.id;
                cs.Core_External_Issue_Category__c = 'Test';
                cs.Core_IPS_Restricted_Secret_Content__c = true;
                cs.Core_Severity__c='Low';
                cs.Status='Open';
                cs.Core_Sub_Status__c='Resolved';
                cs.Description = '';
                cs.Core_CaseType__c = '';
                
            }
            newList.get(0).Core_IPS_Backend_System__c=null;
            newList.get(0).Core_ips_Backend_ID__c = null;
            newList.get(0).Core_IPS_gec_flag__c=false;
            
            newList.get(1).Core_IPS_Backend_ID__c='123';
            newList.get(1).Core_Sub_Status__c='Waiting for Customer Response';
            newList.get(1).Core_IPS_gec_flag__c=false;
            newList.get(1).Core_jsonfield__c='{"Env Dtl Resp" : [ {"Qstn" : "bkc_bsp_version","Ansr" : "All in One M;"} ]}';
            
            newList.get(2).assetid=Asst.id;
            newList.get(2).Status='Closed';
            newList.get(2).Core_Sub_Status__c='Resolved';
            newList.get(2).Core_ips_Backend_ID__c = '12345';
            newList.get(2).Core_jsonfield__c='{"Env Dtl Resp" : [ {"Qstn" : "bkc_bsp_version","Ansr" : "All in One;"} ]}';
            
            newList.get(3).Core_IPS_Backend_ID__c='1234';
            newList.get(3).Status='Closed';
            newList.get(3).Core_Sub_Status__c='Resolved';
            newList.get(3).Core_IPS_gec_flag__c=false;
            newList.get(3).Core_jsonfield__c='{"Env Dtl Resp" : [ {"Qstn" : "bkc_bsp_version","Ansr" : "All in One M;"} ]}';
            
            newList.get(4).Core_Promote_Status__c = 'In Progress';
            newList.get(4).Core_IPS_Backend_ID__c = '0';
            newList.get(4).Status='Closed';
            newList.get(4).Core_Sub_Status__c='No Response from Customer';
            
            case cs5 = new case(recordtypeid=Case.getSObjectType().getDescribe().getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId(),assetid=Asst.id);
            newList.set(5, cs5);
            
            newList.get(6).Core_Promote_Status__c='Promote';
            
            newList.get(7).Core_ips_Backend_ID__c = null;
            newList.get(7).Core_IPS_gec_flag__c=false;
            newList.get(7).Core_Promote_Status__c='Failed';
            
            newList.get(8).Core_IPS_Supported_Product__c= suppProd1.id;
            newList.get(8).Core_IPS_Product_Org1__c=suppOrg1.id;
            newList.get(8).productID=prod1.id;
            newList.get(8).Core_ips_Backend_ID__c = null;
            newList.get(8).Core_IPS_gec_flag__c=false;
            
            
            
            Core_Trigger_Executions__c settings = new Core_Trigger_Executions__c();
            settings.Name = 'InsertCaseCommentForAttach';
            settings.Core_Class_Name__c = 'Core_IPS_CasePromotion_Handler';
            settings.Core_Description__c = 'ABC';
            settings.Core_Object__c = 'Core_IPS_Case_Comments__c';
            settings.Core_Trigger_Events__c = 'After Insert, After update';
            settings.Core_Active__c = True;
            insert settings;
            Core_Trigger_Executions__c triggerForResp =  new Core_Trigger_Executions__c(Core_Active__c = true,Name='updateEnvDetailsOnCaseFromCoreResponse',Core_Class_Name__c='Core_IPS_Response_Handler',Core_Description__c='This method is used to assign the Core_IPS_Answer__c Field on Core_IPS_Response__c Object From Core_IPS_Answer_Master__c Object',Core_Object__c='Core_IPS_Response__c',Core_Trigger_Events__c='Before Insert, Before Update');
            //triggerExecRecordList.add(triggerForResp);
            insert triggerForResp;
            List<Core_IPS_Labels__c> labelList = new List<Core_IPS_Labels__c>();
            Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
            labels.name= 'COMPLETE';
            labels.value__c='COMPLETE';
            labelList.add(labels);
            //insert labels;
            
            Core_IPS_Labels__c labels1 = new Core_IPS_Labels__c ();
            labels1.name= 'PUBLIC_TO_CUSTOMERS';
            labels1.value__c='PUBLIC_TO_CUSTOMERS';
            labelList.add(labels1);
            //insert labels1;
            // Avoid Hardcoding Id Fix - Start - Shipra
            Profile dataMigPrf = [select id, name from Profile where name = 'IPS Data Migration' Limit 1];
            Core_IPS_Labels__c labels2 = new Core_IPS_Labels__c ();
            labels2.name= 'Data Migration Profile Id';
            labels2.value__c=dataMigPrf.Id;
            //    labels2.value__c='00eo0000000f7Gd';
            // Avoid Hardcoding Id Fix - End - Shipra
            labelList.add(labels2);
            //insert labels2;
            
            Core_IPS_Labels__c labels3 = new Core_IPS_Labels__c ();
            labels3.name= 'PRIVATE_TO_INTEL';
            labels3.value__c='PRIVATE_TO_INTEL';
            labelList.add(labels3);
            // insert labels3;
            
            Core_IPS_Labels__c labels4 = new Core_IPS_Labels__c ();
            labels4.name= 'PRIVATE_TO_AGENTS';
            labels4.value__c='PRIVATE_TO_AGENTS';
            labelList.add(labels4);
            //insert labels4;
            
            
            Core_IPS_Labels__c label5= new Core_IPS_Labels__c();
            label5.name='Customer';
            label5.value__c='Customer';
            labelList.add(label5);
            //insert label5;
            
            Core_IPS_Labels__c label6 = new Core_IPS_Labels__c ();
            label6.name='FAE';
            label6.value__c='FAE';
            labelList.add(label6);
            //insert label6;
            
            Core_IPS_Labels__c label7 = new Core_IPS_Labels__c();
            label7.name='Agent';
            label7.value__c='Agent';
            labelList.add(label7);
            //insert label7;
            
            Core_IPS_Labels__c label8 = new Core_IPS_Labels__c();
            label8.name='Backend Integration';
            label8.value__c='Backend Integration';
            labelList.add(label8);
            //insert label8;
            
            Core_IPS_Labels__c label9 = new Core_IPS_Labels__c();
            label9.name='Data Migration';
            label9.value__c='Data Migration';
            labelList.add(label9);
            //insert label9;
            
            Core_IPS_Labels__c label10 = new Core_IPS_Labels__c();
            label10.name='Partner';
            label10.value__c='Partner';
            labelList.add(label10);
            //insert label10;
            
            system.runas(sysadmin)
            {
                insert(newList);
                insert labelList; 
            }
            
            //User u =TestUtilities.getCustomerUser('IPS External Customer');
            
            Core_IPS_Case_Attachments__c att= Core_IPS_Backend_TestClass_Utility.getAttachment();
            att.Core_Upload_Status__c='Complete';
            att.Core_Case__c=newList.get(2).id;
            att.Core_Promote_Status__c = 'Failed';
            att.Core_IPS_Attachment_Visibility__c = 'Public to Customers';
            att.Core_FileUploadedby__c = sysadmin.id; 
            att.Core_File_URL__c ='https://esft-int.intel.com/sftservices/download/ISVC_SCFT/?';
            
            
            
            
            
            Core_IPS_Response__c  cResp = new Core_IPS_Response__c ();
            //cResp.Core_IPS_Survey_Type__c = '';
            cResp.Core_IPS_Question_Master__c = envQuest.id;
            cResp.Core_IPS_Answer_Master__c = answers.id;
            cResp.Core_IPS_Case__c =newList.get(0).id; 
            
            Core_IPS_Response__c  cResp1 = new Core_IPS_Response__c ();
            //cResp1.Core_IPS_Survey_Type__c = '';
            cResp1.Core_IPS_Question_Master__c = envQuest1.id;
            cResp1.Core_IPS_Answer_Master__c = answers1.id;
            cResp1.Core_IPS_Case__c =newList.get(0).id; 
            
            List<Core_IPS_Response__c> qResList =  new List<Core_IPS_Response__c>();
            
            
            qResList.add(cResp);
            qResList.add(cResp1);
            
            
            
            
            
            //creating test data as SysAdmin
            system.runas(sysadmin)
            { 
                
                //insert att;  
                // Creating attachment to execute BackendRouting Logic from 'Core_IPS_Case_Attachments' Trigger
                //insert environList;
                
                insert qResList;
                
            }
            Core_IPS_Backend_Field_Mapping__c backEndField=new Core_IPS_Backend_Field_Mapping__c(Core_IPS_Backend_System__c=backend.id,Core_IPS_Field_Object_Name__c='Case',Core_IPS_Field_Technical_name__c='Core_Severity__c',Core_IPS_Source_Field__c='customer_priority',Core_IPS_Target_Field__c='customfield_10300',Core_IPS_Support_Update__c = true);
            Core_IPS_Backend_Field_Mapping__c backEndField1=new Core_IPS_Backend_Field_Mapping__c(Core_IPS_Backend_System__c=backend.id,Core_IPS_Field_Object_Name__c='Core_IPS_Environment_Details__c',Core_IPS_Field_Technical_name__c='bkc_bsp_version',Core_IPS_Source_Field__c='bkc_bsp_version',Core_IPS_Target_Field__c='customfield_14617',Core_IPS_Support_Update__c = true);
            
            //Creating Backend Field Mapping for SubStatus update routing through workflow -- Manoj Kumar
            Core_IPS_Backend_Field_Mapping__c backEndField2=new Core_IPS_Backend_Field_Mapping__c(Core_IPS_Backend_System__c=backend.id,Core_IPS_Field_Object_Name__c='Case',Core_IPS_Field_Technical_name__c='Core_Sub_Status__c',Core_IPS_Source_Field__c='substatus',Core_IPS_Target_Field__c='substatus',Core_IPS_Support_Update__c = true);
            
            BackEndFieldList.add(backEndField);
            BackEndFieldList.add(backEndField1);
            BackEndFieldList.add(backEndField2); 
            
            //creating test data as SysAdmin
            system.runas(sysadmin)
            {
                insert BackEndFieldList;
            } 
            
            //Creating Backend Value Mapping for SubStatus update routing through workflow -- Manoj Kumar
            Core_IPS_Backend_Value_Mapping__c backendValue = new Core_IPS_Backend_Value_Mapping__c(Core_IPS_Backend_Field_Mapping__c=BackEndFieldList.get(2).Id, Core_IPS_Source_Value__c='Open.Investigating',Core_IPS_Target_Value__c='open.re-open',Core_IPS_Previous_Source_Value__c='Closed.Resolved');
            Core_IPS_Backend_Value_Mapping__c backendValue1 = new Core_IPS_Backend_Value_Mapping__c(Core_IPS_Backend_Field_Mapping__c=BackEndFieldList.get(2).Id, Core_IPS_Source_Value__c='Open.Deferred',Core_IPS_Target_Value__c='open.re-open',Core_IPS_Previous_Source_Value__c='closed');
            Core_IPS_Backend_Value_Mapping__c backendValue2 = new Core_IPS_Backend_Value_Mapping__c(Core_IPS_Backend_Field_Mapping__c=BackEndFieldList.get(2).Id, Core_IPS_Source_Value__c='open',Core_IPS_Target_Value__c='complete',Core_IPS_Previous_Source_Value__c='Closed.Resolved');
            Core_IPS_Backend_Value_Mapping__c backendValue3 = new Core_IPS_Backend_Value_Mapping__c(Core_IPS_Backend_Field_Mapping__c=BackEndFieldList.get(2).Id, Core_IPS_Source_Value__c='Closed',Core_IPS_Target_Value__c='complete',Core_IPS_Previous_Source_Value__c='Open');
            
            BackEndValueList.add(backendValue);
            BackEndValueList.add(backendValue1);
            BackEndValueList.add(backendValue2);
            BackEndValueList.add(backendValue3); 
            
            //creating test data as SysAdmin
            system.runas(sysadmin)
            {
                insert BackEndValueList;
            } 
            //End SubStatus update routing -- Manoj Kumar
            
            
            //Updating the cases to cover executeBackendRouting method logic
            newList.get(8).Core_IPS_Supported_Product__c=suppProd1.id;
            
            newList.get(1).Status='Closed';
            newList.get(1).Core_Sub_Status__c='No response from customer'; 
            
            newList.get(2).Core_jsonfield__c='{"Env Dtl Resp" : [ {"Qstn" : "bkc_bsp_version","Ansr" : "All in One M Update;"} ]}';
            
            newList.get(3).Core_jsonfield__c='{"Env Dtl Resp" : [ {"Qstn" : "bkc_bsp_version","Ansr" : "All in One M Update;"} ]}';
            newList.get(3).Core_Severity__c='Medium';
            //Updating case Status and SubStatus for routing through workflow -- Manoj Kumar
            //newList.get(3).Status='Open';
            newList.get(3).Core_Sub_Status__c='Investigating';
            
            newList.get(4).Core_severity__c= 'High';
            //newList.get(4).Status='Open';
            newList.get(4).Core_Sub_Status__c='Waiting for customer response';
            
            //Adding cases to updateList for updating
            updateList.add(newList.get(0));
            updateList.add(newList.get(1));
            updateList.add(newList.get(2));
            updateList.add(newList.get(3));
            updateList.add(newList.get(4));
            updateList.add(newList.get(5));
            updateList.add(newList.get(7));
            updateList.add(newList.get(8)); 
            
            //Start--3rd Feb 2016--/
            test.startTest();
            
            system.runas(sysadmin)
            {
                //Updating the cases to cover executeBackendRouting method logic
                update updateList;
                
            } 
            
            test.stopTest(); 
        }                             
    }
    
    /********************************************************************************************************************
Method Name    : executeBackendRoutingExceptionTest
Description    : To perform Exception test coverage for executeBackendRouting logic
Modification Log :
* Developer                           Date                   Description
* ----------------------------------------------------------------------------                 
* Manoj Kumar                        22/Mar/2017             Original Version
*******************************************************************************************************************/    
    //comment starts from here for testing
    static testMethod void executeBackendRoutingExceptionTest(){
        preptestdata();
        
        //systmAdmin profile for creating test data
        String sysAdminProfileID = [select id, name from Profile where name = 'System Administrator' Limit 1].Id;
        
        User sysadmin = TestUtilities.getUser();
        sysadmin.username='inteltestuser2@intel.com';
        sysadmin.ProfileID =  sysAdminProfileID;
        
        Core_Trigger_Executions__c settings1 = new Core_Trigger_Executions__c();
        settings1.Name = 'InsertCaseCommentForAttach';
        settings1.Core_Class_Name__c = 'Core_IPS_CasePromotion_Handler';
        settings1.Core_Description__c = 'ABC';
        settings1.Core_Object__c = 'Core_IPS_Case_Comments__c';
        settings1.Core_Trigger_Events__c = 'After Insert, After update';
        settings1.Core_Active__c = True;
        insert settings1;
        system.assert(settings1.Id != null);
        
        Core_Trigger_Executions__c triggerForResp =  new Core_Trigger_Executions__c(Core_Active__c = true,Name='updateEnvDetailsOnCaseFromCoreResponse',Core_Class_Name__c='Core_IPS_Response_Handler',Core_Description__c='This method is used to assign the Core_IPS_Answer__c Field on Core_IPS_Response__c Object From Core_IPS_Answer_Master__c Object',Core_Object__c='Core_IPS_Response__c',Core_Trigger_Events__c='Before Insert, Before Update');
        //triggerExecRecordList.add(triggerForResp);
        //insert triggerForResp;
        
        insert sysadmin;
        
        List<Case> newcaselist = new List<Case>();
        
        Product2 prod=Core_IPS_Backend_TestClass_Utility.getProduct();
        prod.Core_Product_Org__c='IPS';
        
        Core_IPS_Backend_System__c backend= Core_IPS_Backend_TestClass_Utility.getBackendSystem();
        backend.name='test';
        backend.Core_IPS_Support_Case_Field_Update__c=true;
        
        if(sysadmin!=null){
            
            system.runas(sysadmin)
            {
                insert prod;
                insert backend;
            }   
            
            newcaselist = Core_IPS_Backend_TestClass_Utility.getListOfCases(1,'IPS No Assigned Contact Case',prod,backend);
            newcaselist.get(0).core_promote_status__c = 'Failed';
            
            test.startTest();
            
            system.runas(sysadmin)
            {
                Core_IPS_CasePromotion_Handler.caseEnvDet csEnvDet = new Core_IPS_CasePromotion_Handler.caseEnvDet('Env det quest','Env det amswr');
                Core_IPS_CasePromotion_Handler.getBackendID(newcaselist,new Map<Id,case>(),'attachments');
            }   
            test.stopTest();
            
        }
    }
    
    
    public static testMethod  void reprocessLogEntries()
    {
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        ListOfUser = TestUtilities.getListOfUser(10);
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert ListOfUser;
        system.assert(ListOfUser != null);
        if(ListOfUser<>null &&ListOfUser.size()<=10)
        {
            List<Core_Trigger_Executions__c> triggerExecRecordList=new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c triggerExecRecord =new Core_Trigger_Executions__c(Core_Active__c=false,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This flag will allow to switch on and off the IPS Case Backend Routing',Core_Object__c='Case',Core_Trigger_Events__c='before insert, before update',Name='enableIPSCaseBackendRouting');
            Core_Trigger_Executions__c triggerExecRecord1 =new Core_Trigger_Executions__c(Core_Active__c=true,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This fl;ag allows to switch on and off IPS Case Attachment Backend Routing',Core_Object__c='Core_IPS_Case_Attachments__c',Core_Trigger_Events__c='after insert after update',Name='enableIPSCaseAttBackendRouting');
            Core_Trigger_Executions__c triggerExecRecord2 =new Core_Trigger_Executions__c(Core_Active__c=false,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This flag allows to switch on and off case comment trigger',Core_Object__c='Core_IPS_Case_Attachments__c',Core_Trigger_Events__c='before insert, before update',Name='enableIPSCaseCommentBackendRouting' );
            Core_Trigger_Executions__c triggerForResp =  new Core_Trigger_Executions__c(Core_Active__c = true,Name='updateEnvDetailsOnCaseFromCoreResponse',Core_Class_Name__c='Core_IPS_Response_Handler',Core_Description__c='This method is used to assign the Core_IPS_Answer__c Field on Core_IPS_Response__c Object From Core_IPS_Answer_Master__c Object',Core_Object__c='Core_IPS_Response__c',Core_Trigger_Events__c='Before Insert, Before Update');
            triggerExecRecordList.add(triggerForResp);
            triggerExecRecordList.add(triggerExecRecord);
            triggerExecRecordList.add(triggerExecRecord1);
            triggerExecRecordList.add(triggerExecRecord2);
            insert triggerExecRecordList;
            
            List<Core_IPSBackendPromoteReprocesing__c>configIdsList=new List<Core_IPSBackendPromoteReprocesing__c>();
            Core_IPSBackendPromoteReprocesing__c configIds=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='X',Name='OVERRIDE');
            Core_IPSBackendPromoteReprocesing__c configIds1=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='2015-08-13 00:00:00',Name='TODATE');
            Core_IPSBackendPromoteReprocesing__c configIds2=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='2015-08-12 00:00:00',Name='FROMDATE');
            configIdsList.add(configIds);
            configIdsList.add(configIds1);
            configIdsList.add(configIds2);
            insert configIdsList;
            
            Case cs1=new Case();
            Core_IPS_Product_Organization__c suppOrg=Core_IPS_Backend_TestClass_Utility.getSupportOrg();
            system.runas(ListOfUser[0])
            {
                insert suppOrg; 
            }
            Id queRecordId= Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
            
            Core_IPS_Question__c envQuest =New Core_IPS_Question__c();
            envQuest.recordtypeId = queRecordId;
            envQuest.Core_IPS_Datatype__c = 'Text';
            envQuest.Core_IPS_Product_Organization__c = suppOrg.id;
            envQuest.Core_IPS_Question__c='operating system';
            system.runas(ListOfUser[1])
            {
                insert envQuest;
            }
            
            Core_IPS_Answer__c answers =  new Core_IPS_Answer__c();
            answers.Core_IPS_Answer__c = 'chrome';
            answers.Core_IPS_Question__c =envQuest.id;
            answers.Core_IPS_Status__c = 'Active';
            system.runas(ListOfUser[1])
            {
                insert answers;
            }
            
            Core_IPS_Product_Issue_Category__c issueCat=Core_IPS_Backend_TestClass_Utility.getCategory();
            system.runas(ListOfUser[2])
            {
                insert issueCat;
            }
            
            Product2 prod=Core_IPS_Backend_TestClass_Utility.getProduct();
            prod.Core_Product_Org__c='IPS'; //3rd Feb 2016--Validation if we make IPS Flag visible without setting Core_Product_Org__c='IPS'
            system.runas(ListOfUser[3])
            {
                insert prod;
            }
            
            Core_IPS_Supported_Product__c suppProd = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
            suppProd.Core_Product__c=prod.id;
            suppProd.Core_Product_Organization__c=suppOrg.id;
            system.runas(ListOfUser[4])
            {
                insert suppProd;
            }
            
            Core_IPS_Backend_System__c backend= Core_IPS_Backend_TestClass_Utility.getBackendSystem();
            backend.name='test';
            backend.Core_IPS_Support_Org__c=suppOrg.id;
            system.runas(ListOfUser[5])
            {
                insert backend;
            }
            
            Core_IPS_Backend_Supported_Product_Map__c back= Core_IPS_Backend_TestClass_Utility.getBackendId();
            back.Core_IPS_Supported_Product__c=suppProd.id;
            back.core_IPS_backend_System__c= backend.id;
            system.runas(ListOfUser[6])
            {
                insert back;
            }
            
            suppProd.Core_Product__c = prod.id;
            
            
            Core_IPS_Backend_Env_Details_Map__c  backEnviMap =Core_IPS_Backend_TestClass_Utility.getBackendEnvironmentMap();
            
            // Question and answer
            backEnviMap.Core_IPS_Backend_System__c=backend.id; 
            backEnviMap.Core_IPS_Backend_EnvQuestion__c=envQuest.id;
            backEnviMap.Core_IPS_Environment_Variable_Answer__c='chrometest';
            system.runas(ListOfUser[7])
            {
                insert backEnviMap;
            }
            //--------------------------for checkIssueCategoriesCriteria----------------------
            Core_IPS_Master_Issue_Category__c masterIssueCat =Core_IPS_Backend_TestClass_Utility.getMasterIssueCategory();
            system.runas(ListOfUser[8])
            {
                insert masterIssueCat;
            }
            
            Core_IPS_Backend_Case_Categories_Map__c  backendCaseCate=Core_IPS_Backend_TestClass_Utility.getCaseCategories();
            backendCaseCate.Core_IPS_Case_Category__c=masterIssueCat.id;
            backendCaseCate.Core_IPS_Backend_SP_Map__c=back.id;
            system.runas(ListOfUser[9])
            {
                insert backendCaseCate;
            }
            
            List<Core_IPS_Backend_Case_Categories_Map__c>  backendCaseCateList = new List<Core_IPS_Backend_Case_Categories_Map__c>();
            backendCaseCateList.add(backendCaseCate);
            
            RecordType rType =  [Select r.Name, r.DeveloperName,r.id From RecordType r where r.DeveloperName = 'Core_IPS_Case_Create_Self_Assigned' Limit 1]; 
            cs1.RecordTypeID=rType.id;
            cs1.Core_IPS_Supported_Product__c= suppProd.id;
            cs1.Core_IPS_Product_Org1__c=suppOrg.id;
            cs1.productID=prod.id;
            cs1.Core_Promote_Status__c = 'Failed';
            String matched_flag='true';
            
            case cs2=new Case();
            cs2.RecordTypeID=rType.id;
            cs2.Core_IPS_Supported_Product__c= suppProd.id;
            cs2.Core_IPS_Product_Org1__c=suppOrg.id;
            cs2.Core_Promote_Status__c = 'Failed';
            cs2.productID=prod.id;
            
            case cs3=new Case();
            cs3.RecordTypeID=rType.id;
            cs3.Core_IPS_Supported_Product__c= suppProd.id;
            cs3.Core_IPS_Product_Org1__c=suppOrg.id;
            cs3.Core_IPS_Backend_System__c=backend.id;
            cs3.Core_Promote_Status__c = 'Failed';
            cs3.productID=prod.id;
            
            List<Case> csList=new List<Case>();
            csList.add(cs1);
            csList.add(cs2);
            csList.add(cs3);
            system.runas(ListOfUser[0])
            {
                insert csList;
            }
            
            Core_Log_Entry__c log =Core_IPS_Backend_TestClass_Utility.getLogEntry();
            log.Core_sObjectType__c='sf:case';
            log.core_sobjectId__c=cs1.id;
            log.Core_Severity__c='Error';
            log.Core_Project__c='IPS Cloud';
            log.Core_Origin__c='PromoteCase';
            
            //insert log;
            //User u =TestUtilities.getCustomerUser('IPS External Customer');
            
            Core_IPS_Case_Attachments__c att= Core_IPS_Backend_TestClass_Utility.getAttachment();
            att.Core_Upload_Status__c='Complete';
            att.Core_Case__c=cs1.id;
            att.Core_Promote_Status__c = 'Failed';
            att.Core_IPS_Attachment_Visibility__c ='Private to Intel';
            att.Core_FileUploadedby__c = ListOfUser[0].id;
            
            Core_Trigger_Executions__c settings = new Core_Trigger_Executions__c();
            settings.Name = 'InsertCaseCommentForAttach';
            settings.Core_Class_Name__c = 'Core_IPS_CasePromotion_Handler';
            settings.Core_Description__c = 'ABC';
            settings.Core_Object__c = 'Core_IPS_Case_Comments__c';
            settings.Core_Trigger_Events__c = 'After Insert, After update';
            settings.Core_Active__c = True;
            insert settings;
            
            Core_IPS_Labels__c labels = new Core_IPS_Labels__c ();
            labels.name= 'COMPLETE';
            labels.value__c='COMPLETE';
            insert labels;
            
            Core_IPS_Labels__c labels1 = new Core_IPS_Labels__c ();
            labels1.name= 'PUBLIC_TO_CUSTOMERS';
            labels1.value__c='PUBLIC_TO_CUSTOMERS';
            insert labels1;
            
            // Avoid Hardcoding Id Fix - Start - Shipra
            Profile dataMigPrf = [select id, name from Profile where name = 'IPS Data Migration' Limit 1];
            Core_IPS_Labels__c labels2 = new Core_IPS_Labels__c ();
            labels2.name= 'Data Migration Profile Id';
            //labels2.value__c='00eo0000000f7Gd';
            labels2.value__c=dataMigPrf.Id;
            // Avoid Hardcoding Id Fix - End - Shipra
            insert labels2;
            
            Core_IPS_Labels__c labels3 = new Core_IPS_Labels__c ();
            labels3.name= 'PRIVATE_TO_INTEL';
            labels3.value__c='PRIVATE_TO_INTEL';
            insert labels3;
            
            Core_IPS_Labels__c labels4 = new Core_IPS_Labels__c ();
            labels4.name= 'PRIVATE_TO_AGENTS';
            labels4.value__c='PRIVATE_TO_AGENTS';
            insert labels4;
            
            
            Core_IPS_Labels__c label5= new Core_IPS_Labels__c();
            label5.name='Customer';
            label5.value__c='Customer';
            insert label5;
            
            Core_IPS_Labels__c label6 = new Core_IPS_Labels__c ();
            label6.name='FAE';
            label6.value__c='FAE';
            insert label6;
            
            Core_IPS_Labels__c label7 = new Core_IPS_Labels__c();
            label7.name='Agent';
            label7.value__c='Agent';
            insert label7;
            
            Core_IPS_Labels__c label8 = new Core_IPS_Labels__c();
            label8.name='Backend Integration';
            label8.value__c='Backend Integration';
            insert label8;
            
            Core_IPS_Labels__c label91 = new Core_IPS_Labels__c();
            label91.name='Comment Source - Email';
            label91.value__c='Comment Source - Email';
            insert label91;
            
            Core_IPS_Labels__c label9 = new Core_IPS_Labels__c();
            label9.name='Data Migration';
            label9.value__c='Data Migration';
            insert label9;
            
            Core_IPS_Labels__c label10 = new Core_IPS_Labels__c();
            label10.name='Partner';
            label10.value__c='Partner';
            insert label10;
            
            Core_IPS_Labels__c label11 = new Core_IPS_Labels__c();
            label11.name='Partner - DFAE';
            label11.value__c='Partner - DFAE';
            insert label11;
            
            
            Core_IPS_Labels__c   labels111 = new Core_IPS_Labels__c();
            labels111.name= 'Comment Source - Backend System';
            labels111.value__c='Backend System';
            insert labels111;
            
            Core_IPS_Labels__c labels12 = new Core_IPS_Labels__c();
            labels12.name= 'Comment Source - Customer';
            labels12.value__c='Customer Portal';
            insert labels12;
            
            Core_IPS_Labels__c labels13 = new Core_IPS_Labels__c();
            labels13.name= 'Comment Source - Data Migration';
            labels13.value__c='Data Migration';
            insert labels13;
            
            Core_IPS_Labels__c labels15 = new Core_IPS_Labels__c();
            labels15.name= 'Comment Source - Internal';
            labels15.value__c='Internal Portal  ';
            insert labels15;
            
            
            Core_IPS_Labels__c labels16 = new Core_IPS_Labels__c();
            labels16.name= 'Comment Source - N/A';
            labels16.value__c='N/A';
            insert labels16;
            
            
            
            
            
            system.runas(ListOfUser[1])
            {
                //insert att;
            }
            
            Core_IPS_Case_Comments__c comm= Core_IPS_Backend_TestClass_Utility.getCaseComment();
            comm.Core_IPS_Case__c=cs1.id;
            comm.Core_Promote_Status__c='Failed';
            comm.Core_IPS_Comment_Author_Type__c ='Backend Integration';
            system.runas(ListOfUser[2])
            {
                insert comm;
            }
            
            
            Core_Log_Entry__c log1 =Core_IPS_Backend_TestClass_Utility.getLogEntry();
            log1.Core_sObjectType__c='sf:Core_IPS_Case_Comments__c';
            log1.Core_Severity__c='error';
            log1.Core_Project__c='IPS Cloud';
            log1.Core_Origin__c='UpdateCase';
            //insert log1;
            
            Core_Log_Entry__c log2 =Core_IPS_Backend_TestClass_Utility.getLogEntry();
            log2.Core_sObjectType__c='sf:Core_IPS_Case_Attachments__c';
            log2.Core_Severity__c='error';
            log2.Core_Project__c='IPS Cloud';
            log2.Core_Origin__c='UpdateCase';
            //insert log2;
            
            Core_Log_Entry__c log3 =Core_IPS_Backend_TestClass_Utility.getLogEntry();
            log3.Core_sObjectType__c='sf:case';
            log3.core_sobjectId__c=cs2.id;
            log3.Core_Severity__c='error';
            log3.Core_Project__c='IPS Cloud';
            log3.Core_Origin__c='PromoteCase';
            
            List<Core_Log_Entry__c> logList = new List<Core_Log_Entry__c>();
            logList.add(log);
            logList.add(log1);
            logList.add(log2);
            logList.add(log3);
            system.runas(ListOfUser[3])
            {
                insert logList;
            }
            //Core_IPS_CasePromotion_Handler.reProcessFailedPromoteRecords(logList);//3rd Feb 2016--Method is not exist in Core_IPS_CasePromotion_Handler
            
            //Core_IPS_CasePromotion_Handler.getLogEntries();//3rd Feb 2016--Method is not exist in Core_IPS_CasePromotion_Handler
            
            ID[] logids = new List<ID>();
            String testresult;// = Core_IPS_Reprocess_Backend_FailedRecords.reProcessRecords(logIds);
            logids.add(log.id);
            logids.add(log1.id);
            logids.add(log2.id);        
            logids.add(log3.id);
            test.startTest();
            
            testresult = Core_IPS_Reprocess_Backend_FailedRecords.reProcessRecords(logIds);
            
            
            
            system.debug('cs1'+cs1);
            //String testresult1 =Core_IPS_Reprocess_Backend_FailedRecords.reProcessRecordsFromBackSystem(backend.id);
            //start--5th Feb 2016--calling casecomment reprocessing from test class itself
            Core_IPS_Case_Comments__c casecommentobj = new Core_IPS_Case_Comments__c();
            caseCommentobj.id=log1.Core_sObjectId__c;
            
            //sowmya add
            caseCommentobj.Core_Promote_Status__c = 'Failed';
            caseCommentobj.Core_IPS_Case__c = cs1.id;
            // Insert caseCommentobj;
            //sowmya end
            
            Map<id,Core_IPS_Case_Comments__c > mapCaseCommIds=new Map<id,Core_IPS_Case_Comments__c >();
            mapCaseCommIds.put(casecommentobj.id, casecommentobj);
            List<Core_Log_Entry__c > caseCommentLogIds=new List<Core_Log_Entry__c >();
            log1.Core_Severity__c='Processed';
            caseCommentLogIds.add(log1);
            
            Core_IPS_Reprocess_Backend_FailedRecords.reProcessIPSCaseComments(mapCaseCommIds,caseCommentLogIds);
            //End--5th Feb 2016--calling casecomment reprocessing from test class itself
            
           // Core_IPS_Reprocess_Backend_FailedRecords.reProcessRecordsFromBackSystem(backend.id);
            
            
            Map<Id, Core_IPS_Case_Attachments__c> mapAttachment = new Map<Id, Core_IPS_Case_Attachments__c>();
            mapAttachment.put(att.id,att);
            Map<Id, Core_IPS_Case_Comments__c> mapComm = new Map<Id, Core_IPS_Case_Comments__c>();
            mapComm.put(comm.id,comm);        
            Map<Id, case> mapCase= new Map<Id, case>();
            mapCase.put(cs1.id,cs1);                
            //Start--3rd Feb 2016--
            List<Core_IPS_Case_Attachments__c> oldList=new List<Core_IPS_Case_Attachments__c> ();
            List<Core_IPS_Case_Attachments__c> newList=new List<Core_IPS_Case_Attachments__c> ();
            Map<Id,Core_IPS_Case_Attachments__c> oldMap=new Map<Id,Core_IPS_Case_Attachments__c>();
            Map<Id,Core_IPS_Case_Attachments__c> newMap =new Map<Id,Core_IPS_Case_Attachments__c>();
            oldList.add(att);
            newList.add(att);
            newMap.put(att.id,att);
            List<Core_Log_entry__c> testresult2=Core_IPS_Reprocess_Backend_FailedRecords.getLogEntries();
            Core_IPS_CasePromotion_Handler.executeBackendRoutingfromIPSCaseAttachmentTrigger(oldList ,newList,mapAttachment,newMap);
            test.stopTest();
        }
        
    } 
    
    /* This method will test Backend System ReProcess action on all the related Case records
* @param :
* @return: void
* @Last Modified: 26/05/2016
* @Created by: Tanvi Chauhan
* @Reason to Change:
*/
    
    public static testMethod void testReProcessBackendSystem() {
        
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [SELECT id, name FROM Profile WHERE name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        ListOfUser = TestUtilities.getListOfUser(1);
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        Database.insert(ListOfUser);
        System.runAs(ListOfUser[0]){
            // start added by rajeswari for increase the code coverage 22 june 22
            
            Core_IPS_System_Credentails_Apigee__c label17 = new Core_IPS_System_Credentails_Apigee__c();
            label17.Name = 'Core_IPS_Case_Promote';
            label17.Core_IPS_EndPointURL__c = 'Test.org.com';
            insert label17;
            Core_IPS_System_Credentails_Apigee__c label18 = new Core_IPS_System_Credentails_Apigee__c();
            label18.Name = 'Core_IPS_Case_DePromote';
            label18.Core_IPS_EndPointURL__c = 'Test1.org.com';
            insert label18;
            
            Core_IPS_System_Credentails_Apigee__c label19 = new Core_IPS_System_Credentails_Apigee__c();
            label19.Name = 'Core_IPS_Case_FieldUpdate';
            label19.Core_IPS_EndPointURL__c = 'Test2.org.com';
            insert label19;
            
            Core_Trigger_Executions__c label20 =new Core_Trigger_Executions__c();
            label20.Name='myIntelIntegration';
            label20.Core_Active__c=true;
            label20.Core_Class_Name__c='Core_IPS_CaseTriggerHandler';
            label20.Core_Object__c='Case';
            label20.Core_Description__c='MyIntel 3.0';
            label20.Core_Trigger_Events__c='before update, after create';
            insert label20;
            Test.setMock(HttpCalloutMock.class, new IPS_APIGEE_BackendHttpCalloutMock());
            
            // end added by rajeswari for increase the code coverage 22 june 22
            //inserting Product to be associated to Case rec
            Product2 testProduct = Core_IPS_Backend_TestClass_Utility.getProduct();
            testProduct.Core_Product_Org__c='IPS';
            Database.insert(testProduct);
            
            //Inserting Support Org & Backend System
            Core_IPS_Product_Organization__c suppOrg = Core_IPS_Backend_TestClass_Utility.getSupportOrg();
            Database.insert(suppOrg);
            
            Core_IPS_Backend_System__c backendSystem = Core_IPS_Backend_TestClass_Utility.getBackendSystem();
            backendSystem.name='Test Backend System';
            backendSystem.Core_IPS_Support_Org__c=suppOrg.id;
            Database.insert(backendSystem);
            
            //start logic for increase the code coverage by rajeswari 23 july 22 -Commented 4, 8 cases for remove nullpoint exception 
            //inserting Case records for log entries
            List<Case> testCaseRecords = Core_IPS_Backend_TestClass_Utility.getListOfCases(1, 'IPS No Assigned Contact Case', testProduct, backendSystem);
            testCaseRecords[0].Core_Promote_Status__c = 'In Progress';
            //  testCaseRecords[4].Core_Promote_Status__c = 'In Progress';
            //  testCaseRecords[8].Core_Promote_Status__c = 'In Progress';
            testCaseRecords[0].Core_IPS_Backend_Previous_Status__c = 'disassociate';
            
            Database.insert(testCaseRecords);
            // logic for increase the code coverage by rajeswari 23 july 22
            
            Test.startTest();
            String testResult = Core_IPS_Reprocess_Backend_FailedRecords.reProcessRecordsFromBackSystem(backendSystem.id);
            System.assertEquals('Processing completed', testResult);
            Test.stopTest();
        }
        
        
    }
    
    
    /********************************************************************************************************************
Method Name    : preptestdata
Description    : Loads Trigger Execution Custom Settings
Modification Log :
* Developer                           Date                   Description
* ----------------------------------------------------------------------------                 
* Manoj Kumar                        22/Mar/2017             Original Version
*******************************************************************************************************************/  
    
    public static void preptestdata(){
        
        List<Core_Trigger_Executions__c> triggerExecRecordList=new List<Core_Trigger_Executions__c>();
        
        Core_Trigger_Executions__c triggerExecRecord =new Core_Trigger_Executions__c(Core_Active__c=true,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This flag will allow to switch on and off the IPS Case Backend Routing',Core_Object__c='Case',Core_Trigger_Events__c='before insert, before update',Name='enableIPSCaseBackendRouting1');
        Core_Trigger_Executions__c triggerExecRecord1 =new Core_Trigger_Executions__c(Core_Active__c=true,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This flag allows to switch on and off IPS Case Attachment Backend Routing',Core_Object__c='Core_IPS_Case_Attachments__c',Core_Trigger_Events__c='after insert after update',Name='enableIPSCaseAttBackendRouting2');
        Core_Trigger_Executions__c triggerExecRecord2 =new Core_Trigger_Executions__c(Core_Active__c=false,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This flag allows to switch on and off case comment trigger',Core_Object__c='Core_IPS_Case_Attachments__c',Core_Trigger_Events__c='before insert, before update',Name='enableIPSCaseCommentBackendRouting3' );
        Core_Trigger_Executions__c triggerForResp =  new Core_Trigger_Executions__c(Core_Active__c = true,Name='updateEnvDetailsOnCaseFromCoreResponse',Core_Class_Name__c='Core_IPS_Response_Handler',Core_Description__c='This method is used to assign the Core_IPS_Answer__c Field on Core_IPS_Response__c Object From Core_IPS_Answer_Master__c Object',Core_Object__c='Core_IPS_Response__c',Core_Trigger_Events__c='Before Insert, Before Update');
        triggerExecRecordList.add(triggerForResp);
        triggerExecRecordList.add(triggerExecRecord);
        triggerExecRecordList.add(triggerExecRecord1);
        triggerExecRecordList.add(triggerExecRecord2);
        insert triggerExecRecordList;
        
        List<Core_IPSBackendPromoteReprocesing__c>configIdsList=new List<Core_IPSBackendPromoteReprocesing__c>();
        Core_IPSBackendPromoteReprocesing__c configIds=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='X',Name='OVERRIDE');
        Core_IPSBackendPromoteReprocesing__c configIds1=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='2015-08-13 00:00:00',Name='TODATE');
        Core_IPSBackendPromoteReprocesing__c configIds2=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='2015-08-12 00:00:00',Name='FROMDATE');
        configIdsList.add(configIds);
        configIdsList.add(configIds1);
        configIdsList.add(configIds2);
        insert configIdsList;
        
    }
    //====================COverage increse for case promotion handler===============//
    
    static testMethod void executeBackendRoutingTest2()
    {
        // List variables for inserting test data
        List<Case> newList = new List<Case>();
        List<Case> updateList = new List<Case>();
        List<Product2> prodlist = new List<Product2>();
        List<Core_IPS_Product_Organization__c> suppOrgList = new List<Core_IPS_Product_Organization__c>();
        List<Core_IPS_Supported_Product__c> suppProdList = new List<Core_IPS_Supported_Product__c>();
        List <Core_IPS_Backend_Supported_Product_Map__c> backSPList = new List<Core_IPS_Backend_Supported_Product_Map__c>();
        List<Core_IPS_Backend_System__c> backendList = new List<Core_IPS_Backend_System__c>();
        List<Core_IPS_Backend_Field_Mapping__c> BackEndFieldList=new List<Core_IPS_Backend_Field_Mapping__c>();
        List<Core_IPS_Backend_Value_Mapping__c> BackEndValueList = new List<Core_IPS_Backend_Value_Mapping__c>();
        List<Core_IPS_Environment_Details__c> environList=new List<Core_IPS_Environment_Details__c>();
        List<Core_IPS_Environment_Variables__c> envList=new List<Core_IPS_Environment_Variables__c>();
        List<Core_IPS_Assigned_Environment_Variables__c> AssenvList = new List<Core_IPS_Assigned_Environment_Variables__c>();
        
        Core_Trigger_Executions__c triggerForResp =  new Core_Trigger_Executions__c(Core_Active__c = true,Name='updateEnvDetailsOnCaseFromc',Core_Class_Name__c='Core_IPS_Response_Handler',Core_Description__c='This method is used to assign the Core_IPS_Answer__c Field on Core_IPS_Response__c Object From Core_IPS_Answer_Master__c Object',Core_Object__c='Core_IPS_Response__c',Core_Trigger_Events__c='Before Insert, Before Update');
        //triggerExecRecordList.add(triggerForResp);
        insert triggerForResp;
        //systmAdmin profile for creating test data
        String sysAdminProfileID = [select id, name from Profile where name = 'System Administrator' Limit 1].Id;
        
        User sysadmin = TestUtilities.getUser();
        sysadmin.username= 'inteltestuser@intel.com';
        sysadmin.ProfileID =  sysAdminProfileID;
        
        insert sysadmin;
        List<Core_IPS_Response__c> qResList =  new List<Core_IPS_Response__c>();
        //creating test data for product,productOrg,SupportedProduct,SupportProdMap,backendSystem,backendFieldMap,backendValueMap,
        //EnvironDetails,EnvironVariables,AssignEnvironVariables
        if(sysadmin<>null)
        {
            preptestdata();
            
            Product2 prod=Core_IPS_Backend_TestClass_Utility.getProduct();
            prod.Core_Product_Org__c='IPS'; //3rd Feb 2016--Validation if we make IPS Flag visible without setting Core_Product_Org__c='IPS'
            Product2 prod1 = new Product2(Name = 'Test123',Core_Product_Org__c='IPS',Core_Sales_Visible_Flag__c = false, Core_IPS_Visible_Flag_External__c = true,IsActive = true );
            
            prodList.add(prod);
            prodList.add(prod1);
            
            Core_IPS_Product_Organization__c suppOrg=Core_IPS_Backend_TestClass_Utility.getSupportOrg();
            Core_IPS_Product_Organization__c suppOrg1 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'dcg', Core_Organization_Description__c = 'Data Center Group');   
            suppOrgList.add(suppOrg);
            suppOrgList.add(suppOrg1);
            
            //creating test data as SysAdmin
            system.runas(sysadmin)
            {
                insert suppOrgList;
                system.assert(suppOrgList != null); 
                insert prodList;
            }
            
            
            Core_IPS_Supported_Product__c suppProd = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
            suppProd.Core_Product__c=prod.id;
            suppProd.Core_Product_Organization__c=suppOrg.id;
            
            Core_IPS_Supported_Product__c suppProd1 = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
            suppProd1.Core_Product__c=prod.id;
            suppProd1.Core_Product_Organization__c=suppOrg1.id;
            
            suppProdList.add(suppProd);
            suppProdList.add(suppProd1);
            
            Id queRecordId= Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
            
            
            Core_IPS_Question__c envQuest =New Core_IPS_Question__c();
            envQuest.recordtypeId = queRecordId;
            envQuest.Core_IPS_Datatype__c = 'Text';
            envQuest.Core_IPS_Product_Organization__c = suppOrg.id;
            envQuest.Core_IPS_Question__c='operating system';
            
            
            Core_IPS_Question__c envQuest1 =New Core_IPS_Question__c();
            envQuest1.recordtypeId = queRecordId;
            envQuest1.Core_IPS_Datatype__c = 'Text';
            envQuest1.Core_IPS_Product_Organization__c = suppOrg.id;
            envQuest1.Core_IPS_Question__c='bkc_bsp_version';
            
            List<Core_IPS_Question__c> queList = new List<Core_IPS_Question__c>();
            queList.add(envQuest);
            queList.add(envQuest1);
            
            
            
            
            Core_IPS_Backend_System__c backend= Core_IPS_Backend_TestClass_Utility.getBackendSystem();
            backend.name='test';
            backend.Core_IPS_Support_Org__c=suppOrg.id;
            backend.Core_IPS_Support_Case_Field_Update__c=true;
            
            Core_IPS_Backend_System__c backend1= Core_IPS_Backend_TestClass_Utility.getBackendSystem();
            backend1.name='test111';
            backend1.Core_IPS_Support_Org__c=suppOrg1.id;
            backend1.Core_IPS_Support_Case_Field_Update__c=true;
            
            backendList.add(backend);
            backendList.add(backend1); 
            
            //--------------------------for checkIssueCategoriesCriteria----------------------
            Core_IPS_Master_Issue_Category__c masterIssueCat =Core_IPS_Backend_TestClass_Utility.getMasterIssueCategory();
            masterIssueCat.Name='Test'; //5th Feb- for check case external issue category name and master issue category name
            
            //creating test data as SysAdmin
            system.runas(sysadmin)
            {
                insert queList; 
                insert suppProdList;
                insert backendList; 
                insert masterIssueCat;
            }           
            
            Core_IPS_Backend_Supported_Product_Map__c back= Core_IPS_Backend_TestClass_Utility.getBackendId();
            back.Core_IPS_Supported_Product__c=suppProd.id;
            back.core_IPS_backend_System__c= backend.id;
            
            Core_IPS_Backend_Supported_Product_Map__c back1= Core_IPS_Backend_TestClass_Utility.getBackendId();
            back1.Core_IPS_Supported_Product__c=suppProd1.id;
            back1.core_IPS_backend_System__c= backend1.id;
            back1.Core_IPS_Auto_Promote__c = false;
            
            Core_IPS_Backend_Supported_Product_Map__c back2= Core_IPS_Backend_TestClass_Utility.getBackendId();
            back2.Core_IPS_Supported_Product__c=suppProd.id;
            back2.core_IPS_backend_System__c= backend.id;
            back2.Core_IPS_Default__c = true;
            
            backSpList.add(back);
            backSpList.add(back1);
            backSpList.add(back2);
            
            Core_IPS_Answer__c answers =  new Core_IPS_Answer__c();
            answers.Core_IPS_Answer__c = 'chrome';
            answers.Core_IPS_Question__c =envQuest.id;
            answers.Core_IPS_Status__c = 'Active';
            
            Core_IPS_Answer__c answers1 =  new Core_IPS_Answer__c();
            answers1.Core_IPS_Answer__c = 'chrometest';
            answers1.Core_IPS_Question__c =envQuest1.id;
            answers1.Core_IPS_Status__c = 'Active';   
            
            List<Core_IPS_Answer__c> answerList = new list<Core_IPS_Answer__c>();
            answerList.add(answers);
            answerList.add(answers1);    
            
            
            Core_IPS_Product_Issue_Category__c issueCat=Core_IPS_Backend_TestClass_Utility.getCategory();
            issueCat.Core_Supported_Product__c = suppProd.id;
            
            Core_IPS_Assigned_Environment_Variables__c AssEnv=new Core_IPS_Assigned_Environment_Variables__c(Core_IPS_Question__c=envQuest.Id,Core_Supported_Product__c=suppProd.Id, Core_Product_Issue_Sub_Category__c=issueCat.id,Core_Type__c='Product');
            Core_IPS_Assigned_Environment_Variables__c AssEnv1=new Core_IPS_Assigned_Environment_Variables__c(Core_IPS_Question__c=envQuest1.Id,Core_Supported_Product__c=suppProd.Id, Core_Product_Issue_Sub_Category__c=issueCat.id,Core_Type__c='Product');
            
            AssenvList.add(AssEnv);
            AssenvList.add(AssEnv1);
            
            Core_IPS_Backend_Env_Details_Map__c  backEnviMap =Core_IPS_Backend_TestClass_Utility.getBackendEnvironmentMap();
            
            backEnviMap.Core_IPS_Backend_System__c=backend.id; 
            backEnviMap.Core_IPS_Backend_EnvQuestion__c=envQuest.id;
            backEnviMap.Core_IPS_Environment_Variable_Answer__c='chrome';
            
            //creating test data as SysAdmin
            system.runas(sysadmin)
            {
                insert backEnviMap; 
                insert issueCat;
                insert AssEnvList;
                insert backSpList;
                insert answerList;           
            }
            
            
            Asset  Asst=new Asset(Core_Supported_Product__c=suppProd.id,Core_Product_Organization__c=suppOrg.id,Name='Asset1') ;
            system.runas(sysadmin)
            {
                //insert backendCaseCate;
                insert  Asst;  //For case is attached with asset
            }
            
            newList = Core_IPS_Backend_TestClass_Utility.getListOfCases(9,'IPS No Assigned Contact Case',prod,backend);
            for(Case cs : newList){
                
                cs.Core_IPS_Supported_Product__c= suppProd.id;
                cs.Core_IPS_Product_Org1__c=suppOrg.id;
                cs.Core_Case_Issue_Category__c = issueCat.id;
                cs.Core_Case_Issue_Sub_Category__c = issueCat.id;
                cs.Core_External_Issue_Category__c = 'Test';
                cs.Core_Severity__c='Low';
                cs.Status='Open';
                cs.Core_Sub_Status__c='Resolved';
                cs.Description = '';
                cs.Core_CaseType__c = '';
                
            }
            
            newList.get(0).Core_IPS_Backend_System__c=null;
            newList.get(0).Core_ips_Backend_ID__c = null;
            newList.get(0).Core_IPS_gec_flag__c=false;
            
            newList.get(1).Core_IPS_Backend_ID__c='123';
            newList.get(1).Core_Sub_Status__c='Waiting for Customer Response';
            newList.get(1).Core_IPS_gec_flag__c=false;
            newList.get(1).Core_jsonfield__c='{"Env Dtl Resp" : [ {"Qstn" : "bkc_bsp_version","Ansr" : "All in One M;"} ]}';
            
            newList.get(2).assetid=Asst.id;
            newList.get(2).Status='Closed';
            newList.get(2).Core_Sub_Status__c='Resolved';
            newList.get(2).Core_ips_Backend_ID__c = '12345';
            newList.get(2).Core_jsonfield__c='{"Env Dtl Resp" : [ {"Qstn" : "bkc_bsp_version","Ansr" : "All in One;"} ]}';
            
            newList.get(3).Core_IPS_Backend_ID__c='1234';
            newList.get(3).Status='Closed';
            newList.get(3).Core_Sub_Status__c='Resolved';
            newList.get(3).Core_IPS_gec_flag__c=false;
            newList.get(3).Core_jsonfield__c='{"Env Dtl Resp" : [ {"Qstn" : "bkc_bsp_version","Ansr" : "All in One M;"} ]}';
            
            newList.get(4).Core_Promote_Status__c = 'In Progress';
            newList.get(4).Core_IPS_Backend_ID__c = '0';
            newList.get(4).Status='Closed';
            newList.get(4).Core_Sub_Status__c='No Response from Customer';
            
            case cs5 = new case(recordtypeid=Case.getSObjectType().getDescribe().getRecordTypeInfosByName().get('IPS No Assigned Contact Case').getRecordTypeId(),assetid=Asst.id);
            newList.set(5, cs5);
            
            newList.get(6).Core_Promote_Status__c='Promote';
            
            newList.get(7).Core_ips_Backend_ID__c = null;
            newList.get(7).Core_IPS_gec_flag__c=false;
            newList.get(7).Core_Promote_Status__c='Failed';
            
            newList.get(8).Core_IPS_Supported_Product__c= suppProd1.id;
            newList.get(8).Core_IPS_Product_Org1__c=suppOrg1.id;
            newList.get(8).productID=prod.id;
            newList.get(8).Core_ips_Backend_ID__c = null;
            newList.get(8).Core_IPS_gec_flag__c=false;
            
            //creating test Cases as SysAdmin
            system.runas(sysadmin)
            {
                insert(newList);
            }
            
            
            
            Core_IPS_Response__c  cResp = new Core_IPS_Response__c ();
            //cResp.Core_IPS_Survey_Type__c = '';
            cResp.Core_IPS_Question_Master__c = envQuest.id;
            cResp.Core_IPS_Answer_Master__c = answers.id;
            cResp.Core_IPS_Case__c =newList.get(0).id; 
            
            Core_IPS_Response__c  cResp1 = new Core_IPS_Response__c ();
            //cResp1.Core_IPS_Survey_Type__c = '';
            cResp1.Core_IPS_Question_Master__c = envQuest1.id;
            cResp1.Core_IPS_Answer_Master__c = answers1.id;
            cResp1.Core_IPS_Case__c =newList.get(0).id; 
            
            
            
            
            qResList.add(cResp);
            qResList.add(cResp1);
        }    
        //creating test data as SysAdmin
        system.runas(sysadmin)
        {   
            
            //insert att;// Creating attachment to execute BackendRouting Logic from 'Core_IPS_Case_Attachments' Trigger
            insert qResList;
            
        }           
        
    }
    
    //********Added to cover the newly added backend system logics*******//
    
    static testMethod void executeBackendRoutingTestissue1()
    {
        List<Case> newList = new List<Case>();
        Map<Id,Case> newMap = new Map<Id, Case>();
        List<Case> oldList = new List<Case>();
        Map<Id, Case> oldMap = new Map<Id, Case>();
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        ListOfUser = TestUtilities.getListOfUser(10);
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert ListOfUser;
        if(ListOfUser<>null &&ListOfUser.size()<=10)
        {
            test.startTest();
            List<Core_Trigger_Executions__c> triggerExecRecordList=new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c triggerExecRecord =new Core_Trigger_Executions__c(Core_Active__c=true,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This flag will allow to switch on and off the IPS Case Backend Routing',Core_Object__c='Case',Core_Trigger_Events__c='before insert, before update',Name='enableIPSCaseBackendRouting');
            Core_Trigger_Executions__c triggerExecRecord1 =new Core_Trigger_Executions__c(Core_Active__c=true,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This fl;ag allows to switch on and off IPS Case Attachment Backend Routing',Core_Object__c='Core_IPS_Case_Attachments__c',Core_Trigger_Events__c='after insert after update',Name='enableIPSCaseAttBackendRouting');
            Core_Trigger_Executions__c triggerExecRecord2 =new Core_Trigger_Executions__c(Core_Active__c=false,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This flag allows to switch on and off case comment trigger',Core_Object__c='Core_IPS_Case_Attachments__c',Core_Trigger_Events__c='before insert, before update',Name='enableIPSCaseCommentBackendRouting' );
            Core_Trigger_Executions__c triggerForResp =  new Core_Trigger_Executions__c(Core_Active__c = true,Name='updateEnvDetailsOnCaseFromCoreResponse',Core_Class_Name__c='Core_IPS_Response_Handler',Core_Description__c='This method is used to assign the Core_IPS_Answer__c Field on Core_IPS_Response__c Object From Core_IPS_Answer_Master__c Object',Core_Object__c='Core_IPS_Response__c',Core_Trigger_Events__c='Before Insert, Before Update');
            triggerExecRecordList.add(triggerForResp);
            triggerExecRecordList.add(triggerExecRecord);
            triggerExecRecordList.add(triggerExecRecord1);
            triggerExecRecordList.add(triggerExecRecord2);
            insert triggerExecRecordList;
            system.assert(triggerExecRecordList != null);
            List<Core_IPSBackendPromoteReprocesing__c>configIdsList=new List<Core_IPSBackendPromoteReprocesing__c>();
            Core_IPSBackendPromoteReprocesing__c configIds=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='X',Name='OVERRIDE');
            Core_IPSBackendPromoteReprocesing__c configIds1=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='2015-08-13 00:00:00',Name='TODATE');
            Core_IPSBackendPromoteReprocesing__c configIds2=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='2015-08-12 00:00:00',Name='FROMDATE');
            configIdsList.add(configIds);
            configIdsList.add(configIds1);
            configIdsList.add(configIds2);
            insert configIdsList;
            case cs1=new Case();    
            
            List<Core_IPS_Product_Organization__c> suppOrgList = new List<Core_IPS_Product_Organization__c>();
            Core_IPS_Product_Organization__c suppOrg=Core_IPS_Backend_TestClass_Utility.getSupportOrg();
            Core_IPS_Product_Organization__c suppOrg1 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'dcg', Core_Organization_Description__c = 'Data Center Group'); 
            Core_IPS_Product_Organization__c suppOrg2 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'Ics', Core_Organization_Description__c = 'Intel customer Support');   
            Core_IPS_Product_Organization__c suppOrg3 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'Ics1', Core_Organization_Description__c = 'Intel customer Support1');   
            Core_IPS_Product_Organization__c suppOrg4 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'Ics2', Core_Organization_Description__c = 'Intel customer Support2');   
            suppOrgList.add(suppOrg);
            suppOrgList.add(suppOrg1);
            suppOrgList.add(suppOrg2);
            suppOrgList.add(suppOrg3);
            suppOrgList.add(suppOrg4);
            system.runas(ListOfUser[0])
            {
                insert suppOrgList; 
            }
            
            
            
            
            
            Id queRecordId= Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
            
            
            //Core_IPS_Environment_Variables__c eviSuppOrg= Core_IPS_Backend_TestClass_Utility.getEnvidetialsForSuppOrg();
            Core_IPS_Question__c envQuest =New Core_IPS_Question__c();
            envQuest.recordtypeId = queRecordId;
            envQuest.Core_IPS_Datatype__c = 'Text';
            envQuest.Core_IPS_Product_Organization__c = suppOrg.id;
            envQuest.Core_IPS_Question__c='operating system';
            //insert envQuest;
            
            //eviSuppOrg.Core_Product_Organization__c=suppOrg.id;
            
            
            Core_IPS_Question__c envQuest1 =New Core_IPS_Question__c();
            envQuest1.recordtypeId = queRecordId;
            envQuest1.Core_IPS_Datatype__c = 'Text';
            envQuest1.Core_IPS_Product_Organization__c = suppOrg.id;
            envQuest1.Core_IPS_Question__c='bkc_bsp_version';
            
            
            
            Core_IPS_Question__c envQuest2 =New Core_IPS_Question__c();
            envQuest2.recordtypeId = queRecordId;
            envQuest2.Core_IPS_Datatype__c = 'Text';
            envQuest2.Core_IPS_Product_Organization__c = suppOrg4.id;
            envQuest2.Core_IPS_Question__c='operating system';
            
            
            Core_IPS_Question__c envQuest3 =New Core_IPS_Question__c();
            envQuest2.recordtypeId = queRecordId;
            envQuest3.Core_IPS_Datatype__c = 'Text';
            envQuest3.Core_IPS_Product_Organization__c = suppOrg4.id;
            envQuest3.Core_IPS_Question__c='bkc_bsp_version';
            
            
            
            //List<Core_IPS_Environment_Variables__c> envList=new List<Core_IPS_Environment_Variables__c>();
            List<Core_IPS_Question__c> queList = new List<Core_IPS_Question__c>();
            queList.add(envQuest);
            queList.add(envQuest1);
            queList.add(envQuest2);
            queList.add(envQuest3);
            system.runas(ListOfUser[1])
            {
                insert queList;  
            }
            //        Core_IPS_Product_Organization__c suppOrg1=Core_IPS_Backend_TestClass_Utility.getSupportOrg();
            //        system.runas(ListOfUser[2])
            //        {
            //            insert suppOrg1;     
            //        }  
            
            Core_IPS_Answer__c answers =  new Core_IPS_Answer__c();
            answers.Core_IPS_Answer__c = 'chrome';
            answers.Core_IPS_Question__c =envQuest.id;
            answers.Core_IPS_Status__c = 'Active';
            
            Core_IPS_Answer__c answers1 =  new Core_IPS_Answer__c();
            answers1.Core_IPS_Answer__c = 'chrometest';
            answers1.Core_IPS_Question__c =envQuest1.id;
            answers1.Core_IPS_Status__c = 'Active';
            
            Core_IPS_Answer__c answers2 =  new Core_IPS_Answer__c();
            answers2.Core_IPS_Answer__c = 'chrome';
            answers2.Core_IPS_Question__c =envQuest2.id;
            answers2.Core_IPS_Status__c = 'Active';
            
            Core_IPS_Answer__c answers3 =  new Core_IPS_Answer__c();
            answers3.Core_IPS_Answer__c = 'chrometest';
            answers3.Core_IPS_Question__c =envQuest3.id;
            answers3.Core_IPS_Status__c = 'Active';
            
            List<Core_IPS_Answer__c> answerList = new list<Core_IPS_Answer__c>();
            answerList.add(answers);
            answerList.add(answers1);
            answerList.add(answers2);
            answerList.add(answers3);
            
            system.runas(ListOfUser[1])
            {
                insert answerList;  
            }                    
            
            List<Product2> prodlist = new List<Product2>();
            
            
            Product2 prod4= new Product2(Name = 'SkyLake',Core_Sales_Visible_Flag__c = false, Core_IPS_Visible_Flag_External__c = true,IsActive = true );
            prod4.Core_Product_Org__c='IPS';
            
            prodList.add(prod4);
            system.runas(ListOfUser[3])
            {
                insert prodList;
            }
            
            List<Core_IPS_Supported_Product__c> suppProdList = new List<Core_IPS_Supported_Product__c>();
            
            
            Core_IPS_Supported_Product__c suppProd4 = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
            suppProd4.Core_Product__c=prod4.id;
            suppProd4.Core_Product_Organization__c=suppOrg4.id;
            suppProdList.add(suppProd4);
            
            
            system.runas(ListOfUser[4])
            {
                //insert suppProd;
                insert suppProdList;
            }
            
            Group testGroup = new Group(Name='test group', Type='Queue');
            insert testGroup;
            
            System.runAs(ListOfUser[5])
            {
                QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
                insert testQueue;
            }
            
            
            List<Core_IPS_Assigned_Environment_Variables__c> AssenvList = new List<Core_IPS_Assigned_Environment_Variables__c>();
            
            
            Core_IPS_Assigned_Environment_Variables__c AssEnv2=new Core_IPS_Assigned_Environment_Variables__c(Core_IPS_Question__c=envQuest2.Id,Core_Supported_Product__c=suppProd4.Id, Core_Type__c='Product');
            AssenvList.add(AssEnv2);
            
            Core_IPS_Assigned_Environment_Variables__c AssEnv3=new Core_IPS_Assigned_Environment_Variables__c(Core_IPS_Question__c=envQuest3.Id,Core_Supported_Product__c=suppProd4.Id, Core_Type__c='Product');
            AssenvList.add(AssEnv3);
            
            system.runas(ListOfUser[5])
            {
                insert AssEnvList;
            } 
            list<Core_IPS_Product_Issue_Category__c> issuList =  new list<Core_IPS_Product_Issue_Category__c >();           
            
            Core_IPS_Product_Issue_Category__c issueCat1=Core_IPS_Backend_TestClass_Utility.getCategory();
            issueCat1.Core_Supported_Product__c = suppProd4.id;
            issuList.add(issueCat1);
            system.runas(ListOfUser[6])
            {
                insert issuList; 
            }           
            
            List<Core_IPS_Backend_System__c> backendList = new List<Core_IPS_Backend_System__c>();
            
            
            Core_IPS_Backend_System__c backend3= Core_IPS_Backend_TestClass_Utility.getBackendSystem();
            backend3.name='test1111';
            backend3.Core_IPS_Routing_Technique__c = 'Product';
            backend3.Core_IPS_Support_Org__c=suppOrg4.id;
            backend3.Core_IPS_Support_Case_Field_Update__c=true;
            backendList.add(backend3);
            
            Core_IPS_Backend_System__c backend4= Core_IPS_Backend_TestClass_Utility.getBackendSystem();
            backend4.name='test11111';
            backend4.Core_IPS_Routing_Technique__c = 'Product';
            backend4.Core_IPS_Support_Org__c=suppOrg1.id;
            backend4.Core_IPS_Support_Case_Field_Update__c=true;
            backendList.add(backend4);
            
            
            
            system.runas(ListOfUser[7])
            {
                insert backendList;
            }
            
            string bid = backend3.id;
            string b1id = backend4.id;
            //string b2id = backend2.id;
            List<Core_IPSBackendPromoteReprocesing__c>configIdsList1=new List<Core_IPSBackendPromoteReprocesing__c>();
            Core_IPSBackendPromoteReprocesing__c configId1=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='Backend System',Core_Translate_Value__c=bid ,Name=backend3.name);
            Core_IPSBackendPromoteReprocesing__c configId2=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='Backend System',Core_Translate_Value__c=b1id ,Name=backend4.name);
            //Core_IPSBackendPromoteReprocesing__c configId3=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='Backend System',Core_Translate_Value__c=b2id ,Name=backend2.name);
            
            configIdsList1.add(configId1);
            configIdsList1.add(configId2);
            //configIdsList1.add(configId3);
            insert configIdsList1;
            
            
            
            List <Core_IPS_Backend_Supported_Product_Map__c> backSPList = new List<Core_IPS_Backend_Supported_Product_Map__c>();
            
            Core_IPS_Backend_Supported_Product_Map__c back4= Core_IPS_Backend_TestClass_Utility.getBackendId();
            back4.Core_IPS_Supported_Product__c=suppProd4.id;
            back4.core_IPS_backend_System__c= backend3.id;
            back4.Core_IPS_Auto_Promote__c = true;
            backSpList.add(back4);
            
            system.runas(ListOfUser[8])
            {
                insert backSpList;
            }
            
            list<Core_IPS_Backend_Env_Details_Map__c > envMpList =  new list<Core_IPS_Backend_Env_Details_Map__c >();       
            
            
            Core_IPS_Backend_Env_Details_Map__c  backEnviMap1 =Core_IPS_Backend_TestClass_Utility.getBackendEnvironmentMap();
            
            // Question and answer
            backEnviMap1.Core_IPS_Backend_System__c=backend3.id; 
            backEnviMap1.Core_IPS_Backend_EnvQuestion__c=envQuest3.id;
            backEnviMap1.Core_IPS_Environment_Variable_Answer__c='chrometest';
            envMpList.add(backEnviMap1);
            
            
            system.runas(ListOfUser[9])
            {
                insert envMpList;
            }
            //--------------------------for checkIssueCategoriesCriteria----------------------
            Core_IPS_Master_Issue_Category__c masterIssueCat =Core_IPS_Backend_TestClass_Utility.getMasterIssueCategory();
            masterIssueCat.Name='Test'; //5th Feb- for check case external issue category name and master issue category name
            system.runas(ListOfUser[0])
            {
                insert masterIssueCat;
            }
            
            Core_IPS_Backend_Case_Categories_Map__c  backendCaseCate = Core_IPS_Backend_TestClass_Utility.getCaseCategories();
            backendCaseCate.Core_IPS_Case_Category__c=masterIssueCat.id;
            //commented below line by tchauhan
            //backendCaseCate.Core_IPS_Backend_SP_Map__c=back1.id;  
            backendCaseCate.Core_IPS_Backend_SP_Map__c = backSpList[0].id;
            system.runas(ListOfUser[1])
            {
                //insert backendCaseCate;
            }
            
            
            
            RecordType rType =  [Select r.Name, r.DeveloperName,r.id From RecordType r where r.DeveloperName = 'Core_IPS_Case_Create_Self_Assigned' Limit 1];      
            
            
            
            
            
            Case cs15=new case();
            cs15.Core_IPS_Supported_Product__c= suppProd4.id;
            cs15.Core_IPS_Product_Org1__c=suppOrg4.id;
            cs15.productID=prod4.id;
            cs15.OwnerId = testGroup.Id;
            cs15.Core_severity__c= 'Low';
            cs15.recordtypeid=rType.id;
            //Adding case Status and SubStatus -- Manoj Kumar
            cs15.Status='Open';
            cs15.Core_Sub_Status__c='Investigating';
            cs15.Core_Case_Issue_Category__c = issueCat1.id;
            cs15.Core_Case_Issue_Sub_Category__c = issueCat1.id;
            cs15.Core_External_Issue_Category__c = 'Test';
            cs15.Core_IPS_Backend_ID__c = '12121';
            
            system.runas(ListOfUser[3])
            {
                insert cs15;
            }
            
            case c = [select id from case where id =:cs15.id limit 1];
            
            case cs4 =  new case();
            cs4.id =c.id; 
            cs4.Core_IPS_Backend_System__c=backend4.id;
            string idofback='1234';
            cs4.Core_IPS_Backend_ID__c=idofback;
            
            system.runas(ListOfUser[3])
            {
                Update cs4;
            }
            
            
            
            
            Core_IPS_Response__c  cResp = new Core_IPS_Response__c ();
            //cResp.Core_IPS_Survey_Type__c = '';
            cResp.Core_IPS_Question_Master__c = envQuest.id;
            cResp.Core_IPS_Answer_Master__c = answers.id;
            cResp.Core_IPS_Case__c =cs15.id; 
            
            Core_IPS_Response__c  cResp1 = new Core_IPS_Response__c ();
            //cResp1.Core_IPS_Survey_Type__c = '';
            cResp1.Core_IPS_Question_Master__c = envQuest1.id;
            cResp1.Core_IPS_Answer_Master__c = answers1.id;
            cResp1.Core_IPS_Case__c =cs15.id; 
            
            List<Core_IPS_Response__c> qResList =  new List<Core_IPS_Response__c>();
            
            
            qResList.add(cResp);
            qResList.add(cResp1);
            
            system.runas(ListOfUser[4])
            {
                insert qResList;
                
            }  
            
            
            test.stopTest();
        }  
        
    }
    
    
    static testMethod void executeBackendRoutingTestElse()
    {
        List<Case> newList = new List<Case>();
        Map<Id,Case> newMap = new Map<Id, Case>();
        List<Case> oldList = new List<Case>();
        Map<Id, Case> oldMap = new Map<Id, Case>();
        Map<String,ID> profiles = new Map<String,ID>();
        List<Profile> ProfileList = [select id, name from Profile where name = 'System Administrator'];
        for(Profile prf : ProfileList){
            profiles.put(prf.name, prf.id);
        }
        ListOfUser = TestUtilities.getListOfUser(10);
        for(User Usr : ListOfUser){
            Usr.ProfileID =  profiles.get('System Administrator');
        }
        insert ListOfUser;
        if(ListOfUser<>null &&ListOfUser.size()<=10)
        {
            // start added by rajeswari for increase the code coverage 22 june 22
            Core_IPS_System_Credentails_Apigee__c label16 = new Core_IPS_System_Credentails_Apigee__c();
            label16.Name = 'Core_IPS_CaseComment_Update';
            label16.Core_IPS_EndPointURL__c = 'Test.org.com';
            insert label16;
            Core_IPS_System_Credentails_Apigee__c label17 = new Core_IPS_System_Credentails_Apigee__c();
            label17.Name = 'Core_IPS_Case_Promote';
            label17.Core_IPS_EndPointURL__c = 'Test.org.com';
            insert label17;
            Core_IPS_System_Credentails_Apigee__c label18 = new Core_IPS_System_Credentails_Apigee__c();
            label18.Name = 'Core_IPS_Case_DePromote';
            label18.Core_IPS_EndPointURL__c = 'Test1.org.com';
            insert label18;
            
            Core_IPS_System_Credentails_Apigee__c label19 = new Core_IPS_System_Credentails_Apigee__c();
            label19.Name = 'Core_IPS_Case_FieldUpdate';
            label19.Core_IPS_EndPointURL__c = 'Test2.org.com';
            insert label19;
            
            Core_Trigger_Executions__c label20 =new Core_Trigger_Executions__c();
            label20.Name='myIntelIntegration';
            label20.Core_Active__c=true;
            label20.Core_Class_Name__c='Core_IPS_CaseTriggerHandler';
            label20.Core_Object__c='Case';
            label20.Core_Description__c='MyIntel 3.0';
            label20.Core_Trigger_Events__c='before update, after create';
            insert label20;
            Test.setMock(HttpCalloutMock.class, new IPS_APIGEE_BackendHttpCalloutMock());
            
            // end added by rajeswari for increase the code coverage 22 june 22
            List<Core_Trigger_Executions__c> triggerExecRecordList=new List<Core_Trigger_Executions__c>();
            Core_Trigger_Executions__c triggerExecRecord =new Core_Trigger_Executions__c(Core_Active__c=true,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This flag will allow to switch on and off the IPS Case Backend Routing',Core_Object__c='Case',Core_Trigger_Events__c='before insert, before update',Name='enableIPSCaseBackendRouting');
            Core_Trigger_Executions__c triggerExecRecord1 =new Core_Trigger_Executions__c(Core_Active__c=true,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This fl;ag allows to switch on and off IPS Case Attachment Backend Routing',Core_Object__c='Core_IPS_Case_Attachments__c',Core_Trigger_Events__c='after insert after update',Name='enableIPSCaseAttBackendRouting');
            Core_Trigger_Executions__c triggerExecRecord2 =new Core_Trigger_Executions__c(Core_Active__c=false,Core_Class_Name__c='Core_IPS_CasePromotion_Handler',Core_Description__c='This flag allows to switch on and off case comment trigger',Core_Object__c='Core_IPS_Case_Attachments__c',Core_Trigger_Events__c='before insert, before update',Name='enableIPSCaseCommentBackendRouting' );
            Core_Trigger_Executions__c triggerForResp =  new Core_Trigger_Executions__c(Core_Active__c = true,Name='updateEnvDetailsOnCaseFromCoreResponse',Core_Class_Name__c='Core_IPS_Response_Handler',Core_Description__c='This method is used to assign the Core_IPS_Answer__c Field on Core_IPS_Response__c Object From Core_IPS_Answer_Master__c Object',Core_Object__c='Core_IPS_Response__c',Core_Trigger_Events__c='Before Insert, Before Update');
            triggerExecRecordList.add(triggerForResp);
            triggerExecRecordList.add(triggerExecRecord);
            triggerExecRecordList.add(triggerExecRecord1);
            triggerExecRecordList.add(triggerExecRecord2);
            insert triggerExecRecordList;
            system.assert(triggerExecRecordList != null);
            List<Core_IPSBackendPromoteReprocesing__c>configIdsList=new List<Core_IPSBackendPromoteReprocesing__c>();
            Core_IPSBackendPromoteReprocesing__c configIds=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='X',Name='OVERRIDE');
            Core_IPSBackendPromoteReprocesing__c configIds1=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='2015-08-13 00:00:00',Name='TODATE');
            Core_IPSBackendPromoteReprocesing__c configIds2=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='MANUALPROCESSING',Core_Translate_Value__c='2015-08-12 00:00:00',Name='FROMDATE');
            configIdsList.add(configIds);
            configIdsList.add(configIds1);
            configIdsList.add(configIds2);
            insert configIdsList;
            case cs1=new Case();    
            
            List<Core_IPS_Product_Organization__c> suppOrgList = new List<Core_IPS_Product_Organization__c>();
            Core_IPS_Product_Organization__c suppOrg=Core_IPS_Backend_TestClass_Utility.getSupportOrg();
            Core_IPS_Product_Organization__c suppOrg1 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'dcg', Core_Organization_Description__c = 'Data Center Group'); 
            Core_IPS_Product_Organization__c suppOrg2 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'Ics', Core_Organization_Description__c = 'Intel customer Support');   
            Core_IPS_Product_Organization__c suppOrg3 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'Ics1', Core_Organization_Description__c = 'Intel customer Support1');   
            Core_IPS_Product_Organization__c suppOrg4 = new Core_IPS_Product_Organization__c(Core_IPS_Support_Org_Name__c = 'Ics2', Core_Organization_Description__c = 'Intel customer Support2');   
            suppOrgList.add(suppOrg);
            suppOrgList.add(suppOrg1);
            suppOrgList.add(suppOrg2);
            suppOrgList.add(suppOrg3);
            suppOrgList.add(suppOrg4);
            system.runas(ListOfUser[0])
            {
                insert suppOrgList; 
            }
            
            
            
            Id queRecordId= Schema.SObjectType.Core_IPS_Question__c.getRecordTypeInfosByName().get('Environment Detail Question').getRecordTypeId();
            
            
            //Core_IPS_Environment_Variables__c eviSuppOrg= Core_IPS_Backend_TestClass_Utility.getEnvidetialsForSuppOrg();
            Core_IPS_Question__c envQuest =New Core_IPS_Question__c();
            envQuest.recordtypeId = queRecordId;
            envQuest.Core_IPS_Datatype__c = 'Text';
            envQuest.Core_IPS_Product_Organization__c = suppOrg.id;
            envQuest.Core_IPS_Question__c='operating system';
            //insert envQuest;
            
            //eviSuppOrg.Core_Product_Organization__c=suppOrg.id;
            
            
            Core_IPS_Question__c envQuest1 =New Core_IPS_Question__c();
            envQuest1.recordtypeId = queRecordId;
            envQuest1.Core_IPS_Datatype__c = 'Text';
            envQuest1.Core_IPS_Product_Organization__c = suppOrg.id;
            envQuest1.Core_IPS_Question__c='bkc_bsp_version';
            
            
            
            Core_IPS_Question__c envQuest2 =New Core_IPS_Question__c();
            envQuest2.recordtypeId = queRecordId;
            envQuest2.Core_IPS_Datatype__c = 'Text';
            envQuest2.Core_IPS_Product_Organization__c = suppOrg4.id;
            envQuest2.Core_IPS_Question__c='operating system';
            
            
            Core_IPS_Question__c envQuest3 =New Core_IPS_Question__c();
            envQuest2.recordtypeId = queRecordId;
            envQuest3.Core_IPS_Datatype__c = 'Text';
            envQuest3.Core_IPS_Product_Organization__c = suppOrg4.id;
            envQuest3.Core_IPS_Question__c='bkc_bsp_version';
            
            
            
            //List<Core_IPS_Environment_Variables__c> envList=new List<Core_IPS_Environment_Variables__c>();
            List<Core_IPS_Question__c> queList = new List<Core_IPS_Question__c>();
            queList.add(envQuest);
            queList.add(envQuest1);
            queList.add(envQuest2);
            queList.add(envQuest3);
            system.runas(ListOfUser[1])
            {
                insert queList;  
            }      
            
            Core_IPS_Answer__c answers =  new Core_IPS_Answer__c();
            answers.Core_IPS_Answer__c = 'chrome';
            answers.Core_IPS_Question__c =envQuest.id;
            answers.Core_IPS_Status__c = 'Active';
            
            Core_IPS_Answer__c answers1 =  new Core_IPS_Answer__c();
            answers1.Core_IPS_Answer__c = 'chrometest';
            answers1.Core_IPS_Question__c =envQuest1.id;
            answers1.Core_IPS_Status__c = 'Active';
            
            Core_IPS_Answer__c answers2 =  new Core_IPS_Answer__c();
            answers2.Core_IPS_Answer__c = 'chrome';
            answers2.Core_IPS_Question__c =envQuest2.id;
            answers2.Core_IPS_Status__c = 'Active';
            
            Core_IPS_Answer__c answers3 =  new Core_IPS_Answer__c();
            answers3.Core_IPS_Answer__c = 'chrometest';
            answers3.Core_IPS_Question__c =envQuest3.id;
            answers3.Core_IPS_Status__c = 'Active';
            
            List<Core_IPS_Answer__c> answerList = new list<Core_IPS_Answer__c>();
            answerList.add(answers);
            answerList.add(answers1);
            answerList.add(answers2);
            answerList.add(answers3);
            
            system.runas(ListOfUser[1])
            {
                insert answerList;  
            }           
            
            
            
            List<Product2> prodlist = new List<Product2>();
            Product2 prod=Core_IPS_Backend_TestClass_Utility.getProduct();
            prod.Core_Product_Org__c='IPS'; //3rd Feb 2016--Validation if we make IPS Flag visible without setting Core_Product_Org__c='IPS'
            Product2 prod1 = new Product2(Name = 'sofia',Core_Sales_Visible_Flag__c = false, Core_IPS_Visible_Flag_External__c = true,IsActive = true );
            prod1.Core_Product_Org__c='IPS';
            Product2 prod2 = new Product2(Name = 'Kits',Core_Sales_Visible_Flag__c = false, Core_IPS_Visible_Flag_External__c = true,IsActive = true );
            prod2.Core_Product_Org__c='IPS';
            Product2 prod3 = new Product2(Name = 'Server',Core_Sales_Visible_Flag__c = false, Core_IPS_Visible_Flag_External__c = true,IsActive = true );
            prod3.Core_Product_Org__c='IPS';
            Product2 prod4= new Product2(Name = 'SkyLake',Core_Sales_Visible_Flag__c = false, Core_IPS_Visible_Flag_External__c = true,IsActive = true );
            prod4.Core_Product_Org__c='IPS';
            prodList.add(prod);
            prodList.add(prod1);
            prodList.add(prod2);
            prodList.add(prod3);
            prodList.add(prod4);
            system.runas(ListOfUser[3])
            {
                insert prodList;
            }
            
            List<Core_IPS_Supported_Product__c> suppProdList = new List<Core_IPS_Supported_Product__c>();
            Core_IPS_Supported_Product__c suppProd = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
            suppProd.Core_Product__c=prod.id;
            suppProd.Core_Product_Organization__c=suppOrg.id;
            suppProdList.add(suppProd);
            
            Core_IPS_Supported_Product__c suppProd1 = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
            suppProd1.Core_Product__c=prod1.id;
            suppProd1.Core_Product_Organization__c=suppOrg1.id;
            suppProdList.add(suppProd1);  
            
            Core_IPS_Supported_Product__c suppProd2 = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
            suppProd2.Core_Product__c=prod2.id;
            suppProd2.Core_Product_Organization__c=suppOrg2.id;
            suppProdList.add(suppProd2); 
            
            Core_IPS_Supported_Product__c suppProd3 = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
            suppProd3.Core_Product__c=prod3.id;
            suppProd3.Core_Product_Organization__c=suppOrg3.id;
            suppProdList.add(suppProd3);
            
            Core_IPS_Supported_Product__c suppProd4 = Core_IPS_Backend_TestClass_Utility.getSupportedProduct();
            suppProd4.Core_Product__c=prod4.id;
            suppProd4.Core_Product_Organization__c=suppOrg4.id;
            suppProdList.add(suppProd4);
            
            
            system.runas(ListOfUser[4])
            {
                //insert suppProd;
                insert suppProdList;
            }
            
            Group testGroup = new Group(Name='test group', Type='Queue');
            insert testGroup;
            
            System.runAs(ListOfUser[5])
            {
                QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
                insert testQueue;
            }
            
            
            List<Core_IPS_Assigned_Environment_Variables__c> AssenvList = new List<Core_IPS_Assigned_Environment_Variables__c>();
            Core_IPS_Assigned_Environment_Variables__c AssEnv=new Core_IPS_Assigned_Environment_Variables__c(Core_IPS_Question__c=envQuest.Id,Core_Supported_Product__c=suppProd.Id, Core_Type__c='Product');
            AssenvList.add(AssEnv);
            Core_IPS_Assigned_Environment_Variables__c AssEnv1=new Core_IPS_Assigned_Environment_Variables__c(Core_IPS_Question__c=envQuest1.Id,Core_Supported_Product__c=suppProd.Id, Core_Type__c='Product');
            AssenvList.add(AssEnv1);
            
            Core_IPS_Assigned_Environment_Variables__c AssEnv2=new Core_IPS_Assigned_Environment_Variables__c(Core_IPS_Question__c=envQuest2.Id,Core_Supported_Product__c=suppProd4.Id, Core_Type__c='Product');
            AssenvList.add(AssEnv2);
            
            system.runas(ListOfUser[5])
            {
                insert AssEnvList;
            } 
            list<Core_IPS_Product_Issue_Category__c> issuList =  new list<Core_IPS_Product_Issue_Category__c >();           
            Core_IPS_Product_Issue_Category__c issueCat=Core_IPS_Backend_TestClass_Utility.getCategory();
            issueCat.Core_Supported_Product__c = suppProd.id;
            issuList.add(issueCat);
            Core_IPS_Product_Issue_Category__c issueCat1=Core_IPS_Backend_TestClass_Utility.getCategory();
            issueCat1.Core_Supported_Product__c = suppProd4.id;
            issuList.add(issueCat1);
            system.runas(ListOfUser[6])
            {
                insert issuList; 
            }           
            
            List<Core_IPS_Backend_System__c> backendList = new List<Core_IPS_Backend_System__c>();
            Core_IPS_Backend_System__c backend= Core_IPS_Backend_TestClass_Utility.getBackendSystem();
            backend.Core_IPS_Routing_Technique__c = 'Product';
            backend.name='test';
            backend.Core_IPS_Support_Org__c=suppOrg.id;
            backend.Core_IPS_Support_Case_Field_Update__c=true;
            backendList.add(backend);
            
            Core_IPS_Backend_System__c backend1= Core_IPS_Backend_TestClass_Utility.getBackendSystem();
            backend1.name='test111';
            backend1.Core_IPS_Routing_Technique__c = 'Product';
            backend1.Core_IPS_Support_Org__c=suppOrg1.id;
            backend1.Core_IPS_Support_Case_Field_Update__c=true;
            backendList.add(backend1); 
            
            Core_IPS_Backend_System__c backend2= Core_IPS_Backend_TestClass_Utility.getBackendSystem();
            backend2.name='testQueue';
            backend2.Core_IPS_Routing_Technique__c = 'Queue';
            //backend2.Core_IPS_Support_Org__c=suppOrg2.id;
            backend2.Core_IPS_Support_Case_Field_Update__c=true;
            backendList.add(backend2);
            
            system.runas(ListOfUser[7])
            {
                insert backendList;
            }
            string bid = backend.id;
            string b1id = backend1.id;
            string b2id = backend2.id;
            List<Core_IPSBackendPromoteReprocesing__c>configIdsList1=new List<Core_IPSBackendPromoteReprocesing__c>();
            Core_IPSBackendPromoteReprocesing__c configId1=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='Backend System',Core_Translate_Value__c=bid ,Name=backend.name);
            Core_IPSBackendPromoteReprocesing__c configId2=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='Backend System',Core_Translate_Value__c=b1id ,Name=backend1.name);
            Core_IPSBackendPromoteReprocesing__c configId3=new Core_IPSBackendPromoteReprocesing__c (Core_Group_Lookup_Name__c='Backend System',Core_Translate_Value__c=b2id ,Name=backend2.name);
            
            configIdsList1.add(configId1);
            configIdsList1.add(configId2);
            configIdsList1.add(configId3);
            insert configIdsList1;
            
            List <Core_IPS_Backend_Supported_Product_Map__c> backSPList = new List<Core_IPS_Backend_Supported_Product_Map__c>();
            Core_IPS_Backend_Supported_Product_Map__c back= Core_IPS_Backend_TestClass_Utility.getBackendId();
            back.Core_IPS_Supported_Product__c=suppProd.id;
            back.core_IPS_backend_System__c= backend.id;
            backSpList.add(back);
            
            Core_IPS_Backend_Supported_Product_Map__c back1= Core_IPS_Backend_TestClass_Utility.getBackendId();
            back1.Core_IPS_Supported_Product__c=suppProd1.id;
            back1.core_IPS_backend_System__c= backend1.id;
            back1.Core_IPS_Auto_Promote__c = false;
            backSpList.add(back1); 
            
            Core_IPS_Backend_Supported_Product_Map__c back2= Core_IPS_Backend_TestClass_Utility.getBackendId();
            //back2.Core_IPS_Supported_Product__c=suppProd1.id;
            back2.core_IPS_backend_System__c= backend2.id;
            back2.Core_IPS_Auto_Promote__c = false;
            back2.Core_IPS_Queue__c = 'test group';
            backSpList.add(back2);
            
            Core_IPS_Backend_Supported_Product_Map__c back3= Core_IPS_Backend_TestClass_Utility.getBackendId();
            //back2.Core_IPS_Supported_Product__c=suppProd1.id;
            back3.core_IPS_backend_System__c= backend2.id;
            back3.Core_IPS_Auto_Promote__c = false;
            back3.Core_IPS_Queue__c = 'test group';
            back3.Core_IPS_Default__c= true;
            backSpList.add(back3);
            
            
            
            system.runas(ListOfUser[8])
            {
                insert backSpList;
            }
            
            list<Core_IPS_Backend_Env_Details_Map__c > envMpList =  new list<Core_IPS_Backend_Env_Details_Map__c >();       
            Core_IPS_Backend_Env_Details_Map__c  backEnviMap =Core_IPS_Backend_TestClass_Utility.getBackendEnvironmentMap();
            
            // Question and answer
            backEnviMap.Core_IPS_Backend_System__c=backend.id; 
            backEnviMap.Core_IPS_Backend_EnvQuestion__c=envQuest.id;
            backEnviMap.Core_IPS_Environment_Variable_Answer__c='chrome';
            envMpList.add(backEnviMap);
            
            
            system.runas(ListOfUser[9])
            {
                insert envMpList;
            }
            //--------------------------for checkIssueCategoriesCriteria----------------------
            Core_IPS_Master_Issue_Category__c masterIssueCat =Core_IPS_Backend_TestClass_Utility.getMasterIssueCategory();
            masterIssueCat.Name='Test'; //5th Feb- for check case external issue category name and master issue category name
            system.runas(ListOfUser[0])
            {
                insert masterIssueCat;
            }
            
            Core_IPS_Backend_Case_Categories_Map__c  backendCaseCate = Core_IPS_Backend_TestClass_Utility.getCaseCategories();
            backendCaseCate.Core_IPS_Case_Category__c=masterIssueCat.id;
            //commented below line by tchauhan
            //backendCaseCate.Core_IPS_Backend_SP_Map__c=back1.id;  
            backendCaseCate.Core_IPS_Backend_SP_Map__c = backSpList[0].id;
            system.runas(ListOfUser[1])
            {
                insert backendCaseCate;
            }
            
            List<Core_IPS_Backend_Case_Categories_Map__c>  backendCaseCateList = new List<Core_IPS_Backend_Case_Categories_Map__c>();
            backendCaseCateList.add(backendCaseCate);
            
            RecordType rType =  [Select r.Name, r.DeveloperName,r.id From RecordType r where r.DeveloperName = 'Core_IPS_Case_Create_Self_Assigned' Limit 1];      
            
            Asset  Asst=new Asset(Core_Supported_Product__c=suppProd.id,Core_Product_Organization__c=suppOrg.id,Name='Asset1') ;
            system.runas(ListOfUser[2])
            {
                insert  Asst;  //For case is attached with asset
            }
            
            
            Case cs4=new case();
            cs4.Core_IPS_Supported_Product__c= suppProd.id;
            cs4.Core_IPS_Product_Org1__c=suppOrg.id;
            cs4.productID=prod.id;
            cs4.Core_Case_Issue_Category__c = issueCat.id;
            cs4.Core_Case_Issue_Sub_Category__c = issueCat.id;
            cs4.Core_External_Issue_Category__c = 'Test';            
            cs4.Core_IPS_Backend_System__c=backendList[0].id;
            string idofback='1234';
            cs4.Core_IPS_Restricted_Secret_Content__c = true;
            cs4.Core_IPS_Backend_ID__c=idofback;
            cs4.Core_severity__c= 'Low';
            cs4.recordtypeid=rType.id;
            //Adding case Status and SubStatus -- Manoj Kumar
            cs4.Status='Open';
            cs4.Core_Sub_Status__c='Investigating';
            
            
            
            //Case  cs1= new Case();          
            cs1.Core_IPS_Supported_Product__c= suppProd.id;
            cs1.Core_IPS_Product_Org1__c=suppOrg.id;
            cs1.productID=prod.id;
            cs1.Core_IPS_Backend_System__c=backendList[0].id;
            cs1.Core_Case_Issue_Category__c = issueCat.id;
            cs1.Core_Case_Issue_Sub_Category__c = issueCat.id;
            cs1.Core_External_Issue_Category__c = 'Test';
            cs1.Core_IPS_Restricted_Secret_Content__c = true;
            cs1.Core_Severity__c='Low';
            cs1.recordtypeid=rType.id;
            cs1.Status='Open';
            cs1.Core_Sub_Status__c='Investigating';
            
            
            newList.add(cs1);
            
            newList.add(cs4);
            
            system.runas(ListOfUser[3])
            {
                insert(newList);
            }
            
            cs4.Core_severity__c= 'High';
            
            
            
            Core_IPS_Response__c  cResp = new Core_IPS_Response__c ();
            //cResp.Core_IPS_Survey_Type__c = '';
            cResp.Core_IPS_Question_Master__c = envQuest.id;
            cResp.Core_IPS_Answer_Master__c = answers.id;
            cResp.Core_IPS_Case__c =cs1.id; 
            
            Core_IPS_Response__c  cResp1 = new Core_IPS_Response__c ();
            //cResp1.Core_IPS_Survey_Type__c = '';
            cResp1.Core_IPS_Question_Master__c = envQuest1.id;
            cResp1.Core_IPS_Answer_Master__c = answers1.id;
            cResp1.Core_IPS_Case__c =cs1.id; 
            
            List<Core_IPS_Response__c> qResList =  new List<Core_IPS_Response__c>();
            
            
            qResList.add(cResp);
            qResList.add(cResp1);
            
            
            system.runas(ListOfUser[4])
            {
                insert qResList;
                
            }  
            
            case cs11= new case();
            cs11 = cs4;
            
            oldList.add(cs11);
            oldMap.put(cs11.id,cs11);            
            //List<Core_Product_Issue_Category__c > issueCatList = new List<Core_Product_Issue_Category__c>();
            //issueCatList.add(issueCat);
            
            // newMap.put(cs1.id, cs1);
            
            
            //Start--3rd Feb 2016--
            test.startTest();
            List<Core_IPS_Backend_Field_Mapping__c> BackEndFieldList=new List<Core_IPS_Backend_Field_Mapping__c>();
            Core_IPS_Backend_Field_Mapping__c backEndField=new Core_IPS_Backend_Field_Mapping__c(Core_IPS_Backend_System__c=backendList[0].id,Core_IPS_Field_Object_Name__c='Case',Core_IPS_Field_Technical_name__c='Core_Severity__c',Core_IPS_Source_Field__c='customer_priority',Core_IPS_Target_Field__c='customfield_10300',Core_IPS_Support_Update__c = true);
            Core_IPS_Backend_Field_Mapping__c backEndField1=new Core_IPS_Backend_Field_Mapping__c(Core_IPS_Backend_System__c=backendList[0].id,Core_IPS_Field_Object_Name__c='Core_IPS_Environment_Details__c',Core_IPS_Field_Technical_name__c='bkc_bsp_version',Core_IPS_Source_Field__c='bkc_bsp_version',Core_IPS_Target_Field__c='customfield_14617',Core_IPS_Support_Update__c = true);
            
            //Creating Backend Field Mapping for SubStatus update routing through workflow -- Manoj Kumar
            Core_IPS_Backend_Field_Mapping__c backEndField2=new Core_IPS_Backend_Field_Mapping__c(Core_IPS_Backend_System__c=backendList[0].id,Core_IPS_Field_Object_Name__c='Case',Core_IPS_Field_Technical_name__c='Core_Sub_Status__c',Core_IPS_Source_Field__c='substatus',Core_IPS_Target_Field__c='substatus',Core_IPS_Support_Update__c = true);
            //backEndField.Core_IPS_Field_Object_Name__c='Case';
            //backEndField1.Core_IPS_Field_Object_Name__c='Core_IPS_Environment_Details__c';
            backEndField2.Core_IPS_Field_Object_Name__c='Case';
            BackEndFieldList.add(backEndField);
            BackEndFieldList.add(backEndField1);
            BackEndFieldList.add(backEndField2);
            system.runas(ListOfUser[5])
            {
                insert BackEndFieldList;
            }
            //Creating Backend Value Mapping for SubStatus update routing through workflow -- Manoj Kumar
            List<Core_IPS_Backend_Value_Mapping__c> BackEndValueList = new List<Core_IPS_Backend_Value_Mapping__c>();
            Core_IPS_Backend_Value_Mapping__c backendValue = new Core_IPS_Backend_Value_Mapping__c(Core_IPS_Backend_Field_Mapping__c=BackEndFieldList.get(2).Id, Core_IPS_Source_Value__c='Open.Investigating',Core_IPS_Target_Value__c='open.re-open',Core_IPS_Previous_Source_Value__c='Closed.Resolved');
            Core_IPS_Backend_Value_Mapping__c backendValue1 = new Core_IPS_Backend_Value_Mapping__c(Core_IPS_Backend_Field_Mapping__c=BackEndFieldList.get(2).Id, Core_IPS_Source_Value__c='Open.Deferred',Core_IPS_Target_Value__c='open.re-open',Core_IPS_Previous_Source_Value__c='closed');
            Core_IPS_Backend_Value_Mapping__c backendValue2 = new Core_IPS_Backend_Value_Mapping__c(Core_IPS_Backend_Field_Mapping__c=BackEndFieldList.get(2).Id, Core_IPS_Source_Value__c='Closed.Closed',Core_IPS_Target_Value__c='complete',Core_IPS_Previous_Source_Value__c='Open');
            
            BackEndValueList.add(backendValue);
            BackEndValueList.add(backendValue1);
            BackEndValueList.add(backendValue2);
            system.runas(ListOfUser[5])
            {
                insert BackEndValueList;
            }
            //End SubStatus update routing -- Manoj Kumar
            
            Set<ID> backIDList=new Set<ID>();
            backIDList.add(backendList[0].id);
            
            
            
            
            cs4.Core_jsonfield__c='{"Env Dtl Resp" : [ {"Qstn" : "bkc_bsp_version","Ansr" : "All in One M;"} ]}';
            cs4.Core_Severity__c='Medium';
            //Updating case Status and SubStatus for routing through workflow -- Manoj Kumar
            cs4.Status='Closed';
            cs4.Core_Sub_Status__c='Closed';
            cs4.ProductId = Core_IPS_Backend_TestClass_Utility.getProduct()?.Id;
            system.runas(ListOfUser[6])
            {
                update cs4;
                
            }
            
            newList.add(cs4);
            Set<String> envFieldSet = new Set<String>();
            Map<String, String> envFieldSetMap = new Map<String, String>();
            
            envFieldSet.add('bkc_bsp_version');
            
            envFieldSetMap.put('bkc_bsp_version','bkc_bsp_version');
            String jasonStr = cs4.Core_jsonfield__c;
            
            Core_IPS_CasePromotion_Handler.executeBackendFieldUpdate(oldList, newList, oldMap, newMap,backIDList); //3rd Feb 2016--
            
            test.stopTest();
        }  
        //        update(cs);
    }
    
    //****************//
    
    
    
    //***********end here**************//
}