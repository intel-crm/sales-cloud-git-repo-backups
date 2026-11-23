public  class PSG_CpQuoteCloneController {
    
   @AuraEnabled
    public static GlobalVariables doClone (String sObjectId,String action){  
               GlobalVariables globalVar = new GlobalVariables();
        System.debug('sObjectId'+sObjectId);
        List<SBQQ__Quote__c> originalQuote;
        SBQQ__Quote__c clonedQuote;
        String query;
        //id userId = UserInfo.getUserId();
        Id cpRecordType = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('PSG_Quote_Contract_Pricing').getRecordTypeId();
        Boolean allowClone = true;
        Boolean allowRevision = true;
        Boolean allowRevisionBasedOnStatus = true;
            //try {
                query = String.format(
                       'SELECT {0} FROM {1} WHERE Id = \'\'{2}\'\'',
                        new String[] {
                           String.join(
                               new List<String>(
                                   SBQQ__Quote__c.SObjectType.getDescribe().fields.getMap().keySet()
                               ),
                               ','
                           ),
                               String.valueOf(SBQQ__Quote__c.SObjectType),
                               sObjectId
                               }
                );
                   // Query and gets results
 
                originalQuote = Database.query(query);
                if(allowClone ){
                   // Clone the original object. Here you can change anything without affecting the original sObject
                   clonedquote = originalquote[0].clone(false, true, false, false);
              if(action=='clone'){
                /*for(String fieldName : (Label.PSG_QuoteFieldsNull).split(':')){
                    clonedQuote.put(fieldName,null);
                }
                for(String fieldName : (Label.PSG_clone_quote_boolean_to_false).split(':')){
                    clonedQuote.put(fieldName,false);
                }*/
            }
            
              clonedQuote.core_cpq_original_quote__c = originalquote[0].Id;
            //Code seperation for revision and clone
            if(action == 'revision'){
                /*for(String fieldName : (Label.PSG_rev_Quote_fields_toNull).split(':')){
                    clonedQuote.put(fieldName,null);
                }*/
                 clonedQuote.core_cpq_send_email__c=false;
                //Parent quote is setting to inactive
                originalquote[0].core_cpq_active_cb__c = false; 
                 //Quote revision setting the value of the immediate quote.
                clonedQuote.core_cpq_original_quote__c = originalquote[0].Id;
                originalquote[0].core_cpq_quote_revised_cb__c = true;   //Added by Sushmita as a part of US936101
                //Quote revision setting the value of the ultimate parent quote number and Id.
                if(originalquote[0].core_cpq_revision_nbr__c == 1){
                    clonedQuote.core_cpq_ultimate_parent_quote__c = originalquote[0].Id;
                    clonedQuote.core_cpq_ultimate_quote_number_nbr__c = originalquote[0].Name;
                }else{
                    clonedQuote.core_cpq_ultimate_parent_quote__c = originalquote[0].core_cpq_ultimate_parent_quote__c;
                    clonedQuote.core_cpq_ultimate_quote_number_nbr__c = originalquote[0].core_cpq_ultimate_quote_number_nbr__c;
                }                
                clonedQuote.core_cpq_status_txt__c = 'In Progress';
                clonedQuote.SBQQ__Status__c = 'In Progress';
                clonedQuote.core_cpq_assigned_by_nm__c = null;
                clonedQuote.core_cpq_assigned_on__c = null;
                clonedQuote.core_cpq_assigned_to_nm__c = null;

                if(originalquote[0].core_cpq_revision_nbr__c != null){
                    clonedQuote.core_cpq_revision_nbr__c = originalquote[0].core_cpq_revision_nbr__c + 1;
                }else{
                    clonedQuote.core_cpq_revision_nbr__c = 1;
                }                        
            }else if(action == 'clone'){
                clonedQuote.core_cpq_revision_nbr__c = 1;
                clonedQuote.core_cpq_active_cb__c = true;
                clonedQuote.core_cpq_status_txt__c = 'In Progress';
                clonedQuote.SBQQ__Status__c = 'In Progress';
                clonedQuote.core_cpq_quote_revised_cb__c = false;
                clonedQuote.ownerId = userinfo.getUserId();
               // parentSObjects[0].core_cpq_active_cb__c = true; //added newly
                //parent.core_cpq_quote_type_nm__c = parentSObjects[0].core_cpq_quote_type_nm__c;//added newly
                

            }
                   Database.insert(clonedQuote);
                 if(action == 'Revision'){
                   update originalQuote[0];
                 }
                if(action == 'clone'){
                globalVar.messageResult = Label.PSG_Quote_Clone_Success_Message;
            }else{                                   
                globalVar.messageResult = Label.PSG_Quote_Revise_Success_Message;
            }
            globalVar.isSuccess = true;
            globalVar.quoteId = clonedQuote.Id;
             //} 
            /*catch (Exception error) 
            {
                   //Create Error Log when an Exception Occurs
                   Pricing_Tender_Utility.logError(error);
                   globalVar.messageResult = JSON.serialize(error.getMessage());
                   globalVar.quoteId = null;
                   globalVar.isSuccess = false;
                   return globalVar;
             }*/
        }
        /*else
        {
            globalVar.messageResult = Label.PSG_No_Access_Error_Message;
            globalVar.isSuccess = false;
            globalVar.dpaId = null;
        }*/
        return globalVar;
    }
    
    
    public class GlobalVariables{
		@AuraEnabled public String messageResult {get;set;} 
		@AuraEnabled public Id quoteId {get;set;} 
		@AuraEnabled public Boolean isSuccess {get;set;}
    }  
    
}