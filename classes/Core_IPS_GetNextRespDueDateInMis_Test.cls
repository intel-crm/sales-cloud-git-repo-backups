@isTest(SeeAllData=true)
private class Core_IPS_GetNextRespDueDateInMis_Test {
    
    public static testmethod void getActiveMileStone_Test1() {
        List<CaseMilestone> lstCaseMilestone = [SELECT CaseId FROM CaseMilestone WHERE BusinessHoursId != NULL AND isCompleted=False LIMIT 1];                                                        
        Id caseId = lstCaseMilestone[0].CaseId;
        Core_IPS_GetNextResponseDueDateInMis nextResp = new Core_IPS_GetNextResponseDueDateInMis();
        Integer timeInMins = nextResp.calculateMilestoneTriggerTime(caseId,'IPS Next Response');
    }
    
    public static testmethod void getActiveMileStone_Test2() {
        List<CaseMilestone> lstCaseMilestone = [SELECT CaseId FROM CaseMilestone WHERE isCompleted = False AND StartDate != NULL AND case.Core_Next_Response_Due_Date__c != NULL LIMIT 1];                                                        
        Id caseId = lstCaseMilestone[0].CaseId;
        Core_IPS_GetNextResponseDueDateInMis nextResp = new Core_IPS_GetNextResponseDueDateInMis();
        Integer timeInMins = nextResp.calculateMilestoneTriggerTime(caseId,'IPS Next Response');
    }
    
    public static testmethod void getActiveMileStone_Test3() {
        Profile prof = [select id from profile where name = 'System Administrator' limit 1];
        List<User> userList = TestUtilities.getListOfUser(1);
        userList[0].profileId=prof.id;
        insert userlist;
        User SystUserRunAs = userList[0];
        List<case> csLst = new List<case>();
        List<Entitlement> entLst = new List<Entitlement>();
        Id intelSupportOwner = systUserRunAs.Id;
        List<Account> ListOfAccounts = TestUtilities.getListOfAccounts(1);
        List<Contact> ListOfContacts = TestUtilities.getListOfContact(1);
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg  = [select Id from Core_IPS_Product_Organization__c where Name = 'Org-001' limit 1];
        List<Core_IPS_Product_Organization__c> ListOfSupportOrg1  = [select Id from Core_IPS_Product_Organization__c where Name != 'Org-001' limit 1];
        List<Asset> AssetList = TestUtilities.getAssetList(2);
    Recordtype Rtype = [select id from  recordtype where Name ='IPS case create'];
        Test.startTest();
        System.runAs(systUserRunAs) {
            insert ListOfAccounts;
            
            for(Contact ContactRec : ListOfContacts){
                ContactRec.Core_IPS_Intel_Support_Owner__c = intelSupportOwner;
                ContactRec.Accountid = ListOfAccounts.get(0).Id;
            }
            insert ListOfContacts;
            
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
                entitlementId = entLst.get(2).id
            );
            csLst.add(CaseRecord);       
            insert csLst;
        }
        Test.stopTest();
        Core_IPS_GetNextResponseDueDateInMis nextResp = new Core_IPS_GetNextResponseDueDateInMis();
        Integer timeInMins = nextResp.calculateMilestoneTriggerTime(csLst[0].Id,'IPS Next Response');
        Integer timeInMins1 = nextResp.calculateMilestoneTriggerTime(csLst[1].Id,'IPS Next Response');
        Integer timeInMins2 = nextResp.calculateMilestoneTriggerTime(csLst[2].Id,'IPS Next Response');
    }
}