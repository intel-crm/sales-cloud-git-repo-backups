global without sharing class  Core_SAPXMLUtility {
    public class ListOfAccountEaiAltera{ 
        public List<AccountEaiAltera> listAccountEaiAltera = new List<AccountEaiAltera>();
    }
    
    public class AccountEaiAltera{
        public String expressStationId = null;
        public String trainStationId = null;
        public String name = null;
        public String sAPAccountNumber = null;
        public String freightTerms = null;
        public String type = null;
        public String x_ALT_PAYTERMS = null;
        public String x_ALT_SAP_ACCT_TYPE = null;
        public String shippingCondition = null;
        public String streetAddress = null;
        public String streetAddress2 = null;
        public String city = null;
        public String province = null;
        public String state = null;
        public String country = null;
        public String postalCode = null;
        public String regionCode = null;
        public String salesOrganization = null;
        public String nielsenId = null;
        public String distyChannel = null;
        public String shipToEndCustomer = null;
        public String industryCode1 = null;
        public String shippingInstructions = null;
        public String accountName2 = null;
        public String parentAccountTier = null;
        
        //public String isPricingParent = null;
        public List<Shipto_Partner> shipToPartList = new List<Shipto_Partner>();
        //public Shipto_Partner shipToPart = new Shipto_Partner();
    }
    
    public class Shipto_Partner{ 
        Public String shipto=null;
        Public String shiptoExpressStationID=null;        
    }

    global  class JsonResponse{ 
         Public List<JsonResult> results = new List<JsonResult>();
    }
     public class JsonResult{ 
        public String Status = null;
        public String SourceType =null;
        public String SAPAccountNumber = null;
        public String ExpressStationId = null;
        public String TrainStationID = null;
        public String Message = null;
    }
}