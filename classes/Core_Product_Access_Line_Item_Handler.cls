public class Core_Product_Access_Line_Item_Handler{
    
    /*This method is only for migration purposes*/
    public static void inactivateLItemmigrationonly(List<Core_IPS_Map_Par_Line_Item__c> newList){
        List<Core_IPS_Map_Par_Line_Item__c> lItemList = new List<Core_IPS_Map_Par_Line_Item__c>();
        List<Core_IPS_Map_Par_Line_Item__c> lItems = [Select id,Core_Supported_Product_EOIS__c,Core_Status__c from Core_IPS_Map_Par_Line_Item__c where id IN: newList];
        for(Core_IPS_Map_Par_Line_Item__c lItem: lItems){
            if(lItem.Core_Supported_Product_EOIS__c == true){
                lItem.Core_Status__c = 'INACTIVE';
                lItemList.add(lItem);
            }
        }
        update lItemList;
    }

   
    public static List<Asset> getActiveAssets(List<String> AccountidList, List<String> SupProdList){      
            List<Asset> assetList;      
            if(AccountidList!=null && AccountidList.get(0)!=null && AccountidList.get(0).startsWith('001')){        
                assetList = [SELECT id, accountId, contactId, product2Id,Core_Supported_Product__c , Core_Product_Organization__c,Core_Map_List__c from asset where accountid IN: AccountidList and Core_Supported_Product__c IN:SupProdList and Status!='Inactive'];       
            }
            System.debug('Existing Assets>>>>>>>>>>>>>>>>>'+assetList);       
            return assetList;       
    }       
            
    public static List<Asset> getInactiveAssets(List<String> AccountidList, List<String> SupProdList){        
        List<Asset> InactiveAssetList;      
            if(AccountidList.get(0).startsWith('001')){      
                InactiveAssetList = [Select id, accountId, contactId, product2Id,Core_Supported_Product__c , Core_Product_Organization__c,Core_Map_List__c from asset where accountid IN: AccountidList and Core_Supported_Product__c IN:SupProdList and Status='Inactive'];         
            }
            System.debug('Inactive Assets>>>>>>>>>>>>>>>>>'+InactiveAssetList);
            return InactiveAssetList;       
    }
    
    public static void submitPARForApproval(List<Core_IPS_Map_Par_Line_Item__c> newList){
        List<Core_IPS_Map_Par_Line_Item__c> mliList= new List<Core_IPS_Map_Par_Line_Item__c>();
        List<Core_IPS_Map_Par_Line_Item__c> mliList1= new List<Core_IPS_Map_Par_Line_Item__c>();
        // Set<String> accountIdSet = new Set<String>();
        for(Core_IPS_Map_Par_Line_Item__c mli: newList){
            system.debug('###testw1'+mli);
            if(mli.Core_isPARRequest__c==true && mli.Core_Approval_Type__c=='Approval Required'){
                mliList.add(mli);
                // accountIdSet.add(mli.Core_Account__c);  
            }
        }

        // Map<Id,Core_IPS_Map_Par_Line_Item__c> lineItemMap = new Map<id,Core_IPS_Map_Par_Line_Item__c>([select id, Core_MAP_PAR__r.Core_Product_Organization__c from Core_IPS_Map_Par_Line_Item__c where Id in:mliList]);
        // List<String> actidList = new List<String>();
            // if(accountIdSet!=null)
            // actIdList.addAll(accountIdSet);
            // List<asset> existingActAssets;
            // boolean dontAdd=false;
            // if(actIdList!=null && actIdList.size()>0)
            // existingActAssets = getActiveAssets(actIdList);

        // if(mliList!=null && mliList.size()>0){
            // for(Core_IPS_Map_Par_Line_Item__c m: mliList){                               
                // if(m.Core_Account__c!=null && m.Core_MAP_PAR__c!=null && m.Core_isPARRequest__c==true && m.Core_Approval_Type__c=='Approval Required'){
                    // for(Asset a:existingActAssets){
                        // if(a.accountId==m.Core_Account__c && a.Core_Supported_Product__c == m.Core_Supported_Product__c && a.Core_Product_Organization__c==lineItemMap.get(m.id).Core_MAP_PAR__r.Core_Product_Organization__c){
                            // dontAdd = true;
                            // break;
                        // }                 
                    // }
                // }
            // }
        // }
        
        if(mliList!=null && mliList.size()>0){
            submitApprovalRequestForLineItem(mliList);
        }
    }
    
    
    public static void submitApprovalRequestForLineItem(List<Core_IPS_Map_Par_Line_Item__c> litemsForApproval){
        system.debug('###testappr'+litemsForApproval);
        List<Core_IPS_Map_Par_Line_Item__c> LItemList =[select Core_MAP_PAR__c, Core_MAP_PAR__r.Core_Product_Organization__c,Core_MAP_PAR__r.Core_Product_Organization__r.OwnerId,Core_Supported_Product__r.Core_Product_Organization__c from Core_IPS_Map_Par_Line_Item__c where id IN:litemsForApproval];        
        Set<Id> prodOrgIds = new Set<ID>();
        Set<Id> OwnerIdlist= new Set<Id>();
        List<Core_IPS_Product_Organization__c> ProdorgRecords = new List<Core_IPS_Product_Organization__c>();
        Map<Id,Id> OrgIdswithOwnerIds = new Map<Id,Id>();
        Map<Id,List<Core_IPS_Map_Par_Line_Item__c>> OrgIdswithListofProductLitemIds1 = new Map<Id,List<Core_IPS_Map_Par_Line_Item__c>>();
        Map<Id,Approval.ProcessSubmitRequest> ProdOrgtoRequests = new Map<Id,Approval.ProcessSubmitRequest>();
        List<Core_IPS_Map_Par_Line_Item__c> LitemsListbasedonOrgs = new List<Core_IPS_Map_Par_Line_Item__c>();
        
        for(Core_IPS_Map_Par_Line_Item__c parRecord : LItemList){
            prodOrgIds.add(parRecord.Core_MAP_PAR__r.Core_Product_Organization__c);
            OwnerIdlist.add(parRecord.Core_MAP_PAR__r.Core_Product_Organization__r.OwnerId);
        }


        for(Core_IPS_Map_Par_Line_Item__c Litem: LItemList){
            if(OrgIdswithListofProductLitemIds1.containsKey(Litem.Core_Supported_Product__r.Core_Product_Organization__c)){
               OrgIdswithListofProductLitemIds1.get(Litem.Core_Supported_Product__r.Core_Product_Organization__c).add(Litem); 
            }
            else{
               List<Core_IPS_Map_Par_Line_Item__c> LItemRecordsList = new List<Core_IPS_Map_Par_Line_Item__c>();
               LItemRecordsList.add(Litem);        
               OrgIdswithListofProductLitemIds1.put(Litem.Core_Supported_Product__r.Core_Product_Organization__c,LItemRecordsList); 
               system.debug('org id and line items!!!'+OrgIdswithListofProductLitemIds1);
            }
        }
        
        List<Core_IPS_Product_Organization__c> ProdorgRecList = [Select id,OwnerId from Core_IPS_Product_Organization__c where id IN:prodOrgIds];  
        for(Core_IPS_Product_Organization__c Productorg: ProdorgRecList){
            OrgIdswithOwnerIds.put(Productorg.id,Productorg.OwnerId);
            system.debug('org id and owner id map@@@'+OrgIdswithOwnerIds);
        }

        for(Id ProdOrgRec1 :OrgIdswithListofProductLitemIds1.keyset()){                   
            for(Core_IPS_Map_Par_Line_Item__c parRecord : OrgIdswithListofProductLitemIds1.get(ProdOrgRec1)){
                Approval.ProcessSubmitRequest req2 = new Approval.ProcessSubmitRequest();
                List<Approval.ProcessResult> result =new List<Approval.ProcessResult>(); 
                List<Approval.ProcessSubmitRequest> requests = new LIst<Approval.ProcessSubmitRequest>(); 
                List<Id> approverIds2= new List<Id>();                    
                approverIds2.add(OrgIdswithOwnerIds.get(ProdOrgRec1));
                req2.setObjectId(parRecord.id);
                req2.setNextApproverIds(approverIds2);
                requests.add(req2);                                                                                                                              
                result = Approval.process(requests);                                 
            }
        }
    }
    
    //public static boolean dontAdd = false;
    public static void CreateUpdateAssetsonLItemInsert(List<Core_IPS_Map_Par_Line_Item__c> TrgNew){
        if(!Core_Asset_Dispatcher.Assetfieldupdated){
            system.debug('coming here!!!!!!!!!!');
            List<Core_IPS_Map_Par_Line_Item__c> mList = [select id,  Core_Account__c, /*Core_Product__r.name, Core_Product__r.id,*/Core_Status__c,Core_isPARRequest__c, Core_MAP_PAR__r.Core_isPARRequest__c,Core_Supported_Product__r.Core_Supported_Product_Name__c,Core_Supported_Product__r.Core_Supported_Product_Alias__c,Core_MAP_PAR__r.RecordType.Name ,Core_Supported_Product__c,Core_Supported_Product__r.Core_Product__c, Core_MAP_PAR__r.Core_Product_Organization__c,Core_MAP_PAR__r.Core_Product_Organization__r.Name,Core_Approval_Type__c from Core_IPS_Map_Par_Line_Item__c where id IN:TrgNew];
            List<Asset> updateassetlist2 = new List<Asset>();
            List<Asset> updateassetlist3 = new List<Asset>();
            Set<id> prodOrgSet = new Set<Id>();
            Set<String> accountIdSet = new Set<String>();
            Set<String> SupProdIdSet = new Set<String>();
            for(Core_IPS_Map_Par_Line_Item__c m: mList){
                prodOrgSet.add(m.Core_MAP_PAR__r.Core_Product_Organization__c);
                if(m.Core_Account__c!=null)
                accountidSet.add(m.Core_Account__c);
                SupProdIdSet.add(m.Core_Supported_Product__c);
            }   
            List<String> actidList = new List<String>();
            actIdList.addAll(accountIdSet);
            List<String> spidList = new List<String>();
            spidList.addAll(SupProdIdSet);
            List<asset> existingActAssets;
            List<asset> existingObsoleteAssets;
            if(actIdList!=null && actIdList.size()>0)
                existingActAssets = getActiveAssets(actIdList, spidList);
            if(actIdList!=null && actIdList.size()>0)
                existingObsoleteAssets = getInactiveAssets(actIdList, spidList);
            List<Asset> assetList = new List<Asset>();
            if(mlist!=null && mlist.size()>0){
                for(Core_IPS_Map_Par_Line_Item__c m: mList){
                    system.debug('coming here********');
                    boolean dontAdd = false;                        
                    //Duplicate Asset prevention                        
                    if(m.Core_Account__c!=null && m.Core_MAP_PAR__c!=null && !m.Core_MAP_PAR__r.Core_isPARRequest__c){
                        system.debug('coming into Existing Assets IF Condition>>>>>>>>>');
                        for(Asset a:existingActAssets){
                            if(a.accountId==m.Core_Account__c  && a.Core_Supported_Product__c==m.Core_Supported_Product__c && a.Core_Product_Organization__c==m.Core_MAP_PAR__r.Core_Product_Organization__c){
                                a.Core_Map_List__c=a.Core_Map_List__c+';'+m.Core_MAP_PAR__c;
                                updateassetlist2.add(a);
                                dontAdd = true;
                                break;
                            }
                        }
                        
                    }

                    //Duplicate Asset Prevention when Inactive 
                    if(m.Core_Account__c!=null && m.Core_MAP_PAR__c!=null && !m.Core_MAP_PAR__r.Core_isPARRequest__c){
                        for(Asset a:existingObsoleteAssets){
                            if(a.accountId==m.Core_Account__c &&  a.Core_Supported_Product__c==m.Core_Supported_Product__c && a.Core_Product_Organization__c==m.Core_MAP_PAR__r.Core_Product_Organization__c){
                                a.Core_Map_List__c=a.Core_Map_List__c+';'+m.Core_MAP_PAR__c;
                                a.UsageEndDate=null;
                                a.Status = 'Active';//added - 11/19/2015
                                updateassetlist3.add(a);
                                dontAdd = true;
                                break;
                            }
                        }
                            
                    }
                    system.debug('dont add value******'+dontAdd);
                    //Asset Creation
                    if(!dontAdd){
                        //If Map record in transaction contains Account add asset at Account Level
                        if(m.Core_MAP_PAR__c!=null && ((m.Core_MAP_PAR__r.RecordType.Name=='MAP') || ((!m.Core_isPARRequest__c && m.Core_Approval_Type__c=='Approval Required' && m.Core_MAP_PAR__r.RecordType.Name=='PAR') || (m.Core_isPARRequest__c && m.Core_Approval_Type__c=='Auto Approve' && m.Core_MAP_PAR__r.RecordType.Name=='PAR'))) && (m.Core_Account__c!=null) ){
                            system.debug('coming here &&&&&&&&&');
                            Asset ast = new Asset();
                            ast.name = m.Core_Supported_Product__r.Core_Supported_Product_Name__c; //m.Core_Supported_Product_Name__c-m.Core_Product__r.name
                            ast.Core_Supported_Product__c=m.Core_Supported_Product__c;
                            ast.Core_IPS_Asset__c=true;
                            ast.Product2Id=m.Core_Supported_Product__r.Core_Product__c;
                            ast.InstallDate=system.today();
                            ast.Core_Map_List__c=m.Core_MAP_PAR__c;
                            ast.Core_Product_Organization__c =m.Core_MAP_PAR__r.Core_Product_Organization__c;
                            ast.Status = 'Active';
                             //added the below line by kishore on 5/9
                            ast.core_alias__c=m.Core_Supported_Product__r.Core_Supported_Product_Alias__c;
                            ast.recordtypeid = schema.sobjecttype.Asset.getrecordtypeinfosbyname().get('IPS Asset').getRecordTypeId();
                            if(m.Core_Account__c!=null)
                                ast.accountid = m.Core_Account__c;
                            assetList.add(ast);
                        }
                    }   
                }
            }
            system.debug('insert!@#'+assetList);
            system.debug('update actv!@#'+updateassetlist2);
            system.debug('update obs!@#'+updateassetlist3);
            //insert supProdList;
            if(assetList.size()>0)
                insert assetList;
            if(updateassetlist2.size()>0)
                update updateassetlist2;
            if(updateassetlist3.size()>0)
                update updateassetlist3;        
        }
    }
    
    public static void CreateUpdateAssetsonLItemUpdate(List<Core_IPS_Map_Par_Line_Item__c> TrgNew){
        if(!Core_Asset_Dispatcher.Assetfieldupdated){
            //Asset Expiration
            List<Core_IPS_Map_Par_Line_Item__c> mList = [select id, Core_Account__c, /*Core_Product__r.name, Core_Product__r.id,*/Core_Status__c,Core_Supported_Product__r.Core_Supported_Product_Alias__c,Core_Approving_Product_Organization__c,Core_Supported_Product__r.Core_Supported_Product_Name__c,Core_isPARRequest__c, Core_MAP_PAR__r.Core_isPARRequest__c,Core_MAP_PAR__r.RecordType.Name ,Core_Supported_Product__c,Core_Supported_Product__r.Core_Product__c, Core_MAP_PAR__r.Core_Product_Organization__c,Core_MAP_PAR__r.Core_Product_Organization__r.Name,Core_Approval_Type__c from Core_IPS_Map_Par_Line_Item__c where id IN: TrgNew];
            boolean dontAdd1=false;
            List<Id> acctlist= new List<Id>();
            Set<Id> suppProdSet = new Set<Id>();
            for(Core_IPS_Map_Par_Line_Item__c m1: mList){    
                acctlist.add(m1.Core_Account__c);
                suppProdSet.add(m1.Core_Supported_Product__c);
            }
            Map<id,Account> accmap = new Map<Id,Account>([select id, name,(select name,Product2Id,AccountId,Core_Supported_Product__c,Core_Map_List__c from assets where Core_Supported_Product__c IN: suppProdSet) from account where  id IN: acctlist]);
            Map<Id,Set<String>> assetWithMapList = New Map<ID,Set<String>>();
            Map<ID,List<Core_IPS_Map_Par_Line_Item__c>> assetWithLItems = new Map<Id,List<Core_IPS_Map_Par_Line_Item__c>>();
            Set<String> distinctMapIds = new Set<String>();
            for(id aid : accMap.keySet()){
                for(Asset ast : accMap.get(aid).Assets){
                    if(ast.Core_Map_List__c!=null){
                        List<String> mapLst = ast.Core_Map_List__c.split(';');
                        Set<String> mapSetLst = new Set<String>();
                        mapSetLst.addAll(mapLst);
                        assetWithMapList.put(ast.id,mapSetLst);
                        distinctMapIds.addAll(ast.Core_Map_List__c.split(';'));
                    }
                }
            }
            system.debug('test12###'+assetWithLItems.keyset());
            List<Core_IPS_Map_Par_Line_Item__c> otherLI = [select id,Core_Status__c ,Core_MAP_PAR__c,Core_Account__c,Core_Supported_Product__c  from Core_IPS_Map_Par_Line_Item__c where  Core_MAP_PAR__c IN:distinctMapIds and Core_Account__c IN: acctlist and Core_Supported_Product__c IN: suppProdSet ];
            for(Id ast : assetWithMapList.keySet()){
                for(Core_IPS_Map_Par_Line_Item__c li : otherLI){
                    if(assetWithMapList.get(ast).contains(li.Core_MAP_PAR__c)){
                        if(assetWithLItems.keyset().contains(ast)){
                            assetWithLItems.get(ast).add(li);
                        }
                        else{
                            List<Core_IPS_Map_Par_Line_Item__c> newLIList = new List<Core_IPS_Map_Par_Line_Item__c>();
                            newLIList.add(li);
                            assetWithLItems.put(ast,newLIList);
                        }
                    }
                }
            }                
            //list to expire assets
            List<Asset> expireassetList = new List<Asset>();
            //list to update assets if status is made active again
            List<Asset> deexpassetList = new List<Asset>();
            //list to update assets if Auto Approve
            List<Asset> updateassetList = new List<Asset>(); 
            //list to create assets after update based on approval
            List<Asset> updateassetList1 = new List<Asset>(); 
            Set<Asset> expireassetSet =new Set<Asset>(); 
            List<Asset> expireassettoUpdate = new List<Asset>(); 
            
            for(Core_IPS_Map_Par_Line_Item__c m2: mList){
                if(m2.Core_Status__c=='INACTIVE' && accmap!=null && m2.Core_Account__c!=null){   
                    for(Asset asst:accmap.get(m2.Core_Account__c).assets){
                        boolean check=false;
                        if(m2.Core_MAP_PAR__c!=null && ((m2.Core_MAP_PAR__r.RecordType.Name=='MAP') || (!m2.Core_isPARRequest__c && m2.Core_Approval_Type__c=='Approval Required' && m2.Core_MAP_PAR__r.RecordType.Name=='PAR') || (m2.Core_isPARRequest__c && m2.Core_Approval_Type__c=='Auto Approve' && m2.Core_MAP_PAR__r.RecordType.Name=='PAR')) && m2.Core_Account__c!=null && m2.Core_Supported_Product__c==asst.Core_Supported_Product__c){
                            if(assetWithLItems.get(asst.id)!=null){
                            for(Core_IPS_Map_Par_Line_Item__c existLi : assetWithLItems.get(asst.id)){
                                if(existLi!=null && existLi.Core_Status__c == 'ACTIVE' && existLi.Core_MAP_PAR__c!=m2.Core_MAP_PAR__c && existLi.Core_Account__c==asst.AccountID && existLi.Core_Supported_Product__c == asst.Core_Supported_Product__c){
                                    check=true;    
                                }
                            }
                            }
                            if(check==false){
                            asst.Status='Inactive';
                            asst.UsageEndDate=System.today();
                            expireassetList.add(asst);
                            }
                        }
                    } 
                }   
              //Un-expire Asset when the Line Item is Re-activated. 
                if(m2.Core_Status__c=='ACTIVE' && accmap!=null && m2.Core_Account__c!=null){  
                    for(Asset asst:accmap.get(m2.Core_Account__c).assets){
                        if(m2.Core_MAP_PAR__c!=null && m2.Core_Account__c == asst.AccountId && m2.Core_Supported_Product__c==asst.Core_Supported_Product__c){
                            asst.Status='Active';
                            asst.UsageEndDate=null;
                            if(!m2.Core_isPARRequest__c && m2.Core_Approval_Type__c=='Approval Required'&& m2.Core_MAP_PAR__r.RecordType.Name=='PAR'){
                                asst.Core_Map_List__c = asst.Core_Map_List__c+';'+m2.Core_MAP_PAR__c;
                            }
                            dontAdd1=true;
                            deexpassetList.add(asst);
                        }
                    } 
                }
               //Asset creation when approval type is "Approval required". Once the IsParrequest checkbox is made false asset must get created.
                if(!dontAdd1){
                   if(m2.Core_Status__c=='ACTIVE' && accmap!=null && m2.Core_Account__c!=null){   
                       if(m2.Core_MAP_PAR__c!=null &&((m2.Core_MAP_PAR__r.RecordType.Name=='MAP') || ((!m2.Core_isPARRequest__c && m2.Core_Approval_Type__c=='Approval Required'&& m2.Core_MAP_PAR__r.RecordType.Name=='PAR') || (m2.Core_isPARRequest__c && m2.Core_Approval_Type__c=='Auto Approve' && m2.Core_MAP_PAR__r.RecordType.Name=='PAR'))) && m2.Core_Account__c!=null && m2.Core_Supported_Product__c!=null){
                            Asset ast1 = new Asset();
                            ast1.Core_Supported_Product__c=m2.Core_Supported_Product__c;
                            ast1.name = m2.Core_Supported_Product__r.Core_Supported_Product_Name__c;
                            ast1.InstallDate=system.today();
                            ast1.Product2Id=m2.Core_Supported_Product__r.Core_Product__c;
                            ast1.Core_IPS_Asset__c=true;
                            ast1.Core_Product_Organization__c =m2.Core_MAP_PAR__r.Core_Product_Organization__c;
                            ast1.Core_Map_List__c=m2.Core_MAP_PAR__c;
                            ast1.Status = 'Active';
                             //added the below line by kishore on 5/9
                            ast1.core_alias__c=m2.Core_Supported_Product__r.Core_Supported_Product_Alias__c;
                            ast1.recordtypeid = schema.sobjecttype.Asset.getrecordtypeinfosbyname().get('IPS Asset').getRecordTypeId();
                            if(m2.Core_Account__c!=null)
                                ast1.accountid = m2.Core_Account__c;
                            updateassetList1.add(ast1);
                        }
                    }
                }
            }
            expireassetSet.addAll(expireassetList);
            expireassettoUpdate.addAll(expireassetSet);
            if(expireassettoUpdate.size()>0)
            update expireassettoUpdate;
            if(deexpassetList.size()>0)
            update deexpassetList;
            if(updateassetList.size()>0)
            update updateassetList;
            if(updateassetList1.size()>0)
            insert updateassetList1;        
        }
    }
    
     
}