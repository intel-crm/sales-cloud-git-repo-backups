/****************************************************************************************************************************************
* Class Name            : Core_MDF_Payment_Sharing 
* Version               : 1.0 
* Created Date          : 04-02-2019
* Modification Log      : 
* Developer            Date             Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - AT     01-30-2019    
*****************************************************************************************************************************************/
public without sharing class Core_MDF_Payment_Sharing {
    // To hold Company 
    private static set<ID> companySet = new set<ID>();
    //To hold channel program
    private static set<ID> programSet = new set<ID>();
    //To hold account node
    private static set<ID> accountNodeIdSet = new set<ID>();
    //to hold unique claims
    private static Map<String,PartnerFundClaim> mapOfUniqueClaims = new Map<String,PartnerFundClaim>();
    //To hold Region
    private static set<String> regionSet = new set<String>();

    /***************************************************************************************************** 
Method Name:        generateMapForUniqueClaims
@return  :          void
@parameters:        paymentWrapperMap - Payment wrapper.
Description:        This method user to genetrate unique claims for sharing process
@Added By:          Accenture - AD - 04/01/2019
Modified By:        Date:       Changes: 
******************************************************************************************************/    
    public static void generateMapForUniqueClaims(Map<String, Core_MDF_PaymentWrapper> paymentWrapperMap){
        //To hold ultimate account,program and bank as unique key
        String uniqueKeyForPayments;
        for(Core_MDF_PaymentWrapper paymentWrapper : paymentWrapperMap.values())
        {            
            if(paymentWrapper.claimsToBeProcessed !=null){
                //Get the list of Claim account Nodes for the given payment Id
                for (PartnerFundClaim pfc : paymentWrapper.claimsToBeProcessed){
                    //For sharing to internal groups
                    companySet.add(pfc.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c);
                    programSet.add(pfc.ChannelPartner.Core_MDF_Channel_Program__c);
                    regionSet.add(pfc.Core_MDF_Region_Cd__c);
                    
                    //For sharing to external user
                    accountNodeIdSet.add(pfc.ChannelPartnerId);
                    //Payment Id
                    // There can be more than 1 Payment with this key, one payment for each month with this key, hence key needs to be changed for payment sharing.
                    //uniqueKeyForPayments = pfc.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+'-'+pfc.ChannelPartnerId+'-'+pfc.ChannelPartner.Core_MDF_Channel_Program__c+'-'+pfc.Core_MDF_Bank__c;
                    // With combination of Payment Id and channel Partner we will get all the Internal/External users to share this Payment with.
                    uniqueKeyForPayments = pfc.Core_MDF_Payment_id__c+'-'+pfc.ChannelPartnerId;
                    if(!mapOfUniqueClaims.containsKey(uniqueKeyForPayments)){
                        mapOfUniqueClaims.put(uniqueKeyForPayments,pfc);
                    }
                }
            }
            
        }
        system.debug('mapOfUniqueClaims - '+mapOfUniqueClaims);
    }
    /****************************************************************************************************************************************
* Method Name  : sharePaymentRecordsToPartner
* Version     : 1.0 
* Created Date: 30-01-2019
* Modification Log :
* Developer            Date                 Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Intel - Amal Thomas       30/01/2019           Created for sharing the Payment record when created.
*****************************************************************************************************************************************/
    public static void sharePaymentRecordsToPartner( Map<String, Core_MDF_PaymentWrapper> paymentWrapperMap){
        //Store the final list of Payment Id and the users to which the record needs to be shared
        Map<id, List<id>> paymentUserShareList = new Map<Id, List<Id>>();
        //Map of account and list of users
        Map<Id,List<Id>> mapOfAccountUsers = new Map<Id,List<Id>>();
        
        //to genetrate map for unique claims
        generateMapForUniqueClaims(paymentWrapperMap);
        
        for(Core_MDF_Partner_Node_User_Mapping__c pnumRec: [SELECT Id, Core_MDF_Account__c, Core_MDF_User__c 
                                                            FROM Core_MDF_Partner_Node_User_Mapping__c 
                                                            WHERE Core_MDF_User__r.IsActive = true
                                                            AND Core_MDF_Account__c IN : accountNodeIdSet ]){
                                                                
                                                                if(mapOfAccountUsers.containsKey(pnumRec.Core_MDF_Account__c)){
                                                                    mapOfAccountUsers.get(pnumRec.Core_MDF_Account__c).add(pnumRec.Core_MDF_User__c);
                                                                }else {
                                                                    mapOfAccountUsers.put(pnumRec.Core_MDF_Account__c, new List<Id>{pnumRec.Core_MDF_User__c});
                                                                }
                                                            }
        System.debug('mapOfUniqueClaims:::'+mapOfUniqueClaims);
        for(PartnerFundClaim pfcRecord : mapOfUniqueClaims.values()){
            //Payment Id
            Id paymentId = pfcRecord.Core_MDF_Payment_id__c;
            //List of user ids corresponding to account
            List<Id> userIds = mapOfAccountUsers.get(pfcRecord.ChannelPartnerId);
            // Cloned list to copy the users and put this in paymentUserShareList,using userIds is overwriting value for mapOfAccountUsers map
            List<Id> clonedUserList = new List<Id>();
            if(userIds!=null && userIds.size()>0){
                for(Id userId : userIds){
                    clonedUserList.add(userId);
                }
            }
            if(paymentId!=null && clonedUserList!=null && clonedUserList.size()>0){
                if(paymentUserShareList.containsKey(paymentId)){
                    paymentUserShareList.get(paymentId).addAll(clonedUserList);
                }else{
                    paymentUserShareList.put(paymentId, clonedUserList);
                } 
            }
        }
        if(paymentUserShareList!=null && paymentUserShareList.size() > 0){
            //Call the generic sharing method to share the list of payments and corresponding list of users
            
            Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Payment__c',paymentUserShareList, 'Edit');
            Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
        }
    }
    
    /***************************************************************************************************** 
Method Name:        sharePaymentRecordsToInternalUsers
@return  :          void
@parameters:        paymentWrapperMap - Payment wrapper.
Description:        This method user to share payments to respective groups
@Added By:          Accenture - AD - 03/27/2019
Modified By:        Date:       Changes: 
******************************************************************************************************/    
    public static void sharePaymentRecordsToInternalUsers(Map<String, Core_MDF_PaymentWrapper> paymentWrapperMap){
        //key=accId+program+Geo, value=List<PaymentId>
        Map<String,List<Id>> accountIdProgramIdGeoPaymentIdListMap = new Map<String,List<Id>>();

        //key=accId+ProgramId+Geo+SubGeo, value=List<PaymentId>
        Map<String,List<Id>> accountIdProgramIdGeoSubGeoPaymentIdListMap = new Map<String,List<Id>>();

        //for WW -> key=accId+ProgramId, value=List<PaymentId>
        Map<String,List<Id>> accountIdProgramIdPaymentIdListMap = new Map<String,List<Id>>();
        
        
        //To share record on the basis of Channel Program and geo 
        List<Core_MDF_RecordGeoShare> recordGeoShareList= new List<Core_MDF_RecordGeoShare>();
        
        //to genetrate map for unique claims
        generateMapForUniqueClaims(paymentWrapperMap);
        System.debug('mapOfUniqueClaims :::'+mapOfUniqueClaims);
        for(PartnerFundClaim pfcRecord : mapOfUniqueClaims.values()){
            //To share record on the basis of Channel Program and geo 
            recordGeoShareList.add(new Core_MDF_RecordGeoShare(pfcRecord.Core_MDF_Payment_Id__c,pfcRecord.Core_MDF_Region_Cd__c,pfcRecord.Core_MDF_Sub_Region_Cd__c,pfcRecord.Core_MDF_Program__c));
            //Payment Id
            Id paymentId = pfcRecord.Core_MDF_Payment_Id__c;
            //String to store Account, program and Region
            String accountIdProgramIdGeo = (String)pfcRecord.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c+ (String)pfcRecord.ChannelPartner.Core_MDF_Channel_Program__c +pfcRecord.Core_MDF_Region_Cd__c;
            //String to store Account, program, Region and Sub Region
            String accountIdProgramIdGeoSubGeo = (String)pfcRecord.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c + (String)pfcRecord.ChannelPartner.Core_MDF_Channel_Program__c +pfcRecord.Core_MDF_Region_Cd__c+pfcRecord.Core_MDF_Sub_Region_Cd__c;
            //string to store Account and Program
            String accountIdProgramId = (String)pfcRecord.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c +(String)pfcRecord.ChannelPartner.Core_MDF_Channel_Program__c; 
            //Only Geo
            if(accountIdProgramIdGeoPaymentIdListMap.containsKey(accountIdProgramIdGeo)){
                accountIdProgramIdGeoPaymentIdListMap.get(accountIdProgramIdGeo).add(paymentId);
            }
            else{
                accountIdProgramIdGeoPaymentIdListMap.put(accountIdProgramIdGeo, new List<Id>{paymentId});
            }
            
            //Only Geo & Sub Geo
            if(accountIdProgramIdGeoSubGeoPaymentIdListMap.containsKey(accountIdProgramIdGeoSubGeo)){
                accountIdProgramIdGeoSubGeoPaymentIdListMap.get(accountIdProgramIdGeoSubGeo).add(paymentId);
            }
            else{
                accountIdProgramIdGeoSubGeoPaymentIdListMap.put(accountIdProgramIdGeoSubGeo, new List<Id>{paymentId});
            }
            //FOR WW
            if(accountIdProgramIdPaymentIdListMap.containsKey(accountIdProgramId)){
                accountIdProgramIdPaymentIdListMap.get(accountIdProgramId).add(paymentId);
            }
            else{
                accountIdProgramIdPaymentIdListMap.put(accountIdProgramId, new List<Id>{paymentId});
            }
        }
            
            //To share record on the basis of Channel Program and geo 
            if(recordGeoShareList != null && recordGeoShareList.size() >0){
                Core_MDF_ShareRecordToGeoGroup.ShareRecordToGeoGroup('Core_MDF_Payment__c',recordGeoShareList);
            }
            
            // Passing the Parameters to the Generic Share Record Class method 
            // to share the Payment to the respective Group
            if((accountIdProgramIdGeoSubGeoPaymentIdListMap.size()>0) ||(accountIdProgramIdGeoPaymentIdListMap.size()>0) ||accountIdProgramIdPaymentIdListMap.size()>0){
                Core_MDF_CCP_GenericUtility.createShareRecordsForInternal('Core_MDF_Payment__c',companySet, programSet, regionSet, 
                                                                      accountIdProgramIdGeoSubGeoPaymentIdListMap, accountIdProgramIdGeoPaymentIdListMap, 
                                                                      accountIdProgramIdPaymentIdListMap);
            }
    } 
}