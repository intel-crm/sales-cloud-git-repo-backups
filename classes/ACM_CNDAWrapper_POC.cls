public class ACM_CNDAWrapper_POC {
    public String success;
    public String message;
    public List<ResultRecord> result;
    
    public ACM_CNDAWrapper_POC()
    {
        //Do Nothing
    }
    
    public class ResultRecord
    {
        public String contract_type0;
        public String contract_subtype;
        public String counterparty_name;
        public String contract_number;
        public String counterparty_address_line_1;
        public String counterparty_country;
        public String counterparty_state_province;
        public String counterparty_city;
        public String counterparty_zip_or_postal_code;
    }    

}