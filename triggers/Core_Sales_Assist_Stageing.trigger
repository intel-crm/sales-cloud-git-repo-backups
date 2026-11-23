trigger Core_Sales_Assist_Stageing on Core_Sales_Assist_Staging__c (after insert,after Update) {

    new Core_Sales_Assist_Stageing_Handler().run();
}