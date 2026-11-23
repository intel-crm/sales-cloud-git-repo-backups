/****************************************************************************************************
Apex Class Name : PSG_MSVPBusinessLogic
Version         : 1.0 
Created Date    : 01/06/2021
Function        : This class is used as part of MSVP trigger
Modifications   :
*****************************************************************************************************
* Developer                   Date                   Description
* ----------------------------------------------------------------------------                 
* Hema                     01/06/2021               Created
*****************************************************************************************************/
@isTest
public without sharing class PSG_MSVPBusinessLogic {

    /*public static void beforeInsertUpdateOperations(List < price_msvp__c > newList, Map < Id, price_msvp__c > oldMap, Boolean isInsert) {
        try {
            list < price_msvp__c > msvpList = new list < price_msvp__c > ();
            Map < Id, price_msvp__c > msvpOldMap = new Map < Id, price_msvp__c > ();
            
            set < Id > productIdSet = new set < Id > ();
            set < String > productOPNSet = new set < String > ();
            for (price_msvp__c msvpObj: newList) {
                msvpObj.price_prototype_amt__c = msvpObj.price_prototype_amt__c != null ? msvpObj.price_prototype_amt__c : 0;
                if (isInsert){
                    msvpList.add(msvpObj);
                    if (msvpObj.core_cpq_product_nm__c != null) {
                        productIdSet.add(msvpObj.core_cpq_product_nm__c);
                    } else if (msvpObj.core_cpq_effective_date_dt__c != null && msvpObj.core_cpq_product_opn__c != null) {
                        productOPNSet.add(msvpObj.core_cpq_product_opn__c);
                    } else {

                    }
                } else {
                    if (msvpObj.core_cpq_product_nm__c != oldMap.get(msvpObj.Id).core_cpq_product_nm__c) {
                        msvpList.add(msvpObj);
                        productIdSet.add(msvpObj.core_cpq_product_nm__c);
                    }
                }
            }
            if (!msvpList.isEmpty()) {
                Map < Id, Product2 > productMap = new Map < Id, Product2 > ();
                Map < String, Product2 > productOPNWithProductMap = new Map < String, Product2 > ();
                list < price_msvp__c > msvpExistingList = new list < price_msvp__c > ();
                Map < Id, price_msvp__c > msvpExistingMap = new Map < Id, price_msvp__c > ();
                for (price_msvp__c msvp: [SELECT Id, Name, core_cpq_product_nm__c, core_cpq_effective_date_dt__c, core_cpq_isactive__c
                        FROM price_msvp__c
                        WHERE(core_cpq_isactive__c = true OR core_cpq_effective_date_dt__c >= TODAY)
                        and core_cpq_product_nm__c IN: productIdSet
                        Order by core_cpq_effective_date_dt__c asc
                    ]) {
                    msvp.core_cpq_isactive__c = false;
                    if (!msvpExistingMap.isEmpty() && msvpExistingMap.containsKey(msvp.core_cpq_product_nm__c)) {
                        if (msvpExistingMap.get(msvp.core_cpq_product_nm__c).core_cpq_effective_date_dt__c >= msvp.core_cpq_effective_date_dt__c) {
                            msvpExistingMap.put(msvp.core_cpq_product_nm__c, msvp);
                        }
                    } else {
                        msvpExistingMap.put(msvp.core_cpq_product_nm__c, msvp);
                    }

                    msvpExistingList.add(msvp);
                }
                if (!msvpExistingList.IsEmpty()) {
                    update msvpExistingList;
                }

                for (Product2 prod: [SELECT Name, Core_OPN__c FROM Product2 WHERE Id =: productIdSet OR Core_OPN__c =: productOPNSet]) {
                    if (prod.Core_OPN__c != null && productOPNSet.contains(prod.Core_OPN__c)) {
                        productOPNWithProductMap.put(prod.Core_OPN__c, prod);
                    }
                    productMap.put(prod.Id, prod);
                }
                for (price_msvp__c msvpObj: msvpList) {
                    if (!productMap.isEmpty() && productMap.containsKey(msvpObj.core_cpq_product_nm__c)) {
                        msvpObj.core_cpq_product_name_txt__c = productMap.get(msvpObj.core_cpq_product_nm__c).Name;
                        msvpObj.core_cpq_product_opn__c = productMap.get(msvpObj.core_cpq_product_nm__c).Core_OPN__c;
                        if (!msvpExistingList.isEmpty() && msvpObj.core_cpq_effective_date_dt__c == System.today() && msvpExistingMap.containsKey(msvpObj.core_cpq_product_nm__c)) {
                            for (price_msvp__c msvpInactive: msvpExistingMap.values()) {
                                if (msvpObj.core_cpq_effective_date_dt__c > msvpInactive.core_cpq_effective_date_dt__c) {
                                    msvpObj.core_cpq_isactive__c = true;
                                } else if (msvpObj.core_cpq_effective_date_dt__c < msvpInactive.core_cpq_effective_date_dt__c) {
                                    msvpObj.core_cpq_isactive__c = false;
                                    msvpInactive.core_cpq_isactive__c = true;
                                    msvpOldMap.put(msvpInactive.Id, msvpInactive);
                                } else if (msvpObj.core_cpq_effective_date_dt__c == msvpInactive.core_cpq_effective_date_dt__c) {
                                    msvpObj.core_cpq_isactive__c = true;
                                }
                            }
                        } else if (msvpObj.core_cpq_effective_date_dt__c <= System.today()) {
                            msvpObj.core_cpq_isactive__c = true;
                        } else {
                            msvpObj.core_cpq_isactive__c = false;
                        }
                    }
                    if (!productOPNSet.isEmpty()) {
                        if (!productOPNWithProductMap.isEmpty() && productOPNWithProductMap.containsKey(msvpObj.core_cpq_product_opn__c)) {
                            msvpObj.core_cpq_product_name_txt__c = productOPNWithProductMap.get(msvpObj.core_cpq_product_opn__c).Name;
                            msvpObj.core_cpq_product_nm__c = productOPNWithProductMap.get(msvpObj.core_cpq_product_opn__c).Id;
                        } else {
                            msvpObj.addError('OPN ' + msvpObj.core_cpq_product_opn__c +' is Invalid');
                        }
                    }
                }
                if (!msvpOldMap.IsEmpty()) {
                    update msvpOldMap.values();
                }
            }
        } catch (Exception ex) {
            PSG_Utility.logError(ex);
        }
    }*/
}