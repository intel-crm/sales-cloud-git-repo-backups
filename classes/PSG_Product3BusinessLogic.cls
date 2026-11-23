/****************************************************************************************************
Apex Class Name : PSG_Product3BusinessLogic
Version         : 1.0 
Created Date    : 08/13/2021
Function        : This class is used as part of Product trigger for all the PSG functionalities.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hari Kiran K              08/13/2021                Created
*****************************************************************************************************/
public without sharing class PSG_Product3BusinessLogic {
   
    /************************************************************************************************************
    *Method Name : changeProductOnRelatedObjects
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : Copies all the Price Book Entries, Forward Costs, MSVP from most recent created product with same OPN when new Product is inserted or old product is activated.
    ************************************************************************************************************/
    public static void changeProductOnRelatedObjects(List<Product3__c> newList,Map<Id,Product3__c> oldMap,Boolean IsInsert){
        List<Product3__c> prodList=new List<Product3__c>();
        Set<String> opnSet=new Set<String>();
        Map<String,Product3__c> opnProdMap=new Map<String,Product3__c>();
        Map<String,List<PricebookEntry>> prodToPBEMap=new Map<String,List<PricebookEntry>>();
        Map<String,List<price_forward_cost__c>> prodToPFCMap=new Map<String,List<price_forward_cost__c>>();
        Map<String,Set<String>> prodToExisPBMap=new Map<String,Set<String>>();
        Map<String,PricebookEntry> exisprodToPBEMap=new Map<String,PricebookEntry>();
        Map<String,List<core_cpq_list_price__c>> exisprodToLPMap=new  Map<String,List<core_cpq_list_price__c>>();
        List<price_forward_cost__c> pfcListToInsert=new List<price_forward_cost__c>();
        List<PricebookEntry> pbeListToUpdate=new List<PricebookEntry>();
        List<PricebookEntry> pbeListToInsert=new List<PricebookEntry>();
        List<PricebookEntry> spbeListToInsert=new List<PricebookEntry>();
        Map<String,List<price_msvp__c>> prodToMSVPMap=new Map<String,List<price_msvp__c>>();
        Map<String,List<String>> newProdToExisFCMap=new Map<String,List<String>>();
        Map<String,List<String>> newProdToExisMSVPMap=new Map<String,List<String>>();
        Map<String,List<String>> newProdToExisLPMap=new Map<String,List<String>>();
        List<price_msvp__c> msvpListToInsert=new List<price_msvp__c>();
        
        Set<String> inactiveOPNS=new Set<String>();
        if(newList != null){
            for(Product3__c prod : newList){
                if(IsInsert){
                    if(prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.IsActive__c && prod.Core_Product_org__c == 'Sales'){
                        prodList.add(prod);
                        opnSet.add(prod.core_OPN__c);
                    }
                }else{
                    if((prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier) && prod.Core_Product_org__c == 'Sales' && ((oldMap.get(prod.Id).IsActive__c != prod.IsActive__c && prod.IsActive__c) || (oldMap.get(prod.Id).core_OPN__c != prod.Core_OPN__c && oldMap.get(prod.Id).core_OPN__c == null && prod.Core_OPN__c!=null)) ){
                        prodList.add(prod);
                        opnSet.add(prod.core_OPN__c);
                    } 
                    
                    if(prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.Core_Product_org__c == 'Sales' && oldMap.get(prod.Id).IsActive__c != prod.IsActive__c && !prod.IsActive__c && prod.Core_OPN__c!=null){
                        
                        inactiveOPNS.add(prod.core_OPN__c);
                    } 
                    
                }
            }
        }
        
        
        
        if(!opnSet.isEmpty()){
            Map<String,String> opnToExisProdIdMap=getRecentActivatedProduct(opnSet,prodList);            
            for(Product3__c prd: [SELECT Id,core_OPN__c from Product3__c WHERE Id in :opnToExisProdIdMap.values()]){
                if(!opnProdMap.containsKey(prd.core_OPN__c)){
                    opnProdMap.put(prd.core_OPN__c,prd);
                }                
            }
        }
        if(!opnProdMap.isEmpty()){
            List<Product3__c> exisProdList=opnProdMap.values();
            for(PricebookEntry pbe:[Select Id,Product3__c,PriceBook2Id,PriceBook2.Name,UnitPrice from PricebookEntry where Product3__c in :exisProdList]){
                List<PriceBookEntry> pbeList=prodToPBEMap.containsKey(pbe.Product3__c)?prodToPBEMap.get(pbe.Product3__c):new List<PricebookEntry>();
                pbeList.add(pbe);
                prodToPBEMap.put(pbe.Product3__c,pbeList);
            }
            if(!prodList.isEmpty()){
                for(PricebookEntry pbe: [Select Id,Product3__c,PriceBook2Id,UseStandardPrice from PricebookEntry where Product3__c in : prodList]){
                    Set<String> priceBookIds=prodToExisPBMap.containsKey(pbe.Product3__c)?prodToExisPBMap.get(pbe.Product3__c):new Set<String>();
                    priceBookIds.add(pbe.PriceBook2Id);
                    prodToExisPBMap.put(pbe.Product3__c,priceBookIds);
                    exisprodToPBEMap.put(pbe.Product3__c+'_'+pbe.Pricebook2Id,pbe);            
                }
                
                /*Getting the existing FC records of newly modified products.
                for(price_forward_cost__c fc: [Select Id,core_cpq_unique_id__c,core_cpq_product_nm__c from price_forward_cost__c where core_cpq_product_nm__c in : prodList]){
                    if(newProdToExisFCMap.containsKey(fc.core_cpq_product_nm__c)){
                        newProdToExisFCMap.get(fc.core_cpq_product_nm__c).add(fc.core_cpq_unique_id__c);
                    }else{
                        newProdToExisFCMap.put(fc.core_cpq_product_nm__c,new List<String>{fc.core_cpq_unique_id__c});
                    }  
                }*/
                
                //Getting the existing MSVP records of newly modified products.
                //  Commented by Abhigna
                /*for(price_msvp__c msvp: [Select Id,core_cpq_unique_id__c,core_cpq_product_nm__c from price_msvp__c where core_cpq_product_nm__c in : prodList]){
                    if(newProdToExisMSVPMap.containsKey(msvp.core_cpq_product_nm__c)){
                        newProdToExisMSVPMap.get(msvp.core_cpq_product_nm__c).add(msvp.core_cpq_unique_id__c);
                    }else{
                        newProdToExisMSVPMap.put(msvp.core_cpq_product_nm__c,new List<String>{msvp.core_cpq_unique_id__c});
                    }  
                } */
                
                //Getting the existing LP records of newly modified products.
                //Commented By Abhigna
                /*for(core_cpq_list_price__c lp: [Select Id,core_cpq_unique_id__c,core_cpq_product_name__c from core_cpq_list_price__c where core_cpq_product_name__c in : prodList]){
                    if(newProdToExisLPMap.containsKey(lp.core_cpq_product_name__c)){
                        newProdToExisLPMap.get(lp.core_cpq_product_name__c).add(lp.core_cpq_unique_id__c);
                    }else{
                        newProdToExisLPMap.put(lp.core_cpq_product_name__c,new List<String>{lp.core_cpq_unique_id__c});
                    }  
                } */
            }
            /*String fcQuery='Select '+Label.PSG_ForwardCostFieldsToCopy+' from price_forward_cost__c where core_cpq_product_nm__c in :exisProdList';
            for(price_forward_cost__c pfc:(List<price_forward_cost__c>)Database.query(fcQuery)){
                List<price_forward_cost__c> pfcList=prodToPFCMap.containsKey(pfc.core_cpq_product_nm__c)?prodToPFCMap.get(pfc.core_cpq_product_nm__c):new List<price_forward_cost__c>();
                pfcList.add(pfc);
                prodToPFCMap.put(pfc.core_cpq_product_nm__c,pfcList);
            }*/
            String msvpQuery='Select '+Label.PSG_MSVPFieldsToCopy+' from price_msvp__c where core_cpq_product_nm__c in :exisProdList and (core_cpq_IsActive__c__c = true or core_cpq_effective_date_dt__c >= TODAY)';
            for(price_msvp__c msvp:(List<price_msvp__c>)Database.query(msvpQuery)){
                List<price_msvp__c> msvpList=prodToMSVPMap.containsKey(msvp.core_cpq_product_nm__c)?prodToMSVPMap.get(msvp.core_cpq_product_nm__c):new List<price_msvp__c>();
                msvpList.add(msvp);
                prodToMSVPMap.put(msvp.core_cpq_product_nm__c,msvpList);
            }
            
            String listPriceQuery='Select Id,core_cpq_product_name__c,Pricebookentry__c,core_cpq_Price_Book__c,core_cpq_lowerbound_qty__c,core_cpq_upperbound_qty__c,core_cpq_minimum_order_qty__c,core_cpq_multiple_order_quantity__c,core_cpq_list_price_amt__c  from core_cpq_list_price__c where core_cpq_product_name__c in :exisProdList';
            for(core_cpq_list_price__c lp:(List<core_cpq_list_price__c>)Database.query(listPriceQuery)){
                List<core_cpq_list_price__c> lpList=exisprodToLPMap.containsKey(''+lp.core_cpq_product_name__c+lp.core_cpq_Price_Book__c)?exisprodToLPMap.get(''+lp.core_cpq_product_name__c+lp.core_cpq_Price_Book__c):new List<core_cpq_list_price__c>();
                lpList.add(lp);
                exisprodToLPMap.put(''+lp.core_cpq_product_name__c+lp.core_cpq_Price_Book__c,lpList);
            }
        }
        Map<String,PricebookEntry> newProdTOPBEMap= new Map<String,PricebookEntry>();
        List<core_cpq_list_price__c> newlpToUpsert = new List<core_cpq_list_price__c>();
        for(Product3__c prod:prodList){
        string uniqueValue = '';
            if(opnProdMap.containsKey(prod.Core_OPN__c) && prodToPBEMap.containsKey(opnProdMap.get(prod.Core_OPN__c).Id)){
                for(PricebookEntry pbe:prodToPBEMap.get(opnProdMap.get(prod.Core_OPN__c).Id)){
                    //if(prodToExisPBMap.containsKey(prod.Id) && prodToExisPBMap.get(prod.Id).contains(pbe.Pricebook2Id)){
                    if(!prodToExisPBMap.containsKey(prod.Id)){
                        /*if(exisprodToPBEMap.containsKey(prod.Id+'_'+pbe.Pricebook2Id)){
                            PriceBookEntry pbe1=exisprodToPBEMap.get(prod.Id+'_'+pbe.Pricebook2Id);
                            pbe1.UnitPrice=pbe.UnitPrice;
                            pbe1.price_disty_cost__c=pbe.price_disty_cost__c;
                            pbe1.core_cpq_minimum_order_qty__c=pbe.core_cpq_minimum_order_qty__c;
                            pbe1.core_cpq_multiple_order_quantity__c=pbe.core_cpq_multiple_order_quantity__c;
                            uniqueValue = ''+ pbe1.Product3__cId + pbe1.Pricebook2Id;
                            pbe1.core_cpq_unique_id__c = uniqueValue.trim();
                            if(!pbe1.UseStandardPrice){
                                pbeListToUpdate.add(pbe1);
                            }                            
                            newProdTOPBEMap.put(''+ pbe1.Product3__cId + pbe1.Pricebook2Id,pbe1);
                        }
                    }else{*/
                        PricebookEntry newpbe=new PricebookEntry();
                        newpbe.PriceBook2Id=pbe.PriceBook2Id;
                        newpbe.UnitPrice=pbe.UnitPrice;
                        newpbe.price_disty_cost__c=pbe.price_disty_cost__c;
                        newpbe.core_cpq_minimum_order_qty__c=pbe.core_cpq_minimum_order_qty__c;
                        newpbe.core_cpq_multiple_order_quantity__c=pbe.core_cpq_multiple_order_quantity__c;
                        uniqueValue = ''+prod.Id + pbe.Pricebook2Id;
                        newpbe.core_cpq_unique_id__c = uniqueValue.trim();
                        newpbe.Product3__c=prod.Id;
                        newpbe.isActive=true;
                        if(pbe.PriceBook2.Name==Label.PSG_DefaultPricebookName){
                            spbeListToInsert.add(newpbe);
                        }else{
                            pbeListToInsert.add(newpbe);
                        }
                        newProdTOPBEMap.put(''+ prod.Id + pbe.Pricebook2Id,newpbe);
                    }
                }
            }
            /*if(opnProdMap.containsKey(prod.Core_OPN__c) && prodToPFCMap.containsKey(opnProdMap.get(prod.Core_OPN__c).Id)){
                for(price_forward_cost__c pfc:prodToPFCMap.get(opnProdMap.get(prod.Core_OPN__c).Id)){
                    if(!newProdToExisFCMap.containsKey(prod.Id)){
                        price_forward_cost__c newPfc=pfc.clone(false,false,false,false);
                        newPfc.core_cpq_product_nm__c=prod.Id;
                        newPfc.core_cpq_unique_id__c = newPfc.Name + String.ValueOf(prod.Id);
                        pfcListToInsert.add(newPfc);
                    }                    
                }
            }*/
            
            if(opnProdMap.containsKey(prod.Core_OPN__c) && prodToMSVPMap.containsKey(opnProdMap.get(prod.Core_OPN__c).Id)){
                for(price_msvp__c msvp:prodToMSVPMap.get(opnProdMap.get(prod.Core_OPN__c).Id)){
                    if(!newProdToExisMSVPMap.containsKey(prod.Id)){
                        price_msvp__c newMsvp=msvp.clone(false,false,false,false);
                        newMsvp.core_cpq_product_nm__c=prod.Id;
                        newMsvp.core_cpq_unique_id__c=''+prod.Id+msvp.core_cpq_effective_date_dt__c;
                        msvpListToInsert.add(newMsvp);
                    }
                }
            }
        }
        if(!spbeListToInsert.isEmpty()){ 
            insert spbeListToInsert;
        }
        if(!pbeListToInsert.isEmpty()){ 
            insert pbeListToInsert;
        }
        /*if(!pbeListToUpdate.isEmpty()){
            update pbeListToUpdate;
        }*/
        
        for(Product3__c prod:prodList){
            if(opnProdMap.containsKey(prod.Core_OPN__c)){
                for(String key : newProdTOPBEMap.keyset()){
                    if(key.contains(''+prod.Id) && newProdTOPBEMap.get(key).Id != null){
                        PricebookEntry pbe=newProdTOPBEMap.get(key);
                        if(exisprodToLPMap.containsKey(''+opnProdMap.get(prod.Core_OPN__c).Id+pbe.Pricebook2Id)){
                            List<core_cpq_list_price__c> exisLP=exisprodToLPMap.get(''+opnProdMap.get(prod.Core_OPN__c).Id+pbe.Pricebook2Id);
                            for(core_cpq_list_price__c lp : exisLP){
                                if(!newProdToExisLPMap.containsKey(prod.Id)){
                                    core_cpq_list_price__c newLP=lp.clone(false,false,false,false);
                                    newLP.Pricebookentry__c=pbe.Id;
                                    newLP.core_cpq_product_name__c=prod.Id;
                                    newLP.core_cpq_Price_Book__c=pbe.Pricebook2Id;
                                    newLP.core_cpq_unique_id__c=''+lp.core_cpq_lowerbound_qty__c+'.0'+lp.core_cpq_upperbound_qty__c+'.0'+prod.Id+pbe.Id;
                                    newlpToUpsert.add(newLP);
                                }                                
                            }
                        }
                    }
                }
            }
        }
        
        if(!newlpToUpsert.isEmpty()){
            List<core_cpq_list_price__c> failedRec=new List<core_cpq_list_price__c>();
            Database.UpsertResult[] result=Database.upsert(newlpToUpsert,core_cpq_list_price__c.core_cpq_unique_id__c,false);
            for(Integer i=0;i<result.size();i++){
                if (!result[i].isSuccess()) {
                    failedRec.add(newlpToUpsert[i]);
                }
            }
            if(failedRec.size()>0){
                PSG_Utility.createCoreLogEntry('PSG_Product3BusinessLogic','changeProductOnRelatedObjects','Error while Copying List Price records.','Failed Records : \n '+failedRec+'\n\n Database SaveResult : '+result,'Product','Low','');
            }
        }
        
        /*if(!pfcListToInsert.isEmpty()){
            List<price_forward_cost__c> failedRec=new List<price_forward_cost__c>();
            Database.UpsertResult[] result=Database.upsert(pfcListToInsert,price_forward_cost__c.core_cpq_unique_id__c,false);
            for(Integer i=0;i<result.size();i++){
                if (!result[i].isSuccess()) {
                    failedRec.add(pfcListToInsert[i]);
                }
            }
            if(failedRec.size()>0){
                PSG_Utility.createCoreLogEntry('PSG_Product3BusinessLogic','changeProductOnRelatedObjects','Error while Copying Forward cost records.','Failed Records : \n '+failedRec+'\n\n Database SaveResult : '+result,'Product','Low','');
            }
        }*/
        if(!msvpListToInsert.isEmpty()){
            List<price_msvp__c> failedRec=new List<price_msvp__c>();
            Database.UpsertResult[] result=Database.upsert(msvpListToInsert,price_msvp__c.core_cpq_unique_id__c,false);
            for(Integer i=0;i<result.size();i++){
                if (!result[i].isSuccess()) {
                    failedRec.add(msvpListToInsert[i]);
                }
            }
            if(failedRec.size()>0){
                PSG_Utility.createCoreLogEntry('PSG_Product3BusinessLogic','changeProductOnRelatedObjects','Error while Copying MSVP records.','Failed Records : \n '+failedRec+'\n\n Database SaveResult : '+result,'Product','Low','');
            }
        }
    }
    
    
    /**
     * Method Name : getRecentActivatedProduct
     * Parameters : Set of OPN's and newList from trigger
     * Description : Returns map of OPN-> PRODUCT ID by following priorities (ACTIVE -> MOST RECENTLY ACTIVATED -> RECENTLY CREATED PRODUCT)
     * */
    public static Map<String,String> getRecentActivatedProduct(Set<String> opnSet,List<Product3__c> newList){
        Map<String,String> opnToExisProdIdMap=new Map<String,String>();
        for(Product3__c prod : [Select id,core_OPN__c from Product3__c where core_OPN__c in :opnSet and Core_Product_org__c = 'Sales' and Core_Product_Type__c = :Label.PSG_Product_Type_Identifier and Id not in :newList  order by CreatedDate  desc]){
            if(!opnToExisProdIdMap.containsKey(prod.core_OPN__c)){
                opnToExisProdIdMap.put(prod.core_OPN__c,prod.Id);
            } 
        }
        /*for(Product3__cHistory prodHis : [Select id,OldValue, NewValue,Product3__cId,Product3__c.core_OPN__c from Product3__cHistory where Field ='IsActive__c' and Product3__c.core_OPN__c in :opnSet and Product3__c.core_OPN__c not in :opnToExisProdIdMap.keyset() and  Product3__c.Core_Product_org__c = 'Sales' and Product3__c.Core_Product_Type__c = :Label.PSG_Product_Type_Identifier and Product3__cId not in :newList  order by CreatedDate  desc]){
            if(!opnToExisProdIdMap.containsKey(prodHis.Product3__c.core_OPN__c) && prodHis.NewValue == false){
                opnToExisProdIdMap.put(prodHis.Product3__c.core_OPN__c,prodHis.Product3__cId);
            } 
        }*/
        return opnToExisProdIdMap;
    }
    
    
    
    /************************************************************************************************************
    *Method Name : fetchFCRelatedList
    *Created Date: 10/26/2022
    *Author: Ranjit
    *Description : method to fetch FC Related Records of an OPN.
    ************************************************************************************************************/
    
    @AuraEnabled(cacheable=true)
    public static List<price_forward_cost__c> fetchFCRelatedList(String Prod_id,String sortby,String sortOrder){
        List<price_forward_cost__c> FcList=new List<price_forward_cost__c>();
        prod_id=String.escapeSingleQuotes(Prod_id);
        sortby=String.escapeSingleQuotes(sortby);
        sortOrder=String.escapeSingleQuotes(sortOrder);    
        String Query;
        List<Product3__c> Opn =[select Core_OPN__c from Product3__c where id=:Prod_id];
        string fcopn=opn[0].Core_OPN__c;
        Query='Select Id,Name,core_cpq_fc_start_date_dt__c,core_cpq_fc_end_date_dt__c,price_forward_cost_amt__c,core_cpq_forward_cost_period_name_nm__c from price_forward_cost__c where core_cpq_product_opn_txt__c = :fcopn';
        try{
            if(sortby != null && sortOrder !=null){
                Query += ' ORDER BY '+sortby+' '+sortOrder;     
            } 
            FcList=Database.query(Query);
            system.debug('query-->'+Query);
        }catch(Exception ex){
            PSG_Utility.logError(ex);
        }
        return FcList;
    }
}