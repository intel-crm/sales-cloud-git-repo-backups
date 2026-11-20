/****************************************************************************************************************************************
* Class Name  : Seismic_PIMDOV_BatchSync 
* Version     : 1.0 
* Created Date: 05/15/2023
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            05/15/2023               		The Apex Seismic_PIMDOV_BatchSync to sync PIM and Seismic DOVs
* Sandeep Joshi            09/04/2023               		Updated to address Seismic API changes 
*****************************************************************************************************************************************/
public class Seismic_PIMDOV_BatchSync implements Database.Batchable<sObject>, Database.AllowsCallouts { 
    
    // instance member to retain state across transactions
    public Integer recordsProcessed = 0;
    
    public Database.QueryLocator start(Database.BatchableContext bc) {       
        return Database.getQueryLocator(
            'SELECT HierarchyID__c, Hierarchy_Name__c, Seismic_Name__c, L1_ID__c, L2_ID__c, L3_ID__c, L4_ID__c, L5_ID__c FROM Seismic_PIMActiveHierarchy__c WHERE Process__c = true'
        );
    }
    
    
    public void execute(Database.BatchableContext bc, List<Seismic_PIMActiveHierarchy__c> scope){
        
        try {    
            Boolean isProcessed = false;
            
            //00.Initialize Configs
            Seismic_PIMDOVSync.initialize();      
            //02. Get PIM Token
            Seismic_PIMDOVSync.bearerTokenPIM = Seismic_PIMResponseWrapper.getPIMToken();
            //03. Get Seismic Token
            Seismic_PIMDOVSync.seismicToken = Seismic_CustomPropertiesResponseWrapper.getSeismicToken();
                    
            //04. Iterate through Active Hierarchies to make PIM API Calls. One call per DOV.
            for(Seismic_PIMActiveHierarchy__c activeHierarchy : scope){
                
                //Call PIM API for the hierarchy
                Seismic_PIMDOVSync.listHierarchy = Seismic_PIMResponseWrapper.getContentHierarchy(activeHierarchy.HierarchyID__c, Seismic_PIMDOVSync.bearerTokenPIM);
                
                //L1
                if(activeHierarchy.L1_ID__c != null && activeHierarchy.L1_ID__c != ''){
                    Seismic_PIMDOVSync.listCustomProperty = Seismic_CustomPropertiesResponseWrapper.getSeismicCustomProperty(Seismic_PIMDOVSync.seismicToken, activeHierarchy.L1_ID__c);
                    Seismic_PIMDOVSync.listCustomProperty = Seismic_PIMDOVSync.identifyToSync(Seismic_PIMDOVSync.bearerTokenPIM, Seismic_PIMDOVSync.seismicToken, activeHierarchy, 1, activeHierarchy.L1_ID__c);
                    Seismic_PIMDOVSync.listCustomProperty = Seismic_CustomPropertiesResponseWrapper.updateSeismicCustomProperty(Seismic_PIMDOVSync.seismicToken, activeHierarchy.L1_ID__c, Seismic_PIMDOVSync.listCustomProperty);
                    isProcessed = true;
                }
                
                //L2
                if(activeHierarchy.L2_ID__c != null && activeHierarchy.L2_ID__c != ''){
                    Seismic_PIMDOVSync.listCustomProperty = Seismic_CustomPropertiesResponseWrapper.getSeismicCustomProperty(Seismic_PIMDOVSync.seismicToken, activeHierarchy.L2_ID__c);
                    Seismic_PIMDOVSync.listCustomProperty = Seismic_PIMDOVSync.identifyToSync(Seismic_PIMDOVSync.bearerTokenPIM, Seismic_PIMDOVSync.seismicToken, activeHierarchy, 2, activeHierarchy.L2_ID__c);
                    Seismic_PIMDOVSync.listCustomProperty = Seismic_CustomPropertiesResponseWrapper.updateSeismicCustomProperty(Seismic_PIMDOVSync.seismicToken, activeHierarchy.L2_ID__c, Seismic_PIMDOVSync.listCustomProperty);
                    isProcessed = true;
                }
                
                //L3
                if(activeHierarchy.L3_ID__c != null && activeHierarchy.L3_ID__c != ''){
                    Seismic_PIMDOVSync.listCustomProperty = Seismic_CustomPropertiesResponseWrapper.getSeismicCustomProperty(Seismic_PIMDOVSync.seismicToken, activeHierarchy.L3_ID__c);
                    Seismic_PIMDOVSync.listCustomProperty = Seismic_PIMDOVSync.identifyToSync(Seismic_PIMDOVSync.bearerTokenPIM, Seismic_PIMDOVSync.seismicToken, activeHierarchy, 3, activeHierarchy.L3_ID__c);
                    Seismic_PIMDOVSync.listCustomProperty = Seismic_CustomPropertiesResponseWrapper.updateSeismicCustomProperty(Seismic_PIMDOVSync.seismicToken, activeHierarchy.L3_ID__c, Seismic_PIMDOVSync.listCustomProperty);
                    isProcessed = true;
                }
                
                //L4
                if(activeHierarchy.L4_ID__c != null && activeHierarchy.L4_ID__c != ''){
                    Seismic_PIMDOVSync.listCustomProperty = Seismic_CustomPropertiesResponseWrapper.getSeismicCustomProperty(Seismic_PIMDOVSync.seismicToken, activeHierarchy.L4_ID__c);
                    Seismic_PIMDOVSync.listCustomProperty = Seismic_PIMDOVSync.identifyToSync(Seismic_PIMDOVSync.bearerTokenPIM, Seismic_PIMDOVSync.seismicToken, activeHierarchy, 4, activeHierarchy.L4_ID__c);
                    Seismic_PIMDOVSync.listCustomProperty = Seismic_CustomPropertiesResponseWrapper.updateSeismicCustomProperty(Seismic_PIMDOVSync.seismicToken, activeHierarchy.L4_ID__c, Seismic_PIMDOVSync.listCustomProperty);
                    isProcessed = true;
                }
                
                //L5
                if(activeHierarchy.L5_ID__c != null && activeHierarchy.L5_ID__c != ''){
                    Seismic_PIMDOVSync.listCustomProperty = Seismic_CustomPropertiesResponseWrapper.getSeismicCustomProperty(Seismic_PIMDOVSync.seismicToken, activeHierarchy.L5_ID__c);
                    Seismic_PIMDOVSync.listCustomProperty = Seismic_PIMDOVSync.identifyToSync(Seismic_PIMDOVSync.bearerTokenPIM, Seismic_PIMDOVSync.seismicToken, activeHierarchy, 5, activeHierarchy.L5_ID__c);
                    Seismic_PIMDOVSync.listCustomProperty = Seismic_CustomPropertiesResponseWrapper.updateSeismicCustomProperty(Seismic_PIMDOVSync.seismicToken, activeHierarchy.L5_ID__c, Seismic_PIMDOVSync.listCustomProperty);
                    isProcessed = true;
                }
                
                //05 - Notify with summary
                if(isProcessed){
                    Seismic_PIMDOVSync_Notification.sendSummary(Seismic_PIMDOVSync.notifyDOVs, activeHierarchy.Seismic_Name__c);
                }
            }
                       
        }
        catch (Exception e) {         
            Seismic_PIMDOVSync_Notification.senderrorEmail('Error occurred in Seismic_PIMDOV_BatchSync', 'Error occurred in Seismic_PIMDOV_BatchSync Execute : ' + e.getMessage());
            //throw e;       
        }
    }
        
    public void finish(Database.BatchableContext bc){
        Seismic_SFDC_BatchSync myBatchObject = new Seismic_SFDC_BatchSync();
        Database.executeBatch(myBatchObject,1); 
    }
}