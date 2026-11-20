public class Core_Product_Access_Handler{
    /***************************************************************************************************
    Method Name:  changeOwner
    Method Type: Core_Product_Access_Handler Method 
    Version     : 1.0 
    Created Date: 27 Sep 2015
    Function    : This method is used to change the Owner Id
    Input Parameters: Trigger.New List
    Output Parameters: None
    Description:   This method takes in the new list and changes the Owner Id to the Owner Id of the Product Org
                   under which the record is created
    Used in     : 
    Number of Queries Within this Method: 1
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        09/27/2015              Created
    ****************************************************************************************************/      
    public static void changeOwner(List<Core_IPS_MAP_PAR__c> newList){
        List<Id> ListofOrgIds =new List<Id>();
        List<Id> ListofOrgOwnerIds = new List<Id>();
        List<Core_IPS_Product_Organization__c> Orgrecords = new List<Core_IPS_Product_Organization__c>();
            for(Core_IPS_MAP_PAR__c Mapids: newList ){
                ListofOrgIds.add(Mapids.Core_Product_Organization__c); 
            }
        //FLS check added-Venugopal
        if(Core_IPS_Product_Organization__c.SObjectType.getDescribe().isAccessible()){
            Orgrecords = [Select id, Core_IPS_Support_Org_Name__c, Ownerid from Core_IPS_Product_Organization__c where id IN: ListofOrgIds];
        }
            for(Core_IPS_Product_Organization__c Org: Orgrecords){
                ListofOrgOwnerIds.add(Org.OwnerId);
            }
        
        for(Core_IPS_Product_Organization__c OrgRec: Orgrecords){
            for(Core_IPS_MAP_PAR__c MapRec:newList){
                if(MapRec.Core_Product_Organization__c == OrgRec.id)
                    MapRec.OwnerId = OrgRec.OwnerId; 
            }
        }
    }
    
    /***************************************************************************************************
    Method Name:  shareProductAccessRecords
    Method Type: Core_Product_Access_Handler Method 
    Version     : 1.0 
    Created Date: 15 Oct 2015
    Function    : This method is used to call the provide access method to share the record to the Creator
    Input Parameters: Trigger.New List
    Output Parameters: None
    Description:   This method takes in the new list and calls the provide access method of Sharing Utility class
    Used in     : 
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        10/15/2015              Created
    ****************************************************************************************************/      
    public static void shareProductAccessRecords(list<Core_IPS_MAP_PAR__c> newList){
        Set<Id> MAPidSet = new Set<Id>();
        Set<Id> CreatorSet = new Set<Id>();
        for(Core_IPS_MAP_PAR__c MAPRec: newList){
            CreatorSet.add(MAPRec.Createdby.Id);            
        }        
        Map<Id, Id> CreatorByMap = getCreatedUsersByMap(newList,CreatorSet);
        Core_SharingUtility.provideAccess('Core_IPS_MAP_PAR__c', 'Core_MAP_PAR__Share', 'Read', CreatorByMap);   
    }
    
    /***************************************************************************************************
    Method Name:  shareProductAccessRecords
    Method Type: Core_Product_Access_Handler Method 
    Version     : 1.0 
    Created Date: 15 Oct 2015
    Function    : This method is used to construct the parameters for shareProductAccessRecords
    Input Parameters: Trigger.New List and set of User Ids(Createdby Ids)
    Output Parameters: Map of Prodcut Access Header record and UserId(Createdby Id)
    Description:   This method takes in two parameters to construct a Map for shareProductAccessRecords to pass 
                   as a parameter to Sharign Utility class
    Used in     : 
    Number of Queries Within this Method: 0
    Number of Queries in Loop: 0
    Number of Queries from Called methods:  0
    Modification Log :
    * Developer                   Date                   Description
    * ----------------------------------------------------------------------------                 
    * JRK                        10/15/2015              Created
    ****************************************************************************************************/      
    public Static Map<Id,Id> getCreatedUsersByMap(List<Core_IPS_MAP_PAR__c> newList, Set<id> CreatorSet ){ 
        Map<Id, Id> CreatorbyMAP = new Map<Id, Id>();
        for(Core_IPS_MAP_PAR__c MAPRec: newList){
            for(Id CreatorId: CreatorSet){ 
                if(MAPRec.Createdby.Id == CreatorId)
                CreatorbyMAP.put(MAPRec.id,CreatorId);
            }
        }
        return CreatorbyMAP;
    }
   
}