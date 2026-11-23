public class SWS_DisptachCoupenEmailController {
    public static string getSWSLabel(String name){
        String labelValue = '';
        if (!String.isBlank(name)) {
            SWS_Core_CRM_Labels__c swsLabel = SWS_Core_CRM_Labels__c.getValues(name);
            labelValue = swsLabel != null ? swsLabel.SWS_Value__c : '';
        }
        return labelValue;
    }

    public static Map<String,SWS_Core_CRM_Labels__c> getAllSWSLabel(){
        Map<String,SWS_Core_CRM_Labels__c> mapOfSWSLabel = new Map<String,SWS_Core_CRM_Labels__c>();
        return mapOfSWSLabel = SWS_Core_CRM_Labels__c.getAll();
    }
}