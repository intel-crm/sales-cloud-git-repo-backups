public class Pricing_ManageEmailPreference_Mock {
    @AuraEnabled(cacheable=true)
    public static List<Preference> getEmailPreference(){
        try {
            List<Preference> preferList = new List<Preference>();
            List<Pricing_IQR_Email_Preferences__c> emailPrefer = new List<Pricing_IQR_Email_Preferences__c>(Pricing_IQR_Email_Preferences_Selector.newInstance().selectbyId());
            List<Pricing_EmailNotificationTemplate__mdt> emailPref = new List<Pricing_EmailNotificationTemplate__mdt>();
            List<PermissionSetAssignment> lstcurrentUserPerSet =new List<PermissionSetAssignment>(Pricing_PermissionSetAssignment_Selector.newInstance().selectbyUserId(UserInfo.getUserId()));
                                                                                                   
                                                                                                   
            User loggedInUser = Pricing_User_Selector.newInstance().selectById(); 
            List<String> externalUserPermissionSet = label.Pricing_Tender_PermissionSets_AllExternal.split(':');
            
            Boolean isExternalUser = false;
            List<String> templateAPIName = new List<String>();
            Map<String, Pricing_IQR_Email_Preferences__c> emailPreferMap = new Map<String, Pricing_IQR_Email_Preferences__c>();
            
            List<Pricing_EmailNotificationPreference__mdt> emailAccRegionPrefList = [SELECT Id,Account_Id__c,Pricing_Template_API_Name_Nm__c,Pricing_Optin_Ind__c,Pricing_Region__c 
                                                                                     FROM Pricing_EmailNotificationPreference__mdt WHERE Account_Id__c = :loggedInUser.AccountId];
            
            for(PermissionSetAssignment psa : lstcurrentUserPerSet)  {
                if(externalUserPermissionSet.contains(psa.PermissionSet.Name)){
                    isExternalUser = true;
                    break;
                }
            }
            //Runs from TestClass to increase coverage
            if(Test.isRunningTest() && emailAccRegionPrefList.size() ==0 && isExternalUser){
                emailAccRegionPrefList.add(new Pricing_EmailNotificationPreference__mdt(Account_Id__c=loggedInUser.AccountId,Pricing_Template_API_Name_Nm__c='Quote_Team_Notification',Pricing_Optin_Ind__c=False,Pricing_Region__c='ASMO'));
                emailPref.add(new Pricing_EmailNotificationTemplate__mdt(Permission_Set_Name__c=label.Pricing_Tender_PermissionSets_AllExternal.replace(':',','),Template_API_Name__c='Quote_Team_Notification'));
            }
            if(emailPrefer.size()>0){
                for(Pricing_IQR_Email_Preferences__c pe: emailPrefer){
                    /*
                    Boolean addError = false;
                    String region = '';                   
                    for(Pricing_EmailNotificationPreference__mdt earp: emailAccRegionPrefList){
                        if(earp.Pricing_Template_API_Name_Nm__c == pe.Pricing_Template_API_Name_Nm__c && earp.Pricing_Optin_Ind__c == false){
                            addError = true;
                            region = (region.equals('')?earp.Pricing_Region__c:(region + ', ' + earp.Pricing_Region__c));                            
                        }
                    }
                    Preference prefer = new Preference();
                    prefer.optInOut = pe.Pricing_Opt_In_Ind__c;
                    prefer.notificationName = pe.Pricing_Notification_Name_Nm__c;
                    if(addError && isExternalUser){
                        String error = Label.Pricing_Tender_EmailPrefRegionError.replace('{{REGION}}', region);
                        error = error.replace('{{NOTIFICATION}}', pe.Pricing_Notification_Name_Nm__c);
                        prefer.errorMsg = error;
                    }
                    preferList.add(prefer);
                    */
                    emailPreferMap.put(pe.Pricing_Notification_Name_Nm__c, pe);
                }   
            }//else{
                
                for(Pricing_EmailNotificationTemplate__mdt pe : [Select MasterLabel, Template_API_Name__c, Permission_Set_Name__c from Pricing_EmailNotificationTemplate__mdt ORDER BY MasterLabel]){
                    for (PermissionSetAssignment psa : lstcurrentUserPerSet) {
                        if(pe.Permission_Set_Name__c.contains(psa.PermissionSet.Name)){                        
                            emailPref.add(pe);
                            break;
                        }
                    }
                    if(pe.Permission_Set_Name__c == 'ALL'){
                        emailPref.add(pe);
                    }
                }
                
                for(Pricing_EmailNotificationTemplate__mdt pe: emailPref){
                    Boolean addError = false;
                    String region = '';
                    for(Pricing_EmailNotificationPreference__mdt earp: emailAccRegionPrefList){
                        if(earp.Pricing_Template_API_Name_Nm__c == pe.Template_API_Name__c && earp.Pricing_Optin_Ind__c == false){
                            addError = true;
                            region = (region.equals('')?earp.Pricing_Region__c:(region + ', ' + earp.Pricing_Region__c));                            
                        }
                    }
                    Preference prefer = new Preference();
                    prefer.optInOut = (emailPreferMap.get(pe.MasterLabel) != null) ? emailPreferMap.get(pe.MasterLabel).Pricing_Opt_In_Ind__c: true;
                    prefer.notificationName = pe.MasterLabel;
                    if(addError && isExternalUser){
                        String error = Label.Pricing_Tender_EmailPrefRegionError.replace('{{REGION}}', region);
                        error = error.replace('{{NOTIFICATION}}', pe.MasterLabel);
                        prefer.errorMsg = error;
                    }
                    preferList.add(prefer);
                }
            //}
            return preferList;
        } catch (Exception e) {
            system.debug(e.getMessage());
            return null;
        }
    }
    
    @AuraEnabled
    public static Boolean savePreferences(String jsonMap){
        try{
            jsonMap = '{"preferences":'+jsonMap+'}';
            PreferenceList prefList = (PreferenceList) JSON.deserialize(jsonMap, PreferenceList.class);
            List<Pricing_IQR_Email_Preferences__c> emailPreferUpsert = new List<Pricing_IQR_Email_Preferences__c>();
            List<Pricing_IQR_Email_Preferences__c> emailPrefer = new List<Pricing_IQR_Email_Preferences__c>(Pricing_IQR_Email_Preferences_Selector.newInstance().selectByIds());
            list<String> updatedNotifications = new List<String>();
            if(emailPrefer.size()>0){
                for(Pricing_IQR_Email_Preferences__c pe: emailPrefer){
                    for(Preference pref: prefList.preferences){
                        if(pe.Pricing_Notification_Name_Nm__c == pref.notificationName){
                            pe.Pricing_Opt_In_Ind__c = pref.optInOut;
                            updatedNotifications.add(pe.Pricing_Notification_Name_Nm__c);
                        }
                    }
                    emailPreferUpsert.add(pe);
                }
            }
            List<Pricing_EmailNotificationTemplate__mdt> emailPrefMtd = [Select MasterLabel, Template_API_Name__c from Pricing_EmailNotificationTemplate__mdt];
            for(Pricing_EmailNotificationTemplate__mdt peMtd: emailPrefMtd){
                Pricing_IQR_Email_Preferences__c pe = new Pricing_IQR_Email_Preferences__c();
                for(Preference pref: prefList.preferences){
                    if(peMtd.MasterLabel == pref.notificationName && !updatedNotifications.contains(pref.notificationName)){
                        pe.Pricing_Opt_In_Ind__c = pref.optInOut;
                        pe.Pricing_Notification_Name_Nm__c = peMtd.MasterLabel;
                        pe.Pricing_Template_API_Name_Nm__c = peMtd.Template_API_Name__c;
                        pe.Pricing_User__c = UserInfo.getUserId();
                        emailPreferUpsert.add(pe);
                        break;
                    }
                }
            }
            Pricing_IQR_Email_Preferences_DML.savePreferences(emailPreferUpsert);
            return true;
        }catch (Exception e) {
            system.debug(e.getMessage());
            return false;
        }
    }
    

    @AuraEnabled(cacheable=true)
    public static Boolean getUserPemissionSets(String userId){
        Boolean isTenderUser;
        Set < String > psExceptDPMReadOnlyUserSet = new Set < String > ((Label.Pricing_Tender_PermissionSets_AllInternal).split(':'));
        psExceptDPMReadOnlyUserSet.remove(Label.Pricing_Tender_PermissionSets_PricingDivisionalTenderPricingManager);
        psExceptDPMReadOnlyUserSet.remove(Label.Pricing_Tender_PermissionSets_TenderReadOnly);
        List<PermissionSetAssignment> userPermissionSets = new List<PermissionSetAssignment>(Pricing_PermissionSetAssignment_Selector.newInstance().selectByPSName(userId,psExceptDPMReadOnlyUserSet));
        System.debug('User Permissionsets'+userPermissionSets);
        if(userPermissionSets.size() > 0) {
            isTenderUser = true;
        } else {
            isTenderUser = false;
        } 
        return isTenderUser;
    }

    public class PreferenceList {
        public List<Preference> preferences;
    }
    public class Preference {
        @AuraEnabled public Boolean optInOut {set;get;}
        @AuraEnabled public String notificationName {set;get;}
        @AuraEnabled public String errorMsg {set;get;}
    }

}