public without sharing class UCD_ACM_AddressVerificationDataModel {

    public class RequestBody{
        public List<RequestCrossWalk> crosswalks{set;get;}
        public String type{set;get;}
        public Attribute attributes{set;get;}
    }

    public class RequestCrossWalk{
        public String type{set;get;}
        public String value{set;get;}
    }

    public class Attribute{
        public List<AddressLineInfo> AddressLine1{set;get;}
        public List<AddressCityInfo> City{set;get;}
        public List<AddressStateInfo> StateProvince{set;get;}
        public List<AddressCountryInfo> Country{set;get;}
        public List<AddressZipInfo> Zip{set;get;}
    }

    public class AddressLineInfo{
        public String value{set;get;}
    }

    public class AddressCityInfo{
        public String value{set;get;}
    }

    public class AddressStateInfo{
        public String value{set;get;}
    }

    public class AddressCountryInfo{
        public String value{set;get;}
    }

    public class AddressZipInfo{
        public Zipvalue value{set;get;}
    }

    public class Zipvalue{
        public List<AddressZip5Info> Zip5;
    }
    public class AddressZip5Info{
        public String value{set;get;}
    }

    public class ResponseBody{
        public List<ResponseCrossWalk> crosswalks{set;get;}
        public ResponseAttribute attributes{set;get;}
    }
    public class ResponseCrossWalk{
        public String value{set;get;}
    }

    public class ResponseAttribute{
        public List<ResponseAddressLineInfo> AddressLine1{set;get;}
        public List<ResponseAddressCityInfo> City{set;get;}
        public List<ResponseAddressStateInfo> StateProvince{set;get;}
        public List<ResponseAddressCountryInfo> Country{set;get;}
        public List<ResponseAddressZipInfo> Zip{set;get;}
        public List<AddressVerificationstatus> VerificationStatus{set;get;}
    }

    public class ResponseAddressLineInfo{
        public String ov{set;get;}
        public String value{set;get;}
    }

    public class ResponseAddressCityInfo{
        public String ov{set;get;}
        public String value{set;get;}
    }

    public class ResponseAddressStateInfo{
        public String ov{set;get;}
        public String value{set;get;}
        public String lookupCode{set;get;}
        public String lookupError{set;get;}
    }

    public class ResponseAddressCountryInfo{
        public String ov{set;get;}
        public String value{set;get;}
    }

    public class AddressVerificationstatus{
        public String ov{set;get;}
        public String value{set;get;}
    }

    public class ResponseAddressZipInfo{
        public ResponseZipvalue value{set;get;}
    }

    public class ResponseZipvalue{
        public List<ResponseAddressZip5Info> Zip5;
        public List<ResponseAddressPostalCodeInfo> PostalCode;
    }

    public class ResponseAddressZip5Info{
        public String ov{set;get;}
        public String value{set;get;}
    }

    public class ResponseAddressPostalCodeInfo{
        public String ov{set;get;}
        public String value{set;get;}
    }
}