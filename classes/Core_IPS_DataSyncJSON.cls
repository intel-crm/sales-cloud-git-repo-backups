public class Core_IPS_DataSyncJSON {
    public static  void JSonfieldvaluemap(){
        list<Core_IPS_Backend_Field_Map__c> fieldvalumaplist = [Select Id, Name, Core_IPS_Direction__c, Core_IPS_New_Backend_System__r.Name, Core_Object_Name__c, Core_IPS_Order__c, Core_IPS_Source_Field__c, Core_IPS_Target_Field__c, (Select Backend_Field_Mapping_HSD__c, Core_IPS_Source_Value__c, Core_IPS_Target_Value__c from Backend_Value_Mappings_HSD__r) from Core_IPS_Backend_Field_Map__c where Core_IPS_New_Backend_System__c='a3x3F000000JS2o'];
        if(!fieldvalumaplist.isEmpty()){
            JSONGenerator jsonGen = JSON.createGenerator(true);
            jsonGen.writeStartObject();
            for(Core_IPS_Backend_Field_Map__c c: fieldvalumaplist){
                
                jsonGen.writeStringField('Backend_System_Name',c.Core_IPS_New_Backend_System__r.Name);
            }
            
            for(Core_IPS_Backend_Field_Map__c c: fieldvalumaplist){
            
                jsonGen.writeFieldName('Field Mapping');
                jsonGen.writeStartArray();
                jsonGen.writeStringField('Core_IPS_Source_Field__c',c.Core_IPS_Source_Field__c);
                jsonGen.writeStringField('Core_IPS_Target_Field__c',c.Core_IPS_Target_Field__c);
                jsonGen.writeStringField('Core_IPS_Direction__c',c.Core_IPS_Direction__c);
                jsonGen.writeFieldName('Value Mapping');
                jsonGen.writeStartArray();
                jsonGen.writeObject(c.Backend_Value_Mappings_HSD__r);
                //jsonGen.writeStringField('Core_IPS_Target_Value__c',c.Core_IPS_Target_Value__c);
                jsonGen.writeEndArray();
                jsongen.writeEndArray();
            }
            jsonGen.writeEndObject();
            String jsonData = jsonGen.getAsString();
            System.debug('Json Data - ' + jsonData);

        }
    }
}