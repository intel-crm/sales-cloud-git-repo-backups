/*************************************************************************************************************************************
Apex Class Name     : PCC_Submit_DesignRegistrationController
Created Date        : Dec 2023
Function            : Controller class for the aura PCC_Submit_DesignRegistration - used to show the submit for approval button on 
DR when in draft status.
Modifications   :
****************************************************************************************************
* Developer                 Date                Description
* ----------------------------------------------------------------------------  
* Shivini                 27-sep-2024         Added WITH USER_MODE to SOQL and DML statements.
************************************************************************************************************************************************/

public with sharing class PCC_Submit_DesignRegistrationController {

    public static final String LOG_ENTRY_ORIGIN   = 'PCC_Submit_DesignRegistrationController';
    public static final String LOG_ENTRY_PROJECT  = 'DDR Registration';
    public static final String LOG_ENTRY_SCOPE    = 'Submit DDR For Approval';
    public static final String LOG_ENTRY_ERROR    = 'Error';
    public static final String LOG_ENTRY_SEVERITY = 'Error';
    public static final String LOG_ENTRY_INFO     = 'Info';

     @auraEnabled
    public static Boolean productsAvailableonDr(Id recId){
        Boolean productsAvailable = false ;
        try{
            list<Core_Design_Registration_Product__c> drProductList = [SELECT id,Core_Design_Product_Status_Nm__c,Core_Design_Registration_Id__c from Core_Design_Registration_Product__c where Core_Design_Registration_Id__c =:recId and Core_Design_Product_Status_Nm__c ='Pending' WITH USER_MODE];
         if(!drProductList.isEmpty())
            {
             productsAvailable = true;
            } 
               
        }catch (Exception e) {Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_Submit_DesignRegistrationController.productsAvailableonDr' ,'' ,e); throw new AuraHandledException(LabelConfiguration__mdt.getInstance('Core_DDR_Button_Exceptions').Value__c);
        }
        return productsAvailable;
    }
    
    @AuraEnabled
    public static void logictochangestatus(String recId){
        try{
            List<Core_Design_Registration__c> drList = [
                SELECT Id, Core_Product_Group_Nm__c, Core_Design_Registration_Status_Nm__c, Workflow_Status__c 
                FROM Core_Design_Registration__c 
                WHERE Id = :recId WITH USER_MODE];
            if(!drList.isEmpty())
            {
                drList[0].Core_Design_Registration_Status_Nm__c = 'Submitted';
                drList[0].Workflow_Status__c = 'Submitted';
                update drList[0];
            }
        }catch (Exception e) {Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_Submit_DesignRegistrationController.logictochangestatus' ,'' ,e);throw new AuraHandledException(LabelConfiguration__mdt.getInstance('Core_DDR_Button_Exceptions').Value__c);
        }           
    }
    @AuraEnabled
    public static boolean getDRStatus(Id recId){
        boolean drDraftStatus;
        try{
        list<Core_Design_Registration__c> drList = [SELECT id,Core_Product_Group_Nm__c,Core_Design_Registration_Status_Nm__c,Workflow_Status__c from Core_Design_Registration__c where Core_Design_Registration__c.id =:recId WITH USER_MODE ];
        if(drList[0].Core_Design_Registration_Status_Nm__c=='Draft'){
            drDraftStatus=true;        
        }
            
        }catch (Exception e) {Core_Log_Entry.logEntryWithException(LOG_ENTRY_ORIGIN, LOG_ENTRY_PROJECT, LOG_ENTRY_SCOPE, LOG_ENTRY_SEVERITY,'', '' ,'' ,'PCC_Submit_DesignRegistrationController.getDRStatus' ,'' ,e);throw new AuraHandledException('Couldn\'t fetch the dr status'+ e.getStackTraceString());
        }
        return drDraftStatus;
    }

}