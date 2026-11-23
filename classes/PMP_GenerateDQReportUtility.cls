/****************************************************************************************************************************************
* Class Name  : PMP_GenerateDQReportUtility 
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
*
* Developer                           Date                          Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Yashasvi Aggarwal                 22/08/2022            this class is used to find Partner and Offering Issue records and upsert the records 
                                                          in PMP_Marketplace_DQ_Monitor__c object
                                                          External key = Issue Type + Sub Issue Type + RecordId + Issue No
                                                          Note - Issue No is unqiue and last Issue No is DQ22
*****************************************************************************************************************************************/
public class PMP_GenerateDQReportUtility {
    public static String dashboardLink {get;set;}
    
/*************************************************************************************************************
* Method Name : matchString
* Description : this method is used to determine language of input text
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
**************************************************************************************************************/
    public static Boolean matchString(String inputText)
    {
        String regex = '[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff\uff66-\uff9f]';
        Pattern regexPattern = Pattern.compile(regex);
        Matcher regexMatcher = regexPattern.matcher(inputText);
        return regexMatcher.find();
    }

/*************************************************************************************************************
* Method Name : getPartnerTranslationRecords
* Description : this method is used to determine GLS Translation Partner Issue records
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
**************************************************************************************************************/
    public static void getPartnerTranslationRecords(List<PMP_Company__c> partnerList)
    {
       
        for(PMP_Company__c partner : partnerList)
        {
            try
            {
                if(partner.PMP_Company_Information_Language_Nm__c!=null && partner.Name!=null && partner.PMP_Account_Tag_Line__c!=null && partner.PMP_Account_Dsc__c!=null)
                {
                    if(partner.PMP_Company_Information_Language_Nm__c=='English' && ( matchString(partner.Name) || matchString(partner.PMP_Account_Tag_Line__c) || matchString(partner.PMP_Account_Dsc__c)))
                    {
                        createMarketplaceDQMonitorRecord('PMP_Company__c',partner.id,'GLS Translation','Storefront Input Language Mismatch','Input lanuguage is english but either Name,Tagline or Description is not in english','DQ1');
                    }
                    if(partner.PMP_Company_Information_Language_Nm__c=='Japanese' && ( !matchString(partner.Name) || !matchString(partner.PMP_Account_Tag_Line__c) || !matchString(partner.PMP_Account_Dsc__c)))
                    {
                        createMarketplaceDQMonitorRecord('PMP_Company__c',partner.id,'GLS Translation','Storefront Input Language Mismatch','Input lanuguage is japanese but either Name,Tagline or Description is in english','DQ2');
                    }
                    if(partner.PMP_Company_Information_Language_Nm__c=='Simplified Chinese' && ( !matchString(partner.Name) || !matchString(partner.PMP_Account_Tag_Line__c) || !matchString(partner.PMP_Account_Dsc__c)))
                    {
                        createMarketplaceDQMonitorRecord('PMP_Company__c',partner.id,'GLS Translation','Storefront Input Language Mismatch','Input lanuguage is chinese but either Name,Tagline or Description is in english','DQ3');
                    }
                }
            }
            catch(Exception e)
            {
                createLogEntry(e,'PMP_Company__c',partner.id);
            }
        }  
    }
    
/*************************************************************************************************************
* Method Name : getOfferingTranslationRecords
* Description : this method is used to determine GLS Translation Offering Issue records
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
**************************************************************************************************************/    
    //public static void getOfferingTranslationRecords(List<PMP_Partner_Offering__c> offList)
    //{
        // for(PMP_Partner_Offering__c off : offList)
        // {
        //     try
        //     {
        //         if(off.PMP_Offering_Language_Nm__c!=null && off.Name!=null && off.PMP_Partner_Offering_Tag_Line_Txt__c!=null && off.PMP_Partner_Offering_Dsc__c!=null)
        //         {
        //             if(off.PMP_Offering_Language_Nm__c=='English' && ( matchString(off.Name) || matchString(off.PMP_Partner_Offering_Tag_Line_Txt__c) || matchString(off.PMP_Partner_Offering_Dsc__c)))
        //             {
        //                 createMarketplaceDQMonitorRecord('PMP_Partner_Offering__c',off.id,'GLS Translation','Offering Input Language Mismatch','Input lanuguage is english but either Name,Tagline or Description is not in english','DQ4');
        //             }
        //             if(off.PMP_Offering_Language_Nm__c=='Japanese' && ( !matchString(off.Name) || !matchString(off.PMP_Partner_Offering_Tag_Line_Txt__c) || !matchString(off.PMP_Partner_Offering_Dsc__c)))
        //             {
        //                 createMarketplaceDQMonitorRecord('PMP_Partner_Offering__c',off.id,'GLS Translation','Offering Input Language Mismatch','Input lanuguage is japanese but either Name,Tagline or Description is in english','DQ5');
        //             }
        //             if(off.PMP_Offering_Language_Nm__c=='Simplified Chinese' && ( !matchString(off.Name) || !matchString(off.PMP_Partner_Offering_Tag_Line_Txt__c) || !matchString(off.PMP_Partner_Offering_Dsc__c)))
        //             {
        //                 createMarketplaceDQMonitorRecord('PMP_Partner_Offering__c',off.id,'GLS Translation','Offering Input Language Mismatch','Input lanuguage is chinese but either Name,Tagline or Description is in english','DQ6');
        //             }
        //         }
        //     }
        //     catch(Exception e)
        //     {
        //         createLogEntry(e,'PMP_Partner_Offering__c',off.id);
        //     }        
        // }
   // }
    
/*************************************************************************************************************
* Method Name : getCoveoIssueMPIRecords
* Description : this method is used to determine Coveo Search Issue records
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
**************************************************************************************************************/    
    public static void getCoveoIssueMPIRecords(List<PMP_Company__c> partnerList){
        Map<String,List<PMP_Marketing_Profile_Attributes_Mapping__c>> partnerToPartnerAttrMaping = new Map<String,List<PMP_Marketing_Profile_Attributes_Mapping__c>>();
        
        List<PMP_Marketing_Profile_Attributes_Mapping__c> partnerAttributeMappingList = [Select Id,Name,PMP_Marketing_Profile_Id__r.Id, PMP_Marketing_Profile_Id__r.Name, PMP_Marketing_Profile_Id__r.PMP_IPA_Badge_Tier_Txt__c,
                                                                                         PMP_Partner_Segment__r.Name,PMP_Partner_Role__r.Name,PMP_Partner_Specialty__r.Name,PMP_Partner_Tier__r.Name 
                                                                                         from PMP_Marketing_Profile_Attributes_Mapping__c where PMP_Marketing_Profile_Id__c in :partnerList];
        
        for(PMP_Marketing_Profile_Attributes_Mapping__c pam : partnerAttributeMappingList)
        {
            if(!partnerToPartnerAttrMaping.containsKey(pam.PMP_Marketing_Profile_Id__c))
            {
                partnerToPartnerAttrMaping.put(pam.PMP_Marketing_Profile_Id__c, new List<PMP_Marketing_Profile_Attributes_Mapping__c>());
            }
            partnerToPartnerAttrMaping.get(pam.PMP_Marketing_Profile_Id__c).add(pam);
        }
        for(PMP_Company__c partner : partnerList){
            Boolean isSegmentIssue = false;
            Boolean isProgramIssue = false;
            Boolean isSpecalityIssue = false;
            Boolean isTierIssue = false;
            
            List<String> partnerSegmentList = new List<String>();
            List<String> partnerProgramList = new List<String>();
            List<String> partnerSpecalityList = new List<String>();
            List<String> partnerTierList = new List<String>();
            
            List<String> coveoSegmentList = new List<String>();
            List<String> coveoProgramList = new List<String>();
            List<String> coveoSpecalityList = new List<String>();
            List<String> coveoTierList = new List<String>();
            
            if(partner.PMP_Partner_Segment_Nm__c!=null)
            {
                partnerSegmentList = partner.PMP_Partner_Segment_Nm__c.split(';');
            }
            if(partner.PMP_Partner_Program_nm__c!=null)
            {
                partnerProgramList = partner.PMP_Partner_Program_nm__c.split(';');
            }
            if(partner.PMP_Account_Specialty__c!=null)
            {
                partnerSpecalityList = partner.PMP_Account_Specialty__c.split(';');
            }
            if(partner.PMP_IPA_Badge_Tier_Txt__c!=null)
            {
                partnerTierList = partner.PMP_IPA_Badge_Tier_Txt__c.split(';');
            }
            System.debug('tierList'+partnerTierList);
            try
            {
                if(partnerToPartnerAttrMaping.containsKey(partner.id))
                {
                    for(PMP_Marketing_Profile_Attributes_Mapping__c pam : partnerToPartnerAttrMaping.get(partner.id))
                    {
                        if(pam.PMP_Partner_Segment__c!=null)
                        {
                            coveoSegmentList.add(pam.PMP_Partner_Segment__r.Name);
                        }
                        if(pam.PMP_Partner_Role__c!=null)
                        {
                            coveoProgramList.add(pam.PMP_Partner_Role__r.Name);
                        }
                        if(pam.PMP_Partner_Specialty__c!=null)
                        {
                            coveoSpecalityList.add(pam.PMP_Partner_Specialty__r.Name);
                        }
                        if(pam.PMP_Partner_Tier__c!=null)
                        {
                            coveoTierList.add(pam.PMP_Partner_Tier__r.Name);
                        }
                        if(!partnerSegmentList.contains(pam.PMP_Partner_Segment__r.Name) &&  pam.PMP_Partner_Segment__c!=null)
                        {  
                            isSegmentIssue =true;
                        }
                        if(!partnerProgramList.contains(pam.PMP_Partner_Role__r.Name) &&  pam.PMP_Partner_Role__c!=null)
                        {      
                            isProgramIssue=true;
                        }
                        if(!partnerSpecalityList.contains(pam.PMP_Partner_Specialty__r.Name) &&  pam.PMP_Partner_Specialty__c!=null)
                        {  
                            isSpecalityIssue=true;
                        }
                        if(!partnerTierList.contains(pam.PMP_Partner_Tier__r.Name) &&  pam.PMP_Partner_Tier__c!=null)
                        {   
                            isTierIssue=true;
                        }
                    }
                    if(isSegmentIssue || partnerSegmentList.size()!=coveoSegmentList.size())
                    {
                        createMarketplaceDQMonitorRecord('PMP_Company__c',partner.id,'Coveo','Segment Mismatch','Segment Mismatch','DQ7');
                    }
                    if(isProgramIssue || partnerProgramList.size()!=coveoProgramList.size())
                    {
                        createMarketplaceDQMonitorRecord('PMP_Company__c',partner.id,'Coveo','Role Mismatch','Role Mismatch','DQ8');
                    }
                    if(isSpecalityIssue || partnerSpecalityList.size()!=coveoSpecalityList.size())
                    {
                        createMarketplaceDQMonitorRecord('PMP_Company__c',partner.id,'Coveo','Specialty Mismatch','Specialty Mismatch','DQ9');
                    }
                    if(isTierIssue || partnerTierList.size()!=coveoTierList.size())
                    {
                        createMarketplaceDQMonitorRecord('PMP_Company__c',partner.id,'Coveo','Tier Mismatch','Tier Mismatch','DQ10');
                    }          
                }              
            }
            catch(Exception e)
            {
                createLogEntry(e,'PMP_Company__c',partner.id);
            }
        }       
    }
    
/*************************************************************************************************************
* Method Name : getOPIDIssueMPIReccords
* Description : this method is used to determine OPID Issue records
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
**************************************************************************************************************/    
    public static void getOPIDIssueMPIReccords(List<PMP_Company__c> partnerList)
    {
        Set<Id> partnerId = new Set<Id>();
        List<String> accountIds = new List<String>();
        Set<Id> allAccountIds = new  Set<Id>();
        Map<String,List<String>> partnerAccMap= new Map<String,List<String>>();//map to store partner id with respective active opid accounts
        Map<String,List<PRM_AccountChannelMembership__c>> opidACMMap= new Map<String,List<PRM_AccountChannelMembership__c>>();
        Map<String,List<List<PRM_AccountChannelMembership__c>>> partnerACMMap= new Map<String,List<List<PRM_AccountChannelMembership__c>>>();
        Map<String,List<PRM_AccountBenefitAssociation__c>> opidABAMap= new Map<String,List<PRM_AccountBenefitAssociation__c>>();
        Map<String,List<List<PRM_AccountBenefitAssociation__c>>> partnerABAMap= new Map<String,List<List<PRM_AccountBenefitAssociation__c>>>();
        Map<String,List<String>> partnerProgramTierMap= new Map<String,List<String>>();//map to store partner id with respective program tiers
        Map<String,List<String>> partnerBenefitAssMap= new Map<String,List<String>>();//map to store partner id with respective active benefits
        
        for(PMP_Company__c partner : partnerList){
            partnerId.add(partner.Id);
        }
        List<PMP_OPID_MPI_Rel__c> junctionObjects = PMP_Utility.getJunctionAccountToMpiByCompanyId(partnerId);
        Map<Id,Set<Id>> mapOfMpiToListAccountsActive = PMP_Utility.getMapMpiToListAccountActive(junctionObjects);  
        for(PMP_Company__c partner : partnerList){
            if(mapOfMpiToListAccountsActive.containsKey(partner.Id)){
                for(Id acc : mapOfMpiToListAccountsActive.get(partner.Id)){
                    accountIds.add(acc);
                    allAccountIds.add(acc);
                }
                partnerAccMap.put(partner.Id,accountIds);
                accountIds = new List<String>();
            }
        }
        System.debug('allAccountIds--->'+allAccountIds);
        System.debug('partnerAccMap--->'+partnerAccMap);
        List<String> marketplaceBenefitList = new List<String>();
        marketplaceBenefitList.add('Solutions Marketplace Enhanced');
        marketplaceBenefitList.add('Solutions Marketplace Basic Profile');
        marketplaceBenefitList.add('Solutions Marketplace Basic Access');
        List<PRM_AccountChannelMembership__c> accChanelMembrshipList = [Select Id,PRM_Channel_Program_Level_Id__r.Name,PRM_Account_Id__c from PRM_AccountChannelMembership__c where PRM_Account_Id__c in: allAccountIds and PRM_Status_Nm__c='Approved'];
        List<PRM_AccountBenefitAssociation__c> accBenefitAssList = [Select Id,PRM_Partner_Benefit_Id__r.Name,PRM_Account_Id__c from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c in :allAccountIds and PRM_Status_Nm__c='Active' and PRM_Partner_Benefit_Id__r.Name in:marketplaceBenefitList];
        for(PRM_AccountChannelMembership__c acm :accChanelMembrshipList)
        {  
            if(!opidACMMap.containsKey(acm.PRM_Account_Id__c))
            {
                opidACMMap.put(acm.PRM_Account_Id__c, new List<PRM_AccountChannelMembership__c>());
            }
            opidACMMap.get(acm.PRM_Account_Id__c).add(acm);
        }
        System.Debug('opidACMMap--->'+opidACMMap);
        for(PRM_AccountBenefitAssociation__c aba :accBenefitAssList)
        {  
            if(!opidABAMap.containsKey(aba.PRM_Account_Id__c))
            {
                opidABAMap.put(aba.PRM_Account_Id__c, new List<PRM_AccountBenefitAssociation__c>());
            }
            opidABAMap.get(aba.PRM_Account_Id__c).add(aba);
        }
        System.Debug('opidABAMap--->'+opidABAMap);
        List<PMP_OPID_MPI_Rel__c> opidAccList = [Select Id,PMP_Marketing_Profile_Id__c,PMP_One_Partner_ID__c from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__c in: allAccountIds and Is_Active__c=true Limit 50000];
        for(PMP_OPID_MPI_Rel__c opidAcc :opidAccList)
        {
            if(!partnerACMMap.containsKey(opidAcc.PMP_Marketing_Profile_Id__c))
            {
                partnerACMMap.put(opidAcc.PMP_Marketing_Profile_Id__c,new List<List<PRM_AccountChannelMembership__c>>());
            }
            partnerACMMap.get(opidAcc.PMP_Marketing_Profile_Id__c).add(opidACMMap.get(opidAcc.PMP_One_Partner_ID__c));
            if(!partnerABAMap.containsKey(opidAcc.PMP_Marketing_Profile_Id__c))
            {
                partnerABAMap.put(opidAcc.PMP_Marketing_Profile_Id__c,new List<List<PRM_AccountBenefitAssociation__c>>());
            }
            partnerABAMap.get(opidAcc.PMP_Marketing_Profile_Id__c).add(opidABAMap.get(opidAcc.PMP_One_Partner_ID__c));
        }
        System.Debug('partnerACMMap--->'+partnerACMMap);
        System.Debug('partnerABAMap--->'+partnerABAMap);
        
        for(PMP_Company__c partner : partnerList){
            List<String> programTierList = new List<String>();
            List<String> benefitList = new List<String>();
            if(partnerACMMap.get(partner.id)!=null)
            {
                for(List<PRM_AccountChannelMembership__c> acmList : partnerACMMap.get(partner.id))
                {
                    if(acmList!=null)
                    {
                        for(PRM_AccountChannelMembership__c acmRec :acmList)
                        {
                            programTierList.add(acmRec.PRM_Channel_Program_Level_Id__r.Name);
                        }
                    }
                }
                partnerProgramTierMap.put(partner.id,programTierList);
                programTierList = new List<String>(); 
            }
            if(partnerABAMap.get(partner.id)!=null)
            {
                for(List<PRM_AccountBenefitAssociation__c> abaList : partnerABAMap.get(partner.id))
                {
                    if(abaList!=null)
                    {
                        for(PRM_AccountBenefitAssociation__c abaRec : abaList)
                        {
                            if(abaRec.PRM_Partner_Benefit_Id__r.Name=='Solutions Marketplace Basic Access')
                            {
                                abaRec.PRM_Partner_Benefit_Id__r.Name='Solution Marketplace Basic Access';
                            }
                            benefitList.add(abaRec.PRM_Partner_Benefit_Id__r.Name);
                        }
                    }
                }
                partnerBenefitAssMap.put(partner.id,benefitList);
                benefitList = new List<String>();
            }
        }
        System.Debug('partnerProgramTierMap----' + partnerProgramTierMap);
        System.Debug('partnerBenefitAssMap----' + partnerBenefitAssMap);
        
        // OPID Tier Related Issue
        getOPIDTierMismatch(partnerList,partnerProgramTierMap);
        // OPID Benefit Revoked Related Issue
        getOPIDBenefitMismatch(partnerList,partnerBenefitAssMap);
        // OPID Benefit Related Issue
        getOPIDBenefitRevokedFlagMismatch(partnerList,partnerBenefitAssMap,partnerAccMap,partnerProgramTierMap);
        // Storefront Incorrect OPID Sharing Issue
        getStorefrontOPIDSharingIssueRecords(partnerList,partnerAccMap);   
    }
    
/*************************************************************************************************************
* Method Name : getOPIDTierMismatch
* Description : this method is used to determine OPID Tier Issue MPI records
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
**************************************************************************************************************/    
    public static void getOPIDTierMismatch(List<PMP_Company__c> partnerList,Map<String,List<String>> partnerProgramTierMap)
    {
        for(PMP_Company__c partner : partnerList){
            try{
                if(partnerProgramTierMap!=null && !partnerProgramTierMap.isEmpty())
                {
                    if(partnerProgramTierMap.get(partner.id)!=null)
                    {
                        if(partnerProgramTierMap.get(partner.id).contains('Titanium') && partner.PMP_IPA_Badge_Tier_Txt__c!='Titanium')
                        {
                            createMarketplaceDQMonitorRecord('PMP_Company__c',partner.id,'OPID','Tier Mismatch','OPID Tier is Titanium but Storefront Tier is '+ partner.PMP_IPA_Badge_Tier_Txt__c,'DQ11');
                        }
                        if(!partnerProgramTierMap.get(partner.id).contains('Titanium') && partnerProgramTierMap.get(partner.id).contains('Gold') && partner.PMP_IPA_Badge_Tier_Txt__c!='Gold')
                        {
                            createMarketplaceDQMonitorRecord('PMP_Company__c',partner.id,'OPID','Tier Mismatch','OPID Tier is Gold but Storefront Tier is ' + partner.PMP_IPA_Badge_Tier_Txt__c,'DQ12');
                        }
                        if(!partnerProgramTierMap.get(partner.id).contains('Titanium') && !partnerProgramTierMap.get(partner.id).contains('Gold') 
                           && partnerProgramTierMap.get(partner.id).contains('Member') && partner.PMP_IPA_Badge_Tier_Txt__c!='Member')
                        {
                            createMarketplaceDQMonitorRecord('PMP_Company__c',partner.id,'OPID','Tier Mismatch','OPID Tier is Member but Storefront Tier is ' + partner.PMP_IPA_Badge_Tier_Txt__c,'DQ13');
                        }
                    }
                }
            }
            catch(Exception e)
            {
                createLogEntry(e,'PMP_Company__c',partner.id);
            }
        }
    }

/*************************************************************************************************************
* Method Name : getOPIDBenefitMismatch
* Description : this method is used to determine OPID Benefit Issue MPI records
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
**************************************************************************************************************/    
    public static void getOPIDBenefitMismatch(List<PMP_Company__c> partnerList,Map<String,List<String>> partnerBenefitAssMap)
    {
        for(PMP_Company__c partner : partnerList){
            try{
                if(partnerBenefitAssMap!=null && partnerBenefitAssMap.get(partner.id)!=null && !partnerBenefitAssMap.isEmpty())
                {
                    Set<String> uniqueBenefitList = new Set<String>();
                    List<String> benefitList = new List<String>();
                    for(String benefit : partnerBenefitAssMap.get(partner.id))
                    {
                        uniqueBenefitList.add(benefit);
                    }
                    for(String benefit : uniqueBenefitList)
                    {
                        benefitList.add(benefit);
                    }
                    if(uniqueBenefitList.size()>1)
                    {
                        createMarketplaceDQMonitorRecord('PMP_Company__c',partner.id,'OPID','Benefit Mismatch','Storefront has more than one Solutions Marketplace Benefits active','DQ14');
                    }
                    else if(uniqueBenefitList.size()==1)
                    {
                        if(partner.PMP_Partner_Benefit_Type__c!=benefitList[0])
                        {
                            createMarketplaceDQMonitorRecord('PMP_Company__c',partner.id,'OPID','Benefit Mismatch','Benefit Mismatch','DQ15');
                        }
                    }
                    else{}
                }
            }
            catch(Exception e)
            {
                createLogEntry(e,'PMP_Company__c',partner.id);
            }
        }
    }

/*************************************************************************************************************
* Method Name : getOPIDBenefitRevokedFlagMismatch
* Description : this method is used to determine OPID Benefit Revoked Flag Issue MPI records
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
**************************************************************************************************************/    
    public static void getOPIDBenefitRevokedFlagMismatch(List<PMP_Company__c> partnerList,Map<String,List<String>> partnerBenefitAssMap,Map<String,List<String>> partnerAccMap,Map<String,List<String>> partnerProgramTierMap)
    {
        for(PMP_Company__c partner : partnerList){
            try{
                if(partnerAccMap!=null && !partnerAccMap.isEmpty())
                {
                    if(partnerAccMap.get(partner.id)!=null && (partnerProgramTierMap.get(partner.id).isEmpty() && partner.PMP_IPA_Badge_Tier_Txt__c!= null && partner.PMP_IPA_Badge_Tier_Txt__c!=''))
                    {
                        createMarketplaceDQMonitorRecord('PMP_Company__c',partner.id,'OPID','Tier Mismatch','OPID doesnot have active tier but Storefront has ' + partner.PMP_IPA_Badge_Tier_Txt__c +' tier','DQ16');
                    }
                    if(partnerAccMap.get(partner.id)!=null && partnerProgramTierMap.get(partner.id).isEmpty() && !partnerBenefitAssMap.get(partner.id).isEmpty())
                    {
                        createMarketplaceDQMonitorRecord('PMP_Company__c',partner.id,'OPID','Benefit Mismatch','OPID doesnot have active tier but OPID have active benefit','DQ17');
                    }
                    if(partnerAccMap.get(partner.id)!=null && partnerBenefitAssMap.get(partner.id).isEmpty() && partner.PMP_Benefit_Update_Ind__c==false)
                    {
                        createMarketplaceDQMonitorRecord('PMP_Company__c',partner.id,'OPID','Benefit Revoked Flag Mismatch','OPID doesnot have active benefit but Storefront is active','DQ18');
                    }
                    if((partnerAccMap.get(partner.id)!=null || !partnerBenefitAssMap.get(partner.id).isEmpty()) && partner.PMP_Benefit_Update_Ind__c==true)
                    {
                        createMarketplaceDQMonitorRecord('PMP_Company__c',partner.id,'OPID','Benefit Revoked Flag Mismatch','OPID has active benefit but Storefront is inactive','DQ19');
                    }
                    if(partner.PMP_Benefit_Update_Ind__c==false && (partnerAccMap.get(partner.id)==null || partnerAccMap.get(partner.id).isEmpty()))
                    {
                        createMarketplaceDQMonitorRecord('PMP_Company__c',partner.id,'OPID','Benefit Revoked Flag Mismatch','Storefront is active but not associated to any OPID','DQ20');
                    }
                }
                else
                {
                    if(partner.PMP_Benefit_Update_Ind__c==false)
                    {
                        createMarketplaceDQMonitorRecord('PMP_Company__c',partner.id,'OPID','Benefit Revoked Flag Mismatch','Storefront is active but not associated to any OPID','DQ20');
                    }
                }
            }
            catch(Exception e)
            {
                createLogEntry(e,'PMP_Company__c',partner.id);
            }
        }
    }
    
/*************************************************************************************************************
* Method Name : getStorefrontOPIDSharingIssueRecords
* Description : this method is used to determine Incorrect OPID Sharing Issue MPI records
* Version     : 1.0 
* Created Date: 04/11/2022  
* Modification Log :
**************************************************************************************************************/    
    public static void getStorefrontOPIDSharingIssueRecords(List<PMP_Company__c> partnerList,Map<String,List<String>> partnerAccMap)
    {
        Map<String,List<String>> partnerOPIDShareMap = new Map<String,List<String>>();//map to store partner id with respective partner sharing usergroup
        List<PMP_Company__Share> pcShareList = [Select Id,UserOrGroup.Name,ParentId from PMP_Company__Share where ParentId in : partnerList and UserOrGroup.Name like '%001%'];
        for(PMP_Company__Share pcShare : pcShareList)
        {
            if(!partnerOPIDShareMap.containsKey(pcShare.ParentId))
            {
                partnerOPIDShareMap.put(pcShare.ParentId, new List<String>());
            }
            List<String> userGroupName = pcShare.UserOrGroup.Name.split('_');
            partnerOPIDShareMap.get(pcShare.ParentId).add(userGroupName[1]);
            userGroupName= new List<String>();
        }
        System.debug('partnerOPIDShareMap-->'+partnerOPIDShareMap);
    }
    
/*************************************************************************************************************
* Method Name : getOfferingOPIDSharingIssueRecords
* Description : this method is used to determine Incorrect OPID Sharing Issue Offering records
* Version     : 1.0 
* Created Date: 04/11/2022 
* Modification Log :
**************************************************************************************************************/        
    // public static void getOfferingOPIDSharingIssueRecords(List<PMP_Partner_Offering__c> offList)
    // {
        
    // }
/*************************************************************************************************************
* Method Name : getStorefrontImageIssueRecords
* Description : this method is used to determine Image Issue MPI records
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
**************************************************************************************************************/    
    public static void getStorefrontImageIssueRecords(List<PMP_Company__c> partnerList)
    {
        List<String> resourceType = new  List<String>();
        Set<Id> contentDocIds = new Set<Id>();
        List<PMP_Company_Resource__c> pcResList = new List<PMP_Company_Resource__c>();
        List<ContentAsset> contentAssetList = new List<ContentAsset>();
        Map<Id,Id> documentIdContentAssetMap = new Map<Id,Id>();
        Set<Id> partnerIds = new Set<Id>();
        resourceType.add('Image');
        resourceType.add('Thumbnail Image');
        List<String> status = new  List<String>();
        status.add('Published');
        for(PMP_Company__c pc : partnerList)
        {
            partnerIds.add(pc.Id);
        }
        pcResList = [Select Id,Name,PMP_Company_Resource_Type_Nm__c,PMP_Company_Image__c,PMP_Company_Id__c,PMP_Company_Id__r.PMP_Company_Lifecycle_Status_Nm__c from PMP_Company_Resource__c 
                     where PMP_Company_Resource_Type_Nm__c in:resourceType and PMP_Company_Id__c in :partnerIds 
                     and PMP_Company_Id__r.PMP_Company_Lifecycle_Status_Nm__c in :status];
        if(pcResList.size()>0)
        {
            for(PMP_Company_Resource__c pcs : pcResList)
            {
                if(pcs.PMP_Company_Image__c!=null && pcs.PMP_Company_Image__c!='')
                {
                    contentDocIds.add(pcs.PMP_Company_Image__c);
                }            
            }
        }
        contentAssetList = [Select Id,ContentDocumentId from ContentAsset where ContentDocumentId in :contentDocIds];
        if(contentAssetList.size()>0)
        {
            for(ContentAsset ca : contentAssetList)
            {
                documentIdContentAssetMap.put(ca.ContentDocumentId,ca.Id);
            }
        }
        System.debug('documentIdContentAssetMap-->'+documentIdContentAssetMap);
        if(pcResList.size()>0)
        {       
            for(PMP_Company_Resource__c pcs : pcResList)
            {
                try
                {
                    if(pcs.PMP_Company_Image__c==null || pcs.PMP_Company_Image__c=='')
                    {
                        createMarketplaceDQMonitorRecord('PMP_Company__c',pcs.PMP_Company_Id__c,'Image Missing','Storefront Image','Storefront Logo is Missing','DQ21');
                    }
                    else
                    {
                        if(!documentIdContentAssetMap.containsKey(pcs.PMP_Company_Image__c))
                        {
                            createMarketplaceDQMonitorRecord('PMP_Company__c',pcs.PMP_Company_Id__c,'Image Missing','Storefront Image','Storefront Logo is Missing','DQ21');
                        }
                    }
                }
                
                catch(Exception e)
                {
                    createLogEntry(e,'PMP_Company__c',pcs.PMP_Company_Id__c);
                }
            }
        }  
    }

/*************************************************************************************************************
* Method Name : getOfferingImageIssueRecords
* Description : this method is used to determine Image Issue Offering records
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
**************************************************************************************************************/    
   // public static void getOfferingImageIssueRecords(List<PMP_Partner_Offering__c> offList)
    //{
        // List<String> resourceType = new  List<String>();
        // Set<Id> contentDocIds = new Set<Id>();
        // List<ContentAsset> contentAssetList = new List<ContentAsset>();
        // Map<Id,Id> documentIdContentAssetMap = new Map<Id,Id>();
        // List<PMP_Partner_Offering_Resource__c> offResList = new List<PMP_Partner_Offering_Resource__c>();
        // Set<Id> offIds = new Set<Id>();
        // resourceType.add('Image');
        // resourceType.add('Thumbnail Image');
        // List<String> status = new  List<String>();
        // status.add('Published');
        // for(PMP_Partner_Offering__c off : offList)
        // {
        //     offIds.add(off.Id);
        // }
        // offResList = [Select Id,Name,PMP_Offering_Id__c,PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Partner_Offering_Image__c,PMP_Resource_Type_Nm__c from PMP_Partner_Offering_Resource__c 
        //                                             where PMP_Resource_Type_Nm__c in:resourceType and PMP_Offering_Id__c in :offIds 
        //                                             and PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c in :status];
        // if(offResList.size()>0)
        // {
        //     for(PMP_Partner_Offering_Resource__c pcs : offResList)
        //     {
        //         if(pcs.PMP_Partner_Offering_Image__c!=null && pcs.PMP_Partner_Offering_Image__c!='')
        //         {
        //             contentDocIds.add(pcs.PMP_Partner_Offering_Image__c);
        //         }            
        //     }
        // }
        // contentAssetList = [Select Id,ContentDocumentId from ContentAsset where ContentDocumentId in :contentDocIds];
        // if(contentAssetList.size()>0)
        // {
        //     for(ContentAsset ca : contentAssetList)
        //     {
        //         documentIdContentAssetMap.put(ca.ContentDocumentId,ca.Id);
        //     }
        // }
        // System.debug('documentIdContentAssetMap-->'+documentIdContentAssetMap);
        // if(offResList.size()>0)
        // {
        //     for(PMP_Partner_Offering_Resource__c pcs : offResList)
        //     {
        //         try
        //         {
        //             if(pcs.PMP_Partner_Offering_Image__c==null || pcs.PMP_Partner_Offering_Image__c=='')
        //             {
        //                 createMarketplaceDQMonitorRecord('PMP_Partner_Offering__c',pcs.PMP_Offering_Id__c,'Image Missing','Offering Image','Offering Logo is Missing','DQ22'); 
        //             }
        //             else
        //             {
        //                 if(!documentIdContentAssetMap.containsKey(pcs.PMP_Partner_Offering_Image__c))
        //                 {
        //                     createMarketplaceDQMonitorRecord('PMP_Partner_Offering__c',pcs.PMP_Offering_Id__c,'Image Missing','Offering Image','Offering Logo is Missing','DQ22'); 
        //                 }
        //             }
        //         }                     
        //         catch(Exception e)
        //         {
        //             createLogEntry(e,'PMP_Partner_Offering__c',pcs.PMP_Offering_Id__c);
        //         }
        //     }
        // }          
   // }
/*************************************************************************************************************
* Method Name : getSolutionIssueRecords
* Description : this method is used to fetch QuestionResult Issue records
* Version     : 1.0 
* Created Date: 08/11/2022 
* Modification Log :
**************************************************************************************************************/    
//IPA2.0: US-TWC729-7976    
/*public static void getSolutionIssueRecords(List<ArdiraSurvey__Survey_Result__c> solutionList){
        Map<Id,ArdiraSurvey__Question_Result__c> solQstnResMap = new Map<Id,ArdiraSurvey__Question_Result__c>();
        Set<Id> solIds = new Set<Id>();
        String solNotMatchingWithOff='Solution Name is not matching with Offering Name';
        String solNotMatchingWithOffAndQR='Solution Name is not matching with Offering Name And Question Result';
        String solNotMatchingWithQR='Solution Name is not matching with Question Result';      
        
        system.debug('solutionList---'+solutionList);
        for(ArdiraSurvey__Survey_Result__c solutionRec:solutionList){
            solIds.add(solutionRec.Id);
        }
            
       for(ArdiraSurvey__Question_Result__c qstnRes:[Select Id,ArdiraSurvey__Answer_Text__c, ArdiraSurvey__Survey_Result__c, ArdiraSurvey__Question_Text__c 
                                                          from ArdiraSurvey__Question_Result__c 
                                                          where ArdiraSurvey__Survey_Result__c IN :solIds 
                                                          and ArdiraSurvey__Question_Text__c LIKE '%Enter the solution or service name.%']){
       		
            if(qstnRes!=null){
                system.debug('qstnRes---'+qstnRes);
       			solQstnResMap.put(qstnRes.ArdiraSurvey__Survey_Result__c,qstnRes);
            }
       }
        for(ArdiraSurvey__Survey_Result__c sol:solutionList){
            system.debug('sol---'+sol);
            try{
                String dqMsgString = '';
                if(sol!=null && sol.PSS_Partner_Offering__c!=null && sol.PSS_Proposal_Name_Txt__c != sol.PSS_Partner_Offering__r.Name){
                    dqMsgString = solNotMatchingWithOff;
                    system.debug('solQstnResMap at 689---'+' ' + solQstnResMap.get(sol.Id).ArdiraSurvey__Answer_Text__c);
                    if(sol!=null && solQstnResMap.containsKey(sol.Id) && sol.PSS_Proposal_Name_Txt__c!= solQstnResMap.get(sol.Id).ArdiraSurvey__Answer_Text__c){
                        dqMsgString = dqMsgString + solNotMatchingWithOffAndQR;
                    }
                        
                }else{
                    if(sol.PSS_Proposal_Name_Txt__c != solQstnResMap.get(sol.Id).ArdiraSurvey__Answer_Text__c){
                        dqMsgString = solNotMatchingWithQR;
                    }  
                }
                system.debug('dqMsgString----'+dqMsgString);
                if(!String.isEmpty(dqMsgString))
                {
                    createMarketplaceDQMonitorRecord('ArdiraSurvey__Survey_Result__c',sol.Id,'Solution Name Mismatch','Solution Name',dqMsgString,'DQ24'); 
                   
                }
        	}catch(Exception e){
            	createLogEntry(e,'ArdiraSurvey__Survey_Result__c',sol.Id);
        	}
        }
              
    }*/
    
/*************************************************************************************************************
* Method Name : createLogEntry
* Description : this method is used to create log entry records
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
**************************************************************************************************************/    
    public static void createLogEntry(Exception e, String sObjectType, String recordId ){
        Core_Log_Entry__c logEntry = new Core_Log_Entry__c();
        logEntry.Core_Details__c=e.getMessage();
        logEntry.Core_sObjectType__c= sObjectType;
        logEntry.Core_Origin__c='PMP_GenerateDQReportUtility';
        logEntry.Core_Severity__c='Low';
        logEntry.Core_When__c= system.today();
        logEntry.Core_Project__c = 'Marketplace';
        logEntry.Core_sObjectId__c=recordId;
        if(logEntry!=null)
        {
            Database.insert(logEntry);
        }     
    }
    
/*************************************************************************************************************
* Method Name : createMarketplaceDQMonitorRecord
* Description : this method is used to upsert Marketplace DQ Monitor recordd
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
**************************************************************************************************************/    
    public static void createMarketplaceDQMonitorRecord(String sObjectType, String recordId , String issueType, String issueSubType, String issueDescription, String IssueNo){
        List<PMP_Marketplace_DQ_Monitor__c> dqRecList = new List<PMP_Marketplace_DQ_Monitor__c>();
        List<PMP_Marketplace_DQ_Monitor__c> currDQRec = new List<PMP_Marketplace_DQ_Monitor__c>();
        PMP_Marketplace_DQ_Monitor__c dqRec = new PMP_Marketplace_DQ_Monitor__c(); 
        if(sObjectType=='PMP_Company__c')
        {
            dqRec.PMP_Marketing_Profile_Id__c = recordId;
        }
        // else if(sObjectType=='PMP_Partner_Offering__c')
        // {
        //     dqRec.PMP_Offering_Id__c = recordId;
        // } 
        else{
            system.debug('Inside DQ Sol DQ---'+recordId);
            //dqRec.PMP_Partner_Solution_Id__c = recordId;//IPA2.0: US-TWC729-7976
        }         
        dqRec.PMP_Issue_Dsc_Txt__c = issueDescription;
        dqRec.PMP_Issue_Type_Nm__c = issueType;
        dqRec.PMP_External_Key__c= issueType.replaceAll(' ', '_') + '_' + issueSubType.replaceAll(' ', '_')  + '_' + recordId + '_' + IssueNo;
        dqRec.PMP_Issue_Sub_Type_Nm__c=issueSubType;
        system.debug('dqRec---'+dqRec);
        currDQRec = [SELECT Id,PMP_Status_Nm__c from PMP_Marketplace_DQ_Monitor__c where PMP_External_Key__c=:dqRec.PMP_External_Key__c Limit 1];
        if(currDQRec.size()>0)
        {
            if(currDQRec[0].PMP_Status_Nm__c=='Closed' || currDQRec[0].PMP_Status_Nm__c=='ReOpened')
            {
                dqRec.PMP_Status_Nm__c = 'ReOpened';
            }
            else
            {
                dqRec.PMP_Status_Nm__c = 'Open';
            }
        }
        else
        {
            dqRec.PMP_Status_Nm__c = 'Open';
        }
        dqRecList.add(dqRec);
        if(dqRecList.size()>0)
        {
            Schema.SObjectField upsertExternalKey = PMP_Marketplace_DQ_Monitor__c.Fields.PMP_External_Key__c;
            Database.upsert(dqRecList,upsertExternalKey,false);
        }       
    }
    
/*************************************************************************************************************
* Method Name : sendDQReportEmail
* Description : this method is used to send email when DQ Report is generated
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
**************************************************************************************************************/    
    public static void sendDQReportEmail(){
        getDQReportLink();
        EmailTemplate  template = PMP_Utility.getEmailTemplate('PMP_SendDQReportTemplate');
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        //Get public group members
        Group grp=[SELECT Id FROM Group where DeveloperName='PMP_DQReportGroup' LIMIT 1];
        List<GroupMember> groupMembers=[SELECT UserOrGroupId FROM GroupMember where GroupId=:grp.Id];
        Set<Id> userIds=new Set<Id>();
        for (GroupMember groupMember: groupMembers){
            userIds.add(groupMember.UserOrGroupId);
        }
       List<User> userList=[SELECT Id, Name FROM User where Id in :userIds and IsActive=true];    
       for(User u : userList)
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            mail.setTemplateId(template.id);
            mail.setSaveAsActivity(false);
            mail.setTargetObjectId(u.id);
            emailList.add(mail);
        }
        
        if(!emailList.isEmpty()){
            Messaging.sendEmail(emailList);
        }	   
    } 
    
/*************************************************************************************************************
* Method Name : getDQReportLink
* Description : this method is used to fetch DQ Dashboard Link
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
**************************************************************************************************************/    
    public static void getDQReportLink(){
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        dashboardLink = baseUrl + '/lightning/n/DQ_Dashboard';
    }
    
    
}