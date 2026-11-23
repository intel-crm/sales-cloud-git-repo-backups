public class Vivek_testProd {
	
    public Integer count = 1;
    public list<Core_Products_Staging__c> masterList = new list<Core_Products_Staging__c>();  
    map<integer,string> vphProductNumberMap = new map<integer,string>{1=>'98836'};
    public Boolean vplchInd = false;
    public string ipaasId ='76543';
    
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
    public Set<String> opnIDs = new Set<String>();
    public integer loopCount = 0;
    public list<Core_Products_Staging__c> inbMasterList = new  list<Core_Products_Staging__c>();
   
    public string exec(){
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
                   
            if(vplchInd == false && vphProductNumberMap.containsKey(count)){
                String lvl_1_epmId = vphProductNumberMap.get(count);
                /*Deactivation Logic - Based on OPN */
                if(vphProductNumberMap.get(count) == epm_FPGA){
					isFPGA = true;
				}              
                //prdctInbList=Database.query('SELECT '+String.join(Product_Utility.getObjectFields('Product_Inbound_Staging__c'),',')+' FROM Product_Inbound_Staging__c WHERE  level_1_epm_id__c =: lvl_1_epmId  AND iPaaS_Load_ID__c =: ipaasId'); 
                prdctInbList=Database.query('SELECT '+String.join(Product_Utility.getObjectFields('Product_Inbound_Staging__c'),',')+' FROM Product_Inbound_Staging__c LIMIT 40000'); 
            }else if(vplchInd == true){
                String vplchId = Product_Staging_StaticConstants.vplchId;                
                //prdctInbList=Database.query('SELECT '+String.join(Product_Utility.getObjectFields('Product_Inbound_Staging__c'),',')+' FROM Product_Inbound_Staging__c WHERE Core_Hierarchy_ID__c =: vplchId AND iPaaS_Load_ID__c =: ipaasId');
                prdctInbList=Database.query('SELECT '+String.join(Product_Utility.getObjectFields('Product_Inbound_Staging__c'),',')+' FROM Product_Inbound_Staging__c WHERE Core_Hierarchy_ID__c =: vplchId AND iPaaS_Load_ID__c =: ipaasId LIMIT 40000');
            }
            system.debug('prdctInbList >>> '+prdctInbList);
            system.debug('prdctInbList size>>> '+prdctInbList.size());    
            list<Core_Products_Staging__c> StagingRecordsToInsert = new list<Core_Products_Staging__c>();           
            Core_Products_Staging__c stageRecord = new Core_Products_Staging__c();     
            //Pranjal
            Core_Products_Staging__c stageFPHRecord = new Core_Products_Staging__c(); 

            Core_Products_Staging__c stageIPSRecord = new Core_Products_Staging__c();

            List<Product_Inbound_Staging__c> l4WoL5List = new List<Product_Inbound_Staging__c>();      
            if(!prdctInbList.isEmpty() && prdctInbList != null ){
                for(Product_Inbound_Staging__c productLevel : prdctInbList){ 
                    loopCount +=1;
                    if(productLevel != null){
                        stageRecord = product_utility.processInbStgngMapng(productLevel);
			
                        /*OPN Deactivation START - Get OPN Ids of VPH FPGA Records*/                        
                        if(isFPGA){
                            String vph_opn = stageRecord.Core_OPN__c != null ? stageRecord.Core_OPN__c : ''; //(String)stageRecord.get(opnField) ? Product_Utility.getOPN((String)stageRecord.get(opnField)) : '';
                            //System.debug('OPN=='+vph_opn);
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
                     /*   if(!isFPGA && stageRecord.Core_Product_Status__c != null){
                            if(Product_Utility.checkCommonValues(stageRecord.Core_Product_Status__c) == true) {
                                stageRecord.Core_IsActive__c = false;   
                            }
                        }   */                    
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
                        StagingRecordsToInsert.add(stageRecord);
                        //Pranjal
                        StagingRecordsToInsert.add(stageFPHRecord);

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

                            StagingRecordsToInsert.add(stageIPSRecord);
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

                            StagingRecordsToInsert.add(stageIPSRecord);
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

                            StagingRecordsToInsert.add(stageIPSRecord);
                        }
                        // IPS - End
                    }                    
                }
                system.debug('Vph Level 4 Map is'+l4VphMap);
            }     
            
            if (!l4VphMap.isEmpty() && !vplchInd) {
                List<Core_Products_Staging__c> l4Records = Product_Utility.createLevelDatawithRollupSales(l4VphMap,'Core_Product_Group_EPM_ID__c','43',l4WoL5List);
                system.debug('l4records '+l4Records);
                if (!l4Records.isEmpty()) {
                    StagingRecordsToInsert.addAll(l4Records);
                }
            }

            if (!l4VphMapIPS.isEmpty()) {
                List<Core_Products_Staging__c> ipsRecsWithL5 = Product_Utility.createLevelDatawithRollupIPS(l4VphMapIPS,4,vplchInd ? '59':'43');
                if (!ipsRecsWithL5.isEmpty()) {
                    StagingRecordsToInsert.addAll(ipsRecsWithL5);
                }
            }

            if (!l3VphMapIPS.isEmpty()) {
                List<Core_Products_Staging__c> ipsRecsWithL4 = Product_Utility.createLevelDatawithRollupIPS(l4VphMapIPS,3,vplchInd ? '59':'43');
                if (!ipsRecsWithL4.isEmpty()) {
                    StagingRecordsToInsert.addAll(ipsRecsWithL4);
                }
            }

            if (!l2VphMapIPS.isEmpty()) {
                List<Core_Products_Staging__c> ipsRecsWithL3 = Product_Utility.createLevelDatawithRollupIPS(l4VphMapIPS,2,vplchInd ? '59':'43');
                if (!ipsRecsWithL3.isEmpty()) {
                    StagingRecordsToInsert.addAll(ipsRecsWithL3);
                }
            }

            if(!StagingRecordsToInsert.isEmpty() && StagingRecordsToInsert != null){
                masterList.addall(StagingRecordsToInsert);
            }
        
        // End Logic - This is after completion of roll up
        System.debug('count is '+count); 
        System.debug('vphProductNumberMap size is >>>>> '+vphProductNumberMap.keySet().size());
        
        count = count +1;
		
        system.debug('loopCount-> '+loopCount);
		system.debug(count);
		system.debug(masterList);
		system.debug(vphProductNumberMap);
		system.debug(vplchInd);
		system.debug(ipaasId);  
		//system.debug(opnIDs);      
        return '';
    }
        
   
                
        
}