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
        public String Name{get;set;}
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
        public String Name{get;set;}
  }
    
    /*global class PCC_ResponseBodyWrapper{
        public PCC_MasterData_ErrorWrapper errWrp{get;set;}
        public PCC_MasterData_SuccessWrapper successWrp{get;set;}
        public Boolean IsError{get;set;}
        public Boolean IsSuccess{get;set;}
    }*/

    global class SalesforceResponseWrapper{
        public Integer StatusCode{get;set;}
        public String Status{get;set;}
        public Integer ErrorCode{get;set;}
        public String ResponseBody{get;set;}
        public String RecordId{get;set;}
        public String Name{get;set;}
  }
        
    global class restAPIResponseWrapper{
        public Integer StatusCode{get;set;}
        public String Status{get;set;}
        public Integer ErrorCode{get;set;}
        public restAPIInnerResponseWrapper ResponseBody{get;set;}
        public String RecordId{get;set;}
        public String Name{get;set;}
    }
    
    global class restAPIInnerResponseWrapper{
        public String ExternalId{get;set;}
        public String Message{get;set;}
    }
    global class PCC_DRDetailsWrapper{
        Public Integer failedRecordCount{get;set;}
        Public Integer successfulRecordCount{get;set;}
        Public List<restAPIResponseWrapper> respList{get;set;}
        Public String errorMsgForLogEntry{get;set;}
        
        public PCC_DRDetailsWrapper() {
        	respList = new List<restAPIResponseWrapper>();
    	}
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
        Public String designType { get; set; }
        Public String odmBoardPartner { get; set; }
        Public String militaryAerospaceGvrnmtUseInd{get;set;}
        Public String verticalMarket{get;set;}
        Public String externalId{get;set;}
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
        Public String endCustomerUrl{get;set;}
        Public String manufacturingRegion{get;set;}
        Public Date designDecisionDate{get;set;}
        Public Date firstCustomerShipDate{get;set;}
        Public Date productionEndDate{get;set;}
        Public String intelPlatform{get;set;}
        Public String designRegistrationName{get;set;}
        Public String description{get;set;}
        Public String status{get;set;}
        Public String rejectionReason{get;set;}
        Public String rejectionComment{get;set;}
        Public String opportunityId{get;set;}
        Public String designSolutionNetwork{get;set;}
        Public String mindsMessage{get;set;}
        Public String fpgaQuoteComments{get;set;}
        Public String partnerAccount{get;set;}
        Public String endCustomerAccount{get;set;}
        Public String intelTechnicalOwner{get;set;} 
        
     }  

    global class PCC_allDdrDetailsWrapper{
        Public PCC_DesignRegDetailsWrapper DesignRegistrationDetails{get;set;}
        Public List<PCC_DDRDetailsWrapper> AssociatedDesignRegistrationProducts{get;set;}
        Public List<PCC_l4l5DetailsWrapper> AssociatedProducts{get;set;}
    }

    global class PCC_checkDdrDrp{
        Public Map<String, Integer> mapOfDrToDRPCnt{get;set;}
        Public Map<String, String> mapOfDrToDrstatus{get;set;}
    }

    global class restAPIDDRDetailsWrapper{
        public Integer StatusCode{get;set;}
        public String Status{get;set;}
        public Integer ErrorCode{get;set;}
        public PCC_allDdrDetailsWrapper ResponseBody{get;set;}
        public String RecordId{get;set;}
        public String Name{get;set;}
    }  
    global class restAPIDDRDetailsWrapper1{
        public Integer StatusCode{get;set;}
        public String Status{get;set;}
        public Integer ErrorCode{get;set;}
        public PCC_DesignRegDetailsWrapper ResponseBody{get;set;}
        public String RecordId{get;set;}
        public String Name{get;set;}
    }  

    global class PCC_DDRDetailsWrapper{
        Public String name{get;set;}
        Public String id{get;set;}
        Public String designRegId{get;set;}
        Public String productId{get;set;}
        Public Decimal quantity{get;set;}
        Public Date retiredAsOf{get;set;}
        Public String externalId{get;set;}
        Public Decimal targetResaleAmt{get;set;}
        Public String targetResalePriceNote{get;set;}
        Public String status{get;set;}
        Public String comment{get;set;}
        Public String partnerTrackingNumber{get;set;}
        Public Decimal productListPrice{get;set;}
        Public Decimal fullYearValueAmt{get;set;}
        Public String opportunityProductId{get;set;}
        Public String orderingId{get;set;}
        Public String mmId{get;set;}
        Public String oldMMId{get;set;}
        Public String l4ProductName{get;set;}
        Public String l5ProductName{get;set;}
    }
    global class PCC_restAPIDDRDetailsWrapper{
        public Integer StatusCode{get;set;}
        public String Status{get;set;}
        public Integer ErrorCode{get;set;}
        public PCC_DDRDetailsWrapper ResponseBody{get;set;}
        public String RecordId{get;set;}
        public String Name{get;set;}
    }
    global class PCC_l4l5DetailsWrapper{
        Public String mmid{get;set;}
        Public String orderingCode{get;set;}
        //Public String oldMMid{get;set;}
        Public String l4Product{get;set;}
        Public String l5Product{get;set;}
    }
    global class PCC_restAPIl4l5DetailsWrapper{
        public Integer StatusCode{get;set;}
        public String Status{get;set;}
        public Integer ErrorCode{get;set;}
        public PCC_l4l5DetailsWrapper ResponseBody{get;set;}
        public String RecordId{get;set;}
    }
    global class PCC_restAPIParnterLed_Price{
        public Integer StatusCode{get;set;}
        public String Status{get;set;}
        public Integer ErrorCode{get;set;}
        public PCC_ParnterLed_Price ResponseBody{get;set;}
        public String RecordId{get;set;}
    }
    global class PCC_parnterLed_Price{
        Public String mmid{get;set;}
        Public String orderingCode{get;set;}
        Public String oldMMid{get;set;}
        Public Decimal StandardDistiPrice{get;set;}
        Public Decimal RecommendedCustomerPrice{get;set;}
    }
     global class PCC_restAPIPayment_Eligible{
        public Integer StatusCode{get;set;}
        public String Status{get;set;}
        public Integer ErrorCode{get;set;}
        public PCC_paymentInfo_Price ResponseBody{get;set;}
        public String RecordId{get;set;}
    }
    global class PCC_paymentInfo_Price{
        Public String mmid{get;set;}
        Public String orderingCode{get;set;}
        Public String oldMMid{get;set;}
        Public Date   DDIProgramPaymentExpirationDate{get;set;}
        Public String DDIProgramPaymentEligible{get;set;}
        Public String DDIProgramPayRateNAREMEA {get;set;}
	    Public String DDIProgramPayRateAPJPRC {get;set;}
        
    }
    global class PCC_paymentInfo_Price11testdummy{
        Public String mmid{get;set;}
        Public String orderingCode{get;set;}
        Public String oldMMid{get;set;}
        Public Date   DDIProgramPaymentExpirationDate{get;set;}
        Public String DDIProgramPaymentEligible{get;set;}
        Public String DDIProgramPayRate{get;set;}
        
    }
    

}