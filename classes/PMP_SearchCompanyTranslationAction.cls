/**************************************************************************************
Apex Class Name: PMP_SearchCompanyTranslationAction
Version     : 1.0 
Created Date: 21 June, 2019
Description : Class to create of update Company Translation records.
* Modification Log :
* Developer                 Date         Description
* ----------------------------------------------------------------------------
* Nikhil          21/06/2019               Original Version
* Nikhil          29/06/2019               Updated Object used from 'Marketplace Translation' to 'Company Translation'.
* Nikhil          29/06/2019               Added new method 'createTranslationRecords'
*************************************************************************************/

public without sharing class PMP_SearchCompanyTranslationAction {
    
    public static void insertTranslation(Boolean triggerContext, List<PMP_Company__c> newList){
        if (triggerContext)
        {
            List<PMP_Company_Translation__c> translationRecordList = new List<PMP_Company_Translation__c>(); //List of records to be insert
            
            for(PMP_Company__c partner:newList)
            {
                //To create record for tagline field
                PMP_Company_Translation__c trans = new PMP_Company_Translation__c();
                trans.Name = partner.Name;
                trans.PMP_Company_Information_Id__c = partner.id;
                trans.PMP_Field_Nm__c = PMP_StaticConstants_Partner.Tagline;
                translationRecordList.add(trans);
                
                //To create record for Description field
                trans = new PMP_Company_Translation__c();
                trans.Name = partner.Name;
                trans.PMP_Company_Information_Id__c = partner.id;
                trans.PMP_Field_Nm__c = PMP_StaticConstants_Partner.Description;
                translationRecordList.add(trans);  
            }
            try{
            	if(Schema.sObjectType.PMP_Company_Translation__c.isCreateable()){
                	insert translationRecordList;
            	}
            }catch(Exception e){
                System.debug('Error while insert operation for Company Translation records :'+ e);
            }
            
        }
    }
}