public with sharing class CSF_Product_stageQueueable implements Queueable{
    public Integer count;
    public list<Core_Products_Staging__c> masterList = new list<Core_Products_Staging__c>();
    public list<Core_Products_Staging__c> masterList2 = new list<Core_Products_Staging__c>();
    
    
    public Map<integer,Product_ProcessInboundStagingRecords.InputWrapper> inputWrapperMap = new Map<integer,Product_ProcessInboundStagingRecords.InputWrapper>();
    public Boolean vplchInd ;
    public string ipaasId ;
    public Set<String> opnIDs = new Set<String>();
    public boolean bypass;
    public Integer dmlCount = 0; 
    //added
    public Integer dmlCount2 = 0;
    public string query;
    public static String lvl_1_epmId;
    public set<string> level2ids = new set<string>();
    public set<string> level1VplchIds = new set<string>();
    public Integer heapLimit = Integer.valueOf(Label.Product_HeapLimit);
    
    //declare metadata
    public static Map<String, list<Product_Inbound_Staging__c>> l4VphMap = new Map<String, list<Product_Inbound_Staging__c>>();
    public static Map<String, list<Core_Products_Staging__c>> l4VphMapIPS = new Map<String, list<Core_Products_Staging__c>>();
    public static Map<String, list<Core_Products_Staging__c>> l3VphMapIPS = new Map<String, list<Core_Products_Staging__c>>();
    public static Map<String, list<Core_Products_Staging__c>> l2VphMapIPS = new Map<String, list<Core_Products_Staging__c>>();
    public static Map<String, list<Core_Products_Staging__c>> l1VphMapIPS = new Map<String, list<Core_Products_Staging__c>>();  
    //OPN Deactivation
    public static String epm_FPGA = Product_Staging_StaticConstants.FPGA_EPMId;
    public static String opnField = Product_Staging_StaticConstants.OPN_FieldName;	
    public boolean isFPGA = false;	
    public static String vplchId = Product_Staging_StaticConstants.vplchId;
    public static DateTime startQTime;
    public static DateTime endQTime;
    public static Integer elapsedQTime;
    public static String opnDeactivation= Product_Staging_StaticConstants.OPN_Deactivation;
    public static String statusDeactivation= Product_Staging_StaticConstants.Status_Deactivation;
    
    // Product plug-in/out and visibility flags
    Map<String,Product_fields_mapping__mdt> salesConfigMap = Product_Utility.getSalesConfigurationMap();
    Map<String,Product_fields_mapping__mdt> ipsConfigMap = Product_Utility.getIPSConfigurationMap();
    
    public CSF_Product_stageQueueable(Integer i,list<Core_Products_Staging__c> masterListinb,Map<Integer,Product_ProcessInboundStagingRecords.InputWrapper> inputWrapperMap, Boolean vplchInd, string ipaas, Set<String> opnLst){
        this.count = i;
        this.masterList = masterListinb ;
        this.inputWrapperMap = inputWrapperMap ;
        this.vplchInd = inputWrapperMap.get(count).vplchInd;
        this.ipaasId = ipaas;  
        this.opnIDs = opnLst;          
    }
    
    public void execute(QueueableContext context) {
        //try catch block
        try{
            //for analysis
            Heap_Analysis__c hp = new Heap_Analysis__c();
            hp.Class_Name__c = 'Product_stageQueueable';
            hp.iPaaS_Load_ID__c = ipaasId;
            hp.Product_Name__c = String.valueOf(inputWrapperMap.get(count));
            hp.Q_Number__c = count;
            hp.Start_Time__c = system.now();
            startQTime = system.now();
            Integer recordCount = 0;
            
            List<Product_Inbound_Staging__c> l4WoL5List = new List<Product_Inbound_Staging__c>();        
            Product_ProcessInboundStagingRecords.InputWrapper input  = inputWrapperMap.get(count);        
            bypass = false;
            Product_fields_mapping__mdt level5Config;
            Product_fields_mapping__mdt level4Config; 
            //for analysis     
            hp.After_Mapping_CPU_Time__c = Limits.getCpuTime();
            hp.After_Mapping_Heap_Size__c = Limits.getHeapSize();        
            
            if(vplchInd == false && inputWrapperMap.containsKey(count)){
                //Deactivation Logic - Based on OPN
                if(input.level1EPMId == epm_FPGA){
                    isFPGA = true;
                }    
                if(input.atLevel2){
                    level2ids = inputWrapperMap.get(count).level2EPMIds;
                    query = 'SELECT '+String.join(Product_Utility.getObjectFields('Product_Inbound_Staging__c'),',')+' FROM Product_Inbound_Staging__c WHERE  level_2_epm_id__c in: level2Ids  AND iPaaS_Load_ID__c =: ipaasId ';
                }else{
                    lvl_1_epmId = input.level1EPMId;
                    query = 'SELECT '+String.join(Product_Utility.getObjectFields('Product_Inbound_Staging__c'),',')+' FROM Product_Inbound_Staging__c WHERE  level_1_epm_id__c =: lvl_1_epmId  AND iPaaS_Load_ID__c =: ipaasId';
                }
                
                level5Config = salesConfigMap.get('5;43;'+input.level1EPMId);
                level4Config = salesConfigMap.get('4;43;'+input.level1EPMId);
                
            }else if(vplchInd == true){  
                level1VplchIds = inputWrapperMap.get(count).level1VplchEPMIds;
                query = 'SELECT '+String.join(Product_Utility.getObjectFields('Product_Inbound_Staging__c'),',')+' FROM Product_Inbound_Staging__c WHERE Core_Hierarchy_ID__c =: vplchId AND iPaaS_Load_ID__c =: ipaasId  and level_1_epm_id__c in: level1VplchIds ';     
            }       
            
            //-------------------------------------- Sales Starts ---------------------------------------------------------------
            for(Product_Inbound_Staging__c productLevel: Database.query(query)){                    
                recordCount ++ ;
                Core_Products_Staging__c stageRecord = new Core_Products_Staging__c();
                stageRecord = Product_utility.processInbStgngMapng(productLevel,level5Config);
                
                //OPN Deactivation START - Get OPN Ids of VPH FPGA Records                        
                if(isFPGA){
                    String vph_opn = stageRecord.Core_OPN__c != null ? stageRecord.Core_OPN__c : ''; 
                    if(String.isNotBlank(vph_opn)) { opnIDs.add(vph_opn);}                                                       
                }//endIF FPGA
                if(vplchInd && (stageRecord.get('Core_Product_Type_EPM_ID__c') == epm_FPGA)){
                    String vplch_opn = stageRecord.Core_OPN__c != null ? stageRecord.Core_OPN__c : '';
                    if(String.isNotBlank(vplch_opn) && opnIDs.contains(vplch_opn)){
                        stageRecord.Core_IsActive__c=false;                   
                        stageRecord.core_Logging_Type__c ='OPN_Deactivation';
                    } 
                }                        
                //OPN Deactivation END 
                //new method callout for product status based deactivation  
                if(stageRecord!= null && stageRecord.Core_Product_Status__c != null){
                    if(Product_Utility.IsProductDeactivated(isFPGA,stageRecord.Core_Product_Status__c) == false){
                        stageRecord.Core_IsActive__c = false;
                        stageRecord.core_Logging_Type__c ='Status_Deactivation';                              
                    }
                }
                // end
                
                // Level 4 Map 
                if(productLevel != null && String.isNotBlank(productLevel.level_5_epm_id__c)){
                    if(l4VphMap.keyset().contains(productLevel.level_4_epm_id__c)){                         
                        list<Product_Inbound_Staging__c> l5TempList = l4VphMap.get(productLevel.level_4_epm_id__c);                         
                        l5TempList.add(productLevel);
                        l4VphMap.put(productLevel.level_4_epm_id__c, l5TempList); 
                    }
                    else{ 
                        l4VphMap.put(productLevel.level_4_epm_id__c, new List<Product_Inbound_Staging__c>{productLevel} );
                    }
                }
                else {
                    l4WoL5List.add(productLevel);
                }
                
                if ((vplchInd && !Product_Staging_StaticConstants.vplchSalesFilter.contains(stageRecord.Core_Product_Type_EPM_ID__c) )  ||  (level5Config != null && level5Config.Active__c && !vplchInd) ){
                    if (vplchInd || String.isNotBlank(stageRecord.Core_Item_Id__c) || (String.isBlank(productLevel.L5_mmid__c) && level5Config != null && level5Config.Allow_empty_MMID_records__c)) {
                        if(masterList.size() > 9995){
                            masterList2.add(stageRecord);
                        }
                        else{
                            masterlist.add(stageRecord);
                        }
                    }
                }        
            }
            
            
            hp.After_Sales_Heap_Size__c=Limits.getHeapSize();
            hp.After_Sales_CPU_Time__c=Limits.getCpuTime();
            if(Limits.getHeapSize() > heapLimit && !masterList.isEmpty()){
                dmlCount2 = masterList.size();
                Database.insert(masterList,false);
                masterList.clear();            
            }
            //new split fph
            //--------------------------------------- FPH starts------------------------------------------------------------- 
            for(Product_Inbound_Staging__c productLevel: Database.query(query)){
                Core_Products_Staging__c stageFPHRecord = new Core_Products_Staging__c();            
                //pranjal                        
                stageFPHRecord = Product_Utility.processInbStngFPHRecords(productLevel); 
                
                if(!vplchInd  || ( vplchInd && !Product_Staging_StaticConstants.vplchIpsFilter.contains(stageFPHRecord.Core_L3_EPM_ID__c ))){
                    if(masterList.size() + dmlCount2 > 9995){
                        masterList2.add(stageFPHRecord);
                    }
                    else{
                        masterlist.add(stageFPHRecord);
                    }
                }             
            }
            //-------------------------------------- FPH ends----------------------------------------------------------------            
            
            hp.After_FPH_Heap_Size__c=Limits.getHeapSize();
            hp.After_FPH_CPU_Time__c=Limits.getCpuTime();
            
            // Sales Rollup - Level 4
            if (!vplchInd  && level4Config != null && level4Config.Active__c ) {
                List<Core_Products_Staging__c> l4Records = Product_Utility.createLevelDatawithRollupSales(l4VphMap,'Core_Product_Group_EPM_ID__c','43',l4WoL5List,level4Config);
                if (!l4Records.isEmpty()) {
                    if(masterList.size()+ dmlCount2 + l4Records.size() > 9995){
                        masterList2.addall(l4Records);
                    }
                    else{
                        masterlist.addall(l4Records);
                    }            
                }
            }
            // End Logic - This is after completion of roll up
            
            // for analysis
            hp.After_Sales_And_FPH_Heap_Size__c = Limits.getHeapSize();
            hp.After_Sales_And_FPH_CPU_Time__c = Limits.getCpuTime();
            
            // Directly Insert in staging object
            if(!masterList.isEmpty()){
                Database.insert(masterList,false);        
                dmlCount = masterList.size();
            }          
            
            masterList.clear();
            l4WoL5List.clear() ;
            l4VphMap.clear();  
            //----------------------------------------- Sales & FPH Ends --------------------------------------------------------------        
            List<Core_Products_Staging__c> masterList3=processIPSVPHRecords(vplchInd,query,ipsConfigMap);
            List<Core_Products_Staging__c> masterList4=processIPSVPLCHRecords(vplchInd,query,ipsConfigMap);

            if(!masterList2.isEmpty()){
                masterList.addAll(masterList2);
                masterList2.clear(); 
            }

            if(!masterList3.isEmpty()){
                masterList.addAll(masterList3);
                masterList3.clear(); 
            }

            if(!masterList4.isEmpty()){
                masterList.addAll(masterList4);
                masterList4.clear(); 
            }
            
            // for analysis
            hp.After_IPS_Heap_Size__c = Limits.getHeapSize();
            hp.After_IPS_CPU_Time__c = Limits.getCpuTime();
            hp.Output_Record_Count__c =  dmlcount + masterList.size() + dmlCount2;
            // DML Operation  
            if(dmlcount + masterList.size() + dmlCount2  < 9995){            
                // Upsertion based on Unique_Value__c for Core_Products_Staging__c records
                Database.insert(masterList,false);
            }else{
                bypass = true;
                Database.executeBatch(new Product_insStgngRcrdsBatch(count,masterList,inputWrapperMap,vplchInd,ipaasId,opnIDs),1000);            
            }
            masterList.clear();
            
            count = count +1;
            // capture time
            endQTime = System.now();        
            elapsedQTime = endQTime.millisecond()-startQTime.millisecond();    
            hp.Record_Count__c = recordCount;
            hp.End_Time__c = system.now();
            hp.Elapsed_Time__c = Math.abs(elapsedQTime);
            insert hp;
            
            if(count <=  inputWrapperMap.keySet().size() && bypass == false){  
                if(!Test.isRunningTest()){
                    System.enqueueJob(new Product_stageQueueable(count,masterList,inputWrapperMap,vplchInd,ipaasId,opnIDs));
                }            
            }
            else if(count >  inputWrapperMap.keySet().size()  && bypass == false){
                Database.executeBatch(new Product_upsertProduct2Records(ipaasId),Product_Staging_StaticConstants.Product_UpsertProduct2BatchSize);                      
            }
        }        
        catch(Exception ex){
            Product_Utility.createLogEntryAndNotifyUser(ex.getMessage(),ipaasId,'Product_stageQueueable',count,String.valueOf(inputWrapperMap.get(count)));
        }
    } 

     public static List<Core_Products_Staging__c> processIPSVPHRecords(Boolean vplchInd,String query,Map<String,Product_fields_mapping__mdt> ipsConfigMap){
        List<Core_Products_Staging__c> masterLst3=new List<Core_Products_Staging__c>();
        if(!vplchInd){
            for(Product_Inbound_Staging__c productLevel: Database.query(query)){
                // Level 4 Map - IPS
                Core_Products_Staging__c stageIPSRecord = new Core_Products_Staging__c();
                if(String.isNotBlank(productLevel.level_5_epm_id__c)){
                    stageIPSRecord = Product_Utility.processInbStngIPSRecords(productLevel,5,ipsConfigMap);  
                    if(l4VphMapIPS.containsKey(productLevel.level_4_epm_id__c)){                         
                        list<Core_Products_Staging__c> l5TempListIPS = l4VphMapIPS.get(productLevel.level_4_epm_id__c);                         
                        l5TempListIPS.add(stageIPSRecord);
                        l4VphMapIPS.put(productLevel.level_4_epm_id__c, l5TempListIPS); 
                    }
                    else{ 
                        l4VphMapIPS.put(productLevel.level_4_epm_id__c, new List<Core_Products_Staging__c>{stageIPSRecord} )  ;
                    }
                    masterLst3.add(stageIPSRecord);                
                }
                else if(String.isNotBlank(productLevel.level_4_epm_id__c)){
                    stageIPSRecord = Product_Utility.processInbStngIPSRecords(productLevel,4,ipsConfigMap);  
                    if(l3VphMapIPS.containsKey(productLevel.level_3_epm_id__c)){                         
                        list<Core_Products_Staging__c> l4TempListIPS = l3VphMapIPS.get(productLevel.level_3_epm_id__c);                         
                        l4TempListIPS.add(stageIPSRecord);
                        l3VphMapIPS.put(productLevel.level_3_epm_id__c, l4TempListIPS); 
                    }
                    else{ 
                        l3VphMapIPS.put(productLevel.level_3_epm_id__c, new List<Core_Products_Staging__c>{stageIPSRecord} )  ;
                    }
                    
                    masterLst3.add(stageIPSRecord);
                }
                else if(String.isNotBlank(productLevel.level_3_epm_id__c)){
                    stageIPSRecord = Product_Utility.processInbStngIPSRecords(productLevel,3,ipsConfigMap);  
                    if(l2VphMapIPS.containsKey(productLevel.level_2_epm_id__c)){                         
                        list<Core_Products_Staging__c> l3TempListIPS = l2VphMapIPS.get(productLevel.level_2_epm_id__c);                         
                        l3TempListIPS.add(stageIPSRecord);
                        l2VphMapIPS.put(productLevel.level_2_epm_id__c, l3TempListIPS); 
                    }
                    else{ 
                        l2VphMapIPS.put(productLevel.level_2_epm_id__c, new List<Core_Products_Staging__c>{stageIPSRecord} )  ;
                    }
                    
                    masterLst3.add(stageIPSRecord);
                } 
                
                
                /** Added for missing IPS *****/
                else if(String.isNotBlank(productLevel.level_2_epm_id__c)){
                    stageIPSRecord = Product_Utility.processInbStngIPSRecords(productLevel,2,ipsConfigMap);
                    if(l1VphMapIPS.containsKey(productLevel.level_1_epm_id__c)){                         
                        list<Core_Products_Staging__c> l2TempListIPS = l1VphMapIPS.get(productLevel.level_1_epm_id__c);                         
                        l2TempListIPS.add(stageIPSRecord);
                        l1VphMapIPS.put(productLevel.level_1_epm_id__c, l2TempListIPS); 
                    }
                    else{ 
                        l1VphMapIPS.put(productLevel.level_1_epm_id__c, new List<Core_Products_Staging__c>{stageIPSRecord} )  ;
                    }
                    
                    masterLst3.add(stageIPSRecord);
                }
                else if(String.isNotBlank(productLevel.level_1_epm_id__c)){
                    stageIPSRecord = Product_Utility.processInbStngIPSRecords(productLevel,1,ipsConfigMap);
                    masterLst3.add(stageIPSRecord);
                }
                /**** END ********/ 
                
            }        
            //IPS Rollup               
            
            if (!l4VphMapIPS.isEmpty()) {
                List<Core_Products_Staging__c> ipsRecsWithL5 = Product_Utility.createLevelDatawithRollupIPS(l4VphMapIPS,4,vplchInd ? '59':'43',ipsConfigMap);
                if (!ipsRecsWithL5.isEmpty()) {
                    masterLst3.addAll(ipsRecsWithL5);
                }
            }
            
            if (!l3VphMapIPS.isEmpty()) {
                List<Core_Products_Staging__c> ipsRecsWithL4 = Product_Utility.createLevelDatawithRollupIPS(l3VphMapIPS,3,vplchInd ? '59':'43',ipsConfigMap);
                if (!ipsRecsWithL4.isEmpty()) {
                    masterLst3.addAll(ipsRecsWithL4);
                }
            }
            
            if (!l2VphMapIPS.isEmpty()) {
                List<Core_Products_Staging__c> ipsRecsWithL3 = Product_Utility.createLevelDatawithRollupIPS(l2VphMapIPS,2,vplchInd ? '59':'43',ipsConfigMap);
                if (!ipsRecsWithL3.isEmpty()) {
                    masterLst3.addAll(ipsRecsWithL3);
                }
            }
            
            if (!l1VphMapIPS.isEmpty()) {
                List<Core_Products_Staging__c> ipsRecsWithL2 = Product_Utility.createLevelDatawithRollupIPS(l1VphMapIPS,1,vplchInd ? '59':'43',ipsConfigMap);
                if (!ipsRecsWithL2.isEmpty()) {
                    masterLst3.addAll(ipsRecsWithL2);
                }
            }  
        }
        return masterLst3;
    }
    
    public static List<Core_Products_Staging__c> processIPSVPLCHRecords(Boolean vplchInd,String query,Map<String,Product_fields_mapping__mdt> ipsConfigMap){
        List<Core_Products_Staging__c> masterLst4=new list<Core_Products_Staging__c>();
        if(vplchInd){  
            Map<String,Product_Inbound_Staging__c> ipsPreProcessMap = new Map<String,Product_Inbound_Staging__c>();
            for(Product_Inbound_Staging__c productLevel: Database.query(query)){
                if(String.isNotBlank(productLevel.level_1_epm_id__c)){
                    ipsPreProcessMap.put(productLevel.level_1_epm_id__c+';'+'1',productLevel);
                }
                if(String.isNotBlank(productLevel.level_2_epm_id__c)){
                    ipsPreProcessMap.put(productLevel.level_2_epm_id__c+';'+'2',productLevel);
                }
                if(String.isNotBlank(productLevel.level_3_epm_id__c)){        
                    ipsPreProcessMap.put(productLevel.level_3_epm_id__c+';'+'3',productLevel);
                }
                if(String.isNotBlank(productLevel.level_4_epm_id__c)){
                    ipsPreProcessMap.put(productLevel.level_4_epm_id__c+';'+'4',productLevel);        
                }
                if(String.isNotBlank(productLevel.level_5_epm_id__c)){
                    ipsPreProcessMap.put(productLevel.level_5_epm_id__c+';'+'5',productLevel);        
                }
            }
            masterLst4.addAll(Product_utility.processInbStngIPSVplchRecords(ipsPreProcessMap,ipsConfigMap));
        }
        return masterLst4;
    }
        
}