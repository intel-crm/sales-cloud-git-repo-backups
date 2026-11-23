/***************************************************************************************************
* Apex Class Name: mileStoneUtils_Test
* Version     : 1.0 
* Created Date: 19th Dec 2015
* Function    : Test class for Contact_Handler
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Jayaprakash T               02/10/2016               Created
****************************************************************************************************/
@isTest(seealldata=true)
public class mileStoneUtils_Test{
    
    public static User SystUserRunAs; 
    public static List<Case> caseList = new List<Case>();
    public static Account account =  new Account();
    public static Contact con =  new Contact();
    public static Entitlement ent = new Entitlement();
    
    public static void getRecords(integer i){
        
        Profile prof = [select id from profile where name = 'System Administrator' limit 1];
        List<User> userList = new List<user>();
        userList = TestUtilities.getListOfUser(1);
        userList[0].profileId=prof.id;
        insert userlist;
        SystUserRunAs = new User();
        SystUserRunAs = userList[0];
        System.runAs(systUserRunAs){
            account = TestUtilities.getAccountRecord();
            insert account;
            //con = TestUtilities.getContact();
            //insert con;
            caseList = TestUtilities.getListOfCases(10);
            ent = TestUtilities.getEntitlementRecord();
            ent.accountid = account.id;
            ent.startdate = System.today()-1;
            ent.endDate = system.today()+760;
            if(i==1)
            {
             ent.SlaProcessId = Core_IPS_Labels__c.getValues('IPS Standard Entitlement Process ID').Value__c;
            }
            insert ent;
            recordtype Rtype = [select id from  recordtype where Name ='IPS case create'];
            for(case cs:caseList){
                cs.accountId = account.id;
                cs.entitlementId = ent.Id;
                cs.ownerId = userinfo.getUserID();
                cs.recordtypeId = Rtype.Id;
                cs.Core_First_Response_Completed__c =false;
            }
            insert caseList;
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
        
            milestoneUtils.getActiveMileStone(caseList[0]);
            List<CaseMilestone> Lst = [select Id,caseId,completionDate, isCompleted,MileStoneTypeId,MileStoneType.Name from CaseMilestone where caseId in :caseList];
            system.debug(Lst);
            milestoneUtils.getActiveMileStone(caseList);
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
            
            Group testGroup = new Group(Name='test group', Type='Queue');
            insert testGroup;
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
            
            caseList[0].OwnerId = testGroup.Id;//'00G21000000IKxC';
            update caseList;
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
            milestoneUtils.getSetNextResponseDueDate(caseList[0]);
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
            
            
            milestoneUtils.reStartMilestoneClockWhenCustomerresponded(caseList[0]);
            
            //caseList[0].
            milestoneUtils.AddCaseBizHoursOnOwnerUpdate(caseList[0],caseList[1]);
            milestoneUtils.AddCaseBizHoursOnOwnerUpdate(null,caseList[1]);
            //milestoneUtils.getBusinessHours(Owner)
        }
        Test.stoptest();
        
    }  
      
    
           
    
}