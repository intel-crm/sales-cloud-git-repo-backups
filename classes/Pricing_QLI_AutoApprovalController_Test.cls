/**
* @description       : Test Class for Auto Approval Controller
* @author            : Sandeep Chamate
* @group             : Accenture
* @last modified on  : 03-31-2026
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class Pricing_QLI_AutoApprovalController_Test {
    
    @testSetup
    public static void setUpData(){
        List<User> adminUserList = Pricing_Test_Utility.createAdminUser();
        System.runAs(adminUserList[0]){
            
            Test.startTest();
            Pricing_Test_Utility.createPriceBook();
            Account acc = Pricing_Test_Utility.createAccount();
            Contact con = Pricing_Test_Utility.createPrimaryContactWithParam(acc.Id,'QLI_Auto_Approval_Controller');
            List<User> accountExecutiveUserList = Pricing_Test_Utility.createAEUser();
            List<User> salesRepUserList = Pricing_Test_Utility.createSalesRepUser();
            Product2 prod = Pricing_Test_Utility.createWINProduct();
            AccountTeamMember accTeam = new AccountTeamMember(AccountId = acc.Id,
                                                              TeamMemberRole = 'Technical Sales',UserId = salesRepUserList[0].Id);
            insert accTeam;
            List<SBQQ__Quote__c> lstquote = Pricing_Test_Utility.createQuoteWithParam(acc.Id, con.Id, 2,salesRepUserList[0].Email,accountExecutiveUserList[0].Email);
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(lstquote[0].Id, 2);
            Pricing_Approval_Price_Rules__c rule = new Pricing_Approval_Price_Rules__c();
            rule.Pricing_Account__c = acc.id;
            rule.Pricing_Server_Deal_Type_Nm__c = lstquote[0].Pricing_Server_Deal_Type_Nm__c;
            rule.Pricing_End_Customer_Country__c = lstquote[0].Pricing_End_Customer_Country_Nm__c;
            rule.Pricing_Is_Enabled__c = true;
            rule.Pricing_Rule_Start_Date__c = system.today();
            rule.Pricing_Rule_End_Date__c = system.today() + 2;
            rule.Pricing_Quote_Type__c = 'Data Center';
            rule.Pricing_Rule_Name__c = 'test price rule';
            insert rule;
            Pricing_Product_Floor_Price__c prodFloorPrice = new Pricing_Product_Floor_Price__c();
            prodFloorPrice.Pricing_Product__c = lstquoteLines[0].SBQQ__Product__c;
            prodFloorPrice.Pricing_Approved_ECAP_Price__c = 100;
            prodFloorPrice.Pricing_Approval_Price_Rules__c = rule.Id;
            prodFloorPrice.Pricing_Active__c = true;
            insert prodFloorPrice;
            test.stopTest();
        }
    }
    
    static testMethod void testOverlap(){
        Account acc = [select id from Account];
        List<SBQQ__QuoteLine__c> qliList = [SELECT Id, SBQQ__Product__c,Pricing_Quote_Line_Number__c, Pricing_Sales_Rep__c, Pricing_Product_Nm__r.Id, Pricing_Product_Nm__r.Name, Pricing_Status_Nm__c,Pricing_Manager__c,Pricing_ECAP_Price_Amt__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_New_Change_Request_cb__c,
                                            Pricing_FSE_Recommended_Price_Nm__c, Pricing_pm_approval_comments_nm__c, Pricing_Rejection_Comments_nm__c, SBQQ__Quote__c,Pricing_Rejection_Reason__c,SBQQ__Quote__r.Id,SBQQ__Quote__r.SBQQ__PrimaryContact__r.Id,Pricing_Last_Submitted_By_Id__c,SBQQ__Quote__r.SBQQ__SalesRep__c,
                                            Pricing_Change_Request_cb__c,Pricing_Sales_Rep_Approver__c,Customer_Revision_Count_Cnt__c,Pricing_Other_Product_Nm__c, Pricing_New_Quantity_qty__c, Pricing_Request_Discount_Unit_Price_qty__c, Pricing_Req_Discounted_Unit_Price__c, Pricing_Unit_Qty__c,Pricing_Total_Volume_Qty__c,Pricing_Program_Type_Nm__c,Pricing_SDM_Fast_Track__c FROM SBQQ__QuoteLine__c 
                                            ORDER By Pricing_Quote_Line_Number__c LIMIT 2];
        Pricing_Approval_Price_Rules__c approvalRule = [SELECT Id, Name,Pricing_Quote_Type__c, Pricing_End_Date__c, Pricing_Region_Nm__c, Pricing_Form_Factor__c, Pricing_Server_Deal_Type_Nm__c, Pricing_End_Customer_Country__c, Pricing_Account__c, 
                                                                            Pricing_Maximum_Requested_Unit_Price__c, Pricing_Minimum_Requested_Unit_Price__c, Pricing_Intel_Sales_Rep_Email_Txt__c, Pricing_Intel_Account_Exec_Email_Txt__c, Pricing_Approval_Status__c, 
                                                                            Pricing_Minimum_Quantity__c, Pricing_Maximum_Quantity__c, Pricing_Approval_Rejection_Comments__c, Pricing_PriceRule_Id__c, Pricing_Rule_Name__c, Pricing_Is_Enabled__c, Pricing_Is_Active__c, 
                                                                            Pricing_Rule_Start_Date__c, Pricing_Rule_End_Date__c, Pricing_RPM_Email__c, Pricing_Market_Segment_values_Nm__c FROM Pricing_Approval_Price_Rules__c WHERE Pricing_Is_Active__c = true and Pricing_Rule_Name__c = 'test price rule'];
        approvalRule.Pricing_Approval_Status__c = 'Approved';
        update approvalRule;
        Test.startTest();
        Pricing_Approval_Price_Rules__c rule = new Pricing_Approval_Price_Rules__c();
            rule.Pricing_Account__c = acc.id;
            rule.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            rule.Pricing_End_Customer_Country__c = 'India';
            rule.Pricing_Is_Enabled__c = true;
            rule.Pricing_Rule_Start_Date__c = system.today();
            rule.Pricing_Rule_End_Date__c = system.today() + 2;
            rule.Pricing_Quote_Type__c = 'Data Center';
            rule.Pricing_Rule_Name__c = 'test price rule';
            insert rule;
            Pricing_Product_Floor_Price__c prodFloorPrice = new Pricing_Product_Floor_Price__c();
            prodFloorPrice.Pricing_Product__c = qliList[0].SBQQ__Product__c;
            prodFloorPrice.Pricing_Approved_ECAP_Price__c = 100;
            prodFloorPrice.Pricing_Approval_Price_Rules__c = rule.Id;
            prodFloorPrice.Pricing_Active__c = true;
            insert prodFloorPrice;
        Pricing_QuoteLine_AutoApprovalController.isOverlapApprovalPriceRule(rule.Id);
        System.assertEquals(approvalRule != null, true);
        test.stopTest();
    
            }
    
    static testMethod void testOverlapSuccess(){
        Account acc = [select id from Account];
        List<SBQQ__QuoteLine__c> qliList = [SELECT Id, SBQQ__Product__c,Pricing_Quote_Line_Number__c, Pricing_Sales_Rep__c, Pricing_Product_Nm__r.Id, Pricing_Product_Nm__r.Name, Pricing_Status_Nm__c,Pricing_Manager__c,Pricing_ECAP_Price_Amt__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_New_Change_Request_cb__c,
                                            Pricing_FSE_Recommended_Price_Nm__c, Pricing_pm_approval_comments_nm__c, Pricing_Rejection_Comments_nm__c, SBQQ__Quote__c,Pricing_Rejection_Reason__c,SBQQ__Quote__r.Id,SBQQ__Quote__r.SBQQ__PrimaryContact__r.Id,Pricing_Last_Submitted_By_Id__c,SBQQ__Quote__r.SBQQ__SalesRep__c,
                                            Pricing_Change_Request_cb__c,Pricing_Sales_Rep_Approver__c,Customer_Revision_Count_Cnt__c,Pricing_Other_Product_Nm__c, Pricing_New_Quantity_qty__c, Pricing_Request_Discount_Unit_Price_qty__c, Pricing_Req_Discounted_Unit_Price__c, Pricing_Unit_Qty__c,Pricing_Total_Volume_Qty__c,Pricing_Program_Type_Nm__c,Pricing_SDM_Fast_Track__c FROM SBQQ__QuoteLine__c 
                                            ORDER By Pricing_Quote_Line_Number__c LIMIT 2];
        Pricing_Approval_Price_Rules__c approvalRule = [SELECT Id, Name,Pricing_Quote_Type__c, Pricing_End_Date__c, Pricing_Region_Nm__c, Pricing_Form_Factor__c, Pricing_Server_Deal_Type_Nm__c, Pricing_End_Customer_Country__c, Pricing_Account__c, 
                                                                            Pricing_Maximum_Requested_Unit_Price__c, Pricing_Minimum_Requested_Unit_Price__c, Pricing_Intel_Sales_Rep_Email_Txt__c, Pricing_Intel_Account_Exec_Email_Txt__c, Pricing_Approval_Status__c, 
                                                                            Pricing_Minimum_Quantity__c, Pricing_Maximum_Quantity__c, Pricing_Approval_Rejection_Comments__c, Pricing_PriceRule_Id__c, Pricing_Rule_Name__c, Pricing_Is_Enabled__c, Pricing_Is_Active__c, 
                                                                            Pricing_Rule_Start_Date__c, Pricing_Rule_End_Date__c, Pricing_RPM_Email__c, Pricing_Market_Segment_values_Nm__c FROM Pricing_Approval_Price_Rules__c WHERE Pricing_Is_Active__c = true and Pricing_Rule_Name__c = 'test price rule'];
        approvalRule.Pricing_Approval_Status__c = 'Approved';
        update approvalRule;
        Test.startTest();
        Pricing_Approval_Price_Rules__c rule = new Pricing_Approval_Price_Rules__c();
            rule.Pricing_Account__c = acc.id;
            rule.Pricing_Server_Deal_Type_Nm__c = '';
            rule.Pricing_End_Customer_Country__c = 'Egypt';
            rule.Pricing_Is_Enabled__c = true;
            rule.Pricing_Rule_Start_Date__c = system.today();
            rule.Pricing_Rule_End_Date__c = system.today() + 2;
            rule.Pricing_Quote_Type__c = 'Data Center';
            rule.Pricing_Rule_Name__c = 'test price rule';
            insert rule;
            Pricing_Product_Floor_Price__c prodFloorPrice = new Pricing_Product_Floor_Price__c();
            prodFloorPrice.Pricing_Product__c = qliList[0].SBQQ__Product__c;
            prodFloorPrice.Pricing_Approved_ECAP_Price__c = 100;
            prodFloorPrice.Pricing_Approval_Price_Rules__c = rule.Id;
            prodFloorPrice.Pricing_Active__c = true;
            insert prodFloorPrice;
        Pricing_QuoteLine_AutoApprovalController.isOverlapApprovalPriceRule(rule.Id);
        System.assertEquals(approvalRule != null, true);
        test.stopTest();
    
            }
    static testMethod void testFSEAutoAction(){
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        List<SBQQ__QuoteLine__c> qliList = [SELECT Id, Pricing_Quote_Line_Number__c, Pricing_Sales_Rep__c, Pricing_Product_Nm__r.Id, Pricing_Product_Nm__r.Name, Pricing_Status_Nm__c,Pricing_New_Change_Request_cb__c,
                                            Pricing_FSE_Recommended_Price_Nm__c, Pricing_pm_approval_comments_nm__c, Pricing_Rejection_Comments_nm__c, SBQQ__Quote__c,Pricing_Rejection_Reason__c,SBQQ__Quote__r.Id,SBQQ__Quote__r.SBQQ__PrimaryContact__r.Id,Pricing_Last_Submitted_By_Id__c,SBQQ__Quote__r.SBQQ__SalesRep__c,
                                            Pricing_Change_Request_cb__c,Pricing_Sales_Rep_Approver__c,Customer_Revision_Count_Cnt__c,Pricing_Other_Product_Nm__c, Pricing_New_Quantity_qty__c, Pricing_Request_Discount_Unit_Price_qty__c, Pricing_Req_Discounted_Unit_Price__c, Pricing_Unit_Qty__c,Pricing_Total_Volume_Qty__c,Pricing_Program_Type_Nm__c,Pricing_SDM_Fast_Track__c FROM SBQQ__QuoteLine__c 
                                            ORDER By Pricing_Quote_Line_Number__c LIMIT 2];
        
        List<Pricing_QuoteLine_AutoApprovalController.FlowInputs> flowInputsList = new List<Pricing_QuoteLine_AutoApprovalController.FlowInputs>();
        
        Pricing_QuoteLine_AutoApprovalController.FlowInputs inp1 = new Pricing_QuoteLine_AutoApprovalController.FlowInputs();
        Pricing_QuoteLine_AutoApprovalController.FlowInputs inp2 = new Pricing_QuoteLine_AutoApprovalController.FlowInputs();
        inp1.action = 'FSE Approve';
        inp1.quoteLine = qliList[0];
        inp2.action = 'FSE Reject';
        inp2.quoteLine = qliList[1];
        flowInputsList.add(inp1);
        flowInputsList.add(inp2);
        Test.startTest();
        System.runAs(adminUser){
            Pricing_QuoteLine_AutoApprovalController.autoApprovePFIRQuoteLine(flowInputsList);
        }
        Test.stopTest();
        System.assertEquals(QuoteLineBusinessLogic.isAutoApproveReject, true);
    }
    
    static testMethod void testRPMAutoAction(){
        User adminUser = [Select id from User where Email='firstName@intel.com'];
        List<SBQQ__QuoteLine__c> qliList = [SELECT Id, Pricing_Quote_Line_Number__c, Pricing_Sales_Rep__c, Pricing_Product_Nm__r.Id, Pricing_Product_Nm__r.Name, Pricing_Status_Nm__c,Pricing_Manager__c,Pricing_ECAP_Price_Amt__c,Pricing_Meet_Comp_Price_Amt__c,Pricing_New_Change_Request_cb__c,
                                            Pricing_FSE_Recommended_Price_Nm__c, Pricing_pm_approval_comments_nm__c, Pricing_Rejection_Comments_nm__c, SBQQ__Quote__c,Pricing_Rejection_Reason__c,SBQQ__Quote__r.Id,SBQQ__Quote__r.SBQQ__PrimaryContact__r.Id,Pricing_Last_Submitted_By_Id__c,SBQQ__Quote__r.SBQQ__SalesRep__c,
                                            Pricing_Change_Request_cb__c,Pricing_Sales_Rep_Approver__c,Customer_Revision_Count_Cnt__c,Pricing_Other_Product_Nm__c, Pricing_New_Quantity_qty__c, Pricing_Request_Discount_Unit_Price_qty__c, Pricing_Req_Discounted_Unit_Price__c, Pricing_Unit_Qty__c,Pricing_Total_Volume_Qty__c,Pricing_Program_Type_Nm__c,Pricing_SDM_Fast_Track__c FROM SBQQ__QuoteLine__c 
                                            ORDER By Pricing_Quote_Line_Number__c LIMIT 2];
        List<Pricing_QuoteLine_AutoApprovalController.FlowInputs> flowInputsList = new List<Pricing_QuoteLine_AutoApprovalController.FlowInputs>();
        
        Pricing_QuoteLine_AutoApprovalController.FlowInputs inp1 = new Pricing_QuoteLine_AutoApprovalController.FlowInputs();
        Pricing_QuoteLine_AutoApprovalController.FlowInputs inp2 = new Pricing_QuoteLine_AutoApprovalController.FlowInputs();
        inp1.action = 'RPM Approve';
        inp1.quoteLine = qliList[0];
        inp2.action = 'RPM Reject';
        inp2.quoteLine = qliList[1];
        flowInputsList.add(inp1);
        flowInputsList.add(inp2);
        Test.startTest();
        System.runAs(adminUser){
            Pricing_QuoteLine_AutoApprovalController.autoApprovePFIRQuoteLine(flowInputsList);
        }
        Test.stopTest();
        System.assertEquals(QuoteLineBusinessLogic.isAutoApproveReject, true);
    }
    
    static testMethod void testRPMCreateDealAutoAction(){
        User adminUser = [Select id,Email from User where Email='firstName@intel.com'];
        List<User> rpmUsers = Pricing_Test_Utility.createPricingMangerUser();
        Pricing_Approval_Price_Rules__c rule = [SELECT Id,Pricing_RPM_Email__c,OwnerId FROM Pricing_Approval_Price_Rules__c LIMIT 1];
        List<SBQQ__QuoteLine__c> qliList = [SELECT Id, Pricing_Quote_Line_Number__c, SBQQ__Product__c, Pricing_Billing_Start_Date_Dt__c, Pricing_Billing_End_Date_Dt__c, Pricing_Revised_Pricing_Start_Date_dt__c,Pricing_New_Change_Request_cb__c,
                                            Pricing_Reference_Quote_Line_Nbr__c, Pricing_Reference_Quote_Line_Nbr__r.Pricing_Status_Nm__c, Pricing_Reference_Quote_Line_Nbr__r.Pricing_Revised_Pricing_Start_Date_dt__c, 
                                            Pricing_Reference_Quote_Line_Nbr__r.Pricing_Approved_Start_Date_Dt__c, Pricing_End_Customer_Country__c, Pricing_Additional_Comments_Txt__c, Pricing_End_Date_dt__c, Pricing_Sales_Rep__c, Pricing_Product_Nm__r.Id, Pricing_Product_Nm__r.Name, Pricing_Status_Nm__c,Pricing_Manager__c,Pricing_ECAP_Price_Amt__c,Pricing_Meet_Comp_Price_Amt__c,
                                            Pricing_FSE_Recommended_Price_Nm__c, Pricing_pm_approval_comments_nm__c, Pricing_Rejection_Comments_nm__c, SBQQ__Quote__c,Pricing_Rejection_Reason__c,SBQQ__Quote__r.Id,SBQQ__Quote__r.SBQQ__PrimaryContact__r.Id,Pricing_Last_Submitted_By_Id__c,SBQQ__Quote__r.SBQQ__SalesRep__c,
                                            Pricing_Change_Request_cb__c,Pricing_Sales_Rep_Approver__c,Customer_Revision_Count_Cnt__c,Pricing_Other_Product_Nm__c, Pricing_New_Quantity_qty__c, Pricing_Request_Discount_Unit_Price_qty__c, Pricing_Req_Discounted_Unit_Price__c, Pricing_Unit_Qty__c,Pricing_Total_Volume_Qty__c,Pricing_Program_Type_Nm__c,Pricing_SDM_Fast_Track__c FROM SBQQ__QuoteLine__c 
                                            ORDER By Pricing_Quote_Line_Number__c LIMIT 2];
        System.runAs(rpmUsers[0]){
            rule.OwnerId = rpmUsers[0].Id;
            update rule;
        }
        qliList[0].Pricing_Status_Nm__c = 'Pending Further Intel Review';      
        qliList[1].Pricing_Status_Nm__c = 'Pending Further Intel Review'; 
        qliList[0].Pricing_Approved_End_Date_Dt__c = system.today()+1; 
        qliList[0].Pricing_Additional_Comments_Txt__c = 'test';
        //qliList[0].Pricing_End_Date_dt__c = system.today()+1;
        //qliList[0].Pricing_End_Customer_Country__c = 'India';
        update qlilist;            
        
        List<Pricing_QuoteLine_AutoApprovalController.FlowInputs> flowInputsList = new List<Pricing_QuoteLine_AutoApprovalController.FlowInputs>();
        
        Pricing_QuoteLine_AutoApprovalController.FlowInputs inp1 = new Pricing_QuoteLine_AutoApprovalController.FlowInputs();
        Pricing_QuoteLine_AutoApprovalController.FlowInputs inp2 = new Pricing_QuoteLine_AutoApprovalController.FlowInputs();
        inp1.action = 'RPM Create Deal';
        inp1.quoteLine = qliList[0];
        inp1.rpmUserEmail = adminUser.Email;
        inp1.meetCompPrice = 1000;
        inp1.ecapPrice = 100;
        inp1.priceRuleId = rule.Id;
        inp2.action = 'RPM Create Deal';
        inp2.quoteLine = qliList[1];
        inp2.rpmUserEmail = adminUser.Email;
        inp2.meetCompPrice = 1000;
        inp2.ecapPrice = 100;
        inp2.priceRuleId = rule.Id;
        flowInputsList.add(inp1);
        flowInputsList.add(inp2);
        Test.startTest();
        System.runAs(adminUser){
            Pricing_QuoteLine_AutoApprovalController.autoApprovePFIRQuoteLine(flowInputsList);
        }
        Test.stopTest();
        System.assertEquals(QuoteLineBusinessLogic.isAutoApproveReject, true);
    }
    
}