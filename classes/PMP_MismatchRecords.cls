/* Created By - Harsh Mishra
 Created Date -12/09/2022
*/
public class PMP_MismatchRecords {
    
    public static Set<Id> opidBadgeTierCheck(){
        Set<Id> setOfMpi = new Set<Id>();
        Map<Id,String> mapMpiToBadgeTier = new  Map<Id,String>();
        Set<Id> companyId = new Set<Id>();
        Map<Id,List<Id>> mapOfMpiIdToOpids = new  Map<Id,List<Id>>();
        Set<Id> accountIds= new Set<Id>();
        List<Id> accIds = new List<Id>();
        Map<Id,String> mapOfAccountToBadgeTier = new Map<Id,String>();
        Map<Id,List<String>> mapOfMpiIdToOpid = new Map<Id,List<String>>();
        Map<Id,String> mapOfMpiToCalcBadgeTier = new Map<Id,String>();
        set<Id> setOfMismatchbenefitMpiIds = new set<Id>();
        Set<Id> setOfMismatchOpidCount = new Set<Id>();
        Set<Id> setOfMismatchRevokedFlagToBenefit = new Set<Id>();
        Set<Id> setOfMpiForBenefit= new Set<Id>();
        Map<Id,List<PRM_AccountChannelMembership__c>>mapOfIdToAcm = new Map<Id,List<PRM_AccountChannelMembership__c>>();
        Map<Id,List<PRM_AccountBenefitAssociation__c>>mapOfIdToBenefits = new Map<Id,List<PRM_AccountBenefitAssociation__c>>();
        List<PMP_Company__c> comp = [Select Id, Name,PMP_Benefit_Update_Ind__c,PMP_Partner_Benefit_Type__c,
                                     PMP_IPA_Badge_Tier_Txt__c,PMP_Active_OPID_Cnt__c
                                     from PMP_Company__c where  PMP_Company_Lifecycle_Status_Nm__c='Published' ORDER BY createdDate DESC ];
        
        for(PMP_Company__c com : comp ){
            mapMpiToBadgeTier.put(com.Id, com.PMP_IPA_Badge_Tier_Txt__c);
            companyId.add(com.Id);    
        }
        
        List<PMP_OPID_MPI_Rel__c>  juncObjects = [ select Id,PMP_One_Partner_ID__c,
                                                  PMP_Marketing_Profile_Id__c,PMP_Marketing_Profile_Id__r.PMP_Working_Copy_Id__c,
                                                  Is_Active__c
                                                  from PMP_OPID_MPI_Rel__c 
                                                  where Is_Active__c = true];
        
        // creating a map of MPI TO LIST OF ALL RELATED OPIDs
        for(PMP_OPID_MPI_Rel__c opidMPI :juncObjects){
            if(mapOfMpiIdToOpids.get(opidMPI.PMP_Marketing_Profile_Id__c)==null){
                mapOfMpiIdToOpids.put(opidMPI.PMP_Marketing_Profile_Id__c,new List<Id>{opidMPI.PMP_One_Partner_ID__c});
            }
            else{
                mapOfMpiIdToOpids.get(opidMPI.PMP_Marketing_Profile_Id__c).add(opidMPI.PMP_One_Partner_ID__c);
            }
        }
        System.debug('mapOfMpiIdToOpids'+mapOfMpiIdToOpids);
        
        List<PMP_OPID_MPI_Rel__c> junctionObjects =PMP_Utility.getJunctionAccountToMpiByCompanyId(companyId);
        
        for(PMP_OPID_MPI_Rel__c obj :junctionObjects){
            accountIds.add(obj.PMP_One_Partner_ID__c);
        }
        List<PRM_AccountBenefitAssociation__c> benefitList =[select Id,Name,PRM_Status_Nm__c,PRM_Partner_Benefit_Id__c,
                                                             PRM_Partner_Benefit_Id__r.Name,PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c,PRM_Account_Id__c
                                                             from PRM_AccountBenefitAssociation__c
                                                             Where PRM_Account_Id__c IN :accountIds  AND PRM_Status_Nm__c='Active' 
                                                             ];
        for(PRM_AccountBenefitAssociation__c benefit : benefitList){
            if(mapOfIdToBenefits.get(benefit.PRM_Account_Id__c)==null){
                mapOfIdToBenefits.put(benefit.PRM_Account_Id__c,new List<PRM_AccountBenefitAssociation__c>{benefit});
            }
            else{
                mapOfIdToBenefits.get(benefit.PRM_Account_Id__c).add(benefit);
            }
        }
        System.debug('mapOfIdToBenefits'+mapOfIdToBenefits);
       
        
        
        
        List<PRM_AccountChannelMembership__c> acmList = [Select Id,Name, PRM_Account_Id__c,PRM_Channel_Program_Level_Id__r.Name 
                                                         From PRM_AccountChannelMembership__c 
                                                         where PRM_Account_Id__c IN :accountIds 
                                                         AND PRM_Status_Nm__c='Approved'];
        
        
        for(PRM_AccountChannelMembership__c acm :acmList){
            if(mapOfIdToAcm.get(acm.PRM_Account_Id__c)==null){
                mapOfIdToAcm.put(acm.PRM_Account_Id__c, new List<PRM_AccountChannelMembership__c>{acm});
            }
            else{
                mapOfIdToAcm.get(acm.PRM_Account_Id__c).add(acm);
            }
        }
        
        // calculate highest badge tier and storing in a map
        for(Id badge :mapOfIdToAcm.keySet() ){     
            mapOfAccountToBadgeTier.put(badge, PMP_AccountBenefitPartnerUtility.calculateIpaBadgeTier(mapOfIdToAcm.get(badge)));          
        }
        
        for(PMP_OPID_MPI_Rel__c obj :junctionObjects){
            if(mapOfMpiIdToOpid.get(obj.PMP_Marketing_Profile_Id__c) == null){
                mapOfMpiIdToOpid.put(obj.PMP_Marketing_Profile_Id__c,new List<String>{mapOfAccountToBadgeTier.get(obj.PMP_One_Partner_ID__c)});
            }
            else{
                mapOfMpiIdToOpid.get(obj.PMP_Marketing_Profile_Id__c).add(mapOfAccountToBadgeTier.get(obj.PMP_One_Partner_ID__c));
            }
        }
        
        // final calculated badge tier for MPI
        for( Id MpiId : mapOfMpiIdToOpid.keySet()){
            mapOfMpiToCalcBadgeTier.put(MpiId,calculateIpaBadgeTier(mapOfMpiIdToOpid.get(MpiId)));
        }
        
        for(PMP_company__c mpiRecs : comp){
            
            // OPID - if all tiers inactive - then all marketplace benefits should be inactive and mpi benefit revked flag should be true
            if(mapOfMpiToCalcBadgeTier.get(mpiRecs.id)==null && !mpiRecs.PMP_Benefit_Update_Ind__c ) {   
                setOfMpi.add(mpiRecs.Id);        
            }
            
            //Any MPI with benefit revoked flag false , should atleast have one active junction object
            if(!MpiRecs.PMP_Benefit_Update_Ind__c && MpiRecs.PMP_Active_OPID_Cnt__c<1){
                setOfMpi.add(MpiRecs.Id);
            }
            
            // OPID - if all marketplace benefits are inactive - mpi benefit revoked flag should be true
         /* if((mapOfMpiIdToOpids.get(mpiRecs.id)==null || mapOfMpiIdToOpids.get(mpiRecs.id).isEmpty()) && !mpiRecs.PMP_Benefit_Update_Ind__c ){
          //      setOfMpi.add(mpiRecs.Id);
           } */
            if(mapOfMpiIdToOpids.get(mpiRecs.id)!=null){
                for(Id opid :mapOfMpiIdToOpids.get(mpiRecs.id)){
                    if(mapOfIdToBenefits.get(opid)!=null){
                         for(PRM_AccountBenefitAssociation__c benefit :mapOfIdToBenefits.get(opid) ){
                            if(benefit.PRM_Partner_Benefit_Id__r.Name!='Solutions Marketplace Basic Access' &&
                               benefit.PRM_Partner_Benefit_Id__r.Name!='Solutions Marketplace Basic Profile' &&
                               benefit.PRM_Partner_Benefit_Id__r.Name!='Solutions Marketplace Enhanced' &&
                               !mpiRecs.PMP_Benefit_Update_Ind__c ){
                                   setOfMpiForBenefit.add(mpiRecs.Id); 
                                   
                               }
                            else if(!setOfMpiForBenefit.isEmpty()){
                                 
                                setOfMpiForBenefit.clear();
                                break;
                                
                            }      
                        }
                    }
                    else if(!mpiRecs.PMP_Benefit_Update_Ind__c){
                        setOfMpiForBenefit.add(mpiRecs.Id);
                        
                    }
                    if(setOfMpiForBenefit.isEmpty()){
                        break;
                    }
                }
                setOfMpi.addAll(setOfMpiForBenefit);
               
                setOfMpiForBenefit.clear();
            }

           
            
        }
        
         //OPID - if all tiers inactive - mpi tier should be blank and based on active tier show correct tier on mpi
       for(PMP_OPID_MPI_Rel__c jc : junctionObjects){  
            
            if( mapMpiToBadgeTier!=null && !mapMpiToBadgeTier.isEmpty()  &&  mapMpiToBadgeTier.get(jc.PMP_Marketing_Profile_Id__c) != mapOfMpiToCalcBadgeTier.get(jc.PMP_Marketing_Profile_Id__c)){
                setOfMpi.add(jc.PMP_Marketing_Profile_Id__c);              
            }
            
        }
        
        System.debug('setOfMpi'+ JSON.serializePretty(setOfMpi));
        
        system.debug('setOfMpisize'+setOfMpi.size());
        return setOfMpi;
        
    }
    
    public static String calculateIpaBadgeTier(List<String> acmList){
        Map<String,Integer> tierAndRankMap = new Map<String,Integer>{'Member' => 1, 'Gold' => 2, 'Titanium' => 3};
            Map<Integer,String> rankAndTierMap = new Map<Integer,String>{1 => 'Member', 2 => 'Gold', 3 => 'Titanium'};    
                
                Integer highestTierRank = 0;
        
        for(String acm : acmList){
            if(tierAndRankMap.get(acm) > highestTierRank){
                highestTierRank = tierAndRankMap.get(acm); 
            }
        }
        
        return rankAndTierMap.get(highestTierRank);
    }
    
}