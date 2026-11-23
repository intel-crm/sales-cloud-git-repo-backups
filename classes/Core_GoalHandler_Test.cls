/**************************************************************************************
Apex Class Name:  Core_Goal_Test
Version     : 1.0 
Created Date: 12 OCT 2017
Function    : Test Class for the Core_GoalHandler
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* David S Wong                10/12/2017             Original Version
*************************************************************************************/

@isTest
public class Core_GoalHandler_Test {
    
    //Test section added to support Commissionable Transactions
    public static List < Core_Trigger_Executions__c > lstTriggerExecution = new List < Core_Trigger_Executions__c > ();
    public static List < Core_Commissionable_Transaction_Type__c > lstCommissionableTransactionType = new List < Core_Commissionable_Transaction_Type__c > ();
    public static List < Core_Commissions_Percent_Contribution__c > lstCommissionsPctContrib = new List < Core_Commissions_Percent_Contribution__c > ();    
    public static Core_Goal__c goal = new Core_Goal__c();
    public static Account account = new Account();
    public static Opportunity opportunity = new Opportunity(); 
    public static List<Opportunity> lstOpportunity = new List<Opportunity>();
    public static List<User> lstUser = new List<User>();
    public static List<Core_Goal__c> lstGoal = new List<Core_Goal__c>();
    public static Map<Integer,String> mapTeamMemberRole = new Map<Integer,String>();
    static void createTriggerExecutions() {        
        Core_Trigger_Executions__c TriggerExecutions = new Core_Trigger_Executions__c();
        TriggerExecutions.Name = 'goalAddCommissionableTxns';
        TriggerExecutions.Core_Object__c = 'Descriptive Feature';
        TriggerExecutions.Core_Trigger_Events__c = 'After insert After update';
        TriggerExecutions.Core_Active__c = true;
        TriggerExecutions.Core_Description__c = 'This is test description';
        TriggerExecutions.Core_Class_Name__c = 'Test Class';  
        lstTriggerExecution.add(TriggerExecutions);
        
        
        Core_Trigger_Executions__c TriggerExecutions1 = new Core_Trigger_Executions__c();
        TriggerExecutions1.Name = 'beforeGoalUpdateAcptDate';
        TriggerExecutions1.Core_Object__c = 'Descriptive Feature1';
        TriggerExecutions1.Core_Trigger_Events__c = 'Before Update';
        TriggerExecutions1.Core_Active__c = true;
        TriggerExecutions1.Core_Description__c = 'This is test description1';
        TriggerExecutions1.Core_Class_Name__c = 'Test Class1'; 
        lstTriggerExecution.add(TriggerExecutions1);
        lstTriggerExecution.add(new Core_Trigger_Executions__c(Name='restrictInactivePicklist',Core_Object__c='Core_GoalHandler',Core_Trigger_Events__c='before update',Core_Active__c=true,Core_Description__c='Update for Goal',Core_Class_Name__c='Core_GoalHandler'));
        
        insert lstTriggerExecution;
    }
    
    
    
    
    static void createCommissionableTransactionTypes() {        
        
        Core_Commissionable_Transaction_Type__c ctt = new Core_Commissionable_Transaction_Type__c();
        ctt.Name = 'Any Goal';
        ctt.Core_Opportunity_Product__c = 'Any Goal';
        ctt.Core_Commissionable_Transaction_Type__c = 'Deal Wins';
        lstCommissionableTransactionType.add(ctt);
        
        insert lstCommissionableTransactionType;
    }
    
    static void createCommissionsPctContrib() {
        //map of OpportunityTeamMember roles
        mapTeamMemberRole.put(0,'Goal Owner');
        
        Core_Commissions_Percent_Contribution__c cpc = new Core_Commissions_Percent_Contribution__c();
        cpc.Name = mapTeamMemberRole.get(0);
        cpc.Core_Percent_Contribution__c = 100;
        lstCommissionsPctContrib.add(cpc);
        
        insert lstCommissionsPctContrib;
        
    }
    
    static void createData(){
        createTriggerExecutions();        
        createCommissionableTransactionTypes();
        createCommissionsPctContrib();
        //create system admin//
        //Create a series of users
        Id profileId = [SELECT Id FROM Profile WHERE Name='System Administrator'].Id;
        user sysAdmin1=Core_Test_Utility.systemAdminUser;
        List<user> sysAdmin = Core_Test_Utility.Core_User(1);       
        sysAdmin[0].DelegatedApproverId = sysAdmin1.Id;
        sysAdmin[0].ProfileId = profileId;
        sysAdmin[0].LastName = 'Sample10000';
        sysAdmin[0].userName = 'testSampleUser100000@admin.com.crmdev';
        sysAdmin[0].email = 'testSampleUser100000@apttus.com';
        sysAdmin[0].alias = 'osdf';
        sysAdmin[0].communityNickName ='onodjaijdj';
        insert sysAdmin;
        lstUser = Core_Test_Utility.Core_User(6);
        system.debug('sysAdmin--->'+sysAdmin);
        integer i = 0;
        for(User user : lstUser)
        {
            user.FirstName = 'testusmact';
            user.LastName = 'Owner';
            user.Core_WWID__c = '9876543' + i;
            user.ManagerId=sysAdmin[0].Id;
            //Create one CTW and one non-badged user -- these users should not have associated Commissionable Transactions generated
            if (i == 4)
            {
                user.Core_Employee_Type_Code__c = 'CTW';
            }
            else if (i == 5)
            {
                user.Core_Employee_Type_Code__c = 'Non-Badged';
            }
            i++;
            system.debug('Adding user: ' + user.FirstName + ' ' + user.LastName + ' ' + user.Core_WWID__c + ' ' + user.Core_Employee_Type_Code__c );
        }
        
        try {
            insert lstUser;            
        } catch(DmlException e) {
            System.debug('Exception: ' + e.getMessage());
        }
        
        //Create an account
        Id accRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
        account.Name = 'testacct_OpportunityAddCommissionableTxns';            
        account.BillingCountryCode = 'USA';
        account.BillingStateCode = 'AL';
        account.BillingCity = 'Alabama';
        account.BillingStreet = 'test';
        account.Core_CIM_ID__c = '98765432';
        account.recordTypeId = accRecTypeId;
        account.Core_Account_Type__c = 'Distributor';
        account.Core_Sales_Group__c = 'Global Accounts';
        account.Industry = 'Agriculture';
        account.Core_Sales_Groups__c = 'CCG Sales Group';
        try {
            insert account;
            System.debug('Account ' + account.Name + ' inserted.');
        } catch(DmlException e) {
            System.debug('Exception: ' + e.getMessage());
        }
        
        List<Account> accounts = [SELECT Id, Core_CIM_ID__c, Name FROM Account WHERE name = :account.Name LIMIT 1];
        //System.assert(!accounts.isEmpty());
        account = accounts.get(0);
        
        //Create an associated opportunity
        opportunity.CloseDate = System.Today().addDays(24);
        opportunity.StageName = 'Design';
        opportunity.Name = 'testop_OpportunityAddCommissionableTxns';
        opportunity.AccountId = account.Id;
        opportunity.Core_Opportunity_Type__c = 'Deal: Sell-to';
        opportunity.Core_Solution_Area__c = 'DCG 5G Deal #';
        opportunity.Core_Sales_Group__c = 'Global Accounts';
        opportunity.Core_Opportunity_Type__c = 'Deal: Sell-to';
        opportunity.Core_Product_Segment__c = 'Drones';
        opportunity.Core_Product_Application__c = 'Drone - other';
        opportunity.Core_Consumption_Market__c = 'Consumer';
        opportunity.Core_Military_Aerospace_Govmt_End_Use__c = 'No';
        opportunity.Core_Commissionable__c = 'Yes';
        
        //try {
        insert opportunity;
        System.debug('Opportunity ' + opportunity.Name + ' inserted.  AccountID: ' + account.Id);
        //  } catch(DmlException e) {
        //   System.debug('Exception: ' + e.getMessage());
        // }
        system.debug('opportunityId in test class======>'+opportunity.Id);
        //Create a goal
        // list<Core_Goal__c> listgoal=new list<Core_Goal__c>();
        Core_Goal__c goal1=new Core_Goal__c();
        
        List<Core_Opportunity_KPI__c> templist=new List<Core_Opportunity_KPI__c>();
        Core_Opportunity_KPI__c newcoreOpp=new Core_Opportunity_KPI__c();
        newcoreOpp.Core_Opp_KPI_Achieved__c=true;
        newcoreOpp.Core_Opp_KPI_BU_Owner__c='IOTG';
        newcoreOpp.Core_Opp_KPI_Description__c='Test class';
        newcoreOpp.Core_Opp_KPI_Quantity__c=3;
        newcoreOpp.Core_Opp_KPI_Threshold_Met__c='Yes';
        newcoreOpp.Core_Opp_KPI_Threshold_Req__c='';
        newcoreOpp.Core_Opp_KPI_Total_Price__c=100;
        newcoreOpp.Core_Opp_KPI_Type__c='Salesforce Pipeline $';
        newcoreOpp.Core_Opp_KPI_Volume__c=99900.11;
        newcoreOpp.Name='kjhgfd';
        newcoreOpp.Core_Opp_KPI_Opportunity__c=opportunity.Id;
        templist.add(newcoreOpp);
        
        newcoreOpp=new Core_Opportunity_KPI__c();
        newcoreOpp.Core_Opp_KPI_Achieved__c=true;
        newcoreOpp.Core_Opp_KPI_BU_Owner__c='IOTG';
        newcoreOpp.Core_Opp_KPI_Description__c='Test class';
        newcoreOpp.Core_Opp_KPI_Quantity__c=3;
        newcoreOpp.Core_Opp_KPI_Threshold_Met__c='Yes';
        newcoreOpp.Core_Opp_KPI_Threshold_Req__c='';
        newcoreOpp.Core_Opp_KPI_Total_Price__c=100;
        newcoreOpp.Core_Opp_KPI_Type__c='Salesforce Pipeline $';
        newcoreOpp.Core_Opp_KPI_Volume__c=99900.11;
        newcoreOpp.Name='kjhgfd';
        newcoreOpp.Core_Opp_KPI_Opportunity__c=opportunity.Id;
        System.debug(' Core_Opportunity_KPI__c Opportunity Id*******************'+newcoreOpp.Core_Opp_KPI_Opportunity__c);
        templist.add(newcoreOpp); 
        insert templist;
        system.debug('templist%%%%%%%%%%%%%%%'+templist);
        
        //DWG_Opportunity__c dwg=new DWG_Opportunity__c();
        //System.runAs(lstUser[0]){
        goal1.Name = 'testGoal';
        //goal1.Core_Goal_Name__c = 'testGoal';
        goal1.Core_Goal_BU_Focus_Area__c ='CCG Gateway Deal #';
        goal1.Core_Goal_Category__c = 'Assigned';
        goal1.Core_Goal_Status__c = 'Accepted';
        goal1.Core_Goal_Criteria__c ='Comms Service Providers within SCH Segment; Based on “Intel® WAV Baseband Chipset”, PUMA SoCs, GRX SoCs, FALCont chipset. Threshold: 5K Units';
        goal1.Core_Goal_Claim_Date__c = System.Today();
        goal1.Core_Opportunity__c = opportunity.Id;
        
        //goal.OwnerId = lstUser.get(0).Id;
        goal1.Core_Goal_Approver__c=lstUser.get(1).Id;
        goal1.Core_Goal_Owner__c=lstUser.get(1).Id;
        try {
            insert goal1;
            System.debug('DWG Opportunity Id*******************'+goal1.Core_Opportunity__c);
            System.debug('goal ' + goal.Name + ' inserted successfully.' );
        } catch(DmlException e) {
            System.debug('DWG Exception: ' + e.getMessage());
        }
        goal1.name = 'name change';
        update goal1;
        
        //insert goal1;
        
        
        /*dwg.Core_DWG_Opportunity__c=opportunity.Id;
dwg.Core_DWG_Deal_Win_Goal__c=goal1.Id;
insert dwg;*/
        //}
        /*try {
insert goal;
System.debug('goal ' + goal.Core_Goal_Name__c + ' inserted.' );
} catch(DmlException e) {
System.debug('Exception: ' + e.getMessage());
}*/
        System.runAs(sysAdmin[0]){
            lstGoal = [SELECT Id, Name, Core_Goal_BU_Focus_Area__c, Core_Goal_Claim_Date__c, Core_Opportunity__c, OwnerId, CreatedById FROM Core_Goal__c WHERE Name = :goal1.Name LIMIT 1];
            System.assert(!lstGoal.isEmpty());
            goal = lstGoal.get(0);
            OpportunityShare optyShare = new OpportunityShare(UserOrGroupId=sysAdmin[0].Id, OpportunityId=opportunity.Id, RowCause='Manual', OpportunityAccessLevel = 'Read');
            insert optyShare;
        }
        
        //goal1.Core_Goal_KPI_Match_Flag__c=false;
        //goal1.Core_Goal_Approved_By__c=goal1.Id;
        // update goal1;
        
        
        //Core_Opportunity_KPI__c oppKPI = [SELECT id, name, Core_Opp_KPI_Achieved__c, Core_Opp_KPI_Threshold_Met__c, Core_Opp_KPI_Opportunity__c FROM Core_Opportunity_KPI__c WHERE Core_Opp_KPI_Opportunity__c=opportunity.Id];
        
        
        
        List<Core_Opportunity_KPI__c> clst =[SELECT id, name, Core_Opp_KPI_Achieved__c, Core_Opp_KPI_Threshold_Met__c, Core_Opp_KPI_Opportunity__c FROM Core_Opportunity_KPI__c WHERE Core_Opp_KPI_Opportunity__c= :opportunity.Id];
        System.debug('Size of OpptyKPILIST*********'+clst);
        
    }
    
    // updateGoalforKPIChange
    static testMethod void testupdateGoalforKPIChange() {        
        createData();
        
        /* Core_Opportunity_KPI__c OppKPI = new Core_Opportunity_KPI__c();
OppKPI.Name='DCG Cloud New Services Deal #';
OppKPI.Core_Opp_KPI_Opportunity__c=opportunity.Id;
OppKPI.Core_Opp_KPI_Achieved__c=true;
// OppKPI.Core_Goal_KPI_Achieved_Flag__c=True;
insert OppKPI;
OppKPI.Core_Opp_KPI_Achieved__c=false;
update OppKPI;


Core_Opportunity_KPI__c OppKPI1 = new Core_Opportunity_KPI__c();
OppKPI1.Name='DCG Cloud New Services Deal #';
OppKPI1.Core_Opp_KPI_Opportunity__c=opportunity.Id;
OppKPI1.Core_Opp_KPI_Achieved__c=false;
// OppKPI.Core_Goal_KPI_Achieved_Flag__c=false;
insert OppKPI1;
*/
        List<Core_Goal__c> lGoal = [SELECT Id, Core_Goal_Status__c, Core_Goal_Approved_Date__c, Core_Goal_Claim_Date__c, Core_Goal_Approved_By__c
                                    FROM Core_Goal__c WHERE Id = :lstGoal.get(0).Id];
        //System.assert(!lGoal.isEmpty());
        Set<Id> opptyIdKPIIdSet = new Set<Id>();
        
        Core_Goal__c g = lGoal.get(0); 
        // opptyIdKPIIdSet.add(g.Core_Opportunity__c);
        g.Core_Goal_Status__c = 'Approved';
        Core_GoalHandler.alreadyAddedCommissionableTransactions = false;
        test.startTest();
        
        Map<Id, Core_Goal__c> oldGoalMap= new Map<Id, Core_Goal__c>();
        oldGoalMap.put(Opportunity.Id, g);
        //Core_GoalHandler.updateGoalforKPIChange(lGoal, oldGoalMap);
        
        test.stopTest();
    }
    
    
    static testMethod void testApproveGoal() {        
        createData();
        
        List<Core_Goal__c> lGoal = [SELECT Id, Core_Goal_Status__c, Core_Goal_Approved_Date__c, Core_Goal_Claim_Date__c, Core_Goal_Approved_By__c
                                    FROM Core_Goal__c WHERE Id = :lstGoal.get(0).Id];
        //System.assert(!lGoal.isEmpty());
        
        Core_Goal__c g = lGoal.get(0); 
        
        System.debug('>>>>Test Goal Status before update:' + g.Core_Goal_Status__c);
        g.Core_Goal_Status__c = 'Approved';
        //g.Core_Goal_Approved_Date__c = System.today();
        Core_GoalHandler.alreadyAddedCommissionableTransactions = false;
        test.startTest();
        
        try {
            update g;         
        } catch(DmlException e) {
            System.debug('Exception: ' + e.getMessage());
        }
        
        lGoal = 
            [SELECT Id, Core_Goal_Status__c FROM Core_Goal__c WHERE Id = :g.Id];
        //System.assert(!lGoal.isEmpty());
        System.debug('>>>>Test Goal Status after update:' + lGoal.get(0).Core_Goal_Status__c);
        
        
        List <Core_Commissionable_Transaction__c> lct = [            
            SELECT Core_Account_Name__c,Core_Approved_Total_Price__c,Core_CIM_ID__c,Core_Claim_Date__c,
            Core_Employee_Name__c,Core_Last_Approved_Date__c,Core_Milestone_Area__c,
            Core_Milestone_Focus__c,Core_Milestone__c,Core_Opportunity_Name__c,Core_Opportunity_Team_Member_Role__c,
            Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,Core_Product_Type__c,
            Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,Core_Transaction_Type__c,Core_WWID__c,Core_Approved_BU_Short_Name__c
            FROM Core_Commissionable_Transaction__c 
        ];
        
        //System.assert(!lct.isEmpty());
        System.debug(lct.size() + ' entries in Commissionable Transactions associated with goal ' + g.Id);   
        for(Integer i=0; i<lct.size(); i++) {
            System.debug('CT Entries: ' + lct.get(i).Core_Status__c + ' ' + lct.get(i).Core_Employee_Name__c + ' ' 
                         + lct.get(i).Core_WWID__c + ' ' + lct.get(i).Core_Opportunity_Team_Member_Role__c 
                         + ' ' + lct.get(i).Core_Percent_Contribution__c);
        }
        //System.assert(lct.size() == 1);       
        test.stopTest();
        
    }
    
    
    static testMethod void testApproveAndRejectGoal() {
        
        createData();
        
        List<Core_Goal__c> lGoal = [SELECT Id, Core_Goal_Status__c, Core_Goal_Approved_Date__c, Core_Goal_Claim_Date__c, Core_Goal_Approved_By__c
                                    FROM Core_Goal__c WHERE Id = :lstGoal.get(0).Id];
        //System.assert(!lGoal.isEmpty());
        
        Core_Goal__c g = lGoal.get(0); 
        
        System.debug('>>>>Test Goal Status before update:' + g.Core_Goal_Status__c);
        g.Core_Goal_Status__c = 'Approved';
        //g.Core_Goal_Approved_Date__c = System.today();
        Core_GoalHandler.alreadyAddedCommissionableTransactions = false;
        test.startTest();
        
        try {
            update g;         
        } catch(DmlException e) {
            System.debug('Exception: ' + e.getMessage());
        }
        
        lGoal = 
            [SELECT Id, Core_Goal_Status__c
             FROM Core_Goal__c WHERE Id = :lstGoal.get(0).Id];
        //System.assert(!lGoal.isEmpty());
        System.debug('>>>>Test Goal Status after update:' + lGoal.get(0).Core_Goal_Status__c);
        
        Long start = System.now().getTime();
        
        List <Core_Commissionable_Transaction__c> lct = [            
            SELECT Core_Account_Name__c,Core_Approved_Total_Price__c,Core_CIM_ID__c,Core_Claim_Date__c,
            Core_Employee_Name__c,Core_Last_Approved_Date__c,Core_Milestone_Area__c,
            Core_Milestone_Focus__c,Core_Milestone__c,Core_Opportunity_Name__c,Core_Opportunity_Team_Member_Role__c,
            Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,Core_Product_Type__c,
            Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,Core_Transaction_Type__c,Core_WWID__c,Core_Approved_BU_Short_Name__c
            FROM Core_Commissionable_Transaction__c 
        ];
        
        //System.assert(!lct.isEmpty());
        System.debug(lct.size() + ' entries in Commissionable Transactions associated with goal ' + g.Id);   
        for(Integer i=0; i<lct.size(); i++) {
            System.debug('CT Entries: ' + lct.get(i).Core_Status__c + ' ' + lct.get(i).Core_Employee_Name__c + ' ' 
                         + lct.get(i).Core_WWID__c + ' ' + lct.get(i).Core_Opportunity_Team_Member_Role__c 
                         + ' ' + lct.get(i).Core_Percent_Contribution__c);
        }
        //System.assert(lct.size() == 1);       
        
        g = lGoal.get(0);
        g.Core_Goal_Status__c = 'Submitted';
        
        //Ensure the timestamp ticks over to the next second
        while(System.now().getTime()<start+1000){ 
        }
        
        Core_GoalHandler.alreadyAddedCommissionableTransactions = false;
        try {
            update g;         
        } catch(DmlException e) {
            System.debug('Exception: ' + e.getMessage());
        }
        
        start = System.now().getTime();
        
        List <Core_Commissionable_Transaction__c> lct2 = [            
            SELECT Core_Account_Name__c,Core_Approved_Total_Price__c,Core_CIM_ID__c,Core_Claim_Date__c,
            Core_Employee_Name__c,Core_Last_Approved_Date__c,Core_Milestone_Area__c,
            Core_Milestone_Focus__c,Core_Milestone__c,Core_Opportunity_Name__c,Core_Opportunity_Team_Member_Role__c,
            Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,Core_Product_Type__c,
            Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,Core_Transaction_Type__c,Core_WWID__c,Core_Approved_BU_Short_Name__c
            FROM Core_Commissionable_Transaction__c 
            WHERE Core_Status__c != 'Approved'
        ];
        
        //System.assert(!lct2.isEmpty());
        System.debug(lct2.size() + ' unapproved entries in Commissionable Transactions associated with goal ' + g.Id);  
        //System.assert(lct2.size() == 1);  
        for(Integer i=0; i<lct2.size(); i++) {
            /*System.assert(lct.get(i).Core_Status__c == 'Approved');
System.assert(lct2.get(i).Core_Status__c != 'Approved');
System.assert(lct.get(i).Core_Transaction_Timestamp__c <= lct2.get(i).Core_Transaction_Timestamp__c);
System.assert(lct.get(i).Core_WWID__c == lct2.get(i).Core_WWID__c);
System.assert(lct.get(i).Core_Employee_Name__c == lct2.get(i).Core_Employee_Name__c);*/
        }
        
        lGoal = 
            [SELECT Id, Core_Goal_Status__c
             FROM Core_Goal__c WHERE Id = :lstGoal.get(0).Id];
        //System.assert(!lGoal.isEmpty());
        System.debug('>>>>Test Goal Status after 2nd update:' + lGoal.get(0).Core_Goal_Status__c);
        
        g = lGoal.get(0);
        g.Core_Goal_Status__c = 'Approved';
        
        //Ensure the timestamp ticks over to the next second
        while(System.now().getTime()<start+1000){ 
        }       
        
        Core_GoalHandler.alreadyAddedCommissionableTransactions = false;
        try {
            update g;         
        } catch(DmlException e) {
            System.debug('Exception: ' + e.getMessage());
        }
        
        List <Core_Commissionable_Transaction__c> lct3 = [            
            SELECT Core_Account_Name__c,Core_Approved_Total_Price__c,Core_CIM_ID__c,Core_Claim_Date__c,
            Core_Employee_Name__c,Core_Last_Approved_Date__c,Core_Milestone_Area__c,
            Core_Milestone_Focus__c,Core_Milestone__c,Core_Opportunity_Name__c,Core_Opportunity_Team_Member_Role__c,
            Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,Core_Product_Type__c,
            Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,Core_Transaction_Type__c,Core_WWID__c,Core_Approved_BU_Short_Name__c
            FROM Core_Commissionable_Transaction__c 
        ];
        
        //System.assert(!lct3.isEmpty());
        System.debug(lct3.size() + ' total entries in Commissionable Transactions associated with OP ' + g.Id);    
        //System.assert(lct3.size() == 3); 
        for(Integer j=0; j<1; j++) {
            Integer i = j+2; //we actually just want to look at item 3 in lct3
            /*System.assert(lct3.get(i).Core_Status__c == 'Approved');
System.assert(lct2.get(j).Core_Transaction_Timestamp__c <= lct3.get(i).Core_Transaction_Timestamp__c);
System.assert(lct.get(j).Core_WWID__c == lct3.get(i).Core_WWID__c);
System.assert(lct.get(j).Core_Employee_Name__c == lct3.get(i).Core_Employee_Name__c);*/
        }
        
        test.stopTest();               
        
    }
    
    
    static testMethod void testupdateGoalonApproval() {
        //Create a goal for updateGoalonApproval//
        test.starttest();
        createData();
        Core_Goal__c goal1=new Core_Goal__c();
        goal1.Core_Goal_Name__c = 'testGoal';
        goal1.Core_Goal_BU_Focus_Area__c ='CCG Gateway Deal #';
        goal1.Core_Goal_Category__c = 'Assigned';
        goal1.Core_Goal_Status__c = 'Approved';
        goal1.Core_Goal_Criteria__c ='Comms Service Providers within SCH Segment; Based on “Intel® WAV Baseband Chipset”, PUMA SoCs, GRX SoCs, FALCont chipset. Threshold: 5K Units';
        goal1.Core_Goal_Claim_Date__c = System.Today();
        goal1.OwnerId = lstUser.get(0).Id;
        goal1.Core_Goal_Approver__c=lstUser.get(1).Id;
        goal1.Core_Goal_Owner__c=lstUser.get(1).Id;       
        insert goal1;  
        goal1.Core_Goal_Status__c='Submitted';       
        update goal1;
        test.stopTest(); 
    }
    
    static testMethod void GiveShareAccessDWG_Test() {
        test.starttest();
        createData();
        if(!lstGoal.isEmpty())
            Core_Goal_GiveShareAccessDWG.getAccountNames(lstGoal);
        test.stopTest(); 
        goal.Core_Goal_Status__c='Submitted'; 
        update goal;
        // Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        // req1.setObjectId(goal.id);
        
        //Submit on behalf of a specific submitter
        // req1.setSubmitterId(lstUser[0].Id); 
        
        //Submit the approval request for the account
        // Approval.ProcessResult result = Approval.process(req1);
    }
    
    //**************************************FOR KPI DWG****************************************************
    
    public static List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
    public static List<Opportunity> opportunityInstanceList = new List<Opportunity>();
    public static List<Core_Opportunity_KPI__c> opptyKPIList = new List<Core_Opportunity_KPI__c>();
    public static List<Core_Goal__c> opptyDWGList = new List<Core_Goal__c>();
    
    static void setupData2(){
        triggerExecList.add(new Core_Trigger_Executions__c(Name = 'beforeupdateinsertGoalKPI', Core_Active__c = true, 
                                                           Core_Class_Name__c = 'Core_GoalHandler', Core_Description__c = 'Test', 
                                                           Core_Object__c = 'Core_Goal__c', Core_Trigger_Events__c = 'Before Insert Before Update Before Delete'));
        insert triggerExecList;        
        Profile pr = [SELECT id, Name FROM Profile WHERE Name='IT Admin'];
        user usr = [SELECT id, Name, isActive FROM User WHERE ProfileId = :pr.Id AND isActive = true LIMIT 1];  
        
        Account accountInstance = new Account();
        accountInstance.name = 'TestAccount';
        accountInstance.BillingCountryCode = 'USA';
        accountInstance.BIllingStateCode = 'AL';
        accountInstance.BillingCity = 'Alabama';
        accountInstance.BillingStreet = 'test';  
        accountInstance.Core_CIM_ID__c='10102356';
        accountInstance.Core_Sales_Groups__c='CCG Sales Group'; 
        insert accountInstance;
        
        opportunityInstanceList.add(new Opportunity(CloseDate = System.Today().addDays(24), StageName ='Define', Name ='Test OppName', AccountId = accountInstance.Id, 
                                                    Core_First_Customer_Ship_Date__c=system.today().addDays(5), Core_Production_End_Date__c =System.Today().addDays(-10), 
                                                    Core_Opportunity_Type__c='Design: Original', Core_Intel_Platform__c='Apollo Lake D', Core_Technical_Owner__c =usr.Id));
        opportunityInstanceList.add(new Opportunity(CloseDate = System.Today().addDays(24), StageName ='Define', Name ='Test OppName123', AccountId = accountInstance.Id, 
                                                    Core_First_Customer_Ship_Date__c=system.today().addDays(5), Core_Production_End_Date__c =System.Today().addDays(-10), 
                                                    Core_Opportunity_Type__c='Design: Original', Core_Intel_Platform__c='Apollo Lake D', Core_Technical_Owner__c =usr.Id));
        opportunityInstanceList.add(new Opportunity(CloseDate = System.Today().addDays(24), StageName ='Define', Name ='Test OppName1234', AccountId = accountInstance.Id, 
                                                    Core_First_Customer_Ship_Date__c=system.today().addDays(5), Core_Production_End_Date__c =System.Today().addDays(-10), 
                                                    Core_Opportunity_Type__c='Design: Original', Core_Intel_Platform__c='Apollo Lake D', Core_Technical_Owner__c =usr.Id));
        insert opportunityInstanceList;
        
        opptyKPIList.add(new Core_Opportunity_KPI__c(Name='DCG Cloud New Services Deal #', 
                                                     Core_Opp_KPI_Opportunity__c = opportunityInstanceList[0].Id, Core_Opp_KPI_Achieved__c=true));
        opptyKPIList.add(new Core_Opportunity_KPI__c(Name='DCG Cloud New Services Deal #', 
                                                     Core_Opp_KPI_Opportunity__c = opportunityInstanceList[1].Id, Core_Opp_KPI_Achieved__c=false));
        opptyKPIList.add(new Core_Opportunity_KPI__c(Name='CCG Unite Deal #', 
                                                     Core_Opp_KPI_Opportunity__c = opportunityInstanceList[2].Id, Core_Opp_KPI_Achieved__c=false));
        insert opptyKPIList;
        
    }
    
    testMethod static void InsertOppTest1() { 
        setupData2();
        Test.startTest();
        setupData3();    
        Test.stopTest();
    }
    
    static void setupData3(){
        opptyDWGList.add(new Core_Goal__c(Name='Test DWG1', Core_Goal_Category__c = 'Assigned', Core_Goal_BU_Focus_Area__c='DCG Cloud New Services Deal #', 
                                          Core_Goal_Criteria__c='Deal Win # based on Purley XEONS flowing into Solution Types . Threshold: 60 Units Next Gen IaaS, Deep Learning, Database, Function', 
                                          Core_Opportunity__c=opportunityInstanceList[0].Id, Core_Goal_KPI_Match_Flag__c=false, Core_Goal_KPI_Achieved_Flag__c=false));
        opptyDWGList.add(new Core_Goal__c(Name='Test DWG12', Core_Goal_Category__c = 'Assigned', Core_Goal_BU_Focus_Area__c='DCG Cloud New Services Deal #', 
                                          Core_Goal_Criteria__c='Deal Win # based on Purley XEONS flowing into Solution Types . Threshold: 60 Units Next Gen IaaS, Deep Learning, Database, Function', 
                                          Core_Opportunity__c=opportunityInstanceList[0].Id, Core_Goal_KPI_Match_Flag__c=false, Core_Goal_KPI_Achieved_Flag__c=false));
        insert opptyDWGList;
    }
    
    testMethod static void updateDWGOpptyTest(){
        setupData2();
        setupData3();
        Test.startTest();
        System.debug('***OpptyDWG LIst '+opptyDWGList);
        System.debug('***Oppty LIst '+opportunityInstanceList);
        opptyDWGList[0].Core_Opportunity__c = opportunityInstanceList[1].Id;
        Core_GoalHandler.kpiRecurrCheck = false;
        update opptyDWGList[0];
        Test.stopTest(); 
        
    }
    
    testMethod static void updateDWGOpptyTest1(){
        setupData2();
        setupData3();
        Test.startTest();
        System.debug('***OpptyDWG LIst '+opptyDWGList);
        System.debug('***Oppty LIst '+opportunityInstanceList);
        opptyDWGList[0].Core_Opportunity__c = opportunityInstanceList[2].Id;
        Core_GoalHandler.kpiRecurrCheck = false;
        update opptyDWGList[0];
        Test.stopTest();         
    }    
}