public without sharing class PMP_CompanyWithNoActivebenefits {
        public static List<PMP_Company__c> activeMPIBenefits(){
          List<PMP_Company__c> cmpList = [select id, name,PMP_Benefit_Update_Ind__c,PMP_IPA_Badge_Tier_Txt__c from PMP_Company__c Limit 50000];
            set<Id> cmpIds = new set<id>(); 
            for(PMP_Company__c i :cmpList){
               cmpIds.add(i.id); 
            }                
           Set<id> accIds = new Set<id>();
           Set<String> benefitNames = new Set<String>();
           List<PMP_Company__c> partnerList= new List<PMP_Company__c>();
    		
           List<PMP_OPID_MPI_Rel__c> junctionObjects = PMP_Utility.getJunctionAccountToMpiByCompanyId(cmpIds);
            system.debug('companylist :'+junctionObjects);
            
           for(PMP_OPID_MPI_Rel__c opIDMPI: junctionObjects){
               if( opIDMPI.PMP_One_Partner_ID__c != null){
                   accIds.add(opIDMPI.PMP_One_Partner_ID__c);
               }
           }
           
            List<PRM_AccountBenefitAssociation__c> benefitList=[select Id, PRM_Account_Id__c, PRM_Partner_Benefit_Id__c,
                                                                PRM_Partner_Benefit_Id__r.name, PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,  
                                                                PRM_Status_Nm__c, IsValid__c, MPI_Benefit__c from PRM_AccountBenefitAssociation__c 
                                                                where PRM_Account_Id__c IN: accIds];
            for(PRM_AccountBenefitAssociation__c aba : benefitList){
                        if((aba.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c == 'BFTMKTPLBC' && aba.PRM_Status_Nm__c=='Active') || (aba.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c =='BFTMKTPLED' && aba.PRM_Status_Nm__c=='Active') || (aba.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c == 'BNFTSMBA' && aba.PRM_Status_Nm__c=='Active') ){
                            benefitNames.add(aba.PRM_Partner_Benefit_Id__r.Name);   
                        }
             }
            system.debug('benefitNames: '+benefitNames);
            
            //if((benefitNames.isempty() && cmpList.PMP_Benefit_Update_Ind__c == false) ||
             //  (cmpList.PMP_Benefit_Update_Ind__c == false && junctionObjects.isempty()) )
            //{
            //    partnerList.add(cmpList);           
            //}
              system.debug('companylist :'+partnerList);        
                  
            return partnerList;
        }    
    }