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
        
        //Create a series of users
        lstUser = Core_Test_Utility.Core_User(6);
        integer i = 0;
        for(User user : lstUser)
        {
            user.FirstName = 'testusmact';
            user.LastName = 'Owner';
            user.Core_WWID__c = '9876543' + i;
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
        account.Name = 'testacct_OpportunityAddCommissionableTxns';            
        account.BillingCountryCode = 'USA';
        account.BillingStateCode = 'AL';
        account.BillingCity = 'Alabama';
        account.BillingStreet = 'test';
        account.Core_CIM_ID__c = '98765432';
        try {
            insert account;
            System.debug('Account ' + account.Name + ' inserted.');
        } catch(DmlException e) {
            System.debug('Exception: ' + e.getMessage());
        }

        List<Account> accounts = [SELECT Id, Core_CIM_ID__c, Name FROM Account WHERE name = :account.Name LIMIT 1];
        System.assert(!accounts.isEmpty());
        account = accounts.get(0);

        //Create an associated opportunity
        opportunity.CloseDate = System.Today().addDays(24);
        opportunity.StageName = 'Design';
        opportunity.Name = 'testop_OpportunityAddCommissionableTxns';
        opportunity.AccountId = account.Id;
        opportunity.Core_Opportunity_Type__c = 'Deal: Sell-to';

        try {
            insert opportunity;
            System.debug('Opportunity ' + opportunity.Name + ' inserted.  AccountID: ' + account.Id);
        } catch(DmlException e) {
            System.debug('Exception: ' + e.getMessage());
        }
        
        //Create a goal
        goal.Core_Goal_Name__c = 'testGoal';
        goal.Core_Goal_BU_Focus_Area__c = 'CCG: Operators';
        goal.Core_Goal_Category__c = 'Assigned';
        goal.Core_Goal_Claim_Date__c = System.Today();
        goal.OwnerId = lstUser.get(0).Id;
        
        try {
            insert goal;
            System.debug('goal ' + goal.Core_Goal_Name__c + ' inserted.' );
        } catch(DmlException e) {
            System.debug('Exception: ' + e.getMessage());
        }

        lstGoal = [SELECT Id, Name, Core_Goal_BU_Focus_Area__c, Core_Goal_Claim_Date__c, OwnerId FROM Core_Goal__c WHERE Core_Goal_Name__c = :goal.Core_Goal_Name__c LIMIT 1];
        System.assert(!lstGoal.isEmpty());
        goal = lstGoal.get(0);
    }

    static testMethod void testApproveGoal() {        
        createData();
        
        List<Core_Goal__c> lGoal = [SELECT Id, Core_Goal_Status__c, Core_Goal_Approved_Date__c, Core_Goal_Claim_Date__c, Core_Goal_Approved_By__c
                           FROM Core_Goal__c WHERE Id = :lstGoal.get(0).Id];
        System.assert(!lGoal.isEmpty());
        
        Core_Goal__c g = lGoal.get(0); 
        
        System.debug('>>>>Test Goal Status before update:' + g.Core_Goal_Status__c);
        g.Core_Goal_Status__c = 'Approved';
        g.Core_Goal_Approved_Date__c = System.today();
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
        System.assert(!lGoal.isEmpty());
        System.debug('>>>>Test Goal Status after update:' + lGoal.get(0).Core_Goal_Status__c);
                

        List <Core_Commissionable_Transaction__c> lct = [            
            SELECT Core_Account_Name__c,Core_Approved_Total_Price__c,Core_CIM_ID__c,Core_Claim_Date__c,
            Core_Employee_Name__c,Core_Last_Approved_Date__c,Core_Milestone_Area__c,
            Core_Milestone_Focus__c,Core_Milestone__c,Core_Opportunity_Name__c,Core_Opportunity_Team_Member_Role__c,
            Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,Core_Product_Type__c,
            Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,Core_Transaction_Type__c,Core_WWID__c,Core_Approved_BU_Short_Name__c
            FROM Core_Commissionable_Transaction__c 
        ];

        System.assert(!lct.isEmpty());
        System.debug(lct.size() + ' entries in Commissionable Transactions associated with goal ' + g.Id);   
        for(Integer i=0; i<lct.size(); i++) {
            System.debug('CT Entries: ' + lct.get(i).Core_Status__c + ' ' + lct.get(i).Core_Employee_Name__c + ' ' 
                         + lct.get(i).Core_WWID__c + ' ' + lct.get(i).Core_Opportunity_Team_Member_Role__c 
                         + ' ' + lct.get(i).Core_Percent_Contribution__c);
        }
        System.assert(lct.size() == 1);       
        test.stopTest();
    }
    
    static testMethod void testApproveAndRejectGoal() {
        
        createData();
        
        List<Core_Goal__c> lGoal = [SELECT Id, Core_Goal_Status__c, Core_Goal_Approved_Date__c, Core_Goal_Claim_Date__c, Core_Goal_Approved_By__c
                           FROM Core_Goal__c WHERE Id = :lstGoal.get(0).Id];
        System.assert(!lGoal.isEmpty());
        
        Core_Goal__c g = lGoal.get(0); 
        
        System.debug('>>>>Test Goal Status before update:' + g.Core_Goal_Status__c);
        g.Core_Goal_Status__c = 'Approved';
        g.Core_Goal_Approved_Date__c = System.today();
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
        System.assert(!lGoal.isEmpty());
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

        System.assert(!lct.isEmpty());
        System.debug(lct.size() + ' entries in Commissionable Transactions associated with goal ' + g.Id);   
        for(Integer i=0; i<lct.size(); i++) {
            System.debug('CT Entries: ' + lct.get(i).Core_Status__c + ' ' + lct.get(i).Core_Employee_Name__c + ' ' 
                         + lct.get(i).Core_WWID__c + ' ' + lct.get(i).Core_Opportunity_Team_Member_Role__c 
                         + ' ' + lct.get(i).Core_Percent_Contribution__c);
        }
        System.assert(lct.size() == 1);       
        
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
        
        System.assert(!lct2.isEmpty());
        System.debug(lct2.size() + ' unapproved entries in Commissionable Transactions associated with goal ' + g.Id);  
        System.assert(lct2.size() == 1);  
        for(Integer i=0; i<lct2.size(); i++) {
            System.assert(lct.get(i).Core_Status__c == 'Approved');
            System.assert(lct2.get(i).Core_Status__c != 'Approved');
            System.assert(lct.get(i).Core_Transaction_Timestamp__c <= lct2.get(i).Core_Transaction_Timestamp__c);
            System.assert(lct.get(i).Core_WWID__c == lct2.get(i).Core_WWID__c);
            System.assert(lct.get(i).Core_Employee_Name__c == lct2.get(i).Core_Employee_Name__c);
        }
        
        lGoal = 
            [SELECT Id, Core_Goal_Status__c
             FROM Core_Goal__c WHERE Id = :lstGoal.get(0).Id];
        System.assert(!lGoal.isEmpty());
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
        
        System.assert(!lct3.isEmpty());
        System.debug(lct3.size() + ' total entries in Commissionable Transactions associated with OP ' + g.Id);    
        System.assert(lct3.size() == 3); 
        for(Integer j=0; j<1; j++) {
            Integer i = j+2; //we actually just want to look at item 3 in lct3
            System.assert(lct3.get(i).Core_Status__c == 'Approved');
            System.assert(lct2.get(j).Core_Transaction_Timestamp__c <= lct3.get(i).Core_Transaction_Timestamp__c);
            System.assert(lct.get(j).Core_WWID__c == lct3.get(i).Core_WWID__c);
            System.assert(lct.get(j).Core_Employee_Name__c == lct3.get(i).Core_Employee_Name__c);
        }

        test.stopTest();               
        
    }

}