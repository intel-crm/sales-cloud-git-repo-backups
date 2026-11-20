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
    //private static set<ID> companySet = new set<ID>();
    //To hold channel program
    //private static set<ID> programSet = new set<ID>();
    //To hold account node
    private static set<ID> accountNodeIdSet = new set<ID>();
    //to hold unique claims
    private static Map<String,PartnerFundClaim> mapOfUniqueClaims = new Map<String,PartnerFundClaim>();
    //To hold Region
    //private static set<String> regionSet = new set<String>();

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
        List<String> mdfBudgetTypes = Core_MDF_Configuration__c.getValues('BUDGET_TYPE_CLAIM_BANK_HIDE').Core_MDF_Value__c.split(',');
        List<String> ccfdcfprograms = Core_MDF_Configuration__c.getValues('Programs_For_MDF_PaymentRun').Core_MDF_Value__c.split(',');
        for(Core_MDF_PaymentWrapper paymentWrapper : paymentWrapperMap.values())
        {            
            if(paymentWrapper.claimsToBeProcessed !=null){
                //Get the list of Claim account Nodes for the given payment Id
                for (PartnerFundClaim pfc : paymentWrapper.claimsToBeProcessed){
                    //For sharing to internal groups
                    //companySet.add(pfc.Request.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c);
                    //programSet.add(pfc.ChannelPartner.Core_MDF_Channel_Program__c);
                    //regionSet.add(pfc.Core_MDF_Region_Cd__c);
                    
                    //For sharing to external user
                    accountNodeIdSet.add(pfc.ChannelPartnerId);
                    //Added for TWC3117-11781 defect fix, uniqueKeyForPayment for MDF/MDF+ -> it should payment+acc+Geo
                    if((mdfBudgetTypes.contains(pfc.Core_MDF_Budget_Type_Options_Nm__c)) && ccfdcfprograms.contains(pfc.Core_MDF_Program__c)){
                        uniqueKeyForPayments = pfc.Core_MDF_Payment_id__c+'-'+pfc.ChannelPartnerId+'-'+pfc.Core_MDF_Region_Cd__c;
                        if(!mapOfUniqueClaims.containsKey(uniqueKeyForPayments)){
                            mapOfUniqueClaims.put(uniqueKeyForPayments,pfc);
                        }
                    }
                    else{
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
            
        }
    }
   
    /***************************************************************************************************** 
Method Name:        sharePaymentRecordsToPartner
@return  :          void
@parameters:        paymentWrapperMap - Payment wrapper.
Description:        This method user to share payment records to external users
@Added By:          Accenture - NK - 01-03-2022
Modified By:        Date:       Changes: 
******************************************************************************************************/    
    public static List<SObject> sharePaymentRecordsToPartner( Map<String, Core_MDF_PaymentWrapper> paymentWrapperMap){
        //Store the final list of Payment Id and the users to which the record needs to be shared
        Map<id, List<id>> paymentGroupShareList = new Map<Id, List<Id>>();
        //Map of account and list of users
        Map<Id,Id> accIdToExtGrpIdMap = new Map<Id,Id>();
        List<SObject> partnerShareRecordList = new List<SObject>();
        
        //to genetrate map for unique claims
        generateMapForUniqueClaims(paymentWrapperMap);
        
        for(Account acc : [SELECT id,Core_MDF_External_Group_Id__c FROM Account WHERE id IN : accountNodeIdSet AND Core_MDF_External_Group_Id__c != null])
        {
            accIdToExtGrpIdMap.put(acc.id, acc.Core_MDF_External_Group_Id__c);
        }
        
        for(PartnerFundClaim pfcRecord : mapOfUniqueClaims.values()){
            //Payment Id
            Id paymentId = pfcRecord.Core_MDF_Payment_id__c;
            List<Id> gpIdList = new List<Id>();
            gpIdList.add(accIdToExtGrpIdMap.get(pfcRecord.ChannelPartnerId));
            if(paymentId!=null && gpIdList!=null && gpIdList.size()>0){
                if(paymentGroupShareList.containsKey(paymentId)){
                    paymentGroupShareList.get(paymentId).add(accIdToExtGrpIdMap.get(pfcRecord.ChannelPartnerId));
                }else{ 
			paymentGroupShareList.put(paymentId,gpIdList);
                } 
            }
        }
            
       if(paymentGroupShareList!=null && paymentGroupShareList.size() > 0){
               if(Core_MDF_Utility.byPassFeature('Bypass_PaymentsBulkAPISharing')){
                  Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Payment__c',paymentGroupShareList, 'Edit');
                  partnerShareRecordList = Core_MDF_GenericShareRecordActionClass.createShareRecordListforBatch(rmsInst);
                }
               else {
                 Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Payment__c',paymentGroupShareList, 'Edit');
                 Core_MDF_GenericShareRecordActionClass.createShareRecordList(rmsInst);
               }
       }
       return partnerShareRecordList;
}  
/***************************************************************************************************** 
Method Name:        sharePaymentRecordsToInternalUsers
@return  :          void
@parameters:        paymentWrapperMap - Payment wrapper.
Description:        This method user to share payments to respective groups
@Added By:          Accenture - AD - 03/27/2019
Modified By:        Date:       Changes: 
******************************************************************************************************/    
    public static void sharePaymentRecordsToInternalUsers(Map<String, Core_MDF_PaymentWrapper> paymentWrapperMap, String context){
               
        //To share record on the basis of Channel Program and geo 
        List<Core_MDF_RecordGeoShare> recordGeoShareList= new List<Core_MDF_RecordGeoShare>();
        List<Core_MDF_RecordPGMShareWrapper> recordPGMShareList= new List<Core_MDF_RecordPGMShareWrapper>();
        
        //map of payment id and its account id with which it needs to be shared-VD
        Map<Id,List<Id>> paymentIdGroupIdListMap = new Map<Id,List<Id>>();
        
        //to genetrate map for unique claims
        generateMapForUniqueClaims(paymentWrapperMap);
       
        for(PartnerFundClaim pfcRecord : mapOfUniqueClaims.values()){
            //To share record on the basis of Channel Program and geo 
            if(pfcRecord.Core_MDF_Program__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_IPA_Program_Name') || (pfcRecord.Core_MDF_Program__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Co_GTM_program_name') && pfcRecord.Core_MDF_Region_Cd__c != null))
            {
                recordGeoShareList.add(new Core_MDF_RecordGeoShare(pfcRecord.Core_MDF_Payment_Id__c,pfcRecord.Core_MDF_Region_Cd__c,pfcRecord.Core_MDF_Sub_Region_Cd__c,pfcRecord.Core_MDF_Program__c, pfcRecord.Core_MDF_Budget_Type_Options_Nm__c));
                recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfcRecord.Core_MDF_Payment_Id__c,pfcRecord.Core_MDF_Region_Cd__c,pfcRecord.Core_MDF_Sub_Region_Cd__c,pfcRecord.Core_MDF_Program__c, pfcRecord.Core_MDF_Budget_Type_Options_Nm__c,pfcRecord.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
            }else if(pfcRecord.Core_MDF_Program__c==Core_MDF_CustomLabelConfig.getTextValues('Core_MDF_Co_GTM_program_name')){
                List<String> regions = Core_MDF_CCP_ConstantClass.CAMPAIGN_ALL_REGION.split(';');
                for(String geo: regions) {
                    recordGeoShareList.add(new Core_MDF_RecordGeoShare(pfcRecord.Core_MDF_Payment_Id__c,geo,NULL,pfcRecord.Core_MDF_Program__c, pfcRecord.Core_MDF_Budget_Type_Options_Nm__c));   
                    recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfcRecord.Core_MDF_Payment_Id__c,geo,NULL,pfcRecord.Core_MDF_Program__c, pfcRecord.Core_MDF_Budget_Type_Options_Nm__c, pfcRecord.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
                }
            }
            else
            {
                recordGeoShareList.add(new Core_MDF_RecordGeoShare(pfcRecord.Core_MDF_Payment_Id__c,pfcRecord.Core_MDF_Region_Cd__c,pfcRecord.Core_MDF_Sub_Region_Cd__c,pfcRecord.Core_MDF_Program__c));   
                recordPGMShareList.add(new Core_MDF_RecordPGMShareWrapper(pfcRecord.Core_MDF_Payment_Id__c,pfcRecord.Core_MDF_Region_Cd__c,pfcRecord.Core_MDF_Sub_Region_Cd__c,pfcRecord.Core_MDF_Program__c,pfcRecord.ChannelPartner.Core_MDF_CoMarketing_Ultimate_Account__c));
            }
              
            //sharing of payment with account's group.
            //Single payment is associated with more than one account so we need if else condition for account's group id 
            if(pfcRecord.ChannelPartner.Core_MDF_Channel_Program__c != Null && 
               pfcRecord.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c != Null 
               && Core_MDF_shareRecordToAccountGroup.isNodeBasedSharingReqd(pfcRecord.ChannelPartner.Core_MDF_Channel_Program__r.Core_MDF_Technical_Program_Name__c)
               && pfcRecord.ChannelPartner.Core_MDF_Group_Id__c != Null)
            {
                if(paymentIdGroupIdListMap.containsKey(pfcRecord.Core_MDF_Payment_Id__c)){ paymentIdGroupIdListMap.get(pfcRecord.Core_MDF_Payment_Id__c).add(pfcRecord.ChannelPartner.Core_MDF_Group_Id__c);
                }
                else{ paymentIdGroupIdListMap.put(pfcRecord.Core_MDF_Payment_Id__c, new List<Id>{pfcRecord.ChannelPartner.Core_MDF_Group_Id__c});
                } 
            }
        }

        List<SObject> shareRecordList = new List<SObject>();
        List<SObject> geoShareRecordList = new List<SObject>();
        List<SObject> partnerShareRecordList = new List<SObject>();
        List<SObject> accountGroupShareRecordList = new List<SObject>();
        List<SObject> intPGMShareRecordList = new List<SObject>();

        //Metadata Record Sharing
       if(recordGeoShareList != null && recordGeoShareList.size() >0){    
            if(Core_MDF_Utility.byPassFeature('Bypass_PaymentsBulkAPISharing')){
                 //To share record on the basis of Channel Program and geo 
                   geoShareRecordList = Core_MDF_ShareRecordToGeoGroup.shareRecordToGeoGroupforBatch('Core_MDF_Payment__c',recordGeoShareList);
                   if(!geoShareRecordList.isEmpty()){
                        shareRecordList.addAll(geoShareRecordList);
                   }
            }
            
            else {Core_MDF_ShareRecordToGeoGroup.shareRecordToGeoGroup('Core_MDF_Payment__c',recordGeoShareList); }
        }
        partnerShareRecordList = sharePaymentRecordsToPartner(paymentWrapperMap);
        if(!partnerShareRecordList.isEmpty()){
            shareRecordList.addAll(partnerShareRecordList);
        }

        //Sharing payment with account's group - VD
        if(paymentIdGroupIdListMap!=Null && !paymentIdGroupIdListMap.isEmpty()){ Core_MDF_GenericShareRecordActionClass.RecordManualShareClass rmsInst = new Core_MDF_GenericShareRecordActionClass.RecordManualShareClass('Core_MDF_Payment__c', paymentIdGroupIdListMap, 'Edit', 'Manual');
            accountGroupShareRecordList = Core_MDF_GenericShareRecordActionClass.createShareRecordListforBatch(rmsInst);
            if(!accountGroupShareRecordList.isEmpty()){
                shareRecordList.addAll(accountGroupShareRecordList);
            }
        }
       
        // Passing the Parameters to the Generic Share Record Class method 
        // to share the Payment to the respective Group
        if(recordPGMShareList != null && recordPGMShareList.size() >0){
            intPGMShareRecordList = Core_MDF_CCP_GenericUtility.createShareRecForInternalPGMgrps('Core_MDF_Payment__c', recordPGMShareList, false);
            if(!intPGMShareRecordList.isEmpty()){
                shareRecordList.addAll(intPGMShareRecordList);
            }
        }        
        //Insert Payment Share records using Batch
        if(!shareRecordList.isEmpty()){
            if(context == 'Trigger'){
                Database.executeBatch(new Core_MDF_Batch_Bulk_CRUD_Operations(shareRecordList), 500);// Check for Row lock issue by reducing size
            }else if(context == 'PGM'){
                Integer batchSize = 200;
                Integer totalRecords = shareRecordList.size();                
                List<Core_MDF_Batch_Request_and_Update_Log__c> logsToInsert = new List<Core_MDF_Batch_Request_and_Update_Log__c>();
                Id recordTypeId = Schema.SObjectType.Core_MDF_Batch_Request_and_Update_Log__c.getRecordTypeInfosByDeveloperName().get('Core_MDF_Payment_Share').getRecordTypeId();                
                for (Integer i = 0; i < totalRecords; i += batchSize) {
                    List<Map<String, Object>> chunkList = new List<Map<String, Object>>();
                    for (Integer j = i; j < Math.min(i + batchSize, totalRecords); j++) {
                        SObject sObj = shareRecordList[j];
                        Map<String, Object> recordMap = new Map<String, Object>{
                            'ParentId' => (String)sObj.get('ParentId'),
                                'UserOrGroupId' => (String)sObj.get('UserOrGroupId'),
                                'AccessLevel' => (String)sObj.get('AccessLevel'),                                
                                'RowCause' => (String)sObj.get('RowCause')
                                };
                                    chunkList.add(recordMap); 
                    }
                    Map<String, Object> wrapper = new Map<String, Object>{'Core_MDF_Payment__Share' => chunkList};
                        logsToInsert.add(new Core_MDF_Batch_Request_and_Update_Log__c(
                            RecordTypeId = recordTypeId,
                            Core_MDF_Action_txt__c = 'Insert',
                            Core_MDF_Object_apiName_nm__c = 'Core_MDF_Payment__Share',
                            Core_MDF_JSON_String_txt__c = JSON.serialize(wrapper),
                            Core_MDF_Status__c = 'Pending'
                        ));
                }                                
                Database.insert(logsToInsert);
            }
        }        
    } 
}