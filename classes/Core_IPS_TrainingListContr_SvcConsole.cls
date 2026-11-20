public class Core_IPS_TrainingListContr_SvcConsole {

    public Map <String,Core_IPS_Training_SvcConsole__c>  topicList {
        get {
            Map <String,Core_IPS_Training_SvcConsole__c> topics = Core_IPS_Training_SvcConsole__c.getAll();
            return topics;
        }
        set;
     }
}