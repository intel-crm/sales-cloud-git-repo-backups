/*************************************************************************************************************************************************************************
* Class Name  : Intel_Radiobutton 
* Version     : 1.0 
* Created Date: 4/25/2019
* Modification Log : Original Version
* Description : This wrapper class is used in Create Offering functionality. Used in MarketplaceCreateProductController.Apex 
*
* Developer         Modification Log                Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 
**************************************************************************************************************************************************************************/
public class Intel_RadioOption extends Intel_Input{
      public String label { get; set; }
      public String value { get; set; }
      public string valueType { get; set; }
      //Prakash : 06/06 public String defaultValue { get; set; }
      public Boolean isSelected { get; set; } // set to true for initial value
      public List<Intel_RadioOption> children { get; set; }
      public Intel_RadioOption(String lab, String val) { label = lab; value = val; children = new List<Intel_RadioOption>(); }
    }