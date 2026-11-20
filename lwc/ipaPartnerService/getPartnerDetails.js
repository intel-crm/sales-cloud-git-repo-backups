/**
 * Get Partner Details
 * @param {Object} params @AuraEnabled Method Parameters
 * @param {string} params.id Partner ID
 * @returns {Partner} Partner (id, attributes, specialties, longDescription)
 * @function getPartnerDetails
 * @memberof ipaPartnerService
 *
 * @example
 * ...
*/

//import MockData from 'c/ipaMockData';
import getAttribute from '@salesforce/apex/PMP_SearchAttributeNewController.getAttributes';
import userLang from '@salesforce/i18n/lang';

const isDistributor = () => {
    let isDisti = false;

    if(window.location.href.match('distributor') ? true : false){
        isDisti = true;
    }
    console.log('check isdisti : ' , isDisti);
    return isDisti;
}

export default ({ id }) => {
    window.console.log(':::getProdAttribute:::', id);
    let error='';
    return getAttribute({partnerOrOffId: id, langCode: userLang})
        .then(result => {
            window.console.log('result id :: ', id, ':::', result);
            if(result) {
                let specialties = [];
                let res = result[id];
                let attributes = [];
                if(!isDistributor()){
                    specialties = result['Specialty']; 
                    console.log('Specialties : ', specialties);
                }
                
                let longDesc = result['Description'];

                if(res) {
                    res.forEach(function(res, i) {
                        
                        let types = res.types;
                        let type = [];

                        if(types && types.length > 0) {
                            types.forEach(function(r, i) {
                                type.push(r.name);
                            });
                            let data = { title: res.name, values: type };
                            attributes.push(data);
                        }
                    });
                }
                window.console.log(':::attributes:::', result);
                return Promise.resolve({
                    id,
                    attributes: attributes, 
                    specialties: specialties,
                    longDescription: longDesc
                });
            }
        })
        .catch(error => {
            error = error;
            window.console.log('result : ', error);
        });
    }