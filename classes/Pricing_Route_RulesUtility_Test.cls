@isTest(SeeAllData=false)
public class Pricing_Route_RulesUtility_Test {
	@TestSetup
    public static void setUpData(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUserWithParam('routeruleadmin');
        Pricing_Test_Utility.createPriceBook();

        System.runAs(adminUserList[0]){
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'RouteRuler');
            
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            User partnerUserList = Pricing_Test_Utility.createPartnerUser(acc.Id);
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = adminUserList[0].Id);
            insert accTeam;
            AccountTeamMember accTeam2 = new AccountTeamMember(AccountId = acc.Id,TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam2;
            Test.startTest();
            List<SBQQ__Quote__c> quoteList = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 1,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 1);
            
            //Insert Price Route Rules Utility Records
            List<Pricing_Route_Rules_Utility__c> utilityRecList = new List<Pricing_Route_Rules_Utility__c>();
            Pricing_Route_Rules_Utility__c  utilityRec1 = new Pricing_Route_Rules_Utility__c();
            utilityRec1.Pricing_Region_Nm__c = 'ASMO';
            utilityRec1.Pricing_Category_Nm__c = 'CSP';
            utilityRec1.Pricing_End_Customer_Name_Txt__c = 'Dell';
            utilityRec1.Pricing_Pricing_Manager_Email_Txt__c = adminUserList[0].Email;
            utilityRecList.add(utilityRec1);
            insert utilityRecList;
            
            //Insert Group and Group Member
            Group pricingManagerGrp = new Group(Name = 'ASMO DCG HPC Pricing Manager Group', DeveloperName = 'Pricing_ASMO_DCG_HPC_Pricing_Manager_group');
            insert pricingManagerGrp;
            GroupMember grpMember = new groupMember(GroupId = pricingManagerGrp.Id, UserOrGroupId = adminUserList[0].id);
            insert grpMember;
            
           	//Insert Pricing Route Rules
            List<Pricing_Routing_Rules__c> routeRuleList = new List<Pricing_Routing_Rules__c>();
            Pricing_Routing_Rules__c  routeRule1 = new Pricing_Routing_Rules__c();
            routeRule1.Pricing_Region_Nm__c = 'ASMO';
            routeRule1.Pricing_Program_Type_Nm__c = 'Client';
            routeRule1.Pricing_Market_Segment_Nm__c = 'Consumer Retail Pull';
            routeRule1.Pricing_Routing_RPM_Email__c = adminUserList[0].Email;
           	routeRule1.Pricing_Routing_Rule_Start_Dt__c = System.today();
            routeRule1.Pricing_Routing_Rule_End_Dt__c = System.today().addDays(2);
            routeRule1.Pricing_Overall_Quote_Quantity_Nbr__c = 30000;
            routeRule1.Pricing_Routing_Output_Criteria_Nm__c = 'Low Touch';
            routeRule1.Pricing_End_Customer_Country_Nm__c = 'Canada';
            routeRuleList.add(routeRule1);
            
            Pricing_Routing_Rules__c  routeRule2 = new Pricing_Routing_Rules__c();
            routeRule2.Pricing_Region_Nm__c = 'ASMO';
            routeRule2.Pricing_Program_Type_Nm__c = 'Client';
            routeRule2.Pricing_Market_Segment_Nm__c = 'Consumer Retail Pull';
            routeRule2.Pricing_RPM_Group_Name_Txt__c = 'Pricing_ASMO_DCG_HPC_Pricing_Manager_group';
           	routeRule2.Pricing_Routing_Rule_Start_Dt__c = System.today();
            routeRule2.Pricing_Routing_Rule_End_Dt__c = System.today().addDays(2);
            routeRule2.Pricing_Overall_Quote_Quantity_Nbr__c = 30000;
            routeRule2.Pricing_Routing_Output_Criteria_Nm__c = 'Low Touch';
            routeRule2.Pricing_End_Customer_Country_Nm__c = 'Canada';
            routeRuleList.add(routeRule2);
            
            insert routeRuleList;
            Test.stopTest(); 
        }
    }
    
    static testMethod void testEndCustomerInHighOrCSPOrExclusionList(){
        SBQQ__Quote__c quote = [SELECT Id,Pricing_Intel_Sales_Rep_Email_Txt__c,Pricing_Intel_Account_Exec_Email_Txt__c from SBQQ__Quote__c];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Pricing_Quote_Line_Number__c,SBQQ__Quote__c,Pricing_Req_Discounted_Unit_Price__c,SBQQ__Quote__r.OwnerId,RecordType.Name,Pricing_Sales_Rep__c, Pricing_Status_Nm__c from SBQQ__QuoteLine__c LIMIT 1];
        User adminUser = [Select id from User where Email='routeruleadmin@intel.com'];
        Test.startTest();
        System.runAs(adminUser){
            List<Pricing_Route_RulesUtility.FlowInputs> flowInpList1 = new List<Pricing_Route_RulesUtility.FlowInputs>();
            //getEndCustomerName - Unified End Customer Name
            Pricing_Route_Rules_Utility__c routeRulesUtilityRec = [Select Id,Pricing_Region_Nm__c,Pricing_Category_Nm__c,Pricing_End_Customer_Name_Txt__c  from Pricing_Route_Rules_Utility__c];
            Id[] fixedSearchResults = new Id[]{ routeRulesUtilityRec.Id };
            Test.setFixedSearchResults(fixedSearchResults);//Needed for SOSL in Test Class as Text Search Indexing won't be available
            Pricing_Route_RulesUtility.FlowInputs flowInp1 = new Pricing_Route_RulesUtility.FlowInputs();
            flowInp1.quoteId = quote.Id;
            flowInp1.quoteLineId = quoteLineList[0].Id;
            flowInp1.endCustomerCountry = 'India';
            flowInp1.endCustomerName = 'Dell';
            flowInp1.writeInEndCustomerName = 'Dell';
            flowInp1.endCustomerUnifiedName = 'Dell';
            flowInp1.context = 'CSP';
            flowInp1.endCustomerRegion = 'ASMO';
            flowInpList1.add(flowInp1);
            
            //getEndCustomerName - Write In end Customer Name
            Pricing_Route_RulesUtility.FlowInputs flowInp2 = new Pricing_Route_RulesUtility.FlowInputs();
            flowInp2.quoteId = quote.Id;
            flowInp2.quoteLineId = quoteLineList[0].Id;
            flowInp2.endCustomerCountry = '';
            flowInp2.endCustomerName = 'Dell';
            flowInp2.writeInEndCustomerName = 'Dell';
            flowInp2.endCustomerUnifiedName = '';
            flowInp2.context = 'CSP';
            flowInp2.endCustomerRegion = 'ASMO';
            flowInpList1.add(flowInp2);
            Pricing_Route_RulesUtility.isEndCustomerOnAnyList(flowInpList1);
            
            List<Pricing_Route_RulesUtility.FlowInputs> flowInpList2 = new List<Pricing_Route_RulesUtility.FlowInputs>();
            //getEndCustomerName - Write In End Customer Name
            Pricing_Route_RulesUtility.FlowInputs flowInp3 = new Pricing_Route_RulesUtility.FlowInputs();
            flowInp3.quoteId = quote.Id;
            flowInp3.quoteLineId = quoteLineList[0].Id;
            flowInp3.endCustomerCountry = 'India';
            flowInp3.endCustomerName = 'Dell';
            flowInp3.writeInEndCustomerName = 'Dell';
            flowInp3.endCustomerUnifiedName = '';
            flowInp3.context = 'CSP';
            flowInp3.endCustomerRegion = 'ASMO';
            flowInpList2.add(flowInp3);
            
            Pricing_Route_RulesUtility.isEndCustomerOnAnyList(flowInpList2);
            
            List<Pricing_Route_RulesUtility.FlowInputs> flowInpList3 = new List<Pricing_Route_RulesUtility.FlowInputs>();
            //getEndCustomerName - End Customer Name
            Pricing_Route_RulesUtility.FlowInputs flowInp4 = new Pricing_Route_RulesUtility.FlowInputs();
            flowInp4.quoteId = quote.Id;
            flowInp4.quoteLineId = quoteLineList[0].Id;
            flowInp4.endCustomerCountry = 'India';
            flowInp4.endCustomerName = 'Dell';
            flowInp4.writeInEndCustomerName = '';
            flowInp4.endCustomerUnifiedName = '';
            flowInp4.context = 'CSP';
            flowInp4.endCustomerRegion = 'ASMO';
            flowInpList3.add(flowInp4);
            
            Pricing_Route_RulesUtility.isEndCustomerOnAnyList(flowInpList3);
            //When record is not available
            List<Pricing_Route_RulesUtility.FlowInputs> flowInpList4 = new List<Pricing_Route_RulesUtility.FlowInputs>();
            Pricing_Route_RulesUtility.FlowInputs flowInp5 = new Pricing_Route_RulesUtility.FlowInputs();
            flowInp5.quoteId = quote.Id;
            flowInp5.quoteLineId = quoteLineList[0].Id;
            flowInp5.endCustomerCountry = 'India';
            flowInp5.endCustomerName = '';
            flowInp5.writeInEndCustomerName = 'Dell';
            flowInp5.endCustomerUnifiedName = '';
            flowInp5.context = 'CSP';
            flowInp5.endCustomerRegion = 'EMEA';
            flowInpList4.add(flowInp5);
            
            Pricing_Route_RulesUtility.isEndCustomerOnAnyList(flowInpList4);
        }
        Test.stopTest();
    }
    
    static testMethod void testPopulatePricingManagerOnQuote(){
        SBQQ__Quote__c quote = [SELECT Id,Pricing_Intel_Sales_Rep_Email_Txt__c,Pricing_Intel_Account_Exec_Email_Txt__c from SBQQ__Quote__c];
        List<SBQQ__QuoteLine__c> quoteLineList =  [SELECT Id,Pricing_Quote_Line_Number__c,SBQQ__Quote__c,Pricing_Req_Discounted_Unit_Price__c,SBQQ__Quote__r.OwnerId,RecordType.Name,Pricing_Sales_Rep__c, Pricing_Status_Nm__c from SBQQ__QuoteLine__c LIMIT 1];
        User adminUser = [Select id from User where Email='routeruleadmin@intel.com'];
        Test.startTest();
        System.runAs(adminUser){
            List<Pricing_Routing_Rules__c> routeRuleList = [Select Id,Name, Pricing_Routing_RPM_Email__c, Pricing_RPM_Group_Name_Txt__c, Pricing_Routing_Output_Criteria_Nm__c, Pricing_End_Customer_Country_Nm__c From Pricing_Routing_Rules__c];
            List<Pricing_Route_RulesController.FlowInputs> flowInpList1 = new List<Pricing_Route_RulesController.FlowInputs>();
            Pricing_Route_RulesController.FlowInputs flowInp1 = new Pricing_Route_RulesController.FlowInputs();
            flowInp1.quoteId = quote.Id;
            flowInp1.routeRuleId = routeRuleList[0].Id;
            flowInp1.routeRuleName = routeRuleList[0].Name;
            flowInp1.pricingManagerEmail = routeRuleList[0].Pricing_Routing_RPM_Email__c;
            flowInp1.pricingManagerGroupName = routeRuleList[0].Pricing_RPM_Group_Name_Txt__c;
            flowInp1.pricingManagerRouteCategory = routeRuleList[0].Pricing_Routing_Output_Criteria_Nm__c;

            Pricing_Route_RulesController.updatePricingManagerDetails(flowInpList1);
            
            List<Pricing_Route_RulesController.FlowInputs> flowInpList2 = new List<Pricing_Route_RulesController.FlowInputs>();
            Pricing_Route_RulesController.FlowInputs flowInp2 = new Pricing_Route_RulesController.FlowInputs();
            flowInp2.quoteId = quote.Id;
            flowInp2.routeRuleId = routeRuleList[1].Id;
            flowInp2.routeRuleName = routeRuleList[1].Name;
            flowInp2.pricingManagerEmail = routeRuleList[1].Pricing_Routing_RPM_Email__c;
            flowInp2.pricingManagerGroupName = routeRuleList[1].Pricing_RPM_Group_Name_Txt__c;
            flowInp2.pricingManagerRouteCategory = routeRuleList[1].Pricing_Routing_Output_Criteria_Nm__c;
            flowInpList2.add(flowInp2);
            Pricing_Route_RulesController.updatePricingManagerDetails(flowInpList2);
        }
         Test.stopTest();
    }
}