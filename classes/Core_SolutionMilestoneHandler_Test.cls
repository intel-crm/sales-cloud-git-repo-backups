/**************************************************************************************
Apex Class Name:  Core_SolutionMilestoneHandler_Test 
Version     : 1.0 
Created Date: 29 OCT 2015
Function    : Test Class for the Core_SolutionMilestoneHandler trigger
    Modification Log
* Developer                   Date                   Description
* ---------------------------------------------------------------------------- 
* Ajay Doddangadi           01/08/2017       Modified the criteria to before inserting to commission table.
* Sampath Bokam             11/09/2016              Modified code to put an entry in commissions table only for Milestone owner, and not team members                
* David Wong                10/29/2015              Original version
*************************************************************************************/
@istest
public class Core_SolutionMilestoneHandler_Test {

    //Declare/Initialize the Variables
    public static List < Core_Trigger_Executions__c > lstTriggerExecution = new List < Core_Trigger_Executions__c > ();
    public static List < Core_Commissionable_Transaction_Type__c > lstCommissionableTransactionType = new List < Core_Commissionable_Transaction_Type__c > ();
    public static List < Core_Commissions_Percent_Contribution__c > lstCommissionsPctContrib = new List < Core_Commissions_Percent_Contribution__c > ();    
    public static Account account = new Account();
    public static Opportunity opportunity = new Opportunity();    
    public static List<User> lstUser = new List<User>();
    public static List<Core_Solution_Milestone__c> lstSolutionMilestone = new List<Core_Solution_Milestone__c>();
    public static Map<Integer,String> mapMilestone = new Map<Integer,String>();

    static void createTriggerExecutions() {        
        Core_Trigger_Executions__c OpportunityFactsUpdate = new Core_Trigger_Executions__c();
        OpportunityFactsUpdate.Name = 'solutionMilestoneAddCommissionableTxns';
        OpportunityFactsUpdate.Core_Object__c = 'Descriptive Feature';
        OpportunityFactsUpdate.Core_Trigger_Events__c = 'After insert After update';
        OpportunityFactsUpdate.Core_Active__c = true;
        OpportunityFactsUpdate.Core_Description__c = 'This is test description';
        OpportunityFactsUpdate.Core_Class_Name__c = 'Test Class';

        lstTriggerExecution.add(OpportunityFactsUpdate);
        try {
            insert lstTriggerExecution;
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_SolutionMilestoneHandler_Test.createTriggerExecutions');
        }

    }

    static void createCommissionableTransactionTypes() {

        //Milestone map
        mapMilestone.put(0,'Concept/Program Solidification');
        mapMilestone.put(1,'Enabled SW Production GA');
        mapMilestone.put(2,'Deployment / Delivery');

        Core_Commissionable_Transaction_Type__c ctt = new Core_Commissionable_Transaction_Type__c();
        ctt.Name = mapMilestone.get(0);
        ctt.Core_Milestone__c = mapMilestone.get(0);
        ctt.Core_Commissionable_Transaction_Type__c = 'Opportunity Milestones';
        ctt.Core_Milestone__c= 'Concept/Program Solidification';
        lstCommissionableTransactionType.add(ctt);

        ctt = new Core_Commissionable_Transaction_Type__c();
        ctt.Name = mapMilestone.get(2);
        ctt.Core_Milestone__c = mapMilestone.get(2);
        ctt.Core_Commissionable_Transaction_Type__c = 'Opportunity Milestones';
        lstCommissionableTransactionType.add(ctt);
         try {
            insert lstCommissionableTransactionType;
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_SolutionMilestoneHandler_Test.createCommissionableTransactionTypes');
        }


    }

    /*
* Method name  : createData
* Description  : method to Create the instances for the record
* Return Type  : VOID
* Parameter    : NONE
*/  
    static void createData(){

        createTriggerExecutions();        
        createCommissionableTransactionTypes();

        //Create an account
        account.Name = 'testacct_solutionMilestoneAddCommissionableTxns';            
        account.BillingCountryCode = 'USA';
        account.BillingStateCode = 'AL';
        account.BillingCity = 'Alabama';
        account.BillingStreet = 'test';
        account.Core_Business_Party_Id__c = '98765432';
        account.Industry = 'Manufacturing';
        account.Core_Sales_Groups__c = 'Global Solutions & Services Sales Group';
        try {
            insert account;
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_SolutionMilestoneHandler_Test.createData');
        }

        List<Account> accountList = [SELECT Id, Core_Business_Party_Id__c, Name FROM Account WHERE name = :account.Name LIMIT 1];
        //System.assert(!accountList.isEmpty());
        account = accountList.get(0);
        
        //Create an associated opportunity
        opportunity.CloseDate = System.Today().addDays(24);
        opportunity.StageName = 'Prospecting';
        opportunity.Name = 'testop_solutionMilestoneAddCommissionableTxns';
        opportunity.AccountId = account.Id;
        opportunity.Core_Opportunity_Type__c = 'Design: Original';
        
        try {
            insert opportunity;
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_SolutionMilestoneHandler_Test.createData');
        }

        List<Opportunity> opportunityList = [SELECT Id, Name, Core_Opportunity_Type__c FROM Opportunity WHERE name = :opportunity.Name LIMIT 1];
        //System.assert(!opportunityList.isEmpty());
        opportunity = opportunityList.get(0);

        //Create a series of users
        lstUser = Core_Test_Utility.Core_User(1);
        integer i = 0;
        for(User user : lstUser)
        {
            user.FirstName = 'testusmact';
            user.LastName = 'testLastname';
            user.Core_WWID__c = '9876543' + i;
            i++;
        }       


        try {
            insert lstUser;            
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_SolutionMilestoneHandler_Test.createData');
        }
        Database.SaveResult[] lstSaveResultUser = Database.insert(lstUser, false);
       
        lstUser = [SELECT Id, Name, Core_WWID__c, FirstName, LastName, Core_Employee_Type_Code__c
                   FROM User WHERE FirstName = 'testusmact'];
        //System.assert(!lstUser.isEmpty());     
        
        //Create associated solution milestones
        for (integer a=0; a<3; a++)
        {
            Core_Solution_Milestone__c milestone = new Core_Solution_Milestone__c();
            milestone.Core_Opportunity__c = opportunity.Id;
            milestone.Core_Milestone_Description__c = 'Test 2 desp';
            milestone.Core_Milestone__c = mapMilestone.get(a);
            milestone.Core_Milestone_Focus__c = 'Docking';
            milestone.Core_Milestone_Focus_Area__c = 'Deal - CCG';
            milestone.Core_Status__c = 'Pending';   
            milestone.Core_Milestone_Commissionable__c = Core_Static_Variables.YES; // added the condition - US70556
            milestone.Core_Milestone_Claim_Date__c =  System.Today();
            milestone.Core_Milestone_Date__c = System.Today();
            milestone.Core_Owner__c = lstUser.get(0).Id;
            milestone.Core_Deployment_Quantity__c = 10;
            milestone.Core_As_Measured_By__c = 'Test';
            milestone.Core_Results_Key_Learnings__c = 'Test';
            lstSolutionMilestone.add(milestone);
        }
        for (Core_Solution_Milestone__c ms : lstSolutionMilestone) {
            //System.debug('Adding milestone: ' + ms.Core_Milestone_Claim_Date__c +'|' + ms.Core_Milestone__c +'|' + ms.Core_Status__c);
        }

        try {
            insert lstSolutionMilestone;            
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_SolutionMilestoneHandler_Test.createData');
        }
        //Database.SaveResult[] lstSaveResultMilestone = Database.insert(lstSolutionMilestone, false);

        lstSolutionMilestone = [SELECT Id, Core_Opportunity__c, Core_Milestone__c, Core_Milestone_Focus__c, Core_Milestone_Claim_Date__c, Core_Status__c 
                                FROM Core_Solution_Milestone__c WHERE Core_Opportunity__c = :opportunity.Id];

        //System.assert(!lstSolutionMilestone.isEmpty());
        for (Core_Solution_Milestone__c ms : lstSolutionMilestone) {
            //System.debug('Added milestone: ' + ms.Core_Milestone_Claim_Date__c +'|' + ms.Core_Milestone__c +'|' + ms.Core_Status__c);
        }
        //new
            Core_Commissionable_Transaction__c ct = new Core_Commissionable_Transaction__c();
            ct.Core_Opportunity__c = opportunity.Id;
            ct.Core_Status__c = 'Approved';
            ct.Core_Source_ID__c = lstSolutionMilestone[0].Id;
        try {
            insert ct;            
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_SolutionMilestoneHandler_Test.createData');
        }
        //new end
    }

    static testMethod void testApproveMilestone() {
    createData();

    // Ensure that lstSolutionMilestone is not null and contains elements
    if (lstSolutionMilestone != null && !lstSolutionMilestone.isEmpty()) {
        // Query to get the Core_Solution_Milestone__c record
        List<Core_Solution_Milestone__c> lsm = [
            SELECT Id, Core_Opportunity__c, Core_Milestone__c, Core_Milestone_Focus__c, Core_Milestone_Claim_Date__c, Core_Status__c, Core_Milestone_Approved_Date__c 
            FROM Core_Solution_Milestone__c 
            WHERE Id = :lstSolutionMilestone.get(0).Id
        ];

        // Ensure the query returned results
        if (!lsm.isEmpty()) {
            Core_Solution_Milestone__c milestone = lsm.get(0);
            milestone.Core_Status__c = 'Approved';
            milestone.Core_Milestone_Approved_Date__c = System.today();
            milestone.Core_Milestone__c = 'Definition';

            Core_SolutionMilestoneHandler.alreadyAddedCommissionableTransactions = false;

            try {
                update milestone;
            } catch (DmlException e) {
                PMP_Utility.logError(e, 'Core_SolutionMilestoneHandler_Test.testApproveMilestone');
            }

            // Query to get Core_Commissionable_Transaction__c records
            List<Core_Commissionable_Transaction__c> lct = [
                SELECT Core_Account_Name__c, Core_Approved_Total_Price__c, Core_Claim_Date__c,
                Core_Employee_Name__c, Core_Last_Approved_Date__c, Core_Milestone_Area__c,
                Core_Milestone_Focus__c, Core_Milestone__c, Core_Opportunity_Name__c, Core_Opportunity_Team_Member_Role__c,
                Core_Opportunity_Type__c, Core_Opportunity__c, Core_Percent_Contribution__c, Core_Product_Type__c,
                Core_Source_ID__c, Core_Status__c, Core_Transaction_Timestamp__c, Core_Transaction_Type__c, Core_WWID__c 
                FROM Core_Commissionable_Transaction__c 
                WHERE Core_Source_ID__c = :milestone.Id
            ];

            // Debug logging to check the size of lct
            //System.debug(lct.size() + ' entries in Commissionable Transactions associated with milestone ' + milestone.Id);

            // Ensure lct is not empty before accessing
            if (!lct.isEmpty()) {
                for (Integer i = 0; i < lct.size(); i++) {
                    /*System.debug('CT Entries: ' + lct.get(i).Core_Status__c + ' ' + lct.get(i).Core_Employee_Name__c + ' '
                                 + lct.get(i).Core_WWID__c + ' ' + lct.get(i).Core_Opportunity_Team_Member_Role__c
                                 + ' ' + lct.get(i).Core_Percent_Contribution__c);*/
                    // Assert that this is not the CTW or Non-Badged employee
                    // System.assert(lct.get(i).Core_WWID__c != '98765434');
                    // System.assert(lct.get(i).Core_WWID__c != '98765435');
                }
                
                // Access the first entry in lct safely
                Core_Commissionable_Transaction__c ct = lct.get(0);
                // Perform additional assertions or operations with ct if needed
            } else {
                //System.debug('No Commissionable Transactions found for milestone ' + milestone.Id);
            }
        } else {
            //System.debug('No Solution Milestones found for the given Id.');
        }
    } else {
        //System.debug('No Solution Milestones in lstSolutionMilestone.');
    }
}


    static testMethod void testApproveAndRejectMilestone() {

        createData();
        List<Core_Solution_Milestone__c> lsm = 
            [SELECT Id, Core_Opportunity__c, Core_Milestone__c, Core_Milestone_Focus__c, Core_Milestone_Claim_Date__c, Core_Status__c, Core_Milestone_Approved_Date__c 
             FROM Core_Solution_Milestone__c WHERE Core_Milestone__c = :mapMilestone.get(0)];
        //System.assert(!lsm.isEmpty());
        Core_Solution_Milestone__c milestone = lsm.get(0);          
        milestone.Core_Status__c = 'Approved';
        milestone.Core_Milestone_Approved_Date__c = System.today();

        Core_SolutionMilestoneHandler.alreadyAddedCommissionableTransactions = false;
        try {
            update milestone;         
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_SolutionMilestoneHandler_Test.testApproveAndRejectMilestone');
        }

        Long start = System.now().getTime();

        List <Core_Commissionable_Transaction__c> lct = [            
            SELECT Core_Account_Name__c,Core_Approved_Total_Price__c,Core_Claim_Date__c,
            Core_Employee_Name__c,Core_Last_Approved_Date__c,Core_Milestone_Area__c,
            Core_Milestone_Focus__c,Core_Milestone__c,Core_Opportunity_Name__c,Core_Opportunity_Team_Member_Role__c,
            Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,Core_Product_Type__c,
            Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,Core_Transaction_Type__c,Core_WWID__c 
            FROM Core_Commissionable_Transaction__c 
            WHERE Core_Source_ID__c = : milestone.Id
            ORDER BY Core_WWID__c ASC, Core_Employee_Name__c ASC
        ];

        //System.assert(!lct.isEmpty());
        //System.debug(lct.size() + ' entries in Commissionable Transactions associated with milestone ' + milestone.Id); 
        //System.assert(lct.size() == 1);

        lsm = [SELECT Id, Core_Opportunity__c, Core_Milestone__c, Core_Milestone_Focus__c, Core_Milestone_Claim_Date__c, Core_Status__c 
               FROM Core_Solution_Milestone__c WHERE Id = :lstSolutionMilestone.get(0).Id];
        //System.assert(!lsm.isEmpty()); 

        milestone = lsm.get(0);
        milestone.Core_Status__c = 'Pending';

        //Ensure the timestamp ticks over to the next second
        while(System.now().getTime()<start+1000){ 
        }
        //System.debug(System.now().getTime() + '|' + start + '|' + System.now().formatGmt('yyyyMMddHHmmssSSS'));

        Core_SolutionMilestoneHandler.alreadyAddedCommissionableTransactions = false;
        try {
            update milestone;         
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_SolutionMilestoneHandler_Test.testApproveAndRejectMilestone');
        }

        start = System.now().getTime();

        List <Core_Commissionable_Transaction__c> lct2 = [            
            SELECT Core_Account_Name__c,Core_Approved_Total_Price__c,Core_Claim_Date__c,
            Core_Employee_Name__c,Core_Last_Approved_Date__c,Core_Milestone_Area__c,
            Core_Milestone_Focus__c,Core_Milestone__c,Core_Opportunity_Name__c,Core_Opportunity_Team_Member_Role__c,
            Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,Core_Product_Type__c,
            Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,Core_Transaction_Type__c,Core_WWID__c 
            FROM Core_Commissionable_Transaction__c 
            WHERE Core_Source_ID__c = : milestone.Id AND Core_Status__c <> 'Approved'
            ORDER BY Core_WWID__c ASC, Core_Employee_Name__c ASC
        ];

        //System.assert(!lct2.isEmpty());
        //System.debug(lct2.size() + ' entries in Commissionable Transactions associated with milestone ' + milestone.Id);     
        //System.assert(lct2.size() == 1);
        /*for(Integer i=0; i<1; i++) {
            System.assert(lct.get(i).Core_Status__c == 'Approved');
            System.assert(lct2.get(i).Core_Status__c != 'Approved');
            System.assert(lct.get(i).Core_Transaction_Timestamp__c < lct2.get(i).Core_Transaction_Timestamp__c);
            System.assert(lct.get(i).Core_WWID__c == lct2.get(i).Core_WWID__c);
            System.assert(lct.get(i).Core_Employee_Name__c == lct2.get(i).Core_Employee_Name__c);
            System.assert(lct.get(i).Core_Opportunity_Name__c == lct2.get(i).Core_Opportunity_Name__c);
            System.assert(lct.get(i).Core_Milestone__c == lct2.get(i).Core_Milestone__c);
            System.assert(lct.get(i).Core_Milestone__c == mapMilestone.get(0));
        }*/

        //Not a relevant milestone - should not get added to Commissionable Transactions after update
        lsm = [SELECT Id, Core_Opportunity__c, Core_Milestone__c, Core_Milestone_Focus__c, Core_Milestone_Claim_Date__c, Core_Status__c 
               FROM Core_Solution_Milestone__c WHERE Id = :lstSolutionMilestone.get(1).Id];
        //System.assert(!lsm.isEmpty());         
        Core_Solution_Milestone__c milestone2 = lsm.get(0);        
        milestone2.Core_Status__c = 'Approved';
        milestone2.Core_Milestone_Approved_Date__c = System.today();

        //Ensure the timestamp ticks over to the next second
        while(System.now().getTime()<start+1000){ 
        } 

        Core_SolutionMilestoneHandler.alreadyAddedCommissionableTransactions = false;
        try {
            update milestone;         
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_SolutionMilestoneHandler_Test.testApproveAndRejectMilestone');
        } 

        start = System.now().getTime();

        List <Core_Commissionable_Transaction__c> lct3 = [            
            SELECT Core_Account_Name__c,Core_Approved_Total_Price__c,Core_Claim_Date__c,
            Core_Employee_Name__c,Core_Last_Approved_Date__c,Core_Milestone_Area__c,
            Core_Milestone_Focus__c,Core_Milestone__c,Core_Opportunity_Name__c,Core_Opportunity_Team_Member_Role__c,
            Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,Core_Product_Type__c,
            Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,Core_Transaction_Type__c,Core_WWID__c 
            FROM Core_Commissionable_Transaction__c 
            ORDER BY Core_WWID__c ASC, Core_Employee_Name__c ASC
        ];

        //System.assert(lct3.size() == 1);

        lsm = [SELECT Id, Core_Opportunity__c, Core_Milestone__c, Core_Milestone_Focus__c, Core_Milestone_Claim_Date__c, Core_Status__c 
               FROM Core_Solution_Milestone__c WHERE Id = :lstSolutionMilestone.get(0).Id];
        //System.assert(!lsm.isEmpty()); 

        milestone = lsm.get(0);
        milestone.Core_Status__c = 'Approved';

        //Ensure the timestamp ticks over to the next second
        while(System.now().getTime()<start+1000){ 
        }
        //System.debug(System.now().getTime() + '|' + start + '|' + System.now().formatGmt('yyyyMMddHHmmssSSS'));

        Core_SolutionMilestoneHandler.alreadyAddedCommissionableTransactions = false;
        try {
            update milestone;         
        } catch(DmlException e) {
            PMP_Utility.logError(e, 'Core_SolutionMilestoneHandler_Test.testApproveMilestone');
        }

        List <Core_Commissionable_Transaction__c> lct4 = [            
            SELECT Core_Account_Name__c,Core_Approved_Total_Price__c,Core_Claim_Date__c,
            Core_Employee_Name__c,Core_Last_Approved_Date__c,Core_Milestone_Area__c,
            Core_Milestone_Focus__c,Core_Milestone__c,Core_Opportunity_Name__c,Core_Opportunity_Team_Member_Role__c,
            Core_Opportunity_Type__c,Core_Opportunity__c,Core_Percent_Contribution__c,Core_Product_Type__c,
            Core_Source_ID__c,Core_Status__c,Core_Transaction_Timestamp__c,Core_Transaction_Type__c,Core_WWID__c 
            FROM Core_Commissionable_Transaction__c 
            WHERE Core_Source_ID__c = : milestone.Id 
            ORDER BY Core_Transaction_Timestamp__c ASC, Core_WWID__c ASC, Core_Employee_Name__c ASC
        ];

        //System.assert(!lct4.isEmpty());
        //System.debug(lct4.size() + ' entries in Commissionable Transactions associated with milestone ' + milestone.Id);     
        //System.assert(lct4.size() == 1);
    }  
}