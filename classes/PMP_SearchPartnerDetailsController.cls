public with sharing class PMP_SearchPartnerDetailsController extends PMP_SearchWrapperStore{
    
    @AuraEnabled(cacheable=true)
    public static PartnerDetail getPartnerDetails(String partnerId, String langCode){
        //System.debug('PPP-->partnerId:'+partnerId);
        PartnerDetail partnerDetail=new PartnerDetail();
        PMP_Company__c company = new PMP_Company__c();
        //String jsonValue;
        //Boolean cachePreview=False;
        
            if(Schema.sObjectType.PMP_Company__c.isAccessible()){
				//Modified as a part of OPID Restructure : Removing PMP_Account_Id__c from the Query																
                company=[SELECT Id, Name,PMP_Is_Working_Copy_Ind__c,PMP_Marketing_Profile_Id__c, PMP_Partner_Program_nm__c, PMP_Account_Dsc__c, PMP_Account_Address_Txt__c,
                         PMP_Account_Industry__c, PMP_Account_Application__c,PMP_Account_Region__c, PMP_Account_Program_Membership__c,PMP_Company_Lifecycle_Status_Nm__c, 
                         PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c, PMP_Account_Specialty__c,PMP_Account_Website__c,
                         PMP_Account_Tag_Line__c,PMP_Working_Copy_Id__c,PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c,
                         PMP_Working_Copy_Id__r.PMP_Company_Status_Update_Dt__c,PMP_Working_Copy_Id__r.PMP_Is_Updated_Ind__c,
                         PMP_Working_Copy_Id__r.PMP_Initial_Storefront_Submit_Date_Dt__c,PMP_Published_Copy_Id__c,
                         PMP_Published_Copy_Id__r.PMP_Company_Status_Update_Dt__c,PMP_Published_Copy_Id__r.PMP_Is_Updated_Ind__c,
                         PMP_Published_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c,PMP_Is_Published_Ind__c,
                         PMP_Published_Copy_Id__r.PMP_Initial_Storefront_Submit_Date_Dt__c,PMP_Working_Copy_Id__r.PMP_Enhanced_Login_Users_Txt__c,
                         toLabel(PMP_Disti_Components_Nm__c),toLabel(PMP_Disti_Sys_Solutions_Nm__c),PMP_Is_Distributor_Ind__c,PMP_Company_Status_Published_Date_Dt__c,PMP_Working_Copy_Id__r.PMP_Company_Status_Published_Date_Dt__c
                         FROM PMP_Company__c where id=:partnerId LIMIT 1];
            }
        if(company.PMP_Is_Working_Copy_Ind__c == true){
            try{
				//Modified as a part of OPID Restructure : Removing PMP_Account_Id__c from the Query																			
                if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                    company=[SELECT Id, Name,PMP_Marketing_Profile_Id__c, PMP_Partner_Program_nm__c, PMP_Account_Dsc__c, PMP_Account_Address_Txt__c,PMP_Company_Lifecycle_Status_Nm__c,
                             PMP_Account_Industry__c, PMP_Account_Application__c,PMP_Account_Region__c, PMP_Account_Program_Membership__c, 
                             PMP_Is_Enabled_Lead_Gen_Nm__c,PMP_Is_Lead_Gen_Limited_Nm__c, PMP_Account_Specialty__c,PMP_Account_Website__c,
                             PMP_Account_Tag_Line__c,PMP_Working_Copy_Id__c,PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c,
                             PMP_Working_Copy_Id__r.PMP_Company_Status_Update_Dt__c,PMP_Working_Copy_Id__r.PMP_Is_Updated_Ind__c,
                             PMP_Published_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c,PMP_Is_Published_Ind__c,
                             PMP_Working_Copy_Id__r.PMP_Initial_Storefront_Submit_Date_Dt__c,PMP_Working_Copy_Id__r.PMP_Enhanced_Login_Users_Txt__c,
                             toLabel(PMP_Disti_Components_Nm__c),toLabel(PMP_Disti_Sys_Solutions_Nm__c),PMP_Is_Distributor_Ind__c,PMP_Published_Copy_Id__r.PMP_Company_Status_Published_Date_Dt__c,PMP_Company_Status_Published_Date_Dt__c,PMP_Working_Copy_Id__r.PMP_Company_Status_Published_Date_Dt__c
                             FROM PMP_Company__c where PMP_Working_Copy_Id__c =: partnerId LIMIT 1];
                }
                partnerId = company.Id;
            }catch(Exception e){
                //system.debug('error while fetching company records' + e);
            }
            
        }
          
        
        partnerDetail.id=partnerId;
        partnerDetail.name=company.Name;
        partnerDetail.promotion=new List<Promotion>();
        partnerDetail.categories=new List<CategoryTab>();
        partnerDetail.companyResources=new List<PartnerResource>();
        partnerDetail.mobileList=new List<Mobile>();
        //partnerDetail.mdaId = PMP_SearchUtilityController.getMdaId(company.PMP_Account_Id__c);
        
        //To get partner card attributes
        //IPA2.0:US-4497-1631_OfferingEOL
        //Partner partner = PMP_ProductPartnerDetailsController.getPartnerDetails(NULL, company.Id, company, false, langCode);
        Partner partner = PMP_ProductPartnerDetailsController.getPartnerDetails(company.Id, company, false, langCode);

        
        partner.contactByEmail = false;
        partner.contactByForm = true;
        //partner.imageUrl='https://via.placeholder.com/350x197/0071C5/FFFFFF?text=Product';
        partnerDetail.partnerDetails= partner;
        
        //Logic to show notifications in storefront
        if (company.PMP_Working_Copy_Id__c !=null)
        {
          partnerDetail.currentStatus = company.PMP_Working_Copy_Id__r.PMP_Company_Lifecycle_Status_Nm__c;
          partnerDetail.publishedStatus = company.PMP_Company_Lifecycle_Status_Nm__c;
          partnerDetail.isUpdateRequired = company.PMP_Working_Copy_Id__r.PMP_Is_Updated_Ind__c;
            //partnerDetail.partnerType=company.PMP_Working_Copy_Id__r.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c;
            if (company.PMP_Working_Copy_Id__r.PMP_Company_Status_Update_Dt__c!=null)
            {
                Date dt = company.PMP_Working_Copy_Id__r.PMP_Company_Status_Update_Dt__c;
                //system.debug('Date :'+ dt);
                
                DateTime dtm = DateTime.newInstance(dt.year(),dt.month(),dt.day());
                //system.debug('DateTime :'+ dtm);
                partnerDetail.statusUpdateDate = dtm.format('dd-MMM-yyyy');

            }  
            if (company.PMP_Working_Copy_Id__r.PMP_Initial_Storefront_Submit_Date_Dt__c !=null)
            {
                Date dt = company.PMP_Working_Copy_Id__r.PMP_Initial_Storefront_Submit_Date_Dt__c;
                DateTime dtm = DateTime.newInstance(dt.year(),dt.month(),dt.day());
                partnerDetail.initialUpdateDate = dtm.format('dd-MMM-yyyy');
                
            }
            if (company.PMP_Working_Copy_Id__r.PMP_Company_Status_Published_Date_Dt__c !=null)
            {
                Date dt = company.PMP_Working_Copy_Id__r.PMP_Company_Status_Published_Date_Dt__c;
                DateTime dtm = DateTime.newInstance(dt.year(),dt.month(),dt.day());
                partnerDetail.publishedDate = dtm.format('dd-MMM-yyyy');

            }
             
          
        }
           //Added to store published status date -US686715
             
       
     
        
        /********Translation logic Start *******/ 
        String userLanguage =  langCode;
        String description = '';
        String tagline = '';
        List<PMP_Company_Translation__c> transList = new List<PMP_Company_Translation__c>();
    	String streamIdName = PMP_Utility.getValue('PMP_Uberflip_Stream_Id_Name');
        try{
            if(Schema.sObjectType.PMP_Company_Translation__c.isAccessible()){
                transList = [select id, Name, PMP_Field_Nm__c, PMP_English_Txt__c,
                             PMP_Chinese_Txt__c, PMP_Japanese_Txt__c from PMP_Company_Translation__c 
                             where PMP_Company_Information_Id__c = :partnerId AND PMP_Field_Nm__c != :streamIdName];
            }            
        }catch(Exception e){ 
            //System.debug('Error in fetching records of Company Translation :'+ e);
        }
        for(PMP_Company_Translation__c trans: transList)
        {
            String temp = '';
            if (userLanguage == PMP_StaticConstants_Partner.ZH_CN && trans.PMP_Chinese_Txt__c != null){
                temp = trans.PMP_Chinese_Txt__c;
            }
            else if (userLanguage == PMP_StaticConstants_Partner.JA && trans.PMP_Japanese_Txt__c != null){
                temp = trans.PMP_Japanese_Txt__c;
            }
            else if (trans.PMP_English_Txt__c != null){
                temp = trans.PMP_English_Txt__c;
            }
            if (trans.PMP_Field_Nm__c == 'PMP_Account_Dsc__c')
            {
                description = temp;
            }
            else if (trans.PMP_Field_Nm__c == 'PMP_Account_Tag_Line__c')
            {
                tagline = temp;
            }
        }
        
        /********Translation logic End *******/
        if(tagline != null){
            partnerDetail.tagline = tagline.unescapeHtml4(); 
        }
        
        
        //Logic to show more or show less is handled at the UI level
        if (description != null)
        {   
            partnerDetail.partnerDescription= description.unescapeHtml4();
            partnerDetail.partnerShortDescription = description.unescapeHtml4().stripHtmlTags(); //Sending striped string to display in intro section ()
        }
        /*
        //Partner Image Implemetation
        Map<String, String> partnerContentMap = new Map<String,String>();
        List<PMP_Company_Resource__c> partnerResource = new List<PMP_Company_Resource__c>();
        List<String> partnerConDocList = new List<String>();
        try{
            if(Schema.sObjectType.PMP_Company_Resource__c.isAccessible()){
                partnerResource = [SELECT PMP_Company_Id__c, PMP_Company_Image__c from PMP_Company_Resource__c 
                                   WHERE PMP_Company_Id__c =: partnerId and PMP_Company_Resource_Type_Nm__c='Image' and
                                   PMP_Company_Image__c!=null ORDER BY PMP_Company_Resource_Sequence_Nbr__c NULLS LAST LIMIT 1]; //image sequence no when image is deleted ?
            }
        }catch(DmlException  e){
            system.debug('No resource found');
        }
        system.debug('Storefront res list');
        system.debug(partnerResource);
        if(!partnerResource.isEmpty()){
            for( PMP_Company_Resource__c res: partnerResource ){
               // partnerConDocList.add(partnerResource[0].PMP_Company_Image__c);
               partnerContentMap.put(res.PMP_Company_Id__c,res.PMP_Company_Image__c);
            }
        }
        partnerConDocList.addAll(partnerContentMap.values());
        system.debug('Storefront DOC list');
        system.debug(partnerConDocList);
       //List<ContentDistribution> partnerConDistList = PMP_SearchOfferingImageUtility.getContentDistList(partnerConDocList);
       //Map<String,String> partnerConAssetUrl = PMP_SearchOfferingImageUtility.getContentAssetUrlMap(partnerConDocList);
       //system.debug('Storefront dist list');
       //system.debug(partnerConDistList);
       //Partner Image Implemetation ends
        Commented this code because this logic is no more used*/
        //To get Partner Resource
            List<PMP_Company_Resource__c> resourceList = new List<PMP_Company_Resource__c>();
            if(Schema.sObjectType.PMP_Company_Resource__c.isAccessible()){
                resourceList = [SELECT id,PMP_Company_Resource_Type_Nm__c, PMP_Company_Resource_URL_txt__c, Name  from PMP_Company_Resource__c where PMP_Company_Id__c=:partnerId and PMP_Company_Resource_Type_Nm__c!='Image' and PMP_Company_Resource_Type_Nm__c!='Thumbnail Image'];
            }
            for(PMP_Company_Resource__c resource : resourceList){
            PartnerResource res= new PartnerResource();
            res.title= resource.Name;
            res.linkUrl = resource.PMP_Company_Resource_URL_txt__c;
            res.type =resource.PMP_Company_Resource_Type_Nm__c;
            res.openInNewTab= true;
            partnerDetail.companyResources.add(res);
        }
        
        // To show offering related to partner 
        
        //List<PMP_Partner_Offering_Category__c> offCatList = new List<PMP_Partner_Offering_Category__c>();
        //Benefit
        List<String> benCode = new List<String>();
       
          // partnerDetail.partnerType=company.PMP_Account_Id__c.AccountBenefitAssociations__r.PRM_Benefit_Cd__c;
          //Modified as a part of OPID Restructure
        List<Id> accIds = new List<Id>();
        List<PMP_OPID_MPI_Rel__c> junctionObjects = PMP_Utility.getJunctionAccToMpiByCompanyId(company.Id);
        for(PMP_OPID_MPI_Rel__c juncRec : junctionObjects){
            accIds.add(juncRec.PMP_One_Partner_ID__c);
        }
        List<PRM_AccountBenefitAssociation__c> allBenefits = [SELECT PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c FROM PRM_AccountBenefitAssociation__c WHERE PRM_Account_Id__c in: accIds AND PRM_Status_Nm__c = 'Active'];
        for (PRM_AccountBenefitAssociation__c accBen : allBenefits)
        {
            benCode.add(accBen.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c);
        }
	   //Existing Logic			
      /*for (PRM_AccountBenefitAssociation__c accBen:[SELECT PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c FROM PRM_AccountBenefitAssociation__c 
                                                      WHERE     PRM_Account_Id__c =:company.PMP_Account_Id__c AND PRM_Status_Nm__c = 'Active'])
        {
            benCode.add(accBen.PRM_Partner_Benefit_Id__r.PRM_Benefit_Cd__c);
            //System.debug('partnerType'+partnerDetail.partnerType);
          
        }*/
       
    if (benCode.contains(PMP_StaticConstants_Partner.BENEFIT_ENHANCED_CODE))
        {
            
         //getPartnerCategories(partnerDetail, company.Id);
         //For Enhanced
         //partnerDetail.showMoreSection=true;
         partnerDetail.partnerType=PMP_StaticConstants_Partner.BENEFIT_ENHANCED_CODE;
          //getPartnerOfferings(partnerDetail, company.Id, company.Name, langCode);//IPA2.0:US-4497-1631_OfferingEOL
          partnerDetail.showCompanyResourceAndArticle=false;
         partnerDetail.showCompanyResourceAndArticleforEnhanced=true;
        
        }
    else  
         //if(benCode.contains(PMP_StaticConstants_Partner.BENEFIT_BASIC_PROFILE))
        {
            //For Basic
         partnerDetail.showMoreSection=true;
          partnerDetail.partnerType=PMP_StaticConstants_Partner.BENEFIT_BASIC_PROFILE;
         partnerDetail.showCompanyResourceAndArticleforEnhanced=false;
         partnerDetail.showCompanyResourceAndArticle=true;
        }
      
        //Benefit Logic End
        
        //Event Banner In Storefront page
        //IPA2.0:TWC729-8114 Topics Removal/Event Removal
            List<PMP_Marketplace_Event_Partner__c> eventPartner = new List<PMP_Marketplace_Event_Partner__c>();
            if(Schema.sObjectType.PMP_Marketplace_Event_Partner__c.isAccessible()){
                eventPartner = [select PMP_Company_Id__c from PMP_Marketplace_Event_Partner__c  WHERE PMP_Company_Id__c =:partnerId AND PMP_Event_Id__r.PMP_Marketplace_Event_Status__c =true];
            }
            //system.debug('eventPartner::'+eventPartner);
            if(!eventPartner.isEmpty()){
                partnerDetail.isEventRelated = true;
            }
            
            
        
        //Logic related to Edit Storefront access
        partnerDetail.hasAccess = false;
        partnerDetail.isGuest = false;
        Map<String, Boolean> isSamePartnerUserMap = new Map<String, Boolean>();
        Boolean isSamePartnerUserIndicator = false;
        
        
        //To check system admin
        Boolean isSysAdmin = false;
        Id profId = userInfo.getProfileId();
        String profileName = [Select Name from Profile where Id =: profId].Name;
        
        if(PMP_StaticConstants_Partner.adminProfiles.contains(profileName)){
            isSysAdmin = true;
        }    
        List<String> partnerAccountIds = new List<String>();

        //Modified as a part of OPID Restructure
        List<PMP_OPID_MPI_Rel__c> alljunctionRecs = PMP_Utility.getJunctionAccToMpiByCompanyId(company.Id);
        for(PMP_OPID_MPI_Rel__c juncRec : alljunctionRecs){
            partnerAccountIds.add(juncRec.PMP_One_Partner_ID__c);
        }
        //Existing Logic
        //partnerAccountIds.add(company.PMP_Account_Id__c);
        //Checking if same partner's user
        isSamePartnerUserMap = PMP_SearchUtilityController.isSamePartnerUser(partnerAccountIds);
        isSamePartnerUserIndicator=PMP_SearchUtilityController.isSamePartnerUserMethod(partnerAccountIds);
        //Modified as a part of OPID Restructure
        Boolean isSamePartner = false;
        for(String acc : partnerAccountIds){
            if(!isSamePartnerUserMap.containsKey(acc)){
                isSamePartnerUserMap.put(acc, false);
            }else{
                isSamePartner = isSamePartnerUserMap.get(acc);
            }
        }
        //Existing Logic
        /*if(!isSamePartnerUserMap.containsKey(company.PMP_Account_Id__c))
            isSamePartnerUserMap.put(company.PMP_Account_Id__c, false);
        */
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> isOtherPartnerPSet = new List<PermissionSetAssignment>();
        List<PermissionSetAssignment> isPartnerAdminPSet = new List<PermissionSetAssignment>();
        
        //if(Schema.sObjectType.PermissionSetAssignment.isAccessible() && Schema.sObjectType.User.isAccessible()){
        permissionSetList = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name in :PMP_StaticConstants_Partner.permissionSets];
        
        isPartnerAdminPSet = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: Userinfo.getUserId() AND PermissionSet.Name =:PMP_StaticConstants_Partner.permissionSets[0]];
        
        isOtherPartnerPSet = [SELECT Id FROM PermissionSetAssignment WHERE AssigneeId =: Userinfo.getUserId() AND PermissionSet.Name =:PMP_StaticConstants_Partner.otherPartnerPSets];
        //} 
        //system.debug('!PMP_SearchUtilityController.isGuest() => '+!PMP_SearchUtilityController.isGuest());
        //system.debug('isSamePartnerUserMap => '+isSamePartnerUserMap);
        //system.debug('isSamePartnerUserMap.get(company.PMP_Account_Id__c) => '+isSamePartnerUserMap.get(company.PMP_Account_Id__c));
        //system.debug('permissionSetList => '+permissionSetList);
        if(!PMP_SearchUtilityController.isGuest()){
			if(PMP_StaticConstants_Partner.adminProfiles.contains(profileName)  || isSamePartnerUserIndicator && permissionSetList.size()>0)																												   
           // if(PMP_StaticConstants_Partner.adminProfiles.contains(profileName)  || (isSamePartnerUserMap.get(company.PMP_Account_Id__c) && permissionSetList.size()>0))
                partnerDetail.hasAccess = true;
            if(PMP_SearchUtilityController.isIntelAdmin()){
                partnerDetail.hasAccess = true;
            }
        }
        // system.debug('hasAccess => '+partnerDetail.hasAccess);
        partnerDetail.isGuest = PMP_SearchUtilityController.isGuest();
        
        partnerDetail.leadSettings = PMP_SearchCompanyLeadGenController.getExistingSettings(partnerId);
        //system.debug('LeadSettings : ' + partnerDetail.leadSettings);
        //system.debug('leadLangPreference => '+PMP_SearchUtilityController.getLanguageMessage(partnerDetail.leadSettings.languagePreference));
        partnerDetail.leadLangPreference = PMP_SearchUtilityController.getLanguageMessage(partnerDetail.leadSettings.languagePreference);
        /** MANAGE OFFERINGS FUNCTIONALITY START**/
        List<PermissionSetAssignment> isMangeOfferingsPSet = [SELECT Id,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId =: Userinfo.getUserId() AND PermissionSet.Name in:PMP_StaticConstants_Partner.manageOfferingPermissionSets];
        
        // system.debug('isMangeOfferingsPSet----'+isMangeOfferingsPSet.size());
        /*   if(isMangeOfferingsPSet != null && isMangeOfferingsPSet.size()>0){

partnerDetail.manageOfferingAccess = true;                            
}*/
        
        //system.debug('ACC ID :::'+company.PMP_Account_Id__c);       
        /** MANAGE OFFERINGS FUNCTIONALITY END**/
        /*** Lead Gen Logic Starts ***/ 
        
        if( !partnerDetail.isGuest){
			//Commenting as a part of OPID Restructure										  
            /*PMP_Company__c partnerAccount = new PMP_Company__c();
            if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                partnerAccount = [SELECT id,PMP_Account_Id__r.ParentId from PMP_Company__c WHERE id=: partnerId]; 
            }*/
            //system.debug('User Info : '+ user.AccountId);
            //Modified as a part of OPID Restructure
            for(Id acc : accIds){
                if(!isPartnerAdminPSet.isEmpty() && isPartnerAdminPSet.size() > 0 && isSamePartnerUserIndicator){
                    //if(isSamePartnerUserIndicator){
                        partnerDetail.hasLeadGenAccess = true;
                    //}
                }else if(!isOtherPartnerPSet.isEmpty() && isOtherPartnerPSet.size()>0 && isSamePartnerUserIndicator){
                    //if(isSamePartnerUserIndicator){
                        partnerDetail.hasLeadGenAccess = false;
                    //}
                }
                if(!isMangeOfferingsPSet.isEmpty() && isMangeOfferingsPSet.size()>0 && isSamePartnerUserIndicator){
                    //if(isSamePartnerUserIndicator){     
                        partnerDetail.manageOfferingAccess = true;                            
                    //}
                }
            }
			//Existing Logic				
            /*if(!isPartnerAdminPSet.isEmpty() && isPartnerAdminPSet.size() > 0){
                if(isSamePartnerUserMap.get(company.PMP_Account_Id__c)){
                    partnerDetail.hasLeadGenAccess = true;
                }
            }else if(!isOtherPartnerPSet.isEmpty() && isOtherPartnerPSet.size()>0){
                if(isSamePartnerUserMap.get(company.PMP_Account_Id__c)){
                    partnerDetail.hasLeadGenAccess = false;
                }
            }
            if(!isMangeOfferingsPSet.isEmpty() && isMangeOfferingsPSet.size()>0){
                if(isSamePartnerUserMap.get(company.PMP_Account_Id__c)){                         
                    partnerDetail.manageOfferingAccess = true;                            
                }
            }*/
            
            
            
            // Admin If Ends 
            //Modified as a part of OPID Restructure
            partnerDetail.isSamePartnerUser = isSamePartnerUserIndicator;
            //Existing Logic
            //partnerDetail.isSamePartnerUser = isSamePartnerUserMap.get(company.PMP_Account_Id__c);
        }//Guest if Ends
        else{
            partnerDetail.isSamePartnerUser = false;
            partnerDetail.manageOfferingAccess = false;
        }
        if(isSysAdmin || PMP_SearchUtilityController.isIntelAdmin()){
            partnerDetail.hasLeadGenAccess = true;
            partnerDetail.isSamePartnerUser = true;
            partnerDetail.manageOfferingAccess = true;            
        }
        partnerDetail.isIntelAdmin = PMP_SearchUtilityController.isIntelAdmin();
        /*** Lead Gen Logic Ends ***/ 
        
        partnerDetail.isContactPartnerVisible = PMP_SearchUtilityController.isContactButtonVisible(company);

        partnerDetail.showEnhancedPopup = !(company.PMP_Working_Copy_Id__r.PMP_Enhanced_Login_Users_Txt__c != NULL && company.PMP_Working_Copy_Id__r.PMP_Enhanced_Login_Users_Txt__c.contains(UserInfo.getUserId()));
    
        //New Logic for entitlements - Prabuddh (09/13/2020)
        final List<String> entitlements = getEntitlementsForCurrentUser(); 
        partnerDetail.isMarkettingSpecialist = entitlements.contains(PMP_StaticConstants_Partner.MARKETING_SPECIALIST);  
        partnerDetail.isPartnerAdmin = entitlements.contains(PMP_StaticConstants_Partner.PARTNER_ADMIN);    
        partnerDetail.isOfferingEditor = entitlements.contains(PMP_StaticConstants_Partner.OFFERING_EDITOR);  
        // Modified below condition to fix the production Issue -> Added by Onyx (18/02/2022) // Prod Fix - INC11025773
        if (entitlements.contains(PMP_StaticConstants_Partner.EMPLOYEE) && entitlements.size()==1) {
            partnerDetail.isLdrOeEmployee = true;
        } 
        else if (entitlements.contains(PMP_StaticConstants_Partner.LDR) || entitlements.contains(PMP_StaticConstants_Partner.OFFERING_EDITOR)) {
            partnerDetail.isLdrOeEmployee = true;
        }
        else {
            partnerDetail.isLdrOeEmployee = false;
        }     
        
        // System.debug('partnerDetail'+partnerDetail);
        return partnerDetail;
    } 
    
    /*public static void getPartnerCategories(PartnerDetail partnerDetail, String partnerId){
        
        PMP_Company__c partner = new PMP_Company__c();
        
        if(Schema.SObjectType.PMP_Company__c.isAccessible()){
            partner = [SELECT Name FROM PMP_Company__c WHERE Id=:partnerId];
        }
        
        List<CategoryTab> categories = new List<CategoryTab>();
        String ansPimId = PMP_StaticConstants_Partner.PIM_CATEGORY_ID + '%';
        Map<String,Product> offEntMap=new Map<String,Product>();  //Map to assign offering Id with Product Wrapper 
        Map<String,List<Product>> catEntMap=new Map<String,List<Product>>();    //Map to get offering based on Category they belong 
        
        List<PMP_Partner_Offering_Category__c> offCatList = new List<PMP_Partner_Offering_Category__c>();
        
        if(Schema.SObjectType.PMP_Partner_Offering_Category__c.isAccessible()){
            offCatList = [SELECT PMP_Offering_Id__r.PMP_Partner_Offering_Visibility_Nm__c,PMP_Offering_Id__r.PMP_Partner_Offering_Nm__c,PMP_Offering_Id__c, PMP_Offering_Id__r.Name, PMP_Offering_Id__r.PMP_Partner_Offering_Dsc__c,PMP_Category_Id__r.Name FROM PMP_Partner_Offering_Category__c 
                          WHERE PMP_Category_Id__r.PMP_Ancestor_Category_Cd__c LIKE :ansPimId AND PMP_Offering_Id__r.PMP_Company_Id__c=:partner.Id
                          //AND PMP_Offering_Id__c IN (SELECT PMP_Partner_Offering_Id__c FROM PMP_Partner_Offering_Translation__c WHERE PMP_Partner_Offering_Id__r.PMP_Company_Id__c =: partnerId)                               
                          AND PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c =:PMP_StaticConstants_Partner.Published 
                          AND PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY 
                          ORDER BY PMP_Offering_Id__r.PMP_Featured_Offering_Ind__c DESC NULLS LAST, PMP_Offering_Id__r.PMP_Offering_Status_Update_Dt__c DESC NULLS LAST,PMP_Category_Id__r.Name];
        }
        
        
        for(PMP_Partner_Offering_Category__c offCat: offCatList){
            
            Product prod=new Product();
            prod.title=offCat.PMP_Offering_Id__r.PMP_Partner_Offering_Nm__c;
            
            prod.imageUrl='https://via.placeholder.com/350x197/0071C5/FFFFFF?text=Product';
            prod.id=offCat.PMP_Offering_Id__c;
            prod.description=offCat.PMP_Offering_Id__r.PMP_Partner_Offering_Dsc__c;
            prod.attributes=new List<Attribute>(); 
            //To check if intel only offering
            if(offCat.PMP_Offering_Id__r.PMP_Partner_Offering_Visibility_Nm__c == PMP_StaticConstants_Partner.INTEL_ONLY){
                prod.onlyVisibleToIntel = true;
            }
            //Logic end
            offEntMap.put(offCat.PMP_Offering_Id__c,prod);
            
            if (!catEntMap.containsKey(offCat.PMP_Category_Id__c))
            {
                List<Product> prodList=new List<Product>();
                prodList.add(prod);
                catEntMap.put(offCat.PMP_Category_Id__c,prodList);
            }
            else
            {
                catEntMap.get(offCat.PMP_Category_Id__c).add(prod);
            }
        }
        //Logic to fetch Offering name from Translation
        Map<String,PMP_Partner_Offering_Translation__c> offTransMap = new Map<String,PMP_Partner_Offering_Translation__c>();        
        List<PMP_Partner_Offering_Translation__c> offTransList = [SELECT PMP_Field_Nm__c, PMP_Partner_Offering_Id__c, PMP_English_Txt__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c FROM PMP_Partner_Offering_Translation__c 
                                                                  WHERE (PMP_Field_Nm__c = :PMP_StaticConstants_Partner.OFFERING_NAME OR PMP_Field_Nm__c = :PMP_StaticConstants_Partner.OFFERING_DESCRIPTION) AND PMP_Partner_Offering_Id__c IN :offEntMap.keySet()];
        for(PMP_Partner_Offering_Translation__c trans: offTransList){
            if(trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.OFFERING_NAME){
                offEntMap.get(trans.PMP_Partner_Offering_Id__c).title = PMP_SearchUtilityController.getLocalisedName(trans, '','');
            }else if(trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.OFFERING_DESCRIPTION){
                offEntMap.get(trans.PMP_Partner_Offering_Id__c).description = PMP_SearchUtilityController.getLocalisedName(trans, '', '');
            }
        }
        //Changes End
        List<String> offIdList = new List<String>();
        offIdList.addAll(offEntMap.keySet());
        Map<String,List<Attribute>> offAttMap=PMP_SearchAttributeController.getOfferingAttributes(offIdList);
        for (String offId : offEntMap.keySet())
        {
            offEntMap.get(offId).attributes = offAttMap.get(offId);
        }
        //Logic to fetch Card Attributes
        
        //Changes End
        List<PMP_Category__c> catList = [SELECT Id,Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c FROM PMP_Category__c WHERE PMP_Partner_Product_Parent_Category_Cd__c =: PMP_StaticConstants_Partner.PIM_CATEGORY_ID];
        for(PMP_Category__c cat: catList){
            
            CategoryTab category=new CategoryTab();
            category.label= PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, '');   
            category.viewAllLabel=partner.Name.split(' ')[0];
            category.iconUrl='https://via.placeholder.com/107/000000/EEEEEE?Text=Solutions';
            category.entries = new List<Product>();
            if(catEntMap.containsKey(cat.Id)){
                Integer rangeLast = Math.min(catEntMap.get(cat.Id).size() , 5);
                for (Integer i = 0; i < rangeLast ; i++){
                    category.entries.add(catEntMap.get(cat.Id).get(i));
                }
                category.count=catEntMap.get(cat.Id).size();
            }
            
            
            Mobile mob=new Mobile();
            mob.label=category.label + ' ('+category.count+')';
            //mob.link=category.viewAllLinkUrl;
            mob.imgUrl=category.iconUrl;
            partnerDetail.mobileList.add(mob);
            
            //Adding SearchParams for particular Category Tab
            SearchParams params = new SearchParams();
            params.cat = cat.Id;
            params.type = 'product';
            params.selectedFilters = new Map<String,List<String>>();
            List<String> filterList = new List<String>();
            filterList.add(partner.Id);
            params.selectedFilters.put('Partner', filterList);
            
            category.searchParams = params;
            
            if (category.entries.size()>0)
                partnerDetail.categories.add(category);
        }
        
        Map<String,String> offContentMap=new Map<String,String>();
        List<String> conDocList = new List<String>();
        
        List<PMP_Partner_Offering_Resource__c> offResList = new List<PMP_Partner_Offering_Resource__c>();
        if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
            offResList = [Select PMP_Offering_Id__c, PMP_Partner_Offering_Image__c from PMP_Partner_Offering_Resource__c WHERE PMP_Offering_Id__c in :offEntMap.keySet() and PMP_Resource_Type_Nm__c=:PMP_StaticConstants_Partner.THUMBNAIL_IMAGE and PMP_Partner_Offering_Image__c!=null and PMP_Resource_Sequence_Nbr__c = 0];      
        } 
        
        for(PMP_Partner_Offering_Resource__c offRes : offResList){
            offContentMap.put(offRes.PMP_Partner_Offering_Image__c, offRes.PMP_Offering_Id__c);
            conDocList.add(offRes.PMP_Partner_Offering_Image__c);
        }
        
        List<ContentDistribution> conDistList = PMP_SearchOfferingImageUtility.getContentDistList(conDocList);
        
        if(!conDistList.isEmpty()){
            for (ContentDistribution cd : conDistList){           
                offEntMap.get(offContentMap.get(cd.ContentDocumentId)).imageUrl = cd.ContentDownloadUrl;         
            }       
        }
        
    }*/
    //IPA2.0:US-4497-1631_OfferingEOL
    /*public static void getPartnerOfferings(PartnerDetail partnerDetail, String partnerId, String partnerName, String langCode){
        
        //List<CategoryTab> categories = new List<CategoryTab>();
        Map<String,Product> offEntMap=new Map<String,Product>();  //Map to assign offering Id with Product Wrapper 
        List<PMP_Category__c> cats = new List<PMP_Category__c>();
        if(Schema.sObjectType.PMP_Category__c.isAccessible()){
            cats = [SELECT Id FROM PMP_Category__c WHERE PMP_Active_Ind__c= TRUE AND PMP_Partner_Product_Parent_Category_Cd__c =:PMP_StaticConstants_Partner.PIM_CATEGORY_ID ];
        }
        List<String> catIds = new List<String>();
        for(PMP_Category__c cat: cats){
            catIds.add(cat.Id);
        }
        List<PMP_Category__c> catList = new List<PMP_Category__c>();
        if(Schema.sObjectType.PMP_Category__c.isAccessible() && Schema.sObjectType.PMP_Partner_Offering_Category__c.isAccessible()){
            catList = [SELECT Name,PMP_Category_Chinese_Nm__c,PMP_Category_Japanese_Nm__c,PMP_Partner_Product_Category_Cd__c,
                       (SELECT PMP_Offering_Id__r.PMP_Partner_Offering_Visibility_Nm__c,PMP_Offering_Id__r.PMP_Partner_Offering_Nm__c,
                        PMP_Offering_Id__c, PMP_Offering_Id__r.Name, PMP_Offering_Id__r.PMP_Partner_Offering_Dsc__c 
                        FROM Offering_Categories__r WHERE PMP_Offering_Id__r.PMP_Company_Id__c =: partnerId 
                        AND PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c =:PMP_StaticConstants_Partner.Published AND PMP_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c = FALSE 
                        AND PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY 
                        ORDER BY PMP_Offering_Id__r.PMP_Featured_Offering_Ind__c DESC NULLS LAST, PMP_Offering_Id__r.PMP_Offering_Status_Update_Dt__c DESC NULLS LAST LIMIT 5) 
                       FROM PMP_Category__c WHERE PMP_Active_Ind__c=true AND Id IN:catIds ORDER BY PMP_Category_Display_Sequence_Nbr__c];
        }
        Map<String,Integer> countMap = new Map<String,Integer>();
        List<AggregateResult> offCats = new List<AggregateResult>();
        if(Schema.sObjectType.PMP_Partner_Offering_Category__c.isAccessible()){
            offCats = [select COUNT(PMP_Offering_Id__c)cnt, PMP_Category_Id__c from PMP_Partner_Offering_Category__c 
                       where PMP_Offering_Id__r.PMP_Company_Id__c =: partnerId AND PMP_Category_Id__c IN:catIds
                       and PMP_Category_Id__c !=null AND PMP_Category_Id__r.PMP_Active_Ind__c = true 
                       AND PMP_Offering_Id__r.PMP_Partner_Offering_Lifecycle_Status_Nm__c =:PMP_StaticConstants_Partner.Published AND PMP_Offering_Id__r.PMP_Is_Not_Available_On_MP_Ind__c = FALSE
                       AND PMP_Offering_Id__r.PMP_Partner_Offering_Start_Dt__c <= TODAY and PMP_Offering_Id__r.PMP_Partner_Offering_End_Dt__c >= TODAY 
                       GROUP BY PMP_Category_Id__c,PMP_Category_Id__r.Name ORDER BY PMP_Category_Id__r.Name];
        }
        for(AggregateResult offCat: offCats){
            countMap.put((String)offCat.get('PMP_Category_Id__c'),(Integer)offCat.get('cnt'));
        }
        List<PMP_Product_Categories_Images__mdt> metaDataList = [select URL__c,label,PIM_Category_Id__c from PMP_Product_Categories_Images__mdt where PIM_Category_Id__c != null ]; 
        Map<String,String> metadataMap = new Map<String,String>();
        for(PMP_Product_Categories_Images__mdt md : metaDataList){
            metadataMap.put(md.PIM_Category_Id__c,md.URL__c);
        }
        PMP_Company__c partner = new PMP_Company__c();
        if(Schema.sObjectType.PMP_Company__c.isAccessible()){
            partner = [SELECT id, Name,PMP_Marketing_Profile_Id__c from PMP_Company__c where id=: partnerId];
        }
        for(PMP_Category__c cat: catList){
            
            CategoryTab category=new CategoryTab();
            category.label= PMP_SearchUtilityController.getLocalisedName(cat, PMP_StaticConstants_Partner.CAT_NAME_FIELD, langCode);   
            category.viewAllLabel = partnerName.split(' ')[0];
            category.iconUrl='https://via.placeholder.com/107/000000/EEEEEE?Text=Solutions';
            category.entries = new List<Product>();
            
            for(PMP_Partner_Offering_Category__c offCat: cat.Offering_Categories__r){
                Product prod=new Product();
                prod.title=offCat.PMP_Offering_Id__r.PMP_Partner_Offering_Nm__c;
                
                //Changed default logo for ProductCard by NIKHIL 26-Nov-2019
                prod.imageUrl=PMP_StaticConstants_Partner.staticProductUrl;
                prod.id=offCat.PMP_Offering_Id__c;
                prod.description=offCat.PMP_Offering_Id__r.PMP_Partner_Offering_Dsc__c;
                prod.attributes=new List<Attribute>(); 
                //To check if intel only offering
                if(offCat.PMP_Offering_Id__r.PMP_Partner_Offering_Visibility_Nm__c == PMP_StaticConstants_Partner.INTEL_ONLY){
                    prod.onlyVisibleToIntel = true;
                }
                category.entries.add(prod);
                
                offEntMap.put(prod.Id,prod);
                
                Partner productPartner = new Partner();
                productPartner.autoPartnerId = partner.PMP_Marketing_Profile_Id__c;
                productPartner.id = partner.Id; 
                productPartner.name = partner.Name; 
                productPartner.contactByEmail = true;
                productPartner.contactByForm = false;
                prod.partner = productPartner;
            }
    
            category.count= 0;
            if(countMap.containsKey(cat.Id)){
                category.count = countMap.get(cat.Id);
            }
            
            
            
            //Adding SearchParams for particular Category Tab
            SearchParams params = new SearchParams();
            params.cat = cat.Id;
            params.type = 'product';
            params.selectedFilters = new Map<String,List<String>>();
            List<String> filterList = new List<String>();
            filterList.add(partnerId);
            params.selectedFilters.put('Partner', filterList);
            
            Mobile mob=new Mobile();
            mob.label=category.label + ' ('+category.count+')';            
            mob.imgUrl = metadataMap.get(cat.PMP_Partner_Product_Category_Cd__c);
            mob.page = 'search';
            mob.searchParams = params;
            partnerDetail.mobileList.add(mob);
            
            category.searchParams = params;
            
            if (category.entries.size()>0)
                partnerDetail.categories.add(category);
        }
        //Logic to fetch Offering name from Translation
        //Map<String,PMP_Partner_Offering_Translation__c> offTransMap = new Map<String,PMP_Partner_Offering_Translation__c>(); 
        List<PMP_Partner_Offering_Translation__c> offTransList = new List<PMP_Partner_Offering_Translation__c>();
        if(Schema.sObjectType.PMP_Partner_Offering_Translation__c.isAccessible()){
            offTransList = [SELECT PMP_Field_Nm__c, PMP_Partner_Offering_Id__c, PMP_English_Txt__c, PMP_Chinese_Txt__c, PMP_Japanese_Txt__c FROM PMP_Partner_Offering_Translation__c 
                            WHERE (PMP_Field_Nm__c = :PMP_StaticConstants_Partner.OFFERING_NAME OR PMP_Field_Nm__c = :PMP_StaticConstants_Partner.OFFERING_DESCRIPTION) AND PMP_Partner_Offering_Id__c IN :offEntMap.keySet()];
        }
        for(PMP_Partner_Offering_Translation__c trans: offTransList){
            if(trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.OFFERING_NAME){
                offEntMap.get(trans.PMP_Partner_Offering_Id__c).title = PMP_SearchUtilityController.getLocalisedName(trans, '',langCode).unescapeHtml4().stripHtmlTags();
                
            }else if(trans.PMP_Field_Nm__c == PMP_StaticConstants_Partner.OFFERING_DESCRIPTION){
                offEntMap.get(trans.PMP_Partner_Offering_Id__c).description = PMP_SearchUtilityController.getLocalisedName(trans, '', langCode).stripHtmlTags().replaceAll('<[^>]+>', '');
            }
        }
        //Changes End
        List<String> offIdList = new List<String>();
        offIdList.addAll(offEntMap.keySet());
        Map<String,List<Attribute>> offAttMap=PMP_SearchAttributeController.getOfferingAttributes(offIdList, langCode);
        for (String offId : offEntMap.keySet())
        {
            offEntMap.get(offId).attributes = offAttMap.get(offId);
        }
        //Logic to fetch Card Attributes
        //
        Map<String,String> offContentMap=new Map<String,String>();
        List<String> conDocList = new List<String>();
         //Map<String, String> partnerContentMap = new Map<String,String>();//Added by Manasa  - for content Asset implementation
        List<PMP_Partner_Offering_Resource__c> offResList = new List<PMP_Partner_Offering_Resource__c>();
        if(Schema.sObjectType.PMP_Partner_Offering_Resource__c.isAccessible()){
            offResList = [Select PMP_Offering_Id__c, PMP_Partner_Offering_Image__c from PMP_Partner_Offering_Resource__c WHERE PMP_Offering_Id__c in :offEntMap.keySet() 
                          and (PMP_Resource_Type_Nm__c=:PMP_StaticConstants_Partner.THUMBNAIL_IMAGE OR PMP_Resource_Type_Nm__c=:PMP_StaticConstants_Partner.IMAGE)
                          and PMP_Partner_Offering_Image__c!=null and PMP_Resource_Sequence_Nbr__c = 0 ORDER BY PMP_Resource_Type_Nm__c ASC];      
        } 
        
        for(PMP_Partner_Offering_Resource__c offRes : offResList){
            offContentMap.put(offRes.PMP_Offering_Id__c, offRes.PMP_Partner_Offering_Image__c);
            //conDocList.add(offRes.PMP_Partner_Offering_Image__c);
        }
        conDocList.addAll(offContentMap.values());
        //List<ContentDistribution> conDistList = PMP_SearchOfferingImageUtility.getContentDistList(conDocList);
         Map<String,String> offConAssetUrl = PMP_SearchOfferingImageUtility.getContentAssetUrlMap(conDocList);//Added by Manasa  - for content Asset implementation*/
                
        
        /*if(!conDistList.isEmpty()){
            for (ContentDistribution cd : conDistList){           
                offEntMap.get(offContentMap.get(cd.ContentDocumentId)).imageUrl = cd.ContentDownloadUrl;         
            }       
        }*/
    //IPA2.0:US-4497-1631_OfferingEOL
        /*if(!conDocList.isEmpty()){
            for(String offId: offEntMap.keySet()){
                if(offContentMap.containsKey(offId)){
                    String assetName = offConAssetUrl.get(offContentMap.get(offId));
                    offEntMap.get(offId).imageUrl = System.Label.PMP_CommunityURLSuffix+'file-asset/'+assetName+'?isOptimized=false';                    
                }
            }            
        }
        
    }*/
    
    public static string updatePartnerInfo(String partnerId) {
        
        //System.debug(':::partnerId:::' + partnerId);
        String retStr = 'Failed';
        
        if(String.isNotBlank(partnerId)) {
            
            //PMP_Company__c comp = new PMP_Company__c();
            Id userId = UserInfo.getUserId();
            
            PMP_Company__c company = new PMP_Company__c();
            if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                company = [SELECT Id,Name,PMP_Is_Working_Copy_Ind__c, PMP_Working_Copy_Id__c, PMP_Enhanced_Login_Users_Txt__c FROM PMP_Company__c WHERE Id= :partnerId];
            }
            if(!company.PMP_Is_Working_Copy_Ind__c && Schema.sObjectType.PMP_Company__c.isAccessible()) {
                //if(Schema.sObjectType.PMP_Company__c.isAccessible()){
                    company = [SELECT Id,Name,PMP_Is_Working_Copy_Ind__c, PMP_Enhanced_Login_Users_Txt__c FROM PMP_Company__c where Id = :company.PMP_Working_Copy_Id__c];
                //}
            }
            
            company.PMP_Enhanced_Login_Users_Txt__c = company.PMP_Enhanced_Login_Users_Txt__c != NULL ? (userId+';'+company.PMP_Enhanced_Login_Users_Txt__c) : userId;
            //System.debug(':::company:::' + company);
            //if(Schema.sObjectType.PMP_Company__c.isUpdateable()){   //ApexCRUDViolation Fix 
            update company;		//This is the exceptional DML operation. So, no need to uncomment this CRUD violation
            //}
            retStr = 'Success'; 
        }
        return retStr;
    }
    
    public static List<String> getEntitlementsForCurrentUser(){
        List<String> entitlements = new List<String>();
        
        List<PermissionSetAssignment> pSetList = [SELECT Id,PermissionSet.Name FROM PermissionSetAssignment WHERE Assignee.Id = :UserInfo.getUserId() and PermissionSet.IsOwnedByProfile = false];
        
        for(PermissionSetAssignment ps : pSetList){
            entitlements.add(ps.PermissionSet.Name);
        }
        
        
        return entitlements;
    }
}