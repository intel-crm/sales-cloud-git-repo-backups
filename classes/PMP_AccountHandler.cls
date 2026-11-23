/**************************************************************************************
Apex Class Name:  PMP_AccountHandler
Version     : 1.0 
Created Date: 13 JAN 2021
Function    : methods to handle the company records updation.
Modification Log :
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Gopala Krishna Ch              01/13/2021              Original Version
*************************************************************************************/



public without sharing class PMP_AccountHandler {
    
    /***************************************************************************************************** 
Method Name:                                             filterDistiBizOrgs
@return  :                                               String
Modified By:                          Date:              Changes: 
Gopala Krishna Ch                     01/13/2021         US854868 - KTBE : Changes in Biz org, Specialty, Partner Segment should show the updated data. 
******************************************************************************************************/    
    public static String filterDistiBizOrgs(String accountBizType){
        
        String bizorgtype = '';
        if(accountBizType!=''){
            for(String biz : accountBizType.split('\\;')){
                if(PMP_StaticConstants_Partner.bizOrgTypes.contains(biz)){
                    
                    bizorgtype += biz + ';';
                }
            }
            
            if(bizorgtype.endsWith(';')) {
                bizorgtype = bizorgtype.substring(0, bizorgtype.length() - 1);
            }
        }
        return bizorgtype;
    }
    
    /***************************************************************************************************** 
Method Name:                                             updatePartnerInfo
return  :                                               String
Description                                              This method is used to update the company records
Modified By:                          Date:              Changes: 
Gopala Krishna Ch                     01/13/2021         US854868 - KTBE : Changes in Biz org, Specialty, Partner Segment should show the updated data. 
Sathish                               12/9/2021          OPID Restructure - update company details when any account related to the Company changes
******************************************************************************************************/    
    public static void updatePartnerInfo(List<Account> newList, Map<Id,Account> newMap, Map<Id,Account> oldMap) {
        String programMembership = '';
        String partnerProgram = '';
        Set<Id> accountsChanged = new Set<Id>();
        
        List<PMP_Company__c> updateCompanies = new List<PMP_Company__c>();
        Id intelacc_rectypeid = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Mastered_Account').getRecordTypeId();
        Id pagRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PMP_StaticConstants_Partner.pagRecordTypeName).getRecordTypeId();
                  
        Set<Id> accountsAccTypeChanged = new Set<Id>();
        Map<String,String> accountProgramMembershipMap = new Map<String,String>();
        Map<String,String> accountPartnerProgramMap = new Map<String,String>();
        
        try{
            if(!newList.isempty()){
                for(Account acc : newList){
                    Account old = oldMap.get(acc.Id);
                    
                    if(( acc.RecordTypeId == pagRecordTypeId ) && (acc.Core_IPA_Partner_Speciality__c != old.Core_IPA_Partner_Speciality__c  || acc.Core_IPA_Partner_Segment__c != old.Core_IPA_Partner_Segment__c)){
                        accountsChanged.add(acc.Id);
                    }
                    if(( acc.RecordTypeId == pagRecordTypeId ) && (acc.Core_Account_Type__c != old.Core_Account_Type__c )){
                        accountsChanged.add(acc.Id);
                        accountsAccTypeChanged.add(acc.Id); //Added by Krishna Ch DE112186
                      /*  system.debug('accountsChanged==>'+accountsChanged);
                       for(string str :  acc.Core_Account_Type__c.split('\\;')){
                            if(PMP_StaticConstants_Partner.accountBizOrgTypeValues.contains(str) ){
                                accountsAccTypeChanged.add(acc.Id);
                                system.debug('accountsAccTypeChanged==>'+accountsAccTypeChanged);
                            }
                           
                        }*/
                    }
                    system.debug('acc.RecordTypeId  - ' + acc.RecordTypeId + 'intelacc_rectypeid - ' + intelacc_rectypeid);
                    if((acc.RecordTypeId == intelacc_rectypeid )&& 
                       (acc.Name != old.Name || 
                        acc.Core_IPA_Partner_Speciality__c != old.Core_IPA_Partner_Speciality__c  ||
                        acc.Core_User_Defined_Website__c != old.Core_User_Defined_Website__c ||
                        acc.Core_IPA_Partner_Role__c != old.Core_IPA_Partner_Role__c)){
                            accountsChanged.add(acc.Id);
                        }
                }
            }

           // PMP_AccountBenefitPartnerUtility.updateTierOnMPI(accountsChanged);
            
            
            // Commented as part of OPID Restructure - Sathish  [09/Dec/2021]
           
            /*  if(!accountsAccTypeChanged.isempty()){
                
                List<PRM_AccountChannelMembership__c> acMercList =[SELECT PRM_Account_Id__c,PRM_Account_Id__r.Core_Account_Type__c,PRM_Channel_Program_Level_Id__r.Name,toLabel(PRM_Partner_Role__c) FROM PRM_AccountChannelMembership__c where  PRM_Status_Nm__c='Approved' AND PRM_Account_Id__c IN :accountsAccTypeChanged WITH SECURITY_ENFORCED];
                system.debug('acMercList==>'+acMercList);
                if(acMercList != NULL && !acMercList.isempty() ){
                    for(PRM_AccountChannelMembership__c acMrec : acMercList){
                        String bizorgtype = '';
                        String progMembership = '';
                        if(acMrec.PRM_Account_Id__r.Core_Account_Type__c!=null){
                            bizorgtype = filterDistiBizOrgs(acMrec.PRM_Account_Id__r.Core_Account_Type__c);  
                        }
                        if(acMrec.PRM_Partner_Role__c == PMP_StaticConstants_Partner.distributor ){
                            integer i = bizorgtype.split('\\;').size();
                            if(bizorgtype.split('\\;').size() > 1){
                                for(String biz : bizorgtype.split('\\;')){
                                    progMembership += PMP_StaticConstants_Partner.distributor + ' - ' + biz + ';';
                                }
                                if(progMembership.endsWith(';')) {
                                    progMembership = progMembership.substring(0, progMembership.length() - 1);
                                }
                            }
                            else if(String.isEmpty(bizorgtype) && acMrec.PRM_Account_Id__r.Core_Account_Type__c!=null){
                                
                                progMembership = acMrec.PRM_Account_Id__r.Core_Account_Type__c.contains(PMP_StaticConstants_Partner.distributor) ? PMP_StaticConstants_Partner.distributor:'';

                            }
                            else{ 
                                progMembership = PMP_StaticConstants_Partner.distributor + ' - ' + bizorgtype;
                            }
                        }                          
                        else{
                            progMembership =  acMrec.PRM_Partner_Role__c + ' - ' + acMrec.PRM_Channel_Program_Level_Id__r.Name;
                            if(acMrec.PRM_Account_Id__r.Core_Account_Type__c !=null && acMrec.PRM_Partner_Role__c == PMP_StaticConstants_Partner.solProvider && acMrec.PRM_Account_Id__r.Core_Account_Type__c.contains(PMP_StaticConstants_Partner.solAggregator)){
                                progMembership =  acMrec.PRM_Partner_Role__c + ' - ' + PMP_StaticConstants_Partner.solAggregator;
                            }
                            
                        }
                        
                        if(!programMembership.contains(progMembership)){
                            programMembership += ';'  + progMembership;
                        }
                        if(!partnerProgram.contains(';'+acMrec.PRM_Partner_Role__c)){
                            partnerProgram += ';'  + acMrec.PRM_Partner_Role__c;
                        }
                        accountProgramMembershipMap.put(acMrec.PRM_Account_Id__c,programMembership);
                        accountPartnerProgramMap.put(acMrec.PRM_Account_Id__c,partnerProgram);
                    } 
                }
            }
            
            if(!accountsChanged.isempty())
            {
                // Code starts here - OPID Restructure by tilak 
                PMP_Utility utiltyHelper = new PMP_Utility();
				Map<Id,PMP_Company__c> accountToMPI = utiltyHelper.getAccountRelatedMPIRecord(accountsChanged);
				for(Id accountIds : accountToMPI.keySet())
				{
					PMP_Company__c temp = accountToMPI.get(accountIds);
					Account accNew = newMap.get(accountIds);
                    Account accOld = oldMap.get(accountIds);
					
                    temp.PMP_Account_Specialty__c    = accNew.Core_IPA_Partner_Speciality__c;                                               
                    temp.PMP_Partner_Segment_Nm__c    = accNew.Core_IPA_Partner_Segment__c;
					
					if(accNew.Core_Account_Type__c != accOld.Core_Account_Type__c && accountProgramMembershipMap.containskey(accountIds))
					{
                        temp.PMP_Account_Program_Membership__c = accountProgramMembershipMap.get(accountIds);
                        temp.PMP_Partner_Program_nm__c = accountPartnerProgramMap.get(accountIds);
                    }
                    updateCompanies.add(temp);
				}
                // code ends here Get all Junction object related to changed account which is active - tilak 30/09/2021
				
				/* Commented and handled in [Get all Junction object related to changed account which is active - tilak 30/09/2021]
                for(PMP_Company__c comp : [Select Id, PMP_Account_Id__c,PMP_Account_Id__r.Core_IPA_Partner_Speciality__c,PMP_Account_Id__r.Core_IPA_Partner_Segment__c,PMP_Account_Specialty__c,PMP_Partner_Segment_Nm__c, PMP_Account_Program_Membership__c,PMP_Partner_Program_nm__c From PMP_Company__c Where PMP_Account_Id__c IN: accountsChanged]){
                    
                    Account accNew = newMap.get(comp.PMP_Account_Id__c);
                    Account accOld = oldMap.get(comp.PMP_Account_Id__c);
                    
                    comp.PMP_Account_Specialty__c    = accNew.Core_IPA_Partner_Speciality__c;                                               
                    comp.PMP_Partner_Segment_Nm__c    = accNew.Core_IPA_Partner_Segment__c;
                    
                    if(accNew.Core_Account_Type__c != accOld.Core_Account_Type__c && accountProgramMembershipMap.containskey(comp.PMP_Account_Id__c)){
                        comp.PMP_Account_Program_Membership__c = accountProgramMembershipMap.get(comp.PMP_Account_Id__c);
                        comp.PMP_Partner_Program_nm__c = accountPartnerProgramMap.get(comp.PMP_Account_Id__c);
                    }
                    updateCompanies.add(comp);
                }
				*/
            }/*
            
            if(!updateCompanies.isempty() && Schema.sObjectType.PMP_Company__c.isUpdateable()){  
                update updateCompanies;
            }
        } */
        
        catch (exception ex){
            PMP_Utility.logError(ex,'PMP_AccountHandler');
        }
        
        
    } 
    
}