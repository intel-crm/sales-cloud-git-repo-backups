/***************************************************************************************************************************************************************************************************
Apex Class Name:  Core_PSG_UpdateSignalCodeFromStaging
Version     : 1.0 
Created Date: 07 Sept 2021
Function    : CLass to call a Batch which updates Signal Code from PSG Staging table to Product Table
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Sandhya Dayananda             07 Sept 2021            Original Version

*****************************************************************************************************************************************************************************************************/
@isTest
public class Core_PSG_UpdateSignalCodeFromStaging {

    /*@InvocableMethod
    public static void updateSignalCode() {  
        List<Core_PIR_Ext_Attributes__c> lstStaging= new List<Core_PIR_Ext_Attributes__c>();
    	try{          
        	Database.executeBatch(new Core_PSG_ProcessSignalCodeFromStaging());         
        }
        catch(exception e){
        	system.debug('**exception** -->'+ e);
        }
    }*/
}