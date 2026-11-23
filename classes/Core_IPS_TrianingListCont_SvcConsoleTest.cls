@Istest
Public class Core_IPS_TrianingListCont_SvcConsoleTest
{
    static testmethod void Core_TrianingListCont_SvcConsoleTest()
    {
        Core_IPS_Training_SvcConsole__c Training =  new    Core_IPS_Training_SvcConsole__c();
        Training.Name = 'TRNG001';
        Training.Training_Topic__c = 'Google';
        Training.Training_Link__c = 'http://www.google.com';
        insert Training;
        
        Map <String,Core_IPS_Training_SvcConsole__c> Maptopic =  new Map <String,Core_IPS_Training_SvcConsole__c>();
       Maptopic.put('TRNG001',Training);
                PageReference TrainingPage = Page.Core_IPS_Training_SvcConsole;
                Test.setCurrentPage(TrainingPage);
                
               Core_IPS_TrainingListContr_SvcConsole TrianingListController =  new Core_IPS_TrainingListContr_SvcConsole();
               TrianingListController.topicList = Maptopic;
               Map <String,Core_IPS_Training_SvcConsole__c> topic = TrianingListController.topicList;
    }

}