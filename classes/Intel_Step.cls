/*************************************************************************************************************************************************************************
* Class Name  : Intel_Step
* Version     : 1.0 
* Created Date: 4/25/2019
* Modification Log : Original Version
* Description : This wrapper class is used in Create Offering functionality. Used in MarketplaceCreateProductController.Apex 
*
* Developer         Modification Log                Date                                            Description
* ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
* 
**************************************************************************************************************************************************************************/
public class Intel_Step {
      public String name { get; set; }
      public List<Intel_Section> sections { get; set; } { sections = new List<Intel_Section>(); }
      public Intel_Step(String n) { name = n; }
    }