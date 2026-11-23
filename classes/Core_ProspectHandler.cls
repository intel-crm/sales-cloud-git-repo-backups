public class Core_ProspectHandler {
    
    public static void prospectObjectBeforeHandler(List<Core_Prospect__c> listNewProspect,Map<Id,Core_Prospect__c> mapOldsObject){
        //Call the method to populate both Geo & Sub Geo fields using the Country State Reference object
        /**Core_Utility.sObjectGeoMappingField(listNewProspect, mapOldsObject, new list<String>{'Core_Country__c'}, 
                                                new list<String>{'', ''}, 'Core_Region__c','Core_Sub_Region__c'); **/
        
    }

}