/*************************************************************************************************************************************************************************
* Class Name  : Intel_Text
* Version     : 1.0 
* Created Date: 4/25/2019
* Modification Log : Original Version
* Description : This wrapper class is used in Create Offering functionality. Used in MarketplaceCreateProductController.Apex 
*
* Developer         Modification Log                Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 
**************************************************************************************************************************************************************************/
// TEXT - https://developer.salesforce.com/docs/component-library/bundle/lightning:input
public class Intel_Text extends Intel_Input {
      { type = 'text'; }
      public String subType { get; set; }
      public String label { get; set; }
    public String valueType { get; set; }	//default or complex
    public Map<String, String> additionalValues{ get; set; }	//holds additional values if it's complex valueType
    public String textValue{ get; set; }
    public Intel_Text() { subType = 'text'; valueType='default';}
    public Intel_Text(String s) { subType = s; valueType='default';} 
    
    /* { type = 'text'; }
      public String subType { get; set; }
      public String label { get; set; }
      public String textValue { get; set; }
      public Intel_Text() { subType = 'text'; }
      public Intel_Text(String s) { subType = s; }*/
}