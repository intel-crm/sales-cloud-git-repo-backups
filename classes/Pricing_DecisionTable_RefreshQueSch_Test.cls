@isTest
public class Pricing_DecisionTable_RefreshQueSch_Test {
    //Sample Mock
    public class DecisionTableSuccessCalloutMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "Success", "result": "Evaluated"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
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
            routeRule1.Pricing_Decision_Table_Name_Txt__c = 'Test Decision Table1';
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
            routeRule2.Pricing_Decision_Table_Name_Txt__c = 'Test Decision Table1';
            routeRuleList.add(routeRule2);
            
            insert routeRuleList;
            Test.stopTest(); 
        }
    }
    
    static testMethod void testScheduler() {
        User adminUser = [Select id,Email from User where Email='routeruleadmin@intel.com'];
        List<String> decisionTableNames = new List<String>();
        System.runAs(adminUser){
            List<Pricing_Routing_Rules__c> routeRuleList = [Select Id,Name, Pricing_Routing_RPM_Email__c, Pricing_RPM_Group_Name_Txt__c, Pricing_Routing_Output_Criteria_Nm__c, Pricing_End_Customer_Country_Nm__c, Pricing_Decision_Table_Name_Txt__c From Pricing_Routing_Rules__c];
            for(Pricing_Routing_Rules__c prr: routeRuleList) {
                decisionTableNames.add(prr.Pricing_Decision_Table_Name_Txt__c);
            }
            
            Test.startTest();
            Pricing_DecisionTable_RefreshQueue_Sch.scheduleRetry(decisionTableNames, 0);
            Test.stopTest();
        }
    }
    
     static testMethod void testRoutingRuleUpsert() {
        User adminUser = [Select id,Email from User where Email='routeruleadmin@intel.com'];
        System.runAs(adminUser){
            List<Pricing_Routing_Rules__c> routeRuleList = [Select Id,Name, Pricing_Routing_RPM_Email__c, Pricing_RPM_Group_Name_Txt__c, Pricing_Routing_Output_Criteria_Nm__c, Pricing_End_Customer_Country_Nm__c, Pricing_Decision_Table_Name_Txt__c From Pricing_Routing_Rules__c];
            routeRuleList[0].Pricing_End_Customer_Country_Nm__c = 'United States';
            //update routeRuleList[0];//update Routing Rule
            
            List<String> decisionTableNames = new List<String>();
            List<Pricing_Routing_Rules__c> routeRuleInsList = new List<Pricing_Routing_Rules__c>();
			for (Integer i = 0; i < 75; i++) {
                Pricing_Routing_Rules__c  routeRule = new Pricing_Routing_Rules__c();
                routeRule.Pricing_Region_Nm__c = 'ASMO';
                routeRule.Pricing_Program_Type_Nm__c = 'Client';
                routeRule.Pricing_Market_Segment_Nm__c = 'Consumer Retail Pull';
                routeRule.Pricing_Routing_RPM_Email__c = adminUser.Email;
                routeRule.Pricing_Routing_Rule_Start_Dt__c = System.today();
                routeRule.Pricing_Routing_Rule_End_Dt__c = System.today().addDays(2);
                routeRule.Pricing_Overall_Quote_Quantity_Nbr__c = 15000;
                routeRule.Pricing_Routing_Output_Criteria_Nm__c = 'Low Touch';
                routeRule.Pricing_End_Customer_Country_Nm__c = 'Canada';
                routeRule.Pricing_Decision_Table_Name_Txt__c = 'Test Decision Table1';
                routeRuleInsList.add(routeRule);
            }
           
           for(Pricing_Routing_Rules__c prr: routeRuleInsList) {
                decisionTableNames.add(prr.Pricing_Decision_Table_Name_Txt__c);
            }
            Test.setMock(HttpCalloutMock.class, new DecisionTableSuccessCalloutMock());
            Test.startTest();
            insert routeRuleInsList;//insert Route Rule Records
            Test.StopTest();
        }
       

    }
}