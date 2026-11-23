/****************************************************************************************************************************************
 * Class Name  : Core_MDF_AccountDomainMappingProgram
 * Version     : 1.0
 * Created Date: 29-Jan-2020
 * Modification Log :
 * Developer                 Date               Description
 * ---------------------------------------------------------------------------------------------------------------------------------------
 * Accenture - vaishali      29-Jan-2020        
 *****************************************************************************************************************************************/
public with sharing class Core_MDF_AccountDomainMappingProgram {
    
/*****************************************************************************************************
Method Name:        getAllPrograms
@return  :          Map of channel Programs Id and channel program instance
@parameters:        None
Description:        Getting all the channel programs which user have access to
Added By:           Accenture - Vaishali - 29-Jan-2020
******************************************************************************************************/  
    
    public static Map<Id,ChannelProgram> getAllPrograms(){ 
        Map<Id,ChannelProgram> channelProgramMap = new Map<Id,ChannelProgram>([Select Id,Name,Core_MDF_Technical_Program_Name__c from ChannelProgram]);
        return channelProgramMap;
    }
}