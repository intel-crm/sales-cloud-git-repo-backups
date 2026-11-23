/*************************************************************************************************************************************************************************
* Class Name  : Intel_CheckboxOption 
* Version     : 1.0 
* Created Date: 4/25/2019
* Modification Log : Original Version
* Description : This wrapper class is used in Create Offering functionality. Used in MarketplaceCreateProductController.Apex 
*
* Developer         Modification Log                Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 
**************************************************************************************************************************************************************************/
public class Intel_CheckboxOption extends Intel_Input{
    
    public String label { get; set; }
    public String value { get; set; }
    public Boolean checked { get; set; } // set to true if initial value is checked
    public Map<String, String> additionalValues { get; set; }
    public Boolean labelOnly { get; set; } // removes checkbox
    public Boolean prerelease { get; set; } // Gireesh:US581383: prereleaseflag
    public List<Intel_CheckboxOption> children { get; set; }
    
    // alternative child inputs
    public String subType { get; set; } // can be 'text' or 'radio'
    // TEXT
    public String textSubType { get; set; } // can be 'number', 'email', etc.
    public String textValue { get; set; } // initial populated value if type: text
    // RADIO
    public List<Intel_RadioOption> radioOptions { get; set; } // radio options if type: radio
    
    // constructors
    public Intel_CheckboxOption(String lab, String val) { label = lab; value = val; children = new List<Intel_CheckboxOption>(); }
    public Intel_CheckboxOption(String lab, String val, String subType) {
        label = lab; value = val; subType = subType;
        if (subType == 'text') textValue = '';
        if (subType == 'radio') radioOptions = new List<Intel_RadioOption>();
    }
    
    
    
}