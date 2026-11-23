public with sharing class Product_stageQueueable_Parent implements Queueable{
    public Integer count;
    public list<Core_Products_Staging__c> masterList = new list<Core_Products_Staging__c>();
    public list<Core_Products_Staging__c> dummymasterList = new list<Core_Products_Staging__c>();

    public Map<integer,string> vphProductNumberMap = new Map<integer,string>();
    public Boolean vplchInd ;
    public string ipaasId ;
    public Set<String> opnIDs = new Set<String>();
    public Boolean bypass;
    
    //declare metadata
    public Map<String, list<Core_Products_Staging__c>> l4VphMap = new Map<String, list<Core_Products_Staging__c>>();
    public Map<String, list<Core_Products_Staging__c>> l4VphMapIPS = new Map<String, list<Core_Products_Staging__c>>();
    public Map<String, list<Core_Products_Staging__c>> l3VphMapIPS = new Map<String, list<Core_Products_Staging__c>>();
    public Map<String, list<Core_Products_Staging__c>> l2VphMapIPS = new Map<String, list<Core_Products_Staging__c>>();    
    //Pranjal
    public Map<String,String> FPH_fieldMappingTable_VPH = new Map<String,String>();  
    public Map<String,String> FPH_fieldMappingTable_VPLCH = new Map<String,String>();  
    //OPN Deactivation
    public String epm_FPGA = Product_Staging_StaticConstants.FPGA_EPMId;
    public String opnField = Product_Staging_StaticConstants.OPN_FieldName;	
	public boolean isFPGA = false;	    
    
    public Product_stageQueueable_Parent(Integer i,list<Core_Products_Staging__c> masterListinb,Map<integer,string> numberMap, Boolean vplchInd, string ipaas, Set<String> opnLst, Boolean bypass){
        this.count = i;
        this.masterList = masterListinb ;
        this.vphProductNumberMap = numberMap ;
        this.vplchInd = vplchInd;
        this.ipaasId = ipaas;  
        this.opnIDs = opnLst;  
        this.bypass = bypass;
    }
    
    public void execute(QueueableContext context) {
                
        list<Product_Inbound_Staging__c> prdctInbList = new list<Product_Inbound_Staging__c>();        
        // get fields from metadata for L5 insertion -- Product_fields_mapping__mdt for both vph and vplch
        for (Product_fields_mapping__mdt  mappingRec : Product_fields_mapping__mdt.getall().Values()) {            
            //Pranjal
            if(mappingRec.Inbound_staging_field__c != null && mappingRec.FPH_Field__c!=null && mappingRec.Type__c=='Mapping' && mappingRec.Product_Org__c=='FPH'){
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
            system.debug('The size of masterList'+masterList.size());
            system.debug('The product name is '+vphProductNumberMap.get(count));   
            system.debug('Begin operation  - The used heap size is >>>'+Limits.getHeapSize());
            system.debug('Begin operation  - The heap Limit is >>>'+Limits.getLimitHeapSize());

            list<Core_Products_Staging__c> StagingRecordsToInsert = new list<Core_Products_Staging__c>();           
            Core_Products_Staging__c stageRecord = new Core_Products_Staging__c();     
            //Pranjal
            Core_Products_Staging__c stageFPHRecord = new Core_Products_Staging__c(); 

            Core_Products_Staging__c stageIPSRecord = new Core_Products_Staging__c();

            List<Product_Inbound_Staging__c> l4WoL5List = new List<Product_Inbound_Staging__c>();
            if(vplchInd == false && vphProductNumberMap.containsKey(count)){
                String lvl_1_epmId = vphProductNumberMap.get(count);
                /*Deactivation Logic - Based on OPN */
                if(vphProductNumberMap.get(count) == epm_FPGA){
					isFPGA = true;
				}    
                for(Product_Inbound_Staging__c productLevel: Database.query('SELECT '+String.join(Product_Utility.getObjectFields('Product_Inbound_Staging__c'),',')+' FROM Product_Inbound_Staging__c WHERE  level_1_epm_id__c =: lvl_1_epmId  AND iPaaS_Load_ID__c =: ipaasId limit 5000' )){
                    //prdctInbList.add(productLevel);
                    // direct processing
                    stageRecord = product_utility.processInbStgngMapng(productLevel);
                    /*OPN Deactivation START - Get OPN Ids of VPH FPGA Records*/                        
                    if(isFPGA){
                        String vph_opn = stageRecord.Core_OPN__c != null ? stageRecord.Core_OPN__c : ''; //(String)stageRecord.get(opnField) ? Product_Utility.getOPN((String)stageRecord.get(opnField)) : '';
                        System.debug('OPN=='+vph_opn);
                        if(String.isNotBlank(vph_opn)) { opnIDs.add(vph_opn);}                                                       
                    }//endIF FPGA
                    if(vplchInd && (stageRecord.get('Core_Product_Type__c') == epm_FPGA)){
                        String vplch_opn = stageRecord.Core_OPN__c != null ? stageRecord.Core_OPN__c : '';
                        //String vplch_opn = (String)stageRecord.get(opnField) ? Product_Utility.getOPN((String)stageRecord.get(opnField)) : '';
                        if(String.isNotBlank(vplch_opn) && opnIDs.contains(vplch_opn)){
                            stageRecord.Core_IsActive__c=false;   
                        }
                    }                        
                    /*OPN Deactivation END */
                    /* Deactivation based on product status */                         
                    if(!isFPGA && stageRecord.Core_Product_Status__c != null){
                        if(Product_Utility.getProductStatus(stageRecord.Core_Product_Status__c,Label.Product_Non_FPGA_Status_Values) == true) {
                            stageRecord.Core_IsActive__c = false;   
                        }
                    }                       
                    else if(isFPGA && stageRecord.Core_Product_Status__c != null){
                        if(Product_Utility.getProductStatus(stageRecord.Core_Product_Status__c,Label.Product_FPGA_Status_Values) == true) {
                            stageRecord.Core_IsActive__c = false;   
                        }
                    }
                    /* end */
                        //pranjal                        
                    stageFPHRecord = Product_Utility.processInbStngFPHRecords(productLevel,FPH_fieldMappingTable_VPH,FPH_fieldMappingTable_VPLCH); 
                    // Level 4 Map 
                    if(String.isNotBlank(productLevel.level_5_epm_id__c)){
                        if(l4VphMap.keyset().contains(productLevel.level_4_epm_id__c)){                         
                            list<Core_Products_Staging__c> l5TempList = l4VphMap.get(productLevel.level_4_epm_id__c);                         
                            l5TempList.add(stageRecord);
                            l4VphMap.put(productLevel.level_4_epm_id__c, l5TempList); 
                        }
                        else{ 
                            l4VphMap.put(productLevel.level_4_epm_id__c, new List<Core_Products_Staging__c>{stageRecord} );
                        }
                    }
                    else if(String.isNotBlank(productLevel.level_4_epm_id__c)){
                        l4WoL5List.add(productLevel);
                    }
                    masterList.add(stageRecord);
                    //Pranjal
                    masterList.add(stageFPHRecord);

                    // IPS - Start
                    
                    // Level 4 Map - IPS
                    if(String.isNotBlank(productLevel.level_5_epm_id__c)){
                        stageIPSRecord = Product_Utility.processInbStngIPSRecords(productLevel,FPH_fieldMappingTable_VPH,FPH_fieldMappingTable_VPLCH,5);  
                        if(l4VphMapIPS.containsKey(productLevel.level_4_epm_id__c)){                         
                            list<Core_Products_Staging__c> l5TempListIPS = l4VphMapIPS.get(productLevel.level_4_epm_id__c);                         
                            l5TempListIPS.add(stageIPSRecord);
                            l4VphMapIPS.put(productLevel.level_4_epm_id__c, l5TempListIPS); 
                        }
                        else{ 
                            l4VphMapIPS.put(productLevel.level_4_epm_id__c, new List<Core_Products_Staging__c>{stageIPSRecord} )  ;
                        }

                        masterList.add(stageIPSRecord);
                    }
                    else  if(String.isNotBlank(productLevel.level_4_epm_id__c)){
                        stageIPSRecord = Product_Utility.processInbStngIPSRecords(productLevel,FPH_fieldMappingTable_VPH,FPH_fieldMappingTable_VPLCH,4);  
                        if(l3VphMapIPS.containsKey(productLevel.level_3_epm_id__c)){                         
                            list<Core_Products_Staging__c> l4TempListIPS = l3VphMapIPS.get(productLevel.level_3_epm_id__c);                         
                            l4TempListIPS.add(stageIPSRecord);
                            l3VphMapIPS.put(productLevel.level_3_epm_id__c, l4TempListIPS); 
                        }
                        else{ 
                            l3VphMapIPS.put(productLevel.level_3_epm_id__c, new List<Core_Products_Staging__c>{stageIPSRecord} )  ;
                        }

                        masterList.add(stageIPSRecord);
                    }
                    else  if(String.isNotBlank(productLevel.level_3_epm_id__c)){
                        stageIPSRecord = Product_Utility.processInbStngIPSRecords(productLevel,FPH_fieldMappingTable_VPH,FPH_fieldMappingTable_VPLCH,3);  
                        if(l2VphMapIPS.containsKey(productLevel.level_2_epm_id__c)){                         
                            list<Core_Products_Staging__c> l3TempListIPS = l2VphMapIPS.get(productLevel.level_2_epm_id__c);                         
                            l3TempListIPS.add(stageIPSRecord);
                            l2VphMapIPS.put(productLevel.level_2_epm_id__c, l3TempListIPS); 
                        }
                        else{ 
                            l2VphMapIPS.put(productLevel.level_2_epm_id__c, new List<Core_Products_Staging__c>{stageIPSRecord} )  ;
                        }

                        masterList.add(stageIPSRecord);
                    }
                }          
                //prdctInbList=Database.query('SELECT '+String.join(Product_Utility.getObjectFields('Product_Inbound_Staging__c'),',')+' FROM Product_Inbound_Staging__c WHERE  level_1_epm_id__c =: lvl_1_epmId  AND iPaaS_Load_ID__c =: ipaasId'); 
            }else if(vplchInd == true){
                String vplchId = Product_Staging_StaticConstants.vplchId;         
                for(Product_Inbound_Staging__c productLevel: Database.query('SELECT '+String.join(Product_Utility.getObjectFields('Product_Inbound_Staging__c'),',')+' FROM Product_Inbound_Staging__c WHERE Core_Hierarchy_ID__c =: vplchId AND iPaaS_Load_ID__c =: ipaasId')){
                    //prdctInbList.add(productLevel);
                }       
                //prdctInbList=Database.query('SELECT '+String.join(Product_Utility.getObjectFields('Product_Inbound_Staging__c'),',')+' FROM Product_Inbound_Staging__c WHERE Core_Hierarchy_ID__c =: vplchId AND iPaaS_Load_ID__c =: ipaasId');
            }
                        
            if (!l4VphMap.isEmpty() && !vplchInd) {
                List<Core_Products_Staging__c> l4Records = Product_Utility.createLevelDatawithRollupSales(l4VphMap,'Core_Product_Group_EPM_ID__c','43',l4WoL5List);
                system.debug('l4records '+l4Records);
                if (!l4Records.isEmpty()) {
                    masterList.addAll(l4Records);
                }
            }

            if (!l4VphMapIPS.isEmpty()) {
                List<Core_Products_Staging__c> ipsRecsWithL5 = Product_Utility.createLevelDatawithRollupIPS(l4VphMapIPS,4,vplchInd ? '59':'43');
                if (!ipsRecsWithL5.isEmpty()) {
                    masterList.addAll(ipsRecsWithL5);
                }
            }

            if (!l3VphMapIPS.isEmpty()) {
                List<Core_Products_Staging__c> ipsRecsWithL4 = Product_Utility.createLevelDatawithRollupIPS(l4VphMapIPS,3,vplchInd ? '59':'43');
                if (!ipsRecsWithL4.isEmpty()) {
                    masterList.addAll(ipsRecsWithL4);
                }
            }

            if (!l2VphMapIPS.isEmpty()) {
                List<Core_Products_Staging__c> ipsRecsWithL3 = Product_Utility.createLevelDatawithRollupIPS(l4VphMapIPS,2,vplchInd ? '59':'43');
                if (!ipsRecsWithL3.isEmpty()) {
                    masterList.addAll(ipsRecsWithL3);
                }
            }


        // End Logic - This is after completion of roll up
        System.debug('count is '+count); 
        System.debug('vphProductNumberMap size is >>>>> '+vphProductNumberMap.keySet().size());
        System.debug('After All operation  - The used heap size is >>>'+Limits.getHeapSize());
        System.debug('After All operation  - The heap Limit is >>>'+Limits.getLimitHeapSize());
        
        System.debug('masterList size ---- '+masterList.size());
        // Directly Insert in staging object
        /*
        if(masterList.size() < 10000){
            Database.insert(masterList,false);            
        }else{
            //Database.executeBatch(new Product_insStgngRcrdsBatch_2(masterList,vphProductNumberMap,vplchInd,ipaasId,opnIDs),2000);            
            Database.executeBatch(new Product_insStgngRcrdsBatch_2(masterList,ipaasId),2000);            
        } */
        //Directly Insert into staging
        if(masterList.size() < 5000){
            bypass = false;
            System.debug('bypass value when masterlist size is --- '+ masterList.size() +'  ' +bypass);
            //Database.insert(masterList,false);
        }
        else{
            bypass = true;
            System.debug('bypass value when masterlist size is --- '+ masterList.size() +'  ' +bypass);
            //Database.executeBatch(new Product_insStgngRcrdsBatch_2(count,masterList,vphProductNumberMap,vplchInd,ipaasId,opnIDs),2000);
            Database.executeBatch(new Product_insStgngRcrdsBatch_2(masterList,ipaasId,bypass,count),2000);      
        }

        masterList.clear();
        system.debug('The flow still continues of first queuable');
        count = count +1;
        if(count <= vphProductNumberMap.keySet().size() && bypass == false){
            System.debug('queueable about to execute >>>'+count);
            System.debug('The Name of next product is '+vphProductNumberMap.get(count));  
            System.enqueueJob(new Product_stageQueueable_Parent(count,masterList,vphProductNumberMap,vplchInd,ipaasId,opnIDs,bypass));
        }
        else if(count > vphProductNumberMap.keySet().size() && vplchInd == false && bypass == false){
            vplchInd = true;
            System.debug('queueable for VPLCH about to execute and vplchInd ind is >>>'+vplchInd);
            System.enqueueJob(new Product_stageQueueable_Parent(count,masterList,vphProductNumberMap,vplchInd,ipaasId,opnIDs,bypass));
        }
        else if(vplchInd == true && bypass == false){
            System.debug('masterList >>> '+masterList);
            System.debug('masterList size >>> '+masterList.size());
            System.debug('batch about to execute and vplchInd ind is >>>'+vplchInd);  
            //Database.executeBatch(new Product_upsertProduct3Records(ipaasId),2000);                      
        }       
    }   
}