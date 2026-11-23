global class PMP_OfferingList {
    global class OfferingWrapper {
        global String id;
        global String imageUrl;
        global String title;
        
    }

    global static Map<Id, OfferingWrapper> getPartnerOfferings(string partnerId, String langCode){
        List<OfferingWrapper> listOfferingWrapper = new List<OfferingWrapper>();
        List<PMP_Partner_Offering__c> offeringList = [SELECT id, Name FROM PMP_Partner_Offering__c WHERE PMP_Company_Id__c =: partnerId 
                                                      AND PMP_Partner_Offering_Lifecycle_Status_Nm__c =:PMP_StaticConstants_Partner.Published AND PMP_Is_Not_Available_On_MP_Ind__c = false
                                                      AND PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Partner_Offering_End_Dt__c >= TODAY 
                                                      ORDER BY PMP_Featured_Offering_Ind__c DESC NULLS LAST, PMP_Offering_Status_Update_Dt__c DESC NULLS LAST];
        OfferingWrapper offeringData;
        Map<Id, OfferingWrapper> offeringMap = new Map<Id,OfferingWrapper>();
        for(PMP_Partner_Offering__c  offering : offeringList){
            offeringData = new OfferingWrapper();
            offeringData.id = offering.id;
            offeringData.title = offering.Name;
            offeringData.imageUrl = PMP_StaticConstants_Partner.staticProductUrl;
            listOfferingWrapper.add(offeringData);		
            offeringMap.put(offeringData.Id,offeringData);
        }
        Map<String,PMP_Partner_Offering_Translation__c> offTransMap = new Map<String,PMP_Partner_Offering_Translation__c>(); 
        List<PMP_Partner_Offering_Translation__c> offTransList = new List<PMP_Partner_Offering_Translation__c>();
        if(Schema.sObjectType.PMP_Partner_Offering_Translation__c.isAccessible()){
            offTransList = [SELECT PMP_Field_Nm__c, PMP_Partner_Offering_Id__c, PMP_English_Txt__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c FROM PMP_Partner_Offering_Translation__c 
                            WHERE (PMP_Field_Nm__c = :PMP_StaticConstants_Partner.OFFERING_NAME) 
                            AND PMP_Partner_Offering_Id__c IN :offeringMap.keySet()];
        }
        for(PMP_Partner_Offering_Translation__c trans: offTransList){
            if(trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.OFFERING_NAME){
                offeringMap.get(trans.PMP_Partner_Offering_Id__c).title = PMP_SearchUtilityController.getLocalisedName(trans, '',langCode).unescapeHtml4().stripHtmlTags();
            }
        }
        //To get Offering Image
        Map<String,String> offContentMap=new Map<String,String>();
        List<String> conDocList = new List<String>();
        List<PMP_Partner_Offering_Resource__c> offResList = new List<PMP_Partner_Offering_Resource__c>();
        if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
            offResList = [Select PMP_Offering_Id__c, PMP_Partner_Offering_Image__c from PMP_Partner_Offering_Resource__c
                          WHERE PMP_Offering_Id__c in :offeringMap.keySet() 
                          AND PMP_Resource_Type_Nm__c=:PMP_StaticConstants_Partner.IMAGE
                          AND PMP_Partner_Offering_Image__c != null and PMP_Resource_Sequence_Nbr__c = 0 ORDER BY PMP_Resource_Type_Nm__c ASC];
        } 
        for(PMP_Partner_Offering_Resource__c offRes : offResList){
            if(offRes.PMP_Partner_Offering_Image__c != null){
                offContentMap.put(offRes.PMP_Offering_Id__c, offRes.PMP_Partner_Offering_Image__c);
            }
        }
        conDocList.addAll(offContentMap.values());
        Map<String,String> offConAssetUrl = PMP_SearchOfferingImageUtility.getContentAssetUrlMap(conDocList);
        if(!conDocList.isEmpty()){
            for(String offId: offeringMap.keySet()){
                if(offContentMap.containsKey(offId)){
                    String assetName = offConAssetUrl.get(offContentMap.get(offId));
                    offeringMap.get(offId).imageUrl = System.Label.PMP_CommunityURLSuffix+'file-asset/'+assetName+'?isOptimized=false';  
                }
            }            
        }
        return offeringMap;
    }
    
}