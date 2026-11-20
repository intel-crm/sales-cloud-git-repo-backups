/****************************************************************************************************
Apex Class Name:  Core_FieldSetWrapper_Test
Version     : 1.0 
Created Date: 17 DEC 2014
Function    : Test class for "Core_FieldSetWrapper" Class
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Kunal Mehta             17/12/2014              Original Version
*****************************************************************************************************/
@isTest
public class Core_FieldSetWrapper_Test {
    Static Final String  SOL_FOCUS_SELECT_1 = '5G UE/CPE';
    Static Final String  SOL_FOCUS_SELECT_2 = 'Client Transformation';

    Static Final String INTEL_PLATFORM = 'Broadwell';

    Static List<Opportunity> lstOpportunityInsertion;

    Static List<Account> lstAccountInsertion;
    /*
     * Method name  : setupTestData
     * Description  : Method to setup test data ( Leads)
     * Return Type  : None
     * Parameter    : None
     */
    static void setupTestData() {

        // Create and insert a list of Account records
        Id newAccountRecTypeId = [select Id from RecordType where DeveloperName = 'Mastered_Account' and sobjecttype = 'Account' limit 1][0].Id;
        lstAccountInsertion = new List<Account>();
        lstAccountInsertion = Core_Test_Utility.createAccount(5);
        for (Integer i = 0; i < 5; i++) {
            lstAccountInsertion.get(i).Core_Sales_Groups__c = 'PRC Sales Group';
            lstAccountInsertion.get(i).RecordTypeId = newAccountRecTypeId;
        }
        //System.runAs(Core_Test_Utility.systemAdminUser) {
            insert lstAccountInsertion;
        //}

        // Create and insert a list of Opportunity records
        lstOpportunityInsertion = new List<Opportunity>();
        lstOpportunityInsertion = Core_Test_Utility.createOpportunity(5);

        // Updated the opportunity record to relate it to Account records
        for (Integer i = 0; i < 5; i++) {
            lstOpportunityInsertion.get(i).AccountId = lstAccountInsertion.get(i).Id;
        }

        insert lstOpportunityInsertion;
    }

    /*
     * Method name  : testFieldSetWrapperController
     * Description  : Testmethod method for testing "Core_FieldSetWrapper" Controller
     *Return Type  : None
     * Parameter    : None
     */


    public static testMethod void testFieldSetWrapperController() {

        // Setting up the enivronment for testing 
        setupTestData();

        // Setting up the page to be tested
        PageReference searchPage = Page.Core_OpportunitySearch;

        User userInstance = [SELECT Id, Name, Core_Employee_Type_Code__c From USER Where isActive = TRUE
                             AND Core_Employee_Type_Code__c = : System.Label.Core_Employee_Type LIMIT 1];

        Test.startTest();

            System.runAs(userInstance) {
    
                // Creating the instance of controller to be tested      
                Core_OpportunitySearchController pageController = new Core_OpportunitySearchController();
                pageController.search();
    
                //  System.assertEquals(pageController.bErrorMessage, true);
    
    
                // Iterating on the feild set fields and populating value for testing
                for (Core_fieldSetWrapper fieldSetInstance: pageController.lstOpportunityFieldSetWrapper ) {
                    if (fieldSetInstance.dataType == 'PICKLIST' && fieldSetInstance.fieldName.equalsIgnoreCase('Core_Intel_Platform__c'))
                        fieldSetInstance.selectedPicklistValue = INTEL_PLATFORM;

                    if (fieldSetInstance.dataType == 'STRING' && 
                        fieldSetInstance.relatedField != NULL &&
                        fieldSetInstance.relatedField.equalsIgnoreCase('Name') && 
                        fieldSetInstance.relatedObject != NULL &&
                        fieldSetInstance.relatedObject.equalsIgnoreCase('Account'))
                        fieldSetInstance.textValue = 'Test';

                    if (fieldSetInstance.dataType == 'MULTIPICKLIST' && fieldSetInstance.fieldName.equalsIgnoreCase('Core_Solution_Focus__c')) {
                        fieldSetInstance.chosen = new List<String> {SOL_FOCUS_SELECT_1};
                        List<SelectOption> chosenMultiselect = new List<SelectOption>();
                        chosenMultiselect.add(new SelectOption(SOL_FOCUS_SELECT_1, SOL_FOCUS_SELECT_1));
                        chosenMultiselect.add(new SelectOption(SOL_FOCUS_SELECT_2, SOL_FOCUS_SELECT_2));
                        fieldSetInstance.chosenItems = chosenMultiselect;
                        fieldSetInstance.available = new List<String> {SOL_FOCUS_SELECT_2};
                        fieldSetInstance.add();

                        List<SelectOption> chosentoRemoveMultiselect = new List<SelectOption>();
                        chosentoRemoveMultiselect.add(new SelectOption(SOL_FOCUS_SELECT_2, SOL_FOCUS_SELECT_2));
                        fieldSetInstance.chosenItems = chosentoRemoveMultiselect;
                        fieldSetInstance.chosen = new List<String> {SOL_FOCUS_SELECT_2};
                        fieldSetInstance.remove();
                    }
                }
            }
    
            User accessDeniedUser = [SELECT Id, Name, Core_Employee_Type_Code__c From USER Where isActive = TRUE
                                     AND Core_Employee_Type_Code__c != : System.Label.Core_Employee_Type LIMIT 1];
    
            System.runAs(accessDeniedUser) {
                Core_OpportunitySearchController pageController1 = new Core_OpportunitySearchController();
    
                System.assertEquals(pageController1.bEmployeeAccessCode, false);
            }

        Test.stopTest();

    }
}