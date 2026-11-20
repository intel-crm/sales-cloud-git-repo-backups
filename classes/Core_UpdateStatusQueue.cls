/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_UpdateStatusQueue 
Version     : 1.0 
Created Date: 11 DEC 2020
Function    : Utility methods to create JSONs
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sanket Mahajan             12/11/2020              Original Version

*****************************************************************************************************************************************************************************************************/

public class Core_UpdateStatusQueue implements Queueable{
    public set<Id> oppIdSet = new set<Id>();
    public List<Core_KPI_Staging__c> ksFinalList = new List<Core_KPI_Staging__c>();
    
    
    public Core_UpdateStatusQueue(Set<id> opids){
        this.oppIdSet = opids;
    }
    
    public void execute(QueueableContext context){
        if(oppIdSet.size()>0){
            Integer days = Integer.valueOf(System.label.Core_Old_KPI_Update_Days);
            Date startDate = Date.today().addDays(-Integer.valueOf(days));
            List<Core_KPI_Staging__c> ksListforOpp = [select id,Core_Opportunity_ID_Txt__c, Core_Status__c from Core_KPI_Staging__c where Core_Refresh_Type__c = 'Incremental' and Core_Status__c !='Success' and Core_Opportunity_ID_Txt__c in:oppIdSet and  CreatedDate >=:startDate];
            if(ksListforOpp.size()>0){
                for(Core_KPI_Staging__c ks : ksListforOpp ){        
                    ks.Core_Status__c = 'Success';
                    ksFinalList.add(ks);
                }
                if(ksFinalList.size()>0){
                    database.update(ksFinalList,false);
                }
           }           
        }
    }
}