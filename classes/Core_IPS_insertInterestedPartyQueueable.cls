/***************************************************************************************************
Class Name          : Core_IPS_insertInterestedPartyQueueable
Version             : 1.0 
Created Date        : 14 Jan 2018
Function            : This Class is a Queueable Class for Interested Party insertion. Test class coverage is
            in Core_IPS_IntelSupportTeam_Handler_Test
Input Parameters    : List<Core_IPS_Intel_Support_Team__c> and List<Case>
Output Parameters   : NA
Description         : NA
Used in             : trigger Handler class Core_IPS_IntelSupportTeam_Handler
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                    
* Aayushi Singhal             14/01/2018              Created DE29283
* Aayushi Singhal        15/02/2019        Modified DE32193
****************************************************************************************************/
global class Core_IPS_insertInterestedPartyQueueable implements Queueable{
    //Modified the Queueable Class to take only the Interested party records and insert them
    List<Core_IPS_Case_Interested_Party__c> interestedPartyList= new List<Core_IPS_Case_Interested_Party__c>();
    global Core_IPS_insertInterestedPartyQueueable(List<Core_IPS_Case_Interested_Party__c> IPList){
    interestedPartyList= IPList;   
    }
    
    global void execute(QueueableContext context){
    
        List<Core_IPS_Case_Interested_Party__c> interestedPartyListToInsert=new List<Core_IPS_Case_Interested_Party__c>();
        Integer count=0;
        if(interestedPartyList!=null && interestedPartyList.size()>0){
            for(Integer i = interestedPartyList.size()-1 ; i >=0; i--){ 
                interestedPartyListToInsert.add(interestedPartyList.remove(i));
                count++;
                if(count==30)
                    break;
            }

        }
        if(interestedPartyListToInsert.size()>0){
            try{
            insert interestedPartyListToInsert ;
            }catch(Exception ex){
             system.debug('errors in interested party'+ex.getCause()+ex.getLineNumber()); 
             Core_IPS_ExceptionHandling.logEntryWithException(ex,'Core_IPS_insertInterestedPartyQueueable','Interested Party');
            }
        }
        if(!Test.isRunningTest() && interestedPartyList!=null && interestedPartyList.size()>0){
                System.enqueueJob(new Core_IPS_insertInterestedPartyQueueable(interestedPartyList));
    }   
        
    }
 

}