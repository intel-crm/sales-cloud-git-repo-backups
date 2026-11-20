/********************************************************************************************************************************************************************
        Apex Class Name:  Core_IQR_PIM_IntelProductDataScheduler
        Version     : 1.0 
        Created Date: 05/17/2022
        Function    : Batch class to update product data from PIM. Product attributes for update are maxTDP, CoreCount
        
        Modification Log:
        * Developer                   Date                   Description
        * ----------------------------------------------------------------------------                 
        * Shijas KM              05/17/2022   
        * Core_IQRPIMIntelProductDataScheduler          
        *******************************************************************************************************************************************************************/
        public class Core_IQRPIMIntelProductDataScheduler {
            @InvocableMethod
            public static void Core_IQRPIMIntelProductDataScheduler() { 
                Database.executeBatch(new Core_IQR_PIM_IntelProductData(),1); 
            }
        }