public  Class  UserProperties {
        
        public Boolean partnerUser =false;       
        public Boolean partnerAgentUser =false ;     
        public Boolean externalUser =false;
        public string PartnerType ='';
        public Boolean ExtUser =false;
        public List<PermissionSetAssignment>  partDFAEUser;
        public Boolean isNACCase =false;
        public Boolean userHasAccess =false;
    

        public  userProperties(){
            partnerUser = Label.Core_Partner_Profile_Id.contains(String.valueOf(userInfo.getProfileId().substring(0, 15)));       
            partnerAgentUser = Label.Core_IPS_Agent_Partner_Profile_id.contains(String.valueOf(userInfo.getProfileId().substring(0, 15)));     
            externalUser = Network.getNetWorkid() != null? True:false;
            userHasAccess =  Label.Core_IPS_Agent_Profiles.contains(String.valueOf(userInfo.getProfileId().substring(0, 15)));       
        
            String authrPartnerType = Core_Utility.getPartnerUserType(userinfo.getuserid()); 
            if(authrPartnerType != null){
                if(authrPartnerType.split(';').size()>0)                
                    partnerType = authrPartnerType.split(';')[0];                 
            }

            String Extprof =  System.Label.Core_IPS_External_Customer_Profile_Ids;
            ExtUser = Extprof.contains(String.valueOf(userInfo.getProfileId().substring(0,15)));
            String prtDFAE = System.Label.Core_IPS_Partner_DFAE_Permission_Set; 
            partDFAEUser  = [Select id,AssigneeId  from PermissionSetAssignment where AssigneeId =: userInfo.getUserId() and PermissionSetId =:prtDFAE LIMIT 1];    
            
        }

    }