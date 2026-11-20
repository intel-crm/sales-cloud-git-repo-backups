/****************************************************************************************************** 
Class Name:         Core_MDF_PFR_Utility
@parameters:        N/A
Description:        Utility Class for PartnerFundRequest to fetch Various metadata Records
Added By:           SS   24-12-2019
Modified By:        Date:           Changes:

*******************************************************************************************************/
public without sharing class Core_MDF_PFR_Utility {
	/****************************************************************************************************** 
    Method Name:        insertPFR
    @return  :          void
    @parameters:        PartnerFundRequest
    Description:        inserts the PFR Record
    Added By:           SB - 03/22/2020
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static void insertPFR(PartnerFundRequest pfrRecord){
        if(pfrRecord != NULL){
            insert pfrRecord;
        }
    }
    
    /****************************************************************************************************** 
    Method Name:        updatePFR
    @return  :          void
    @parameters:        PartnerFundRequest
    Description:        updates the PFR Record
    Added By:           SB - 03/22/2020
    Modified By:        Date:      Changes: 
    *******************************************************************************************************/
    public static void updatePFR(PartnerFundRequest pfrRecord){
    	if(pfrRecord != NULL){
            update pfrRecord;
	}
    }
}