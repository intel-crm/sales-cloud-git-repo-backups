/***************************************************************************************************
* Apex Class Name : Core_ProductAccess_Product_Handler
* Test Class Name : Core_ProductAccess_Product_Test
* Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Rickey Flores               15/2/2016               Created
* Ganapati                    22/11/2019              Modified for US517859 
****************************************************************************************************/
public without sharing class  Core_ProductAccess_Product_Handler{
    
    // Added by Ganapati for - US517859 - start
    private static final String PAR_HIDDEN = 'Par Hidden';
    private static final String APPROVAL_REQUIRED = 'Approval Required';
    private static final String AUTO_APPROVE = 'Auto Approve';
    // Added by Ganapati for - US517859 - end
    
    public static void duplicateRecordprevention(List<Core_IPS_MAP_Product__c> trgNew){
        if(Core_IPS_MAP_Product__c.SObjectType.getDescribe().isQueryable()){
            List<Core_IPS_MAP_Product__c> existingProducts=[Select Core_MAP_Supported_Product__c,Core_MAP_PAR__c from Core_IPS_MAP_Product__c where Core_MAP_PAR__c =:trgNew[0].Core_MAP_PAR__c];
            
            for(Core_IPS_MAP_Product__c newMapProducts: trgNew){
                for(Core_IPS_MAP_Product__c oldMapProducts: existingProducts){
                    if(oldMapProducts.Core_MAP_PAR__c==newMapProducts.Core_MAP_PAR__c && oldMapProducts.Core_MAP_Supported_Product__c==newMapProducts.Core_MAP_Supported_Product__c){
                        newMapProducts.adderror('Cannot add the same Supported Product twice');
                    }
                }
            }
        }
    }
    
    public static void createLineItems(List<Core_IPS_MAP_Product__c> trgNew){
        List<Core_IPS_MAP_Account__c> ajuncMAP = new List<Core_IPS_MAP_Account__c>();
        List<Core_IPS_Map_Par_Line_Item__c> lineitemsLISTMAP = new List<Core_IPS_Map_Par_Line_Item__c>();
        List<Id> mapParIds = new List<Id>();
        List<Id> pmapParIds = new List<Id>();
        List<Core_IPS_Map_Par_Line_Item__c> activatedLitems = new List<Core_IPS_Map_Par_Line_Item__c>();
        List<Core_IPS_Map_Par_Line_Item__c> newLineItemsToInsert = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(Core_IPS_MAP_Product__c mapacc : trgNew){ 
            pmapParIds.add(mapacc.Core_MAP_PAR__c);
        }
        if(!Core_IPS_MAPAccount_Dispatcher.DontExecuteTrigger){
            if (Core_IPS_MAP_PAR__c.SObjectType.getDescribe().isQueryable() ||Core_IPS_MAP_Product__c.SObjectType.getDescribe().isQueryable()||Core_IPS_Map_Par_Line_Item__c.SObjectType.getDescribe().isQueryable()) {
                Map<Id,Core_IPS_MAP_PAR__c> pmapParRecords=new Map<Id,Core_IPS_MAP_PAR__c>([select id,(Select id, Core_Account__c,Core_MAP_PAR__c,Core_MAP_PAR__r.RecordType.Name from MAP_Accounts__r) from Core_IPS_MAP_PAR__c where id IN : pmapParIds]);
                //  Added by Chiru - 20-08-24 - APEX GURU - SOQL FIX
                Map<Id, Core_IPS_MAP_Product__c> trgNewMap = new Map<Id, Core_IPS_MAP_Product__c>(trgNew);
                Map<Id,Core_IPS_MAP_Product__c> mapPrWithCoreProd=new Map<Id,Core_IPS_MAP_Product__c>([select id, name, Core_MAP_Supported_Product__r.id, Core_MAP_Supported_Product__r.Core_Supported_Product_Name__c, Core_MAP_Supported_Product__r.Core_Product__c from Core_IPS_MAP_Product__c where id IN: trgNewMap.keySet()]);
                
                List<Core_IPS_Map_Par_Line_Item__c> inactivelist = [select id,name, Core_Account__c, /*Core_Product__c,*/ Core_Supported_Product__c,Core_Supported_Product_EOIS__c from Core_IPS_Map_Par_Line_Item__c where Core_Status__c='INACTIVE' AND Core_MAP_PAR__c IN: pmapParIds];
                Set<Id> inactiveLitemAccounts = new Set<Id>();
                Set<Id> inactiveLitemProducts = new Set<Id>();
                for(Core_IPS_MAP_Product__c pMAP:trgNew){
                    if(pmapParRecords.get(pMap.Core_MAP_PAR__c).MAP_Accounts__r.size()>0){                         
                        for(Core_IPS_MAP_Account__c amAP:pmapParRecords.get(pMap.Core_MAP_PAR__c).MAP_Accounts__r){
                            if(inactivelist!=null && inactivelist.size()>0){
                                for(Core_IPS_Map_Par_Line_Item__c inactlitems: inactivelist){
                                    if(inactlitems.Core_Supported_Product__c == pmAP.Core_MAP_Supported_Product__c && inactlitems.Core_Account__c == aMAP.Core_Account__c){
                                        inactiveLitemAccounts.add(inactlitems.Core_Account__c);
                                        inactiveLitemProducts.add(inactlitems.Core_Supported_Product__c);
                                        inactlitems.Core_Status__c='ACTIVE';
                                        activatedLitems.add(inactlitems);
                                    }   
                                }
                            }
                            if(inactivelist!=null && inactivelist.size()>0 && (inactiveLitemAccounts.contains(aMAP.Core_Account__c) == false || inactiveLitemProducts.contains(pmAP.Core_MAP_Supported_Product__c) == false )){
                                Core_IPS_Map_Par_Line_Item__c insertlitem = new Core_IPS_Map_Par_Line_Item__c();
                                insertlitem.Core_Account__c=aMAP.Core_Account__c;
                                insertlitem.Core_MAP_PAR__c=aMAP.Core_MAP_PAR__c;
                                if(aMAP.Core_MAP_PAR__r.RecordType.Name  == 'MAP') {
                                    insertlitem.RecordTypeId = schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId();
                                } else if(aMAP.Core_MAP_PAR__r.RecordType.Name  == 'PAR'){
                                    insertlitem.RecordTypeId = schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId();
                                }  
                                insertlitem.Core_Status__c='ACTIVE';
                                insertlitem.Core_Supported_Product__c=mapPrWithCoreProd.get(pMap.id).Core_MAP_Supported_Product__r.id;
                                newLineItemsToInsert.add(insertlitem);    
                            }
                        }
                    }   
                }
                if (Core_IPS_Map_Par_Line_Item__c.SObjectType.getDescribe().isUpdateable()) {
                    if(activatedLitems !=null && activatedLitems.size()>0){
                        update activatedLitems;
                        Core_IPS_MAPAccount_Dispatcher.MAPAccountLineItemCreate =false;
                    }
                }
                if(newLineItemsToInsert.size()>0){
                    Core_Asset_Dispatcher.Assetfieldupdated = false;
                    if(Core_IPS_Map_Par_Line_Item__c.SObjectType.getDescribe().isCreateable()){
                        insert newLineItemsToInsert;
                    }
                    Core_ProductAccess_Product_Dispatcher.MAPProducttLineItemCreate = false;
                }
                //Create new line item- Product times the no of Accounts.
                if(Core_ProductAccess_Product_Dispatcher.MAPProducttLineItemCreate){
                    //Map<Id,Core_IPS_MAP_Product__c> mapPrWithCoreProd=new Map<Id,Core_IPS_MAP_Product__c>([select id, name, Core_MAP_Supported_Product__r.id, Core_MAP_Supported_Product__r.Core_Supported_Product_Name__c, Core_MAP_Supported_Product__r.Core_Product__c from Core_IPS_MAP_Product__c where id IN: trgNew]);
                    for(Core_IPS_MAP_Product__c pMAP:trgNew){                    
                        if(pmapParRecords.get(pMap.Core_MAP_PAR__c).MAP_Accounts__r.size()>0){
                            for(Core_IPS_MAP_Account__c amAP:pmapParRecords.get(pMap.Core_MAP_PAR__c).MAP_Accounts__r){
                                Core_IPS_Map_Par_Line_Item__c lineItemMAP = new Core_IPS_Map_Par_Line_Item__c();
                                lineItemMAP.Core_Account__c=aMAP.Core_Account__c;                            
                                lineItemMAP.Core_MAP_PAR__c=aMAP.Core_MAP_PAR__c;
                                //added by Roshan- 10/21/15
                                if(aMAP.Core_MAP_PAR__r.RecordType.Name  == 'MAP') {
                                    lineItemMAP.RecordTypeId = schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); 
                                } else if(aMAP.Core_MAP_PAR__r.RecordType.Name  == 'PAR') {
                                    lineItemMAP.RecordTypeId = schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId();
                                }
                                //added by Roshan- 10/21/15
                                lineItemMAP.Core_Status__c='ACTIVE';
                                lineItemMAP.Core_Supported_Product__c=mapPrWithCoreProd.get(pMap.id).Core_MAP_Supported_Product__r.id;
                                //lineItemMAP.Core_Supported_Product_Name__c=mapPrWithCoreProd.get(pMap.id).Core_MAP_Supported_Product__r.Core_Supported_Product_Name__c;-commented off Nov 30
                                lineitemsLISTMAP.add(lineItemMAP);
                            }  
                        }
                    }
                    if(Core_IPS_Map_Par_Line_Item__c.SObjectType.getDescribe().isCreateable()){
                        if(lineitemsLISTMAP.size()>0) {
                            insert lineitemsLISTMAP;       
                        }
                    }
                    
                } 
            }
        }
    }
    
    public static void deleteLineItems(List<Core_IPS_MAP_Product__c> trgOld){
        
        List<Id> oldMapParIds = new List<Id>();
        List<Id> lstProdIds = new List<ID>();
        List<Core_IPS_Map_Par_Line_Item__c> statusupdtList = new List<Core_IPS_Map_Par_Line_Item__c>();
        
        //for(Core_IPS_MAP_Product__c mapacc : trgOld){// Commented by ganapati for PMD fix
        if (Core_IPS_MAP_Product__c.SObjectType.getDescribe().isQueryable()) {
            for(Core_IPS_MAP_Product__c mapacc : [select id, name,Core_MAP_Supported_Product__r.Id, Core_MAP_Supported_Product__r.Core_Product__c,Core_MAP_PAR__c from Core_IPS_MAP_Product__c where Id IN :trgOld]){// Commented by ganapati for PMD fix
                //Core_IPS_MAP_Product__c triglist2=[select id, name, Core_MAP_Supported_Product__r.Core_Product__c,Core_MAP_PAR__c from Core_IPS_MAP_Product__c where id=: mapacc.id];
                //lstProdIds.add(triglist2.Core_MAP_Supported_Product__r.Core_Product__c);
                //lstProdIds.add(triglist2.Core_MAP_Supported_Product__r.id);// Commented by ganapati for PMD fix
                lstProdIds.add(mapacc.Core_MAP_Supported_Product__r.Id);
                oldMapParIds.add(mapacc.Core_MAP_PAR__c);
            }
        }
        
        
        //Remove the line items and also unshare and expire the assets for those supported products that are bring deleted.
        //Deleting Line Items
        if (Core_IPS_Map_Par_Line_Item__c.SObjectType.getDescribe().isQueryable()) {
            List<Core_IPS_Map_Par_Line_Item__c> statusupdt= [Select Core_Account__c,Core_MAP_PAR__c from Core_IPS_Map_Par_Line_Item__c where /*Core_Product__c=:lstProdIds*/ Core_Supported_Product__c=:lstProdIds and Core_MAP_PAR__c IN : oldMapParIds];
            for(Core_IPS_Map_Par_Line_Item__c mpli:statusupdt){
                mpli.Core_Status__c='INACTIVE';
                statusupdtList.add(mpli);
            }
        }
        
        
        if (Core_IPS_Map_Par_Line_Item__c.SObjectType.getDescribe().isUpdateable()) {
            update statusupdtList;
        }
        
        
    }
    
    /*   public static void getMapProdChangeCount(List<Core_IPS_MAP_Product__c> trgNew){
Set<Id> mapProdIds= new Set<Id>();
MAP<Id, Core_IPS_MAP_PAR__c> mapRecsMap = new MAP<Id, Core_IPS_MAP_PAR__c>(); 
List<Core_IPS_MAP_PAR__c> updateMAPLst = new List<Core_IPS_MAP_PAR__c>();

for(Core_IPS_MAP_Product__c prodids : trgNew){
mapProdIds.add(prodids.Core_MAP_PAR__c);
}
List<Core_IPS_MAP_PAR__c> mapRecords = new List<Core_IPS_MAP_PAR__c>([select Id, Core_IPS_MAP_Count_Supp_prod__c, (Select Id, Core_MAP_Supported_Product__r.Id, Core_MAP_Supported_Product__r.Core_Flag_Status__c, Core_MAP_PAR__c, Core_MAP_PAR__r.RecordType.Name from MAP_Supported_Products__r) from Core_IPS_MAP_PAR__c WHERE Id IN : mapProdIds AND RecordType.Name = 'MAP']); 
for(Core_IPS_MAP_PAR__c mapRecd : mapRecords ){
mapRecd.Core_IPS_MAP_Count_Supp_prod__c = mapRecd.MAP_Supported_Products__r.size();
updateMAPLst.add(mapRecd);
}
if(!updateMAPLst.isEmpty()) {
update updateMAPLst;
}
} */
    
    /***************************************************************************************************
Method Name: getCasesWithOrgConfigSet
Version     : 1.0 
Created Date: 27 August 2019
Description : This method takes the list of Core_IPS_MAP_Product__c and sets the access flag on MAP.
* Developer                   Date                   Description
* --------------------------------------------------------------------------------------------------               
* Ganapati                  22/11/2019           Created for US517859
* Ranjini                   21/9/2020           Created for US767983
****************************************************************************************************/    
    public static void setAccessFlagOnMAP(List<Core_IPS_MAP_Product__c> trgNew) {
        Set<Id> pmapParIds = new Set<Id>();
        List<Core_IPS_MAP_PAR__c> mapRecords = new List<Core_IPS_MAP_PAR__c>();
        MAP<Id, Core_IPS_MAP_PAR__c> mapRecsMap = new MAP<Id, Core_IPS_MAP_PAR__c>(); 
        List<Core_IPS_MAP_PAR__c> updateMAPLst = new List<Core_IPS_MAP_PAR__c>();
        
        for(Core_IPS_MAP_Product__c mapProd : trgNew){ 
            pmapParIds.add(mapProd.Core_MAP_PAR__c);
        } 
        
        if(Core_IPS_MAP_PAR__c.SObjectType.getDescribe().isAccessible()){ //FLS check already added - Aditya
             mapRecords=new List<Core_IPS_MAP_PAR__c>([select Id,Core_IPS_MAP_Access_Flag__c,Core_IPS_MAP_Count_Supp_prod__c, (Select Id, Core_MAP_Supported_Product__r.Id, Core_MAP_Supported_Product__r.Core_Flag_Status__c, Core_MAP_PAR__c, Core_MAP_PAR__r.RecordType.Name from MAP_Supported_Products__r) from Core_IPS_MAP_PAR__c WHERE Id IN : pmapParIds AND RecordType.Name = 'MAP']);
        }
                //both if loop added by ranjini for DE93122
        if(mapRecords.size()>0 ){
            if(mapRecords[0].MAP_Supported_Products__r.size()!=null && mapRecords[0].MAP_Supported_Products__r.size()>0){
         
            if(mapRecords[0].MAP_Supported_Products__r.size()==1){
                for(Core_IPS_MAP_PAR__c mapRec : mapRecords) {
                    Integer parHiddenProdCnt = 0;
                    Integer approvalReqProdCnt = 0;
                    Integer autoApproveProdCnt = 0;
                    mapRec.Core_IPS_MAP_Access_Flag__c = '';
                    
                    mapRec.Core_IPS_MAP_Count_Supp_prod__c = mapRec.MAP_Supported_Products__r.size();
                    updateMAPLst.add(mapRec);
                    
                    if(mapRec.MAP_Supported_Products__r.size() == 0 ) {
                        mapRecsMap.put(mapRec.Id, mapRec);
                    }
                    for(Core_IPS_MAP_Product__c mapProduct : mapRec.MAP_Supported_Products__r) {
                        String accessFlag = mapProduct.Core_MAP_Supported_Product__r.Core_Flag_Status__c;
                        if(PAR_HIDDEN.equalsIgnoreCase(accessFlag)) {
                            parHiddenProdCnt++;
                        } else if(APPROVAL_REQUIRED.equalsIgnoreCase(accessFlag)) {
                            approvalReqProdCnt++;
                        }  else if(AUTO_APPROVE.equalsIgnoreCase(accessFlag)) {
                            autoApproveProdCnt++;
                        } 
                    }
                    if(parHiddenProdCnt>0) {
                        mapRec.Core_IPS_MAP_Access_Flag__c = PAR_HIDDEN;
                    } else if(approvalReqProdCnt > 0) {
                        mapRec.Core_IPS_MAP_Access_Flag__c = APPROVAL_REQUIRED;
                    } else if(autoApproveProdCnt > 0) {
                        mapRec.Core_IPS_MAP_Access_Flag__c = AUTO_APPROVE;
                    } else {
                        mapRec.Core_IPS_MAP_Access_Flag__c = '';
                    }
                    if(!mapRecsMap.containsKey(mapRec.Id)) {
                        mapRecsMap.put(mapRec.Id, mapRec);
                    } else {
                        mapRecsMap.remove(mapRec.Id);
                        mapRecsMap.put(mapRec.Id, mapRec);
                    }
                }
            }
        }
        }
           
        
        if( !mapRecsMap.isEmpty() ) { 
            update mapRecsMap.values(); 
        }
        
        /*  for(Core_IPS_MAP_PAR__c mapRecd : mapRecords ){
mapRecd.Core_IPS_MAP_Count_Supp_prod__c = mapRecd.MAP_Supported_Products__r.size();
updateMAPLst.add(mapRecd);
}       
if(!updateMAPLst.isEmpty()) {
update updateMAPLst;
}*/
        
    }
}