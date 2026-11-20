/****************************************************************************************************
Function    : Test class for testing the "Core_GlobalOpportunitySearch" Page
*****************************************************************************************************/
@isTest
private class Core_OpportunitySearchController_Test {
    
    Static Final Integer TEST_RECORD_SIZE   = 10;   // 1010
    Static Final String  INTEL_PLATFORM     = 'Agilex';
    Static Final String  SOL_FOCUS_SELECT_1 = 'Big Data/Analytics';
    Static Final String  SOL_FOCUS_SELECT_2 = 'Client: Sell Up/Refresh';
    
    // List to store Opportunity records
    Static List<Opportunity> lstOpportunityInsertion;
    
    // List to store Account records
    Static List<Account> lstAccountInsertion;
    
    /*
     * Method name  : setupTestData
     * Description  : Method to setup test data
     * Return Type  : None
     * Parameter    : None
     */
    static void setupTestData() {
    
        lstAccountInsertion = new List<Account>();
        lstAccountInsertion = Core_Test_Utility.createAccount(TEST_RECORD_SIZE);
        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert lstAccountInsertion;
        }

        // Create and insert a list of Opportunity records
        lstOpportunityInsertion = new List<Opportunity>();
        lstOpportunityInsertion = Core_Test_Utility.createOpportunity(TEST_RECORD_SIZE);

        Opportunity opp;

        // Updated the opportunity record to relate it to Account records
        for (Integer i = 0; i < TEST_RECORD_SIZE; i++) {
            opp = lstOpportunityInsertion.get(i);
            opp.AccountId                    = lstAccountInsertion.get(i).Id;
            opp.Core_Intel_Platform__c       = INTEL_PLATFORM;
            opp.Core_Opportunity_Geo_ASMO__c = true;
            opp.Core_Opportunity_Geo_EMEA__c = true;
            opp.Core_Opportunity_Geo_APJ__c  = true;
            opp.Core_Opportunity_Geo_PRC__c  = true;
            opp.Opportunity_Focus__c= 'Core';
            opp.Core_Opportunity_Type__c ='Design: Original';
        }

        System.runAs(Core_Test_Utility.systemAdminUser) {
            insert lstOpportunityInsertion;
        }    

        Core_Opportunity_Partner__c oppPartner = new Core_Opportunity_Partner__c(Core_Opportunity__c=lstOpportunityInsertion.get(0).Id, Core_Partner__c=lstAccountInsertion.get(0).Id, Core_Partner_Type__c='OEM');
        insert oppPartner;        
    }



    /*
     * Method name  : opportunitySearchControllerTest
     * Description  : Testmethod method for testing "Core_GlobalOpportunitySearch" Page and its controller
     * Return Type  : None
     * Parameter    : None
     */


    public static testMethod void opportunitySearchControllerTest() {

        // Setting up the enivronment for testing 
        setupTestData();   
        List<Core_FieldSetWrapper> ourlstOpportunityFieldSetWrapper = new List<Core_FieldSetWrapper>();
        List<Schema.FieldSetMember> lstOpportunityFieldSetMembers = SObjectType.Opportunity.FieldSets.Core_GlobalOpportunitySearch.getFields();     
        
        PageReference searchPage = Page.Core_OpportunitySearch;
        Test.setCurrentPage(searchPage);
        User accessDeniedUser = [SELECT Id, Name, Core_Employee_Type_Code__c From USER Where isActive = TRUE
            AND Core_Employee_Type_Code__c != : System.Label.Core_Employee_Type LIMIT 1];
        
        Test.startTest();

        System.runAs(Core_Test_Utility.systemAdminUser) {


            List<Opportunity> testOpps = [SELECT AccountId, Core_Intel_Platform__c, OwnerId, StageName, Core_Product_Segment__c, 
                                                 Core_Product_Application__c, Core_Consumption_Market__c, Core_Solution_Focus__c,
                                                 Owner.Name, Name, Account.Name 
                                          FROM OPPORTUNITY 
                                          WHERE  Core_Intel_Platform__c = 'Broadwell'];
          



            // Creating the instance of controller to be tested      
            Core_OpportunitySearchController pageController = new Core_OpportunitySearchController();
            pageController.populateFieldSet('Opportunity',lstOpportunityFieldSetMembers, ourlstOpportunityFieldSetWrapper);
            pageController.lstOpportunityFieldSetWrapper = ourlstOpportunityFieldSetWrapper;
            // Asserting that user has access to page
            System.assertEquals(pageController.bEmployeeAccessCode, true);

            pageController.search();

            // Asserting that user didn't enter any filter criteria before searching
            System.assertEquals(pageController.bErrorMessage, true);

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
                    try{
                        fieldSetInstance.add();
                    }catch(Exception e){
                         Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Error in test class ',Core_Details__c = e.getMessage(), Core_Origin__c='Core_OpportunitySearchController_test', Core_Severity__c='Info', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM');
            			 insert logEntry;

                    }

                    List<SelectOption> chosentoRemoveMultiselect = new List<SelectOption>();
                    chosentoRemoveMultiselect.add(new SelectOption(SOL_FOCUS_SELECT_2, SOL_FOCUS_SELECT_2));
                    fieldSetInstance.chosenItems = chosentoRemoveMultiselect;
                    fieldSetInstance.chosen = new List<String> {SOL_FOCUS_SELECT_2};
                    try{
                        fieldSetInstance.remove();
                    }catch(Exception e){
                         Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Error in test class ',Core_Details__c = e.getMessage(), Core_Origin__c='Core_OpportunitySearchController_Test', Core_Severity__c='Info', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM');
            			 insert logEntry;
                    }
                }

            }

            pageController.inputOpp.Core_Opportunity_Geo_APJ__c  = true;
            pageController.inputOpp.Core_Opportunity_Geo_ASMO__c = true;
            pageController.inputOpp.Core_Opportunity_Geo_EMEA__c = true;
            pageController.inputOpp.Core_Opportunity_Geo_PRC__c  = true;

            pageController.search();

            

            

            // Asserting that search retunred more than TEST_RECORD_SIZE records
            // System.assertEquals(pageController.bmoreRecords, true);

            // Asserting that the query returned 50 results on first page
//[BM] 8/7            System.assertEquals(pageController.lstSearchOpportunities.size(), 50);

            Opportunity selectedOpportunity = lstOpportunityInsertion.get(0);
            

            pageController.selectedOpportunityId = selectedOpportunity.id;
            try{
                pageController.sendEmail();
            }catch(Exception e){
                 Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Error in test class ',Core_Details__c = e.getMessage(), Core_Origin__c='Core_OpportunitySearchController_Test', Core_Severity__c='Info', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM');
            	 insert logEntry;
 
            }

            // Asserting whether email was sent
//[BM] 8/7            System.assertEquals(pageController.iEmailSentCount, 1);


            pageController.next();
            // Asserting that the query returned 50 results
//[BM] 8/7            System.assertEquals(pageController.lstSearchOpportunities.size(), 10);

            pageController.first();
            // Asserting that the query returned 50 results
//[BM] 8/7            System.assertEquals(pageController.lstSearchOpportunities.size(), 50);

            pageController.last();
            // Asserting that the query returned 10 results
//[BM] 8/7            System.assertEquals(pageController.lstSearchOpportunities.size(), 10);

            pageController.previous();
            // Asserting that the query returned 50 results
//[BM] 8/7            System.assertEquals(pageController.lstSearchOpportunities.size(), 50);

            pageController.search();

            // Clearing all the filters entered by the user
            pageController.clearFilters();

            // Iterating on the feild set fields and populating value for testing
            for (Core_fieldSetWrapper fieldSetInstance: pageController.lstOpportunityFieldSetWrapper) {
                if (fieldSetInstance.dataType == 'PICKLIST' && fieldSetInstance.fieldName.equalsIgnoreCase('Core_Intel_Platform__c'))
                    fieldSetInstance.selectedPicklistValue = 'test value';
            }

            pageController.search();

            // Asserting if user entered search text doesn't fetch any opportunities            
//[BM] 8/7            System.assertEquals(pageController.bOpportunitiesPresent, false);
        }

        // Testing page for user who doesn't have access to page
        System.runAs(accessDeniedUser) {
            Core_OpportunitySearchController pageController1 = new Core_OpportunitySearchController();

            // Asserting that user doesn't have access to page
//[BM] 8/7            System.assertEquals(pageController1.bEmployeeAccessCode, false);
        }

        Test.stopTest();

    }
    
    
    public static testMethod void opportunitySearchControllerPartnerTest() {

        // Setting up the enivronment for testing 
        setupTestData();            
        
        PageReference searchPage = Page.Core_OpportunitySearch;

        Test.startTest();

        System.runAs(Core_Test_Utility.systemAdminUser) {


            List<Opportunity> testOpps = [SELECT AccountId, Core_Intel_Platform__c, OwnerId, StageName, Core_Product_Segment__c, 
                                                 Core_Product_Application__c, Core_Consumption_Market__c, Core_Solution_Focus__c,
                                                 Owner.Name, Name, Account.Name 
                                          FROM OPPORTUNITY 
                                          WHERE  Core_Intel_Platform__c = :INTEL_PLATFORM];

            


            // Creating the instance of controller to be tested      
            Core_OpportunitySearchController pageController = new Core_OpportunitySearchController();

            // Asserting that user has access to page
            System.assertEquals(pageController.bEmployeeAccessCode, true);

            pageController.autoPartnerSearch();

            // Asserting that Partner Search works even without any search criteria
            System.assertEquals(pageController.bErrorMessage, false);


            List<Core_FieldSetWrapper> combinedFields = new List<Core_FieldSetWrapper>();

            combinedFields.addAll(pageController.lstOpportunityFieldSetWrapper);
            combinedFields.addAll(pageController.lstPartnerFieldSetWrapper);
            

            // Iterating on the feild set fields and populating value for testing
            for (Core_fieldSetWrapper fieldSetInstance: combinedFields) {
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
                    try{
                        fieldSetInstance.add();
                    }catch(Exception e){
                         Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Error in test class ',Core_Details__c = e.getMessage(), Core_Origin__c='Core_OpportunitySearchController_Test', Core_Severity__c='Info', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM');
            			 insert logEntry;
 
                    }

                    List<SelectOption> chosentoRemoveMultiselect = new List<SelectOption>();
                    chosentoRemoveMultiselect.add(new SelectOption(SOL_FOCUS_SELECT_2, SOL_FOCUS_SELECT_2));
                    fieldSetInstance.chosenItems = chosentoRemoveMultiselect;
                    fieldSetInstance.chosen = new List<String> {SOL_FOCUS_SELECT_2};
                    try{
                        fieldSetInstance.remove();
                    }catch(Exception e){
                        Core_Log_Entry__c logEntry =new Core_Log_Entry__c(Core_Message__c = 'Error in test class ',Core_Details__c = e.getMessage(), Core_Origin__c='Core_OpportunitySearchController_Test', Core_Severity__c='Info', Core_When__c=System.Now(), Core_Project__c = 'Sales CRM');
            			insert logEntry;
 
                    }
                }

            }

            pageController.autoPartnerSearch();

            

            pageController.next();
            pageController.first();
            pageController.last();
            pageController.previous();

        }

        Test.stopTest();

    }
    
    
    public static testMethod void opportunitySearchControllerPropertiesTest() {

        // Setting up the enivronment for testing 
        setupTestData();            
        
        PageReference searchPage = Page.Core_OpportunitySearch;

        Test.startTest();

        System.runAs(Core_Test_Utility.systemAdminUser) {


            // Creating the instance of controller to be tested      
            Core_OpportunitySearchController pageController = new Core_OpportunitySearchController();

            // Asserting that user has access to page
            String partnerFields = pageController.partnerFields;
            
            // Sets partnerSearchOverride => True
            pageController.autoPartnerSearch();
            System.assertEquals(pageController.isPartnerSearch, true);
            
            pageController.sortHeader = new Core_SortedGrid_ColumnHeader('Core_Intel_Platform__c');            
            pageController.inputOpp   = new Opportunity(CloseDate=NULL); 
                                    
        }
    }    
    
}