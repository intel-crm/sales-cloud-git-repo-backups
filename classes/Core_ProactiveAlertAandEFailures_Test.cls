/******************************************************************************************************************************************
Class Name  : Core_ProactiveAlertAandEFailures_Test
Version     : 1.0
Created Date: 10 JULY 2022
Function    : This is test class for Core_ProactiveAlertAandEFailures class   

Modification Log :
* Developer                 	Date [DD/MM/YYYY]           	Description
* ----------------------------------------------------------------------------
* Akshay More [Team: DRACO]			10/07/2022              	Original version
*****************************************************************************************************************************************/
@isTest
public class Core_ProactiveAlertAandEFailures_Test {
    
    public static final String LOG_ENTRY_ORIGIN = 'SFDC';
    public static final String LOG_ENTRY_ERROR = 'error';
    public static final String AGS_RESPONSE ='AGS Response';
    public static final String LOG_ENT_PROJ_ALERT = 'AccessAndEntitlement';
    public static final String LOG_ENT_SCOPE_ALERT = 'A&EFailureAlert';
    public static final String LOG_ENT_OBJ_ALERT = 'Contact';
    public static final String LOG_ENT_MSG = 'A&E Failure in Inbound Message';
    //--------------------------------------------------------------------------------------------------
    // TEST SETUP AND UTILITY METHODS
    
    @testSetup 
    static void setupTestData() {
        Account intelAccount1 = new Account(Name ='IntelAccount1',Core_Account_Type__c = 'Original Design Manufacturer (ODM)',
                                            Industry='Agriculture', BillingCity='delhi',BillingCountry='Ind',BillingStreet='cbc chowk delhi');
        insert intelAccount1;
        
        Contact contact1 = new Contact(firstname='Intel',Core_IPA_Contact_Segment__c ='Client Computing;Data Center', 
                                       lastname='Contact1', accountId=intelAccount1.id,Email='dellco1234@dell.com');
        insert contact1;
        
        insert new Core_AE_Proactive_Alerts__c(Send_Proactive_Alert__c = true, Alert_Frequency__c = 5);
        
        List<Core_Log_Entry__c> logEntryList = new List<Core_Log_Entry__c>();
        List<Proactive_Alerts_on_A_E_Integration__mdt> lstProactiveAlertMtd = new List<Proactive_Alerts_on_A_E_Integration__mdt>();
        lstProactiveAlertMtd = Proactive_Alerts_on_A_E_Integration__mdt.getall().values();
        for(Proactive_Alerts_on_A_E_Integration__mdt ProActAlert : lstProactiveAlertMtd) {
            if(ProActAlert.Core_Is_Active__c && !ProActAlert.IsIgnore__c){ 
                for(Integer i = 0; i < ProActAlert.Core_Minimum_count_for_Alert__c + 2; i++){
                    Core_Log_Entry__c logEntry = new Core_Log_Entry__c();
                    logEntry.Core_Origin__c = LOG_ENTRY_ORIGIN;
                    logEntry.Core_Severity__c = LOG_ENTRY_ERROR;
                    logEntry.Core_Project__c = LOG_ENT_PROJ_ALERT;
                    logEntry.Core_Scope__c = LOG_ENT_SCOPE_ALERT;
                    logEntry.Core_sObjectType__c = LOG_ENT_OBJ_ALERT;
                    logEntry.Core_Message__c = LOG_ENT_MSG;
                    logEntry.Core_sObjectId__c = contact1.Id;
                    logEntry.Core_Details__c = 'Some Entitlement Name-->' + ProActAlert.Core_Error_Text__c;
                    logEntry.Core_When__c = system.now();
                    logEntry.Core_Tags__c = '300005019183;a003b00000xiKIIAA2;003o000000P8ngQAAR;1338492;someemail@mail.com;';
                    logEntryList.add(logEntry);
                }
            }
        }
        insert logEntryList;
    }
    
    static testMethod void processLogEntryTest() {
        Test.startTest();
        Core_ProactiveAlertAandEFailures.processLogEntry();
        Test.stopTest();
    }
}