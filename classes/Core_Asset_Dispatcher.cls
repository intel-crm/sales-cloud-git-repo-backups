public class Core_Asset_Dispatcher{
    
     public static boolean Assetfieldupdated=false;     
     public static String newListStr; 
     public static String oldListStr;
     public static void beforeMethod(List<Asset> oldList, List<Asset> newList, 
                            Map<Id,Asset> oldMap,Map<Id,Asset> newMap){
                            
         //[Below 2 lines are making sure to process only IPS records.]
         List<Asset> ipsNewRecordList = Core_IPS_Helper_Utility.getIPSRecords('Asset',newList);
         List<Asset> ipsOldRecordList = Core_IPS_Helper_Utility.getIPSRecords('Asset',oldList);         
         
         if(trigger.isInsert){
             if(ipsNewRecordList <> null && ipsNewRecordList.size() > 0){
                 //newListStr = JSON.serialize(ipsNewRecordList);   //commented by Aayushi DE40248
                 Core_Asset_Handler.changeAssetOwner(ipsNewRecordList);
                 //Core_Asset_Handler.updateProductInformationOnAsset(newListStr); //commented by Aayushi DE40248
                 Core_Asset_Handler.updateProductInformationOnAsset(ipsNewRecordList); 
				 Core_Asset_Handler.updateProjectInformationOnAsset(ipsNewRecordList); 	//added by Aayushi US113701
             }
         }
         if(trigger.isUpdate){                            
          
         }
         
         if(trigger.isDelete){
         
         }
    }  
    
    public static void afterMethod(List<Asset> oldList, List<Asset> newList, 
                            Map<Id,Asset> oldMap,Map<Id,Asset> newMap){
         
         //[Below 2 lines are making sure to process only IPS records.]
         List<Asset> ipsNewRecordList = Core_IPS_Helper_Utility.getIPSRecords('Asset',newList);
         List<Asset> ipsOldRecordList = Core_IPS_Helper_Utility.getIPSRecords('Asset',oldList);         
         if(trigger.isInsert){    
             if(ipsNewRecordList <> null && ipsNewRecordList.size() > 0){
                 newListStr = JSON.serialize(ipsNewRecordList);
                 Core_Asset_Handler.LItemUpdate(newListStr);
                 Core_Asset_Handler.UpdateProjProduct(newListStr);     
                 Core_Asset_Handler.grantAssetAccesstoCustomers(newListStr); //Sharing asset to IPS External
                 Core_Asset_Handler.grantAssetAccesstoFAEs(newListStr); //Sharing asset to IPS Internal
             }
         }
         if(trigger.isUpdate){         
            if(ipsNewRecordList <> null && ipsNewRecordList.size() > 0){
                newListStr = JSON.serialize(ipsNewRecordList);
                oldListStr = JSON.serialize(ipsOldRecordList);
                Core_Asset_Handler.LItemUpdate(newListStr);
                Core_Asset_Handler.grantAssetAccesstoCustomers(newListStr); //Sharing asset to IPS External
		if(!System.isFuture() && !System.isBatch()){
                	Core_Asset_Handler.grantAssetAccesstoFAEs(oldListStr,newListStr); //Sharing asset to IPS Internal
		}
            }
            //Core_Asset_Handler.shareAssets(newList);            
         }
      
         if(trigger.isDelete){
         
         }
    }  
}