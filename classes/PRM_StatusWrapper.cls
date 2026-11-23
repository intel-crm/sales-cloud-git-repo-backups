Public class PRM_StatusWrapper{
        public PRM_Registration_Request__c registration{set;get;}
        public Boolean isSuccess{set;get;}
        public boolean ACRCheck{set;get;}
        public boolean subCheck{set;get;}        
        public string regType{set;get;}
        public boolean EntitlementCheck{set;get;}
        public boolean BenefitCheck{set;get;} 
}