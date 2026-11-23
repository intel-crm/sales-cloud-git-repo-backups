global class BatchClassforDRUpdate implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    String object_name;
    public String dr_Are_Intel_items_used_for_MINDS;
    public String dr_City;
    public String dr_mapped_rec_id;
    public String dr_Country;
    public String dr_Decision_Date;
    public String dr_Description;
    public String dr_End_Customer_Name;
    public String dr_External_Id;
    public String dr_First_Customer_Ship_Date;
    public String dr_Opportunity_Volume;
    public String dr_Partner_FAE;
    public String dr_Partner_FAE_Email;
    public String dr_Product_Segment;
    public String dr_Product_Application;
    public String dr_Production_End_Date;
    public String dr_State_Province;
    public String dr_Street1;
    public String dr_Vertical_Market;
    public String dr_Zip_Postal_Code;
    public String dr_name_mapped_with;
    List<Id> recordIds = new List<Id>();

    global Database.QueryLocator start(Database.BatchableContext BC) {        
        BatchDRUtility utilityInstance = new BatchDRUtility();
        utilityInstance.initialize();
        object_name = utilityInstance.getObjectName();
        dr_name_mapped_with=utilityInstance.dr_name_mapped_with;
        dr_Are_Intel_items_used_for_MINDS=utilityInstance.dr_Are_Intel_items_used_for_MINDS;
        dr_City=utilityInstance.dr_City;
        dr_mapped_rec_id=utilityInstance.dr_mapped_rec_id;
        dr_Country=utilityInstance.dr_Country;
        dr_Decision_Date=utilityInstance.dr_Decision_Date;
        dr_Description=utilityInstance.dr_Description;
        dr_End_Customer_Name=utilityInstance.dr_End_Customer_Name;
        dr_External_Id=utilityInstance.dr_External_Id;
        dr_First_Customer_Ship_Date=utilityInstance.dr_First_Customer_Ship_Date;
        dr_Opportunity_Volume=utilityInstance.dr_Opportunity_Volume;
        dr_Partner_FAE=utilityInstance.dr_Partner_FAE;
        dr_Partner_FAE_Email=utilityInstance.dr_Partner_FAE_Email;
        dr_Product_Segment=utilityInstance.dr_Product_Segment;
        dr_Product_Application=utilityInstance.dr_Product_Application;
        dr_Production_End_Date=utilityInstance.dr_Production_End_Date;
        dr_State_Province=utilityInstance.dr_State_Province;
        dr_Street1=utilityInstance.dr_Street1;
        dr_Vertical_Market=utilityInstance.dr_Vertical_Market;
        dr_Zip_Postal_Code=utilityInstance.dr_Zip_Postal_Code;

        String query = 'SELECT Id, ' +dr_name_mapped_with+', '+ dr_Are_Intel_items_used_for_MINDS + ', ' + dr_City + ', ' + dr_Country + ', ' + dr_Decision_Date + ', ' + dr_Description + ', ' + dr_End_Customer_Name + ', ' + dr_External_Id + ', ' + dr_First_Customer_Ship_Date + ', ' + dr_Opportunity_Volume + ', ' + dr_Partner_FAE + ', ' + dr_Partner_FAE_Email + ', ' + dr_Product_Segment + ', ' + dr_Product_Application + ', ' + dr_Production_End_Date + ', ' + dr_State_Province + ', ' + dr_Street1 + ', ' + dr_Vertical_Market + ', ' + dr_Zip_Postal_Code + ' FROM ' + object_name + ' WHERE Id = \'a3DDf000000CQV9MAO\' AND CreatedDate!=Today';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> objectRecords) {
        List<Design_Registration_Stage__c> drUpdateList = new List<Design_Registration_Stage__c>();
        List<Id> recId=new List<Id>();
        
            for (sObject rec1 : objectRecords){
               
                recId.add(rec1.Id);
                
            }
        system.debug(recId);
        try {
            List<Design_Registration_Stage__c> existingDr=[select Id,Response__c, Record_Id_from_Response__c,Are_Intel_items_used_for_MINDS__c, City__c,Country__c, Decision_Date__c, Description__c, End_Customer_Name__c, External_Id__c, First_Customer_Ship_Date__c, Name, Opportunity_Volume__c, Partner_FAE__c, Partner_FAE_Email__c, Product_Application__c, Product_Segment__c, Production_End_Date__c, Record_Id_from_main_object__c,State_Province__c, Street1__c, Vertical_Market__c from Design_Registration_Stage__c where Record_Id_from_main_object__c IN:recId];
            for (sObject rec : objectRecords) { 
                if(existingDr!=null){
                    for(Design_Registration_Stage__c dr:existingDr){
                        if(dr.Record_Id_from_main_object__c==rec.Id){
                      dr.Name=(String) rec.get(dr_name_mapped_with);
                dr.Are_Intel_items_used_for_MINDS__c = (String)rec.get(dr_Are_Intel_items_used_for_MINDS);
                dr.City__c = (String) rec.get(dr_City);
                dr.Country__c = (String) rec.get(dr_Country);
                dr.Decision_Date__c = (Date) rec.get(dr_Decision_Date);
                dr.Description__c = (String) rec.get(dr_Description);
                dr.End_Customer_Name__c = (String) rec.get(dr_End_Customer_Name);
                dr.External_Id__c = (String) rec.get(dr_External_Id);
                dr.First_Customer_Ship_Date__c = (Date) rec.get(dr_First_Customer_Ship_Date);
                dr.Opportunity_Volume__c = (Decimal) rec.get(dr_Opportunity_Volume);
                dr.Partner_FAE__c = (String) rec.get(dr_Partner_FAE);
                dr.Partner_FAE_Email__c = (String) rec.get(dr_Partner_FAE_Email);
                dr.Product_Application__c = (String) rec.get(dr_Product_Application);
                dr.Product_Segment__c = (String) rec.get(dr_Product_Segment);
                dr.Production_End_Date__c = (Date) rec.get(dr_Production_End_Date);
                dr.Record_Id_from_main_object__c = (String) rec.get(dr_mapped_rec_id);
                dr.State_Province__c = (String) rec.get(dr_State_Province);
                dr.Street1__c = (String) rec.get(dr_Street1);
                dr.Vertical_Market__c = (String) rec.get(dr_Vertical_Market);
                dr.Zip_Postal_Code__c = (String) rec.get(dr_Zip_Postal_Code); 
                        drUpdateList.add(dr); 
                        }
                        }
                }
                               
             
            }
            
            update drUpdateList;
            for (Design_Registration_Stage__c drMapping1 : drUpdateList) {
            recordIds.add(drMapping1.Id);
        }
        } catch (Exception e) {
            System.debug('Error in batch execution: ' + e.getMessage());
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {

        if (!recordIds.isEmpty()) {
           makeCallout(recordIds);
        }
    }
    public static void makeCallout(List<Id> recordIds) {
        try {
            List<Design_Registration_Stage__c> recordData = [SELECT Id,Name,Record_Id_from_Response__c,Response__c,Record_Id_from_main_object__c,Country__c,City__c,Are_Intel_items_used_for_MINDS__c,Vertical_Market__c,Product_Segment__c,Product_Application__c,Partner_FAE__c,Partner_FAE_Email__c,Opportunity_Volume__c,End_Customer_Name__c,State_Province__c,Street1__c,Zip_Postal_Code__c,Production_End_Date__c,Decision_Date__c,Description__c,External_Id__c,First_Customer_Ship_Date__c from Design_Registration_Stage__c WHERE Id IN :recordIds];

            for (Design_Registration_Stage__c rec1 : recordData) {
                DRStage_utility.calloutUpdateDR(rec1);
            }
        } catch (Exception ex) {
            System.debug('An error occurred: ' + ex.getMessage());
        }
    }
}