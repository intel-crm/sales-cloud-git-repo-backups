trigger Core_MDF_ErrorLogging on Core_MDF_Error_Logging__e (after insert) {
    for (Core_MDF_Error_Logging__e event : Trigger.New) {
       Core_MDF_CCP_UtilityClass.logSeverityErrorWithPE(event);
    }

}