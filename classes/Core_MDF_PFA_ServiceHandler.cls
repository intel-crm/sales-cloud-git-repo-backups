/****************************************************************************************************************************************
* Class Name  : Core_MDF_PFAServiceHandler 
* Version     : 1.0 
* Created Date: 27-11-2018
* Modification Log :
* Developer            Date               Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Accenture -    27-11-2018          Service Class for Handling Allocations and sending list of allocations for further processing
*****************************************************************************************************************************************/
public without sharing class Core_MDF_PFA_ServiceHandler{
    
    public static void checkUpdatedAllocations(list<PartnerFundAllocation> allocationsUpdated, map<Id,PartnerFundAllocation> allocationsBeforeUpdate){
        
        
        Map<Id,PartnerFundAllocation> updatedAllocations = new Map<Id,PartnerFundAllocation>();
        try{
            for(PartnerFundAllocation pfaRecord: allocationsUpdated){
                PartnerFundAllocation oldPfaRecord = (PartnerFundAllocation)allocationsBeforeUpdate.get(pfaRecord.Id);
                if((pfaRecord.Amount > oldPfaRecord.Amount)){
                    updatedAllocations.put(pfaRecord.Id,pfaRecord);
                }
                
            }
        }     
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}   
        if(updatedAllocations!=null && updatedAllocations.size()>0 ) {
            System.debug('Insdise PAF Service controller');
            Core_MDF_Process_PAF_Claim.fetchClaimsByAllocationIds(updatedAllocations.keySet());
            
        } 
        
        
    }
    /***************************************************************************************************** 
Method Name:        invokeAllocationShareRecordToGeoGroup
@return  :          void
@parameters:        List of Allocation record
Description:        This is invocable method to perform Geo Based Sharing for a Allocation record
Added By:           Accenture-VD  
Date :        04-Nov-2019
Modified By:        Date:       Changes: 
******************************************************************************************************/
    @InvocableMethod
    public static void invokeAllocationShareRecordToGeoGroup(List<PartnerFundAllocation> listOfPFA)
    {
        //To share record on the basis of Channel Program and geo      
        List<Core_MDF_RecordGeoShare> recordGeoShareList= new List<Core_MDF_RecordGeoShare>();
        //Getting all the account ids from Partner Marketing Budget
        List<Id> accountIds = new List<Id>();
        //Map of account id and account 
        Map<Id,Account> accountIdToAccountMap = new Map<Id,Account>();
        //To store program ids
        List<Id> programIds = new List<Id>();
        //Map of channel Program id and technical program name 
        Map<Id,String> cpIdToTechProgNameMap = new Map<Id,String>();
        try{
            for(PartnerFundAllocation pfa: listOfPFA){
                //Getting all the accounts from Budget List
                accountIds.add(pfa.ChannelPartnerId);
            }
            for (Account acc: [Select Id,Core_Geo__c,Core_Sub_Geo__c, Core_MDF_Channel_Program__c, Core_MDF_CoMarketing_Ultimate_Account__c from Account where id IN :accountIds]) {
                //To get account's geo and subgeo field
                accountIdToAccountMap.put(acc.Id,acc);
                //Storing account's program
                programIds.add(acc.Core_MDF_Channel_Program__c);
            }
            //Iterating to get channel program technical program name
            for (ChannelProgram cp: [Select Id,Name,Core_MDF_Technical_Program_Name__c from ChannelProgram where id IN :programIds]) {
                cpIdToTechProgNameMap.put(cp.Id,cp.Name);
            }
            
            for(PartnerFundAllocation pfaObj : listOfPFA){
                Account account = accountIdToAccountMap.get(pfaObj.ChannelPartnerId);
                //To share record on the basis of Channel Program and geo
                recordGeoShareList.add(new Core_MDF_RecordGeoShare(pfaObj.id,account.Core_Geo__c,account.Core_Sub_Geo__c,cpIdToTechProgNameMap.get(account.Core_MDF_Channel_Program__c)));
            }  
            //To share record on the basis of Channel Program and geo
            if(recordGeoShareList!=null && recordGeoShareList.size()>0){
                Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('PartnerFundAllocation',recordGeoShareList);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);}
    }
}