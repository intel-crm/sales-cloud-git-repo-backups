public class PMP_Company_Info_TriggerHandler extends TriggerHandler {
  
    Map<Id,PMP_Company__c> oldMap = (Map<Id,PMP_Company__c>) Trigger.oldMap;
    Map<Id,PMP_Company__c> newMap = (Map<Id,PMP_Company__c>) Trigger.newMap;
    Map<String,Core_Trigger_Executions__c> mapFunctionalityNameTriggerExecution = Core_Trigger_Executions__c.getAll(); 
    //Public Static Boolean solutionInsertOpidRecursive= false;/*IPA2.0: US-TWC729-7976*/
    //Public Static Boolean solutionUpdateOpidRecursive= false;/*IPA2.0: US-TWC729-7976*/
    //Public Static Boolean offeringSharingOpidRecursive = false;
    Public static Boolean mappingAttributeRecursive = false;
    
    public override void afterInsert() { 
        //Draco
        //Method Calling removed from loop US709757 July 06, 2020 Avanish
        //for(PMP_Company__c newCompany : (List<PMP_Company__c>) trigger.new){
          
             //   PMP_Company_Info_Sharing.shareCompanyInfoRecords(Trigger.Old, Trigger.New);
                
        //}

 
        
        //Tanzanite code added on 22nd Aug
        if(mapFunctionalityNameTriggerExecution.containsKey('Company_Info_Handler') && 
           mapFunctionalityNameTriggerExecution.get('Company_Info_Handler').Core_Active__c){  
               if(!mappingAttributeRecursive){
                   //TranslationEOL
          PMP_SearchCompanyTranslationAction.insertTranslation(Trigger.isInsert, trigger.new);
            PMP_AccountBenefitPartnerUtility.InsertCompanyAttributeMappingRecords(trigger.new);
                   mappingAttributeRecursive = true;
               }
               
        }
        
        //To create Staging Record
        if(mapFunctionalityNameTriggerExecution.containsKey('Company_Autofill_Handler') && mapFunctionalityNameTriggerExecution.get('Company_Autofill_Handler').Core_Active__c){ 
            PMP_Company_Info_TriggerHelper.createStagingFromCompany(trigger.new);
        }
		/*IPA2.0: US-TWC729-7976*/
        /*if((mapFunctionalityNameTriggerExecution.containsKey('MPI_Mem_Handler') && 
           mapFunctionalityNameTriggerExecution.get('MPI_Mem_Handler').Core_Active__c)&& (!solutionInsertOpidRecursive)){
               PSS_SolutionOPIDRollup.populateMPIOnSolution(trigger.new);
               solutionInsertOpidRecursive = true;
           }*/
    
    }
    
    public override void afterUpdate() {
        List<PMP_Company__c> newOwnerChangedCompanies = new List<PMP_Company__c>();
        List<PMP_Company__c> oldOwnerChangedCompanies = new List<PMP_Company__c>();

        findOwnerChangedCompanies(newOwnerChangedCompanies, oldOwnerChangedCompanies);

        if (triggerExecutionActive('PMP_Companyinfosharing_handler')) {
            shareCompanyInfoIfChanged(newOwnerChangedCompanies, oldOwnerChangedCompanies);
        }
        //IPA 2.0 TWC729-8060
        // if (triggerExecutionActive('MPI_Auto_Benefit_Handler')) {
        //     autoAssignBenefitsOnMpiBenefitChange();
        // }

        if (triggerExecutionActive('Company_Info_Handler')) {
            handleCompanyInfoUpdates();
        }
		/*IPA2.0: US-TWC729-7976*/
        /*if (triggerExecutionActive('MPI_Mem_Handler') && !solutionUpdateOpidRecursive) {
            updateMPIOnSolution();
        }*/
    }

        private void findOwnerChangedCompanies(List<PMP_Company__c> newOwnerChangedCompanies, List<PMP_Company__c> oldOwnerChangedCompanies) {
            for (PMP_Company__c newCompany : (List<PMP_Company__c>) Trigger.new) {
                if (newCompany.OwnerId != oldMap.get(newCompany.Id).OwnerId) {
                    newOwnerChangedCompanies.add(newCompany);
                    oldOwnerChangedCompanies.add((PMP_Company__c) Trigger.oldMap.get(newCompany.Id));
                }
            }
        }

        private void shareCompanyInfoIfChanged(List<PMP_Company__c> newOwnerChangedCompanies, List<PMP_Company__c> oldOwnerChangedCompanies) {
            if (!newOwnerChangedCompanies.isEmpty() && !oldOwnerChangedCompanies.isEmpty()) {
                PMP_Company_Info_Sharing.shareCompanyInfoRecords(oldOwnerChangedCompanies, newOwnerChangedCompanies);
            }
        }
        //IPA 2.0 TWC729-8060
        // private void autoAssignBenefitsOnMpiBenefitChange() {
        //     PMP_AccountBenefitPartnerUtility.autoAssignBenefitsOnMpiBenefitChange((Map<Id, PMP_Company__c>) Trigger.newMap, (Map<Id, PMP_Company__c>) Trigger.oldMap);
        // }

        private void handleCompanyInfoUpdates() {
            if (PMP_SearchTierTriggerUtility.runOnce() && PMP_StaticConstants_Partner.isCompanyAfterUpdateTriggerActive) {
                PMP_SearchCompanyLeadGenAction.updatePublishedCopy(Trigger.isUpdate, Trigger.new, Trigger.old, newMap, oldMap);
                PMP_SearchPartnerTriggerHelper.syncPublishedPartnerCopy(Trigger.new, oldMap);
            }

            if (!mappingAttributeRecursive) {
                 //TranslationEOL
                //PMP_SearchPartnerTriggerHelper.createTranslationForRSSFeed(Trigger.new, oldMap);
                PMP_Company_Info_TriggerHelper.updatecompanyAttributeMappingRecords(Trigger.new, oldMap);
                mappingAttributeRecursive = true;
            }
        }
		/*IPA2.0: US-TWC729-7976*/
        /*private void updateMPIOnSolution() {
            PSS_SolutionOPIDRollup.updateMPIOnSlution(Trigger.new, oldMap);
            solutionUpdateOpidRecursive = true;
        }*/

        private Boolean triggerExecutionActive(String functionalityName) {
            return mapFunctionalityNameTriggerExecution.containsKey(functionalityName) && 
                mapFunctionalityNameTriggerExecution.get(functionalityName).Core_Active__c;
        }


    
     public override void beforeInsert() {

       // PMP_AccountBenefitPartnerUtility.checkIfAnyActiveOpidMpiRelationshipExists(Trigger.new);
        if(mapFunctionalityNameTriggerExecution.containsKey('Company_Info_Handler') && 
           mapFunctionalityNameTriggerExecution.get('Company_Info_Handler').Core_Active__c){
               PMP_Company_Info_TriggerHelper.updateCompanyRegionOnCountryChange(trigger.new, NULL);
     }
     }
    
     public override void beforeUpdate() {
         
        if(mapFunctionalityNameTriggerExecution.containsKey('Company_Info_Handler') && 
           mapFunctionalityNameTriggerExecution.get('Company_Info_Handler').Core_Active__c){
               PMP_Company_Info_TriggerHelper.updateCompanyRegionOnCountryChange(trigger.new, oldMap);
			   PMP_Company_Info_TriggerHelper.updateIntelAdmin(trigger.new, oldMap);

     }
       //IPA 2.0 TWC729-8060
    /* if((mapFunctionalityNameTriggerExecution.containsKey('OPID_MPI_Validation_Handler') && 
     mapFunctionalityNameTriggerExecution.get('OPID_MPI_Validation_Handler').Core_Active__c)){
        PMP_AccountBenefitPartnerUtility.validateForAutoAssignBenefits((Map<Id,PMP_Company__c>)Trigger.newMap,(Map<Id,PMP_Company__c>)Trigger.oldMap);
     }  */    
      /*for(PMP_Company__c newCompany : (List<PMP_Company__c>) trigger.new){
             if(newCompany.PMP_Partner_Benefit_Type__c == PMP_StaticConstants_Partner.Solutions_Marketplace_Basic_Profile && 
                oldMap.get(newCompany.Id).PMP_Partner_Benefit_Type__c  == PMP_StaticConstants_Partner.Solutions_Marketplace_Enhanced ){
                    newCompany.PMP_Suppress_Email_Ind__c=false;
                }
         }*/
     }   

}