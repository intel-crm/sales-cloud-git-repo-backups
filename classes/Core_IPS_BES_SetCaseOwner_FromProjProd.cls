global class Core_IPS_BES_SetCaseOwner_FromProjProd {

    @InvocableMethod
    public static void  assignCaseOwner(List<Case> caseList) {
        Map<Id,Id> mapCaseAssetSupProd = new Map<Id,Id>() ;
        Map<String,Id> mapProjProdOwner=new Map<String,Id>() ;
        Map<Id,Id> mapProjOwner = new Map<Id,Id>() ;
        Set<Id> supportedProdIDs= new Set<Id>()  ;
        Set<Id> projIDs= new Set<Id>();
        List<Case> cases = new List<Case>();

        try{  
            Set<Id> suppProdIDs = new Set<Id>()  ;
            Set<Id> caseAssetids = new Set<Id>()  ;
            for(Case c : caseList){
                //supportedProdIDs.add(c.Core_IPS_Supported_Product__c);
                projIDs.add(c.Core_IPS_Project_Case__c);
                if(c.AssetId!=null){
                    caseAssetids.add(c.AssetId);
                }
            }
            
            if(caseAssetids.size()>0 && projIDs!=null && projIDs.size()>0 && Asset.SObjectType.getDescribe().isAccessible()) { //FLS Already added - Aditya
                for(Asset objAst : [SELECT Id,Core_Supported_Product__c FROM Asset WHERE Id IN :caseAssetids]){
                    supportedProdIDs.add(objAst.Core_Supported_Product__c);
                    mapCaseAssetSupProd.put(objAst.Id,objAst.Core_Supported_Product__c);
                }    
                
            }
            
            if(supportedProdIDs!=null && supportedProdIDs.size()>0 && projIDs!=null && projIDs.size()>0)
            {                                       
                for(Core_IPS_Product__c projProd : [Select Id, Core_IPS_Prod_Def_Case_Owner_ID__c, Core_Supported_Product__c,Core_IPS_Project__c,Core_IPS_Project__r.Core_IPS_Private__c,Core_IPS_Project__r.OwnerId FROM Core_IPS_Product__c WHERE Core_Supported_Product__c IN :supportedProdIDs AND Core_IPS_Project__c in : projIDs]) 
                {  
                    String projKey = String.valueOf(projProd.Core_Supported_Product__c)+String.valueOf(projProd.Core_IPS_Project__c);
                    
                    if(!String.isBlank(projProd.Core_IPS_Prod_Def_Case_Owner_ID__c)) {   // added by sumukh for US261517 & US264004 AND [Removed by sumukh for US586420  && (projProd.Core_IPS_Product_Case_Owner__r.Isactive==True) )]                 
                        mapProjProdOwner.put(projKey,projProd.Core_IPS_Prod_Def_Case_Owner_ID__c);
                    }else {
                        mapProjProdOwner.put(projProd.Core_IPS_Project__c,projProd.Core_IPS_Project__r.OwnerId);
                    }
                }              
            }    
            //End by Gourav
            Id gECRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPS GEC ReadOnly').getRecordTypeId();               
            for(Case cs: caseList){
                String caseKey = (cs.Core_IPS_Supported_Product__c==null ? String.valueOf(cs.Asset.Core_Supported_Product__c) : String.valueOf(cs.Core_IPS_Supported_Product__c)) + 
                            String.valueOf(cs.Core_IPS_Project_Case__c);
                if(mapProjProdOwner !=null && mapProjProdOwner.containsKey(caseKey) && cs.RecordTypeId!= GECRecordTypeId){  
                     cs.OwnerId=mapProjProdOwner.get(caseKey); 
                }
                cases.add(cs);
            }
            
            if(!cases.isempty()){
                Database.update(cases);
            } 
        }
        catch(Exception e){ 
            Core_IPS_ExceptionHandling.logEntryWithException(e, 'Case', 'Core_IPS_CaseTriggerHandler');
            
        } 
    }
}