/****************************************************************************************************
Apex Class Name : PSG_ProductBusinessLogic
Version         : 1.0 
Created Date    : 08/13/2021
Function        : This class is used as part of Product trigger for all the PSG functionalities.
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hari Kiran K              08/13/2021                Created
*****************************************************************************************************/
public without sharing class PSG_ProductBusinessLogic {
   
    /************************************************************************************************************
    *Method Name : changeProductOnRelatedObjects
    *Created Date: 08/13/2021
    *Author: Hari
    *Description : Copies all the Price Book Entries, Forward Costs, MSVP from most recent created product with same OPN when new Product is inserted or old product is activated.
    ************************************************************************************************************/
    public static void changeProductOnRelatedObjects(List<Product2> newList,Map<Id,Product2> oldMap,Boolean IsInsert){
        List<Product2> prodList=new List<Product2>();
        Set<String> opnSet=new Set<String>();
        Map<String,Product2> opnProdMap=new Map<String,Product2>();
        Map<String,List<PricebookEntry>> prodToPBEMap=new Map<String,List<PricebookEntry>>();
        
        Map<String,Set<String>> prodToExisPBMap=new Map<String,Set<String>>();
        Map<String,PricebookEntry> exisprodToPBEMap=new Map<String,PricebookEntry>();
        Map<String,List<core_cpq_list_price__c>> exisprodToLPMap=new  Map<String,List<core_cpq_list_price__c>>();
        
        
        List<PricebookEntry> pbeListToInsert=new List<PricebookEntry>();
        List<PricebookEntry> spbeListToInsert=new List<PricebookEntry>();
        Map<String,List<price_msvp__c>> prodToMSVPMap=new Map<String,List<price_msvp__c>>();
        
        Map<String,List<String>> newProdToExisMSVPMap=new Map<String,List<String>>();
        Map<String,List<String>> newProdToExisLPMap=new Map<String,List<String>>();
        List<price_msvp__c> msvpListToInsert=new List<price_msvp__c>();
        
        Set<String> inactiveOPNS=new Set<String>();
        if(newList != null){
            for(Product2 prod : newList){
                if(IsInsert){
                    if(prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.isActive && prod.Core_Product_org__c == 'Sales' && !String.isBlank(prod.Core_OPN__c)){
                        prodList.add(prod);
                        opnSet.add(prod.core_OPN__c);                        
                    }
                }else{
                    if((prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier) && prod.Core_Product_org__c == 'Sales' && ((oldMap.get(prod.Id).isActive != prod.isActive && prod.isActive) || (oldMap.get(prod.Id).core_OPN__c != prod.Core_OPN__c && oldMap.get(prod.Id).core_OPN__c == null && prod.Core_OPN__c!=null)) ){
                        prodList.add(prod);
                        opnSet.add(prod.core_OPN__c);                        
                    }                     
                    if(prod.Core_Product_Type__c == Label.PSG_Product_Type_Identifier && prod.Core_Product_org__c == 'Sales' && oldMap.get(prod.Id).isActive != prod.isActive && !prod.isActive && prod.Core_OPN__c!=null){
                        inactiveOPNS.add(prod.core_OPN__c);
                    }                    
                }
            }
        }
        if(!opnSet.isEmpty()){            
            Map<String,String> opnToExisProdIdMap=getRecentActivatedProduct(opnSet,prodList);              
            for(Product2 prd: [SELECT Id,core_OPN__c from Product2 WHERE Id in :opnToExisProdIdMap.values()]){
                if(!opnProdMap.containsKey(prd.core_OPN__c)){
                    opnProdMap.put(prd.core_OPN__c,prd);
                }                
            }            
        }
        if(!opnProdMap.isEmpty()){            
            List<Product2> exisProdList=opnProdMap.values();
            for(PricebookEntry pbe:[Select Id,Product2Id,PriceBook2Id,PriceBook2.Name,UnitPrice,price_disty_cost__c,core_cpq_minimum_order_qty__c,core_cpq_multiple_order_quantity__c from PricebookEntry where Product2Id in :exisProdList]){
                List<PriceBookEntry> pbeList=prodToPBEMap.containsKey(pbe.Product2Id)?prodToPBEMap.get(pbe.Product2Id):new List<PricebookEntry>();
                pbeList.add(pbe);
                prodToPBEMap.put(pbe.Product2Id,pbeList);
            }            
            if(!prodList.isEmpty() && !IsInsert){
                Map<Id, Product2> prodListMap = new Map<Id, Product2>(prodList);
                for(PricebookEntry pbe: [Select Id,Product2Id,PriceBook2Id,UseStandardPrice from PricebookEntry where Product2Id in : prodListMap.keyset()]){
                    Set<String> priceBookIds=prodToExisPBMap.containsKey(pbe.Product2Id)?prodToExisPBMap.get(pbe.Product2Id):new Set<String>();
                    priceBookIds.add(pbe.PriceBook2Id);
                    prodToExisPBMap.put(pbe.Product2Id,priceBookIds);
                    exisprodToPBEMap.put(pbe.Product2Id+'_'+pbe.Pricebook2Id,pbe);            
                } 
                //Getting the existing MSVP records of newly modified products.
                for(price_msvp__c msvp: [Select Id,core_cpq_unique_id__c,core_cpq_product_nm__c from price_msvp__c where core_cpq_product_nm__c in : prodListMap.keyset()]){
                    if(newProdToExisMSVPMap.containsKey(msvp.core_cpq_product_nm__c)){
                        newProdToExisMSVPMap.get(msvp.core_cpq_product_nm__c).add(msvp.core_cpq_unique_id__c);
                    }else{
                        newProdToExisMSVPMap.put(msvp.core_cpq_product_nm__c,new List<String>{msvp.core_cpq_unique_id__c});
                    }  
                }
                //Getting the existing LP records of newly modified products.
                for(core_cpq_list_price__c lp: [Select Id,core_cpq_unique_id__c,core_cpq_product_name__c from core_cpq_list_price__c where core_cpq_product_name__c in : prodListMap.keyset()]){
                    if(newProdToExisLPMap.containsKey(lp.core_cpq_product_name__c)){
                        newProdToExisLPMap.get(lp.core_cpq_product_name__c).add(lp.core_cpq_unique_id__c);
                    }else{
                        newProdToExisLPMap.put(lp.core_cpq_product_name__c,new List<String>{lp.core_cpq_unique_id__c});
                    }  
                }
            }
            String msvpQuery='Select '+String.escapeSingleQuotes(Label.PSG_MSVPFieldsToCopy)+' from price_msvp__c where core_cpq_product_nm__c in :exisProdList and (core_cpq_isactive__c = true or core_cpq_effective_date_dt__c >= TODAY)';
            if(String.isNotBlank(msvpQuery)){
                for(price_msvp__c msvp:(List<price_msvp__c>)Database.query(msvpQuery)){
                	List<price_msvp__c> msvpList=prodToMSVPMap.containsKey(msvp.core_cpq_product_nm__c)?prodToMSVPMap.get(msvp.core_cpq_product_nm__c):new List<price_msvp__c>();
                	msvpList.add(msvp);
                	prodToMSVPMap.put(msvp.core_cpq_product_nm__c,msvpList);
            	}
            }
            String listPriceQuery='Select Id,core_cpq_product_name__c,Pricebookentry__c,core_cpq_Price_Book__c,core_cpq_lowerbound_qty__c,core_cpq_upperbound_qty__c,core_cpq_minimum_order_qty__c,core_cpq_multiple_order_quantity__c,core_cpq_list_price_amt__c  from core_cpq_list_price__c where core_cpq_product_name__c in :exisProdList';
            if(String.isNotBlank(listPriceQuery)){
                for(core_cpq_list_price__c lp:(List<core_cpq_list_price__c>)Database.query(listPriceQuery)){
                	List<core_cpq_list_price__c> lpList=exisprodToLPMap.containsKey(''+lp.core_cpq_product_name__c+lp.core_cpq_Price_Book__c)?exisprodToLPMap.get(''+lp.core_cpq_product_name__c+lp.core_cpq_Price_Book__c):new List<core_cpq_list_price__c>();
                	lpList.add(lp);
                	exisprodToLPMap.put(''+lp.core_cpq_product_name__c+lp.core_cpq_Price_Book__c,lpList);
            	} 
            }            
        }
        Map<String,PricebookEntry> newProdTOPBEMap= new Map<String,PricebookEntry>();
        List<core_cpq_list_price__c> newlpToUpsert = new List<core_cpq_list_price__c>();
        for(Product2 prod:prodList){
        string uniqueValue = '';
            if(opnProdMap.containsKey(prod.Core_OPN__c) && prodToPBEMap.containsKey(opnProdMap.get(prod.Core_OPN__c).Id)){
                for(PricebookEntry pbe:prodToPBEMap.get(opnProdMap.get(prod.Core_OPN__c).Id)){
                    if(!prodToExisPBMap.containsKey(prod.Id)){
                        PricebookEntry newpbe=new PricebookEntry();
                        newpbe.PriceBook2Id=pbe.PriceBook2Id;
                        newpbe.UnitPrice=pbe.UnitPrice;
                        newpbe.price_disty_cost__c=pbe.price_disty_cost__c;
                        newpbe.core_cpq_minimum_order_qty__c=pbe.core_cpq_minimum_order_qty__c;
                        newpbe.core_cpq_multiple_order_quantity__c=pbe.core_cpq_multiple_order_quantity__c;
                        uniqueValue = ''+prod.Id + pbe.Pricebook2Id;
                        newpbe.core_cpq_unique_id__c = uniqueValue.trim();
                        newpbe.Product2Id=prod.Id;
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
        for(Product2 prod:prodList){
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
                                    newLP.core_cpq_product_opn_txt__c = prod.Core_OPN__c;//Added for TWC3133-5529 by Bhawana Manoj Kumar
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
                
                PSG_Utility.createCoreLogEntry('PSG_ProductBusinessLogic','changeProductOnRelatedObjects','Error while Copying List Price records.','Failed Records : \n '+failedRec+'\n\n Database SaveResult : '+result,'Product','Low','');                
            }
        }
        if(!msvpListToInsert.isEmpty()){
            List<price_msvp__c> failedRec=new List<price_msvp__c>();
            Database.UpsertResult[] result=Database.upsert(msvpListToInsert,price_msvp__c.core_cpq_unique_id__c,false);
            for(Integer i=0;i<result.size();i++){
                if (!result[i].isSuccess()) {
                    failedRec.add(msvpListToInsert[i]);
                }
            }
            if(failedRec.size()>0){
                PSG_Utility.createCoreLogEntry('PSG_ProductBusinessLogic','changeProductOnRelatedObjects','Error while Copying MSVP records.','Failed Records : \n '+failedRec+'\n\n Database SaveResult : '+result,'Product','Low','');
            }
        }
    }
    
    
    /**
     * Method Name : getRecentActivatedProduct
     * Parameters : Set of OPN's and newList from trigger
     * Description : Returns map of OPN-> PRODUCT ID by following priorities (ACTIVE -> MOST RECENTLY ACTIVATED -> RECENTLY CREATED PRODUCT)
     * */
    public static Map<String,String> getRecentActivatedProduct(Set<String> opnSet,List<Product2> newList){
        Map<String,String> opnToExisProdIdMap=new Map<String,String>();
        for(Product2 prod : [Select id,core_OPN__c from Product2 where core_OPN__c in :opnSet and Core_Product_org__c = 'Sales' and Core_Product_Type__c = :Label.PSG_Product_Type_Identifier and Id not in :newList  order by CreatedDate  desc]){
            if(!opnToExisProdIdMap.containsKey(prod.core_OPN__c)){
                opnToExisProdIdMap.put(prod.core_OPN__c,prod.Id);
            } 
        }
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
        List<Product2> Opn =[select Core_OPN__c from Product2 where id=:Prod_id];
        string fcopn=opn[0].Core_OPN__c;
        Query='Select Id,Name,core_cpq_fc_start_date_dt__c,core_cpq_fc_end_date_dt__c,price_forward_cost_amt__c,core_cpq_forward_cost_period_name_nm__c from price_forward_cost__c where core_cpq_product_opn_txt__c = :fcopn';
        try{
            if(sortby != null && sortOrder !=null){
                Query += ' ORDER BY '+sortby+' '+sortOrder;     
            } 
            if(String.isNotBlank(Query)){
               FcList=Database.query(Query); 
            }     
        }catch(Exception ex){
            PSG_Utility.logError(ex);
        }
        return FcList;
    }
}