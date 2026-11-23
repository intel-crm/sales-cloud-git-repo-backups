@isTest
public class PCC_RebateClaimHandler_2_Test {
    @testSetup
    static void createTriggerExecutions() {        
        List<Core_Trigger_Executions__c> triggerExecList = new List<Core_Trigger_Executions__c>();
        Core_Trigger_Executions__c triggerExec = new Core_Trigger_Executions__c();
        triggerExec.Name = 'PCC_RebateClaimAddToQueue';
        triggerExec.Core_Active__c = true;
        triggerExec.Core_Class_Name__c = 'PCC_RebateClaimHandler_2';
        triggerExec.Core_Description__c = 'Test';
        triggerExec.Core_Object__c = 'PCC_Rebate_Claim__c';
        triggerExec.Core_Trigger_Events__c = 'After Update After Insert';
        triggerExecList.add(triggerExec);
        
        Core_Trigger_Executions__c triggerExec1 = new Core_Trigger_Executions__c();
        triggerExec1.Name = 'PCC_RebateClaimPaymentProcessed';
        triggerExec1.Core_Active__c = true;
        triggerExec1.Core_Class_Name__c = 'PCC_RebateClaimHandler_2';
        triggerExec1.Core_Description__c = 'Test';
        triggerExec1.Core_Object__c = 'PCC_Rebate_Claim__c';
        triggerExec1.Core_Trigger_Events__c = 'After Update';
        triggerExecList.add(triggerExec1);  
        
        Core_Trigger_Executions__c triggerExec2 = new Core_Trigger_Executions__c();
        triggerExec2.Name = 'PCC_RebateClaimupdatePaymentstatus';
        triggerExec2.Core_Active__c = true;
        triggerExec2.Core_Class_Name__c = 'PCC_RebateClaimHandler_2';
        triggerExec2.Core_Description__c = 'Test';
        triggerExec2.Core_Object__c = 'PCC_Rebate_Claim__c';
        triggerExec2.Core_Trigger_Events__c = 'before Update';
        triggerExecList.add(triggerExec2);   
        
        insert triggerExecList;
    }
    
    @isTest
    static void testUpdatePaymentProcessedStatus() {
        // Create a list of test PCC_Rebate_Claim__c records
        List<PCC_Rebate_Claim__c> claimsToInsert = new List<PCC_Rebate_Claim__c>();
        
        // Test Case 1: Record that meets the criteria for update
        PCC_Rebate_Claim__c claim1 = new PCC_Rebate_Claim__c(
            PCC_CSAR_ID__c = 'CSAR12345',
            PCC_Payment_Ref_Id__c = 'REF12345',
            PCC_Claim_Status__c = 'Claim Approved - Payment Pending'
        );
        claimsToInsert.add(claim1);
        
        // Insert the test records
        insert claimsToInsert;
        
        // Call the method with the inserted records
        Test.startTest();
        PCC_RebateClaimHandler_2.UpdatePaymentProcessedStatus(claimsToInsert);
        
        Test.stopTest();
        
        // Retrieve the updated records in a new context
        List<PCC_Rebate_Claim__c> updatedClaims = [SELECT PCC_CSAR_ID__c, PCC_Payment_Ref_Id__c, 
                                                   PCC_Claim_Status__c, PCC_Payment_Date__c FROM PCC_Rebate_Claim__c 
                                                   WHERE Id IN :claimsToInsert];
        
        // Verify that the record has been updated
        PCC_Rebate_Claim__c updatedClaim1 = updatedClaims[0];
        System.assertEquals('Claim Approved - Payment Pending', updatedClaim1.PCC_Claim_Status__c, 'Claim 1 status should be updated to Payment Processed');
    }     
    
    @isTest
    static void testSendPaymentProcessedEmailNoty() {
        try{       
            List<PCC_Rebate_Claim__c> claimsToInsert = new List<PCC_Rebate_Claim__c>();        
            PCC_Rebate_Claim__c claim1 = new PCC_Rebate_Claim__c(
                PCC_CSAR_ID__c = 'CSAR12345',
                PCC_Payment_Ref_Id__c = 'REF12345',
                PCC_Claim_Status__c = 'Claim Approved - Payment Pending'
            );
            claimsToInsert.add(claim1);
            insert claimsToInsert;
            List<PCC_Rebate_Claim__c> updatedClaims = [SELECT Id, PCC_Claim_Status__c, PCC_Submitted_By__r.Email,PCC_Submitted_By__r.Name FROM PCC_Rebate_Claim__c WHERE Id IN :claimsToInsert LIMIT 1];
            
            Map<Id, PCC_Rebate_Claim__c> oldMap = new Map<Id, PCC_Rebate_Claim__c>();
            for (PCC_Rebate_Claim__c claim : updatedClaims) {            
                PCC_Rebate_Claim__c oldClaim = claim.clone();
                oldClaim.PCC_Claim_Status__c = 'Claim Approved - Payment Pending';
                oldMap.put(claim.Id, oldClaim);
                claim.PCC_Claim_Status__c = 'Payment Processed';            
            }  
            update updatedClaims;
            PCC_RebateClaimHandler_2.SendPaymentProcessedEmailNoty(updatedClaims, oldMap);   
            // Retrieve the updated records in a new context
            List<PCC_Rebate_Claim__c> updatedClaims11 = [SELECT PCC_CSAR_ID__c, PCC_Payment_Ref_Id__c, 
                                                         PCC_Claim_Status__c, PCC_Payment_Date__c FROM PCC_Rebate_Claim__c 
                                                         WHERE Id IN :updatedClaims];
            
            // Verify that the record has been updated
            PCC_Rebate_Claim__c updatedClaim1 = updatedClaims11[0];
            System.assertEquals('Payment Processed', updatedClaim1.PCC_Claim_Status__c, 'Claim 1 status should be updated to Payment Processed');           
            
        }catch(Exception ex){
            System.debug('Exception in test::'+ex);
        }
    }
    
    @isTest
    public static void testValidateLines(){       
        System.runAs(Core_Test_Utility.systemAdminUser) {         
           
            Id accountRecordTypeIntel = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Intel Account').getRecordTypeId();
            
            List<account>  acc = Core_Test_Utility.createAccount(1);
            acc[0].Name='Test Test';
            acc[0].recordTypeId = accountRecordTypeIntel;
            insert acc;
            
            Id contactRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Intel Contact').getRecordTypeId(); 
            Contact con = PRM_TestUtility.getContact();
            con.AccountId = acc[0].Id;
            con.Email='test.user@intel.com';
            con.Core_Preferred_Language__c = 'ENG';
            con.Core_eRPM_Language_Code__c = 'ENG';
            con.RecordTypeId = contactRecordType;
            con.Core_IPA_Partner_Role__c = 'Service Provider';
            con.Email = 'test.test@test.com';
            con.Core_Central_Block__c=false;
            con.MailingCountry = 'India';
            insert con;
            
            Pricing_UnifiedEndCustomerAccountMapping__c unifiedEndCustomer = new Pricing_UnifiedEndCustomerAccountMapping__c();
            unifiedEndCustomer.name='Write In End Customer';
            insert unifiedEndCustomer;
            
            Id recTypeParentId = Schema.SObjectType.PCC_Rebate_Claim_Stage__c.getRecordTypeInfosByDeveloperName().get('Header').getRecordTypeId();
            Id recTypeChildId = Schema.SObjectType.PCC_Rebate_Claim_Stage__c.getRecordTypeInfosByDeveloperName().get('Line_Items').getRecordTypeId();
            
            PCC_Rebate_Claim_Stage__c headerRecord = new PCC_Rebate_Claim_Stage__c();
            headerRecord.PCC_Partner__c = acc[0].Id;
            headerRecord.recordTypeId = recTypeParentId;
            insert headerRecord;
            List<PCC_Rebate_Claim_Stage__c> stgLst = new List<PCC_Rebate_Claim_Stage__c>();
            PCC_Rebate_Claim_Stage__c stageRec = new PCC_Rebate_Claim_Stage__c(
                PCC_Parent_Record__c = headerRecord.Id,
                PCC_Quote_Line_Number__c='Q-100-11-1234',
                PCC_Country__c='USA',
                PCC_Invoice_Date__c=String.valueof(Date.today()),
                PCC_Status__c='Pending',
                PCC_OEM__c = 'Asus',
                PCC_Product__c = 'TestProduct1',
                PCC_Quantity__c = String.valueof(10),
                recordTypeId = recTypeChildId,
                PCC_Partner__c = acc[0].Id
            );
            stgLst.add(stageRec);
            PCC_Rebate_Claim_Stage__c stageRec1 = new PCC_Rebate_Claim_Stage__c(
                PCC_Parent_Record__c = headerRecord.Id,
                PCC_Quote_Line_Number__c='Q-100-11-1234',
                PCC_Country__c='USA',
                PCC_Error_Messages__c = 'Blank OEM Name ',
                PCC_Invoice_Date__c=String.valueof(Date.today()),
                PCC_Status__c='Pending',
                PCC_OEM__c = '',
                PCC_Product__c = 'TestProduct2',
                PCC_Quantity__c = String.valueof(10),
                recordTypeId = recTypeChildId,
                PCC_Partner__c = acc[0].Id
            );
             stgLst.add(stageRec1);
            
            PCC_Rebate_Claim_Stage__c stageRec2 = new PCC_Rebate_Claim_Stage__c(
                PCC_Parent_Record__c = headerRecord.Id,
                PCC_Quote_Line_Number__c='Q-12345-123',
                PCC_Country__c='USA',
                PCC_Error_Messages__c = 'Blank Claim Quantity',
                PCC_Invoice_Date__c=String.valueof(Date.today()),
                PCC_Status__c='Pending',
                PCC_OEM__c = 'Asus',
                PCC_Product__c = 'TestProduct2',
                PCC_Quantity__c = '',
                recordTypeId = recTypeChildId,
                PCC_Partner__c = acc[0].Id
            );
             stgLst.add(stageRec2);
            
            PCC_Rebate_Claim_Stage__c stageRec3 = new PCC_Rebate_Claim_Stage__c(
                PCC_Parent_Record__c = headerRecord.Id,
                PCC_Quote_Line_Number__c='Q-100-11-1234',
                PCC_Country__c='USA',
                PCC_Error_Messages__c = 'Error 1: Invalid OEM Name ',
                PCC_Invoice_Date__c=String.valueof(System.today().addDays(-10)),
                PCC_Status__c='Pending',
                PCC_OEM__c = 'Samsung',
                PCC_Product__c = 'TestProduct2',
                PCC_Quantity__c = String.valueof(100),
                recordTypeId = recTypeChildId,
                PCC_Partner__c = acc[0].Id
            );
             stgLst.add(stageRec3);
            
            PCC_Rebate_Claim_Stage__c stageRec4 = new PCC_Rebate_Claim_Stage__c(
                PCC_Parent_Record__c = headerRecord.Id,
                PCC_Quote_Line_Number__c='Q-111-11-1234',
                PCC_Country__c='USA',
                PCC_Error_Messages__c = 'Blank Claim Quantity',
                PCC_Invoice_Date__c=String.valueof(Date.today()),
                PCC_Status__c='Pending',
                PCC_OEM__c = 'Dell',
                PCC_Product__c = 'TestProduct2',
                PCC_Quantity__c = String.valueof(1),
                recordTypeId = recTypeChildId,
                PCC_Partner__c = acc[0].Id
            );
             stgLst.add(stageRec4);
            
            insert stgLst;
            
            Product2 prod = new Product2(Name='TestProduct',
                                         Core_Product_Org__c = 'Sales',
                                         Core_Product_Type__c = 'Processors',
                                         Core_Sales_Visible_Flag__c = true,
                                         Core_Hierarchy_ID__c = '43',
                                         Core_Group_Code_Short_Name__c = 'DCG~DCAI',
                                         Core_Processor_Number_Nm__c = 'P6500',
                                         IsActive = true);
            insert prod;
            
            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c quote = new SBQQ__Quote__c();
            quote.SBQQ__Account__c = acc[0].Id;
            quote.SBQQ__PrimaryContact__c = con.Id;
            quote.Pricing_Server_Deal_Type_Nm__c = 'Enterprise';
            quote.Pricing_Project_Name_Nm__c = 'Test Project';
            quote.RecordTypeId=Pricing_Tender_Utility.getRecordTypeId('SBQQ__Quote__c',Label.Pricing_Tender_Quote_RecordType_Create);
            quote.Pricing_Intel_Sales_Rep_Email_Txt__c = 'firstNameSalesRep@intel.com';
            quote.Pricing_End_Customer__c=unifiedEndCustomer.id;
            quote.Pricing_Customer_Nm__c = 'FMH';
            quote.Pricing_ShipmentStDate_Dt__c = system.today()+1;
            quote.Pricing_Intel_Account_Exec_Email_Txt__c = 'firstNameAE@intel.com';
            quote.Pricing_Bid_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(7);
            quote.Pricing_ShipmentEndDate_Dt__c = quote.Pricing_ShipmentStDate_Dt__c.addDays(30);
            quote.Pricing_End_Customer_Country_Nm__c = 'Afghanistan';
            quote.Pricing_Region_Nm__c = 'APJ';
            quote.SBQQ__Status__c = 'Submitted';
            quoteList.add(quote);
            insert quoteList;  
            
            List<SBQQ__QuoteLine__c> lstquoteLines = Pricing_Test_Utility.createQuoteLines(quoteList[0].Id, 2);
            lstquoteLines[0].Pricing_Quote_Line_Number__c='Q-100-11-1234';
            lstquoteLines[0].Pricing_Approved_Unit_Qty__c=20;
            lstquoteLines[0].Pricing_OEM_Name_FI_Nm__c = 'Asus';
            lstquoteLines[0].Pricing_FI_Net_RPU_Amt__c = 10;
            lstquoteLines[0].Pricing_Status_Nm__c = 'Approved';
            
            lstquoteLines[1].Pricing_Quote_Line_Number__c='Q-111-11-1234';
            lstquoteLines[1].Pricing_Approved_Unit_Qty__c=20;
            lstquoteLines[1].Pricing_OEM_Name_FI_Nm__c = 'Dell';
            lstquoteLines[1].Pricing_FI_Net_RPU_Amt__c = 10;
            lstquoteLines[1].Pricing_Status_Nm__c = 'Approved';
            update lstquoteLines;
            
            PCC_Rebate_Claim__c rcInstance = new PCC_Rebate_Claim__c();
            rcInstance.PCC_Claim_Status__c = 'Draft';      
            insert rcInstance; 
            
            PCC_Rebate_Claim_Line_Item__c rc_line = new PCC_Rebate_Claim_Line_Item__c();
            rc_line.PCC_Rebate_Claim__c = rcInstance.Id;
            rc_line.PCC_Quote_Line_Number__c = 	lstquoteLines[0].Id;   
            rc_line.PCC_Quantity__c= 5;
            rc_line.PCC_Invoice__c= '2000'; 
            rc_line.PCC_OEM_Name__c = 'Asus';
            rc_line.PCC_Status__c = 'Submitted';
            rc_line.PCC_Invoice_Date__c = System.today();
            rc_line.PCC_Claimed_Rebate_Amount__c = 50000;
            insert rc_line;
            Test.startTest();
            rcInstance.PCC_Claim_Status__c = 'Claim Submitted';
            update rcInstance;   
            
            rcInstance.PCC_Claim_Status__c = 'Claim Approved - Payment Pending';
            update rcInstance;   
            
            rcInstance.PCC_Claim_Status__c = 'Payment Processed';
            update rcInstance;   
            Test.stopTest();
        }       
    }
}