public class PRM_AcountContactMembershipWrapper {
	@AuraEnabled
        public string acrRecord{get;set;}

        @AuraEnabled
        public string partnerRole{get;set;}
        
        @AuraEnabled
        public List<ChannelProgramWrapper> channelList{get;set;}
        
        public class ChannelProgramWrapper{
            @AuraEnabled
            public string channelProgramlevelName{get;set;}
            @AuraEnabled
            public string channelProgramlevelId{get;set;}
        }
}