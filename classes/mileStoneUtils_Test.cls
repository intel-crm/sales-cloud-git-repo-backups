/***************************************************************************************************
* Apex Class Name: mileStoneUtils_Test
* Version     : 1.0 
* Created Date: 19th Dec 2015
* Function    : Test class for Contact_Handler
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T               02/10/2016               Created
* Ganapati 		      		  29/07/2019	       	   Modified for - US404375 - Technical: Test Classes are failing in Production 
****************************************************************************************************/
@isTest(seealldata=false)
public class mileStoneUtils_Test{
    
    public static User SystUserRunAs; 
    public static List<Case> caseList = new List<Case>();
    public static List<Case> caseList2 = new List<Case>();
    public static Account account =  new Account();
    public static Contact con =  new Contact();
    public static case cse1 = new Case();
    public static Entitlement ent = new Entitlement();
    public static Id slaprocessId = [Select Id, Name, NameNorm, IsActive, VersionNumber from SlaProcess Where Name = 'IPS Standard SLA Entitlement' and IsActive=true].Id;
    
    public static void getRecords(integer i){
        
        Profile prof = [select id from profile where name = 'System Administrator' limit 1];
        List<User> userList = new List<user>();
        userList = TestUtilities.getListOfUser(1);
        userList[0].profileId=prof.id;
        insert userlist;
        SystUserRunAs = new User();
        SystUserRunAs = userList[0];
        
        System.runAs(systUserRunAs){
            Core_Trigger_Executions__c  TriggerExecution1 = new Core_Trigger_Executions__c();
            TriggerExecution1.Name = 'caseSLAManagement';
            TriggerExecution1.Core_Active__c = true;
            TriggerExecution1.Core_Class_Name__c ='Core_IPS_CaseTriggerHandler';
            TriggerExecution1.Core_Description__c = 'Used to perform SLA Management on case';
            TriggerExecution1.Core_Object__c = 'Case';
            TriggerExecution1.Core_Trigger_Events__c = 'Before insert, Before Update';
            insert TriggerExecution1;
            
            List<Core_IPS_Labels__c> lablesList = new List<Core_IPS_Labels__c>();
            Core_IPS_Labels__c labels = new Core_IPS_Labels__c();
            labels.name= 'IPS Standard Entitlement Process ID';
            labels.value__c=slaprocessId;
            lablesList.add(labels);
            
            Core_IPS_Labels__c labels1 = new Core_IPS_Labels__c();
            labels1.name= 'IPS_Case_Status_Investigating';
            labels1.value__c='Investigating';
            lablesList.add(labels1);
            
            string gecRTypeId = [SELECT id from RecordType where Name ='IPS GEC ReadOnly'].Id;
            Core_IPS_Labels__c labels2 = new Core_IPS_Labels__c();
            labels2.name= 'GEC Record Type Id';
            labels2.value__c=gecRTypeId;
            lablesList.add(labels2);

            Core_IPS_Labels__c labels3 = new Core_IPS_Labels__c ();
            labels3.name= 'PUBLIC_TO_CUSTOMERS';
            labels3.value__c='Public to Customers';
            lablesList.add(labels3);
            
            Core_IPS_Labels__c labels4 = new Core_IPS_Labels__c ();
            labels4.name= 'PRIVATE_TO_INTEL';
        	labels4.value__c= 'Private to Intel';
            lablesList.add(labels4);
            
            Core_IPS_Labels__c labels5= new Core_IPS_Labels__c();
            labels5.name= 'PRIVATE_TO_AGENTS';
            labels5.value__c= 'Private to Agents';
			lablesList.add(labels5);
            
            Core_IPS_Labels__c labels6= new Core_IPS_Labels__c();
            labels6.name='Customer';
            labels6.value__c='Customer';
            lablesList.add(labels6);
            
            Core_IPS_Labels__c labels7 = new Core_IPS_Labels__c ();
            labels7.name='FAE';
            labels7.value__c='FAE';
            lablesList.add(labels7);
            
            Core_IPS_Labels__c labels8 = new Core_IPS_Labels__c();
            labels8.name='Agent';
            labels8.value__c='Agent';
            lablesList.add(labels8);
            
            Core_IPS_Labels__c labels9 = new Core_IPS_Labels__c();
            labels9.name='Backend Integration';
            labels9.value__c='Backend Integration';
            lablesList.add(labels9);
            
            Core_IPS_Labels__c labels10 = new Core_IPS_Labels__c();
            labels10.name='Data Migration';
            labels10.value__c='Data Migration';
            lablesList.add(labels10);
            
            Core_IPS_Labels__c labels11 = new Core_IPS_Labels__c();
            labels11.name='Partner';
            labels11.value__c='Partner';
            lablesList.add(labels11);
            
            Core_IPS_Labels__c labels12 = new Core_IPS_Labels__c ();
            labels12.name= 'PRIVATE_TO_PARTNERS';
            labels12.value__c= 'Private to Partner';
            lablesList.add(labels12);
            
            Core_IPS_Labels__c labels13 = new Core_IPS_Labels__c();
            labels13.name='Partner - DFAE';
            labels13.value__c='Partner - DFAE';
            lablesList.add(labels13);
            
            Core_IPS_Labels__c labels14 = new Core_IPS_Labels__c();
            labels14.name='Partner - Agent';
            labels14.value__c='Partner - Agent';
            lablesList.add(labels14);
            
            Core_IPS_Labels__c labels15 = new Core_IPS_Labels__c();
            labels15.name='Comment Source - Customer';
            labels15.value__c='Customer Portal';
            lablesList.add(labels15);
            
            Core_IPS_Labels__c labels16 = new Core_IPS_Labels__c();
            labels16.name='Comment Source - Internal';
            labels16.value__c='Internal Portal';
            lablesList.add(labels16);
            
            Core_IPS_Labels__c labels17 = new Core_IPS_Labels__c ();
            labels17.name= 'Comment Source - Email';
            labels17.value__c= 'Email';
            lablesList.add(labels17);
            
            Core_IPS_Labels__c labels18 = new Core_IPS_Labels__c();
            labels18.name='Comment Source - N/A';
            labels18.value__c='N/A';
            lablesList.add(labels18);
            
            Core_IPS_Labels__c labels19 = new Core_IPS_Labels__c();
            labels19.name='Comment Source - Data Migration';
            labels19.value__c='Data Migration';
            lablesList.add(labels19);
            
            insert lablesList;
            
            List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert ListOfSupportOrg;
            List<Core_IPS_Product_Organization__c> supOrgLst = [SELECT Id, Name FROM Core_IPS_Product_Organization__c LIMIT 2];
            String orgNum1 = (supOrgLst[0].Name).right(3);
            String orgId1 = supOrgLst[0].Id;
            List<Core_IPS_SupOrg_Priority_Biz_hrs_mapping__c> bizHrsMappingList = new List<Core_IPS_SupOrg_Priority_Biz_hrs_mapping__c>();
            Core_IPS_SupOrg_Priority_Biz_hrs_mapping__c bizhrsmp1 = new Core_IPS_SupOrg_Priority_Biz_hrs_mapping__c();
            bizhrsmp1.Name = 'Test Org 1- Critical';
            bizhrsmp1.Active__c = true;
            bizhrsmp1.Supported_Org_Number__c = orgNum1;
            bizhrsmp1.Case_Priority_level__c = 'Critical';
            bizhrsmp1.Business_Hours__c = '8';
            bizhrsmp1.Supported_Org_ID__c = orgId1;
            bizHrsMappingList.add(bizhrsmp1);
            
            Core_IPS_SupOrg_Priority_Biz_hrs_mapping__c bizhrsmp2 = new Core_IPS_SupOrg_Priority_Biz_hrs_mapping__c();
            bizhrsmp2.Name = 'Test Org 1- High';
            bizhrsmp2.Active__c = true;
            bizhrsmp2.Supported_Org_Number__c = orgNum1;
            bizhrsmp2.Case_Priority_level__c = 'High';
            bizhrsmp2.Business_Hours__c = '16';
            bizhrsmp2.Supported_Org_ID__c = orgId1;
            bizHrsMappingList.add(bizhrsmp2);
            
            Core_IPS_SupOrg_Priority_Biz_hrs_mapping__c bizhrsmp3 = new Core_IPS_SupOrg_Priority_Biz_hrs_mapping__c();
            bizhrsmp3.Name = 'Test Org 1 - Medium';
            bizhrsmp3.Active__c = true;
            bizhrsmp3.Supported_Org_Number__c = orgNum1;
            bizhrsmp3.Case_Priority_level__c = 'Medium';
            bizhrsmp3.Business_Hours__c = '24';
            bizhrsmp3.Supported_Org_ID__c = orgId1;
            bizHrsMappingList.add(bizhrsmp3);
            
            Core_IPS_SupOrg_Priority_Biz_hrs_mapping__c bizhrsmp4 = new Core_IPS_SupOrg_Priority_Biz_hrs_mapping__c();
            bizhrsmp4.Name = 'Test Org 1- Low';
            bizhrsmp4.Active__c = true;
            bizhrsmp4.Supported_Org_Number__c = orgNum1;
            bizhrsmp4.Case_Priority_level__c = 'Low';
            bizhrsmp4.Business_Hours__c = '32';
            bizhrsmp4.Supported_Org_ID__c = orgId1;
            bizHrsMappingList.add(bizhrsmp4);
            
            insert bizHrsMappingList;
            
            List<Core_IPS_Q_Biz_hours_mapping__c> labellist2 = new List<Core_IPS_Q_Biz_hours_mapping__c>();
            Core_IPS_Q_Biz_hours_mapping__c bizLabel1 = new Core_IPS_Q_Biz_hours_mapping__c();
            bizLabel1.Name = 'Default';
            bizLabel1.Business_Hours_Name__c = 'Default';
            bizLabel1.Business_Hours_ID__c = '01mo0000000JgfE';
            bizLabel1.Queue_ID__c = '00Go0000001pg1s';
            bizLabel1.Queue_Name__c = 'IPS - Unassigned Cases';
            labellist2.add(bizLabel1);   
            Core_IPS_Q_Biz_hours_mapping__c bizLabel2 = new Core_IPS_Q_Biz_hours_mapping__c();
            bizLabel2.Name = 'test_group';
            bizLabel2.Business_Hours_Name__c = 'test_group';
            bizLabel2.Business_Hours_ID__c = '01mo0000000JgfE';
            bizLabel2.Queue_ID__c = '00Go0000001pg1s';
            bizLabel2.Queue_Name__c = 'IPS - Unassigned Cases';
            labellist2.add(bizLabel2);
            insert labellist2;
            Id intelSupportOwner = systUserRunAs.id;
            account = TestUtilities.getAccountRecord();
            insert account;
            
            List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
            insert ListOfAccounts;
            
            List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
            }
            insert ListOfContacts;
            
            list<Asset> AssetList = TestUtilities.getAssetList(2);
            for(Asset Asst : AssetList){
                Asst.accountId = ListOfAccounts.get(0).Id;
                Asst.Contactid = ListOfContacts.get(0).id;
                Asst.Core_Product_Organization__c = supOrgLst.get(0).id;
            }
            AssetList[1].Core_Product_Organization__c = supOrgLst.get(1).id;
            insert AssetList;
            
            caseList = TestUtilities.getListOfCases(10);
            List<Entitlement> entLst = new List<Entitlement>();
            ent = TestUtilities.getEntitlementRecord();
            ent.accountid = ListOfAccounts.get(0).Id;
            ent.AssetId = AssetList.get(0).id;
            ent.startdate = System.today()-1;
            ent.endDate = system.today()+760;
            if(i==1) {
                ent.SlaProcessId = Core_IPS_Labels__c.getValues('IPS Standard Entitlement Process ID').Value__c;
            }
            entLst.add(ent);
            Entitlement ent1 = new Entitlement();
            ent1 = TestUtilities.getEntitlementRecord();
            ent1.accountid = ListOfAccounts.get(0).Id;
            ent1.AssetId = AssetList.get(1).id;
            ent1.startdate = System.today()-1;
            ent1.endDate = system.today()+760;
            if(i==1) {
                ent1.SlaProcessId = Core_IPS_Labels__c.getValues('IPS Standard Entitlement Process ID').Value__c;
            }
            entLst.add(ent1);
            insert entLst;
            recordtype Rtype = [select id from  recordtype where Name ='IPS case create'];
            for(case cs:caseList) {
                cs.accountId = ListOfAccounts.get(0).Id;
                cs.ContactId = ListOfContacts.get(0).id;
                cs.entitlementId = entLst.get(0).id;
                cs.ownerId = userinfo.getUserID();
                cs.recordtypeId = Rtype.Id;
                cs.Core_First_Response_Completed__c =false;
                cs.Priority = 'Low';
                cs.Core_Sub_Status__c = 'Reproduced';
                cs.Core_Intel_Sup_Owner__c = UserInfo.getUserId();
                cs.Core_IPS_Is_Notification_Active__c = true;
                cs.Core_Latest_Comment_Time_Stamp__c = System.now()+1;
            }
            caseList[0].SlaStartDate = System.now() - 1;
            caseList[1].entitlementId = entLst.get(1).id;
            insert caseList;

            for(case cs:caseList) {
                cs.Priority = 'High';
                cs.Core_First_Response_Completed__c =true;
            }
            caseList[0].SlaStartDate = System.now() - 1;
            update caseList;
			/*
            List<Core_IPS_Case_Comments__c> caseCommentList = new List<Core_IPS_Case_Comments__c>();
                Core_IPS_Case_Comments__c comment;
                for(Case cs:caseList){
                    comment = new Core_IPS_Case_Comments__c();
                    comment.core_ips_Case__c=cs.id;
                    comment.Core_IPS_Comment_Authored_By__c = userInfo.getUserID();
                    comment.Core_IPS_Comment_Authored_By_Email__c = userInfo.getUseremail();
                    comment.Core_IPS_Comment_Authored_By_FirstName__c = userInfo.getFirstName();
                    comment.Core_IPS_Comment_Authored_By_Name__c = userInfo.getUsername();
                    comment.Core_IPS_Comment__c =  'test comment';
                    comment.Core_IPS_Rich_Comment__c = 'test comment';
                    comment.Core_IPS_Comment_Attachment_Id__c = null;
                    comment.Core_IPS_Comment_Author_Type__c='Agent';
					comment.Core_IPS_Case_Comment_Type__c = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
                    caseCommentList.add(comment);
                }
                insert caseCommentList;
            
            	List<Core_IPS_Case_Comments__c> caseCommentList2 = new List<Core_IPS_Case_Comments__c>();
                for(Case cs:caseList){
                    comment = new Core_IPS_Case_Comments__c();
                    comment.core_ips_Case__c=cs.id;
                    comment.Core_IPS_Comment_Authored_By__c = userInfo.getUserID();
                    comment.Core_IPS_Comment_Authored_By_Email__c = userInfo.getUseremail();
                    comment.Core_IPS_Comment_Authored_By_FirstName__c = userInfo.getFirstName();
                    comment.Core_IPS_Comment_Authored_By_Name__c = userInfo.getUsername();
                    comment.Core_IPS_Comment__c =  'test comment';
                    comment.Core_IPS_Rich_Comment__c = 'test comment';
                    comment.Core_IPS_Comment_Attachment_Id__c = null;
                    comment.Core_IPS_Comment_Author_Type__c='Agent';
					comment.Core_IPS_Case_Comment_Type__c = Core_IPS_Labels__c.getValues('PUBLIC_TO_CUSTOMERS').value__c;
                    caseCommentList.add(comment);
                }
                insert caseCommentList2;
            */
            List<Core_IPS_Case_Interested_Party__c> interestedpartyLst = new List<Core_IPS_Case_Interested_Party__c>();
            Core_IPS_Case_Interested_Party__c interestedparty;
            for(Case cs : caseList) {
                interestedparty = new Core_IPS_Case_Interested_Party__c ();
                interestedparty.Contact__C = ListOfContacts.get(0).id;
                interestedparty.Case__c= cs.Id;
                interestedpartyLst.add(interestedparty);
            }
            insert interestedpartyLst;
            
            cse1.accountId = ListOfAccounts.get(0).Id;
            cse1.ownerId = userinfo.getUserID();
            cse1.recordtypeId = Rtype.Id;
            insert cse1;
        }
    }
    
/***************************************************************************************************
* Method Name: inactivatingIPtest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 1st Feb 2016
* Description:   
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                       02/01/2015                Created
****************************************************************************************************/         
    public static testmethod void getActiveMileStone_Test(){
        
        Test.starttest();
        getRecords(1);
        System.runAs(SystUserRunAs){ 
                
            milestoneUtils.getMileStone(caseList[0]);
            milestoneUtils.getActiveMileStone(caseList[0]);
            List<CaseMilestone> Lst = [select Id,caseId,completionDate, isCompleted,MileStoneTypeId,MileStoneType.Name from CaseMilestone where caseId in :caseList];
            system.debug(Lst);
            caseList.add(caseList[0]);
            caseList.add(caseList[1]);
            milestoneUtils.getActiveMileStone(caseList);
            milestoneUtils.getCasesWithOrgConfigSet(caseList);
        }
        Test.stoptest();
        
    }
    
    
    /***************************************************************************************************
* Method Name: inactivatingIPtest
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 1st Feb 2016
* Description:   
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* JRK                       02/01/2015                Created
****************************************************************************************************/         
    public static testmethod void getActiveMileStone1_Test(){
        
        Test.starttest();
        getRecords(1);
        System.runAs(SystUserRunAs){       
             
            Group testGroup = new Group(Name='test_group', Type='Queue');
            insert testGroup;
            set<String>ownerids = new set<String>();
            ownerids.add(testGroup.id);
            Map<String,String> testMAp = new Map<String,String>();
            testMAp = milestoneUtils.getBusinessHoursByOwner(ownerids);
            Id s =milestoneUtils.getBusinessHoursId(testGroup.id);
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
            
            caseList[0].OwnerId = testGroup.Id;//'00G21000000IKxC';
            // update caseList;
            milestoneUtils.getActiveMileStone(caseList[0]);
            List<CaseMilestone> Lst = [select Id,caseId,completionDate, isCompleted,MileStoneTypeId,MileStoneType.Name from CaseMilestone where caseId in :caseList];
            system.debug(Lst);
            milestoneUtils.getActiveMileStone(caseList);
            
            
        }
        Test.stoptest();
        
    }
    
    
    /***************************************************************************************************
* Method Name: getSetNextResponseDueDate_Test
* Method Type: Test Method
* Version     : 1.0 
* Created Date: 19th Dec 2015
* Description:  
* Scenario Type: Positive 
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T             11/18/2015                 Created
****************************************************************************************************/         
    public static testmethod void getSetNextResponseDueDate_Test(){
        getRecords(0);
        Test.starttest();
        System.runAs(SystUserRunAs){
            
            milestoneUtils.isCaseMilestoneUpdateRequired(caseList[0],System.today());  
            caseList[0].Core_Sub_Status__c='Waiting';
            update caseList[0];
            milestoneUtils.stopMilestoneClockWhenAwaitingCustomerResponse(caseList[0]);
            caseList[0].Core_Sub_Status__c='Investigating';
            caseList[0].Core_First_Response_Completed__c=true;
            caseList[0].Core_Next_Response_Due_Date__c = System.today();
            BusinessHours bh = [select id from BusinessHours limit 1];
            //insert bh;
            caseList[0].businesshoursid=bh.id;
            update caseList[0];
            
            case c = [select id,IsStopped,Core_Sub_Status__c,businesshoursid,Core_First_Response_Completed__c,Core_Next_Response_Due_Date__c,StopStartDate from case where id =:caseList[0].id];
            milestoneUtils.reStartMilestoneClockWhenCustomerresponded(c);
            milestoneUtils.getSetNextResponseDueDate(c);
            
            //caseList[0].
            milestoneUtils.AddCaseBizHoursOnOwnerUpdate(caseList[0],caseList[1]);
            milestoneUtils.AddCaseBizHoursOnOwnerUpdate(null,caseList[1]);
            //milestoneUtils.getBusinessHours(Owner)
        }
        Test.stoptest();
        
    }  
    public static testmethod void getSetNextResponseDueDate_Test3(){
        getRecords(0);
        Test.starttest();
        System.runAs(SystUserRunAs){
            caseList[0].Core_Sub_Status__c='Waiting';
            update caseList[0];
            milestoneUtils.stopMilestoneClockWhenAwaitingCustomerResponse(caseList[0]);
            caseList[0].Core_Sub_Status__c='Investigating';
            caseList[0].Core_Next_Response_Due_Date__c = null;
            caseList[0].Core_First_Response_Completed__c = true;
            caseList[0].IsStopped = true;
            
            update caseList[0];
            MilestoneType mt = [SELECT Id, Name FROM MilestoneType where name = 'IPS Case First Response' limit 1];
            
            List<CaseMilestone> cmsToUpdate = [select Id, completionDate from CaseMilestone cm
                                               where caseId =: caseList[0].id and cm.MilestoneType.Name=:mt.name];
            
            case c = [select id,ownerid,IsStopped,Core_Sub_Status__c,Core_First_Response_Completed__c,Core_Next_Response_Due_Date__c,StopStartDate from case where id =:caseList[0].id];
            milestoneUtils.AddCaseBizHoursOnOwnerUpdate(caseList[0],c);
            
        }
    }
    public static testmethod void getSetNextResponseDueDate_Test2(){
        getRecords(0);
        Test.starttest();
        System.runAs(SystUserRunAs){
            milestoneUtils.getSetNextResponseDueDate(caseList[0]);
            caseList[0].Core_Sub_Status__c='Waiting';
            update caseList[0];
            milestoneUtils.stopMilestoneClockWhenAwaitingCustomerResponse(caseList[0]);
            caseList[0].Core_Sub_Status__c='Investigating';
            caseList[0].Core_Next_Response_Due_Date__c = System.today();
            caseList[0].Core_First_Response_Completed__c = true;
            caseList[0].IsStopped = true;
            
            update caseList[0];
            System.debug('milestone - get : '+milestoneutils.getMilestone(caseList[0]));
            MilestoneType mt = [SELECT Id, Name FROM MilestoneType where name = 'IPS Case First Response' limit 1];
            
            List<CaseMilestone> cmsToUpdate = [select Id, completionDate from CaseMilestone cm
                                               where caseId =: caseList[0].id and cm.MilestoneType.Name=:mt.name];
            
            case c = [select id,IsStopped,Core_Sub_Status__c,Core_First_Response_Completed__c,Core_Next_Response_Due_Date__c,StopStartDate from case where id =:caseList[0].id];
            
            milestoneUtils.reStartMilestoneClockWhenCustomerresponded(c);
        }
        Test.stoptest();
    }
    public static testmethod void getActiveMileStone2_Test(){
        
        Test.starttest();
        getRecords(1);
        System.runAs(SystUserRunAs){       
             
            Group testGroup = new Group(Name='test_group', Type='Queue');
            insert testGroup;
            set<String>ownerids = new set<String>();
            ownerids.add(testGroup.id);
            Map<String,String> testMAp = new Map<String,String>();
            testMAp = milestoneUtils.getBusinessHoursByOwner(null);
            Id s =milestoneUtils.getBusinessHoursId(null);
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
            
            caseList[0].OwnerId = testGroup.Id;//'00G21000000IKxC';
            // update caseList;
            milestoneUtils.getActiveMileStone(caseList[0]);
            List<CaseMilestone> Lst = [select Id,caseId,completionDate, isCompleted,MileStoneTypeId,MileStoneType.Name from CaseMilestone where caseId in :caseList];
            system.debug(Lst);
            milestoneUtils.getActiveMileStone(caseList);
            
        }
        Test.stoptest();
        
    }
}