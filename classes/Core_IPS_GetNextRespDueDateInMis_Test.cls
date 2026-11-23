@isTest(SeeAllData=false)
private class Core_IPS_GetNextRespDueDateInMis_Test {
    @testsetup
    public static void setupData(){
      /*  List<Core_IPS_Product_Organization__c> prodOrg = new List<Core_IPS_Product_Organization__c>();
        Core_IPS_Product_Organization__c org = new Core_IPS_Product_Organization__c();
        org.name = 'Org-001';
        Core_IPS_Product_Organization__c org1 = new Core_IPS_Product_Organization__c();
        org.name = 'Org-002';
        prodOrg.add(org);
        prodOrg.add(org1);
        insert prodOrg;*/
        
		List<Core_IPS_Product_Organization__c> listOfSupportOrg  = TestUtilities.getListOfSupportOrg(2);
            insert listOfSupportOrg;
        
        List<Account> acc = TestUtilities.getAccountsList(1);
        insert acc;
         List<Core_IPS_Labels__c> lablesList = new List<Core_IPS_Labels__c>();
            
            Core_IPS_Labels__c labels1 = new Core_IPS_Labels__c();
            labels1.name= 'IPS Standard Entitlement Process ID';
            labels1.value__c='5523F00000000K5';
            lablesList.add(labels1);
        insert lablesList;
     /*  // Case caseList = TestUtilities.getCase();
       List<case> caseList = new List<case>();
       	Case caseRecord = new Case();
        caseRecord.Status = 'New';
        caseRecord.Origin = 'Web';
        caseRecord.Priority = 'High';
        caseRecord.Subject = 'TestSubject';
        caseRecord.Description = 'TestDescription';
        caseRecord.Core_Next_Response_Due_Date__c =  Date.today().addDays(15);
        caseList.add(caseRecord);
      insert caseList;
        	
        List<Core_IPS_CaseMileStone_Label__c> milestoneList = new List<Core_IPS_CaseMileStone_Label__c>();
        	Core_IPS_CaseMileStone_Label__c milestoneList1 = new Core_IPS_CaseMileStone_Label__c();
        	milestoneList1.Name = 'ATHR Fix Test';
        	milestoneList1.CaseId__c = caseList[0].Id;
        	milestoneList1.BusinessHoursId__c = '01mo0000000JgfEAAS';
        	milestoneList1.isCompleted__c = False;
        	milestoneList1.StartDate__c = Date.today();
        	milestoneList.add(milestoneList1);
       insert milestoneList;*/


    }
  /*  public static testmethod void getActiveMileStone_Test1() {
        List<Core_IPS_CaseMileStone_Label__c> lstCaseMilestone = [SELECT CaseId__c FROM Core_IPS_CaseMileStone_Label__c WHERE  BusinessHoursId__c != NULL AND isCompleted__c=False LIMIT 1];                                                        
        Id caseId = lstCaseMilestone[0].CaseId__c;
        Core_IPS_GetNextResponseDueDateInMis nextResp = new Core_IPS_GetNextResponseDueDateInMis();
        Integer timeInMins = nextResp.calculateMilestoneTriggerTime(caseId,'IPS Next Response');
    }
    
   public static testmethod void getActiveMileStone_Test2() {
        
       // List<CaseMilestone> lstCaseMilestone = [SELECT CaseId FROM CaseMilestone WHERE isCompleted = False AND StartDate != NULL AND case.Core_Next_Response_Due_Date__c != NULL LIMIT 1];
        Case cs = [Select Id, Core_Next_Response_Due_Date__c FRom Case Where Subject = 'TestSubject' AND Core_Next_Response_Due_Date__c!= null Limit 1];
        MilestoneType mt = new MilestoneType(
            Name = 'First Response',
            //SobjectType = 'Case',
            RecurrenceType = 'NoRecurrence'
        );
        //insert mt;
        List<CaseMilestone> cm = [Select ID FROM casemilestone];
        System.debug('CM--->'+cm);
		//insert cm;
        List<Core_IPS_CaseMileStone_Label__c> lstCaseMilestone = [SELECT CaseId__c,StartDate__c FROM Core_IPS_CaseMileStone_Label__c WHERE isCompleted__c = False AND StartDate__c != NULL AND CaseId__c = :cs.Id LIMIT 1];   
        System.debug('Cases-->'+ cs);
        System.debug('lstCaseMilestone-->'+ lstCaseMilestone);
        Id caseId = lstCaseMilestone[0].CaseId__c;
        Core_IPS_GetNextResponseDueDateInMis nextResp = new Core_IPS_GetNextResponseDueDateInMis();
        Integer timeInMins = nextResp.calculateMilestoneTriggerTime(caseId,'IPS Next Response');
    }
    */
    public static testmethod void getActiveMileStone_Test3() {
        Profile prof = [select id,Name from profile where name = 'System Administrator' limit 1];
        
        
        List<User> userList = TestUtilities.getListOfUser(1);
        userList[0].profileId=prof.id;
        insert userlist;
        User SystUserRunAs = userList[0];//UserInfo.getUserId();
       // PermissionSet adminPS = [SELECT Id FROM PermissionSet WHERE Name = '' LIMIT 1];
       // insert new PermissionSetAssignment(AssigneeId = SystUserRunAs.Id, PermissionSetId = adminPS.Id);
        SlaProcess sla = [SELECT Id FROM SlaProcess WHERE Name = 'IPS Standard SLA Entitlement' AND IsActive = true LIMIT 1];
        List<case> csLst = new List<case>();
        List<Entitlement> entLst = new List<Entitlement>();
        Id intelSupportOwner =  UserInfo.getUserId();//systUserRunAs.Id;
        
        List<Account> ListOfAccounts = [Select id from Account Limit 1];
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = [select Id,Core_IPS_Support_Org_Name__c from Core_IPS_Product_Organization__c where Core_IPS_Support_Org_Name__c = 'TestName 1' limit 1];
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg1  = [select Id,Core_IPS_Support_Org_Name__c from Core_IPS_Product_Organization__c where Core_IPS_Support_Org_Name__c != 'TestName 1' limit 1];
        List<Asset> AssetList = TestUtilities.getAssetList(2);
        Recordtype Rtype = [select id from  recordtype where Name ='IPS case create'];
        Test.startTest();
     	System.runAs(systUserRunAs) {
            
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
            }
            //insert ListOfContacts;
            
            for(Asset Asst : AssetList){
                Asst.accountId = ListOfAccounts.get(0).Id;
                Asst.Contactid = ListOfContacts.get(0).id;
                Asst.Core_Product_Organization__c = ListOfSupportOrg.get(0).id;
            }
            AssetList[1].Core_Product_Organization__c = ListOfSupportOrg1.get(0).id;
            insert AssetList;

			            
            Entitlement ent = TestUtilities.getEntitlementRecord();
            ent.accountid = ListOfAccounts.get(0).Id;
            ent.AssetId = AssetList.get(0).id;
            ent.startdate = System.today()-1;
            ent.endDate = system.today()+760;
            ent.SlaProcessId = Core_IPS_Labels__c.getValues('IPS Standard Entitlement Process ID').Value__c;
            entLst.add(ent);
            
            Entitlement ent1 = TestUtilities.getEntitlementRecord();
            ent1.accountid = ListOfAccounts.get(0).Id;
            ent1.AssetId = AssetList.get(1).id;
            ent1.startdate = System.today()-1;
            ent1.endDate = system.today()+760;
            ent1.SlaProcessId = Core_IPS_Labels__c.getValues('IPS Standard Entitlement Process ID').Value__c;
            entLst.add(ent1);
            
            Entitlement ent2 = TestUtilities.getEntitlementRecord();
            ent2.accountid = ListOfAccounts.get(0).Id;
            ent2.startdate = System.today()-1;
            ent2.endDate = system.today()+760;
        	ent2.SlaProcessId = sla.Id;
            entLst.add(ent2);
            insert entLst;
            
            Case cs = new Case();
            cs.accountId = ListOfAccounts.get(0).Id;
            cs.ContactId = ListOfContacts.get(0).id;
            cs.entitlementId = entLst.get(0).id;
            cs.AssetId =AssetList.get(0).id;
            cs.ownerId = userinfo.getUserID();
            cs.recordtypeId = Rtype.Id;
            cs.Core_First_Response_Completed__c =false;
            cs.Priority = 'High';
            cs.Core_Sub_Status__c = 'Reproduced';
            cs.Core_Intel_Sup_Owner__c = UserInfo.getUserId();
            cs.Core_IPS_Is_Notification_Active__c = true;
            cs.Core_Latest_Comment_Time_Stamp__c = System.now()+1;
            cs.SlaStartDate = System.now() - 1;
            csLst.add(cs);
            
            Case cs1 = new Case();
            cs1.accountId = ListOfAccounts.get(0).Id;
            cs1.ContactId = ListOfContacts.get(0).id;
            //cs1.entitlementId = entLst.get(1).id;
            //cs1.AssetId =AssetList.get(1).id;
            cs1.ownerId = userinfo.getUserID();
            cs1.recordtypeId = Rtype.Id;
            cs1.Core_First_Response_Completed__c =false;
            cs1.Priority = 'High';
            cs1.Core_Sub_Status__c = 'Reproduced';
            cs1.Core_Intel_Sup_Owner__c = UserInfo.getUserId();
            cs1.Core_IPS_Is_Notification_Active__c = true;
            cs1.Core_Latest_Comment_Time_Stamp__c = System.now()+1;
            cs1.SlaStartDate = System.now() - 1;
            csLst.add(cs1);
            
            Case CaseRecord = new Case(
                Status = 'New',
                Origin = 'Web',
                Priority = 'High',
                Subject = 'TestSubject 1',
                Description = 'TestDescription',
                RecordTypeId = Rtype.Id,
                accountId = ListOfAccounts.get(0).Id,
                ContactId = ListOfContacts.get(0).id,
                entitlementId = entLst.get(2).id,
                Core_Next_Response_Due_Date__c =  Date.today().addDays(15)
            );
            csLst.add(CaseRecord);       
            insert csLst;
         List<CaseMilestone> milestones = [SELECT Id, MilestoneType.Name, StartDate FROM CaseMilestone WHERE CaseId = :CaseRecord.Id AND StartDate != null];
        System.debug('milestones-->'+milestones);
        }
        Test.stopTest();
        Core_IPS_GetNextResponseDueDateInMis nextResp = new Core_IPS_GetNextResponseDueDateInMis();
        Integer timeInMins = nextResp.calculateMilestoneTriggerTime(csLst[0].Id,'IPS Next Response');
        Integer timeInMins1 = nextResp.calculateMilestoneTriggerTime(csLst[1].Id,'IPS Next Response');
        Integer timeInMins2 = nextResp.calculateMilestoneTriggerTime(csLst[2].Id,'IPS Next Response');
    }
}