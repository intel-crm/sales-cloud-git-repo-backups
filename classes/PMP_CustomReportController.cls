public class PMP_CustomReportController {
    
    public static Boolean matchString(String inputText)
    {
        String regex = '[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff\uff66-\uff9f]';
        Pattern regexPattern = Pattern.compile(regex);
        Matcher regexMatcher = regexPattern.matcher(inputText);
        return regexMatcher.find();
    }
    
    public static List<PMP_Partner_Offering__c> getOfferingTranslationRecords()
    {
        List<PMP_Partner_Offering__c> offList = [Select Id,PMP_Offering_Language_Nm__c,Name,PMP_Partner_Offering_Tag_Line_Txt__c,PMP_Partner_Offering_Dsc__c from PMP_Partner_Offering__c
                                                 where PMP_Partner_Offering_Lifecycle_Status_Nm__c ='Admin Review'];
        
        List<PMP_Partner_Offering__c> offTransList = new List<PMP_Partner_Offering__c>();
        if(offList!=null)
        {
            for(PMP_Partner_Offering__c off : offList)
            {
                if(off.PMP_Offering_Language_Nm__c!=null && off.Name!=null && off.PMP_Partner_Offering_Tag_Line_Txt__c!=null && off.PMP_Partner_Offering_Dsc__c!=null)
                {
                    if(off.PMP_Offering_Language_Nm__c=='English' && ( matchString(off.Name) || matchString(off.PMP_Partner_Offering_Tag_Line_Txt__c) || matchString(off.PMP_Partner_Offering_Dsc__c)))
                    {
                        offTransList.add(off);
                    }
                    if(off.PMP_Offering_Language_Nm__c=='Japanese' && ( !matchString(off.Name) || !matchString(off.PMP_Partner_Offering_Tag_Line_Txt__c) || !matchString(off.PMP_Partner_Offering_Dsc__c)))
                    {
                        offTransList.add(off);
                    }
                    if(off.PMP_Offering_Language_Nm__c=='Simplified Chinese' && ( !matchString(off.Name) || !matchString(off.PMP_Partner_Offering_Tag_Line_Txt__c) || !matchString(off.PMP_Partner_Offering_Dsc__c)))
                    {
                        offTransList.add(off);
                    }
                }
            }
        }
        
        for(PMP_Partner_Offering__c off : offTransList)
        {
            System.debug('offTransList--->'+offTransList);
        }
        
        return offTransList;
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
   @AuraEnabled
   // OPID Issue Method
    public static List<PMP_Company__c> getCompanyRecords(String searchKey, String sortBy, String sortDirection, String year)
    {
        List<String> partnerIds = new List<String>();
        partnerIds.add('a5S8A000000HPZQUA4');
         partnerIds.add('a5S8A000000CoNGUA0');
      
        //partnerIds.add('a5S2i000000ArIoEAK');
        List<PMP_Company__c> partnerList = [ Select Id,Name,PMP_IPA_Badge_Tier_Txt__c,PMP_Partner_Benefit_Type__c,PMP_Benefit_Update_Ind__c from PMP_Company__c where PMP_Company_Lifecycle_Status_Nm__c ='Published' and id in:partnerIds  order by createdDate desc Limit 5000 ]; 
        List<PMP_Company__c> pList = new List<PMP_Company__c>();
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
        
        Map<String,List<String>> partnerOPIDShareMap = new Map<String,List<String>>();//map to store partner id with respective partner sharing usergroup
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
        for(PMP_Company__c partner : partnerList){
             // OPID Tier Related Issue
            if(partnerProgramTierMap!=null && !partnerProgramTierMap.isEmpty())
            {
                if(partnerProgramTierMap.get(partner.id)!=null)
                {
                    if(partnerProgramTierMap.get(partner.id).contains('Titanium') && partner.PMP_IPA_Badge_Tier_Txt__c!='Titanium')
                    {
                        System.debug('Entry1');
                        pList.add(partner);
                    }
                    if(!partnerProgramTierMap.get(partner.id).contains('Titanium') && partnerProgramTierMap.get(partner.id).contains('Gold') && partner.PMP_IPA_Badge_Tier_Txt__c!='Gold')
                    {
                        System.debug('Entry2');
                        pList.add(partner);
                    }
                    if(!partnerProgramTierMap.get(partner.id).contains('Titanium') && !partnerProgramTierMap.get(partner.id).contains('Gold') 
                       && partnerProgramTierMap.get(partner.id).contains('Member') && partner.PMP_IPA_Badge_Tier_Txt__c!='Member')
                    {
                        System.debug('Entry3');
                        pList.add(partner);
                    }
                }
            }
  
            // OPID Benefit Revoked Related Issue
            if(partnerAccMap!=null && !partnerAccMap.isEmpty())
            {
                if(partnerAccMap.get(partner.id)!=null && (partnerProgramTierMap.get(partner.id).isEmpty() && partner.PMP_IPA_Badge_Tier_Txt__c!= null && partner.PMP_IPA_Badge_Tier_Txt__c!=''))
                {
                    system.debug('1');
                     pList.add(partner);
                }
                if(partnerAccMap.get(partner.id)!=null && partnerProgramTierMap.get(partner.id).isEmpty() && !partnerBenefitAssMap.get(partner.id).isEmpty())
                {
                    system.debug('2');
                     pList.add(partner);
                }
                if(partnerAccMap.get(partner.id)!=null && partnerBenefitAssMap.get(partner.id).isEmpty() && partner.PMP_Benefit_Update_Ind__c==false)
                {
                    system.debug('3');
                     pList.add(partner);
                }
                if(partnerAccMap.get(partner.id)!=null && partner.PMP_Benefit_Update_Ind__c==true)
                {
                    system.debug('4');
                     pList.add(partner);
                }
                if(partner.PMP_Benefit_Update_Ind__c==false && (partnerAccMap.get(partner.id)==null || partnerAccMap.get(partner.id).isEmpty()))
                {
                    system.debug('5');
                     pList.add(partner);
                }
            }
            else
            {
                if(partner.PMP_Benefit_Update_Ind__c==false)
                {
                    system.debug('6');
                    pList.add(partner);
                }
            }
            
            // OPID Benefit Related Issue
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
                    system.debug('6');
                     pList.add(partner);
                }
                else if(uniqueBenefitList.size()==1)
                {
                    if(partner.PMP_Partner_Benefit_Type__c!=benefitList[0])
                    {
                        system.debug('7');
                        pList.add(partner);
                    }
                }
                else
                {
                    
                }
            }
            
        }
        for(PMP_Company__c pc : pList)
        {
            partnerIds.add(pc.Id);
            System.debug('pc record--->'+pc);
        }
        System.debug('pList size--->'+pList.size());
        Integer selectedYear = Integer.valueOf(year);
        String query = 'Select Id,Name,CreatedDate,PMP_IPA_Badge_Tier_Txt__c,PMP_Partner_Benefit_Type__c,PMP_Partner_Program_nm__c,PMP_Partner_Segment_Nm__c,LastModifiedDate from PMP_Company__c';
        if ( searchKey != null && searchKey != '' ) {
            String key = '%' + searchKey + '%';
            query += ' and Name LIKE :key';
        }
        if ( sortBy != null && sortDirection != null ) {
            query += ' ORDER BY ' + sortBy + ' ' + sortDirection;
        }
        query = query + ' LIMIT 50000';
        return Database.query( query );
    }
    
    @AuraEnabled
    public static Map < String, Decimal > getMPIByGroup(String selectedGroup) {
        String query = 'Select Count(Id) partnerCount,'+ selectedGroup +' groupValue from PMP_Company__c GROUP BY '+ selectedGroup;
        List < AggregateResult > result = Database.query( query );
        Map < String, Decimal > wrapp = new Map < String, Decimal > ();

        for (AggregateResult ar: result) {
            wrapp.put(String.valueOf(ar.get('groupValue')), (Decimal) ar.get('partnerCount'));

        }
        return wrapp;
    }
    
    /*************************************************************************************************************
* Method Name : getStorefrontImageIssueRecords
* Description : this method is used to determine Image Issue MPI records
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
**************************************************************************************************************/    
    public static void getStorefrontImageIssueRecords()
    {
        Set<Id> pList = new Set<Id>();
        List<String> resourceType = new  List<String>();
    
        Set<Id> partnerIds = new Set<Id>();
        partnerIds.add('a5S8A000000HPZQUA4');
        resourceType.add('Image');
        resourceType.add('Thumbnail Image');
        List<String> status = new  List<String>();
        status.add('Published');
  
        List<PMP_Company_Resource__c> pcResList = [Select Id,Name,PMP_Company_Resource_Type_Nm__c,PMP_Company_Image__c,PMP_Company_Id__c,PMP_Company_Id__r.PMP_Company_Lifecycle_Status_Nm__c from PMP_Company_Resource__c 
                                                   where PMP_Company_Resource_Type_Nm__c in:resourceType and PMP_Company_Id__c in :partnerIds 
                                                   and PMP_Company_Id__r.PMP_Company_Lifecycle_Status_Nm__c in :status];
        if(pcResList!=null)
        {       
            for(PMP_Company_Resource__c psRes : pcResList)
            {
                try
                {    
                    if(psRes.PMP_Company_Image__c==null || psRes.PMP_Company_Image__c=='')
                    {
                        pList.add(psRes.PMP_Company_Id__c);
                    }
                }
                catch(Exception e)
                {
                    
                }
            }
        }
        for(Id pc : pList)
        {
            System.debug('pc record--->'+pc);
        }
    }

/*************************************************************************************************************
* Method Name : getOfferingImageIssueRecords
* Description : this method is used to determine Image Issue Offering records
* Version     : 1.0 
* Created Date: 22/08/2022 
* Modification Log :
**************************************************************************************************************/    
    public static void getOfferingImageIssueRecords()
    {
        // List<String> resourceType = new  List<String>();
        // Set<Id> offIds = new Set<Id>();
        // Set<Id> offList = new Set<Id>();
        // offIds.add('a5b8A000000V7WxQAK');
        // resourceType.add('Image');
        // resourceType.add('Thumbnail Image');
        // List<String> status = new  List<String>();
        // status.add('Published');
      
        // List<PMP_Partner_Offering_Resource__c> offResList = [Select Id,Name,PMP_Offering_Id__c,PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c,PMP_Partner_Offering_Image__c,PMP_Resource_Type_Nm__c from PMP_Partner_Offering_Resource__c 
        //                                             where PMP_Resource_Type_Nm__c in:resourceType and PMP_Offering_Id__c in :offIds 
        //                                             and PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c in :status];
        // if(offResList!=null)
        // {       
        //     for(PMP_Partner_Offering_Resource__c offRes : offResList)
        //     {
        //         try
        //         {    
        //             if(offRes.PMP_Partner_Offering_Image__c==null || offRes.PMP_Partner_Offering_Image__c=='')
        //             {
        //                 offList.add(offRes.PMP_Offering_Id__c);
        //             }
        //         }
        //         catch(Exception e)
        //         {
                    
        //         }
        //     }
        // }
        
        // for(Id pc : offList)
        // {
        //     System.debug('pc record--->'+pc);
        // }
        
    }
    
    public static void getOPIDAccountBenefitIssueRecords(){
        List<String> accTypeList = new List<String>();
        accTypeList.add('Intel Account');
        accTypeList.add('Partner Account Group');
        List<Account> accList = [Select Id,Name from Account where RecordType.Name in :accTypeList];
        List<Account> aList = new List<Account>();
        Set<Id> accountIds = new  Set<Id>();
        Map<String,List<PRM_AccountBenefitAssociation__c>> opidABAMap= new Map<String,List<PRM_AccountBenefitAssociation__c>>();
        Map<String,List<Boolean>> opidMPIRelActive= new Map<String,List<Boolean>>();
        for(Account acc : accList){
            accountIds.add(acc.Id);
        }     
        List<PRM_AccountBenefitAssociation__c> accBenefitAssList = new List<PRM_AccountBenefitAssociation__c>();
        List<String> marketplaceBenefitList = new List<String>();
        marketplaceBenefitList.add('Solutions Marketplace Enhanced');
        marketplaceBenefitList.add('Solutions Marketplace Basic Profile');
        marketplaceBenefitList.add('Solutions Marketplace Basic Access');
        
        accBenefitAssList = [Select Id,PRM_Partner_Benefit_Id__r.Name,PRM_Account_Id__c from PRM_AccountBenefitAssociation__c where PRM_Account_Id__c in :accountIds and PRM_Status_Nm__c='Active' and PRM_Partner_Benefit_Id__r.Name in:marketplaceBenefitList];
        for(PRM_AccountBenefitAssociation__c aba :accBenefitAssList)
        {  
            if(!opidABAMap.containsKey(aba.PRM_Account_Id__c))
            {
                opidABAMap.put(aba.PRM_Account_Id__c, new List<PRM_AccountBenefitAssociation__c>());
            }
            opidABAMap.get(aba.PRM_Account_Id__c).add(aba);
        }
        List<PMP_OPID_MPI_Rel__c> opidMPIRelList = [Select Id,PMP_Marketing_Profile_Id__c,PMP_One_Partner_ID__c,Is_Active__c from PMP_OPID_MPI_Rel__c where PMP_One_Partner_ID__c in: accountIds];
        for(PMP_OPID_MPI_Rel__c opiMPIRel : opidMPIRelList)
        {
            if(!opidMPIRelActive.containsKey(opiMPIRel.PMP_One_Partner_ID__c))
            {
                opidMPIRelActive.put(opiMPIRel.PMP_One_Partner_ID__c,new List<Boolean>());
            }
            opidMPIRelActive.get(opiMPIRel.PMP_One_Partner_ID__c).add(opiMPIRel.Is_Active__c);
        }
        for(Account acc : accList)
        {
            if((opidABAMap.get(acc.Id)==null || opidABAMap.get(acc.Id).isEmpty()))
            {
                if(opidMPIRelActive.get(acc.Id)!=null)
                {
                    if(opidMPIRelActive.get(acc.Id).contains(true))
                    {
                        //aList.add(acc);
                    }
                }            
            }
            else
            {
                if(opidMPIRelActive.get(acc.Id)!=null)
                {
                    if(!opidMPIRelActive.get(acc.Id).contains(true))
                    {
                        aList.add(acc);
                    }
                }
            }
        }
        for(Account pc : aList)
        {
            System.debug('pc record--->'+pc);
        }
    }
}