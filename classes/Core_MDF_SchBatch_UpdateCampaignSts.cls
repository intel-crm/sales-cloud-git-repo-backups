/**************************************************************************************
Apex Class Name:  Core_MDF_SchBatch_UpdateCampaignSts 
Version     : 1.0 
Created Date: 25 07 2018
Function    : Scheduler class for the batch to change campaigns status to Completed.
Author      : Ealisha Chatterjee
Modification Log :
* Change#                 Author                   Date                   Description
* ----------------------------------------------------------------------------                 
* Core MDF Rel1           Ealisha Chatterjee       25/04/2016              Original Version
* Included CCP Programs      Narayani Perachi     29/01/2019         Modified the query to filter only CCF and DCF Accounts. 
                                                                                 Also added where condition for 'Planned' status
* Increased Batch Size      Narayani Perachi     29/01/2019         Increased batch size from 100 to 200  
*************************************************************************************/

global without sharing class Core_MDF_SchBatch_UpdateCampaignSts implements Schedulable {

    global void execute(SchedulableContext sc) 
    {
        
        String extractedClaimWindow;
        string query ='select Id,Core_mdf_program__c,Core_MDF_Campaign_Reference_Number__c,Name,Status,EndDate,StartDate from Campaign where';  
        query += ' (recordtype.developername in:ccpProgram) AND ((status=\'Planned\' AND StartDate <=:todaydt AND EndDate >=:todaydt) OR (status in:checkStatus AND (';
        /*commented as a part of Core_MDF_CCP_Claim_Window__mdt optimization
        List<Core_MDF_CCP_Claim_Window__mdt> d = [SELECT Core_MDF_Program__c,Core_MDF_Claim_Window__c FROM Core_MDF_CCP_Claim_Window__mdt] ;*/
        Datetime dtTime=System.now();
        date dt= date.newinstance(dtTime.year(), dtTime.month(), (dtTime.day()-1));
        //date todaydt= date.newinstance(dtTime.year(), dtTime.month(), (dtTime.day()));
        query += '(enddate <= :dt) OR';
        /*commented as a part of Core_MDF_CCP_Claim_Window__mdt optimization
        // for(Core_MDF_CCP_Claim_Window__mdt record:d)
        //     { 
        //         integer claimWindow=record.Core_MDF_Claim_Window__c.intValue();
        //         string program=record.Core_MDF_Program__c;
        //         Date claimWindowAdded= dt.addMonths(-claimWindow);
        //         string claimMonth =(string.valueOf(claimWindowAdded.month()).length()<2)?0+string.valueOf(claimWindowAdded.month()):string.valueOf(claimWindowAdded.month());    
        //         string claimDay =(string.valueOf(claimWindowAdded.day()).length()<2)?0+string.valueOf(claimWindowAdded.day()):string.valueOf(claimWindowAdded.day());                   
        //         extractedClaimWindow = claimWindowAdded.year() + '-' + claimMonth + '-' + claimDay;
        //         query += ' (Core_mdf_program__c =\''+program+'\' and enddate<='+extractedClaimWindow+') OR';  
        //         System.System.debug('@@@vikas sch extractedClaimWindow: '+extractedClaimWindow);
        //     }*/
        
        query = query.left(query.length()-2) + ')))';
    //query += ' (status=\'Planned\' AND StartDate <=:todaydt AND EndDate >=:todaydt))';        
        
        //query += ' StartDate<=:todaydt OR'
        
        Core_MDF_Batch_UpdateCampaignSts batch = new Core_MDF_Batch_UpdateCampaignSts();
        batch.queryActive = query;
        Database.executeBatch(batch, 200);
     }
}