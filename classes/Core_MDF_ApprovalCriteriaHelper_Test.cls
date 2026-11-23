/****************************************************************************************************************************************
* Class Name  : Core_MDF_ApprovalCriteriaHelper_Test 
* Version     : 1.0 
* Created Date: 09-13-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture – Harika P        09/13/2018                   Created Core_MDF_ApprovalCriteriaHelper_Test to test the set of dynamic picklist values.
*****************************************************************************************************************************************/
@isTest(SeeAllData=false)
private class Core_MDF_ApprovalCriteriaHelper_Test 
{ 
/****************************************************************************************************************************************
    Method Name:                                             createTestData
    Description:                                             Creating Test data to test Approval criteria Functionality.
    Added By:                                                Accenture – Harika P  -  09/13/2018
    Modified By:                  Date:                      Changes: 
    Accenture – Harika P          09/13/2018                 Created.
*****************************************************************************************************************************************/
    @isTest static void createTestData() 
    {
        UserRole usRole = [SELECT Id,Name FROM UserRole where Name = 'Admin' LIMIT 1];
        // Creating User with utility class 
        User usr = Core_MDF_CCP_TestDataUtility.createUser(false);
        usr.LastName = 'User Test';
        usr.UserRoleId = usRole.Id;
        Database.insert(usr);
        
        System.runAs(usr){  
            // Creating Criteria Instance 
            Core_MDF_Criteria__c cr = Core_MDF_CCP_TestDataUtility.createCriteria('PartnerFundRequest','Core_MDF_Activity_Approval_Processs',
               'Core_MDF_Channel_Partner_Led__c','Equal','true','Core_MDF_Start_Date__c','Greater Than or Equal', String.valueOf(System.today()),
               'Core_MDF_Country__c','Equal','INDIA','Core_MDF_ProductType__c','Equal','Desktop','RequestedAmount','Greater Than','4000',false);
            // Inserting Criteria
            Core_MDF_ApprovalCriteriaHelper.updateApprovalCriteria(cr);
            System.assert(cr.Id != NULL); 
            
            //Testing getAllFields method
            list<String> result = Core_MDF_ApprovalCriteriaHelper.getAllFields('PartnerFundRequest');

        
            result = Core_MDF_ApprovalCriteriaHelper.getAllFields('Campaign');

            //Testing updateApprovalCriteria method
            cr.Core_MDF_Object_Type__c = 'Contact';
            Core_MDF_ApprovalCriteriaHelper.updateApprovalCriteria(cr);
            System.assertEquals('Contact',cr.Core_MDF_Object_Type__c);
            
            //Creating Approver Set record
            Core_MDF_Approver__c approverSet = Core_MDF_CCP_TestDataUtility.createApprover(cr.Id,usr.Id, false);
            Database.insert(approverSet);
            
            //Creating Criteria Rules
            Core_MDF_Criteria_Rule__c crule1 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverSet.Id,'Core_MDF_End_Date__c','Less Than',
                                                                                              String.valueOf(System.today().addDays(90)),false);        
            Core_MDF_Criteria_Rule__c crule2 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverSet.Id,'RequestedAmount','Less Than or Equal'
                                                                                              ,'8000',false);        
            Core_MDF_Criteria_Rule__c crule3 = Core_MDF_CCP_TestDataUtility.createCriteriaRule(approverSet.Id,'Core_MDF_Brand__c','Equal',
                                                                                              'Intel Core i7+ Processor',false);
            list<Core_MDF_Criteria_Rule__c> crtRuleList = new list<Core_MDF_Criteria_Rule__c>();
            crtRuleList.add(crule1);
            crtRuleList.add(crule2);
            crtRuleList.add(crule3);
            Core_MDF_ApprovalCriteriaHelper.updateCriteriaRule(crtRuleList,approverSet.Id);
            System.assert(crule1.Id != NULL);
            System.assert(crule3.Id != NULL);
            System.assert(crule2.Id != NULL);
            
            crule1.Core_MDF_Field_Name__c = 'Core_MDF_Brand__c';
            Core_MDF_ApprovalCriteriaHelper.updateCriteriaRule(crtRuleList,approverSet.Id);
            System.assertEquals('Core_MDF_Brand__c',crule1.Core_MDF_Field_Name__c);
            
            list<Core_MDF_Criteria_Rule__c> newCrtRuleList = new list<Core_MDF_Criteria_Rule__c>();
            newCrtRuleList.add(crule1);
            newCrtRuleList.add(crule2);
            Core_MDF_ApprovalCriteriaHelper.updateCriteriaRule(newCrtRuleList,approverSet.Id);

            
            Core_MDF_ApprovalCriteriaHelper.getAllObjects();
            Core_MDF_ApprovalCriteriaHelper.getCriteria(cr.Id);
            Core_MDF_ApprovalCriteriaHelper.getCriteriaRule(cr.Id);
            Core_MDF_ApprovalCriteriaHelper.getFields(approverSet.Id);           
            
        } 
    }                
}