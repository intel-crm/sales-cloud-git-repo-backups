public without sharing class Core_MDF_SendEmailForVAT {
    @InvocableMethod
    public static void determineRecipients(List<initialInputs> processInput){
        List<initialInputs> accountManagersList = new List<initialInputs>();
        List<initialInputs> paymentAdminsList = new List<initialInputs>();
        try{
            for(initialInputs inputs : processInput){
                if(inputs.reason == 'AccountManager'){
                    accountManagersList.add(inputs);
                }
                if(inputs.reason == 'PaymentAdmin'){
                    System.debug('inside first if');
                    paymentAdminsList.add(inputs);
                }  
            }
            
            if(accountManagersList != NULL && accountManagersList.Size() > 0){
                toAccountManagerUsers(accountManagersList);
            }
            if(paymentAdminsList != NULL && paymentAdminsList.Size() > 0){
                toPaymentAdminUsers(paymentAdminsList);
            }
        }
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
    
    public static void toAccountManagerUsers(List<initialInputs> accMgrUserList){
        Set<Id> accIdSet = new Set<Id>();
        Set<Id> programIdSet = new Set<Id>();       
        Map<String,Id> geoGroupIdMap = new Map<String,Id>();
        String pgmSubRegion;
        String pgmRegion;
        String accCPSubGeo;
        String accCPGeo;
        try{
            for(initialInputs inputs : accMgrUserList){
                if(inputs.accountId != NULL){
                    accIdSet.add(inputs.accountId);
                }
                if(inputs.programId != NULL){
                    programIdSet.add(inputs.programId);
                }                
            }
            
            if(accIdSet != NULL && programIdSet != NULL){
                for(Core_MDF_Partner_Group_Mapping__c pgm : [SELECT Id, Core_MDF_Group_Id__c, Core_MDF_Sub_Region_cd__c, Core_MDF_Account__c,
                                                             Core_MDF_Channel_Program__c, Core_MDF_Region_cd__c 
                                                             FROM Core_MDF_Partner_Group_Mapping__c
                                                             WHERE Core_MDF_Type_of_Access__c = 'INTERNAL' AND
                                                             Core_MDF_Account__c IN: accIdSet AND
                                                             Core_MDF_Channel_Program__c IN: programIdSet])
                	{
                        if(pgm.Core_MDF_Region_cd__c == 'ASMO' && pgm.Core_MDF_Sub_Region_cd__c != NULL)
                        {
                            pgmSubRegion = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c + pgm.Core_MDF_Sub_Region_cd__c;
                            geoGroupIdMap.put(pgmSubRegion,pgm.Core_MDF_Group_Id__c);
                        }else{
                            pgmRegion = (String)pgm.Core_MDF_Account__c + (String)pgm.Core_MDF_Channel_Program__c + pgm.Core_MDF_Region_cd__c;
                            geoGroupIdMap.put(pgmRegion,pgm.Core_MDF_Group_Id__c);
                        }                    
                	}
                }

        	
            List<Core_MDF_DetermineEmailRecipients.InitialInputs> inputList = new List<Core_MDF_DetermineEmailRecipients.InitialInputs>();
            
            for(initialInputs input : accMgrUserList){
                List<String> groupIdList = new List<String>();
                accCPSubGeo = input.accountId + (String)input.programId + input.region + input.subRegion;
                accCPGeo = input.accountId + (String)input.programId + input.region;
                
                Core_MDF_DetermineEmailRecipients.InitialInputs params = new Core_MDF_DetermineEmailRecipients.InitialInputs();                
                params.recordId = input.recordId;
                params.templateName = input.templateName;
                params.sendDiff = input.sendDiff;
                params.permissionSetName = input.permissionSetName;
                params.recipients = input.recipients;
                if(geoGroupIdMap.containsKey(accCPSubGeo) && geoGroupIdMap.get(accCPSubGeo) != NULL){
                    groupIdList.add(geoGroupIdMap.get(accCPSubGeo));
                }
                if(geoGroupIdMap.containsKey(accCPGeo) && geoGroupIdMap.get(accCPGeo) != NULL){
                    groupIdList.add(geoGroupIdMap.get(accCPGeo));
                }
                if(groupIdList != NULL && groupIdList.Size() > 0){
                    params.groupId = String.join(groupIdList, ';');
                    inputList.add(params);
                }
                
            }
            if(inputList != NULL && inputList.Size() > 0){
                Core_MDF_DetermineEmailRecipients.determineRecipients(inputList);
            }
            
        }
        
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
    
    public static void toPaymentAdminUsers(List<initialInputs> paymentAdminUserList){
        Set<String> programNameSet = new Set<String>();
        Set<String> regionSet = new Set<String>();
        Map<String,Id> geoGroupIdMap = new Map<String,Id>();
        String progGeoMdtSubRegion;
        String progGeoMdtRegion;
        String progSubGeo;
        String progGeo;
        try{
            for(initialInputs inputs : paymentAdminUserList){
                if(inputs.programName != NULL){
                    programNameSet.add(inputs.programName);
                }
                if(inputs.region != NULL){
                    regionSet.add(inputs.region);
                }                
            }
            
            if(programNameSet != NULL && regionSet != NULL){
                for(Core_MDF_ProgramGeoGroupMap__mdt progGeoMdt : [SELECT Id,Core_MDF_Program__c, Core_MDF_Payment_Admin_Queue_Id__c, 
                                                                   Core_MDF_Region__c, Core_MDF_Sub_Region__c 
                                                                   FROM Core_MDF_ProgramGeoGroupMap__mdt
                                                                   WHERE Core_MDF_Program__c IN: programNameSet AND 
                                                                   Core_MDF_Region__c IN: regionSet AND 
                                                                   Core_MDF_Payment_Admin_Queue_Id__c != NULL])
                {
                        if(progGeoMdt.Core_MDF_Sub_Region__c != NULL)
                        {
                            progGeoMdtSubRegion = (String)progGeoMdt.Core_MDF_Program__c + (String)progGeoMdt.Core_MDF_Region__c + progGeoMdt.Core_MDF_Sub_Region__c;
                            geoGroupIdMap.put(progGeoMdtSubRegion,progGeoMdt.Core_MDF_Payment_Admin_Queue_Id__c);
                        }else{
                            progGeoMdtRegion = (String)progGeoMdt.Core_MDF_Program__c + (String)progGeoMdt.Core_MDF_Region__c;
                            geoGroupIdMap.put(progGeoMdtRegion,progGeoMdt.Core_MDF_Payment_Admin_Queue_Id__c);
                        }                    
                	}
                }

        	
            List<Core_MDF_GenericClassToSendMail.MailParams> settingMailParameters = new List<Core_MDF_GenericClassToSendMail.MailParams>();
            
            for(initialInputs input : paymentAdminUserList){
                List<String> groupIdList = new List<String>();
                progSubGeo = input.ProgramName + input.region + input.subRegion;
                progGeo = input.ProgramName + input.region;
                
                Core_MDF_GenericClassToSendMail.MailParams params = new Core_MDF_GenericClassToSendMail.MailParams();                
                params.recordId = input.recordId;
                params.templateName = input.templateName;
                params.sendDiff = input.sendDiff;
                
                if(geoGroupIdMap.containsKey(progSubGeo) && geoGroupIdMap.get(progSubGeo) != NULL){
                    groupIdList.add(geoGroupIdMap.get(progSubGeo));
                }
                if(geoGroupIdMap.containsKey(progGeo) && geoGroupIdMap.get(progGeo) != NULL){
                    groupIdList.add(geoGroupIdMap.get(progGeo));
                }
                if(groupIdList != NULL && groupIdList.Size() > 0){
                    params.groupId = String.join(groupIdList, ';');
                    settingMailParameters.add(params);
                }
                
            }
            if(settingMailParameters != NULL && settingMailParameters.Size() > 0){
                Core_MDF_GenericClassToSendMail.sendEmailMethod(settingMailParameters);
            }            
        }
        
        catch(Exception e){Core_MDF_CCP_UtilityClass.logError(e);} 
    }
    
    public class InitialInputs{        
        @InvocableVariable(label = 'AccountId')
        public Id accountId;
        
        @InvocableVariable(label = 'ProgramId')
        public Id programId;
        
        @InvocableVariable(label = 'ProgramName')
        public string programName;
        
        @InvocableVariable(label = 'Region')
        public string region;
        
        @InvocableVariable(label = 'SubRegion')
        public string subRegion;
        
        @InvocableVariable(label = 'Reason' required = true)
        public string reason;  
        
        @InvocableVariable(label = 'recordId' required = true)
        public Id recordId;
                
        @InvocableVariable(label = 'templateDeveloperName' required = true)
        public String templateName;
        
        @InvocableVariable(label = 'sendDiff')
        public Boolean sendDiff = TRUE;
        
        @InvocableVariable(label = 'PermissionSet')
        public String permissionSetName;
        
        @InvocableVariable(label = 'Recipients')
        public string recipients;
        
    }
}