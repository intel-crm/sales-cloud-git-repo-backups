/*************************************************************************************************************************************************************************
* Class Name  : Intel_DropdownOption 
* Version     : 1.0 
* Created Date: 4/25/2019
* Modification Log : Original Version
* Description : This wrapper class is used in Create Offering functionality. Used in MarketplaceCreateProductController.Apex 
*
* Developer         Modification Log                Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 
**************************************************************************************************************************************************************************/
public class Intel_DropdownOption {
	  public String label { get; set; }
      public String value { get; set; }
      public String businessSegments {get;set;} //added by Abhishek US523547
      //public String defaultValue { get; set; }// check who added this field as it is not given by DRACO
      public Boolean disabled { get; set; }
      public Boolean required { get; set; }
      public Intel_DropdownOption(String lab, String val) { label = lab; value = val; }
}