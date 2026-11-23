public class Core_ProductAccess_Product_Handler{

    public static void DuplicateRecordprevention(List<Core_IPS_MAP_Product__c> TrgNew){
        List<Core_IPS_MAP_Product__c> ExistingProducts=[Select Core_MAP_Supported_Product__c,Core_MAP_PAR__c from Core_IPS_MAP_Product__c where Core_MAP_PAR__c =:TrgNew[0].Core_MAP_PAR__c];
        for(Core_IPS_MAP_Product__c NewMapProducts: TrgNew){
            for(Core_IPS_MAP_Product__c OldMapProducts: ExistingProducts){
                if(OldMapProducts.Core_MAP_PAR__c==NewMapProducts.Core_MAP_PAR__c && OldMapProducts.Core_MAP_Supported_Product__c==NewMapProducts.Core_MAP_Supported_Product__c)
                    NewMapProducts.adderror('Cannot add the same Supported Product twice');
                
            }
        }
    }
    
    public static void createLineItems(List<Core_IPS_MAP_Product__c> TrgNew){
    
        List<Core_IPS_MAP_Account__c> ajuncMAP = new List<Core_IPS_MAP_Account__c>();
        List<Core_IPS_Map_Par_Line_Item__c> lineitemsLISTMAP = new List<Core_IPS_Map_Par_Line_Item__c>();
        List<Id> mapParIds = new List<Id>();
        List<Id> pmapParIds = new List<Id>();
        List<Core_IPS_Map_Par_Line_Item__c> activatedLitems = new List<Core_IPS_Map_Par_Line_Item__c>();
        List<Core_IPS_Map_Par_Line_Item__c> newLineItemsToInsert = new List<Core_IPS_Map_Par_Line_Item__c>();
    
        for(Core_IPS_MAP_Product__c mapacc : TrgNew){ 
            pmapParIds.add(mapacc.Core_MAP_PAR__c);
        }
        if(!Core_IPS_MAPAccount_Dispatcher.DontExecuteTrigger){
        Map<Id,Core_IPS_MAP_PAR__c> pmapParRecords=new Map<Id,Core_IPS_MAP_PAR__c>([select id,(Select id, Core_Account__c,Core_MAP_PAR__c,Core_MAP_PAR__r.RecordType.Name from MAP_Accounts__r) from Core_IPS_MAP_PAR__c where id IN : pmapParIds]);
            Map<Id,Core_IPS_MAP_Product__c> mapPrWithCoreProd=new Map<Id,Core_IPS_MAP_Product__c>([select id, name, Core_MAP_Supported_Product__r.id, Core_MAP_Supported_Product__r.Core_Supported_Product_Name__c, Core_MAP_Supported_Product__r.Core_Product__c from Core_IPS_MAP_Product__c where id IN: TrgNew]);
            List<Core_IPS_Map_Par_Line_Item__c> inactivelist = [select id,name, Core_Account__c, /*Core_Product__c,*/ Core_Supported_Product__c,Core_Supported_Product_EOIS__c from Core_IPS_Map_Par_Line_Item__c where Core_Status__c='INACTIVE' AND Core_MAP_PAR__c IN: pmapParIds];
            Set<Id> inactiveLitemAccounts = new Set<Id>();
            Set<Id> inactiveLitemProducts = new Set<Id>();
                for(Core_IPS_MAP_Product__c pMAP:TrgNew){
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
                                    if(aMAP.Core_MAP_PAR__r.RecordType.Name  == 'MAP')
                                        insertlitem.RecordTypeId = schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId();
                                    else if(aMAP.Core_MAP_PAR__r.RecordType.Name  == 'PAR')
                                        insertlitem.RecordTypeId = schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId();
                                insertlitem.Core_Status__c='ACTIVE';
                                insertlitem.Core_Supported_Product__c=mapPrWithCoreProd.get(pMap.id).Core_MAP_Supported_Product__r.id;
                                newLineItemsToInsert.add(insertlitem);    
                            }
                        }
                    }   
                }
            if(activatedLitems !=null && activatedLitems.size()>0){
                system.debug('coming here&&&&&&&&&&&&&');
                update activatedLitems;
                Core_IPS_MAPAccount_Dispatcher.MAPAccountLineItemCreate =false;
            }
            if(newLineItemsToInsert.size()>0){
               Core_Asset_Dispatcher.Assetfieldupdated = false;
               insert newLineItemsToInsert;
               Core_ProductAccess_Product_Dispatcher.MAPProducttLineItemCreate = false;
            }

    
            
            //Create new line item- Product times the no of Accounts.
            if(Core_ProductAccess_Product_Dispatcher.MAPProducttLineItemCreate){
                //Map<Id,Core_IPS_MAP_Product__c> mapPrWithCoreProd=new Map<Id,Core_IPS_MAP_Product__c>([select id, name, Core_MAP_Supported_Product__r.id, Core_MAP_Supported_Product__r.Core_Supported_Product_Name__c, Core_MAP_Supported_Product__r.Core_Product__c from Core_IPS_MAP_Product__c where id IN: TrgNew]);
                for(Core_IPS_MAP_Product__c pMAP:TrgNew){                    
                    if(pmapParRecords.get(pMap.Core_MAP_PAR__c).MAP_Accounts__r.size()>0){
                        for(Core_IPS_MAP_Account__c amAP:pmapParRecords.get(pMap.Core_MAP_PAR__c).MAP_Accounts__r){
                            Core_IPS_Map_Par_Line_Item__c lineItemMAP = new Core_IPS_Map_Par_Line_Item__c();
                            lineItemMAP.Core_Account__c=aMAP.Core_Account__c;                            
                            lineItemMAP.Core_MAP_PAR__c=aMAP.Core_MAP_PAR__c;
                             //added by Roshan- 10/21/15
                                if(aMAP.Core_MAP_PAR__r.RecordType.Name  == 'MAP')
                                    lineItemMAP.RecordTypeId = schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId(); 
                                else if(aMAP.Core_MAP_PAR__r.RecordType.Name  == 'PAR')
                                    lineItemMAP.RecordTypeId = schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId();
                                //added by Roshan- 10/21/15
                            lineItemMAP.Core_Status__c='ACTIVE';
                            lineItemMAP.Core_Supported_Product__c=mapPrWithCoreProd.get(pMap.id).Core_MAP_Supported_Product__r.id;
                            //lineItemMAP.Core_Supported_Product_Name__c=mapPrWithCoreProd.get(pMap.id).Core_MAP_Supported_Product__r.Core_Supported_Product_Name__c;-commented off Nov 30
                            lineitemsLISTMAP.add(lineItemMAP);
                        }  
                    }
                }
               if(lineitemsLISTMAP.size()>0)             
               insert lineitemsLISTMAP;       
            } 
        } 
              
        }
             
    
    
    public static void DeleteLineItems(List<Core_IPS_MAP_Product__c> TrgOld){
    
        List<Id> oldMapParIds = new List<Id>();
        List<Id> lstProdIds = new List<ID>();
        List<Core_IPS_Map_Par_Line_Item__c> StatusupdtList = new List<Core_IPS_Map_Par_Line_Item__c>();
    
        for(Core_IPS_MAP_Product__c mapacc : TrgOld){
            Core_IPS_MAP_Product__c Triglist2=[select id, name, Core_MAP_Supported_Product__r.Core_Product__c,Core_MAP_PAR__c from Core_IPS_MAP_Product__c where id=: mapacc.id];
            //lstProdIds.add(Triglist2.Core_MAP_Supported_Product__r.Core_Product__c);
            lstProdIds.add(Triglist2.Core_MAP_Supported_Product__r.id);
            oldMapParIds.add(mapacc.Core_MAP_PAR__c);
        }
        
        //Remove the line items and also unshare and expire the assets for those supported products that are bring deleted.
        //Deleting Line Items
        List<Core_IPS_Map_Par_Line_Item__c> statusupdt= [Select Core_Account__c,Core_MAP_PAR__c from Core_IPS_Map_Par_Line_Item__c where /*Core_Product__c=:lstProdIds*/ Core_Supported_Product__c=:lstProdIds and Core_MAP_PAR__c IN : oldMapParIds];
            for(Core_IPS_Map_Par_Line_Item__c mpli:statusupdt){
                mpli.Core_Status__c='INACTIVE';
                StatusupdtList.add(mpli);
            }
            update StatusupdtList;
        
    }

}