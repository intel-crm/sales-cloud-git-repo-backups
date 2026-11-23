public with sharing class Product_stageQueueableCloneP implements Queueable{
    public Integer count;
    public list<Core_Products_Staging__c> masterList = new list<Core_Products_Staging__c>();
    public Map<integer,string> vphProductNumberMap = new Map<integer,string>();
    public Boolean vplchInd ;
    public string ipaasId ;
    
    //declare metadata
    public Map<String,String> l5_VPH_fieldMappingTable = new Map<String,String>();    
    public Map<String, list<Core_Products_Staging__c>> l4VphMap = new Map<String, list<Core_Products_Staging__c>>();
    public Map<String,String> l5_VPLCH_fieldMappingTable = new Map<String,String>();
    public Map<String,String> l5_VPLCH_fieldMappingTable_oneLvlAvail = new Map<String,String>();
    public Map<String,String> l5_VPLCH_fieldMappingTable_twoLvlAvail = new Map<String,String>();
    public Map<String,String> l5_VPLCH_fieldMappingTable_threeLvlAvail = new Map<String,String>();
    public Map<String,String> l5_VPLCH_fieldMappingTable_fourLvlAvail = new Map<String,String>();
    //Pranjal
    public Map<String,String> FPH_fieldMappingTable_VPH = new Map<String,String>();  
    public Map<String,String> FPH_fieldMappingTable_VPLCH = new Map<String,String>();  
  
    
    public Product_stageQueueableCloneP(Integer i,list<Core_Products_Staging__c> masterListinb,Map<integer,string> numberMap, Boolean vplchInd, string ipaas){
        this.count = i;
        this.masterList = masterListinb ;
        this.vphProductNumberMap = numberMap ;
        this.vplchInd = vplchInd;
        this.ipaasId = ipaas;        
    }
    
    public void execute(QueueableContext context) {
        
        list<Product_Inbound_Staging__c> prdctInbList = new list<Product_Inbound_Staging__c>();        
        // get fields from metadata for L4 and L5 insertion -- Product_fields_mapping__mdt for both vph and vplch
        for (Product_fields_mapping__mdt  mappingRec : Product_fields_mapping__mdt.getall().Values()) {
            if (mappingRec.Inbound_staging_field__c != null && mappingRec.Product_staging_field__c != null && mappingRec.Type__c == 'Mapping' && mappingRec.Product_Org__c!='FPH') {          
                if(mappingRec.Hierarchy_ID__c == Product_Staging_StaticConstants.vphId){
                    l5_VPH_fieldMappingTable.put(mappingRec.Product_staging_field__c,mappingRec.Inbound_staging_field__c);                    
                }
                else if(mappingRec.Hierarchy_ID__c == Product_Staging_StaticConstants.vplchId){
                    if(mappingRec.MasterLabel.contains(Product_Staging_StaticConstants.vplchId)){
                        l5_VPLCH_fieldMappingTable.put(mappingRec.Product_staging_field__c,mappingRec.Inbound_staging_field__c);
                    }
                    if(mappingRec.Is_one_level_available__c == true){
                        l5_VPLCH_fieldMappingTable_oneLvlAvail.put(mappingRec.Product_staging_field__c,mappingRec.Inbound_staging_field__c);
                    }
                    if(mappingRec.Is_two_levels_available__c == true){
                        l5_VPLCH_fieldMappingTable_twoLvlAvail.put(mappingRec.Product_staging_field__c,mappingRec.Inbound_staging_field__c);
                    }
                    if(mappingRec.Is_three_levels_available__c == true){
                        l5_VPLCH_fieldMappingTable_threeLvlAvail.put(mappingRec.Product_staging_field__c,mappingRec.Inbound_staging_field__c);
                    }
                    if(mappingRec.Is_four_levels_available__c == true){
                        l5_VPLCH_fieldMappingTable_fourLvlAvail.put(mappingRec.Product_staging_field__c,mappingRec.Inbound_staging_field__c);
                    }
                }
            }
            //Pranjal
            else if(mappingRec.Inbound_staging_field__c != null && mappingRec.FPH_Field__c!=null && mappingRec.Type__c=='Mapping' && mappingRec.Product_Org__c=='FPH'){
                if(mappingRec.Hierarchy_ID__c == Product_Staging_StaticConstants.vphId){
                    FPH_fieldMappingTable_VPH.put(mappingRec.Product_staging_field__c,mappingRec.Inbound_staging_field__c);                    
                }
                if(mappingRec.Hierarchy_ID__c == Product_Staging_StaticConstants.vplchId){
                    FPH_fieldMappingTable_VPLCH.put(mappingRec.Product_staging_field__c,mappingRec.Inbound_staging_field__c);                    
                }
            }
        }    
        //add try catch 
            system.debug('The value of vplchInd'+vplchInd);
            system.debug('The value of ipaasId'+ipaasId);
            system.debug('The value of vphProductNumberMap'+vphProductNumberMap);
            system.debug('The value of masterList'+masterList);            
            if(vplchInd == false && vphProductNumberMap.containsKey(count)){
                String lvl_1_epmId = vphProductNumberMap.get(count);                
                prdctInbList=Database.query('SELECT '+String.join(Product_Utility.getProductInboundStagingFields(),',')+' FROM Product_Inbound_Staging__c WHERE  level_1_epm_id__c =: lvl_1_epmId  AND iPaaS_Load_ID__c =: ipaasId'); 
            }else if(vplchInd == true){
                String vplchId = Product_Staging_StaticConstants.vplchId;                
                prdctInbList=Database.query('SELECT '+String.join(Product_Utility.getProductInboundStagingFields(),',')+' FROM Product_Inbound_Staging__c WHERE Core_Hierarchy_ID__c =: vplchId AND iPaaS_Load_ID__c =: ipaasId');
            }
            system.debug('prdctInbList >>> '+prdctInbList);
            system.debug('prdctInbList size>>> '+prdctInbList.size());    
            list<Core_Products_Staging__c> StagingRecordsToInsert = new list<Core_Products_Staging__c>();           
            Core_Products_Staging__c stageRecord = new Core_Products_Staging__c();       
            //Pranjal
            Core_Products_Staging__c stageFPHRecord = new Core_Products_Staging__c();       
            if(!prdctInbList.isEmpty() && prdctInbList != null ){
                for(Product_Inbound_Staging__c productLevel : prdctInbList){ 
                    if(productLevel != null){
                        /*stageRecord = product_utility.processInbStgngMapng(productLevel,
                                                                       l5_VPH_fieldMappingTable,
                                                                       l5_VPLCH_fieldMappingTable,                                                                       
                                                                       l5_VPLCH_fieldMappingTable_oneLvlAvail,
                                                                       l5_VPLCH_fieldMappingTable_twoLvlAvail,
                                                                       l5_VPLCH_fieldMappingTable_threeLvlAvail,
                                                                       l5_VPLCH_fieldMappingTable_fourLvlAvail);*/
                        //pranjal
                     stageFPHRecord = Product_Utility.processInbStngFPHRecords(productLevel,FPH_fieldMappingTable_VPH,FPH_fieldMappingTable_VPLCH);  
                        // Level 4 Map 
                        if(String.isNotBlank(productLevel.level_4_epm_id__c)){
                            if(l4VphMap.keyset().contains(productLevel.level_4_epm_id__c)){                         
                                list<Core_Products_Staging__c> l5TempList = l4VphMap.get(productLevel.level_4_epm_id__c);                         
                                l5TempList.add(stageRecord);
                                l4VphMap.put(productLevel.level_4_epm_id__c, l5TempList); 
                            }
                            else{ 
                                l4VphMap.put(productLevel.level_4_epm_id__c, new List<Core_Products_Staging__c>{stageRecord} )  ;
                            }
                        }
                        //StagingRecordsToInsert.add(stageRecord);
                        StagingRecordsToInsert.add(stageFPHRecord);
                    }                    
                }
                system.debug('Vph Level 4 Map is'+l4VphMap);
            }     
            
            if (!l4VphMap.isEmpty() && !vplchInd) {
                //List<Core_Products_Staging__c> l4Records = Product_Utility.createLevelDatawithRollupSales(l4VphMap,'Core_Product_Group_EPM_ID__c','43');
               // system.debug('l4records '+l4Records);
               // if (!l4Records.isEmpty()) {
                   // StagingRecordsToInsert.addAll(l4Records);
               // }
            }
            if(!StagingRecordsToInsert.isEmpty() && StagingRecordsToInsert != null){
                masterList.addall(StagingRecordsToInsert);
            }
        
        // End Logic - This is after completion of roll up
        System.debug('count is '+count); 
        System.debug('vphProductNumberMap size is >>>>> '+vphProductNumberMap.keySet().size());
        
        count = count +1;
        if(count <= vphProductNumberMap.keySet().size()){
            System.debug('queueable about to execute >>>'+count);
            System.enqueueJob(new Product_stageQueueableCloneP(count,masterList,vphProductNumberMap,vplchInd,ipaasId));
            
        }
        else if(count > vphProductNumberMap.keySet().size() && vplchInd == false ){
            vplchInd = true;
            System.debug('queueable for VPLCH about to execute and vplchInd ind is >>>'+vplchInd);
            System.enqueueJob(new Product_stageQueueableCloneP(count,masterList,vphProductNumberMap,vplchInd,ipaasId));
        }
        else if(vplchInd == true){
            System.debug('masterList >>> '+masterList);
            System.debug('masterList size >>> '+masterList.size());
            System.debug('batch about to execute and vplchInd ind is >>>'+vplchInd);                        
            Database.executeBatch(new Product_insStgngRcrdsBatch(masterList),2000);            
        }       

    }   
}