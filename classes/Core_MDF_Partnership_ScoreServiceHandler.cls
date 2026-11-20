public without sharing class Core_MDF_Partnership_ScoreServiceHandler {
    
    //static varaibles for sharing Partnership Score
    //public static List<Id> listOfAccIds = new List<Id>();
    public static void populateAndValidateFields(List<Core_MDF_Partnership_Score__c> psNewList) {
        try{
            Map<Id,string> programIdToLabelMap = new Map<Id,string>();
            for(Core_MDF_ChannelProgram__mdt channelProgram : [Select Id, Core_MDF_Technical_Program_Name__c,Core_MDF_Program_ID__c FROM Core_MDF_ChannelProgram__mdt LIMIT 1000]){
                programIdToLabelMap.put(channelProgram.Core_MDF_Program_ID__c, channelProgram.Core_MDF_Technical_Program_Name__c);
            }
            
            for(Core_MDF_Partnership_Score__c partnerScore: psNewList){
                if(partnerScore.Core_MDF_Account_Id__c != null && partnerScore.Core_MDF_Channel_Program_Id__c != null &&
                   string.isNotBlank(partnerScore.Core_MDF_Quarter_Year_Nm__c) && !programIdToLabelMap.isEmpty()){
                       partnerScore.Core_MDF_External_Id__c = string.valueOf(partnerScore.Core_MDF_Channel_Program_Id__c)+string.valueOf(partnerScore.Core_MDF_Virtual_Corp_Account_Id__c)+partnerScore.Core_MDF_Quarter_Year_Nm__c;
                       partnerScore.Core_MDF_Quarter_nm__c = partnerScore.Core_MDF_Quarter_Year_Nm__c.split(' ')[0];
                       partnerScore.Core_MDF_Year_nm__c = partnerScore.Core_MDF_Quarter_Year_Nm__c.split(' ')[1];
                       partnerScore.Core_MDF_Program_nm__c = programIdToLabelMap.get(String.valueOf(partnerScore.Core_MDF_Channel_Program_Id__c).substring(0, 15));
                   }
                
            }
        }
        catch(Exception e){ 
          //System.debug('generate ExternalId Error '+e.getMessage()+' '+e.getLineNumber());
            Core_MDF_CCP_UtilityClass.logError(e); 
        }
    }
    
    public static void populateExternalId(List<Core_MDF_Partnership_Score__c> Records) {
        try{
            List<Core_MDF_Partnership_Score__c> abc = new List<Core_MDF_Partnership_Score__c>();
            Map<id,string> RecToExternalId = new Map<id,String>();
            for(Core_MDF_Partnership_Score__c psc: Records){
                string programid =psc.Core_MDF_Channel_Program_Id__c;
                psc.Core_MDF_External_Id__c = programid+psc.Core_MDF_Virtual_Corp_Account_Id__c+psc.Core_MDF_Year_nm__c+' '+psc.Core_MDF_Quarter_nm__c;
                RecToExternalId.put(psc.id,psc.Core_MDF_External_Id__c);
            }
        }
        catch(Exception e){ 
            //System.debug('Duplicate erraor at 12 '+e.getMessage());
            
        }
    }
    
    public static void populatecarryForwardAmt(List<Core_MDF_Partnership_Score__c> Records) {
        Map<String, id> pScore = new Map<String, id> ();
        Map<String, decimal> pScore2 = new Map<String, decimal> ();
        List<string> qtr = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
        String qtrforCarryfwdAmt = qtr[2];
        String qtrforprevQtr = qtr[1];
        try{
            for(Core_MDF_Partnership_Score__c psdrec:[Select Id, Core_MDF_Virtual_Corp_Account_Id__c, Core_MDF_Program_Nm__c,Core_MDF_Channel_Program_Id__c,Core_MDF_Account_Id__c,Core_MDF_External_Id__c,Core_MDF_Balance_Amount_Amt__c  FROM Core_MDF_Partnership_Score__c Where Core_MDF_Quarter_Year_Nm__c =: qtrforCarryfwdAmt ]) {
                string ExtIdKey = String.valueOf(psdrec.Core_MDF_Channel_Program_Id__c)+String.valueOf(psdrec.Core_MDF_Virtual_Corp_Account_Id__c);
                pScore.put(ExtIdKey,psdrec.id);
                
            }
            for (Core_MDF_Partnership_Score__c  psdrecarry: Records)
            {
                String newExtId =String.valueOf(psdrecarry.Core_MDF_Channel_Program_Id__c)+String.valueOf(psdrecarry.Core_MDF_Virtual_Corp_Account_Id__c);
                psdrecarry.Core_MDF_Partnership_Score_Id__c =pScore.get(newExtId);
            }
            
        }
        catch(Exception e){ 
            //System.debug('Exception Occured '+e.getMessage());
            
        }
    }
    
    public static void claimProcessesOnBeforeUpdate(List<Core_MDF_Partnership_Score__c> newClaimList, List<Core_MDF_Partnership_Score__c> oldClaimList, Map<Id,Core_MDF_Partnership_Score__c> oldClaimMap,Map<Id,Core_MDF_Partnership_Score__c> newClaimMap){
        //key check isActive
        //Id batchInstanceId = Database.executeBatch(new Core_MDF_PartnerShipScoreToDetail(pfcListToBeUpdated,'UpdateCases',caseOwnerIdList),Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Case_Process_Batch_Size')));
        
    }
 /*****************************************************************************************************
Method Name:        shareRecordtoPGMgroups
@return  :          void
@parameters:        List of Partnership score record
Description:        This method to perform External PGM Based Sharing for a Partnership score record
Added By:           Accenture-MR
Date :                25-Feb-2022
Modified By:        Date:       Changes:
*****************************************************************************************************/
    public static void shareRecordtoPGMgroups (List <Core_MDF_Partnership_Score__c> newPartnerScoreList) {
        Set<String> setOfChannelPrgm = new Set<String>();
        List<Id> listOfAccIds = new List<Id>();
        try{
            for (Core_MDF_Partnership_Score__c partnerScoreObj : newPartnerScoreList)
            {
                listOfAccIds.add(partnerScoreObj.Core_MDF_Account_Id__c);
                setOfChannelPrgm.add(partnerScoreObj.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c); 
            }
            
            Map<String,Id> accIdProgIdToPgmGrpMap =new Map<String,Id>();
            List<Core_MDF_Partnership_Score__Share> listOfPartnerScoreShareRecords=new List<Core_MDF_Partnership_Score__Share>();
            
            for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT ID,Core_MDF_Account__c,Core_MDF_Region_cd__c,Core_MDF_Sub_Region_cd__c,Core_MDF_Type_of_Access__c,Core_MDF_Channel_Program__c,Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c,Core_MDF_Group_Id__c FROM Core_MDF_Partner_Group_Mapping__c 
                                                         WHERE Core_MDF_Account__c IN :listOfAccIds AND Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c IN :setOfChannelPrgm AND Core_MDF_Inactive_Ind__c = false AND Core_MDF_Type_of_Access__c = 'External'])
            {
                String key = String.valueOf(pgm.Core_MDF_Account__c) + String.valueOf(pgm.Core_MDF_Channel_Program__c);
                accIdProgIdToPgmGrpMap.put(key,pgm.Core_MDF_Group_Id__c);
            }
            
            //Iterate through new potential records
            if(!accIdProgIdToPgmGrpMap.isEmpty())
            {
                for (Core_MDF_Partnership_Score__c partnerScore : newPartnerScoreList)
                {    
                    //Unique Key
                    String accIdPrgmIdKey = String.valueOf(partnerScore.Core_MDF_Account_Id__c) + String.valueOf(partnerScore.Core_MDF_Channel_Program_Id__c);
                    if(accIdProgIdToPgmGrpMap.containskey(accIdPrgmIdKey))
                    {
                        Core_MDF_Partnership_Score__Share partnerShare  = new Core_MDF_Partnership_Score__Share();
                        partnerShare.ParentId = partnerScore.Id;
                        partnerShare.UserOrGroupId = accIdProgIdToPgmGrpMap.get(accIdPrgmIdKey);
                        partnerShare.AccessLevel = 'Edit';
                        partnerShare.RowCause = Schema.Core_MDF_Partnership_Score__Share.RowCause.Manual;
                        listOfPartnerScoreShareRecords.add(partnerShare);  
                        
                    }
                }
                if(listOfPartnerScoreShareRecords.size()>0 && listOfPartnerScoreShareRecords !=null)
                {   
                    Database.insert(listOfPartnerScoreShareRecords);
                }
            }      
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}
        
    }
    
    /*****************************************************************************************************
Method Name:        shareRecordToGeoGroup
@return  :          void
@parameters:        List of Partnership score record
Description:        This method to perform account and program Based Sharing for a Partnership score record
Added By:           Accenture-MR
Date :                25-Feb-2022
Modified By:        Date:       Changes:
*****************************************************************************************************/
    public static void shareRecordToGeoGroup(List<Core_MDF_Partnership_Score__c> newPartnerScoreList) {
        //To share record on the basis of Channel Program and geo
        List<Core_MDF_RecordGeoShare> recordGeoShareList = new List<Core_MDF_RecordGeoShare>();
        List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
        Set<Id> setOfNodeBasedAccounts = new Set<Id>();
        Set<Id> setOfNodeBasedPrograms = new Set<Id>();
        //Map of account id and account
        Map<Id, Account> accountIdToAccountMap = new Map<Id, Account>();
        Map<Id, String> mapOfScrIdToAccPgmId = new Map<Id, String>();
        try{
            for(Core_MDF_Partnership_Score__c partnerScore :newPartnerScoreList) {
                // Preparing final Map of partnerScore Id as key and Intel Account Id and Program Id as value
                if(Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd(partnerScore.Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c)){
                    setOfNodeBasedAccounts.add(partnerScore.Core_MDF_Account_Id__c);
                    setOfNodeBasedPrograms.add(partnerScore.Core_MDF_Channel_Program_Id__c);
                    mapOfScrIdToAccPgmId.put(partnerScore.Id, String.valueOf(partnerScore.Core_MDF_Account_Id__c) + String.valueOf(partnerScore.Core_MDF_Channel_Program_Id__c));
                }
                recordGeoShareList.add(new Core_MDF_RecordGeoShare(partnerScore.id, partnerScore.Core_MDF_Account_Id__r.Core_Geo__c, partnerScore.Core_MDF_Account_Id__r.Core_Sub_Geo__c, partnerScore.Core_MDF_Channel_Program_Id__r.Name));
                recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(partnerScore.id, partnerScore.Core_MDF_Account_Id__r.Core_Geo__c, partnerScore.Core_MDF_Account_Id__r.Core_Sub_Geo__c, partnerScore.Core_MDF_Channel_Program_Id__r.Name,partnerScore.Core_MDF_Account_Id__c));
            }
        
            //To share record on the basis of Channel Program and geo
            if(recordGeoShareList != null && recordGeoShareList.size() > 0) {
                Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('Core_MDF_Partnership_Score__c', recordGeoShareList);
            }
            if(recordPGMShareList != null && recordPGMShareList.size() >0){
                Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('Core_MDF_Partnership_Score__c', recordPGMShareList);
            }
            //To share Partnership Score records with its account group            
            if(mapOfScrIdToAccPgmId!=Null && !mapOfScrIdToAccPgmId.isEmpty()){
                Core_MDF_shareRecordToAccountGroup.shareRecordToAllAcctGroupInHierarchy(mapOfScrIdToAccPgmId, 'Core_MDF_Partnership_Score__c', new List<Id>(setOfNodeBasedAccounts), new List<Id>(setOfNodeBasedPrograms));
            } 
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}
        
    }
     /*****************************************************************************************************
Method Name:        updatePartnershipScoreShareFlag
@return  :          void
@parameters:        List of Partnership score record
Description:        This method to set IsRecordSharedFlag to true after sharing partnership score record
Added By:           Accenture-MR
Date :              24-May-2022
Modified By:        Date:       Changes:
*****************************************************************************************************/
public static void updatePartnershipScoreShareFlag(List<Core_MDF_Partnership_Score__c> newPartnerScoreList){
    try{
        for(Core_MDF_Partnership_Score__c partnerScore:newPartnerScoreList)
        {
            partnerScore.Core_MDF_IsRecordShared_ind__c=true;
        }
        update newPartnerScoreList;
    }
    catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}
}
/*****************************************************************************************************
Method Name:        partnershipscoreSharingMainMethod
@return  :          void
@parameters:        List of Partnership score record
Description:        This method used to share partnership score records. This method cannot be used for if there are large number of records are inserted/updated
                    Maximum number of recods can be 30(Based on number of program specific groups for IPA).
Added By:           Accenture-MR
Date :              24-May-2022
Modified By:        Date:       Changes:
*****************************************************************************************************/
public static void partnershipscoreSharingMainMethod(List<Core_MDF_Partnership_Score__c> newPartnerScoreList){
    try{
        Set<Id> parternshipScoreIdSet = new Set<Id>();
        for(Core_MDF_Partnership_Score__c newPS : newPartnerScoreList){
            parternshipScoreIdSet.add(newPS.Id);
        }
        List<Core_MDF_Partnership_Score__c> newPartnerScoreData=[Select Core_MDF_Account_Id__c,Core_MDF_Account_Id__r.Core_Geo__c,Core_MDF_Account_Id__r.Core_Sub_Geo__c,Core_MDF_Channel_Program_Id__c,Core_MDF_Channel_Program_Id__r.Name,Core_MDF_Channel_Program_Id__r.Core_MDF_Technical_Program_Name__c from Core_MDF_Partnership_Score__c where Id IN :parternshipScoreIdSet];
        if(!newPartnerScoreData.isEmpty())
        {
        shareRecordtoPGMgroups(newPartnerScoreData);
        shareRecordToGeoGroup(newPartnerScoreData);
        updatePartnershipScoreShareFlag(newPartnerScoreData);
        }
    }
    catch(Exception e){}
    
}
    /*****************************************************************************************************
Method Name:        validatePartnerScoreforUpdate
@return  :          void
@parameters:        List of Partnership score record
Description:        This method to validate create/update of partnership score record based on the fiscal quarter.
Added By:           Accenture-MR
Date :              15-Mar-2022
Modified By:        Date:       Changes:
*****************************************************************************************************/
    public static void validatePartnerScoreforUpdate (List <Core_MDF_Partnership_Score__c> psObjs, Map<Id,Core_MDF_Partnership_Score__c> psOldObjs) {
        for(Core_MDF_Partnership_Score__c pScore : psObjs){
            
            if(pScore.Core_MDF_Quarter_nm__c == null || pScore.Core_MDF_Year_nm__c == null){
                pScore.addError(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Partner_Score_Field_Validation'));
            }
        }
    }
    /*****************************************************************************************************
Method Name:        resharePartnershipScoreRecords
@return  :          void
@parameters:        map of trigger.new and trigger.old values
Description:        This method to share partnership score record after owner update
Added By:           Accenture-MR
Date :              24-May-2022
Modified By:        Date:       Changes:
*****************************************************************************************************/
    Public static void resharePartnershipScoreRecords(Map<Id, Core_MDF_Partnership_Score__c> oldPartnershipscore, Map<Id, Core_MDF_Partnership_Score__c> newPartnershipscore){
        List<Core_MDF_Partnership_Score__c> partnershipScoreOwnerUpdatedList =new List<Core_MDF_Partnership_Score__c>();
        Integer PartnershipSharingSyncBatchSize=Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PartnershipSharingSyncBatchSize'));
        Integer PartnershipShareASyncBatchSize=Integer.valueOf(Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_PartnershipShareASyncBatchSize'));
        try{
            for(Id partnershipScoreId:oldPartnershipscore.keySet()){
                //Owner Update check
                if(oldPartnershipscore.get(partnershipScoreId).OwnerId != newPartnershipscore.get(partnershipScoreId).OwnerId){
                    
                    partnershipScoreOwnerUpdatedList.add(newPartnershipscore.get(partnershipScoreId));
                    
                }
            }
            //if Owner update list is not empty do the sharing
            if(!partnershipScoreOwnerUpdatedList.isEmpty()){
                if(partnershipScoreOwnerUpdatedList.size()>PartnershipSharingSyncBatchSize){ 
                    Core_MDF_Batch_Partnership_Score_Sharing batchInstance=new Core_MDF_Batch_Partnership_Score_Sharing((List<Core_MDF_Partnership_Score__c>) partnershipScoreOwnerUpdatedList);
                    Id batchId = Database.executeBatch(batchInstance,PartnershipShareASyncBatchSize);
                }else
                {
                    Core_MDF_Partnership_ScoreServiceHandler.partnershipscoreSharingMainMethod((List<Core_MDF_Partnership_Score__c>) partnershipScoreOwnerUpdatedList);
                }
                
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}
        
    }
    /*****************************************************************************************************
Method Name:        resetIsRecordSharedFlagAfterOwnerUpdate
@return  :          void
@parameters:        map of trigger.new and trigger.old values
Description:        This method to set IsRecordShared flag to false so the record will be picked by batch class for sharing
Added By:           Accenture-MR
Date :              24-May-2022
Modified By:        Date:       Changes:
*****************************************************************************************************/
    
    Public static void resetIsRecordSharedFlagAfterOwnerUpdate(Map<Id, Core_MDF_Partnership_Score__c> oldPartnershipscore, Map<Id, Core_MDF_Partnership_Score__c> newPartnershipscore){
        try{
            for(Core_MDF_Partnership_Score__c pscList : newPartnershipscore.values())
            {
                //Checking if owner is changed
                if(oldPartnershipscore.get(pscList.Id).OwnerId != pscList.OwnerId){
                    pscList.Core_MDF_IsRecordShared_ind__c=false;
                }
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);throw e;}
    }
    
    /*****************************************************************************************************                              
    Method Name   :        populateZonePercentage                                
    @return       :        void                          
    @parameters   :        List<Core_MDF_Partnership_Score__c> psNewList, Map<Id,Core_MDF_Partnership_Score__c> psOldMap
    Description   :        To Populate Zone Percentage fields on Parternship Score records
    Added By      :        JB - Accenture - 11/10/2023
    Modified By   :        Date:           Changes:                                 
    JB - Accenture         11/10/2023      To Populate Zone Percentage fields on Parternship Score records
    ******************************************************************************************************/
    public static void populateZonePercentage(List<Core_MDF_Partnership_Score__c> psNewList, Map<Id,Core_MDF_Partnership_Score__c> psOldMap) {
        List<Core_MDF_Partnership_Score__c> psList = new List<Core_MDF_Partnership_Score__c>();
        Set<String> zoneSet = new Set<String>();
        Set<String> quarterSet = new Set<String>();
        Set<String> zoneAndQuarterKeySet = new Set<String>();

        for(Core_MDF_Partnership_Score__c ps : psNewList){
            if((psOldMap == null && String.isNotBlank(ps.Core_MDF_Zone_nm__c)) || (psOldMap != null && (ps.Core_MDF_Zone_nm__c != psOldMap.get(ps.Id).Core_MDF_Zone_nm__c))){
                psList.add(ps);
                if(String.isNotBlank(ps.Core_MDF_Zone_nm__c)){
                    zoneSet.add(ps.Core_MDF_Zone_nm__c);
                    quarterSet.add(ps.Core_MDF_Quarter_Year_Nm__c);
                    zoneAndQuarterKeySet.add(ps.Core_MDF_Zone_nm__c + ps.Core_MDF_Quarter_Year_Nm__c);
                }
            }
        }

        Map<String,Core_MDF_PartnerResponseZone__c> zoneAndQuarterKeyToPartnerResponseZoneMap = new Map<String,Core_MDF_PartnerResponseZone__c>();

        List<String> quarterYearList = Core_MDF_RecoveryClaimReportViewCtrl.getQuarterOptionsMap();
        String startQuarterYear = quarterYearList[quarterYearList.size()-1]; //Starting Quarter
        String endQuarterYear = quarterYearList[0]; // Current Quarter
        String quarterandYearList = getQuartersByStartAndEndRange(startQuarterYear, endQuarterYear);
        for(Core_MDF_PartnerResponseZone__c prz : [SELECT Id, Core_MDF_Zone_Nm__c, Core_MDF_ZV_Percent_Recovery__c, Core_MDF_PV1_Percent_Recovery__c, core_MDF_PV2_Percent_Recovery__c, Core_MDF_PV4_Percent_Recovery__c, Core_MDF_Effective_Start_Quarter_txt__c, Core_MDF_Effective_End_Quarter_txt__c  FROM Core_MDF_PartnerResponseZone__c WHERE Core_MDF_Zone_Nm__c IN: zoneSet]){
            String przStartQuarter = quarterYearList.contains(prz.Core_MDF_Effective_Start_Quarter_txt__c) ? prz.Core_MDF_Effective_Start_Quarter_txt__c : startQuarterYear;
            String przEndQuarter = quarterYearList.contains(prz.Core_MDF_Effective_End_Quarter_txt__c) ? prz.Core_MDF_Effective_End_Quarter_txt__c : endQuarterYear;
            String extractedString = (przStartQuarter == przEndQuarter) ? przStartQuarter : quarterandYearList.substringBetween(przStartQuarter, przEndQuarter);
            Set<String> finalQuarterSet = new Set<String>();
            finalQuarterSet.add(przStartQuarter);
            if(String.isNotBlank(extractedString)){
                finalQuarterSet.addAll(extractedString.split(','));
            }
            finalQuarterSet.add(przEndQuarter);

            for(String finalQuarter : finalQuarterSet){
                String zoneAndQuarterKey = prz.Core_MDF_Zone_Nm__c + finalQuarter;
                if(zoneAndQuarterKeySet.contains(zoneAndQuarterKey)){
                    zoneAndQuarterKeyToPartnerResponseZoneMap.put(prz.Core_MDF_Zone_Nm__c + finalQuarter, prz);
                }
            }
        }

        for(Core_MDF_Partnership_Score__c ps : psList){
            
            //Populate Percentage fields based on Zone
            String key = ps.Core_MDF_Zone_nm__c + ps.Core_MDF_Quarter_Year_Nm__c;
            if(zoneAndQuarterKeyToPartnerResponseZoneMap.containsKey(key)){
                ps.Core_MDF_PV1_Percentage_nbr__c = zoneAndQuarterKeyToPartnerResponseZoneMap.get(key).Core_MDF_PV1_Percent_Recovery__c;
                ps.Core_MDF_PV2_Percentage_nbr__c = zoneAndQuarterKeyToPartnerResponseZoneMap.get(key).Core_MDF_PV2_Percent_Recovery__c;
                
            }else{
                ps.Core_MDF_PV1_Percentage_nbr__c = null;
                ps.Core_MDF_PV2_Percentage_nbr__c = null;
            }
        }
    }

    /*****************************************************************************************************                              
    Method Name   :        getQuartersByStartAndEndRange                                
    @return       :        List<String>                          
    @parameters   :        String startQuarterYear, String endQuarterYear
    Description   :        Get all the Quarter and Year between a Start and End Quarter and Year
    Added By      :        JB - Accenture - 11/10/2023
    Modified By   :        Date:           Changes:                                 
    JB - Accenture         11/10/2023      Get all the Quarter and Year between a Start and End Quarter and Year
    ******************************************************************************************************/
    public static String getQuartersByStartAndEndRange(String startQuarterYear, String endQuarterYear) {

        Integer startQuarter = Integer.valueOf(startQuarterYear.split(' ')[0].replace('Q', ''));
        Integer startYear = Integer.valueOf(startQuarterYear.split(' ')[1]);

        Integer endQuarter = Integer.valueOf(endQuarterYear.split(' ')[0].replace('Q', ''));
        Integer endYear = Integer.valueOf(endQuarterYear.split(' ')[1]);

        String quarterYear = '';
        String currQuarterandYear = '';

        Integer currentQuarter = startQuarter;
        Integer currentYear = startYear;

        Boolean hasValidRange = false;
        
        if(startYear <= endYear || (startYear == endYear && startQuarter <= endQuarter)){
            hasValidRange = true;
        }

        while(hasValidRange) { /*!(currentYear == endYear && currentQuarter > endQuarter)*/
            quarterYear += 'Q' + currentQuarter + ' ' + currentYear + ',';
            currQuarterandYear = 'Q' + currentQuarter + ' ' + currentYear;

            if(currQuarterandYear == endQuarterYear){
                hasValidRange = false; // Make as false if reaches the end Quarter and Year
            }

            currentQuarter++;
            if(currentQuarter > 4) {
                currentQuarter = 1;
                currentYear++;
            }
        }

        return quarterYear;
    }
}