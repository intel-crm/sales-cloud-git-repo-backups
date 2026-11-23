public class ObjectFieldMappingController {
    @AuraEnabled(cacheable=true)
    public static List<String> getAllObjects() {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        List<String> objectLabels = new List<String>();
        
        for (Schema.SObjectType objectType : gd.values()) {
            String name = objectType.getDescribe().getName();
            if(!objectType.getDescribe().isCustomSetting() && !name.endsWith('history') && !name.endsWith('tag')&&
               !name.endsWith('share') && !name.endsWith('feed') && !name.endsWith('__e') && !name.endsWith('Event') && !name.endsWith('__mdt')){      
                   objectLabels.add(objectType.getDescribe().getLabel()+' | '+objectType.getDescribe().getName());
                   System.debug( 'Name : ' + name);
               }
            
        }
        objectLabels.sort();
        
        return new List<String>(objectLabels);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getObjectFields(String selectedObject) {
        System.debug('selectedObject -->'+JSON.serialize(selectedObject));
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        
        Schema.SObjectType objectType = gd.get(selectedObject.trim());
        System.debug('objectType -->'+objectType);
        List<String> fields = new List<String>();
        
        if (objectType != null) {
            Schema.DescribeSObjectResult objDescribe = objectType.getDescribe();
            for (Schema.SObjectField field : objDescribe.fields.getMap().values()) {
                //fields.add(field.getDescribe().getName()); //field.getDescribe().getLabel()+' | '+
                fields.add(field.getDescribe().getLabel()+' | '+field.getDescribe().getName());
            }
        }
        fields.sort();
        return new List<String>(fields);
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getDRFields(){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType objectType = gd.get('Design_Registration_Stage__c');
        List<String> fields = new List<String>();
        if (objectType != null) {
            Schema.DescribeSObjectResult objDescribe = objectType.getDescribe();
            for (Schema.SObjectField field : objDescribe.fields.getMap().values()) {
                if(field.getDescribe().getName().contains('__c') ||field.getDescribe().getName().contains('Name') ){
                    fields.add(field.getDescribe().getLabel());
                }
            }
        }
        
        return fields;
    }
    @AuraEnabled(cacheable=true)
    public static List<String> getDRPFields(){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        Schema.SObjectType objectType = gd.get('Design_Registration_Product_M2M_Stage__c');
        List<String> fields = new List<String>();
        if (objectType != null) {
            Schema.DescribeSObjectResult objDescribe = objectType.getDescribe();
            for (Schema.SObjectField field : objDescribe.fields.getMap().values()) {
                if(field.getDescribe().getName().contains('__c') ||field.getDescribe().getName().contains('Name')){
                    fields.add(field.getDescribe().getLabel());
                }
            }
        }
        
        return fields;
    }
    
    
    
    
    
    @AuraEnabled
    public static void saveMapping(List<Map<String, String>> comboDataArray, String selectedObject) {
        DR_field_mapping_stored__c existingMetadataList = null;
        
        try {
            // Query existing record
            List<DR_field_mapping_stored__c> existingRecords = [SELECT DR_Are_Intel_items_used_mapped_with__c, DR_City_mapped_with__c, DR_Country_mapped_with__c, DR_Decision_Date_mapped_with__c, DR_Description_mapped_with__c, DR_End_Customer_Name_mapped_with__c, DR_External_Id_mapped_with__c, DR_First_Customer_Ship_Date_mapped_with__c, DR_Mapped_to_Rec_Id__c, DR_Opportunity_Volume_mapped_with__c, DR_Partner_FAE_Email_mapped_with__c, DR_Partner_FAE_mapped_with__c, DR_Product_Application_mapped_with__c, DR_Product_Segment_mapped_with__c, DR_Production_End_Date_mapped_with__c, DR_State_Province_mapped_with__c, DR_Street1_mapped_with__c, DR_Vertical_Market_mapped_with__c, DR_Zip_Postal_Code_mapped_with__c, Id, Object_to_be_mapped__c from DR_field_mapping_stored__c WHERE Name='DR_field_mapping_to_main_object_info' LIMIT 1];
            
            if (!existingRecords.isEmpty()) {
                existingMetadataList = existingRecords[0];
                
                // Update the corresponding fields based on the combo data array
                if (comboDataArray != null && !comboDataArray.isEmpty()) {
                    for (Map<String, String> comboData : comboDataArray) {
                        String label = comboData.get('label');
                        String selectedValue = comboData.get('selectedValue');
                        
                        if (label != null && selectedValue != null) {
                            // Update the corresponding field based on the combo data
                            switch on label {
                                when 'Design Registration Stage Name' {
                                    existingMetadataList.DR_Name_mapped_with__c = selectedValue;
                                }
                                when 'Are Intel items used for MINDS?' {
                                    existingMetadataList.DR_Are_Intel_items_used_mapped_with__c = selectedValue;
                                }
                                when 'City' {
                                    existingMetadataList.DR_City_mapped_with__c = selectedValue;
                                }
                                when 'Country' {
                                    existingMetadataList.DR_Country_mapped_with__c = selectedValue;
                                }
                                when 'Decision Date' {
                                    existingMetadataList.DR_Decision_Date_mapped_with__c = selectedValue;
                                }
                                when 'Description' {
                                    existingMetadataList.DR_Description_mapped_with__c = selectedValue;
                                }
                                when 'End Customer Name' {
                                    existingMetadataList.DR_End_Customer_Name_mapped_with__c = selectedValue;
                                }
                                when 'External Id' {
                                    existingMetadataList.DR_External_Id_mapped_with__c = selectedValue;
                                }
                                when 'First Customer Ship Date' {
                                    existingMetadataList.DR_First_Customer_Ship_Date_mapped_with__c = selectedValue;
                                }
                                when 'Record Id from main object' {
                                    existingMetadataList.DR_Mapped_to_Rec_Id__c = selectedValue;
                                }
                                when 'Opportunity Volume' {
                                    existingMetadataList.DR_Opportunity_Volume_mapped_with__c = selectedValue;
                                }
                                when 'Partner FAE' {
                                    existingMetadataList.DR_Partner_FAE_mapped_with__c = selectedValue;
                                }
                                when 'Partner FAE Email' {
                                    existingMetadataList.DR_Partner_FAE_Email_mapped_with__c = selectedValue;
                                }
                                when 'Product Application' {
                                    existingMetadataList.DR_Product_Application_mapped_with__c = selectedValue;
                                }
                                when 'Product Segment' {
                                    existingMetadataList.DR_Product_Segment_mapped_with__c = selectedValue;
                                }
                                when 'Production End Date' {
                                    existingMetadataList.DR_Production_End_Date_mapped_with__c = selectedValue;
                                }
                                when 'State/Province' {
                                    existingMetadataList.DR_State_Province_mapped_with__c = selectedValue;
                                }
                                when 'Street1' {
                                    existingMetadataList.DR_Street1_mapped_with__c = selectedValue;
                                }
                                when 'Vertical Market' {
                                    existingMetadataList.DR_Vertical_Market_mapped_with__c = selectedValue;
                                }
                                when 'Zip/Postal Code' {
                                    existingMetadataList.DR_Zip_Postal_Code_mapped_with__c = selectedValue;
                                }
                            }
                        }
                    }
                    
                    
                    existingMetadataList.Object_to_be_mapped__c=selectedObject;
                    update existingMetadataList;
                } else {
                    // Handle the case where comboDataArray is null or empty
                    
                }
            } else {
                // Create a new record
                DR_field_mapping_stored__c newRec = new DR_field_mapping_stored__c();
                newRec.Name = 'DR_field_mapping_to_main_object_info';
                
                // Set fields based on the combo data array
                if (comboDataArray != null && !comboDataArray.isEmpty()) {
                    for (Map<String, String> comboData : comboDataArray) {
                        String label = comboData.get('label');
                        String selectedValue = comboData.get('selectedValue');
                        
                        if (label != null && selectedValue != null) {
                            // Set fields based on the combo data
                            switch on label {
                                when 'Design Registration Stage Name' {
                                    newRec.DR_Name_mapped_with__c = selectedValue;
                                }
                                when 'Are Intel items used for MINDS?' {
                                    newRec.DR_Are_Intel_items_used_mapped_with__c = selectedValue;
                                }
                                when 'City' {
                                    newRec.DR_City_mapped_with__c = selectedValue;
                                }
                                when 'Country' {
                                    newRec.DR_Country_mapped_with__c = selectedValue;
                                }
                                when 'Decision Date' {
                                    newRec.DR_Decision_Date_mapped_with__c = selectedValue;
                                }
                                when 'Description' {
                                    newRec.DR_Description_mapped_with__c = selectedValue;
                                }
                                when 'End Customer Name' {
                                    newRec.DR_End_Customer_Name_mapped_with__c = selectedValue;
                                }
                                when 'External Id' {
                                    newRec.DR_External_Id_mapped_with__c = selectedValue;
                                }
                                when 'First Customer Ship Date' {
                                    newRec.DR_First_Customer_Ship_Date_mapped_with__c = selectedValue;
                                }
                                when 'Record Id from main object' {
                                    newRec.DR_Mapped_to_Rec_Id__c = selectedValue;
                                }
                                when 'Opportunity Volume' {
                                    newRec.DR_Opportunity_Volume_mapped_with__c = selectedValue;
                                }
                                when 'Partner FAE' {
                                    newRec.DR_Partner_FAE_mapped_with__c = selectedValue;
                                }
                                when 'Partner FAE Email' {
                                    newRec.DR_Partner_FAE_Email_mapped_with__c = selectedValue;
                                }
                                when 'Product Application' {
                                    newRec.DR_Product_Application_mapped_with__c = selectedValue;
                                }
                                when 'Product Segment' {
                                    newRec.DR_Product_Segment_mapped_with__c = selectedValue;
                                }
                                when 'Production End Date' {
                                    newRec.DR_Production_End_Date_mapped_with__c = selectedValue;
                                }
                                when 'State/Province' {
                                    newRec.DR_State_Province_mapped_with__c = selectedValue;
                                }
                                when 'Street1' {
                                    newRec.DR_Street1_mapped_with__c = selectedValue;
                                }
                                when 'Vertical Market' {
                                    newRec.DR_Vertical_Market_mapped_with__c = selectedValue;
                                }
                                when 'Zip/Postal Code' {
                                    newRec.DR_Zip_Postal_Code_mapped_with__c = selectedValue;
                                }
                            }
                            
                        }
                    }
                    
                    
                    
                    // Insert the new record
                    newRec.Object_to_be_mapped__c=selectedObject;
                    insert newRec;
                } else {
                    // Handle the case where comboDataArray is null or empty
                    
                }
            }
        } catch (Exception e) {
            // Handle exceptions here
            
        }
    }
    @AuraEnabled
    public static void saveDRPMapping(List<Map<String, String>> comboDataArray, String selectedObject) {
        DRP_field_mapping_stored__c existingMetadataList = null;
        
        try {
            // Query existing record
            List<DRP_field_mapping_stored__c> existingRecords = [select id,Name, DRP_Design_Registration_ID_mapped_with__c, DRP_MMID_mapped_with__c, DRP_Name_mapped_with__c, DRP_Old_MMID_mapped_with__c, DRP_Ordering_Code_mapped_with__c, DRP_Quantity_mapped_with__c, DRP_Target_Resale_Price_mapped_with__c from DRP_field_mapping_stored__c WHERE Name='DRP_field_mapping_to_main_object_info' LIMIT 1];
            
            if (!existingRecords.isEmpty()) {
                existingMetadataList = existingRecords[0];
                
                // Update the corresponding fields based on the combo data array
                if (comboDataArray != null && !comboDataArray.isEmpty()) {
                    for (Map<String, String> comboData : comboDataArray) {
                        String label = comboData.get('label');
                        String selectedValue = comboData.get('selectedValue');
                        
                        if (label != null && selectedValue != null) {
                            // Update the corresponding field based on the combo data
                            switch on label {
                                when 'Design Registration M2M Stage' {
                                    existingMetadataList.DRP_Design_Registration_ID_mapped_with__c = selectedValue;
                                }
                                when 'Design Registration Product M2M Stage Na' {
                                    existingMetadataList.DRP_Name_mapped_with__c = selectedValue;
                                }
                                when 'MMID' {
                                    existingMetadataList.DRP_MMID_mapped_with__c = selectedValue;
                                }
                                when 'Ordering Code' {
                                    existingMetadataList.DRP_Ordering_Code_mapped_with__c = selectedValue;
                                }
                                when 'Quantity' {
                                    existingMetadataList.DRP_Quantity_mapped_with__c = selectedValue;
                                }
                                when 'Record Id from main object' {
                                    existingMetadataList.DRP_Mapped_to_Rec_Id__c = selectedValue;
                                }
                                when 'Target Resale Price' {
                                    existingMetadataList.DRP_Target_Resale_Price_mapped_with__c = selectedValue;
                                }
                                when 'Old MMID' {
                                    existingMetadataList.DRP_Old_MMID_mapped_with__c = selectedValue;
                                }
                                
                                
                            }
                        }
                    }
                    
                    
                    existingMetadataList.Object_to_be_mapped__c=selectedObject;
                    update existingMetadataList;
                } else {
                    // Handle the case where comboDataArray is null or empty
                    
                }
            } else {
                // Create a new record
                DRP_field_mapping_stored__c newRec = new DRP_field_mapping_stored__c();
                newRec.Name = 'DRP_field_mapping_to_main_object_info';
                
                // Set fields based on the combo data array
                if (comboDataArray != null && !comboDataArray.isEmpty()) {
                    for (Map<String, String> comboData : comboDataArray) {
                        String label = comboData.get('label');
                        String selectedValue = comboData.get('selectedValue');
                        
                        if (label != null && selectedValue != null) {
                            // Set fields based on the combo data
                            switch on label {
                                when 'Design Registration M2M Stage' {
                                    newRec.DRP_Design_Registration_ID_mapped_with__c = selectedValue;
                                }
                                when 'Design Registration Product M2M Stage Na' {
                                    newRec.DRP_Name_mapped_with__c = selectedValue;
                                }
                                when 'MMID' {
                                    newRec.DRP_MMID_mapped_with__c = selectedValue;
                                }
                                when 'Ordering Code' {
                                    newRec.DRP_Ordering_Code_mapped_with__c = selectedValue;
                                }
                                when 'Quantity' {
                                    newRec.DRP_Quantity_mapped_with__c = selectedValue;
                                }
                                when 'Record Id from main object' {
                                    newRec.DRP_Mapped_to_Rec_Id__c = selectedValue;
                                }
                                when 'Target Resale Price' {
                                    newRec.DRP_Target_Resale_Price_mapped_with__c = selectedValue;
                                }
                                when 'Old MMID' {
                                    newRec.DRP_Old_MMID_mapped_with__c = selectedValue;
                                }
                                
                            }
                            
                        }
                    }
                    
                    
                    
                    // Insert the new record
                    newRec.Object_to_be_mapped__c=selectedObject;
                    insert newRec;
                } else {
                    // Handle the case where comboDataArray is null or empty
                    
                }
            }
        } catch (Exception e) {
            // Handle exceptions here
            
        }
    }
}