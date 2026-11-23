public with sharing class PRD_ProcessInboundProductsHelper {
   /* public static List<Product_fields_mapping__mdt> fields = Product_fields_mapping__mdt.getAll().values();
    public static List<Core_Products_Staging__c> createSalesProducts( List<Product_Inbound_Staging__c> inboundProducts){
        return null;
    }

    public static List<Core_Products_Staging__c> createIPSProducts( List<Product_Inbound_Staging__c> inboundProducts){
        List<Core_Products_Staging__c> stagingRecs = new List<Core_Products_Staging__c>();
        Map<String,Product_Inbound_Staging__c> uniqueIdMap = new Map<String,Product_Inbound_Staging__c>();
        Map<String,String> idNameMap =  new Map<String,String>();

        for (Product_Inbound_Staging__c inboundRec : inboundProducts) {
            String key = (String.isBlank(inboundRec.level_1_epm_id__c) ? '' : inboundRec.level_1_epm_id__c+';')
            +(String.isBlank(inboundRec.level_2_epm_id__c) ? '' : inboundRec.level_2_epm_id__c+';')
            +(String.isBlank(inboundRec.level_3_epm_id__c) ? '' : inboundRec.level_3_epm_id__c+';')
            +(String.isBlank(inboundRec.level_4_epm_id__c) ? '' : inboundRec.level_4_epm_id__c+';')
            +(String.isBlank(inboundRec.level_5_epm_id__c) ? '' : inboundRec.level_5_epm_id__c+';');

            for (Integer i=1 ; i<=5 ; i++) {
                idNameMap.put(String.valueOf(inboundRec.get('level_'+i+'_epm_id__c')),String.valueOf(inboundRec.get('level_'+i+'_epm_name__c')));
            }
            uniqueIdMap.put(key,inboundRec);
        }

        for (String key : uniqueIdMap.keySet()) {
            for(String ky: key.split(';')) {
                stagingRecs.add(returnIPSProdStagingInstance(uniqueIdMap.get(key),ky,idNameMap.get(ky)));
            }
        }
        return stagingRecs;
    }

    public static List<Core_Products_Staging__c> createFPHs( List<Product_Inbound_Staging__c> inboundProducts){
        List<Core_Products_Staging__c> stagingRecs = new List<Core_Products_Staging__c>();
        Map<String,String> idNameMap =  new Map<String,String>();

        for (Product_Inbound_Staging__c inboundRec : inboundProducts) {

            for (Integer i=1 ; i<=5 ; i++) {
                idNameMap.put(String.valueOf(inboundRec.get('level_'+i+'_epm_id__c')),String.valueOf(inboundRec.get('level_'+i+'_epm_name__c')));
            }

            String key = (String.isBlank(inboundRec.level_5_epm_id__c) ? 'l5;' : inboundRec.level_5_epm_id__c+';')
            +(String.isBlank(inboundRec.level_4_epm_id__c) ? 'l4;' : inboundRec.level_4_epm_id__c+';')
            +(String.isBlank(inboundRec.level_3_epm_id__c) ? 'l3;' : inboundRec.level_3_epm_id__c+';')
            +(String.isBlank(inboundRec.level_2_epm_id__c) ? 'l2;' : inboundRec.level_2_epm_id__c+';')
            +(String.isBlank(inboundRec.level_1_epm_id__c) ? 'l1' : inboundRec.level_1_epm_id__c);

            Integer i = 5;
            while (i > 1) {
                if (inboundRec.get('level_'+i+'_epm_id__c') == null || inboundRec.get('level_'+i+'_epm_id__c') == '') {
                   key = key.replace('l'+i, 'l'+(i-1));
                }
                i--;
            }

            Integer j = 5;
            while (j > 1) {
                if (key.contains('l'+j)) {
                    key = key.replace('l'+j, String.valueOf(inboundRec.get('level_'+j+'_epm_id__c')));
                }
                j--;
            }

            stagingRecs.add(returnFPHProdStagingInstance(inboundRec,key,idNameMap));
        }
        return stagingRecs;
    }

    private static Core_Products_Staging__c returnIPSProdStagingInstance (Product_Inbound_Staging__c inboundRec, String epmId, String epmName) {
        Core_Products_Staging__c staging = new Core_Products_Staging__c();
        staging.Core_Product_Name__c = epmName;
        staging.Core_Product_Name_EPM_ID__c = epmId;
        staging.Core_Product_Org__c = 'IPS';
        staging.Core_Unique_ID__c = epmId;
        staging.Unique_Value__c = 'IPS;'+epmId+';'+inboundRec.iPaaS_Load_ID__c;
        for (Product_fields_mapping__mdt field: fields) {
            staging.put(field.Product_staging_field__c , inboundRec.get(field.Inbound_staging_field__c));
        }
        return staging;
    }

    private static Core_Products_Staging__c returnFPHProdStagingInstance (Product_Inbound_Staging__c inboundRec, String uniqueId, Map<String,String> idNameMap){
        
        Core_Products_Staging__c staging = new Core_Products_Staging__c();

        Integer i = 5;
        for (String s: uniqueId.split(';')) {
            staging.put('Core_L'+i+'_EPM_ID__c',s);
            staging.put('Core_L'+i+'_EPM_Name__c',idNameMap.get(s));
            i--;
        }

        staging.Core_Unique_ID__c = uniqueId;
        staging.Core_Product_Org__c = 'FPH';
        staging.Unique_Value__c = 'FPH;'+uniqueId+';'+inboundRec.iPaaS_Load_ID__c;
        for (Product_fields_mapping__mdt field: fields) {
            staging.put(field.Product_staging_field__c , inboundRec.get(field.Inbound_staging_field__c));
        }
        return staging;
    }

    public static Map<String,List<Product_Inbound_Staging__c>> getL1andRelatedProducts(List<Product_Inbound_Staging__c> stagingRecs){
        Map<String,List<Product_Inbound_Staging__c>> prodMap = new Map<String,List<Product_Inbound_Staging__c>>();

        for(Product_Inbound_Staging__c prod: stagingRecs){
            if (String.isNotBlank(prod.level_1_epm_id__c)) {
                if(!prodMap.containsKey(prod.level_1_epm_id__c)){
                    prodMap.put(prod.level_1_epm_id__c,new List<Product_Inbound_Staging__c>{prod});
                }
                else{
                    prodMap.get(prod.level_1_epm_id__c).add(prod);
                }
            }
        }

        return prodMap;
    }

    // SALES
    public static List<Core_Products_Staging__c> createLevelDatawithRollupSales(Map<String,List<Core_Products_Staging__c>> levelDataMap, String levelDownApiName, String hierarchyId, List<Product_Inbound_Staging__c> l4WoL5List){
        
        List<Core_Products_Staging__c> prodStagingTobeInserted = new List<Core_Products_Staging__c>();
        Map<String,List<Core_Products_Staging__c>> levelDownDataMap = new Map<String,List<Core_Products_Staging__c>>();
        // Currently enabled only at L4 level - insert and rollup
        Map<String,String> eligibleLevels = new Map<String,String>{'Core_Product_Group_EPM_ID__c'=>null};
        //Map<String,String> eligibleLevels = new Map<String,String>{'Core_Product_Group_EPM_ID__c'=>'Core_Product_Series_EPM_ID__c','Core_Product_Series_EPM_ID__c'=>null};

        // List of attributes to be rolled up for Sales - VPH or VPLCH
        List<Product_fields_mapping__mdt> mappings = [SELECT Id,Inbound_staging_field__c,Product_staging_field__c FROM Product_fields_mapping__mdt WHERE Type__c='Rollup' AND Product_Org__c = 'Sales' AND Hierarchy_ID__c=:hierarchyId];

        for (String lKey : levelDataMap.keySet()) {

            //First L5 product under the current L4
            Core_Products_Staging__c level1stRec = levelDataMap.get(lKey)[0];

            Core_Products_Staging__c ldownRec = new Core_Products_Staging__c();
            if (hierarchyId == Product_Staging_StaticConstants.vphId) {
                // L1
                ldownRec.Core_Product_Type_EPM_ID__c = level1stRec.Core_Product_Type_EPM_ID__c;
                ldownRec.Core_Product_Type__c = level1stRec.Core_Product_Type__c;
                // L2
                ldownRec.Core_Product_Family_EPM_ID__c = level1stRec.Core_Product_Family_EPM_ID__c;
                ldownRec.Core_Product_Family__c = level1stRec.Core_Product_Family__c;
                // L3
                ldownRec.Core_Product_Series_EPM_ID__c = levelDownApiName == 'Core_Product_Group_EPM_ID__c'? level1stRec.Core_Product_Series_EPM_ID__c:'';
                ldownRec.Core_Product_Series__c = levelDownApiName == 'Core_Product_Group_EPM_ID__c'? level1stRec.Core_Product_Series__c:'';
                // L4
                ldownRec.Core_Product_Name_EPM_ID__c = levelDownApiName == 'Core_Product_Group_EPM_ID__c'? level1stRec.Core_Product_Group_EPM_ID__c :( levelDownApiName == 'Core_Product_Series_EPM_ID__c'? level1stRec.Core_Product_Series_EPM_ID__c:'');
                ldownRec.Core_Product_Name__c = levelDownApiName == 'Core_Product_Group_EPM_ID__c'? level1stRec.Core_Product_Group__c :( levelDownApiName == 'Core_Product_Series_EPM_ID__c'? level1stRec.Core_Product_Series__c:'');
            
            }
            ldownRec.Level__c = levelDownApiName == 'Core_Product_Group_EPM_ID__c'? '4':'3';
            ldownRec.Core_Unique_ID__c = (levelDownApiName == 'Core_Product_Group_EPM_ID__c' ? level1stRec.Core_Product_Group_EPM_ID__c+';':'')+level1stRec.Core_Product_Series_EPM_ID__c+';'+level1stRec.Core_Product_Family_EPM_ID__c+';'+level1stRec.Core_Product_Type_EPM_ID__c;
            ldownRec.Core_Hierarchy_ID__c = hierarchyId;
            ldownRec.Core_Hierarchy_Name__c = hierarchyId == '43' ? 'Valid Product Hierarchy' : 'Valid Platform Codename Hierarchy';
            ldownRec.Core_IsActive__c = true;
            ldownRec.Core_Sales_Visible_Flag__c = true;
            ldownRec.Core_Product_Org__c = 'Sales';
            ldownRec.iPaaS_Load_ID__c = level1stRec.iPaaS_Load_ID__c;
            

            for (Product_fields_mapping__mdt mapping : mappings) {
                String rollupValue = '';
                for (Core_Products_Staging__c prodStaging : levelDataMap.get(lKey)) {
                    String val = String.valueOf(prodStaging.get(mapping.Product_staging_field__c));
                    if(String.isNotBlank(val)){
                        rollupValue = String.isBlank(rollupValue) ? val : rollupValue+';'+val;
                    }    
                }

                if(String.isNotBlank(rollupValue)){
                    ldownRec.put(mapping.Product_staging_field__c,removeDuplicateEntries(rollupValue));
                }
            }

            prodStagingTobeInserted.add(ldownRec);

            if(eligibleLevels.containsKey(levelDownApiName) && eligibleLevels.get(levelDownApiName) != null){ 

                if(!levelDownDataMap.containsKey((String)ldownRec.get(eligibleLevels.get(levelDownApiName)))){
                    levelDownDataMap.put((String)ldownRec.get(eligibleLevels.get(levelDownApiName)),new List<Core_Products_Staging__c>{ldownRec});
                }
                else{
                    levelDownDataMap.get((String)ldownRec.get(eligibleLevels.get(levelDownApiName))).add(ldownRec);
                }

            }
        }
        
        if(eligibleLevels.containsKey(levelDownApiName) && eligibleLevels.get(levelDownApiName) != null){ 
            prodStagingTobeInserted.addAll(createLevelDatawithRollupSales(levelDownDataMap,eligibleLevels.get(levelDownApiName),hierarchyId,null));
        }

        // This list will contains all L4s without any L5 record
        if (l4WoL5List != null && !l4WoL5List.isEmpty()){
            for (Product_Inbound_Staging__c pis: l4WoL5List) {
                Core_Products_Staging__c l4Rec = new Core_Products_Staging__c();
                 // L1
                 l4Rec.Core_Product_Type_EPM_ID__c = pis.level_1_epm_id__c;
                 l4Rec.Core_Product_Type__c = pis.level_1_epm_name__c;
                 // L2
                 l4Rec.Core_Product_Family_EPM_ID__c = pis.level_2_epm_id__c;
                 l4Rec.Core_Product_Family__c = pis.level_2_epm_name__c;
                 // L3
                 l4Rec.Core_Product_Series_EPM_ID__c = pis.level_3_epm_id__c;
                 l4Rec.Core_Product_Series__c = pis.level_3_epm_name__c;
                 // L4
                 l4Rec.Core_Product_Name_EPM_ID__c = pis.level_4_epm_id__c;
                 l4Rec.Core_Product_Name__c = pis.level_4_epm_name__c;

                 for (Product_fields_mapping__mdt mapping : mappings) {
                   l4Rec.put(mapping.Product_staging_field__c,pis.get(mapping.Inbound_staging_field__c)); 
                 }
                 prodStagingTobeInserted.add(l4Rec);
            }
        }

        return prodStagingTobeInserted;
    }

    // IPS
    public static List<Core_Products_Staging__c> createLevelDatawithRollupIPS(Map<String,List<Core_Products_Staging__c>> levelDataMap, Integer level, String hierarchyId){
        List<Core_Products_Staging__c> prodStagingTobeInserted = new List<Core_Products_Staging__c>();
        Map<String,List<Core_Products_Staging__c>> levelDownDataMap = new Map<String,List<Core_Products_Staging__c>>();

        Map<Integer,Boolean> eligibleLevels = new Map<Integer,Boolean>{
            4=>true,
            3=>true,
            2=>true,
            1=>false
        };

        // List of attributes to be rolled up for Sales - VPH or VPLCH
        List<Product_fields_mapping__mdt> mappings = [SELECT Id,Product_staging_field__c FROM Product_fields_mapping__mdt WHERE Type__c='Rollup' AND Product_Org__c = 'IPS' AND Hierarchy_ID__c=:hierarchyId];

        for (String lKey : levelDataMap.keySet()) {

            //First L5 product under the current L4
            Core_Products_Staging__c level1stRec = levelDataMap.get(lKey)[0];

            Core_Products_Staging__c ldownRec = new Core_Products_Staging__c();

            ldownRec.Core_Product_Name_EPM_ID__c = (String)level1stRec.get('Core_L'+level+'_EPM_ID__c');
            ldownRec.Core_Product_Name__c = (String)level1stRec.get('Core_L'+level+'_EPM_Name__c');
            
            for (Integer i=1; i<=5;i++) {
                ldownRec.put('Core_L'+i+'_EPM_ID__c', level1stRec.get('Core_L'+i+'_EPM_ID__c'));
                ldownRec.put('Core_L'+i+'_EPM_Name__c', level1stRec.get('Core_L'+i+'_EPM_Name__c'));
            }
            
            ldownRec.Level__c = String.valueOf(level);
            ldownRec.Core_Unique_ID__c = (String)level1stRec.get('Core_L'+level+'_EPM_ID__c');
            ldownRec.Core_Hierarchy_ID__c = hierarchyId;
            ldownRec.Core_Hierarchy_Name__c = hierarchyId == '43' ? 'Valid Product Hierarchy' : 'Valid Platform Codename Hierarchy';
            ldownRec.Core_IsActive__c = true;
            ldownRec.Core_IPS_Visible_Flag_External__c = ((hierarchyId == '43' && (level == 2 || level == 3)) || (hierarchyId == '59' && (level == 2 || level == 4)));
            ldownRec.Core_Product_Org__c = 'IPS';
            ldownRec.iPaaS_Load_ID__c = level1stRec.iPaaS_Load_ID__c;
            
            if (eligibleLevels.get(level)) {
                for (Product_fields_mapping__mdt mapping : mappings) {
                    String rollupValue = '';
                    for (Core_Products_Staging__c prodStaging : levelDataMap.get(lKey)) {
                        String val = String.valueOf(prodStaging.get(mapping.Product_staging_field__c));
                        if(String.isNotBlank(val)){
                            rollupValue = String.isBlank(rollupValue) ? val : rollupValue+';'+val;
                        }    
                    }

                    if(String.isNotBlank(rollupValue)){
                        ldownRec.put(mapping.Product_staging_field__c,removeDuplicateEntries(rollupValue));
                    }
                }
            }

            prodStagingTobeInserted.add(ldownRec);

            if(eligibleLevels.containsKey(level-1)){ 

                if(!levelDownDataMap.containsKey((String)ldownRec.get('Core_L'+(level-1)+'_EPM_ID__c'))){
                    levelDownDataMap.put((String)ldownRec.get('Core_L'+(level-1)+'_EPM_ID__c'),new List<Core_Products_Staging__c>{ldownRec});
                }
                else{
                    levelDownDataMap.get((String)ldownRec.get('Core_L'+(level-1)+'_EPM_ID__c')).add(ldownRec);
                }

            }
        }
        
        if(eligibleLevels.containsKey(level-1)){ 
            prodStagingTobeInserted.addAll(createLevelDatawithRollupIPS(levelDownDataMap,(level-1),hierarchyId));
        }

        return prodStagingTobeInserted;
    }   

    private static String removeDuplicateEntries (String str) {
        List<String> spltList = str.split(';');
        Set<String> spltSet = new Set<String>(spltList);
        return String.join(new List<String>(spltSet), ';');
    }

    public static void heapSizeCode () {
        List<Product_Inbound_Staging__c> lis = [select Id,level_1_epm_id__c, level_2_epm_id__c, level_3_epm_id__c, level_4_epm_id__c, level_5_epm_id__c from Product_Inbound_Staging__c where iPaaS_Load_ID__c ='1685428812105' and level_1_epm_id__c='98836'];
        Map<String,List<Product_Inbound_Staging__c>> l2Map = new Map<String,List<Product_Inbound_Staging__c>>();
        Map<Integer,List<Product_Inbound_Staging__c>> l2MapProcess = new Map<Integer,List<Product_Inbound_Staging__c>>();

        for (Product_Inbound_Staging__c p : lis) {
            if (!l2Map.containsKey(p.level_2_epm_id__c)) {
                l2Map.put(p.level_2_epm_id__c,new List<Product_Inbound_Staging__c>{p});
            }
            else {
                l2Map.get(p.level_2_epm_id__c).add(p);
            }
        }

        List<Product_Inbound_Staging__c> tmp = new List<Product_Inbound_Staging__c>();
        Integer i = 1;
        List<String> keyList = new List<String>(l2Map.keySet());

        for(String k : l2Map.keySet()){
            tmp.addAll(l2Map.get(k));
            if (tmp.size() > 900 || (keyList.indexOf(k) + 1 == keyList.size())){
                l2MapProcess.put(i,tmp);
                i++;
                tmp = new List<Product_Inbound_Staging__c>();
            }
        }

        for(Integer k : l2MapProcess.keySet()){
            system.debug('aravind-'+k+'-'+l2MapProcess.get(k).size());
        }

        /* i = 1 //Passed

        (l2MapProcess,i++)

        if(l2MapProcess != null && l2MapProcess.containsKey(i)){
            // set Inbound list to passed list
        }
        else {
            l2MapProcess = null;
        // existing rest of the code
        }*/

   /* }

    public static Map<String,Product_fields_mapping__mdt> getSalesConfigurationMap () {

        Map<String,Product_fields_mapping__mdt> configMap = new Map<String,Product_fields_mapping__mdt>();
        for (Product_fields_mapping__mdt mapping : [SELECT Id,Sales_Visible__c,IQR_Visible__c,Active__c,Hierarchy_ID__c,Product_Type__c,Product_Type_EMP_Id__c,Level__c FROM Product_fields_mapping__mdt WHERE Type__c='Level Configuration' AND Product_Org__c = 'Sales']){
            if(!configMap.containsKey(mapping.Level__c+';'+mapping.Hierarchy_ID__c+';'+mapping.Product_Type_EMP_Id__c)){
                configMap.put(mapping.Level__c+';'+mapping.Hierarchy_ID__c+';'+mapping.Product_Type_EMP_Id__c, mapping);
            }
            
        }
        
        return configMap;

    }

    public static Map<String,Product_fields_mapping__mdt> getIPSConfigurationMap () {

        Map<String,Product_fields_mapping__mdt> configMap = new Map<String,Product_fields_mapping__mdt>();
        for (Product_fields_mapping__mdt mapping : [SELECT Id,IPS_Visible_Flag_External__c,Active__c,Hierarchy_ID__c,Level__c FROM Product_fields_mapping__mdt WHERE Type__c='Level Configuration' AND Product_Org__c = 'IPS']){
            if(!configMap.containsKey(mapping.Level__c+';'+mapping.Hierarchy_ID__c)){
                configMap.put(mapping.Level__c+';'+mapping.Hierarchy_ID__c, mapping);
            }
            
        }
        return configMap;

    }

    public static void setMMattributesBasedOnRestriction ( Product_Inbound_Staging__c inboundStaging, Core_Products_Staging__c stageRecord, Product_fields_mapping__mdt salesConfig){
        List<String> mmIds  = new List<String>();
        Map<String,MMAttributes> mmAttributeMap = new Map<String,MMAttributes>();


        for (String mmId: mmIds) {
            MMAttributes mm = new MMAttributes();
            for (String code : inboundStaging.L5_OrderingCode__c.split(';')) {
                if(code.split('-')[0] == mmId){
                    mm.orderingCode = code.split('-')[1];
                }    
            }
            for (String code : inboundStaging.L5_MaterialStatusCode__c.split(';')) {
                if(code.split('-')[0] == mmId){
                    mm.productStatus = code.split('-')[1];
                }    
            }
            for (String code : inboundStaging.Restriction_Code__c.split(';')) {
                if(code.split('-')[0] == mmId){
                    mm.restrictionCode = Integer.valueOf(code.split('-')[1]);
                }    
            }
            mmAttributeMap.put(mmId,mm);
        }
        
        /*for(Integer i=0; i < mmIds.size();i++){
            MMAttributes mm = new MMAttributes();
            Map<String,String> strMap = new Map<String,String>();
            for (String code : inboundStaging.L5_OrderingCode__c.split(';')) {
                if(code.split('-')[0] == ){

                }
                strMap.put(code.split('-')[0],code.split('-')[1]);
            }
            mm.orderingCode = strMap.get()
            mm.productStatus = (i < inboundStaging.L5_MaterialStatusCode__c.split(';').size()) ? (inboundStaging.L5_MaterialStatusCode__c.split(';'))[i] : null;
            mm.restrictionCode = (i < inboundStaging.Restriction_Code__c.split(';').size()) ? Integer.valueOf((inboundStaging.Restriction_Code__c.split(';'))[i]) : null;
            
            mmAttributeMap.put(mmIds[i],mm);
        }*/

       /* for (String mmId : mmAttributeMap.keySet()) {
            MMAttributes attr = mmAttributeMap.get(mmId);
            if (attr.restrictionCode <= Integer.valueOf(salesConfig.Restriction_Code__c)) {
                if(stageRecord.get('Core_Item_Id__c') == null || !((String)stageRecord.get('Core_Item_Id__c')).containsIgnoreCase(mmId)){
                    stageRecord.put('Core_Item_Id__c' ,stageRecord.get('Core_Item_Id__c') == null ? mmId :stageRecord.get('Core_Item_Id__c') +';'+mmId);
                }
                if(stageRecord.get('Core_Product_Status__c') == null || !((String)stageRecord.get('Core_Product_Status__c')).containsIgnoreCase(attr.productStatus)){
                    stageRecord.put('Core_Product_Status__c' ,stageRecord.get('Core_Product_Status__c') == null ? attr.productStatus : stageRecord.get('Core_Product_Status__c') +';'+attr.productStatus);
                }
                if(stageRecord.get('Core_Forecast_Product_Name__c') == null || !((String)stageRecord.get('Core_Forecast_Product_Name__c')).containsIgnoreCase(attr.orderingCode)){
                    stageRecord.put('Core_Forecast_Product_Name__c' ,stageRecord.get('Core_Forecast_Product_Name__c') == null ? attr.orderingCode : stageRecord.get('Core_Forecast_Product_Name__c') +';'+attr.orderingCode);
                }
            }
        } 
    }

    public class MMAttributes {
        public String productStatus{get;set;}

        public String orderingCode{get;set;}

        public Integer restrictionCode{get;set;}
    }*/

}