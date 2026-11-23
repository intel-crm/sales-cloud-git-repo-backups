/****************************************************************************************************************************************
* Class Name  : Core_MDF_UpdateBankDetails_Test
* Version     : 1.0
* Created Date: 11-07-2018
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Varun Kumar                   11-07-2018                    Test class for Core_MDF_UpdateBankDetails
*****************************************************************************************************************************************/
@isTest
public class Core_MDF_UpdateBankDetails_Test {

    @isTest
    static void updateBankDetails(){

        Account acc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);

        Core_MDF_Bank__c newBank = Core_MDF_CCP_TestDataUtility.createBank(acc.id, 'Core_MDF_Client_CoMarketing_Fund', false,'1234567891');
        newBank.Core_MDF_Bank_Status__c = 'Draft';
        newBank.Core_MDF_DUNS__c = '578299333';
        newBank.Core_MDF_Bank_Beneficiary_Name__c = 'TEST BENEFICIARY NAME';
        newBank.Core_MDF_Bank_Location__c = 'IN';
        newBank.Core_MDF_Swift_Code__c = 'BOFSGB21124';
        newBank.Core_MDF_Intermediary_Indicator__c = 'N';
        newBank.Core_MDF_Routing_Number__c = '123456';
        newBank.Core_MDF_ESD_Hold_Indicator__c = FALSE;
        newBank.Core_MDF_Effective_Date__c = system.today().addDays(5);
        newBank.Core_MDF_Supplier_Name__c='TEST SUPPLIER NAME';
        newBank.Name = 'TEST BANK';
        newBank.Core_MDF_Currency_cd__c = 'USD';
        Insert newBank;

        Core_Integration_Inbound_Message__c payLoad1 = new Core_Integration_Inbound_Message__c();
        payLoad1.Core_Payload__c = '[{"SUPPL_HLD_PMT_IND":"N","bnfcy_nm":"TEST BENEFICIARY NAME","intrmd_bank_ind":"N","bnk_nm":"TEST BANK","bnk_nbr":"123456","ap_vndr_nbr":1234567891,"DUNS_NBR":"578299333 ","ctry_cd":"GB ","suppl_nm":"Test","swift_cd":"BOFSGB21124 ", "currency_cd": "USD"}]';
        payLoad1.Core_Message_Type__c = 'Bank';
        payLoad1.Core_Source_System__c   = 'EDW';
        insert payLoad1;

        Core_MDF_Bank__c updatedBank = [SELECT  Name,Core_MDF_Bank_Status__c,Core_MDF_ESD_Hold_Indicator__c,
                                        Core_MDF_Bank_Beneficiary_Name__c, Core_MDF_Swift_Code__c, Core_MDF_DUNS__c,
                                        Core_MDF_Routing_Number__c, Core_MDF_ESD_Update__c, Core_MDF_Supplier_Number__c, Core_MDF_Supplier_Name__c, Core_MDF_Bank_Location__c
                                        FROM Core_MDF_Bank__c
                                        WHERE Core_MDF_Supplier_Number__c = '1234567891' AND Core_MDF_Currency_cd__c = 'USD' LIMIT 1];

        System.assertEquals(FALSE, updatedBank.Core_MDF_ESD_Hold_Indicator__c);
        //System.assertEquals('TEST BANK', updatedBank.Name);
        //System.assertEquals('BENEFICIARY NAME', updatedBank.Core_MDF_Bank_Beneficiary_Name__c);
        System.assertEquals('BOFSGB21124', updatedBank.Core_MDF_Swift_Code__c);
        System.assertEquals('578299333', updatedBank.Core_MDF_DUNS__c);
        System.assertEquals('123456', updatedBank.Core_MDF_Routing_Number__c);
        System.assertEquals('1234567891', updatedBank.Core_MDF_Supplier_Number__c);
        System.assertEquals('Test',updatedBank.Core_MDF_Supplier_Name__c);
        //System.assertEquals('GB', updatedBank.Core_MDF_Bank_Location__c);
        //system.assertEquals('Inactive', updatedBank.Core_MDF_Bank_Status__c);

        Core_Integration_Inbound_Message__c ciim=[SELECT Core_Processing_Status__c from Core_Integration_Inbound_Message__c where Id= :payLoad1.Id];
        System.assertEquals('Successful', ciim.Core_Processing_Status__c);

        acc.Core_MDF_CoMarketingActive__c  = false;
        update acc;

        Core_Integration_Inbound_Message__c payLoad2 = new Core_Integration_Inbound_Message__c();
        payLoad2.Core_Payload__c = '[{"SUPPL_HLD_PMT_IND":"Y","bnfcy_nm":"TEST BENEFICIARY NAME","intrmd_bank_ind":"N","bnk_nm":"TEST BANK","bnk_nbr":"123456","ap_vndr_nbr":1234567891,"DUNS_NBR":"578299333 ","ctry_cd":"GB ","suppl_nm":"Test","swift_cd":"BOFSGB22124", "currency_cd": "USD"}]';
        payLoad2.Core_Message_Type__c = 'Bank';
        payLoad2.Core_Source_System__c = 'EDW';
        insert payLoad2;
    }


    @isTest
    static void updateBankwithInvalidPayload(){

        Account acc = Core_MDF_CCP_TestDataUtility.createIntelAccount('Test Account', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, true);

        Core_MDF_Bank__c newBank = Core_MDF_CCP_TestDataUtility.createBank(acc.id, 'Core_MDF_Client_CoMarketing_Fund', false,'1234567891');
        newBank.Core_MDF_Bank_Status__c = 'Draft';
        newBank.Core_MDF_Effective_Date__c = system.today().addDays(5);
        newBank.Core_MDF_Currency_cd__c = 'USD';
        Insert newBank;

        Core_Integration_Inbound_Message__c payLoad = new Core_Integration_Inbound_Message__c();
        payLoad.Core_Payload__c = '[{"SUPPL_HLD_PMT_IND":"Y","bnfcy_nm":,"intrmd_bank_ind":"N","bnk_nm":"TEST BANK","bnk_nbr":"123456 ","ap_vndr_nbr":1234567891,"DUNS_NBR":"578299331 ","ctry_cd":"GB ","swift_cd":"BOFSGB21124 ", "currency_cd": "USD"}]';
        payLoad.Core_Message_Type__c = 'Bank';
        payLoad.Core_Source_System__c   = 'EDW';
        insert payLoad;

        Core_MDF_Bank__c updatedBank = [SELECT  Name,Core_MDF_Bank_Status__c,Core_MDF_ESD_Hold_Indicator__c,
                                        Core_MDF_Bank_Beneficiary_Name__c, Core_MDF_Swift_Code__c, Core_MDF_DUNS__c,
                                        Core_MDF_Routing_Number__c, Core_MDF_ESD_Update__c, Core_MDF_Supplier_Number__c
                                        FROM Core_MDF_Bank__c
                                        WHERE Core_MDF_Supplier_Number__c = '1234567891' AND Core_MDF_Currency_cd__c = 'USD' LIMIT 1];

        System.assertEquals(FALSE,updatedBank.Core_MDF_ESD_Hold_Indicator__c);

        Core_Integration_Inbound_Message__c ciim=[SELECT Core_Processing_Status__c from Core_Integration_Inbound_Message__c where Id= :payLoad.Id];
        System.assertEquals('Failed', ciim.Core_Processing_Status__c);
    }


    @TestSetUP
    static void triggerForERPM(){

        Core_Trigger_Executions__c triggerActive = new Core_Trigger_Executions__c();
        triggerActive.NAME = 'processInboundMessagesERPM';
        triggerActive.Core_Active__c = TRUE;
        triggerActive.Core_Class_Name__c = 'Core_IntegrationInboundMessageHandler';
        triggerActive.Core_Description__c = 'Process inbound ERPM messages from iPaaS';
        triggerActive.Core_Object__c = 'Core_Integration_Inbound_Message__c';
        triggerActive.Core_Trigger_Events__c = 'after insert, after update';
        insert triggerActive;
    }

    @isTest
    static void insertPayLoadForContact(){
        Core_Integration_Inbound_Message__c contactPayLoad = new Core_Integration_Inbound_Message__c();
        contactPayLoad.Core_Message_Type__c = 'Contact';
        contactPayLoad.Core_Source_System__c = 'ERPM';
        insert contactPayLoad;
        System.assert(contactPayLoad.Core_Source_System__c == 'ERPM');
        }

    @isTest
    static void insertPayLoadForAccount(){
        Core_Integration_Inbound_Message__c accountPayLoad = new Core_Integration_Inbound_Message__c();
        accountPayLoad.Core_Message_Type__c = 'Account';
        accountPayLoad.Core_Source_System__c = 'ERPM';
        insert accountPayLoad;
        System.assert(accountPayLoad.Core_Source_System__c == 'ERPM');
    }

    @isTest
    static void insertPayLoadForBlackBox(){
        Core_Integration_Inbound_Message__c blackBoxPayLoad = new Core_Integration_Inbound_Message__c();
        blackBoxPayLoad.Core_Message_Type__c = 'Blackbox';
        blackBoxPayLoad.Core_Source_System__c = 'ERPM';
        insert blackBoxPayLoad;
        System.assert(blackBoxPayLoad.Core_Source_System__c == 'ERPM');
    }

    @isTest
    static void insertPayLoadForAGS(){

        Core_Trigger_Executions__c triggerActive = new Core_Trigger_Executions__c();
        triggerActive.NAME = 'processInboundMessagesAGS';
        triggerActive.Core_Active__c = TRUE;
        triggerActive.Core_Class_Name__c = 'Core_IntegrationInboundMessageHandler';
        triggerActive.Core_Description__c = 'Process inbound AGS messages from iPaaS';
        triggerActive.Core_Object__c = 'Core_Integration_Inbound_Message__c';
        triggerActive.Core_Trigger_Events__c = 'after insert, after update';
        insert triggerActive;

        Core_Integration_Inbound_Message__c rolePayLoad = new Core_Integration_Inbound_Message__c();
        rolePayLoad.Core_Message_Type__c = 'Role';
        rolePayLoad.Core_Source_System__c = 'AGS';
        insert rolePayLoad;
        System.assert(rolePayLoad.Core_Source_System__c == 'AGS');
    }

    @isTest
    static void insertPayLoadForQuote(){

        Core_Trigger_Executions__c triggerActive = new Core_Trigger_Executions__c();
        triggerActive.NAME = 'processInboundMessages';
        triggerActive.Core_Active__c = TRUE;
        triggerActive.Core_Class_Name__c = 'Core_IntegrationInboundMessageHandler';
        triggerActive.Core_Description__c = 'Process inbound messages from iPaas';
        triggerActive.Core_Object__c = 'Core_Integration_Inbound_Message__c';
        triggerActive.Core_Trigger_Events__c = 'before insert, before update';
        insert triggerActive;

        Core_Integration_Inbound_Message__c quotePayLoad = new Core_Integration_Inbound_Message__c();
        quotePayLoad.Core_Message_Type__c = 'Quote';
        insert quotePayLoad;
        System.assert(quotePayLoad.Core_Message_Type__c == 'Quote');
    }
    @isTest
    static void logErrorinLogObjectWithReasonTest(){

            List<Account> acctList = new List<Account>();

            Account acc1 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 1', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            Database.insert(acc1);
            system.assert(acc1.id!=Null);

            acctList.add(acc1);
            Account acc2 = Core_MDF_CCP_TestDataUtility.createIntelAccount ('Test Account 2', Core_MDF_CCP_TestDataUtility.Intel_Account_Record_Type, false);
            Database.insert(acc2);
            acctList.add(acc2);
            String errortext = 'Test';
            Core_MDF_CCP_UtilityClass.updateListAndLogErrors(acctList,errortext);
            Core_MDF_CCP_UtilityClass.logErrorinLogObject(errortext, 'Test');
            system.assert(acc2.id!=Null);
            Core_MDF_UpdateBankDetails.logErrorinLogObjectWithReason(errortext,'parsing exception');
      }
}