/****************************************************************************************************************************************
* Class Name  : Core_MDF_BankJSONParser
* Version     : 1.0
* Created Date: 11-02-2018
* Modification Log :
* Developer                     Date                            Description
* ---------------------------------------------------------------------------------------------------------------------------------------
* Varun Kumar                   11-02-2018                      Created for parsing the response from the ESD system
* Accenture - SB                25-06-2020                      Updated to bring in 2 more fields (bnk_nm_last_four_digits & bnk_curr) from ESD System
*****************************************************************************************************************************************/
public class Core_MDF_BankJSONParser {
    public String SUPPL_HLD_PMT_IND;        // ESD Hold Indicator
    public String bnfcy_nm;                 // Bank Beneficiary Name
    public String intrmd_bank_ind;          // Intermediary Indicator
    public String bnk_nbr;                  // Routing Number
    public String bnk_nm;                   // Bank Name
    public String ap_vndr_nbr;              // Supplier Number
    public String DUNS_NBR;                 // DUNS
    public String ctry_cd;                  // Country Code
    public String swift_cd;                 // Swift Code
    public String suppl_nm;                 // Supplier Name
    public String currency_cd;              // Bank Currency
    public String suppliercity;             // Bank Supplier City
    public String supplierregion;           // Bank Supplier Region
    public String supplierpostal;           // Bank Supplier Postal
    public String suppliercountry;          // Bank Supplier Country

    /*****************************************************************************************************************************************
    Method Name:                                             parse
    @return    :
    @parameters:                                             String json
    Added By   :                                             Varun Kumar  -  11-02-2018
    Modified By:                  Date:                      Changes:
    *****************************************************************************************************************************************/
    public static List<Core_MDF_BankJSONParser> parse(String json) {
        return (List<Core_MDF_BankJSONParser>) System.JSON.deserialize(json, List<Core_MDF_BankJSONParser>.class);
    }
}