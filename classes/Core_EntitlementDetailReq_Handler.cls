@SuppressWarnings('PMD')

    public without sharing class Core_EntitlementDetailReq_Handler extends TriggerHandler { 
        
        public static boolean hasRun = false;
        public Static Set<String> availablePermSets = new Set<String>();
        public Static Set<String> avialablePublicGroups = new Set<String>();
        public Static Map<String,Id> entitlementNameIdMap = new Map<String,Id>();
        public Static Map<String, Id> entitlementDispIdMap = new Map<String,Id>();
        public Static Map<String,Set<String>> errorMessages = new Map<String,Set<String>>();
        //public Static boolean migrateData = false;
       
        public override void beforeInsert() {
             if(isActive('EntDetailReq_ValidateRequest') && !hasRun){
                 validateRequests((List<Core_Entitlement_Detail_Request__c>) Trigger.new );
             }         
        }
        public override void afterInsert() {
            if(isActive('EntDetailReq_Process_Approval') && !hasRun){
                hasRun = true;
                processApproval( (List<Core_Entitlement_Detail_Request__c>) Trigger.new , (Map<id,Core_Entitlement_Detail_Request__c>) Trigger.oldMap);   
            }        
        }
        public override void beforeUpdate() {
            if(isActive('EntDetailReq_ValidateRequest') && !hasRun){
                 validateRequests((List<Core_Entitlement_Detail_Request__c>) Trigger.new);
             }
        }
        public override void afterUpdate() {
            if(isActive('EntDetailReq_Process_Approval') && !hasRun){
                hasRun = true;
                processApproval( (List<Core_Entitlement_Detail_Request__c>) Trigger.new , (Map<id,Core_Entitlement_Detail_Request__c>) Trigger.oldMap);   
            }
        }
        public static void processApproval(List<Core_Entitlement_Detail_Request__c> newReqs, Map<id,Core_Entitlement_Detail_Request__c> oldReqsMap){
            Map<id,List<String>> errors = new Map<Id,List<String>>();        
            Map<String,Id> eRPMEnggsIdMap = new Map<String,Id>();  
            Map<String,Id> agsRolesIdMap = new Map<String,Id>(); 
            Set<Id> approvedReqIds = new Set<Id>();
            Set<String> eRPMEnggCodes = new Set<String>();
            Set<String> eRPMEnggCodesLst = new Set<String>();
            Set<String> agsRoles = new Set<String>();
            Set<String> agsRolesLst = new Set<String>();
            List<Core_ERPM_Engagement__c> newERPMEnggs = new List<Core_ERPM_Engagement__c>();
            List<Core_AGS_Role__c> newAGSRoles = new List<Core_AGS_Role__c>();
            List<Core_Entitlement__c> entitlementDetails = new List<Core_Entitlement__c>();
            Map<Id,String> entReqIdMap = new Map<Id,String>();
            List<Core_Entitlement_Detail_Request__c> approvedReqs = new List<Core_Entitlement_Detail_Request__c>();
            
            for(Core_Entitlement_Detail_Request__c newReq: newReqs){
                //if(newReq.Core_IsMigrated__c || (newReq.Core_Status_Nm__c=='Approved' && oldReqsMap!=null && oldReqsMap.get(newReq.Id).Core_Status_Nm__c=='Submitted')){
                if(newReq.Core_Status_Nm__c== Label.Core_Entitlement_Request_Approved && (oldReqsMap==null ||(oldReqsMap!=null && oldReqsMap.get(newReq.Id).Core_Status_Nm__c==Label.Core_Entitlement_Request_Submitted))){
                    approvedReqs.add(newReq);
                    eRPMEnggCodes.add(newReq.Core_ERPM_Engagement_Nm__c);
                    agsRoles.add(newReq.Core_AGS_Role_Nm__c);                            
                }            
            }
            if(approvedReqs.size() > 0){            
                if(eRPMEnggCodes.size() > 0){
                    //Fetch existing ERPM Engagement records
                    for(Core_ERPM_Engagement__c engg: [SELECT id,Name FROM Core_ERPM_Engagement__c WHERE Name IN :eRPMEnggCodes] ){
                        eRPMEnggsIdMap.put(engg.Name, engg.Id); 
                    }
                }
                if(agsRoles.size() > 0){
                    //Fetch existing AGS Role records
                    for(Core_AGS_Role__c agsRoleRec : [SELECT id,Name FROM Core_AGS_Role__c WHERE Name IN :agsRoles]){
                        agsRolesIdMap.put(agsRoleRec.Name, agsRoleRec.Id);                
                    }
                }
                for(Core_Entitlement_Detail_Request__c approvedReq: approvedReqs){
                    String enggCode = approvedReq.Core_ERPM_Engagement_Nm__c;
                    //Create a new ERPM Engagement record if not already exist.
                    if(!String.isEmpty(enggCode) && !eRPMEnggCodesLst.contains(enggCode) && !eRPMEnggsIdMap.containsKey(enggCode)){
                        Core_ERPM_Engagement__c engg = new Core_ERPM_Engagement__c();
                        engg.Name = enggCode;
                        //engg.Core_Technical_Engagement_Code__c = String.isEmpty(approvedReq.Core_Technical_Engagement_Cd__c)? enggCode:approvedReq.Core_Technical_Engagement_Cd__c ;
                        engg.Core_Technical_Engagement_Code__c = approvedReq.Core_Technical_Engagement_Cd__c;
                        engg.Core_Technical_DeDup_Number__c = approvedReq.Core_Technical_DeDup_Number__c;
                        engg.Core_Engagement_Type__c = approvedReq.Core_Engagement_Type__c;
                        newERPMEnggs.add(engg);
                        eRPMEnggCodesLst.add(enggCode);//To avoid creating Duplicate ERPM Engg records
                    }
                    String agsRole = approvedReq.Core_AGS_Role_Nm__c;
                    //Create a new AGS Role record if not already exist.
                    if(!String.isEmpty(agsRole) && !agsRolesLst.contains(agsRole) && !agsRolesIdMap.containsKey(agsRole)){
                        Core_AGS_Role__c newAgsRoleRec = new Core_AGS_Role__c();
                        newAgsRoleRec.Name = agsRole;
                        //newAgsRoleRec.Core_Technical_Name__c = String.IsEmpty(approvedReq.Core_Technical_Nm__c) ? agsRole : approvedReq.Core_Technical_Nm__c; 
                        newAgsRoleRec.Core_Technical_Name__c = approvedReq.Core_Technical_Nm__c;
                        newAGSRoles.add(newAgsRoleRec);
                        agsRolesLst.add(agsRole);//To avoid creating Duplicate AGS Role records
                    }
                }
                if(newERPMEnggs.size() > 0){
                    database.insert(newERPMEnggs,false);
                    //Add newly created ERPM Engagements to Map
                    for(Core_ERPM_Engagement__c engg: newERPMEnggs){
                        eRPMEnggsIdMap.put(engg.Name, engg.Id); 
                    }
                }
                if(newAGSRoles.size() > 0){
                    database.insert(newAGSRoles,false);
                    //Add newly created AGS Roles to Map
                    for(Core_AGS_Role__c agsRoleRec : newAGSRoles){
                        agsRolesIdMap.put(agsRoleRec.Name, agsRoleRec.Id);
                    }
                }
                //system.debug('agsRolesIdMap ==>'+agsRolesIdMap);            
                for(Core_Entitlement_Detail_Request__c newReq: approvedReqs){
                    //Create a new Entitlement Detail Record
                    Core_Entitlement__c newEntitlement = new Core_Entitlement__c();
                    newEntitlement.Name = newReq.Name;
                    newEntitlement.Core_Category__c = newReq.Core_Category_Nm__c;
                    newEntitlement.Core_Sub_Category__c = newReq.Core_Sub_Category_Nm__c;
                    newEntitlement.Core_Description__c = newReq.Core_Description_Txt__c;
                    newEntitlement.Core_Display_Name__c = newReq.Core_Display_Nm__c;
                    newEntitlement.Core_Help_Text__c = newReq.Core_Help_Txt__c;
                    newEntitlement.Core_Permission_Set_API_Nm__c = newReq.Core_Permission_Set_API_Nm__c;
                    newEntitlement.Core_Public_Group_API_Nm__c = newReq.Core_Public_Group_API_Nm__c;
                    newEntitlement.Core_IsActive__c = True;
                    newEntitlement.Core_AGS_Role_Id__c = (agsRolesIdMap.containsKey(newReq.Core_AGS_Role_Nm__c))? agsRolesIdMap.get(newReq.Core_AGS_Role_Nm__c) : null ;
                    newEntitlement.Core_ERPM_Engagement_Id__c = (eRPMEnggsIdMap.containsKey(newReq.Core_ERPM_Engagement_Nm__c)) ? eRPMEnggsIdMap.get(newReq.Core_ERPM_Engagement_Nm__c): null ;
                    newEntitlement.Core_Entitlement_Detail_Request__c = newReq.Id;
                    entitlementDetails.add(newEntitlement);                
                    if(newReq.Core_DisplayOnUI_Ind__c && !String.isEmpty(newReq.Core_Applicable_Profiles_Txt__c)){
                        system.debug('add vaalues to entReqIdMap');
                        entReqIdMap.put(newReq.Id, newReq.Name);
                    }//End of If DisplayOnUI                
                }
                system.debug('entitlementDetails===>'+entitlementDetails);
                if(entitlementDetails.size() > 0){
                    system.debug('before inserting entitlements');
                    database.saveresult[] result = database.insert(entitlementDetails, false);
                    for(database.saveresult res: result){
                        if(!res.isSuccess()){
                           system.debug(res.getErrors());                        
                        }
                    }
                    for(Core_Entitlement__c ent: entitlementDetails){
                        system.debug('entId ==>'+ent.Id);
                    }
                    system.debug('after inserting entitlements');
                    //If Diplay on UI check box is checked, add Entitlements to Picklist and create/update Entitlement Profile Access record.
                    system.debug('entReqIdMap===>'+entReqIdMap);
                    if(entReqIdMap.size() > 0){
                        system.debug('before addEntitlementToProfileAccessPickList');
                        addEntitlementToProfileAccessPickList(entReqIdMap);
                        //Core_EntitlementDetailReq_Queueable qJob = new Core_EntitlementDetailReq_Queueable(entReqIdMap);
                        //system.enqueueJob(qJob);
                        system.debug('after addEntitlementToProfileAccessPickList');
                    }
                }  
            }
        } 
        public static void validateRequests(List<Core_Entitlement_Detail_Request__c> newReqs){
            Set<String> permissionSetNames = new Set<String>();
            //Set<String> availablePermSets = new Set<String>();
            Set<String> publicGroupNames = new Set<String>();
            //Set<String> avialablePublicGroups = new Set<String>();
            Set<String> entitlementNames = new Set<String>();
            Set<String> entitlementDispNames = new Set<String>();
            Set<String> profileNames = new Set<String>();
            Set<String> availableProfileNames = new Set<String>();       
            Set<String> errorMsgs = new Set<String>();
            String errorMsg = '';
            Map<String,String>  entWithErrorsMap = new Map<String,string>();
            String allEntWithError;


            //String withoutERPMEnggRecordTypeId = '';
            Id withERPMEnggRecordTypeId = Schema.SObjectType.Core_Entitlement_Detail_Request__c.getRecordTypeInfosByDeveloperName().get(Label.Core_With_ERPM_Engagement_RecordType).getRecordTypeId();
            for(Core_Entitlement_Detail_Request__c newReq: newReqs){
                if(!String.isEmpty(newReq.Core_Permission_Set_API_Nm__c)){
                    permissionSetNames.add(newReq.Core_Permission_Set_API_Nm__c);   
                }
                if(!String.isEmpty(newReq.Core_Public_Group_API_Nm__c)){
                    publicGroupNames.add(newReq.Core_Public_Group_API_Nm__c);   
                }  
                entitlementNames.add(newReq.Name);
                entitlementDispNames.add(newReq.Core_Display_Nm__c);
                if(newReq.Core_DisplayOnUI_Ind__c && !String.isEmpty(newReq.Core_Applicable_Profiles_Txt__c)){
                    profileNames.addAll(newReq.Core_Applicable_Profiles_Txt__c.split(','));
                }
            }
            
            if(entitlementNames.size() > 0){
                for(Core_Entitlement__c entitlement : [SELECT id,Name,Core_Display_Name__c FROM Core_Entitlement__c WHERE Name IN :entitlementNames OR Core_Display_Name__c IN :entitlementDispNames ]){
                    entitlementNameIdMap.put(entitlement.Name, entitlement.Id);
                    entitlementDispIdMap.put(entitlement.Core_Display_Name__c,entitlement.Id );
                }
            }
            system.debug('entitlementNameIdMap===>'+entitlementNameIdMap);
            system.debug('entitlementDispIdMap===>'+entitlementDispIdMap);
            if(permissionSetNames.size() > 0){
                for(PermissionSet permSet : [SELECT id,Name FROM PermissionSet WHERE Name IN :permissionSetNames]){
                    availablePermSets.add(permSet.name); 
                }
            }
            if(publicGroupNames.size() > 0){
                for(Group grp: [SELECT id,DeveloperName FROM Group WHERE DeveloperName  IN :publicGroupNames]){
                    avialablePublicGroups.add(grp.DeveloperName);
                }
            }
            if(profileNames.size() > 0){
                //availableProfileNames
                for(Profile profile : [SELECT id,Name FROM Profile WHERE Name IN :profileNames]){
                    availableProfileNames.add(profile.Name);
                }
            }
            
           
            for(Core_Entitlement_Detail_Request__c newReq: newReqs){ 
                //errorMsg = '';
                String entWithErrors;
                //Validate Entitlement Name
                if(entitlementNameIdMap.containsKey(newReq.Name)){
                    entWithErrors = Label.Core_Entitlement_DuplicateName_Msg;
                   // newReq.addError(Label.Core_Entitlement_DuplicateName_Msg);  
                    //errorMsgs.add(Label.Core_Entitlement_DuplicateName_Msg);
                    //errorMsg = (String.isEmpty(errorMsg)?'Entitlement Name already exists.':errorMsg+'\n'+'Entitlement Name already exists.');
                }
                
                //Validate Display Entitlement Name
                if(entitlementDispIdMap.containsKey(newReq.Core_Display_Nm__c)){
                    if(entWithErrors != null){
                    entWithErrors = entWithErrors + ',' + Label.Core_Entitlement_DuplicateDispName_Msg;
                    }else{
                        entWithErrors = Label.Core_Entitlement_DuplicateDispName_Msg;
                    }
                    //newReq.addError(Label.Core_Entitlement_DuplicateDispName_Msg); 
                    //errorMsgs.add(Label.Core_Entitlement_DuplicateDispName_Msg);
                    //errorMsg = (String.isEmpty(errorMsg)?'Entitlement Display Name already exists.':errorMsg+'\n'+'Entitlement Display Name already exists.');
                }
                
                /*
                //if(!String.isEmpty(newReq.Core_ERPM_Engagement_Nm__c) || !String.isEmpty(newReq.Core_Engagement_Type__c) || !String.isEmpty(newReq.Core_Technical_Engagement_Cd__c) || !String.isEmpty(newReq.Core_Technical_DeDup_Number__c)){
                if(newReq.RecordTypeId == withERPMEnggRecordTypeId){
                    if(String.isEmpty(newReq.Core_ERPM_Engagement_Nm__c)){
                        newReq.addError(Label.Core_Entitlement_EnggName_Empty_Msg);
                        errorMsgs.add(Label.Core_Entitlement_EnggName_Empty_Msg);
                    }
                    if(String.isEmpty(newReq.Core_Engagement_Type__c)){
                        newReq.addError(Label.Core_Entitlement_EnggType_Msg);
                        errorMsgs.add(Label.Core_Entitlement_EnggType_Msg);
                    } 
                    if(String.isEmpty(newReq.Core_Technical_Engagement_Cd__c)){
                        newReq.addError(Label.Core_Entitlement_TechEnggCode_Msg);
                        errorMsgs.add(Label.Core_Entitlement_TechEnggCode_Msg);
                    } 
                }*/
                if(newReq.Core_Status_Nm__c== Label.Core_Entitlement_Request_Approved ){
                    if(newReq.Core_AGS_Role_Nm__c.toUpperCase()=='TBD'){
                      //    newReq.addError(Label.Core_Entitlement_AGSRole_Msg);
                        errorMsgs.add(Label.Core_Entitlement_AGSRole_Msg);  
                        if(entWithErrors != null){
                            entWithErrors = entWithErrors + ',' + Label.Core_Entitlement_AGSRole_Msg;
                            }else{
                                entWithErrors = Label.Core_Entitlement_AGSRole_Msg;
                            }
                    }
                    if(newReq.Core_Technical_Nm__c.toUpperCase()=='TBD'){
                        //newReq.addError(Label.Core_Entitlement_AGSRole_TechName_Msg);
                        errorMsgs.add(Label.Core_Entitlement_AGSRole_TechName_Msg);  
                        if(entWithErrors != null){
                            entWithErrors = entWithErrors + ',' + Label.Core_Entitlement_AGSRole_TechName_Msg;
                            }else{
                                entWithErrors = Label.Core_Entitlement_AGSRole_TechName_Msg;
                            }
                    }
                }
                if(!String.isEmpty(newReq.Core_Permission_Set_API_Nm__c) && !availablePermSets.contains(newReq.Core_Permission_Set_API_Nm__c)){                
                   // newReq.addError(Label.Core_Entitlement_PermSet_Msg);
                if(entWithErrors != null){
                            entWithErrors = entWithErrors + ',' + Label.Core_Entitlement_PermSet_Msg;
                            }else{
                                entWithErrors = Label.Core_Entitlement_PermSet_Msg;
                            }              
                    errorMsgs.add(Label.Core_Entitlement_PermSet_Msg);
                    //errorMsg = (String.isEmpty(errorMsg)?'Permission Set is not available.':errorMsg+'\n'+'Permission Set is not available.');        
                }
                //system.debug('GroupName ===>'+newReq.Core_Public_Group_API_Nm__c);
                if(!String.isEmpty(newReq.Core_Public_Group_API_Nm__c) && !avialablePublicGroups.contains(newReq.Core_Public_Group_API_Nm__c)){                
                    //newReq.addError(Label.Core_Entitlement_PublicGroup_Msg);
                    errorMsgs.add(Label.Core_Entitlement_PublicGroup_Msg);
                    //errorMsg = (String.isEmpty(errorMsg)?'Public group is not available.':errorMsg+'\n'+'Public group is not available.');   
                        if(entWithErrors != null){
                            entWithErrors = entWithErrors + ',' + Label.Core_Entitlement_PublicGroup_Msg;
                            }else{
                                entWithErrors = Label.Core_Entitlement_PublicGroup_Msg;
                            }               
                }
                if(newReq.Core_DisplayOnUI_Ind__c){
                    if(String.isEmpty(newReq.Core_Applicable_Profiles_Txt__c)){
                      //  newReq.addError(Label.Core_Entitlement_ProfilesBlank_Msg);
                      if(entWithErrors != null){
                            entWithErrors = entWithErrors + ',' + Label.Core_Entitlement_ProfilesBlank_Msg;
                            }else{
                                entWithErrors = Label.Core_Entitlement_ProfilesBlank_Msg;
                            }
                        errorMsgs.add(Label.Core_Entitlement_ProfilesBlank_Msg);
                    }else{
                        String nonExistingProfiles = '';
                        for(String profileName : newReq.Core_Applicable_Profiles_Txt__c.split(',')){
                            if(!availableProfileNames.contains(profileName)){
                                nonExistingProfiles = (String.isEmpty(nonExistingProfiles)) ? profileName: nonExistingProfiles+', '+profileName;
                            }
                        }
                        if(!String.isEmpty(nonExistingProfiles)){
                        //    newReq.addError(nonExistingProfiles+' '+Label.Core_Entitlement_ProfilesNotFound_Msg);
                        if(entWithErrors != null){
                            entWithErrors = entWithErrors + ',' + Label.Core_Entitlement_ProfilesNotFound_Msg;
                            }else{
                                entWithErrors = Label.Core_Entitlement_ProfilesNotFound_Msg;
                            }
                            errorMsgs.add(nonExistingProfiles+' '+Label.Core_Entitlement_ProfilesNotFound_Msg);
                        } 
                    }                
                }//END of Display on UI check
                if(errorMsgs.size() > 0){
                    addErrorMessage(newReq.Name, errorMsgs );
                }
                if(entWithErrors != null){
                    entWithErrorsMap.put(newReq.Name,entWithErrors);
                    if(allEntWithError != null){
                        allEntWithError = allEntWithError + ','+ newReq.Name;
                    }else{
                        allEntWithError = newReq.Name;
                    }
                }
            }
            
            if(!entWithErrorsMap.isEmpty() && entWithErrorsMap.size() >0){
                for(Core_Entitlement_Detail_Request__c newReq: newReqs){ 
                    String defaultErrorStr = 'Record not processed due to error in '+ allEntWithError;
                    if(entWithErrorsMap.containsKey(newReq.Name)){
                        newReq.addError(entWithErrorsMap.get(newReq.Name));
                    }else{
                        newReq.addError(defaultErrorStr);
                    }
                }
            }
        }
        private static void addErrorMessage(String entName, Set<String> msgs){
            if(errorMessages.containsKey(entName)){
                errorMessages.get(entName).addAll(msgs);
            }else{
                errorMessages.put(entName, msgs);
            }
        }
        
        @Future(callout=True)
        public static void addEntitlementToProfileAccessPickList(Map<Id,String> entReqIdMap){
            // addEntitlementToProfileAccessPickList(entlmntNmsTobeAddedToPicklst, profileEntitlementMap);            
            try {  
                system.debug('entering addEntitlementToProfileAccessPickList');
                Set<String> alreadyAddedValues = new Set<String>();
                //String picklistapiname = 'Core_Entitlement_Profile_Access__c.Core_Entitlements_Allowed__c';   
                String picklistapiname = Label.Core_Entitlement_ProfileAccess_PicklistFld_APIName;
                MetadataAPIService.MetadataPort service = new MetadataAPIService.MetadataPort();               
                service.SessionHeader = new MetadataAPIService.SessionHeader_element();
                service.SessionHeader.sessionId = UserInfo.getSessionId();
                
                List<String> entitlementNames = entReqIdMap.values();
                
                MetadataAPIService.CustomField customField = (MetadataAPIService.CustomField) service.readMetadata('CustomField', new String[] { picklistapiname}).getRecords()[0];
                //system.debug('customField===>'+customField);
                //List<MetadataAPIService.CustomValue> objCustomValues = new List<MetadataAPIService.CustomValue>();
                for(MetadataAPIService.CustomValue objCustomValue : customField.valueSet.valueSetDefinition.value){
                    if(entitlementNames.contains(objCustomValue.fullName)){//Check if entitlement name is already added to the picklist
                        alreadyAddedValues.add(objCustomValue.fullName); 
                    }
                }
                for(String entlName : entitlementNames) {
                    //Add new Entitlement Name if it is not already added to the pick list
                    if(!alreadyAddedValues.contains(entlName)){
                        MetadataAPIService.CustomValue objCustomValue = new MetadataAPIService.CustomValue();
                        objCustomValue.fullName = entlName;
                        objCustomValue.label = entlName;
                        objCustomValue.isActive = True;
                        objCustomValue.default_x = false;
                        //MetadataService.ValueSet vs = customField.valueSet;
                        customField.valueSet.valueSetDefinition.value.add(objCustomValue);  
                    }
                } 
                // Update Picklist metadata
                List<MetadataAPIService.SaveResult> lstResults = service.updateMetadata( new MetadataAPIService.Metadata[] { customField });
                createOrUpdateProfileAccess(entReqIdMap.keySet());
            } catch (Exception ce) {
                system.debug('Error===>'+ce.getCause());
                system.debug('Error Line#===>'+ce.getLineNumber()+';;'+ce.getMessage()+';;;'+ce.getStackTraceString());
            }
        }
        public static void createOrUpdateProfileAccess(Set<Id> entlmntIdsTobeAddedToPicklst){
            Map<String,Set<String>> entProfileMap = new Map<String,Set<String>>();
            Set<String> entlNames = new Set<String>();
            Integer MAX_SELECTED_ENTITLEMENT_SIZE = Integer.valueOf(Label.Core_Entitlement_PicklistLimit); // picklist selected values limit
                 
            Map<String,Core_Entitlement_Profile_Access__c> profileAccMap = new Map<String,Core_Entitlement_Profile_Access__c>();
            List<Core_Entitlement_Profile_Access__c> profileAccTobeUpserted = new List<Core_Entitlement_Profile_Access__c>();
            Integer entlmentSize = 0;
            //List<Core_Entitlement_Profile_Access__c> profileAccTobeInserted = new List<Core_Entitlement_Profile_Access__c>();
            Map<String,Id> profileNameMap = new Map<String,Id>();
            if(entlmntIdsTobeAddedToPicklst.size() > 0) {
                for(Core_Entitlement_Detail_Request__c entDetReq: [SELECT Id,Name,Core_Applicable_Profiles_Txt__c,Core_DisplayOnUI_Ind__c FROM Core_Entitlement_Detail_Request__c WHERE Id IN :entlmntIdsTobeAddedToPicklst]){
                    if(entDetReq.Core_DisplayOnUI_Ind__c && !String.isEmpty(entDetReq.Core_Applicable_Profiles_Txt__c)){
                        entlNames.add(entDetReq.Name);
                        for(String profName: entDetReq.Core_Applicable_Profiles_Txt__c.split(',') ){
                            if(entProfileMap.containsKey(profName)){
                                entProfileMap.get(profName).add(entDetReq.Name);
                            }else{
                                entProfileMap.put(profName, new Set<String>{entDetReq.Name}); 
                            }   
                        }                        
                    }
                }
                if(entProfileMap.size() > 0){               
                    for(Profile prof : [SELECT id,Name FROM Profile WHERE Name IN :entProfileMap.keySet()]){
                        profileNameMap.put(prof.Name, prof.Id);
                    }
                    for(Core_Entitlement_Profile_Access__c profileAccRec : [SELECT id,Name,Core_Entitlements_Allowed__c FROM Core_Entitlement_Profile_Access__c 
                                                                            WHERE Name IN :entProfileMap.keySet() ORDER By CreatedDate DESC]){
                                                                                if(!profileAccMap.containsKey(profileAccRec.Name)){
                                                                                   //Add latest record to the map, when multiple records are already available.
                                                                                   profileAccMap.put(profileAccRec.Name, profileAccRec); 
                                                                                }                                                                            
                                                                            } 
                    for(String profileName : entProfileMap.keySet()){
                        String entNames = '';
                        if(profileAccMap.containsKey(profileName)){
                            //MAX_SELECTED_ENTITLEMENT_SIZE
                            Core_Entitlement_Profile_Access__c profAccess = profileAccMap.get(profileName);
                            entlmentSize = String.isEmpty(profAccess.Core_Entitlements_Allowed__c) ? 0 :profAccess.Core_Entitlements_Allowed__c.split(';').size();
                            if(entlmentSize >= MAX_SELECTED_ENTITLEMENT_SIZE){  //If already selected entitlements size reached the limit, create a new Profile Access record                         
                                Core_Entitlement_Profile_Access__c newProfAcc1 = createProfileAccess(profileName,entProfileMap.get(profileName),profileNameMap); 
                                if(newProfAcc1!=null){
                                    profileAccTobeUpserted.add(newProfAcc1);
                                }
                            }else if ((MAX_SELECTED_ENTITLEMENT_SIZE - entlmentSize ) >= entProfileMap.get(profileName).size()){ 
                                //If number of entitlements to be added is less than the available limit in the record
                                //suppose if the record is already having 90 picklist values and 10 more to be added newly .. update the existing record
                                for(String entlmntName: entProfileMap.get(profileName) ){
                                    entNames = (String.isEmpty(entNames)) ? entlmntName: entNames+';'+entlmntName;
                                }
                                if(!String.isEmpty(entNames)){
                                    //Core_Entitlement_Profile_Access__c profAcc = new Core_Entitlement_Profile_Access__c();
                                    profileAccTobeUpserted.add(new Core_Entitlement_Profile_Access__c(Id=profAccess.Id, Core_Entitlements_Allowed__c = profAccess.Core_Entitlements_Allowed__c+';'+entNames));
                                }
                            }else if((MAX_SELECTED_ENTITLEMENT_SIZE - entlmentSize) < entProfileMap.get(profileName).size()){
                                //If number of entitlements to be added is more than the available limit in the record
                                //suppose if the record is already having 90 picklist values and 20 more to be added newly .. 
                                //Add 10 values to the existing record and create a new record for the remaining 10 values
                                Integer availableSize = (MAX_SELECTED_ENTITLEMENT_SIZE - entlmentSize);
                                Set<String> notAddedEntNames =  new Set<String>();
                                Integer i=0;
                                entNames = '';
                                for(String entlmntName: entProfileMap.get(profileName) ){
                                    ++i;
                                    if(i<=availableSize){
                                        entNames = (String.isEmpty(entNames)) ? entlmntName: entNames+';'+entlmntName; 
                                    }else{
                                        notAddedEntNames.add(entlmntName);
                                    }                                
                                }
                                if(!String.isEmpty(entNames)){                               
                                    profileAccTobeUpserted.add(new Core_Entitlement_Profile_Access__c(Id=profAccess.Id, Core_Entitlements_Allowed__c = profAccess.Core_Entitlements_Allowed__c+';'+entNames));
                                }
                                if(notAddedEntNames.size() > 0){
                                    Core_Entitlement_Profile_Access__c newProfAcc2 = createProfileAccess(profileName,notAddedEntNames,profileNameMap); 
                                    if(newProfAcc2!=null){
                                        profileAccTobeUpserted.add(newProfAcc2);
                                    }
                                }
                            }
                        }else{
                            //If Profile access record is not available, create a new one
                            if(profileNameMap.containsKey(profileName)){                           
                                Core_Entitlement_Profile_Access__c newProfAcc3 =  createProfileAccess(profileName,entProfileMap.get(profileName),profileNameMap);
                                if(newProfAcc3!=null){
                                    profileAccTobeUpserted.add(newProfAcc3);
                                }
                            }
                        }
                    } //END of entProfileMap FOR     
                    if(profileAccTobeUpserted.size() > 0){
                        database.UpsertResult[] results = database.upsert(profileAccTobeUpserted, false);
                        for(database.UpsertResult res: results){
                            if(!res.isSuccess()){
                                for(database.Error error:res.getErrors()){
                                    system.debug('Error ==>'+error);
                                }
                            }
                        }
                    }
                } //END of entProfileMap IF           
            } 
        }//End of Method 
        
        public static Core_Entitlement_Profile_Access__c createProfileAccess(String profileName, Set<String> entlmentNames, Map<String,Id> profileNameMap){
            if(profileNameMap.containsKey(profileName) && entlmentNames.size() > 0){
                String entNames = '';
                for(String entName : entlmentNames){
                    entNames = String.isEmpty(entNames) ? entName:entNames+';'+entName;
                }
                if(!String.isEmpty(entNames)){
                    Core_Entitlement_Profile_Access__c profileAcc = new Core_Entitlement_Profile_Access__c();
                    profileAcc.Name = profileName;
                    profileAcc.Core_Entitlements_Allowed__c = entNames;
                    profileAcc.Core_Profile_Id__c = profileNameMap.get(profileName);  
                    return profileAcc;
                }
            }
            return null;
        }
        
        /**************************** REST API Call to Migrate Data tp DEVINT Starts ******************************************/
        /*
        public static AccessTokenResponse getAccessToken(List<Core_Entitlement_Migration_Details__mdt> migrationMdts){
            
            AccessTokenResponse accessToken = new AccessTokenResponse();
            if(migrationMdts.size() > 0){
                String clientId = migrationMdts[0].Core_Client_Id__c;
                String clientSecret = migrationMdts[0].Core_Consumer_Key__c; 
                String username = migrationMdts[0].Core_UserName__c;
                String password = migrationMdts[0].Core_Password__c;  
                String reqbody = 'grant_type=password&client_id='
                    +clientId+'&client_secret='
                    +clientSecret+'&username='
                    +username+'&password='+password;
                
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setBody(reqbody);
                req.setMethod('POST');
                req.setEndpoint(migrationMdts[0].Core_AccessToken_URL__c);
                HttpResponse res = h.send(req);
                accessToken = (AccessTokenResponse) JSON.deserialize(res.getBody(), AccessTokenResponse.class);
            }
            return accessToken;
        }
        
        public static void migrateData(Set<Id> reqIds, String targetSys){
            if(reqIds.size() > 0){       
                List<Core_Entitlement_Migration_Details__mdt> migrationMdts = [SELECT MasterLabel,Core_AccessToken_URL__c,Core_API_Endpoint_URL__c,
                                                                               Core_Client_Id__c,Core_Consumer_Key__c,Core_Organization_Id__c,
                                                                               Core_Password__c,Core_UserName__c
                                                                               FROM Core_Entitlement_Migration_Details__mdt WHERE MasterLabel= :targetSys];
                if(migrationMdts.size() > 0){
                    AccessTokenResponse accessToken = getAccessToken(migrationMdts);
                    if(accessToken!=null){
                        Http h = new Http();
                        HttpRequest req = new HttpRequest();
                        req.setHeader('Authorization','Bearer ' + accessToken.access_token);
                        req.setHeader('Content-Type','application/json');
                        req.setHeader('accept','application/json');
                        req.setMethod('POST');
                        req.setEndpoint(migrationMdts[0].Core_API_Endpoint_URL__c);
                        req.setBodyAsBlob(Blob.valueOf(getDataJSON(reqIds)));
                        //req.setBody(Blob.valueOf(getDataJSON(reqIds)));
                        HttpResponse res = h.send(req);   
                        //system.debug('Response ==>'+res.getBody());
                    }  
                }
            }   
        }
        public static string getDataJSON(Set<Id> reqIds){
            List<EntitlementDetailRequest> reqs = new List<EntitlementDetailRequest>();
            List<Core_Entitlement_Detail_Request__c> entDetReqs = [SELECT Name,Core_Display_Nm__c,Core_Category_Nm__c, Core_Sub_Category_Nm__c, Core_Description_Txt__c, Core_Help_Txt__c, Core_ERPM_Engagement_Nm__c, Core_Engagement_Type__c, Core_Technical_Engagement_Cd__c, Core_Technical_DeDup_Number__c, Core_AGS_Role_Nm__c, Core_Technical_Nm__c, Core_Permission_Set_API_Nm__c, Core_Public_Group_API_Nm__c, Core_DisplayOnUI_Ind__c, Core_Applicable_Profiles_Txt__c  FROM Core_Entitlement_Detail_Request__c WHERE Id IN :reqIds]; 
            //List<Core_Integration_Outbound_Message__c> obms = new List<Core_Integration_Outbound_Message__c>();
            if(entDetReqs.size() > 0 ){                
                String tags = '';            
                for(Core_Entitlement_Detail_Request__c entDetReq : entDetReqs){
                    EntitlementDetailRequest req = new EntitlementDetailRequest();
                    //tags = String.isEmpty(tags) ? entDetReq.Name: tags+', '+entDetReq.Name;
                    req.Name = entDetReq.Name;
                    req.Core_Display_Name = entDetReq.Core_Display_Nm__c;
                    req.Core_Category = entDetReq.Core_Category_Nm__c;
                    req.Core_Sub_Category =  entDetReq.Core_Sub_Category_Nm__c;
                    req.Core_Description = entDetReq.Core_Description_Txt__c;
                    req.Core_Help_Text = entDetReq.Core_Help_Txt__c;
                    req.Core_ERPM_Engagement_Id = entDetReq.Core_ERPM_Engagement_Nm__c;
                    req.Core_Engagement_Type = entDetReq.Core_Engagement_Type__c;
                    req.Core_Technical_Engagement_Code = entDetReq.Core_Technical_Engagement_Cd__c;
                    req.Core_Technical_DeDup_Number = entDetReq.Core_Technical_DeDup_Number__c;
                    req.Core_AGS_Role_Id = entDetReq.Core_AGS_Role_Nm__c;
                    req.Core_Technical_Name = entDetReq.Core_Technical_Nm__c;
                    req.Core_Permission_Set_API_Nm = entDetReq.Core_Permission_Set_API_Nm__c;
                    req.Core_Public_Group_API_Nm = entDetReq.Core_Public_Group_API_Nm__c;
                    req.Core_DisplayOnUI = entDetReq.Core_DisplayOnUI_Ind__c;
                    req.Core_Applicable_Profiles = entDetReq.Core_Applicable_Profiles_Txt__c;
                    reqs.add(req);
                }
            }
            return (reqs.size() >0) ? JSON.serialize(reqs) : '';
            
        }
        
        public class AccessTokenResponse {
            public String access_token {set; get;}
            public String instance_url {set; get;}
            public String id {set; get;}
            public String token_type {set; get;}
            public String issued_at {set; get;}
            public String signature {set; get;}
        }
        public class EntitlementDetailRequest {
            public String Name {set; get;}
            public String Core_Display_Name {set; get;}
            public String Core_Category {set; get;}
            public String Core_Sub_Category {set; get;}
            public String Core_Description {set; get;}
            public String Core_Help_Text {set; get;}
            public String Core_ERPM_Engagement_Id {set; get;}
            public String Core_Engagement_Type {set; get;}
            public String Core_Technical_Engagement_Code {set; get;}
            public String Core_Technical_DeDup_Number {set; get;}
            public String Core_AGS_Role_Id {set; get;}
            public String Core_Technical_Name {set; get;}
            public String Core_Permission_Set_API_Nm {set; get;}
            public String Core_Public_Group_API_Nm {set; get;}
            public boolean Core_DisplayOnUI {set; get;}
            public String Core_Applicable_Profiles {set; get;}
        }
        */
         /**************************** REST API Call to Migrate Data to DEVINT Ends ******************************************/
    }