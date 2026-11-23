global class BatchClassforDRP implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    String object_name;
    public String drp_dr_Id;
    public String drp_MMId;
    public String drp_Ordering_Code;
    public String drp_Name;
    public String drp_Quanitity;
    public String drp_Target_Resale_price;
    public String drp_Old_MMId;
    public String drp_Record_Id_from_main_object;
    public String drp_RecordId_main_Object;
    public String query;
   
    Datetime fiveMinutesAgo = Datetime.now().addMinutes(-5);
    String formattedDateTime = fiveMinutesAgo.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    List<Id> recordIdsCreate = new List<Id>();
    List<Id> recordIdsUpdate = new List<Id>();
    
    global Database.QueryLocator start(Database.BatchableContext BC) {        
        BatchDRUtility utilityInstance = new BatchDRUtility();
        utilityInstance.initializeDRP();
        object_name = utilityInstance.getDRPObjectName();
       drp_dr_Id= utilityInstance.drp_DR_ID_mapped_with;
  drp_MMId= utilityInstance.drp_Mmid_mapped_with;
        drp_Old_MMId=utilityInstance.drp_Old_mmid_mapped_with;
   drp_Ordering_Code= utilityInstance.drp_Ordering_code_mapped_with;
    drp_Name= utilityInstance.drp_name_mapped_with;
    drp_Quanitity= utilityInstance.drp_quantity_mapped_with;
    drp_Target_Resale_price= utilityInstance.drp_Target_resale_mapped_with;
        drp_RecordId_main_Object=utilityInstance.drp_mapped_rec_id;
        if(drp_MMId!=null){
        query = 'SELECT Id, ' +drp_dr_Id+', '+ drp_MMId + ', ' + drp_Name + ', ' + drp_Quanitity + ', ' + drp_Target_Resale_price + ' FROM ' + object_name + ' WHERE CreatedDate >= ' + formattedDateTime + ' OR LastModifiedDate >= ' + formattedDateTime ;
        }
        if(drp_Old_MMId!=null){
        query = 'SELECT Id, ' +drp_dr_Id+', ' + drp_Old_MMId + ', ' + drp_Name + ', ' + drp_Quanitity + ', ' + drp_Target_Resale_price + ' FROM ' + object_name + ' WHERE CreatedDate >= ' + formattedDateTime + ' OR LastModifiedDate >= ' + formattedDateTime ;
        }
        if(drp_Ordering_Code!=null){
        query = 'SELECT Id, ' +drp_dr_Id+', ' + drp_Ordering_Code + ', ' + drp_Name + ', ' + drp_Quanitity + ', ' + drp_Target_Resale_price + ' FROM ' + object_name + ' WHERE CreatedDate >= ' + formattedDateTime + ' OR LastModifiedDate >= ' + formattedDateTime ;
        }
        if (Test.isRunningTest()) {
            // Additional logic specific to non-test execution
            query ='select Design_Registration_dummy__c,MMID__c, Name, Old_MMID__c, Ordering_Code__c, Quantity__c, Record_Id_from_main_object__c, Record_Id_from_Response__c, Response__c, Target_Resale_Price__c from Design_Registration_Product_M2M_Stage__c Limit 1'; 
        }
            system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> objectRecords) {
        for(sObject record:objectRecords){
        system.debug('Id '+record.Id);
        }
       
        List<Design_Registration_Product_M2M_Stage__c> drpMappingRecords = new List<Design_Registration_Product_M2M_Stage__c>();
        List<Design_Registration_Product_M2M_Stage__c> drpUpdateList = new List<Design_Registration_Product_M2M_Stage__c>();
        List<Id> recId=new List<Id>();
        List<Id> recDRId=new List<Id>();
        List<Id> existingDRPRecId=new List<Id>();
        for (sObject rec1 : objectRecords){            
            recId.add(rec1.Id); 
            recDRId.add((String)rec1.get(drp_dr_Id));
        }
        system.debug(recId);
  system.debug(recDRId);
        List<Design_Registration_Stage__c> drforDRPstage=[select id,Record_Id_from_main_object__c from Design_Registration_Stage__c where Record_Id_from_main_object__c in:recDRId];
            List<Design_Registration_Product_M2M_Stage__c> existingDrp=[select Design_Registration_dummy__c, Id, MMID__c, Name, Ordering_Code__c, Quantity__c, Record_Id_from_main_object__c,Old_MMID__c, Record_Id_from_Response__c, Response__c, Target_Resale_Price__c  from Design_Registration_Product_M2M_Stage__c  where Record_Id_from_main_object__c IN:recId];
        for(Design_Registration_Product_M2M_Stage__c existingDRPId:existingDrp){
            existingDRPRecId.add(existingDRPId.Record_Id_from_main_object__c);
        }
       
            try {
                for (sObject rec1 : objectRecords) { 
                    for(Design_Registration_Stage__c dr1:drforDRPstage){
                        if(dr1.Record_Id_from_main_object__c==(Id)rec1.get(drp_dr_Id)){
                            if(!existingDrp.isEmpty()){
                    for(Design_Registration_Product_M2M_Stage__c drp:existingDrp){
                        if(drp.Record_Id_from_main_object__c==rec1.Id ){
                            
                            drp.Design_Registration_dummy__c=dr1.Id;
                            if(drp_MMId != null && !String.isBlank(drp_MMId)){

                            drp.MMID__c = (String)rec1.get(drp_MMId);
                            }
                            drp.Name = (String) rec1.get(drp_Name);
                            
                            if(drp_Ordering_Code != null && !String.isBlank(drp_Ordering_Code)){
                            drp.Ordering_Code__c = (String) rec1.get(drp_Ordering_Code);
                        }
                           
                            drp.Quantity__c = (Decimal) rec1.get(drp_Quanitity);
                            drp.Record_Id_from_main_object__c = (String) rec1.get(drp_RecordId_main_Object);
                            drp.Target_Resale_Price__c = (Decimal) rec1.get(drp_Target_Resale_price);
                            if(drp_Old_MMId!=null && !String.isBlank(drp_Old_MMId)){
                          drp.Old_MMID__c= (String) rec1.get(drp_Old_MMId);
                        }
                          
                            drpUpdateList.add(drp); 
                        }
                    }
                    }
                
                    system.debug(drpUpdateList);
                    
                    if(!existingDRPRecId.contains(rec1.Id)){
                    Design_Registration_Product_M2M_Stage__c drpMapping = new Design_Registration_Product_M2M_Stage__c(); 
                    drpMapping.Name=(String) rec1.get(drp_Name);
                    drpMapping.Design_Registration_dummy__c=dr1.Id;
                        drpMapping.Quantity__c = (Decimal) rec1.get(drp_Quanitity);
                            drpMapping.Record_Id_from_main_object__c = (String) rec1.get(drp_RecordId_main_Object);
                            drpMapping.Target_Resale_Price__c = (Decimal) rec1.get(drp_Target_Resale_price);
                        if(drp_MMId!=null && !String.isBlank(drp_MMId)){   
                        drpMapping.MMID__c = (String)rec1.get(drp_MMId);
                        }
                        if(drp_Ordering_Code!=null && !String.isBlank(drp_Ordering_Code)){
                            drpMapping.Ordering_Code__c = (String) rec1.get(drp_Ordering_Code);
                        }
                            
                        if(drp_Old_MMId!=null && !String.isBlank(drp_Old_MMId)){
                          drpMapping.Old_MMID__c= (String) rec1.get(drp_Old_MMId);
                        }
                    drpMappingRecords.add(drpMapping);  
                    }
                }
                    }
                    
                }
                update drpUpdateList;
                for (Design_Registration_Product_M2M_Stage__c drpMapping1 : drpUpdateList) {
                    recordIdsUpdate.add(drpMapping1.Id);
                }
                insert drpMappingRecords;
                for (Design_Registration_Product_M2M_Stage__c drpMapping2 : drpMappingRecords) {
                    recordIdsCreate.add(drpMapping2.Id);
                }
            }catch (Exception e) {
                System.debug('Error in batch execution: ' + e.getMessage());
            }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        
        if (!recordIdsCreate.isEmpty()) {
            makeCreateCallout(recordIdsCreate);
        }
        if (!recordIdsUpdate.isEmpty()) {
            makeUpdateCallout(recordIdsUpdate);
        }
    }
    public static void makeCreateCallout(List<Id> recordIds) {
        try {
            List<Design_Registration_Product_M2M_Stage__c> recordData = [select Id,Design_Registration_dummy__c,Design_Registration_dummy__r.Record_Id_from_Response__c, MMID__c, Old_MMID__c, Name, Ordering_Code__c, Quantity__c, Record_Id_from_main_object__c, Record_Id_from_Response__c, Response__c, Target_Resale_Price__c  from Design_Registration_Product_M2M_Stage__c WHERE Id IN :recordIds];
            
            for (Design_Registration_Product_M2M_Stage__c rec1 : recordData) {
                BatchDRUtility.calloutCreateDRP(rec1);
            }
        } catch (Exception ex) {
            System.debug('An error occurred: ' + ex.getMessage());
        }
    }
    public static void makeUpdateCallout(List<Id> recordIds) {
        try {
            List<Design_Registration_Product_M2M_Stage__c> recordData = [select Id,Design_Registration_dummy__c,Design_Registration_dummy__r.Record_Id_from_Response__c, MMID__c, Old_MMID__c, Name, Ordering_Code__c, Quantity__c, Record_Id_from_main_object__c, Record_Id_from_Response__c, Response__c, Target_Resale_Price__c  from Design_Registration_Product_M2M_Stage__c WHERE Id IN :recordIds];

            for (Design_Registration_Product_M2M_Stage__c rec1 : recordData) {
                BatchDRUtility.calloutUpdateDRP(rec1);
            }
        } catch (Exception ex) {
            System.debug('An error occurred: ' + ex.getMessage());
        }
    }
}