public class JsonParser{ // please update the name as this is causing issues in existing classes where standard JSONParser is used
    public DPAHeader DPAHeader{get;set;}
    public class DPAListLIST{
        public DPALine  DPALine {get;set;}
    }
    public class DPALine {
        public String Name{get;set;}
        public Integer LowerBound{get;set;}
        public Integer UpperBound{get;set;}
        public String Id{get;set;}
    }
    public class DPAHeader{
        public String SAP{get;set;}
        public String Submitter{get;set;}
        public String SubmittetEmail{get;set;}
        public String Name{get;set;}
        public DPAListLIST DPAListLIST{get;set;}
        public String Id{get;set;}
    }
}