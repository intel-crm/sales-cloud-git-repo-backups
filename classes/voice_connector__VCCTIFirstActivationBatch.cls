/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class VCCTIFirstActivationBatch implements Database.AllowsCallouts, Database.Batchable<voice_connector.VCCall> {
    global Date endDate;
    global String processedBy;
    global Date startDate;
    global voice_connector__VCCTISettings__mdt vcctiSetting;
    global VCCTIFirstActivationBatch(Date endDate, Date startDate, voice_connector__VCCTISettings__mdt vcctiSetting) {

    }
}
