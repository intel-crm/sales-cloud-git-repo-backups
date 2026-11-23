public class Core_IPS_MAPAccount_Handler{
    /***************************************************************************************************
    Method Name:  DuplicateRecordprevention
    Method Type: Core_IPS_MAPAccount_Handler Method 
    Version     : 1.0 
    Created Date: 20 Aug 2015
    Function    : This method is used to prevent the addition of a duplicate record (OOTB Duplicate rules were not helpful)
    Input Parameters: Trigger.New List
    Output Parameters: None
    Description:   This method takes in the new list and checks the record to be added against the list of records that are already present
    Used in     : 
    Number of Queries Within this Method: 1
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        08/20/2015              Created
    ****************************************************************************************************/ 
    public static void DuplicateRecordprevention(List<Core_IPS_MAP_Account__c> TrgNew){
        List<Core_IPS_MAP_Account__c> ExistingAccounts=[Select Core_Account__c,Core_MAP_PAR__c from Core_IPS_MAP_Account__c where Core_MAP_PAR__c =:TrgNew[0].Core_MAP_PAR__c];
        
        for(Core_IPS_MAP_Account__c NewMapAccounts: TrgNew){
            for(Core_IPS_MAP_Account__c OldMapAccounts: ExistingAccounts){
                if(OldMapAccounts.Core_MAP_PAR__c==NewMapAccounts.Core_MAP_PAR__c && OldMapAccounts.Core_Account__c==NewMapAccounts.Core_Account__c)
                    NewMapAccounts.adderror('Cannot add the same Account twice');                
            }
        }
    }
    
    /***************************************************************************************************
    Method Name:  createLineItems
    Method Type: Core_IPS_MAPAccount_Handler Method 
    Version     : 1.0 
    Created Date: 05 Aug 2015
    Function    : This method is used to create Line Items 
    Input Parameters: Trigger.New List
    Output Parameters: None
    Description:   This method takes in the new list and creates new Line items if no inactive exist or re-activate Inactive LineItems
    Used in     : 
    Number of Queries Within this Method: 2
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        08/05/2015              Created
    ****************************************************************************************************/ 
    public static void createLineItems(List<Core_IPS_MAP_Account__c> TrgNew){    
        List<Core_IPS_MAP_Product__c> pjuncMAP = new List<Core_IPS_MAP_Product__c>();
        List<Core_IPS_Map_Par_Line_Item__c> lineitemsLISTMAP = new List<Core_IPS_Map_Par_Line_Item__c>();
        List<Id> mapParIds = new List<Id>();
        List<Core_IPS_Map_Par_Line_Item__c> activatedLitems = new List<Core_IPS_Map_Par_Line_Item__c>();
        List<Core_IPS_Map_Par_Line_Item__c> EOISLitems = new List<Core_IPS_Map_Par_Line_Item__c>();          
        List<Core_IPS_Map_Par_Line_Item__c> newLineItemsToInsert = new List<Core_IPS_Map_Par_Line_Item__c>();
        for(Core_IPS_MAP_Account__c mapacc : TrgNew){
            mapParIds.add(mapacc.Core_MAP_PAR__c);
        }
        
        if(!Core_IPS_MAPAccount_Dispatcher.DontExecuteTrigger){
            Map<Id,Core_IPS_MAP_PAR__c> mapParRecords=new Map<Id,Core_IPS_MAP_PAR__c>([select id,RecordType.Name,(Select id,Core_MAP_Supported_Product__r.Core_Supported_Product_Name__c,Core_MAP_Supported_Product__r.id, Core_MAP_Supported_Product__r.Core_Product__c,Core_MAP_PAR__c,Core_MAP_PAR__r.RecordType.Name from MAP_Supported_Products__r) from Core_IPS_MAP_PAR__c where id IN : mapParIds]);
            List<Core_IPS_Map_Par_Line_Item__c> inactlitemlist = [select id, name,Core_Account__c,Core_Supported_Product_EOIS__c,RecordTypeId,recordType.Name,Core_Supported_Product__c from Core_IPS_Map_Par_Line_Item__c where Core_Status__c='INACTIVE' and Core_MAP_PAR__c IN: MapParIDs];            
            Set<Id> inactiveLitemAccounts = new Set<Id>();
            Set<Id> inactiveLitemProducts = new Set<Id>();
                for(Core_IPS_MAP_Account__c aMAP:TrgNew){
                    if(mapParRecords.get(aMap.Core_MAP_PAR__c).MAP_Supported_Products__r.size()>0){
                        for(Core_IPS_MAP_Product__c pmAP: mapParRecords.get(aMap.Core_MAP_PAR__c).MAP_Supported_Products__r){    
                            if(inactlitemlist!=null && inactlitemlist.size()>0){
                                for(Core_IPS_Map_Par_Line_Item__c inactlitem: inactlitemlist){
                                    if(inactlitem.Core_Account__c==aMAP.Core_Account__c && inactlitem.Core_Supported_Product__c == pmAP.Core_MAP_Supported_Product__c ){
                                        inactiveLitemAccounts.add(inactlitem.Core_Account__c);
                                        inactiveLitemProducts.add(inactlitem.Core_Supported_Product__c);
                                        if(inactlitem.Core_Supported_Product_EOIS__c <> true){
                                            inactlitem.Core_Status__c='ACTIVE';
                                            activatedLitems.add(inactlitem);
                                            system.debug('activated &&&&&&&&'+activatedLitems);
                                        }else{
                                            EOISLitems.add(inactlitem);
                                        }                                        
                                    }                                 
                                }  
                            }
                            system.debug('Acc&&&&&&&&'+inactiveLitemAccounts.contains(aMAP.Core_Account__c));
                            system.debug('Product&&&&&'+inactiveLitemProducts.contains(pmAP.Core_MAP_Supported_Product__c));
                            if(inactlitemlist!=null && inactlitemlist.size()>0 && (inactiveLitemAccounts.contains(aMAP.Core_Account__c) == false || inactiveLitemProducts.contains(pmAP.Core_MAP_Supported_Product__c) == false )){
                                system.debug('I am here&&&&&&&&&&&&');
                                Core_IPS_Map_Par_Line_Item__c insertlitem = new Core_IPS_Map_Par_Line_Item__c();
                                insertlitem.Core_Account__c=aMAP.Core_Account__c;
                                insertlitem.Core_MAP_PAR__c=pmAP.Core_MAP_PAR__c;
                                if(pmAP.Core_MAP_PAR__r.RecordType.Name  == 'MAP')
                                    insertlitem.RecordTypeId = schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId();
                                else if(pmAP.Core_MAP_PAR__r.RecordType.Name  == 'PAR')
                                    insertlitem.RecordTypeId = schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId();
                                insertlitem.Core_Status__c='ACTIVE';
                                insertlitem.Core_Supported_Product__c=pmap.Core_MAP_Supported_Product__r.id;                                
                                newLineItemsToInsert.add(insertlitem);    
                            }
                        }
                    }   
                
            }
            system.debug('activated size&&&&&&&&&'+activatedLitems.size());
            if(activatedLitems !=null && activatedLitems.size()>0){
                system.debug('coming here&&&&&&&&&&&&&');
                update activatedLitems;
                Core_IPS_MAPAccount_Dispatcher.MAPAccountLineItemCreate =false;
            }
            if(newLineItemsToInsert <> null && newLineItemsToInsert.size()>0){
                Core_Asset_Dispatcher.Assetfieldupdated = false;
                insert newLineItemsToInsert;
                Core_IPS_MAPAccount_Dispatcher.MAPAccountLineItemCreate =false;
            }
            if(EOISLitems.size()>0){
                Core_IPS_MAPAccount_Dispatcher.MAPAccountLineItemCreate =false;
            }
            

            if(Core_IPS_MAPAccount_Dispatcher.MAPAccountLineItemCreate){
                for(Core_IPS_MAP_Account__c aMAP:TrgNew){
                    if(mapParRecords.get(aMap.Core_MAP_PAR__c).MAP_Supported_Products__r.size()>0){
                        for(Core_IPS_MAP_Product__c pmAP:mapParRecords.get(aMap.Core_MAP_PAR__c).MAP_Supported_Products__r){
                            Core_IPS_Map_Par_Line_Item__c lineItemMAP = new Core_IPS_Map_Par_Line_Item__c();
                            lineItemMAP.Core_Account__c=aMAP.Core_Account__c;
                            lineItemMAP.Core_MAP_PAR__c=pmAP.Core_MAP_PAR__c;
                            if(pmAP.Core_MAP_PAR__r.RecordType.Name  == 'MAP')
                                lineItemMAP.RecordTypeId = schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('MAP').getRecordTypeId();
                            else if(pmAP.Core_MAP_PAR__r.RecordType.Name  == 'PAR')
                                lineItemMAP.RecordTypeId = schema.sobjecttype.Core_IPS_Map_Par_Line_Item__c.getrecordtypeinfosbyname().get('PAR').getRecordTypeId();
                            lineItemMAP.Core_Status__c='ACTIVE';
                            lineItemMAP.Core_Supported_Product__c=pmap.Core_MAP_Supported_Product__r.id;
                            //lineItemMAP.Core_Supported_Product_Name__c=pmAP.Core_MAP_Supported_Product__r.Core_Supported_Product_Name__c;-commented off Nov 30
                            lineitemsLISTMAP.add(lineItemMAP);
                        }
                    }
                    
                }
                if(lineitemsLISTMAP.size()>0)
                insert lineitemsLISTMAP;
            }         
        }
    }
    
    /***************************************************************************************************
    Method Name:  DeleteLineItems
    Method Type: Core_IPS_MAPAccount_Handler Method 
    Version     : 1.0 
    Created Date: 05 Aug 2015
    Function    : This method is used to Inactivate Line Items 
    Input Parameters: Trigger.New List
    Output Parameters: None
    Description:   This method takes in the old list and Inactives the existing Line Items with the same Account that is deleted
    Used in     : 
    Number of Queries Within this Method: 1
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        08/05/2015              Created
    ****************************************************************************************************/ 
    public static void DeleteLineItems(List<Core_IPS_MAP_Account__c> TrgOld){    
        List<Id> lstAccIds = new List<ID>();
        List<ID> oldMapParIds = new List<ID>();
        List<Core_IPS_Map_Par_Line_Item__c> StatusupdtList = new List<Core_IPS_Map_Par_Line_Item__c>();
        
        for(Core_IPS_MAP_Account__c mapacc : TrgOld){
            lstAccIds.add(mapacc.Core_Account__c);
            oldMapParIds.add(mapacc.Core_MAP_PAR__c);
        }
        List<Core_IPS_Map_Par_Line_Item__c> statusupdt= [Select Core_Account__c,Core_MAP_PAR__c from Core_IPS_Map_Par_Line_Item__c where Core_Account__c IN: lstAccIds and Core_MAP_PAR__c IN : oldMapParIds];
        for(Core_IPS_Map_Par_Line_Item__c mpli:statusupdt){
            mpli.Core_Status__c='INACTIVE';
            StatusupdtList.add(mpli);
        }
        if(StatusupdtList!=null)
            update StatusupdtList;
    }
    
    /***************************************************************************************************
    Method Name:  DeleteLineItems
    Method Type: Core_IPS_MAPAccount_Handler Method 
    Version     : 1.0 
    Created Date: 05 Aug 2015
    Function    : This method is used to Inactivate Line Items 
    Input Parameters: Trigger.New List
    Output Parameters: None
    Description:   This method takes in the old list and Inactives the existing Line Items with the same Account that is deleted
    Used in     : 
    Number of Queries Within this Method: 1
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        08/05/2015              Created
    ****************************************************************************************************/ 
    @future
    public static void SharetoFAE(String serializedList){
        List<Core_IPS_MAP_Account__c> newList = (List<Core_IPS_MAP_Account__c>)JSON.deserialize(serializedList, List<Core_IPS_MAP_Account__c>.class);
        List<Core_IPS_MAP_Account__c> listAccountJo = [Select id,Core_Account__c,Core_MAP_PAR__c from Core_IPS_MAP_Account__c where id IN: newList];
        Set<Id> AccountSet = new Set<Id>();
        Map<Id,Set<id>> faesByMAP = new Map<Id,Set<id>>();
        for(Core_IPS_MAP_Account__c AccJo: listAccountJo){
            AccountSet.add(AccJo.Core_Account__c);
        }
        //Generate Header and Account map collection
        Map<Id,Set<Id>> AccountsByMap = getAccountsByMap(newList);
        //Generate Account and FAEList map collection 
        Map<Id,Set<Id>> faesByAccount = Core_IPS_Helper_Utility.getFAEsByAccount(AccountSet);
        //Generate Map and FAElist map collection
        if((AccountsByMap <> null && AccountsByMap.size()>0) && (faesByAccount <> null && faesByAccount.size()>0))
        faesByMAP = getFAEsbyMAP(AccountsByMap,faesByAccount);
        //Give Access to FAE to the created MAPs
        Core_SharingUtility.provideAccess('Core_IPS_MAP_PAR__c', 'Core_IPS_MAP_PAR__Share', 'Read', faesByMAP);

    }
    
    /***************************************************************************************************
    Method Name:  DeleteLineItems
    Method Type: Core_IPS_MAPAccount_Handler Method 
    Version     : 1.0 
    Created Date: 05 Aug 2015
    Function    : This method is used to Inactivate Line Items 
    Input Parameters: Trigger.New List
    Output Parameters: None
    Description:   This method takes in the old list and Inactives the existing Line Items with the same Account that is deleted
    Used in     : 
    Number of Queries Within this Method: 1
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        08/05/2015              Created
    ****************************************************************************************************/ 
    public static Map<Id,Set<Id>> getAccountsByMap(List<Core_IPS_MAP_Account__c> JOList){            
        Map<Id,Set<Id>> AccountsByMAP = new Map<Id,Set<Id>>();
            Set<Id> HeaderIdList = new Set<Id>();
            for(Core_IPS_MAP_Account__c AccJo: JOList){
                HeaderIdList.add(AccJo.Core_MAP_PAR__c);
            }
        List<Core_IPS_MAP_PAR__c> HeaderList = [Select id from Core_IPS_MAP_PAR__c where Recordtype.Name = 'PAR' and id IN: HeaderIdList];
            for(Core_IPS_MAP_PAR__c Header: HeaderList){
                Set<Id> accountIdList = new Set<Id>();
                for(Core_IPS_MAP_Account__c AccJO: JOList){
                    if(Header.id == AccJO.Core_MAP_PAR__c)
                    accountIdList.add(AccJO.Core_Account__c);
                }
                AccountsByMap.put(Header.id,accountIdList);
            }
        return AccountsByMap;
    }
    
    /***************************************************************************************************
    Method Name:  DeleteLineItems
    Method Type: Core_IPS_MAPAccount_Handler Method 
    Version     : 1.0 
    Created Date: 05 Aug 2015
    Function    : This method is used to Inactivate Line Items 
    Input Parameters: Trigger.New List
    Output Parameters: None
    Description:   This method takes in the old list and Inactives the existing Line Items with the same Account that is deleted
    Used in     : 
    Number of Queries Within this Method: 1
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        08/05/2015              Created
    ****************************************************************************************************/ 
    public static Map<Id,Set<id>> getFAEsbyMAP(Map<Id,Set<Id>> AccountsByMap, Map<Id,Set<Id>> faesByAccount){
        Set<Id> MAPIdSet = AccountsByMap.keySet();
        Map<Id, Set<Id>> faesByMAP = new Map<Id, Set<Id>>();
        for(Id MAPId: MAPIdSet){
            for(Id accId: AccountsByMap.get(MAPId)){
                Set<Id> userIdSet = new Set<Id>();
                for(Id userId:faesByAccount.get(accId)){
                    userIdSet.add(userId);
                }
                if(userIdSet.size()>0 && userIdSet <> null)
                   faesByMAP.put(MAPId,userIdSet); 
            }
        }
        return faesByMAP;
    }
    
     /***************************************************************************************************
    Method Name:  getMapAcctChangeCount
    Method Type: Core_IPS_MAPAccount_Handler Method 
    Version     : 1.0 
    Created Date: 02 Dec 2019
    Function    : This method is used to track additon/deletion of MAP records for Product Access History 
    Input Parameters: Trigger.New List
    Output Parameters: None
    Description:   This method takes in the old list and Inactives the existing Line Items with the same Account that is deleted
    Used in     : Core_IPS_MAPAccount_Dispatcher
    Number of Queries Within this Method: 1
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * Sumukh                   03/12/2019                 Created
    ****************************************************************************************************/     
    public static void getMapAcctChangeCount(List<Core_IPS_MAP_Account__c> newList){
       Set<Id> mapAcctIds= new Set<Id>();
       MAP<Id, Core_IPS_MAP_PAR__c> mapRecsMap = new MAP<Id, Core_IPS_MAP_PAR__c>(); 
       List<Core_IPS_MAP_PAR__c> updateMAPLst = new List<Core_IPS_MAP_PAR__c>();
         
         for(Core_IPS_MAP_Account__c acctids : newList){            
            mapAcctIds.add(acctids.Core_MAP_PAR__c);
         }
         List<Core_IPS_MAP_PAR__c> mapRecords = new List<Core_IPS_MAP_PAR__c>([select Id, Core_IPS_MAP_Count_Supp_acct__c, (Select Id, Core_Account__c, Core_MAP_PAR__c, Core_MAP_PAR__r.RecordType.Name from MAP_Accounts__r) from Core_IPS_MAP_PAR__c WHERE Id IN : mapAcctIds AND RecordType.Name = 'MAP']); 
          for(Core_IPS_MAP_PAR__c mapRecd : mapRecords ){
             mapRecd.Core_IPS_MAP_Count_Supp_acct__c= mapRecd.MAP_Accounts__r.size();
             updateMAPLst.add(mapRecd);
          }
        if(!updateMAPLst.isEmpty()) {
          update updateMAPLst;
        }
    } 
    /*** End by sumukh ***/  
    
}