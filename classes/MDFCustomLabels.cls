public class MDFCustomLabels {
    
    public static Map<String,String> labelMap = new Map<String,String>();
    
    static{
        Map<String,String> objMap =  new Map<String,String>();
        For(Custom_Label__mdt labelObj : [SELECT
                                          DeveloperName,Value__c
                                          FROM 
                                          Custom_Label__mdt]){
                                              labelMap.put(labelObj.DeveloperName,labelObj.Value__c);
                                              
                                          }
    }
    
    @AuraEnabled
    public static Map<String,String> getLabels(){
        return labelMap;
    }
    
}