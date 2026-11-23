/*************************************************************************************************************************************
Apex Class Name     : PCC_Wrapper
Version             : 
Created Date        : May 2023
************************************************************************************************************************************************/
global class PCC_Wrapper {
    
    global class PCC_MasterData_SuccessWrapper{
        public Integer StatusCode{get;set;}
        public String Status{get;set;}
        public Integer ErrorCode{get;set;}
        public Map<String, List<PCC_PicklistWrapper>> ResponseBody{get;set;}
        public String RecordId{get;set;}
	}
    
    global class PCC_PicklistWrapper{
        public String Label{get;set;}
        public String ApiName{get;set;}
        //public Boolean IsActive{get;set;}
    }
    
    global class PCC_MasterData_ErrorWrapper{
        public Integer StatusCode{get;set;}
        public String Status{get;set;}
        public Integer ErrorCode{get;set;}
        public String ResponseBody{get;set;}
        public String RecordId{get;set;}
	}

    global class SalesforceResponseWrapper{
        public Integer StatusCode{get;set;}
        public String Status{get;set;}
        public Integer ErrorCode{get;set;}
        public String ResponseBody{get;set;}
        public String RecordId{get;set;}
	}
    
    global class PCC_ReqiredDRFieldsCheckWrapper{
        Public Map<String, List<String>> mapFieldsToDrRec{get;set;}
        Public Map<String, Core_Design_Registration__c> mapExtIdToDRRec{get;set;}
        Public List<Core_Design_Registration__c> listDrRecsWithExtId{get;set;}
    }

    global class PCC_Update_DDRRequestWrapper{
        Public String name{get;set;}
        public String productGroup{get;set;}
        public String militaryAerospaceGvrnmtUseInd{get;set;}
        public String verticalMarket{get;set;}
        public String productSegment{get;set;}
        public String productApplication{get;set;}
        public String recOrExtId{get;set;}        
        Public String opportunityVolume{get;set;}
        Public String partnerFAE{get;set;}
        Public String partnerFSR{get;set;}
        Public String endCustomerName{get;set;}
        Public String endCustomerAddress1{get;set;}
        Public String endCustomerAddress2{get;set;}
        Public String endCustomerPostalCode{get;set;}
        Public String endCustomerCountry{get;set;}
        Public String endCustomerCity{get;set;}
        Public String endCustomerState{get;set;}
        Public String endCustomerContactTitle{get;set;}
        Public String endCustomerContactName{get;set;}
        Public String endCustomerContactEmail{get;set;}
        Public String endCustomerContactPhone{get;set;}
        Public String manufacturingRegion{get;set;}
        Public String designDecisionDate{get;set;}
        Public Date firstCustomerShipDate{get;set;}
        Public String productionEndDate{get;set;}
        Public String intelPlatform{get;set;}
        Public String designRegistrationName{get;set;}
        Public String description{get;set;}
        Public String uniqueId{get;set;}
    }
    
    global class restAPIResponseWrapper{
        public Integer StatusCode{get;set;}
        public String Status{get;set;}
        public Integer ErrorCode{get;set;}
        public restAPIInnerResponseWrapper ResponseBody{get;set;}
        public String RecordId{get;set;}
    }
    
    global class restAPIInnerResponseWrapper{
        public String ExternalId{get;set;}
        public String Message{get;set;}
    }
    global class PCC_DRDetailsWrapper{
        Public Integer failedRecordCount{get;set;}
        Public Integer successfulRecordCount{get;set;}
        Public List<restAPIResponseWrapper> respList{get;set;}
    }
    global class PCC_DRDetailsWrapperForPut{
        Public Integer failedRecordCount{get;set;}
        Public Integer successfulRecordCount{get;set;}
        Public List<SalesforceResponseWrapper> respList{get;set;}
    }
    
    global class PCC_DDRProductWrapper{
        public String productId{get;set;}
        public String DesignRegId{get;set;}
        public String quantity{get;set;}
        public String status{get;set;}
        public String retiredAsOf{get;set;}
        public String externalId{get;set;}
    }
     
     global class PCC_DesignRegDetailsWrapper{
        Public String name{get;set;}
        Public String productGroup{get;set;}
        Public String productSegment{get;set;}
        Public String productApplication{get;set;}
        Public String militaryAerospaceGvrnmtUseInd{get;set;}
        Public String verticalMarket{get;set;}
        Public String uniqueId{get;set;}
        Public String opportunityVolume{get;set;}
        Public String partnerFAE{get;set;}
        Public String partnerFSR{get;set;}
        Public String endCustomerName{get;set;}
        Public String endCustomerAddress1{get;set;}
        Public String endCustomerAddress2{get;set;}
        Public String endCustomerPostalCode{get;set;}
        Public String endCustomerCountry{get;set;}
        Public String endCustomerCity{get;set;}
        Public String endCustomerState{get;set;}
        Public String endCustomerContactTitle{get;set;}
        Public String endCustomerContactName{get;set;}
        Public String endCustomerContactEmail{get;set;}
        Public String endCustomerContactPhone{get;set;}
        Public String manufacturingRegion{get;set;}
        Public String designDecisionDate{get;set;}
        Public Date firstCustomerShipDate{get;set;}
        Public String productionEndDate{get;set;}
        Public String intelPlatform{get;set;}
        Public String designRegistrationName{get;set;}
        Public String description{get;set;}
    }
    
    global class restAPIDDRDetailsWrapper{
        public Integer StatusCode{get;set;}
        public String Status{get;set;}
        public Integer ErrorCode{get;set;}
        public PCC_DesignRegDetailsWrapper ResponseBody{get;set;}
        public String RecordId{get;set;}
    }  

}