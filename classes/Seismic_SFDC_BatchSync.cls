/****************************************************************************************************************************************
* Class Name  : Seismic_SFDC_BatchSync 
* Version     : 1.0 
* Created Date: 05/15/2023
* Modification Log :
* Developer                     Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Sandeep Joshi            05/15/2023               		The Apex Seismic_SFDC_BatchSync to sync Seismic and SFDC Custom Object - Seismic_DOV__c
* Sandeep Joshi            09/04/2023               		Updated to address Seismic API changes 
*****************************************************************************************************************************************/
public class Seismic_SFDC_BatchSync implements Database.Batchable<sObject>, Database.AllowsCallouts { 
    
    // instance member to retain state across transactions
    public Integer recordsProcessed = 0;
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        //00.Initialize Configs
        Seismic_PIMDOVSync.initialize();
        
        if(Seismic_PIMDOVSync.config.get('IsTest') != 'True')
        {
            delete [SELECT Property_Name__c FROM Seismic_DOV__c];
        }
        return Database.getQueryLocator(
            'SELECT HierarchyID__c, Hierarchy_Name__c, Seismic_Name__c, L1_ID__c, L2_ID__c, L3_ID__c, L4_ID__c, L5_ID__c FROM Seismic_PIMActiveHierarchy__c WHERE Process__c = true'
        );
    }
    
    
    public void execute(Database.BatchableContext bc, List<Seismic_PIMActiveHierarchy__c> scope){
        
        try {    
            
            //00.Initialize Configs
            Seismic_PIMDOVSync.initialize();
            
            //02. Get PIM Token
            Seismic_PIMDOVSync.bearerTokenPIM = Seismic_PIMResponseWrapper.getPIMToken();
            
            //03. Get Seismic Token
            Seismic_PIMDOVSync.seismicToken = Seismic_CustomPropertiesResponseWrapper.getSeismicToken();
            
            //Iterate through Active Hierarchies to make PIM API Calls. One call per DOV.
            for(Seismic_PIMActiveHierarchy__c activeHierarchy : scope){
                
                //Call PIM API for the hierarchy
                Seismic_PIMDOVSync.listHierarchy = Seismic_PIMResponseWrapper.getContentHierarchy(activeHierarchy.HierarchyID__c, Seismic_PIMDOVSync.bearerTokenPIM);
                System.debug('listHierarchy >> ' + Seismic_PIMDOVSync.listHierarchy);
                
                //L1
                if(activeHierarchy.L1_ID__c != null && activeHierarchy.L1_ID__c != ''){
                    Seismic_PIMDOVSync.listCustomProperty = Seismic_CustomPropertiesResponseWrapper.getSeismicCustomProperty(Seismic_PIMDOVSync.seismicToken, activeHierarchy.L1_ID__c);
                    Seismic_PIMDOVSync.add_SeismicDOV_SFDC();
                    Seismic_PIMDOVSync.update_PIMDOVID_SFDC(1, Seismic_PIMDOVSync.tmpDOVInsertList);
                }
                
                //L2
                if(activeHierarchy.L2_ID__c != null && activeHierarchy.L2_ID__c != ''){
                    Seismic_PIMDOVSync.listCustomProperty = Seismic_CustomPropertiesResponseWrapper.getSeismicCustomProperty(Seismic_PIMDOVSync.seismicToken, activeHierarchy.L2_ID__c);
                    Seismic_PIMDOVSync.add_SeismicDOV_SFDC();
                    Seismic_PIMDOVSync.update_PIMDOVID_SFDC(2, Seismic_PIMDOVSync.tmpDOVInsertList);
                }

                //L3
                if(activeHierarchy.L3_ID__c != null && activeHierarchy.L3_ID__c != ''){
                    Seismic_PIMDOVSync.listCustomProperty = Seismic_CustomPropertiesResponseWrapper.getSeismicCustomProperty(Seismic_PIMDOVSync.seismicToken, activeHierarchy.L3_ID__c);
                    Seismic_PIMDOVSync.add_SeismicDOV_SFDC();
                    Seismic_PIMDOVSync.update_PIMDOVID_SFDC(3, Seismic_PIMDOVSync.tmpDOVInsertList);
                }

                //L4
                if(activeHierarchy.L4_ID__c != null && activeHierarchy.L4_ID__c != ''){
                    Seismic_PIMDOVSync.listCustomProperty = Seismic_CustomPropertiesResponseWrapper.getSeismicCustomProperty(Seismic_PIMDOVSync.seismicToken, activeHierarchy.L4_ID__c);
                    Seismic_PIMDOVSync.add_SeismicDOV_SFDC();
                    Seismic_PIMDOVSync.update_PIMDOVID_SFDC(4, Seismic_PIMDOVSync.tmpDOVInsertList);
                }
                
                //L5
                if(activeHierarchy.L5_ID__c != null && activeHierarchy.L5_ID__c != ''){
                    Seismic_PIMDOVSync.listCustomProperty = Seismic_CustomPropertiesResponseWrapper.getSeismicCustomProperty(Seismic_PIMDOVSync.seismicToken, activeHierarchy.L5_ID__c);
                    Seismic_PIMDOVSync.add_SeismicDOV_SFDC();
                    Seismic_PIMDOVSync.update_PIMDOVID_SFDC(5, Seismic_PIMDOVSync.tmpDOVInsertList);
                }

                recordsProcessed+=1;
            }
            
            if(Seismic_PIMDOVSync.tmpDOVInsertList.size() >0 && Seismic_PIMDOVSync.config.get('IsTest') != 'True'){
                insert Seismic_PIMDOVSync.tmpDOVInsertList;
                delete [SELECT Property_Name__c FROM Seismic_DOV__c WHERE PIM_GUID__c = null or PIM_GUID__c = ''];
            } 
        }
        catch (Exception e) {         
            Seismic_PIMDOVSync_Notification.senderrorEmail('Error occurred in Seismic_SFDC_BatchSync', 'Error occurred in Seismic_SFDC_BatchSync Execute : ' + e.getMessage());
            //throw e;            
        }
    }
        
    public void finish(Database.BatchableContext bc){ 
        Seismic_PIMConfig__c mconfig = [SELECT Value__c FROM Seismic_PIMConfig__c WHERE Key__c = 'Seismic_SDFC_SYNC' LIMIT 1];
        List<Seismic_DOV__c> tempTable = [SELECT Property_Name__c FROM Seismic_DOV__c LIMIT 1];
        
        if(mconfig.Value__c == 'False' && tempTable.size() >0){
            mconfig.Value__c = 'True';
            update mconfig;
        }
    }
}